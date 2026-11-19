package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.inventory.InventoryWasteLog;
import model.dto.inventory.OrderCancellationData;
import model.dto.inventory.TransitDamageData;
import model.dto.inventory.WasteStatisticDTO;
import model.dto.order.SubOrderDTO;
import model.entity.order.ShippingAddress;
import util.DBContext;
import enums.WasteStage;
import enums.TransactionType;

public class InventoryWasteDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(InventoryWasteDAO.class.getName());
    private static final java.time.format.DateTimeFormatter DATE_FMT = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public InventoryWasteDAO() {
    }


    public boolean recordManualWaste(long shopId, long variantId, int quantity, String reasonNote, Long loggedBy) {
        return recordManualWaste(shopId, variantId, WasteStage.WAREHOUSE_EXPIRED.name(), quantity, reasonNote, loggedBy);
    }

    public boolean recordManualWaste(long shopId, long variantId, String wasteStage, int quantity, String reasonNote, Long loggedBy) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn) {
            conn.setAutoCommit(false);

            String checkSql = "SELECT pv.stock_quantity, pv.price, pv.unit, p.shop_id "
                    + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "WHERE pv.variant_id = ? AND p.shop_id = ?";
            int currentStock = 0;
            BigDecimal price = BigDecimal.ZERO;
            String unit = "kg";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setLong(1, variantId);
                psCheck.setLong(2, shopId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        currentStock = rs.getInt("stock_quantity");
                        price = rs.getBigDecimal("price");
                        unit = rs.getNString("unit");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (currentStock < quantity || quantity <= 0) {
                conn.rollback();
                return false;
            }

            // 1. Trừ tồn kho tự động trong product_variants
            String updateStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity - ?, updated_at = CURRENT_TIMESTAMP WHERE variant_id = ?";
            try (PreparedStatement psStock = conn.prepareStatement(updateStockSql)) {
                psStock.setInt(1, quantity);
                psStock.setLong(2, variantId);
                psStock.executeUpdate();
            }

            // 2. Cập nhật lô hàng tương ứng (nếu có bảng product_batches)
            try {
                String updateBatchSql = "UPDATE product_batches SET current_quantity = CASE WHEN current_quantity >= ? THEN current_quantity - ? ELSE 0 END WHERE variant_id = ?";
                try (PreparedStatement psBatch = conn.prepareStatement(updateBatchSql)) {
                    psBatch.setInt(1, quantity);
                    psBatch.setInt(2, quantity);
                    psBatch.setLong(3, variantId);
                    psBatch.executeUpdate();
                }
            } catch (SQLException ignored) {
                // Bỏ qua nếu bảng batches không tồn tại
            }

            // 3. Ghi log tiêu hủy trực tiếp vào bảng duy nhất inventory_transactions
            String stage = (wasteStage != null && !wasteStage.isBlank()) ? wasteStage.trim() : WasteStage.WAREHOUSE_EXPIRED.name();
            BigDecimal totalLoss = price.multiply(BigDecimal.valueOf(quantity));
            String insertSql = "INSERT INTO inventory_transactions (shop_id, variant_id, batch_id, sub_order_id, user_id, "
                    + "transaction_type, waste_stage, quantity_changed, previous_stock, new_stock, cost_price, estimated_loss, reason, created_at) "
                    + "VALUES (?, ?, NULL, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
            try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                psIns.setLong(1, shopId);
                psIns.setLong(2, variantId);
                psIns.setLong(3, loggedBy != null ? loggedBy : 3L);
                psIns.setString(4, stage);
                psIns.setString(5, stage);
                psIns.setInt(6, -quantity);
                psIns.setInt(7, currentStock);
                psIns.setInt(8, Math.max(0, currentStock - quantity));
                psIns.setBigDecimal(9, price);
                psIns.setBigDecimal(10, totalLoss);
                psIns.setNString(11, reasonNote);
                psIns.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "Error recording manual waste", ex);
            return false;
        } finally {
            closeQuietly(conn);
        }
    }


    /**
     * Bước 1: Lấy thông tin đơn hàng con và danh sách mặt hàng đã đặt.
     */
    private OrderCancellationData fetchOrderCancellationData(Connection conn, long subOrderId) throws SQLException {
        String fetchOrderSql = "SELECT so.shop_id, so.order_id, oi.variant_id, oi.quantity, oi.unit, oi.unit_price "
                + "FROM sub_orders so "
                + "JOIN order_items oi ON so.sub_order_id = oi.sub_order_id "
                + "WHERE so.sub_order_id = ?";

        OrderCancellationData data = new OrderCancellationData();
        try (PreparedStatement psFetch = conn.prepareStatement(fetchOrderSql)) {
            psFetch.setLong(1, subOrderId);
            try (ResultSet rs = psFetch.executeQuery()) {
                while (rs.next()) {
                    data.setShopId(rs.getLong("shop_id"));
                    data.setParentOrderId(rs.getLong("order_id"));
                    long varId = rs.getLong("variant_id");
                    int qty = rs.getInt("quantity");
                    String unit = rs.getString("unit");
                    BigDecimal price = rs.getBigDecimal("unit_price");
                    data.addItem(new Object[]{varId, qty, unit, price});
                }
            }
        }
        return data;
    }

    /**
     * Bước 2: Cập nhật trạng thái đơn hàng con sang CANCELLED.
     */
    private void updateSubOrderToCancelled(Connection conn, long subOrderId, String reason, Long loggedBy) throws SQLException {
        String updateStatusSql = "UPDATE sub_orders SET status = 'CANCELLED', cancel_reason = ?, "
                + "cancelled_by = ?, cancelled_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP "
                + "WHERE sub_order_id = ?";
        try (PreparedStatement psUp = conn.prepareStatement(updateStatusSql)) {
            psUp.setNString(1, reason);
            if (loggedBy != null) {
                psUp.setLong(2, loggedBy);
            } else {
                psUp.setNull(2, Types.BIGINT);
            }
            psUp.setLong(3, subOrderId);
            psUp.executeUpdate();
        }
    }

    /**
     * Bước 3: Đồng bộ trạng thái đơn cha sang CANCELLED (nếu tất cả đơn con đều đã bị hủy).
     */
    private void syncParentOrderStatus(Connection conn, long parentOrderId) throws SQLException {
        String syncParentSql = "UPDATE o SET o.order_status = 'CANCELLED', o.updated_at = CURRENT_TIMESTAMP "
                + "FROM orders o "
                + "WHERE o.order_id = ? "
                + "  AND NOT EXISTS ( "
                + "      SELECT 1 FROM sub_orders other "
                + "      WHERE other.order_id = o.order_id "
                + "        AND other.status <> 'CANCELLED' "
                + "  )";
        try (PreparedStatement psSync = conn.prepareStatement(syncParentSql)) {
            psSync.setLong(1, parentOrderId);
            psSync.executeUpdate();
        }
    }

    /**
     * Bước 4: Phân tách hoa quả: Quả hỏng ghi sổ hao hụt (QC_PACKING), quả lành hoàn lại kho bán.
     */
    private void processCancellationWasteAndRestock(Connection conn, long shopId, long subOrderId,
            List<Object[]> items, Map<Long, Integer> wastedQtyMap, String reason, Long loggedBy) throws SQLException {

        String insertWasteSql = "INSERT INTO inventory_transactions (shop_id, variant_id, batch_id, sub_order_id, user_id, "
                + "transaction_type, waste_stage, quantity_changed, previous_stock, new_stock, cost_price, estimated_loss, reason, created_at) "
                + "VALUES (?, ?, NULL, ?, ?, 'QC_PACKING', 'QC_PACKING', ?, 0, 0, ?, ?, ?, CURRENT_TIMESTAMP)";

        String restoreStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity + ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE variant_id = ?";

        String deductBatchSql = "UPDATE product_batches SET current_quantity = CASE WHEN current_quantity >= ? THEN current_quantity - ? ELSE 0 END, updated_at = CURRENT_TIMESTAMP "
                + "WHERE batch_id = (SELECT TOP 1 batch_id FROM product_batches WHERE variant_id = ? AND status = 'ACTIVE' ORDER BY expiry_date ASC)";

        try (PreparedStatement psWaste = conn.prepareStatement(insertWasteSql);
             PreparedStatement psRestore = conn.prepareStatement(restoreStockSql);
             PreparedStatement psBatchDeduct = conn.prepareStatement(deductBatchSql)) {

            boolean hasWaste = false;
            boolean hasRestore = false;

            for (Object[] item : items) {
                long varId = (long) item[0];
                int totalOrderedQty = (int) item[1];
                String unit = (String) item[2];
                BigDecimal price = (BigDecimal) item[3];

                int wastedQty = totalOrderedQty;
                if (wastedQtyMap != null && wastedQtyMap.containsKey(varId)) {
                    int userWasted = wastedQtyMap.get(varId);
                    wastedQty = Math.min(totalOrderedQty, Math.max(0, userWasted));
                }
                int goodQty = Math.max(0, totalOrderedQty - wastedQty);

                // Ghi sổ biến động kho (hao hụt phần nông sản bị dập hỏng)
                if (wastedQty > 0) {
                    BigDecimal loss = price.multiply(BigDecimal.valueOf(wastedQty));
                    psWaste.setLong(1, shopId);
                    psWaste.setLong(2, varId);
                    psWaste.setLong(3, subOrderId);
                    psWaste.setLong(4, loggedBy != null ? loggedBy : 3L);
                    psWaste.setInt(5, -wastedQty);
                    psWaste.setBigDecimal(6, price);
                    psWaste.setBigDecimal(7, loss);
                    psWaste.setNString(8, reason != null ? reason : "Hỏng khi sơ chế đóng gói");
                    psWaste.addBatch();

                    // Đồng bộ trừ tồn lô tương ứng theo FEFO
                    psBatchDeduct.setInt(1, wastedQty);
                    psBatchDeduct.setInt(2, wastedQty);
                    psBatchDeduct.setLong(3, varId);
                    psBatchDeduct.addBatch();

                    hasWaste = true;
                }

                // Cộng hoàn trả vào kho số lượng quả còn tươi nguyên
                if (goodQty > 0) {
                    psRestore.setInt(1, goodQty);
                    psRestore.setLong(2, varId);
                    psRestore.addBatch();
                    hasRestore = true;
                }
            }

            if (hasWaste) {
                psWaste.executeBatch();
                psBatchDeduct.executeBatch();
            }
            if (hasRestore) {
                psRestore.executeBatch();
            }
        }
    }

    public boolean logOrderCancellationWaste(long subOrderId, String reason, Long loggedBy, Map<Long, Integer> wastedQtyMap) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn) {
            conn.setAutoCommit(false);

            // 1. Lấy thông tin đơn hàng và danh sách hoa quả
            OrderCancellationData data = fetchOrderCancellationData(conn, subOrderId);
            if (data == null || data.getShopId() == 0 || data.getItems().isEmpty()) {
                conn.rollback();
                return false;
            }

            // 2. Cập nhật trạng thái đơn con sang CANCELLED
            updateSubOrderToCancelled(conn, subOrderId, reason, loggedBy);

            // 3. Đồng bộ trạng thái đơn cha (nếu tất cả đơn con đều đã CANCELLED)
            syncParentOrderStatus(conn, data.getParentOrderId());

            // 4. Xử lý tách hoa quả: Quả hỏng ghi sổ hao hụt, quả lành hoàn kho bán
            processCancellationWasteAndRestock(conn, data.getShopId(), subOrderId, data.getItems(), wastedQtyMap, reason, loggedBy);

            conn.commit();
            return true;
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "Error logging order cancellation waste", ex);
            return false;
        } finally {
            closeQuietly(conn);
        }
    }

    private TransitDamageData fetchTransitDamageData(Connection conn, long subOrderId) throws SQLException {
        String fetchOrderSql = "SELECT so.shop_id, so.cancel_reason, oi.variant_id, oi.quantity, oi.unit, oi.unit_price "
                + "FROM sub_orders so "
                + "JOIN order_items oi ON so.sub_order_id = oi.sub_order_id "
                + "WHERE so.sub_order_id = ?";

        TransitDamageData data = new TransitDamageData();
        try (PreparedStatement psFetch = conn.prepareStatement(fetchOrderSql)) {
            psFetch.setLong(1, subOrderId);
            try (ResultSet rs = psFetch.executeQuery()) {
                while (rs.next()) {
                    data.setShopId(rs.getLong("shop_id"));
                    data.setCurrentReason(rs.getString("cancel_reason"));
                    long varId = rs.getLong("variant_id");
                    int qty = rs.getInt("quantity");
                    String unit = rs.getString("unit");
                    BigDecimal price = rs.getBigDecimal("unit_price");
                    data.addItem(new Object[]{varId, qty, unit, price});
                }
            }
        }
        return data;
    }

    private void updateTransitDamageReason(Connection conn, long subOrderId, String currentReason, String note) throws SQLException {
        String updatedReason = (currentReason != null ? currentReason : "")
                + " [ĐÃ XỬ LÝ TIÊU HỦY: Ghi nhận hao hụt do vận chuyển" + (note != null && !note.isBlank() ? " - " + note.trim() : "") + "]";

        String updateStatusSql = "UPDATE sub_orders SET cancel_reason = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = ?";
        try (PreparedStatement psUp = conn.prepareStatement(updateStatusSql)) {
            psUp.setNString(1, updatedReason);
            psUp.setLong(2, subOrderId);
            psUp.executeUpdate();
        }
    }

    private void processTransitDamageWasteAndRestock(Connection conn, long shopId, long subOrderId,
            List<Object[]> items, Map<Long, Integer> wastedQtyMap, String note, Long loggedBy) throws SQLException {

        String insertWasteSql = "INSERT INTO inventory_transactions (shop_id, variant_id, batch_id, sub_order_id, user_id, "
                + "transaction_type, waste_stage, quantity_changed, previous_stock, new_stock, cost_price, estimated_loss, reason, created_at) "
                + "VALUES (?, ?, NULL, ?, ?, 'TRANSIT_DAMAGE', 'TRANSIT_DAMAGE', ?, 0, 0, ?, ?, ?, CURRENT_TIMESTAMP)";

        String restoreStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity + ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE variant_id = ?";

        String deductBatchSql = "UPDATE product_batches SET current_quantity = CASE WHEN current_quantity >= ? THEN current_quantity - ? ELSE 0 END, updated_at = CURRENT_TIMESTAMP "
                + "WHERE batch_id = (SELECT TOP 1 batch_id FROM product_batches WHERE variant_id = ? AND status = 'ACTIVE' ORDER BY expiry_date ASC)";

        try (PreparedStatement psWaste = conn.prepareStatement(insertWasteSql);
             PreparedStatement psRestore = conn.prepareStatement(restoreStockSql);
             PreparedStatement psBatchDeduct = conn.prepareStatement(deductBatchSql)) {

            boolean hasWaste = false;
            boolean hasRestore = false;

            for (Object[] item : items) {
                long varId = (long) item[0];
                int totalOrderedQty = (int) item[1];
                String unit = (String) item[2];
                BigDecimal price = (BigDecimal) item[3];

                int wastedQty = totalOrderedQty;
                if (wastedQtyMap != null && wastedQtyMap.containsKey(varId)) {
                    int userWasted = wastedQtyMap.get(varId);
                    wastedQty = Math.min(totalOrderedQty, Math.max(0, userWasted));
                }
                int goodQty = Math.max(0, totalOrderedQty - wastedQty);

                // Ghi sổ biến động kho (hao hụt phần hoa quả dập nát do vận chuyển)
                if (wastedQty > 0) {
                    BigDecimal loss = price.multiply(BigDecimal.valueOf(wastedQty));
                    psWaste.setLong(1, shopId);
                    psWaste.setLong(2, varId);
                    psWaste.setLong(3, subOrderId);
                    psWaste.setLong(4, loggedBy != null ? loggedBy : 3L);
                    psWaste.setInt(5, -wastedQty);
                    psWaste.setBigDecimal(6, price);
                    psWaste.setBigDecimal(7, loss);
                    psWaste.setNString(8, "Đứt chuỗi lạnh/dập nát khi giao: " + (note != null ? note : ""));
                    psWaste.addBatch();

                    // Đồng bộ trừ tồn lô tương ứng theo FEFO
                    psBatchDeduct.setInt(1, wastedQty);
                    psBatchDeduct.setInt(2, wastedQty);
                    psBatchDeduct.setLong(3, varId);
                    psBatchDeduct.addBatch();

                    hasWaste = true;
                }

                // Hoàn trả vào kho bán số lượng quả tươi còn lại
                if (goodQty > 0) {
                    psRestore.setInt(1, goodQty);
                    psRestore.setLong(2, varId);
                    psRestore.addBatch();
                    hasRestore = true;
                }
            }

            if (hasWaste) {
                psWaste.executeBatch();
                psBatchDeduct.executeBatch();
            }
            if (hasRestore) {
                psRestore.executeBatch();
            }
        }
    }

    public boolean logTransitDamageWaste(long subOrderId, String note, Long loggedBy, Map<Long, Integer> wastedQtyMap) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn) {
            conn.setAutoCommit(false);

            TransitDamageData data = fetchTransitDamageData(conn, subOrderId);
            if (data == null || data.getShopId() == 0 || data.getItems().isEmpty()) {
                conn.rollback();
                return false;
            }

            if (data.isAlreadyProcessed()) {
                conn.rollback();
                return true;
            }

            updateTransitDamageReason(conn, subOrderId, data.getCurrentReason(), note);

            processTransitDamageWasteAndRestock(conn, data.getShopId(), subOrderId, data.getItems(), wastedQtyMap, note, loggedBy);

            conn.commit();
            return true;
        } catch (SQLException ex) {
            rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "Error logging transit damage waste", ex);
            return false;
        } finally {
            closeQuietly(conn);
        }
    }

    public List<InventoryWasteLog> getWasteLogsByShop(long shopId, String stageFilter, String keyword, int page, int pageSize) {
        List<InventoryWasteLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT it.transaction_id AS waste_id, it.shop_id, it.variant_id, it.batch_id, it.sub_order_id, "
                + "COALESCE(it.waste_stage, 'WAREHOUSE_EXPIRED') AS waste_stage, ABS(it.quantity_changed) AS quantity, "
                + "pv.unit, COALESCE(it.cost_price, pv.price) AS cost_price, COALESCE(it.estimated_loss, pv.price * ABS(it.quantity_changed)) AS estimated_loss, it.reason AS reason_note, it.user_id AS logged_by, it.created_at, "
                + "p.name AS product_name, pv.variant_name, pv.sku, pb.batch_code, so.sub_order_code, u.full_name AS logged_by_name "
                + "FROM inventory_transactions it "
                + "JOIN product_variants pv ON it.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN product_batches pb ON it.batch_id = pb.batch_id "
                + "LEFT JOIN sub_orders so ON it.sub_order_id = so.sub_order_id "
                + "LEFT JOIN users u ON it.user_id = u.user_id "
                + "WHERE it.shop_id = ? "
                + "  AND (it.waste_stage IS NOT NULL OR it.transaction_type IN ('DAMAGED', 'EXPIRED', 'STORAGE_ISSUE', 'QUALITY_FAIL', 'LOST', 'DISPOSAL', 'QC_PACKING', 'TRANSIT_DAMAGE')) "
        );

        if (stageFilter != null && !stageFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(stageFilter)) {
            sql.append(" AND it.waste_stage = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR pv.variant_name LIKE ? OR pv.sku LIKE ? OR pb.batch_code LIKE ? OR so.sub_order_code LIKE ?) ");
        }

        sql.append(" ORDER BY it.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setLong(idx++, shopId);

            if (stageFilter != null && !stageFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(stageFilter)) {
                ps.setString(idx++, stageFilter.trim());
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }

            int offset = Math.max(0, (page - 1) * pageSize);
            ps.setInt(idx++, offset);
            ps.setInt(idx++, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InventoryWasteLog item = new InventoryWasteLog();
                    item.setWasteId(rs.getLong("waste_id"));
                    item.setShopId(rs.getLong("shop_id"));
                    item.setVariantId(rs.getLong("variant_id"));
                    long batchId = rs.getLong("batch_id");
                    if (!rs.wasNull()) {
                        item.setBatchId(batchId);
                    }
                    item.setBatchCode(rs.getString("batch_code"));
                    long subId = rs.getLong("sub_order_id");
                    if (!rs.wasNull()) {
                        item.setSubOrderId(subId);
                    }
                    item.setWasteStage(rs.getString("waste_stage"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnit(rs.getString("unit"));
                    item.setCostPrice(rs.getBigDecimal("cost_price"));
                    item.setEstimatedLoss(rs.getBigDecimal("estimated_loss"));
                    item.setReasonNote(rs.getString("reason_note"));
                    long lby = rs.getLong("logged_by");
                    if (!rs.wasNull()) {
                        item.setLoggedBy(lby);
                    }
                    item.setCreatedAt(rs.getTimestamp("created_at"));
                    item.setProductName(rs.getString("product_name"));
                    item.setVariantName(rs.getString("variant_name"));
                    item.setSku(rs.getString("sku"));
                    item.setSubOrderCode(rs.getString("sub_order_code"));
                    item.setLoggedByName(rs.getString("logged_by_name"));
                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting waste logs for shop " + shopId, ex);
        }
        return list;
    }

    public int countWasteLogsByShop(long shopId, String stageFilter, String keyword) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM inventory_transactions it "
                + "JOIN product_variants pv ON it.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN product_batches pb ON it.batch_id = pb.batch_id "
                + "LEFT JOIN sub_orders so ON it.sub_order_id = so.sub_order_id "
                + "WHERE it.shop_id = ? "
                + "  AND (it.waste_stage IS NOT NULL OR it.transaction_type IN ('DAMAGED', 'EXPIRED', 'STORAGE_ISSUE', 'QUALITY_FAIL', 'LOST', 'DISPOSAL', 'QC_PACKING', 'TRANSIT_DAMAGE')) "
        );

        if (stageFilter != null && !stageFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(stageFilter)) {
            sql.append(" AND it.waste_stage = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR pv.variant_name LIKE ? OR pv.sku LIKE ? OR pb.batch_code LIKE ? OR so.sub_order_code LIKE ?) ");
        }

        Connection conn = getConnection();
        if (conn == null) {
            return 0;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setLong(idx++, shopId);

            if (stageFilter != null && !stageFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(stageFilter)) {
                ps.setString(idx++, stageFilter.trim());
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting waste logs for shop " + shopId, ex);
        }
        return 0;
    }

    public WasteStatisticDTO getWasteStatisticsByShop(long shopId) {
        WasteStatisticDTO dto = new WasteStatisticDTO();
        String summarySql = "SELECT ISNULL(SUM(ABS(it.quantity_changed)), 0) AS total_qty, "
                + "ISNULL(SUM(COALESCE(it.estimated_loss, pv.price * ABS(it.quantity_changed))), 0) AS total_loss, COUNT(*) AS total_count "
                + "FROM inventory_transactions it "
                + "JOIN product_variants pv ON it.variant_id = pv.variant_id "
                + "WHERE it.shop_id = ? "
                + "  AND (it.waste_stage IS NOT NULL OR it.transaction_type IN ('DAMAGED', 'EXPIRED', 'STORAGE_ISSUE', 'QUALITY_FAIL', 'LOST', 'DISPOSAL', 'QC_PACKING', 'TRANSIT_DAMAGE'))";

        Connection conn = getConnection();
        if (conn == null) {
            return dto;
        }

        try (conn) {
            try (PreparedStatement ps = conn.prepareStatement(summarySql)) {
                ps.setLong(1, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        dto.setTotalWasteQuantity(rs.getInt("total_qty"));
                        dto.setTotalLossAmount(rs.getBigDecimal("total_loss"));
                        dto.setTotalLogsCount(rs.getInt("total_count"));
                    }
                }
            }

            String topSql = "SELECT TOP 5 pv.variant_id, p.name AS product_name, pv.variant_name, pv.unit, "
                    + "SUM(ABS(it.quantity_changed)) AS qty, SUM(COALESCE(it.estimated_loss, pv.price * ABS(it.quantity_changed))) AS loss "
                    + "FROM inventory_transactions it "
                    + "JOIN product_variants pv ON it.variant_id = pv.variant_id "
                    + "JOIN products p ON pv.product_id = p.product_id "
                    + "WHERE it.shop_id = ? "
                    + "  AND (it.waste_stage IS NOT NULL OR it.transaction_type IN ('DAMAGED', 'EXPIRED', 'STORAGE_ISSUE', 'QUALITY_FAIL', 'LOST', 'DISPOSAL', 'QC_PACKING', 'TRANSIT_DAMAGE')) "
                    + "GROUP BY pv.variant_id, p.name, pv.variant_name, pv.unit "
                    + "ORDER BY loss DESC";

            try (PreparedStatement psTop = conn.prepareStatement(topSql)) {
                psTop.setLong(1, shopId);
                try (ResultSet rsTop = psTop.executeQuery()) {
                    List<WasteStatisticDTO.TopWasteItem> topList = new ArrayList<>();
                    while (rsTop.next()) {
                        WasteStatisticDTO.TopWasteItem item = new WasteStatisticDTO.TopWasteItem();
                        item.setVariantId(rsTop.getLong("variant_id"));
                        item.setProductName(rsTop.getString("product_name"));
                        item.setVariantName(rsTop.getString("variant_name"));
                        item.setUnit(rsTop.getString("unit"));
                        item.setQuantity(rsTop.getInt("qty"));
                        item.setTotalLoss(rsTop.getBigDecimal("loss"));
                        topList.add(item);
                    }
                    dto.setTopWastedVariants(topList);
                }
            }

            String soldSql = "SELECT ISNULL(SUM(oi.quantity), 0) AS sold_qty "
                    + "FROM sub_orders so JOIN order_items oi ON so.sub_order_id = oi.sub_order_id "
                    + "WHERE so.shop_id = ? AND so.status = 'DELIVERED'";
            int totalSold = 0;
            try (PreparedStatement psSold = conn.prepareStatement(soldSql)) {
                psSold.setLong(1, shopId);
                try (ResultSet rsSold = psSold.executeQuery()) {
                    if (rsSold.next()) {
                        totalSold = rsSold.getInt("sold_qty");
                    }
                }
            }

            int totalVolume = totalSold + dto.getTotalWasteQuantity();
            if (totalVolume > 0) {
                double rate = ((double) dto.getTotalWasteQuantity() / totalVolume) * 100.0;
                dto.setWasteRatePercent(Math.round(rate * 10.0) / 10.0);
            } else {
                dto.setWasteRatePercent(0.0);
            }

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error calculating waste statistics for shop " + shopId, ex);
        }
        return dto;
    }

    public boolean logTransitDamageWasteByCode(String subOrderCode, String note, Long loggedBy, Map<Long, Integer> wastedQtyMap) {
        String sql = "SELECT sub_order_id FROM sub_orders WHERE sub_order_code = ?";
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        long subOrderId = 0;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subOrderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    subOrderId = rs.getLong("sub_order_id");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding sub_order_id for code: " + subOrderCode, ex);
            return false;
        }
        if (subOrderId <= 0) {
            return false;
        }
        return logTransitDamageWaste(subOrderId, note, loggedBy, wastedQtyMap);
    }

    public List<SubOrderDTO> getPendingReturnedOrdersByShop(long shopId) {
        List<SubOrderDTO> list = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }

        String sql = "SELECT so.sub_order_id, so.sub_order_code, so.order_id, so.shop_id, "
                + "       so.delivery_date, so.delivery_slot_id, dts.display_label AS slot_display, so.note, "
                + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                + "       so.status, so.cancel_reason, so.created_at, so.updated_at, "
                + "       o.order_code, o.payment_status, o.payment_method, "
                + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city "
                + "FROM sub_orders so "
                + "JOIN orders o ON so.order_id = o.order_id "
                + "LEFT JOIN delivery_time_slots dts ON so.delivery_slot_id = dts.slot_id "
                + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                + "WHERE so.shop_id = ? AND so.status IN ('RETURNED', 'FAILED') "
                + "ORDER BY so.updated_at DESC, so.created_at DESC";

        OrderFulfillmentDAO fulfillmentDAO = new OrderFulfillmentDAO();
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SubOrderDTO so = new SubOrderDTO();
                    so.setSubOrderId(rs.getLong("sub_order_id"));
                    so.setSubOrderCode(rs.getString("sub_order_code"));
                    so.setOrderId(rs.getLong("order_id"));
                    so.setOrderCode(rs.getString("order_code"));
                    so.setShopId(rs.getLong("shop_id"));
                    java.sql.Date dDate = rs.getDate("delivery_date");
                    if (dDate != null) so.setDeliveryDate(dDate.toLocalDate());
                    int sId = rs.getInt("delivery_slot_id");
                    if (!rs.wasNull()) so.setDeliverySlotId(sId);
                    String slotDisplay = rs.getString("slot_display");
                    String dateStr = (dDate != null) ? dDate.toLocalDate().format(DATE_FMT) : null;
                    String finalSlotLabel = (slotDisplay != null ? slotDisplay : "08:00 - 10:00")
                            + (dateStr != null ? " (" + dateStr + ")" : "");
                    so.setDeliverySlot(finalSlotLabel);
                    so.setNote(rs.getString("note"));
                    so.setShopSubtotal(rs.getBigDecimal("shop_subtotal"));
                    so.setShopShippingFee(rs.getBigDecimal("shop_shipping_fee"));
                    so.setShopDiscount(rs.getBigDecimal("shop_discount"));
                    so.setShopTotal(rs.getBigDecimal("shop_total"));
                    so.setStatus(rs.getString("status"));
                    so.setCancelReason(rs.getNString("cancel_reason"));
                    so.setCreatedAt(rs.getTimestamp("created_at"));
                    so.setUpdatedAt(rs.getTimestamp("updated_at"));
                    so.setPaymentStatus(rs.getString("payment_status"));
                    so.setPaymentMethod(rs.getString("payment_method"));
                    ShippingAddress addr = new ShippingAddress();
                    addr.setRecipientName(rs.getString("recipient_name"));
                    addr.setRecipientPhone(rs.getString("recipient_phone"));
                    addr.setStreetAddress(rs.getString("street_address"));
                    addr.setWard(rs.getString("ward"));
                    addr.setDistrict(rs.getString("district"));
                    addr.setCity(rs.getString("city"));
                    so.setShippingAddress(addr);
                    so.setItems(new ArrayList<>(fulfillmentDAO.getOrderItemsBySubOrderId(so.getSubOrderId())));
                    list.add(so);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching pending returned orders for shop " + shopId, ex);
        }
        return list;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Rollback failed", ex);
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error closing connection", ex);
            }
        }
    }
}
