package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.InventoryBatchItem;
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
}
