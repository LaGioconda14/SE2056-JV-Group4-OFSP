package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.InventoryBatchItem;
import model.InventoryTransaction;
import model.ProductBatch;
import java.sql.SQLException;
import java.util.*;
import util.DBContext;

public class InventoryDAO extends DBContext {

    private static volatile Boolean HAS_PRODUCT_BATCHES = null;

    /**
     * Kiểm tra an toàn xem bảng product_batches có tồn tại trong CSDL SQL Server hay không.
     * Tránh lỗi SQLServerException: Invalid object name 'product_batches'.
     */
    private boolean checkHasProductBatches(Connection conn) {
        if (HAS_PRODUCT_BATCHES != null) {
            return HAS_PRODUCT_BATCHES;
        }
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT OBJECT_ID('dbo.product_batches', 'U')")) {
            if (rs.next()) {
                HAS_PRODUCT_BATCHES = (rs.getObject(1) != null);
            } else {
                HAS_PRODUCT_BATCHES = false;
            }
        } catch (Exception ex) {
            HAS_PRODUCT_BATCHES = false;
        }
        return HAS_PRODUCT_BATCHES != null && HAS_PRODUCT_BATCHES;
    }

    public List<InventoryBatchItem> getInventoryAlertItems(long shopId, String keyword, String riskLevel, 
                                                          String sortBy, String viewTab, int page, int pageSize) {
        List<InventoryBatchItem> list = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }

        try (conn) {
            boolean hasBatches = checkHasProductBatches(conn);
            StringBuilder sql = new StringBuilder();

            if (hasBatches) {
                sql.append("SELECT ")
                   .append("    COALESCE(pb.batch_id, 0) AS batch_id, ")
                   .append("    COALESCE(pb.batch_code, CONCAT('LH-', pv.sku)) AS batch_code, ")
                   .append("    pv.variant_id, ")
                   .append("    p.product_id, ")
                   .append("    pv.sku, ")
                   .append("    p.name AS product_name, ")
                   .append("    pv.variant_name, ")
                   .append("    p.certification, ")
                   .append("    COALESCE(pb.batch_type, pv.variant_name) AS batch_type, ")
                   .append("    COALESCE(pi.image_url, (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, image_id ASC)) AS image_url, ")
                   .append("    pb.harvest_date, ")
                   .append("    COALESCE(pb.harvest_time_label, N'06:00 Hôm nay') AS harvest_time_label, ")
                   .append("    COALESCE(pb.freshness_score, 95) AS freshness_score, ")
                   .append("    COALESCE(pb.freshness_note, N'Độ tươi: 95% (Chuẩn kho lạnh)') AS freshness_note, ")
                   .append("    COALESCE(pb.current_quantity, pv.stock_quantity) AS current_quantity, ")
                   .append("    COALESCE(pb.initial_quantity, CASE WHEN pv.stock_quantity > 50 THEN pv.stock_quantity ELSE 50 END) AS initial_quantity, ")
                   .append("    pv.low_stock_threshold, ")
                   .append("    pv.unit, ")
                   .append("    COALESCE(pb.pending_packing_text, N'0 đơn chờ xuất') AS pending_packing_text, ")
                   .append("    pv.price ")
                   .append("FROM product_variants pv ")
                   .append("JOIN products p ON pv.product_id = p.product_id ")
                   .append("LEFT JOIN product_batches pb ON pv.variant_id = pb.variant_id ")
                   .append("LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 ")
                   .append("WHERE p.shop_id = ? ");
            } else {
                sql.append("SELECT ")
                   .append("    0 AS batch_id, ")
                   .append("    CONCAT('LH-', pv.sku) AS batch_code, ")
                   .append("    pv.variant_id, ")
                   .append("    p.product_id, ")
                   .append("    pv.sku, ")
                   .append("    p.name AS product_name, ")
                   .append("    pv.variant_name, ")
                   .append("    p.certification, ")
                   .append("    pv.variant_name AS batch_type, ")
                   .append("    COALESCE(pi.image_url, (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, image_id ASC)) AS image_url, ")
                   .append("    pv.created_at AS harvest_date, ")
                   .append("    N'06:00 Hôm nay' AS harvest_time_label, ")
                   .append("    95 AS freshness_score, ")
                   .append("    N'Độ tươi: 95% (Chuẩn kho lạnh)' AS freshness_note, ")
                   .append("    pv.stock_quantity AS current_quantity, ")
                   .append("    CASE WHEN pv.stock_quantity > 50 THEN pv.stock_quantity ELSE 50 END AS initial_quantity, ")
                   .append("    pv.low_stock_threshold, ")
                   .append("    pv.unit, ")
                   .append("    N'0 đơn chờ xuất' AS pending_packing_text, ")
                   .append("    pv.price ")
                   .append("FROM product_variants pv ")
                   .append("JOIN products p ON pv.product_id = p.product_id ")
                   .append("LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 ")
                   .append("WHERE p.shop_id = ? ");
            }

            List<Object> params = new ArrayList<>();
            params.add(shopId);

            // Keyword filter
            if (keyword != null && !keyword.trim().isEmpty()) {
                if (hasBatches) {
                    sql.append(" AND (p.name LIKE ? OR pv.sku LIKE ? OR pb.batch_code LIKE ?) ");
                } else {
                    sql.append(" AND (p.name LIKE ? OR pv.sku LIKE ? OR CONCAT('LH-', pv.sku) LIKE ?) ");
                }
                String kw = "%" + keyword.trim() + "%";
                params.add(kw);
                params.add(kw);
                params.add(kw);
            }

            String qtyCol = hasBatches ? "COALESCE(pb.current_quantity, pv.stock_quantity)" : "pv.stock_quantity";
            String freshCol = hasBatches ? "COALESCE(pb.freshness_score, 95)" : "95";

            // Risk Level filter
            if (riskLevel != null && !riskLevel.trim().isEmpty() && !"all".equalsIgnoreCase(riskLevel)) {
                if ("critical".equalsIgnoreCase(riskLevel)) {
                    sql.append(" AND (").append(qtyCol).append(" <= 5 OR (").append(qtyCol).append(" - pv.low_stock_threshold) <= -5) ");
                } else if ("warning".equalsIgnoreCase(riskLevel)) {
                    sql.append(" AND (").append(qtyCol).append(" <= pv.low_stock_threshold AND ").append(qtyCol).append(" > 5) ");
                } else if ("safe".equalsIgnoreCase(riskLevel)) {
                    sql.append(" AND (").append(qtyCol).append(" > pv.low_stock_threshold) ");
                }
            }

            // View Tab filter
            if (viewTab != null && !viewTab.trim().isEmpty()) {
                if ("alert".equalsIgnoreCase(viewTab)) {
                    sql.append(" AND (").append(qtyCol).append(" <= pv.low_stock_threshold) ");
                } else if ("freshness".equalsIgnoreCase(viewTab)) {
                    sql.append(" AND (").append(freshCol).append(" <= 85) ");
                }
            }

            // Sorting
            if ("stock_desc".equalsIgnoreCase(sortBy)) {
                sql.append(" ORDER BY ").append(qtyCol).append(" DESC ");
            } else if ("freshness_asc".equalsIgnoreCase(sortBy)) {
                sql.append(" ORDER BY ").append(freshCol).append(" ASC ");
            } else if ("freshness_desc".equalsIgnoreCase(sortBy)) {
                sql.append(" ORDER BY ").append(freshCol).append(" DESC ");
            } else {
                sql.append(" ORDER BY (CASE WHEN ").append(qtyCol).append(" <= pv.low_stock_threshold THEN 0 ELSE 1 END), ").append(qtyCol).append(" ASC ");
            }

            // Pagination
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            int offset = (page - 1) * pageSize;
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            params.add(offset);
            params.add(pageSize);

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        InventoryBatchItem item = new InventoryBatchItem();
                        item.setBatchId(rs.getLong("batch_id"));
                        item.setBatchCode(rs.getString("batch_code"));
                        item.setVariantId(rs.getLong("variant_id"));
                        item.setProductId(rs.getLong("product_id"));
                        item.setSku(rs.getString("sku"));
                        item.setProductName(rs.getString("product_name"));
                        item.setVariantName(rs.getString("variant_name"));
                        item.setCertification(rs.getString("certification"));
                        item.setBatchType(rs.getString("batch_type"));

                        String img = rs.getString("image_url");
                        if (img == null || img.trim().isEmpty()) {
                            img = "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop";
                        }
                        item.setImage(img);

                        item.setHarvestDate(rs.getTimestamp("harvest_date"));
                        item.setHarvestTimeLabel(rs.getString("harvest_time_label"));
                        item.setFreshnessScore(rs.getInt("freshness_score"));
                        item.setFreshnessNote(rs.getString("freshness_note"));
                        item.setCurrentQuantity(rs.getInt("current_quantity"));
                        item.setInitialQuantity(rs.getInt("initial_quantity"));
                        item.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                        item.setUnit(rs.getString("unit"));
                        item.setPendingPackingText(rs.getString("pending_packing_text"));
                        item.setPrice(rs.getDouble("price"));

                        list.add(item);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countInventoryAlertItems(long shopId, String keyword, String riskLevel, String viewTab) {
        int count = 0;
        Connection conn = getConnection();
        if (conn == null) {
            return count;
        }

        try (conn) {
            boolean hasBatches = checkHasProductBatches(conn);
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT COUNT(pv.variant_id) ")
               .append("FROM product_variants pv ")
               .append("JOIN products p ON pv.product_id = p.product_id ");
            if (hasBatches) {
                sql.append("LEFT JOIN product_batches pb ON pv.variant_id = pb.variant_id ");
            }
            sql.append("WHERE p.shop_id = ? ");

            List<Object> params = new ArrayList<>();
            params.add(shopId);

            if (keyword != null && !keyword.trim().isEmpty()) {
                if (hasBatches) {
                    sql.append(" AND (p.name LIKE ? OR pv.sku LIKE ? OR pb.batch_code LIKE ?) ");
                } else {
                    sql.append(" AND (p.name LIKE ? OR pv.sku LIKE ? OR CONCAT('LH-', pv.sku) LIKE ?) ");
                }
                String kw = "%" + keyword.trim() + "%";
                params.add(kw);
                params.add(kw);
                params.add(kw);
            }

            String qtyCol = hasBatches ? "COALESCE(pb.current_quantity, pv.stock_quantity)" : "pv.stock_quantity";
            String freshCol = hasBatches ? "COALESCE(pb.freshness_score, 95)" : "95";

            if (riskLevel != null && !riskLevel.trim().isEmpty() && !"all".equalsIgnoreCase(riskLevel)) {
                if ("critical".equalsIgnoreCase(riskLevel)) {
                    sql.append(" AND (").append(qtyCol).append(" <= 5 OR (").append(qtyCol).append(" - pv.low_stock_threshold) <= -5) ");
                } else if ("warning".equalsIgnoreCase(riskLevel)) {
                    sql.append(" AND (").append(qtyCol).append(" <= pv.low_stock_threshold AND ").append(qtyCol).append(" > 5) ");
                } else if ("safe".equalsIgnoreCase(riskLevel)) {
                    sql.append(" AND (").append(qtyCol).append(" > pv.low_stock_threshold) ");
                }
            }

            if (viewTab != null && !viewTab.trim().isEmpty()) {
                if ("alert".equalsIgnoreCase(viewTab)) {
                    sql.append(" AND (").append(qtyCol).append(" <= pv.low_stock_threshold) ");
                } else if ("freshness".equalsIgnoreCase(viewTab)) {
                    sql.append(" AND (").append(freshCol).append(" <= 85) ");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        count = rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    public int getCriticalStockCount(long shopId) {
        int count = 0;
        Connection conn = getConnection();
        if (conn == null) {
            return count;
        }

        try (conn) {
            boolean hasBatches = checkHasProductBatches(conn);
            String sql;
            if (hasBatches) {
                sql = "SELECT COUNT(pv.variant_id) FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "LEFT JOIN product_batches pb ON pv.variant_id = pb.variant_id "
                    + "WHERE p.shop_id = ? AND COALESCE(pb.current_quantity, pv.stock_quantity) <= 5";
            } else {
                sql = "SELECT COUNT(pv.variant_id) FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "WHERE p.shop_id = ? AND pv.stock_quantity <= 5";
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        count = rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public String getCriticalItemNames(long shopId) {
        List<String> names = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return "Dâu Tochi, Nho Hạ Đen, Bơ Booth";
        }

        try (conn) {
            boolean hasBatches = checkHasProductBatches(conn);
            String sql;
            if (hasBatches) {
                sql = "SELECT TOP 3 p.name FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "LEFT JOIN product_batches pb ON pv.variant_id = pb.variant_id "
                    + "WHERE p.shop_id = ? AND COALESCE(pb.current_quantity, pv.stock_quantity) <= 5 "
                    + "ORDER BY COALESCE(pb.current_quantity, pv.stock_quantity) ASC";
            } else {
                sql = "SELECT TOP 3 p.name FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "WHERE p.shop_id = ? AND pv.stock_quantity <= 5 "
                    + "ORDER BY pv.stock_quantity ASC";
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String name = rs.getString(1);
                        if (name.contains("Dâu Tây")) names.add("Dâu Tochi");
                        else if (name.contains("Nho Hạ Đen")) names.add("Nho Hạ Đen");
                        else if (name.contains("Bơ")) names.add("Bơ Booth");
                        else names.add(name);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (names.isEmpty()) {
            return "Dâu Tochi, Nho Hạ Đen, Bơ Booth";
        }
        return String.join(", ", names);
    }

    public int getExpiringFreshnessCount(long shopId) {
        int count = 0;
        Connection conn = getConnection();
        if (conn == null) {
            return 2;
        }

        try (conn) {
            boolean hasBatches = checkHasProductBatches(conn);
            if (hasBatches) {
                String sql = "SELECT COUNT(pb.batch_id) FROM product_batches pb JOIN product_variants pv ON pb.variant_id = pv.variant_id "
                           + "JOIN products p ON pv.product_id = p.product_id "
                           + "WHERE p.shop_id = ? AND (pb.freshness_score <= 80 OR DATEDIFF(hour, pb.harvest_date, GETDATE()) >= 48)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, shopId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            count = rs.getInt(1);
                        }
                    }
                }
            } else {
                String sql = "SELECT COUNT(pv.variant_id) FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                           + "WHERE p.shop_id = ? AND DATEDIFF(hour, pv.created_at, GETDATE()) >= 48";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, shopId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            count = rs.getInt(1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public BigDecimal getTotalInventoryValue(long shopId) {
        BigDecimal total = BigDecimal.ZERO;
        Connection conn = getConnection();
        if (conn == null) {
            return BigDecimal.ZERO;
        }

        try (conn) {
            boolean hasBatches = checkHasProductBatches(conn);
            String sql;
            if (hasBatches) {
                sql = "SELECT SUM(pv.price * COALESCE(pb.current_quantity, pv.stock_quantity)) "
                    + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "LEFT JOIN product_batches pb ON pv.variant_id = pb.variant_id "
                    + "WHERE p.shop_id = ?";
            } else {
                sql = "SELECT SUM(pv.price * pv.stock_quantity) "
                    + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "WHERE p.shop_id = ?";
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BigDecimal val = rs.getBigDecimal(1);
                        if (val != null) {
                            total = val;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

    public boolean restockVariant(long variantId, int addedQuantity) {
        String sqlVariant = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE variant_id = ?";
        String sqlBatch = "UPDATE product_batches SET current_quantity = current_quantity + ?, initial_quantity = initial_quantity + ? WHERE variant_id = ?";
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try (conn) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(sqlVariant)) {
                ps1.setInt(1, addedQuantity);
                ps1.setLong(2, variantId);
                ps1.executeUpdate();
            }

            if (checkHasProductBatches(conn)) {
                try (PreparedStatement ps2 = conn.prepareStatement(sqlBatch)) {
                    ps2.setInt(1, addedQuantity);
                    ps2.setInt(2, addedQuantity);
                    ps2.setLong(3, variantId);
                    ps2.executeUpdate();
                } catch (Exception ignored) {}
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean applyFreshSaleDiscount(long variantId, int discountPercent) {
        String sql = "UPDATE product_variants SET price = price * (100.0 - ?) / 100.0 WHERE variant_id = ?";
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, discountPercent);
            ps.setLong(2, variantId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


    // ================= BATCH & INVENTORY TRANSACTIONS (feature/shop_product) =================

    public List<ProductBatch> getBatchesByShopId(long shopId) {
        List<ProductBatch> list = new ArrayList<>();
        String sql = "SELECT b.batch_id, b.batch_code, b.variant_id, b.initial_quantity, "
                + "       b.current_quantity, b.expiry_date, b.status, "
                + "       DATEDIFF(day, GETDATE(), b.expiry_date) AS days_remaining, "
                + "       CASE "
                + "           WHEN b.expiry_date < GETDATE() THEN N'Quá hạn' "
                + "           WHEN DATEDIFF(day, GETDATE(), b.expiry_date) BETWEEN 0 AND 7 THEN N'Cận date' "
                + "           ELSE N'An toàn' "
                + "       END AS status_text, "
                + "       pv.sku, pv.variant_name, p.name AS product_name, "
                + "       c.category_name, product_image.image_url "
                + "FROM product_batches b "
                + "JOIN product_variants pv ON b.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY (SELECT TOP 1 pi.image_url FROM product_images pi "
                + "             WHERE pi.product_id = p.product_id "
                + "             ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) product_image "
                + "WHERE p.shop_id = ? "
                + "ORDER BY b.expiry_date ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductBatch batch = new ProductBatch();
                    batch.setBatchId(rs.getLong("batch_id"));
                    batch.setBatchCode(rs.getString("batch_code"));
                    batch.setVariantId(rs.getLong("variant_id"));
                    batch.setInitialQuantity(rs.getInt("initial_quantity"));
                    batch.setCurrentQuantity(rs.getInt("current_quantity"));
                    batch.setExpiryDate(rs.getDate("expiry_date"));
                    batch.setStatus(rs.getString("status"));

                    // Nhận trực tiếp kết quả từ SQL tính sẵn
                    batch.setDaysRemaining(rs.getInt("days_remaining"));
                    batch.setStatusText(rs.getString("status_text"));

                    batch.setSku(rs.getString("sku"));
                    batch.setVariantName(rs.getString("variant_name"));
                    batch.setProductName(rs.getString("product_name") + " (" + rs.getString("variant_name") + ")");
                    batch.setImageUrl(rs.getString("image_url"));

                    list.add(batch);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean restockBatch(long variantId, long shopId, long userId, int quantity, String expiryDate, String note) {
        String sqlGetCount = "SELECT COUNT(*) FROM product_batches WHERE batch_code LIKE ?";
        String sqlInsertBatch = "INSERT INTO product_batches (batch_code, variant_id, initial_quantity, current_quantity, expiry_date, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, 'ACTIVE', GETDATE(), GETDATE())";
        String sqlUpdateVariantStock = "UPDATE product_variants SET stock_quantity = stock_quantity + ?, updated_at = GETDATE() WHERE variant_id = ?";
        String sqlInsertTrans = "INSERT INTO inventory_transactions (batch_id, variant_id, shop_id, user_id, transaction_type, quantity_changed, previous_stock, new_stock, reason, created_at) VALUES (?, ?, ?, ?, 'RESTOCK', ?, ?, ?, ?, GETDATE())";

        java.time.LocalDate now = java.time.LocalDate.now();
        String yearMonth = String.format("%d%02d", now.getYear(), now.getMonthValue());
        String prefix = "LOT-" + yearMonth + "-";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Bật Transaction đảm bảo an toàn dữ liệu

            // 1. Sinh mã lô tự động
            int sequence = 1;
            try (PreparedStatement psCount = conn.prepareStatement(sqlGetCount)) {
                psCount.setString(1, prefix + "%");
                try (ResultSet rs = psCount.executeQuery()) {
                    if (rs.next()) {
                        sequence = rs.getInt(1) + 1;
                    }
                }
            }
            String batchCode = prefix + String.format("%02d", sequence);

            // 2. Insert vào product_batches
            long generatedBatchId = 0;
            try (PreparedStatement psBatch = conn.prepareStatement(sqlInsertBatch, Statement.RETURN_GENERATED_KEYS)) {
                psBatch.setString(1, batchCode);
                psBatch.setLong(2, variantId);
                psBatch.setInt(3, quantity);
                psBatch.setInt(4, quantity);
                psBatch.setDate(5, java.sql.Date.valueOf(expiryDate));
                psBatch.executeUpdate();

                try (ResultSet rsKeys = psBatch.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        generatedBatchId = rsKeys.getLong(1);
                    }
                }
            }

            // 3. Cộng dồn stock_quantity vào bảng product_variants tương ứng
            try (PreparedStatement psUpdateVar = conn.prepareStatement(sqlUpdateVariantStock)) {
                psUpdateVar.setInt(1, quantity);
                psUpdateVar.setLong(2, variantId);
                psUpdateVar.executeUpdate();
            }

            // 4. Ghi log vào inventory_transactions
            try (PreparedStatement psTrans = conn.prepareStatement(sqlInsertTrans)) {
                psTrans.setLong(1, generatedBatchId);
                psTrans.setLong(2, variantId);
                psTrans.setLong(3, shopId);
                psTrans.setLong(4, userId);
                psTrans.setInt(5, quantity);
                psTrans.setInt(6, 0);
                psTrans.setInt(7, quantity);
                psTrans.setString(8, (note != null && !note.isEmpty()) ? note : "Nhập kho lô mới " + batchCode);
                psTrans.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    public boolean adjustBatch(long batchId, long variantId, long shopId, long userId, int deductQuantity, String transactionType, String reason) {
        String sqlGetBatch = "SELECT current_quantity, status FROM product_batches WHERE batch_id = ?";
        String sqlUpdateBatch = "UPDATE product_batches SET current_quantity = current_quantity - ?, "
                + "status = CASE WHEN (current_quantity - ?) <= 0 OR ? = 'EXPIRED' THEN 'INACTIVE' ELSE status END, "
                + "updated_at = GETDATE() WHERE batch_id = ?";
        String sqlUpdateVariant = "UPDATE product_variants SET stock_quantity = stock_quantity - ?, updated_at = GETDATE() WHERE variant_id = ?";
        String sqlInsertTrans = "INSERT INTO inventory_transactions (batch_id, variant_id, shop_id, user_id, transaction_type, quantity_changed, previous_stock, new_stock, reason, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Bật Transaction

            int currentQty = 0;
            try (PreparedStatement psGet = conn.prepareStatement(sqlGetBatch)) {
                psGet.setLong(1, batchId);
                try (ResultSet rs = psGet.executeQuery()) {
                    if (rs.next()) {
                        currentQty = rs.getInt("current_quantity");
                    } else {
                        return false;
                    }
                }
            }

            // Kiểm tra tồn kho lô
            if (currentQty < deductQuantity) {
                return false; // Không đủ hàng -> trả về false, KHÔNG NÉM LỖI
            }

            int newQty = currentQty - deductQuantity;

            // 1. Cập nhật số lượng và trạng thái lô
            try (PreparedStatement psUpBatch = conn.prepareStatement(sqlUpdateBatch)) {
                psUpBatch.setInt(1, deductQuantity);
                psUpBatch.setInt(2, deductQuantity);
                psUpBatch.setString(3, transactionType);
                psUpBatch.setLong(4, batchId);
                psUpBatch.executeUpdate();
            }

            // 2. Cập nhật tổng tồn kho biến thể
            try (PreparedStatement psUpVar = conn.prepareStatement(sqlUpdateVariant)) {
                psUpVar.setInt(1, deductQuantity);
                psUpVar.setLong(2, variantId);
                psUpVar.executeUpdate();
            }

            // 3. Ghi log giao dịch kho
            try (PreparedStatement psTrans = conn.prepareStatement(sqlInsertTrans)) {
                psTrans.setLong(1, batchId);
                psTrans.setLong(2, variantId);
                psTrans.setLong(3, shopId);
                psTrans.setLong(4, userId);
                psTrans.setString(5, transactionType);
                psTrans.setInt(6, -deductQuantity);
                psTrans.setInt(7, currentQty);
                psTrans.setInt(8, newQty);
                psTrans.setString(9, (reason != null && !reason.trim().isEmpty()) ? reason : "Trừ hao kho thủ công");
                psTrans.executeUpdate();
            }

            conn.commit();
            return true; // Thành công
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false; // Lỗi SQL xảy ra -> tự catch, rollback và trả về false, KHÔNG NÉM LỖI RA NGOÀI
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    public List<InventoryTransaction> getInventoryHistory(int variantId, int batchId, int shopId) {
        List<InventoryTransaction> historyList = new ArrayList<>();

        // Thêm điều kiện t.batch_id = ? để lọc chính xác theo lô
        String sql = "SELECT it.*, u.full_name AS fullName, u.avatar_url AS userAvatar, u.email AS userEmail "
                + "FROM inventory_transactions it "
                + "LEFT JOIN users u ON it.user_id = u.user_id "
                + "WHERE it.variant_id = ? AND it.batch_id = ? AND it.shop_id = ? "
                + "ORDER BY it.created_at DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, variantId);
            ps.setInt(2, batchId); // Truyền tham số batchId vào
            ps.setInt(3, shopId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InventoryTransaction it = new InventoryTransaction();
                    it.setTransactionId(rs.getInt("transaction_id"));
                    it.setBatchId(rs.getInt("batch_id"));
                    it.setVariantId(rs.getInt("variant_id"));
                    it.setShopId(rs.getInt("shop_id"));
                    it.setUserId(rs.getInt("user_id"));
                    it.setTransactionType(rs.getString("transaction_type"));
                    it.setQuantityChanged(rs.getInt("quantity_changed"));
                    it.setPreviousStock(rs.getInt("previous_stock"));
                    it.setNewStock(rs.getInt("new_stock"));
                    it.setReason(rs.getString("reason"));
                    it.setCreatedAt(rs.getTimestamp("created_at"));

                    // Map thông tin người thực hiện (JOIN từ bảng users)
                    it.setFullName(rs.getString("fullName"));
                    it.setUserAvatar(rs.getString("userAvatar"));
                    it.setUserEmail(rs.getString("userEmail"));

                    historyList.add(it);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return historyList;
    }

    public boolean checkExistBatchByBatchId(long batchId) {
        boolean checkExit = false;
        String sql = "Select*from product_batches where batch_id=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, batchId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                checkExit = true;
                return checkExit;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return checkExit;
    }

    /**
     * Kiểm tra xem lô hàng và biến thể có thuộc quyền sở hữu của shop hay không
     */
    public boolean checkBatchBelongsToShop(int variantId, int batchId, int shopId) {
        String sql = "SELECT 1 FROM product_batches b "
                + "JOIN product_variants v ON b.variant_id = v.variant_id "
                + "JOIN products p ON v.product_id = p.product_id "
                + "WHERE b.batch_id = ? AND v.variant_id = ? AND p.shop_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, batchId);
            ps.setInt(2, variantId);
            ps.setInt(3, shopId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next(); // Trả về true nếu tồn tại bản ghi khớp, ngược lại false
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    
public boolean disposeBatch(long batchId, long variantId, long shopId, long userId, String reasonCode, String description) {
        String sqlGet = "SELECT variant_id, current_quantity FROM product_batches WHERE batch_id = ?";
        String sqlUpBatch = "UPDATE product_batches SET current_quantity = 0, status = 'INACTIVE', updated_at = GETDATE() WHERE batch_id = ?";
        String sqlUpVar = "UPDATE product_variants SET stock_quantity = stock_quantity - ?, updated_at = GETDATE() WHERE variant_id = ?";
        String sqlInsTrans = "INSERT INTO inventory_transactions (batch_id, variant_id, shop_id, user_id, transaction_type, quantity_changed, previous_stock, new_stock, reason, created_at) "
                           + "VALUES (?, ?, ?, ?, 'DISPOSAL', ?, ?, 0, ?, GETDATE())";

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            int currentQty = 0;
            long realVariantId = 0;

            // 1. Lấy thông tin lô hàng
            try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                ps.setLong(1, batchId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        realVariantId = rs.getLong("variant_id");
                        currentQty = rs.getInt("current_quantity");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (currentQty <= 0) {
                conn.rollback();
                return false;
            }

            // 2. Cập nhật lô hàng về 0 và chuyển trạng thái thành INACTIVE
            try (PreparedStatement ps = conn.prepareStatement(sqlUpBatch)) {
                ps.setLong(1, batchId);
                ps.executeUpdate();
            }

            // 3. Trừ tồn kho biến thể tương ứng
            try (PreparedStatement ps = conn.prepareStatement(sqlUpVar)) {
                ps.setInt(1, currentQty);
                ps.setLong(2, realVariantId);
                ps.executeUpdate();
            }

            // 4. Ghi log lịch sử giao dịch hủy kho
            try (PreparedStatement ps = conn.prepareStatement(sqlInsTrans)) {
                ps.setLong(1, batchId);
                ps.setLong(2, realVariantId);
                ps.setLong(3, shopId);
                ps.setLong(4, userId);
                ps.setInt(5, -currentQty);
                ps.setInt(6, currentQty);
                ps.setString(7, buildReasonText(reasonCode, description));
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }


    private String buildReasonText(String reasonCode, String description) {
        String baseReason;
        if (reasonCode == null) {
            reasonCode = "";
        }
        switch (reasonCode) {
            case "DAMAGED":
                baseReason = "Trái cây bị dập nát, hư hỏng cơ học";
                break;
            case "STORAGE_ISSUE":
                baseReason = "Sự cố bảo quản kho mát / mất điện đột xuất";
                break;
            case "QUALITY_FAIL":
                baseReason = "Không đạt tiêu chuẩn ATVSTP kiểm định";
                break;
            case "EXPIRED":
                baseReason = "Hàng hết hạn sử dụng (Hủy toàn bộ lô)";
                break;
            case "LOST":
                baseReason = "Kiểm kê thất thoát kho";
                break;
            default:
                baseReason = "Xuất hủy lô hàng";
                break;
        }
        if (description != null && !description.trim().isEmpty()) {
            return baseReason + " - " + description.trim();
        }
        return baseReason;
    }
}
