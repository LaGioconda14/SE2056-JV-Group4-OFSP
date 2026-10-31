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
import model.InventoryWasteLog;
import model.WasteStatisticDTO;
import util.DBContext;

public class InventoryWasteDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(InventoryWasteDAO.class.getName());

    public InventoryWasteDAO() {
        initTable();
    }

    private void initTable() {
        String sql = "IF OBJECT_ID(N'dbo.inventory_waste_logs', N'U') IS NULL "
                + "BEGIN "
                + "    CREATE TABLE [dbo].[inventory_waste_logs] ( "
                + "        [waste_id]          BIGINT IDENTITY(1,1) PRIMARY KEY, "
                + "        [shop_id]           BIGINT NOT NULL, "
                + "        [variant_id]        BIGINT NOT NULL, "
                + "        [sub_order_id]      BIGINT NULL, "
                + "        [waste_stage]       VARCHAR(50) NOT NULL, "
                + "        [quantity]          INT NOT NULL, "
                + "        [unit]              NVARCHAR(30) NOT NULL, "
                + "        [cost_price]        DECIMAL(18, 2) NOT NULL, "
                + "        [estimated_loss]    DECIMAL(18, 2) NOT NULL, "
                + "        [reason_note]       NVARCHAR(500) NOT NULL, "
                + "        [image_proof_url]   VARCHAR(500) NULL, "
                + "        [logged_by]         BIGINT NULL, "
                + "        [created_at]        DATETIME DEFAULT CURRENT_TIMESTAMP "
                + "    ); "
                + "END";
        Connection conn = getConnection();
        if (conn == null) {
            return;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error initializing inventory_waste_logs table", ex);
        }
    }

    public boolean insertWasteLog(long shopId, long variantId, Long subOrderId, String wasteStage,
            int quantity, String unit, BigDecimal costPrice, String reasonNote, String imageProofUrl, Long loggedBy) {
        String sql = "INSERT INTO inventory_waste_logs (shop_id, variant_id, sub_order_id, waste_stage, quantity, "
                + "unit, cost_price, estimated_loss, reason_note, image_proof_url, logged_by, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            BigDecimal estimatedLoss = costPrice.multiply(BigDecimal.valueOf(quantity));
            ps.setLong(1, shopId);
            ps.setLong(2, variantId);
            if (subOrderId != null) {
                ps.setLong(3, subOrderId);
            } else {
                ps.setNull(3, Types.BIGINT);
            }
            ps.setString(4, wasteStage);
            ps.setInt(5, quantity);
            ps.setNString(6, unit != null ? unit : "kg");
            ps.setBigDecimal(7, costPrice);
            ps.setBigDecimal(8, estimatedLoss);
            ps.setNString(9, reasonNote);
            if (imageProofUrl != null) {
                ps.setString(10, imageProofUrl);
            } else {
                ps.setNull(10, Types.VARCHAR);
            }
            if (loggedBy != null) {
                ps.setLong(11, loggedBy);
            } else {
                ps.setNull(11, Types.BIGINT);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting waste log", ex);
            return false;
        }
    }

    public boolean recordManualWaste(long shopId, long variantId, int quantity, String reasonNote, Long loggedBy) {
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

            String updateStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity - ?, updated_at = CURRENT_TIMESTAMP WHERE variant_id = ?";
            try (PreparedStatement psStock = conn.prepareStatement(updateStockSql)) {
                psStock.setInt(1, quantity);
                psStock.setLong(2, variantId);
                psStock.executeUpdate();
            }

            BigDecimal totalLoss = price.multiply(BigDecimal.valueOf(quantity));
            String insertSql = "INSERT INTO inventory_waste_logs (shop_id, variant_id, sub_order_id, waste_stage, quantity, "
                    + "unit, cost_price, estimated_loss, reason_note, logged_by, created_at) "
                    + "VALUES (?, ?, NULL, 'WAREHOUSE_EXPIRED', ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
            try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                psIns.setLong(1, shopId);
                psIns.setLong(2, variantId);
                psIns.setInt(3, quantity);
                psIns.setNString(4, unit != null ? unit : "kg");
                psIns.setBigDecimal(5, price);
                psIns.setBigDecimal(6, totalLoss);
                psIns.setNString(7, reasonNote);
                if (loggedBy != null) {
                    psIns.setLong(8, loggedBy);
                } else {
                    psIns.setNull(8, Types.BIGINT);
                }
                psIns.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error recording manual waste", ex);
        }
        return false;
    }

    public boolean logOrderCancellationWaste(long subOrderId, String reason, Long loggedBy) {
        return logOrderCancellationWaste(subOrderId, reason, loggedBy, null);
    }

    public boolean logOrderCancellationWaste(long subOrderId, String reason, Long loggedBy, Map<Long, Integer> wastedQtyMap) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn) {
            conn.setAutoCommit(false);

            String fetchOrderSql = "SELECT so.shop_id, so.order_id, oi.variant_id, oi.quantity, oi.unit, oi.unit_price "
                    + "FROM sub_orders so "
                    + "JOIN order_items oi ON so.sub_order_id = oi.sub_order_id "
                    + "WHERE so.sub_order_id = ?";

            long shopId = 0;
            long parentOrderId = 0;
            List<Object[]> items = new ArrayList<>();
            try (PreparedStatement psFetch = conn.prepareStatement(fetchOrderSql)) {
                psFetch.setLong(1, subOrderId);
                try (ResultSet rs = psFetch.executeQuery()) {
                    while (rs.next()) {
                        shopId = rs.getLong("shop_id");
                        parentOrderId = rs.getLong("order_id");
                        long varId = rs.getLong("variant_id");
                        int qty = rs.getInt("quantity");
                        String unit = rs.getString("unit");
                        BigDecimal price = rs.getBigDecimal("unit_price");
                        items.add(new Object[]{varId, qty, unit, price});
                    }
                }
            }

            if (shopId == 0 || items.isEmpty()) {
                conn.rollback();
                return false;
            }

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

            String insertWasteSql = "INSERT INTO inventory_waste_logs (shop_id, variant_id, sub_order_id, waste_stage, "
                    + "quantity, unit, cost_price, estimated_loss, reason_note, logged_by, created_at) "
                    + "VALUES (?, ?, ?, 'QC_PACKING', ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

            String restoreStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity + ?, updated_at = CURRENT_TIMESTAMP "
                    + "WHERE variant_id = ?";

            try (PreparedStatement psWaste = conn.prepareStatement(insertWasteSql);
                 PreparedStatement psRestore = conn.prepareStatement(restoreStockSql)) {

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

                    if (wastedQty > 0) {
                        BigDecimal loss = price.multiply(BigDecimal.valueOf(wastedQty));
                        psWaste.setLong(1, shopId);
                        psWaste.setLong(2, varId);
                        psWaste.setLong(3, subOrderId);
                        psWaste.setInt(4, wastedQty);
                        psWaste.setNString(5, unit != null ? unit : "kg");
                        psWaste.setBigDecimal(6, price);
                        psWaste.setBigDecimal(7, loss);
                        psWaste.setNString(8, reason);
                        if (loggedBy != null) {
                            psWaste.setLong(9, loggedBy);
                        } else {
                            psWaste.setNull(9, Types.BIGINT);
                        }
                        psWaste.addBatch();
                        hasWaste = true;
                    }

                    if (goodQty > 0) {
                        psRestore.setInt(1, goodQty);
                        psRestore.setLong(2, varId);
                        psRestore.addBatch();
                        hasRestore = true;
                    }
                }

                if (hasWaste) {
                    psWaste.executeBatch();
                }
                if (hasRestore) {
                    psRestore.executeBatch();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error logging order cancellation waste", ex);
        }
        return false;
    }

    public boolean logTransitDamageWaste(long subOrderId, String note, Long loggedBy, Map<Long, Integer> wastedQtyMap) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn) {
            conn.setAutoCommit(false);

            String fetchOrderSql = "SELECT so.shop_id, so.cancel_reason, oi.variant_id, oi.quantity, oi.unit, oi.unit_price "
                    + "FROM sub_orders so "
                    + "JOIN order_items oi ON so.sub_order_id = oi.sub_order_id "
                    + "WHERE so.sub_order_id = ?";

            long shopId = 0;
            String currentReason = "";
            List<Object[]> items = new ArrayList<>();
            try (PreparedStatement psFetch = conn.prepareStatement(fetchOrderSql)) {
                psFetch.setLong(1, subOrderId);
                try (ResultSet rs = psFetch.executeQuery()) {
                    while (rs.next()) {
                        shopId = rs.getLong("shop_id");
                        currentReason = rs.getString("cancel_reason");
                        long varId = rs.getLong("variant_id");
                        int qty = rs.getInt("quantity");
                        String unit = rs.getString("unit");
                        BigDecimal price = rs.getBigDecimal("unit_price");
                        items.add(new Object[]{varId, qty, unit, price});
                    }
                }
            }

            if (shopId == 0 || items.isEmpty()) {
                conn.rollback();
                return false;
            }

            if (currentReason != null && currentReason.contains("[ĐÃ XỬ LÝ")) {
                conn.rollback();
                return true;
            }

            String updatedReason = (currentReason != null ? currentReason : "")
                    + " [ĐÃ XỬ LÝ TIÊU HỦY: Ghi nhận hao hụt do vận chuyển" + (note != null && !note.isBlank() ? " - " + note.trim() : "") + "]";

            String updateStatusSql = "UPDATE sub_orders SET cancel_reason = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = ?";
            try (PreparedStatement psUp = conn.prepareStatement(updateStatusSql)) {
                psUp.setNString(1, updatedReason);
                psUp.setLong(2, subOrderId);
                psUp.executeUpdate();
            }

            String insertWasteSql = "INSERT INTO inventory_waste_logs (shop_id, variant_id, sub_order_id, waste_stage, "
                    + "quantity, unit, cost_price, estimated_loss, reason_note, logged_by, created_at) "
                    + "VALUES (?, ?, ?, 'TRANSIT_DAMAGE', ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

            String restoreStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity + ?, updated_at = CURRENT_TIMESTAMP "
                    + "WHERE variant_id = ?";

            try (PreparedStatement psWaste = conn.prepareStatement(insertWasteSql);
                 PreparedStatement psRestore = conn.prepareStatement(restoreStockSql)) {

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

                    if (wastedQty > 0) {
                        BigDecimal loss = price.multiply(BigDecimal.valueOf(wastedQty));
                        psWaste.setLong(1, shopId);
                        psWaste.setLong(2, varId);
                        psWaste.setLong(3, subOrderId);
                        psWaste.setInt(4, wastedQty);
                        psWaste.setNString(5, unit != null ? unit : "kg");
                        psWaste.setBigDecimal(6, price);
                        psWaste.setBigDecimal(7, loss);
                        psWaste.setNString(8, "Đứt chuỗi lạnh/dập nát khi giao: " + (note != null ? note : ""));
                        if (loggedBy != null) {
                            psWaste.setLong(9, loggedBy);
                        } else {
                            psWaste.setNull(9, Types.BIGINT);
                        }
                        psWaste.addBatch();
                        hasWaste = true;
                    }

                    if (goodQty > 0) {
                        psRestore.setInt(1, goodQty);
                        psRestore.setLong(2, varId);
                        psRestore.addBatch();
                        hasRestore = true;
                    }
                }

                if (hasWaste) {
                    psWaste.executeBatch();
                }
                if (hasRestore) {
                    psRestore.executeBatch();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error logging transit damage waste", ex);
            return false;
        }
    }

    public List<InventoryWasteLog> getWasteLogsByShop(long shopId, String stageFilter, String keyword, int page, int pageSize) {
        List<InventoryWasteLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT l.waste_id, l.shop_id, l.variant_id, l.sub_order_id, l.waste_stage, l.quantity, "
                + "l.unit, l.cost_price, l.estimated_loss, l.reason_note, l.image_proof_url, l.logged_by, l.created_at, "
                + "p.name AS product_name, pv.variant_name, pv.sku, so.sub_order_code, u.full_name AS logged_by_name "
                + "FROM inventory_waste_logs l "
                + "JOIN product_variants pv ON l.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN sub_orders so ON l.sub_order_id = so.sub_order_id "
                + "LEFT JOIN users u ON l.logged_by = u.user_id "
                + "WHERE l.shop_id = ? "
        );

        if (stageFilter != null && !stageFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(stageFilter)) {
            sql.append(" AND l.waste_stage = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR pv.variant_name LIKE ? OR pv.sku LIKE ? OR so.sub_order_code LIKE ? OR l.reason_note LIKE ?) ");
        }

        sql.append(" ORDER BY l.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

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
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
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
                    item.setImageProofUrl(rs.getString("image_proof_url"));
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
                "SELECT COUNT(*) FROM inventory_waste_logs l "
                + "JOIN product_variants pv ON l.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN sub_orders so ON l.sub_order_id = so.sub_order_id "
                + "WHERE l.shop_id = ? "
        );

        if (stageFilter != null && !stageFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(stageFilter)) {
            sql.append(" AND l.waste_stage = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR pv.variant_name LIKE ? OR pv.sku LIKE ? OR so.sub_order_code LIKE ? OR l.reason_note LIKE ?) ");
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
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
                ps.setNString(idx++, kw);
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
        String summarySql = "SELECT ISNULL(SUM(quantity), 0) AS total_qty, "
                + "ISNULL(SUM(estimated_loss), 0) AS total_loss, COUNT(*) AS total_count "
                + "FROM inventory_waste_logs WHERE shop_id = ?";

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
                    + "SUM(l.quantity) AS qty, SUM(l.estimated_loss) AS loss "
                    + "FROM inventory_waste_logs l "
                    + "JOIN product_variants pv ON l.variant_id = pv.variant_id "
                    + "JOIN products p ON pv.product_id = p.product_id "
                    + "WHERE l.shop_id = ? "
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
}
