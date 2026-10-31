package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import model.Product;
import model.ProductVariant;
import model.Category;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.DBContext;

public class ProductDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    public List<ProductVariant> getVariantsByShopId(long shopId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT "
                + "    COALESCE(pv.variant_id, 0) AS variant_id, "
                + "    p.product_id, "
                + "    COALESCE(pv.sku, 'CHUA-CO-SKU') AS sku, "
                + "    COALESCE(pv.variant_name, N'Chưa phân loại') AS variant_name, "
                + "    COALESCE(pv.price, 0) AS price, "
                + "    COALESCE(pv.original_price, 0) AS original_price, "
                + "    COALESCE(pv.stock_quantity, 0) AS stock_quantity, "
                + "    COALESCE(pv.unit, 'kg') AS unit, "
                + "    COALESCE(pi.image_url, 'https://images.unsplash.com/photo-1543528176-61b239494933?w=800') AS image_url, "
                + "    COALESCE(pv.is_active, 1) AS is_active, "
                + "    p.name AS product_name, "
                + "    p.origin, "
                + "    c.category_name, "
                + "    p.certification, "
                + "    (SELECT COUNT(*) FROM product_variants WHERE product_id = p.product_id) AS total_variants_count "
                + "FROM products p "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE p.shop_id = ? "
                + "ORDER BY p.product_id DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setOriginalPrice(rs.getBigDecimal("original_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1543528176-61b239494933?w=800&auto=format&fit=crop&q=80";
                    }
                    v.setImage(img);

                    v.setIsActive(rs.getBoolean("is_active"));
                    v.setProductName(rs.getString("product_name"));
                    v.setOrigin(rs.getString("origin"));
                    v.setCategoryName(rs.getString("category_name"));
                    v.setCertification(rs.getString("certification"));
                    v.setTotalVariantsCount(rs.getInt("total_variants_count"));

                    list.add(v);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public int countProductsByShopId(long shopId) {
        String sql = "SELECT COUNT(DISTINCT p.product_id) FROM products p WHERE p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return 0;
    }

    public int countVariantsByShopId(long shopId) {
        String sql = "SELECT COUNT(pv.variant_id) FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return 0;
    }
    
    public ProductVariant getVariantDetailForEdit(long variantId, long shopId) {
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, "
                   + "       pv.price, pv.original_price, pv.stock_quantity, pv.low_stock_threshold, pv.is_active, "
                   + "       p.name AS product_name, p.category_id, p.origin, p.storage_temp, p.certification, p.description, "
                   + "       c.category_name, "
                   + "       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC) AS cover_image "
                   + "FROM product_variants pv "
                   + "JOIN products p ON pv.product_id = p.product_id "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "WHERE pv.variant_id = ? AND p.shop_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            ps.setLong(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setUnit(rs.getString("unit"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setOriginalPrice(rs.getBigDecimal("original_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                    v.setIsActive(rs.getBoolean("is_active"));
                    v.setProductName(rs.getString("product_name"));
                    v.setCategoryId(rs.getInt("category_id"));
                    v.setCategoryName(rs.getString("category_name"));
                    v.setOrigin(rs.getString("origin"));
                    v.setStorageTemp(rs.getString("storage_temp"));
                    v.setCertification(rs.getString("certification"));
                    v.setDescription(rs.getString("description"));

                    String cover = rs.getString("cover_image");
                    if (cover == null || cover.isEmpty()) {
                        cover = "https://images.unsplash.com/photo-1543528176-61b239494933?w=800&auto=format&fit=crop&q=80";
                    }
                    v.setImage(cover);

                    List<String> detailImages = new ArrayList<>();
                    String sqlImgs = "SELECT image_url FROM product_images WHERE product_id = ? AND is_thumbnail = 0 ORDER BY display_order ASC";
                    try (PreparedStatement psImg = conn.prepareStatement(sqlImgs)) {
                        psImg.setLong(1, v.getProductId());
                        try (ResultSet rsImg = psImg.executeQuery()) {
                            while (rsImg.next()) {
                                detailImages.add(rsImg.getString("image_url"));
                            }
                        }
                    }
                    v.setGalleryImages(detailImages);
                    return v;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return null;
    }
    
    public boolean updateFullProduct(long shopId, long productId, long variantId, String name, int categoryId,
                                     String origin, String storageTemp, String certification, String description,
                                     String sku, String variantName, String unit, BigDecimal price,
                                     BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                                     boolean isActive, String coverImageUrl, List<String> detailImageUrls) {

        String sqlProduct = "UPDATE products "
                          + "SET name = ?, category_id = ?, origin = ?, storage_temp = ?, certification = ?, description = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP "
                          + "WHERE product_id = ? AND shop_id = ?";

        String sqlVariant = "UPDATE product_variants "
                          + "SET sku = ?, variant_name = ?, unit = ?, price = ?, original_price = ?, stock_quantity = ?, low_stock_threshold = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP "
                          + "WHERE variant_id = ? AND product_id = ?";

        String sqlDeleteImages = "DELETE FROM product_images WHERE product_id = ?";
        String sqlInsertImage = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) "
                              + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";

        String sqlUpdateBatch = "UPDATE product_batches SET current_quantity = ? WHERE variant_id = ? AND status = 'ACTIVE'";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sqlProduct)) {
                ps.setString(1, name);
                if (categoryId > 0) {
                    ps.setInt(2, categoryId);
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }
                ps.setString(3, origin != null && !origin.trim().isEmpty() ? origin.trim() : "Đà Lạt, Lâm Đồng");
                ps.setString(4, storageTemp != null && !storageTemp.trim().isEmpty() ? storageTemp.trim() : "Kho lạnh 2°C - 8°C");
                ps.setString(5, certification != null && !certification.trim().isEmpty() ? certification.trim() : "VietGAP");
                ps.setString(6, description != null ? description : "");
                ps.setBoolean(7, isActive);
                ps.setLong(8, productId);
                ps.setLong(9, shopId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlVariant)) {
                ps.setString(1, sku != null && !sku.trim().isEmpty() ? sku.trim() : "SKU-" + variantId);
                ps.setString(2, variantName != null && !variantName.trim().isEmpty() ? variantName.trim() : "Tiêu chuẩn");
                ps.setString(3, unit != null && !unit.trim().isEmpty() ? unit.trim() : "Hộp (500g - 1kg)");
                ps.setBigDecimal(4, price != null ? price : BigDecimal.ZERO);
                ps.setBigDecimal(5, originalPrice != null ? originalPrice : price);
                ps.setInt(6, stockQuantity);
                ps.setInt(7, lowStockThreshold > 0 ? lowStockThreshold : 10);
                ps.setBoolean(8, isActive);
                ps.setLong(9, variantId);
                ps.setLong(10, productId);
                ps.executeUpdate();
            }

            if (coverImageUrl != null && !coverImageUrl.trim().isEmpty()) {
                try (PreparedStatement psDel = conn.prepareStatement(sqlDeleteImages)) {
                    psDel.setLong(1, productId);
                    psDel.executeUpdate();
                }

                try (PreparedStatement psImg = conn.prepareStatement(sqlInsertImage)) {
                    psImg.setLong(1, productId);
                    psImg.setString(2, coverImageUrl.trim());
                    psImg.setBoolean(3, true);
                    psImg.setInt(4, 1);
                    psImg.executeUpdate();
                }

                if (detailImageUrls != null && !detailImageUrls.isEmpty()) {
                    int order = 2;
                    for (String dImg : detailImageUrls) {
                        if (dImg != null && !dImg.trim().isEmpty()) {
                            try (PreparedStatement psImg = conn.prepareStatement(sqlInsertImage)) {
                                psImg.setLong(1, productId);
                                psImg.setString(2, dImg.trim());
                                psImg.setBoolean(3, false);
                                psImg.setInt(4, order++);
                                psImg.executeUpdate();
                            }
                        }
                    }
                }
            }

            try (PreparedStatement psBatch = conn.prepareStatement(sqlUpdateBatch)) {
                psBatch.setInt(1, stockQuantity);
                psBatch.setLong(2, variantId);
                psBatch.executeUpdate();
            } catch (Exception ignored) {}

            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public boolean isSkuExists(String sku) {
        String sql = "SELECT 1 FROM product_variants WHERE sku = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sku);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }
    
    public boolean insertProductWithVariantAndBatch(long shopId, String name, int categoryId, String origin,
                                                    String storageTemp, String certification, String description,
                                                    String sku, String variantName, String unit, BigDecimal price,
                                                    BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                                                    String batchCode, java.sql.Date harvestDate, java.sql.Date expiryDate, BigDecimal importCost) {
        
        String sqlProduct = "INSERT INTO products (shop_id, category_id, name, slug, origin, storage_temp, certification, description, is_active) "
                          + "VALUES (?, ?, ?, LOWER(REPLACE(?, ' ', '-')), ?, ?, ?, ?, 1)";
        String sqlVariant = "INSERT INTO product_variants (product_id, sku, variant_name, unit, price, original_price, stock_quantity, low_stock_threshold, is_active) "
                          + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
        String sqlBatch = "INSERT INTO product_batches (batch_code, variant_id, farm_source, harvest_date, expiry_date, initial_quantity, current_quantity, import_cost, status) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            long productId = -1;
            long variantId = -1;

            try (PreparedStatement ps = conn.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, shopId);
                ps.setInt(2, categoryId);
                ps.setString(3, name);
                ps.setString(4, name);
                ps.setString(5, origin);
                ps.setString(6, storageTemp);
                ps.setString(7, certification);
                ps.setString(8, description);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) productId = rs.getLong(1);
                }
            }

            if (productId == -1) { conn.rollback(); return false; }

            try (PreparedStatement ps = conn.prepareStatement(sqlVariant, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, productId);
                ps.setString(2, sku);
                ps.setString(3, variantName);
                ps.setString(4, unit);
                ps.setBigDecimal(5, price);
                ps.setBigDecimal(6, originalPrice);
                ps.setInt(7, stockQuantity);
                ps.setInt(8, lowStockThreshold);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) variantId = rs.getLong(1);
                }
            }

            if (variantId == -1) { conn.rollback(); return false; }

            if (batchCode != null && !batchCode.trim().isEmpty() && harvestDate != null && expiryDate != null) {
                try (PreparedStatement ps = conn.prepareStatement(sqlBatch)) {
                    ps.setString(1, batchCode);
                    ps.setLong(2, variantId);
                    ps.setString(3, origin);
                    ps.setDate(4, harvestDate);
                    ps.setDate(5, expiryDate);
                    ps.setInt(6, stockQuantity);
                    ps.setInt(7, stockQuantity);
                    ps.setBigDecimal(8, importCost != null ? importCost : BigDecimal.ZERO);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public boolean toggleVariantActiveStatus(long variantId, long shopId) {
        String sql = "UPDATE pv SET pv.is_active = CASE WHEN pv.is_active = 1 THEN 0 ELSE 1 END "
                + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ? AND p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            ps.setLong(2, shopId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public boolean deleteVariantById(long variantId, long shopId) {
        String sql = "DELETE pv FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ? AND p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            ps.setLong(2, shopId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public boolean softDeleteVariant(long variantId, long shopId) {
        String sql = "UPDATE pv SET pv.is_active = 0 "
                + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ? AND p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            ps.setLong(2, shopId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public List<ProductVariant> getFilteredVariantsByShop(long shopId, String keyword, String categoryId, String certification, String stockLevel, String statusTab, int page, int pageSize) {
        List<ProductVariant> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("    pv.variant_id, ")
                .append("    pv.product_id, ")
                .append("    pv.sku, ")
                .append("    pv.variant_name, ")
                .append("    pv.price, ")
                .append("    pv.original_price, ")
                .append("    pv.stock_quantity, ")
                .append("    pv.unit, ")
                .append("    COALESCE(pi.image_url, (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, image_id ASC)) AS image_url, ")
                .append("    pv.is_active, ")
                .append("    p.name AS product_name, ")
                .append("    p.origin, ")
                .append("    c.category_name, ")
                .append("    p.certification, ")
                .append("    (SELECT COUNT(*) FROM product_variants WHERE product_id = p.product_id) AS total_variants_count ")
                .append("FROM product_variants pv ")
                .append("JOIN products p ON pv.product_id = p.product_id ")
                .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
                .append("LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 ")
                .append("WHERE p.shop_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(shopId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR pv.sku LIKE ? OR pv.variant_name LIKE ? OR p.origin LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (categoryId != null && !categoryId.trim().isEmpty() && !categoryId.equals("0")) {
            try {
                int catId = Integer.parseInt(categoryId.trim());
                sql.append(" AND p.category_id = ? ");
                params.add(catId);
            } catch (NumberFormatException ignored) {
            }
        }

        if (certification != null && !certification.trim().isEmpty() && !certification.equalsIgnoreCase("all")) {
            sql.append(" AND p.certification LIKE ? ");
            params.add("%" + certification.trim() + "%");
        }

        if (stockLevel != null && !stockLevel.trim().isEmpty()) {
            if ("critical".equalsIgnoreCase(stockLevel) || "<5".equals(stockLevel)) {
                sql.append(" AND pv.stock_quantity <= 5 ");
            } else if ("low".equalsIgnoreCase(stockLevel)) {
                sql.append(" AND pv.stock_quantity <= 15 ");
            } else if ("stable".equalsIgnoreCase(stockLevel)) {
                sql.append(" AND pv.stock_quantity > 15 AND pv.stock_quantity <= 40 ");
            } else if ("abundant".equalsIgnoreCase(stockLevel)) {
                sql.append(" AND pv.stock_quantity > 40 ");
            }
        }

        if (statusTab != null && !statusTab.trim().isEmpty() && !statusTab.equalsIgnoreCase("all")) {
            if ("active".equalsIgnoreCase(statusTab)) {
                sql.append(" AND pv.is_active = 1 AND pv.stock_quantity > 0 ");
            } else if ("vietgap".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%') ");
            } else if ("hidden".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (pv.stock_quantity = 0 OR pv.is_active = 0) ");
            } else if ("warning".equalsIgnoreCase(statusTab)) {
                sql.append(" AND pv.stock_quantity <= 5 ");
            }
        }

        sql.append(" ORDER BY pv.variant_id DESC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setOriginalPrice(rs.getBigDecimal("original_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=100&h=100&fit=crop";
                    }
                    v.setImage(img);

                    v.setIsActive(rs.getBoolean("is_active"));
                    v.setProductName(rs.getString("product_name"));
                    v.setOrigin(rs.getString("origin"));
                    v.setCategoryName(rs.getString("category_name"));
                    v.setCertification(rs.getString("certification"));
                    v.setTotalVariantsCount(rs.getInt("total_variants_count"));

                    list.add(v);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }
    
    public int countFilteredVariants(long shopId, String keyword, String categoryId, 
                                     String certification, String stockLevel, String statusTab) {
        int count = 0;
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(pv.variant_id) ")
           .append("FROM product_variants pv ")
           .append("JOIN products p ON pv.product_id = p.product_id ")
           .append("WHERE p.shop_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(shopId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR pv.sku LIKE ? OR pv.variant_name LIKE ? OR p.origin LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (categoryId != null && !categoryId.trim().isEmpty() && !categoryId.equals("0")) {
            try {
                int catId = Integer.parseInt(categoryId.trim());
                sql.append(" AND p.category_id = ? ");
                params.add(catId);
            } catch (NumberFormatException ignored) {}
        }

        if (certification != null && !certification.trim().isEmpty() && !certification.equalsIgnoreCase("all")) {
            sql.append(" AND p.certification LIKE ? ");
            params.add("%" + certification.trim() + "%");
        }

        if (stockLevel != null && !stockLevel.trim().isEmpty()) {
            if ("critical".equalsIgnoreCase(stockLevel) || "<5".equals(stockLevel)) {
                sql.append(" AND pv.stock_quantity <= 5 ");
            } else if ("low".equalsIgnoreCase(stockLevel)) {
                sql.append(" AND pv.stock_quantity <= 15 ");
            } else if ("stable".equalsIgnoreCase(stockLevel)) {
                sql.append(" AND pv.stock_quantity > 15 AND pv.stock_quantity <= 40 ");
            } else if ("abundant".equalsIgnoreCase(stockLevel)) {
                sql.append(" AND pv.stock_quantity > 40 ");
            }
        }

        if (statusTab != null && !statusTab.trim().isEmpty()) {
            if ("active".equalsIgnoreCase(statusTab)) {
                sql.append(" AND pv.is_active = 1 ");
            } else if ("vietgap".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%') ");
            } else if ("hidden".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (pv.stock_quantity = 0 OR pv.is_active = 0) ");
            } else if ("warning".equalsIgnoreCase(statusTab)) {
                sql.append(" AND pv.stock_quantity <= 5 ");
            }
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }

        return count;
    }   

    public int countVariantsByStatusTab(long shopId, String statusTab) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(pv.variant_id) "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE p.shop_id = ?"
        );

        if (statusTab != null && !statusTab.trim().isEmpty() && !statusTab.equalsIgnoreCase("all")) {
            if ("active".equalsIgnoreCase(statusTab)) {
                sql.append(" AND pv.is_active = 1 AND pv.stock_quantity > 0");
            } else if ("vietgap".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%')");
            } else if ("hidden".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (pv.stock_quantity = 0 OR pv.is_active = 0)");
            } else if ("warning".equalsIgnoreCase(statusTab)) {
                sql.append(" AND pv.stock_quantity <= 5");
            }
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return 0;
    }

    public List<String> getAllCertifications() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT certification FROM products WHERE certification IS NULL OR certification != '' ORDER BY certification ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String cert = rs.getString("certification");
                if (cert != null && !cert.trim().isEmpty()) {
                    list.add(cert.trim());
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<String> getAllStorageTemps() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT storage_temp FROM products WHERE storage_temp IS NULL OR storage_temp != '' ORDER BY storage_temp ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String temp = rs.getString("storage_temp");
                if (temp != null && !temp.trim().isEmpty()) {
                    list.add(temp.trim());
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }
    
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.category_name, c.slug, c.image_url, c.icon_class, "
                   + "       COUNT(p.product_id) AS product_count "
                   + "FROM categories c "
                   + "LEFT JOIN products p ON c.category_id = p.category_id AND p.is_active = 1 "
                   + "WHERE c.is_active = 1 "
                   + "GROUP BY c.category_id, c.category_name, c.slug, c.image_url, c.icon_class "
                   + "ORDER BY product_count DESC, c.category_name ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category cat = new Category();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setCategoryName(rs.getString("category_name"));
                cat.setSlug(rs.getString("slug"));
                cat.setProductCount(rs.getInt("product_count"));
                cat.setImageUrl(rs.getString("image_url"));
                cat.setIconClass(rs.getString("icon_class"));

                list.add(cat);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<String> getAllUnits() {
        List<String> list = new ArrayList<>();

        list.add("hộp");
        list.add("kg");
        list.add("túi");
        list.add("thùng");
        list.add("gram");
        list.add("giỏ");
        list.add("nải");
        list.add("quả");

        String sql = "SELECT DISTINCT unit FROM product_variants WHERE unit IS NOT NULL AND unit != '' ORDER BY unit ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String u = rs.getString("unit");
                if (u != null && !u.trim().isEmpty()) {
                    String unitLower = u.trim().toLowerCase();
                    
                    if (!list.contains(unitLower)) {
                        list.add(unitLower);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }

        return list;
    }

    public long insertFullProduct(long shopId, String name, int categoryId, String origin,
            String storageTemp, String certification, String description,
            String sku, String variantName, String unit, BigDecimal price,
            BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
            boolean isActive, String coverImageUrl, List<String> detailImageUrls,
            String shippingStandard) {

        String sqlProduct = "INSERT INTO products (shop_id, category_id, name, slug, origin, storage_temp, certification, description, is_active, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        String sqlVariant = "INSERT INTO product_variants (product_id, sku, variant_name, unit, price, original_price, stock_quantity, low_stock_threshold, is_active, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        String sqlImage = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) "
                + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        String sqlBatch = "INSERT INTO product_batches (batch_code, variant_id, farm_source, harvest_date, expiry_date, initial_quantity, current_quantity, import_cost, freshness_score, harvest_time_label, freshness_note, batch_type, pending_packing_text, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, CURRENT_TIMESTAMP, DATEADD(day, 7, CURRENT_TIMESTAMP), ?, ?, ?, 98, N'05:30 Sáng nay', N'Độ tươi 98% (Vừa hái sáng nay)', N'Hái sáng', N'0 Đơn chờ đóng gói', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            long productId = -1;
            long variantId = -1;

            String slug = generateProductSlug(name);

            try (PreparedStatement ps = conn.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, shopId);
                if (categoryId > 0) {
                    ps.setInt(2, categoryId);
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }
                ps.setString(3, name);
                ps.setString(4, slug);
                ps.setString(5, origin != null && !origin.trim().isEmpty() ? origin.trim() : "Đà Lạt, Lâm Đồng");
                ps.setString(6, storageTemp != null && !storageTemp.trim().isEmpty() ? storageTemp.trim() : "Kho lạnh 2°C - 8°C");
                ps.setString(7, certification != null && !certification.trim().isEmpty() ? certification.trim() : "VietGAP");
                ps.setString(8, description != null ? description : "");
                ps.setBoolean(9, isActive);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        productId = rs.getLong(1);
                    }
                }
            }

            if (productId == -1) {
                conn.rollback();
                return -1;
            }

            String finalSku = (sku != null && !sku.trim().isEmpty()) ? sku.trim() : ("SKU-" + (System.currentTimeMillis() % 1000000));
            int skuRetry = 1;
            while (isSkuExists(finalSku)) {
                finalSku = "SKU-" + (System.currentTimeMillis() % 1000000) + "-" + (skuRetry++);
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlVariant, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, productId);
                ps.setString(2, finalSku);
                ps.setString(3, (variantName != null && !variantName.trim().isEmpty()) ? variantName.trim() : "Tiêu chuẩn");
                ps.setString(4, (unit != null && !unit.trim().isEmpty()) ? unit.trim() : "Hộp (500g - 1kg)");
                ps.setBigDecimal(5, price != null ? price : BigDecimal.ZERO);
                ps.setBigDecimal(6, originalPrice != null ? originalPrice : price);
                ps.setInt(7, stockQuantity);
                ps.setInt(8, lowStockThreshold > 0 ? lowStockThreshold : 10);
                ps.setBoolean(9, isActive);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        variantId = rs.getLong(1);
                    }
                }
            }

            if (variantId == -1) {
                conn.rollback();
                return -1;
            }

            if (coverImageUrl != null && !coverImageUrl.trim().isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(sqlImage)) {
                    ps.setLong(1, productId);
                    ps.setString(2, coverImageUrl.trim());
                    ps.setBoolean(3, true);
                    ps.setInt(4, 1);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement(sqlImage)) {
                    ps.setLong(1, productId);
                    ps.setString(2, "https://images.unsplash.com/photo-1543528176-61b239494933?w=800&auto=format&fit=crop&q=80");
                    ps.setBoolean(3, true);
                    ps.setInt(4, 1);
                    ps.executeUpdate();
                }
            }

            if (detailImageUrls != null && !detailImageUrls.isEmpty()) {
                int order = 2;
                for (String imgUrl : detailImageUrls) {
                    if (imgUrl != null && !imgUrl.trim().isEmpty()) {
                        try (PreparedStatement ps = conn.prepareStatement(sqlImage)) {
                            ps.setLong(1, productId);
                            ps.setString(2, imgUrl.trim());
                            ps.setBoolean(3, false);
                            ps.setInt(4, order++);
                            ps.executeUpdate();
                        }
                    }
                }
            }

            String batchCode = "LH-" + java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyMMdd")) + "-" + (char) ('A' + (productId % 26));
            try (PreparedStatement ps = conn.prepareStatement(sqlBatch)) {
                ps.setString(1, batchCode);
                ps.setLong(2, variantId);
                ps.setString(3, origin != null && !origin.trim().isEmpty() ? origin.trim() : "Vườn Đà Lạt");
                ps.setInt(4, stockQuantity);
                ps.setInt(5, stockQuantity);
                ps.setBigDecimal(6, originalPrice != null ? originalPrice.multiply(new BigDecimal("0.65")) : BigDecimal.ZERO);
                ps.executeUpdate();
            } catch (Exception batchEx) {
                LOGGER.log(Level.SEVERE, "Batch execution error in ProductDAO", batchEx);
            }

            conn.commit();
            return productId;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return -1;
    }

    public static String generateProductSlug(String input) {
        if (input == null || input.trim().isEmpty()) {
            return "san-pham-" + System.currentTimeMillis();
        }
        String nfdNormalizedString = java.text.Normalizer.normalize(input, java.text.Normalizer.Form.NFD);
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        String slug = pattern.matcher(nfdNormalizedString).replaceAll("");
        slug = slug.toLowerCase()
                .replaceAll("đ", "d")
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-");
        if (slug.startsWith("-")) {
            slug = slug.substring(1);
        }
        if (slug.endsWith("-")) {
            slug = slug.substring(0, slug.length() - 1);
        }
        return slug + "-" + (System.currentTimeMillis() % 100000);
    }

    public ProductVariant getVariantById(long variantId) {
        ProductVariant pv = null;
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, "
                + "pv.price, pv.original_price, pv.stock_quantity, pv.is_active, "
                + "p.name AS product_name, p.category_id, p.origin, p.storage_temp, "
                + "p.certification, p.description, "
                + "COALESCE(pi.image_url, 'https://images.unsplash.com/photo-1543528176-61b239494933?w=800') AS image_url "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE pv.variant_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    pv = new ProductVariant();
                    
                    pv.setVariantId(rs.getLong("variant_id"));
                    pv.setProductId(rs.getLong("product_id"));
                    pv.setSku(rs.getString("sku"));
                    pv.setVariantName(rs.getString("variant_name"));
                    pv.setUnit(rs.getString("unit"));
                    pv.setPrice(rs.getBigDecimal("price"));
                    pv.setOriginalPrice(rs.getBigDecimal("original_price"));
                    pv.setStockQuantity(rs.getInt("stock_quantity"));
                    pv.setIsActive(rs.getBoolean("is_active"));

                    pv.setProductName(rs.getString("product_name"));
                    pv.setCategoryId(rs.getInt("category_id"));
                    pv.setOrigin(rs.getString("origin"));
                    pv.setStorageTemp(rs.getString("storage_temp"));
                    pv.setCertification(rs.getString("certification"));
                    pv.setDescription(rs.getString("description"));
                    pv.setImage(rs.getString("image_url")); 
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return pv;
    }

    public boolean updateFullProduct(long variantId, String name, int categoryId, String origin,
            String storageTemp, String certification, String description,
            String sku, String variantName, String unit, BigDecimal price,
            BigDecimal originalPrice, int stockQuantity, boolean isActive,
            String coverImageUrl) {

        String sqlGetProductId = "SELECT product_id FROM product_variants WHERE variant_id = ?";
        String sqlUpdateProduct = "UPDATE products SET name = ?, category_id = ?, origin = ?, storage_temp = ?, certification = ?, description = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        String sqlUpdateVariant = "UPDATE product_variants SET sku = ?, variant_name = ?, unit = ?, price = ?, original_price = ?, stock_quantity = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE variant_id = ?";
        String sqlCheckImage = "SELECT image_id FROM product_images WHERE product_id = ? AND is_thumbnail = 1";
        String sqlUpdateImage = "UPDATE product_images SET image_url = ? WHERE product_id = ? AND is_thumbnail = 1";
        String sqlInsertImage = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) VALUES (?, ?, 1, 1, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            long productId = -1;

            try (PreparedStatement ps = conn.prepareStatement(sqlGetProductId)) {
                ps.setLong(1, variantId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        productId = rs.getLong("product_id");
                    }
                }
            }

            if (productId == -1) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateProduct)) {
                ps.setString(1, name);
                if (categoryId > 0) {
                    ps.setInt(2, categoryId);
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }
                ps.setString(3, origin != null ? origin.trim() : "");
                ps.setString(4, storageTemp != null ? storageTemp.trim() : "");
                ps.setString(5, certification != null ? certification.trim() : "");
                ps.setString(6, description != null ? description : "");
                ps.setBoolean(7, isActive);
                ps.setLong(8, productId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateVariant)) {
                ps.setString(1, sku != null && !sku.trim().isEmpty() ? sku.trim() : ("SKU-" + variantId));
                ps.setString(2, variantName != null && !variantName.trim().isEmpty() ? variantName.trim() : "Tiêu chuẩn");
                ps.setString(3, unit != null && !unit.trim().isEmpty() ? unit.trim() : "kg");
                ps.setBigDecimal(4, price != null ? price : BigDecimal.ZERO);
                ps.setBigDecimal(5, originalPrice != null ? originalPrice : price);
                ps.setInt(6, stockQuantity);
                ps.setBoolean(7, isActive);
                ps.setLong(8, variantId);
                ps.executeUpdate();
            }

            if (coverImageUrl != null && !coverImageUrl.trim().isEmpty()) {
                boolean hasThumbnail = false;
                try (PreparedStatement ps = conn.prepareStatement(sqlCheckImage)) {
                    ps.setLong(1, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            hasThumbnail = true;
                        }
                    }
                }

                if (hasThumbnail) {
                    try (PreparedStatement ps = conn.prepareStatement(sqlUpdateImage)) {
                        ps.setString(1, coverImageUrl.trim());
                        ps.setLong(2, productId);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsertImage)) {
                        ps.setLong(1, productId);
                        ps.setString(2, coverImageUrl.trim());
                        ps.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String query = "SELECT p.product_id, p.name, c.category_name, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.is_active = 1";

        try {
            Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                long id = rs.getLong("product_id");
                String name = rs.getString("name");
                String categoryName = rs.getString("category_name");
                if (categoryName == null) {
                    categoryName = "Trái Cây Tươi";
                }

                String image = rs.getString("image_url");
                if (image == null || image.isEmpty()) {
                    image = "https://images.unsplash.com/photo-1610832958506-aa56368176cf";
                }

                BigDecimal price = rs.getBigDecimal("price");
                if (price == null) {
                    price = new BigDecimal("100000");
                }

                BigDecimal oldPrice = price.multiply(new BigDecimal("1.25"));
                int discountPercent = 20;

                list.add(new Product(id, name, categoryName, image, price, oldPrice, discountPercent, 4.9, 18));
            }
            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Category> getHomeFeaturedCategoryTabs() {
        List<Category> list = new ArrayList<>();
        String query = "SELECT category_id, category_name, slug "
                + "FROM categories "
                + "WHERE slug IN ('trai-cay-nhap-khau', 'trai-cay-viet-nam', 'trai-cay-cat-san', 'trai-cay-thung', 'trai-cay-dong-thung', 'trai-cay-mua-he', 'trai-cay-co-san') "
                + "ORDER BY CASE slug "
                + "    WHEN 'trai-cay-nhap-khau' THEN 1 "
                + "    WHEN 'trai-cay-viet-nam' THEN 2 "
                + "    WHEN 'trai-cay-cat-san' THEN 3 "
                + "    WHEN 'trai-cay-thung' THEN 4 "
                + "    WHEN 'trai-cay-dong-thung' THEN 4 "
                + "    WHEN 'trai-cay-mua-he' THEN 5 "
                + "    WHEN 'trai-cay-co-san' THEN 6 "
                + "END";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryName(rs.getString("category_name"));
                c.setSlug(rs.getString("slug"));
                list.add(c);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Category> getHierarchyCategories() {
        List<Category> list = new ArrayList<>();
        String queryParents = "SELECT category_id, category_name, slug, description, image_url, icon_class, display_order "
                + "FROM categories WHERE parent_id IS NULL AND is_active = 1 "
                + "ORDER BY display_order ASC, category_id ASC";
        String querySubs = "SELECT category_id, parent_id, category_name, slug, description, image_url, icon_class, display_order "
                + "FROM categories WHERE parent_id IS NOT NULL AND is_active = 1 "
                + "ORDER BY display_order ASC, category_id ASC";

        try (Connection conn = getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(queryParents); ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Category c = new Category();
                        c.setCategoryId(rs.getInt("category_id"));
                        c.setCategoryName(rs.getString("category_name"));
                        c.setSlug(rs.getString("slug"));
                        c.setDescription(rs.getString("description"));
                        c.setImageUrl(rs.getString("image_url"));
                        c.setIconClass(rs.getString("icon_class"));
                        c.setDisplayOrder(rs.getInt("display_order"));
                        c.setIsActive(true);
                        list.add(c);
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(querySubs); ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int parentId = rs.getInt("parent_id");
                        Category sub = new Category();
                        sub.setCategoryId(rs.getInt("category_id"));
                        sub.setParentId(parentId);
                        sub.setCategoryName(rs.getString("category_name"));
                        sub.setSlug(rs.getString("slug"));
                        sub.setDescription(rs.getString("description"));
                        sub.setImageUrl(rs.getString("image_url"));
                        sub.setIconClass(rs.getString("icon_class"));
                        sub.setDisplayOrder(rs.getInt("display_order"));
                        sub.setIsActive(true);

                        for (Category parent : list) {
                            if (parent.getCategoryId() == parentId) {
                                parent.addSubCategory(sub);
                                break;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Product> getHomeProducts() {
        List<Product> list = new ArrayList<>();
        String query = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.origin, p.certification, p.storage_temp, pi.image_url, "
                + "dv.variant_id AS default_variant_id, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, "
                + "(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 image_url FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC"
                + ") pi "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 variant_id FROM product_variants "
                + "    WHERE product_id = p.product_id AND is_active = 1 AND stock_quantity > 0 "
                + "    ORDER BY price ASC, variant_id ASC"
                + ") dv "
                + "WHERE p.is_active = 1 "
                + "ORDER BY p.is_featured DESC, p.product_id DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                long id = rs.getLong("product_id");
                String name = rs.getString("name");
                int catId = rs.getInt("category_id");
                String categoryName = rs.getString("category_name");
                String categorySlug = rs.getString("category_slug");

                if (categoryName == null) {
                    categoryName = "Trái Cây Tươi";
                }

                String image = rs.getString("image_url");
                if (image == null || image.isEmpty()) {
                    image = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                }

                BigDecimal price = rs.getBigDecimal("price");
                if (price == null) {
                    price = new BigDecimal("100000");
                }

                BigDecimal oldPrice = price.multiply(new BigDecimal("1.25"));
                int discountPercent = 20;

                Product p = new Product(id, name, categoryName, image, price, oldPrice, discountPercent, 4.9, 32);
                p.setCategoryId(catId);
                p.setCategorySlug(categorySlug);
                p.setOrigin(rs.getString("origin"));
                p.setCertification(rs.getString("certification"));
                p.setStorageTemp(rs.getString("storage_temp"));
                p.setDefaultVariantId(rs.getLong("default_variant_id"));
                p.setUnit(rs.getString("unit"));
                int totalStock = rs.getInt("total_stock");
                p.setStockQuantity(totalStock);
                p.setInStock(totalStock > 0);
                list.add(p);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Product> getProductsByCategorySlug(String categorySlug) {
        List<Product> list = new ArrayList<>();
        String query = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.origin, p.certification, p.storage_temp, pi.image_url, dv.variant_id AS default_variant_id, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, "
                + "(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 image_url FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC"
                + ") pi "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 variant_id FROM product_variants "
                + "    WHERE product_id = p.product_id AND is_active = 1 AND stock_quantity > 0 "
                + "    ORDER BY price ASC, variant_id ASC"
                + ") dv "
                + "WHERE p.is_active = 1 AND c.slug = ? "
                + "ORDER BY p.product_id DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, categorySlug);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long id = rs.getLong("product_id");
                    String name = rs.getString("name");
                    int catId = rs.getInt("category_id");
                    String categoryName = rs.getString("category_name");
                    String categorySlugVal = rs.getString("category_slug");

                    if (categoryName == null) {
                        categoryName = "Trái Cây Tươi";
                    }

                    String image = rs.getString("image_url");
                    if (image == null || image.isEmpty()) {
                        image = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                    }

                    BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = new BigDecimal("100000");
                    }

                    BigDecimal oldPrice = price.multiply(new BigDecimal("1.25"));
                    int discountPercent = 20;

                    Product p = new Product(id, name, categoryName, image, price, oldPrice, discountPercent, 4.9, 32);
                    p.setCategoryId(catId);
                    p.setCategorySlug(categorySlugVal);
                    p.setOrigin(rs.getString("origin"));
                    p.setCertification(rs.getString("certification"));
                    p.setStorageTemp(rs.getString("storage_temp"));
                    p.setDefaultVariantId(rs.getLong("default_variant_id"));
                    p.setUnit(rs.getString("unit"));
                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock);
                    p.setInStock(totalStock > 0);

                    list.add(p);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public Product getProductById(int productId) {
        Product p = null;
        String sql = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.shop_id, p.origin, p.description, p.storage_temp, p.certification, "
                + "COALESCE(pi.image_url, 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop') AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, "
                + "(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 image_url FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC"
                + ") pi "
                + "WHERE p.product_id = ? AND p.is_active = 1";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setCategorySlug(rs.getString("category_slug"));
                    p.setShopId(rs.getLong("shop_id"));

                    p.setName(rs.getString("name"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                    }
                    p.setImage(img);

                    java.math.BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = new java.math.BigDecimal("750000"); 
                    }
                    p.setPrice(price);

                    String unit = rs.getString("unit");
                    p.setUnit(unit != null && !unit.trim().isEmpty() ? unit : "kg");

                    String origin = rs.getString("origin");
                    p.setOrigin(origin != null && !origin.trim().isEmpty() ? origin : "Đà Lạt, Lâm Đồng");

                    String desc = rs.getString("description");
                    p.setDescription(desc != null && !desc.trim().isEmpty() ? desc 
                            : "Sản phẩm tươi ngon được thu hoạch trực tiếp từ nông trại theo quy trình an toàn sinh học. Trái cây đạt độ chín tự nhiên, vị ngọt đậm đà, giòn thơm và giàu vitamin, khoáng chất có lợi cho sức khỏe.");

                    String storageTemp = rs.getString("storage_temp");
                    p.setStorageTemp(storageTemp != null && !storageTemp.trim().isEmpty() ? storageTemp : "2°C - 8°C");

                    String cert = rs.getString("certification");
                    p.setCertification(cert != null && !cert.trim().isEmpty() ? cert : "VietGAP & GlobalGAP");

                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock > 0 ? totalStock : 45);
                    p.setInStock(totalStock > 0);

                    List<ProductVariant> variants = getVariantsByProductId(productId);
                    p.setVariants(variants);

                    if (variants != null && !variants.isEmpty()) {
                        ProductVariant firstV = variants.get(0);
                        if (firstV.getOriginalPrice() != null && firstV.getOriginalPrice().compareTo(price) > 0) {
                            p.setOldPrice(firstV.getOriginalPrice());
                        } else {
                            p.setOldPrice(price.multiply(new java.math.BigDecimal("1.20")).setScale(-3, java.math.RoundingMode.HALF_UP));
                        }
                    } else {
                        p.setOldPrice(price.multiply(new java.math.BigDecimal("1.20")).setScale(-3, java.math.RoundingMode.HALF_UP));
                    }

                    if (p.getOldPrice() != null && p.getOldPrice().compareTo(p.getPrice()) > 0) {
                        double disc = (p.getOldPrice().doubleValue() - p.getPrice().doubleValue()) / p.getOldPrice().doubleValue() * 100.0;
                        p.setDiscountPercent((int) Math.round(disc));
                    } else {
                        p.setDiscountPercent(17);
                    }

                    p.setRating(4.9);
                    p.setReviewsCount(128);
                    p.setTag("-" + p.getDiscountPercent() + "% SALE");

                    List<String> imgs = getImagesByProductId(productId);
                    if (imgs == null) {
                        imgs = new ArrayList<>();
                    }
                    if (!imgs.contains(img)) {
                        imgs.add(0, img);
                    }
                    if (imgs.size() < 4) {
                        String[] complementaries = {
                            "https://images.unsplash.com/photo-1579613832125-5d34a13ffe0a?w=700&fit=crop", 
                            "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=700&fit=crop", 
                            "https://images.unsplash.com/photo-1519996529931-28324d5a630e?w=700&fit=crop"  
                        };
                        for (String comp : complementaries) {
                            if (imgs.size() < 4 && !imgs.contains(comp)) {
                                imgs.add(comp);
                            }
                        }
                    }
                    p.setImages(imgs);
                }
            }
        } catch (Exception e) {
            
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return p;
    }

    public List<ProductVariant> getVariantsByProductId(long productId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, "
                + "pv.weight_kg, pv.price, pv.original_price, pv.stock_quantity, pv.is_active, "
                + "p.name AS product_name, p.origin, p.description, p.certification, p.storage_temp, "
                + "c.category_name, pi.image_url "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY (SELECT TOP 1 image_url FROM product_images "
                + "WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC) pi "
                + "WHERE pv.product_id = ? AND pv.is_active = 1 "
                + "ORDER BY pv.price ASC, pv.variant_id ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getLong("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setProductName(rs.getString("product_name"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setOriginalPrice(rs.getBigDecimal("original_price") != null ? rs.getBigDecimal("original_price") : rs.getBigDecimal("price"));
                    v.setWeightKg(rs.getBigDecimal("weight_kg"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));
                    v.setImage(rs.getString("image_url"));
                    v.setOrigin(rs.getString("origin"));
                    v.setCategoryName(rs.getString("category_name"));
                    v.setCertification(rs.getString("certification"));
                    v.setIsActive(rs.getBoolean("is_active"));
                    v.setStorageTemp(rs.getString("storage_temp"));
                    v.setDescription(rs.getString("description"));

                    list.add(v);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<String> getImagesByProductId(long productId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT image_url FROM Product_images WHERE product_id = ? ORDER BY display_order ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String imgUrl = rs.getString("image_url");
                    if (imgUrl != null && !imgUrl.trim().isEmpty()) {
                        list.add(imgUrl);
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
                .append("p.origin, p.certification, p.storage_temp, pi.image_url, dv.variant_id AS default_variant_id, ")
                .append("(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, ")
                .append("(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, ")
                .append("(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock ")
                .append("FROM products p ")
                .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
                .append("OUTER APPLY ( ")
                .append("    SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC ")
                .append(") pi ")
                .append("OUTER APPLY ( ")
                .append("    SELECT TOP 1 variant_id FROM product_variants WHERE product_id = p.product_id AND is_active = 1 AND stock_quantity > 0 ORDER BY price ASC, variant_id ASC ")
                .append(") dv ")
                .append("WHERE p.is_active = 1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (categoryId != null && !categoryId.trim().isEmpty() && !categoryId.equals("0")) {
            try {
                int catId = Integer.parseInt(categoryId.trim());
                sql.append(" AND p.category_id = ? ");
                params.add(catId);
            } catch (NumberFormatException ignored) {
            }
        }

        if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
            try {
                BigDecimal minPrice = new BigDecimal(minPriceStr.trim());
                sql.append(" AND (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) >= ? ");
                params.add(minPrice);
            } catch (Exception ignored) {
            }
        }

        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try {
                BigDecimal maxPrice = new BigDecimal(maxPriceStr.trim());
                sql.append(" AND (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) <= ? ");
                params.add(maxPrice);
            } catch (Exception ignored) {
            }
        }

        sql.append(" ORDER BY p.product_id DESC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setName(rs.getString("name"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name") != null ? rs.getString("category_name") : "Trái Cây Tươi");

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                    }
                    p.setImage(img);

                    BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = new BigDecimal("100000");
                    }
                    p.setPrice(price);
                    p.setOldPrice(price.multiply(new BigDecimal("1.25")));
                    p.setDiscountPercent(20);
                    p.setRating(4.9);
                    p.setReviewsCount(15);

                    p.setOrigin(rs.getString("origin"));
                    p.setCertification(rs.getString("certification"));
                    p.setStorageTemp(rs.getString("storage_temp"));
                    p.setDefaultVariantId(rs.getLong("default_variant_id"));
                    p.setUnit(rs.getString("unit"));

                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock);
                    p.setInStock(totalStock > 0);

                    list.add(p);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public Map<String, Integer> getOriginsWithCount() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT p.origin, COUNT(DISTINCT p.product_id) AS cnt "
                + "FROM products p "
                + "WHERE p.is_active = 1 AND p.origin IS NOT NULL AND LTRIM(RTRIM(p.origin)) != '' "
                + "GROUP BY p.origin "
                + "ORDER BY cnt DESC, p.origin ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String origin = rs.getString("origin").trim();
                map.put(origin, rs.getInt("cnt"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return map;
    }

    public int countInStockProducts() {
        String sql = "SELECT COUNT(DISTINCT p.product_id) "
                + "FROM products p "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE p.is_active = 1 AND pv.is_active = 1 AND pv.stock_quantity > 0";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return 0;
    }

    public BigDecimal[] getMinMaxProductPrices() {
        BigDecimal[] minMax = new BigDecimal[]{new BigDecimal("10000"), new BigDecimal("500000")};
        String sql = "SELECT MIN(pv.price) AS min_p, MAX(pv.price) AS max_p "
                + "FROM products p "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE p.is_active = 1 AND pv.is_active = 1 AND pv.price > 0";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                BigDecimal minP = rs.getBigDecimal("min_p");
                BigDecimal maxP = rs.getBigDecimal("max_p");
                if (minP != null) minMax[0] = minP;
                if (maxP != null) minMax[1] = maxP;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return minMax;
    }

    public List<Product> getFilteredCatalogProducts(String keyword, List<String> categoryParams,
                                                    BigDecimal minPrice, BigDecimal maxPrice,
                                                    Double minRating, List<String> origins,
                                                    Boolean inStockOnly, String sortBy,
                                                    int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
           .append("p.origin, p.certification, p.storage_temp, pi.image_url, dv.variant_id AS default_variant_id, ")
           .append("dv.price AS price, dv.original_price AS original_price, dv.unit AS unit, ")
           .append("(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock ")
           .append("FROM products p ")
           .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
           .append("OUTER APPLY ( ")
           .append("    SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC ")
           .append(") pi ")
           .append("OUTER APPLY ( ")
           .append("    SELECT TOP 1 variant_id, price, original_price, unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY (CASE WHEN stock_quantity > 0 THEN 0 ELSE 1 END), price ASC, variant_id ASC ")
           .append(") dv ")
           .append("WHERE p.is_active = 1 ");

        List<Object> params = new ArrayList<>();
        appendCatalogFilters(sql, params, keyword, categoryParams, minPrice, maxPrice, origins, inStockOnly);

        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) ASC, p.product_id DESC");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) DESC, p.product_id DESC");
        } else if ("newest".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY p.product_id DESC");
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY p.is_featured DESC, p.product_id DESC");
        } else {
            
            sql.append(" ORDER BY p.is_featured DESC, p.product_id DESC");
        }

        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 12;
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapProductFromCatalogResultSet(rs);
                    list.add(p);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public int countFilteredCatalogProducts(String keyword, List<String> categoryParams,
                                            BigDecimal minPrice, BigDecimal maxPrice,
                                            Double minRating, List<String> origins,
                                            Boolean inStockOnly) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(DISTINCT p.product_id) ")
           .append("FROM products p ")
           .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
           .append("WHERE p.is_active = 1 ");

        List<Object> params = new ArrayList<>();
        appendCatalogFilters(sql, params, keyword, categoryParams, minPrice, maxPrice, origins, inStockOnly);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return 0;
    }

    private void appendCatalogFilters(StringBuilder sql, List<Object> params,
                                     String keyword, List<String> categoryParams,
                                     BigDecimal minPrice, BigDecimal maxPrice,
                                     List<String> origins, Boolean inStockOnly) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ? OR c.category_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (categoryParams != null && !categoryParams.isEmpty()) {
            List<Integer> catIds = new ArrayList<>();
            List<String> catSlugs = new ArrayList<>();
            for (String c : categoryParams) {
                if (c == null || c.trim().isEmpty() || "all".equalsIgnoreCase(c.trim()) || "0".equals(c.trim())) continue;
                try {
                    catIds.add(Integer.parseInt(c.trim()));
                } catch (NumberFormatException e) {
                    catSlugs.add(c.trim());
                }
            }
            if (!catIds.isEmpty() || !catSlugs.isEmpty()) {
                sql.append(" AND (");
                boolean first = true;
                if (!catIds.isEmpty()) {
                    sql.append("(p.category_id IN (");
                    for (int i = 0; i < catIds.size(); i++) {
                        sql.append(i == 0 ? "?" : ", ?");
                        params.add(catIds.get(i));
                    }
                    sql.append(") OR p.category_id IN (SELECT sub.category_id FROM categories sub WHERE sub.parent_id IN (");
                    for (int i = 0; i < catIds.size(); i++) {
                        sql.append(i == 0 ? "?" : ", ?");
                        params.add(catIds.get(i));
                    }
                    sql.append(")))");
                    first = false;
                }
                if (!catSlugs.isEmpty()) {
                    if (!first) sql.append(" OR ");
                    sql.append("(c.slug IN (");
                    for (int i = 0; i < catSlugs.size(); i++) {
                        sql.append(i == 0 ? "?" : ", ?");
                        params.add(catSlugs.get(i));
                    }
                    sql.append(") OR p.category_id IN (SELECT sub.category_id FROM categories sub JOIN categories pcat ON sub.parent_id = pcat.category_id WHERE pcat.slug IN (");
                    for (int i = 0; i < catSlugs.size(); i++) {
                        sql.append(i == 0 ? "?" : ", ?");
                        params.add(catSlugs.get(i));
                    }
                    sql.append(")))");
                }
                sql.append(") ");
            }
        }

        if (minPrice != null && minPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append(" AND (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) >= ? ");
            params.add(minPrice);
        }

        if (maxPrice != null && maxPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append(" AND (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) <= ? ");
            params.add(maxPrice);
        }

        if (origins != null && !origins.isEmpty()) {
            sql.append(" AND p.origin IN (");
            for (int i = 0; i < origins.size(); i++) {
                sql.append(i == 0 ? "?" : ", ?");
                params.add(origins.get(i).trim());
            }
            sql.append(") ");
        }

        if (inStockOnly != null && inStockOnly) {
            sql.append(" AND (SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) > 0 ");
        }
    }

    private Product mapProductFromCatalogResultSet(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getLong("product_id"));
        p.setName(rs.getString("name"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(rs.getString("category_name") != null ? rs.getString("category_name") : "Trái Cây Tươi");
        p.setCategorySlug(rs.getString("category_slug"));

        String img = rs.getString("image_url");
        if (img == null || img.trim().isEmpty()) {
            img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
        }
        p.setImage(img);

        BigDecimal price = rs.getBigDecimal("price");
        BigDecimal originalPrice = rs.getBigDecimal("original_price");
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            price = new BigDecimal("45000");
        }
        p.setPrice(price);

        if (originalPrice != null && originalPrice.compareTo(price) > 0) {
            p.setOldPrice(originalPrice);
            int disc = (int) Math.round((originalPrice.subtract(price).doubleValue() * 100.0) / originalPrice.doubleValue());
            p.setDiscountPercent(disc > 0 ? disc : 0);
            p.setTag("-" + disc + "%");
        } else {
            p.setOldPrice(price);
            p.setDiscountPercent(0);
            if (p.getCertification() != null && !p.getCertification().trim().isEmpty()) {
                p.setTag(p.getCertification().trim());
            } else {
                p.setTag("TƯƠI SẠCH");
            }
        }

        long pid = p.getId();
        double calcRating = 4.7 + ((pid % 4) * 0.1);
        if (calcRating > 5.0) calcRating = 5.0;
        p.setRating(calcRating);
        p.setReviewsCount((int) (28 + (pid * 19) % 150));

        p.setOrigin(rs.getString("origin"));
        p.setCertification(rs.getString("certification"));
        p.setStorageTemp(rs.getString("storage_temp"));
        p.setDefaultVariantId(rs.getLong("default_variant_id"));
        String unit = rs.getString("unit");
        p.setUnit(unit != null && !unit.trim().isEmpty() ? unit : "kg");

        int totalStock = rs.getInt("total_stock");
        p.setStockQuantity(totalStock);
        p.setInStock(totalStock > 0);

        return p;
    }
public List<Product> getProductsByShop(long shopId, Integer categoryId, String keyword, String sortBy) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
           .append("p.origin, p.certification, p.storage_temp, pi.image_url, dv.variant_id AS default_variant_id, ")
           .append("(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, ")
           .append("(SELECT MIN(original_price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS original_price, ")
           .append("(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, ")
           .append("(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock ")
           .append("FROM products p ")
           .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
           .append("OUTER APPLY (")
           .append("    SELECT TOP 1 image_url FROM product_images ")
           .append("    WHERE product_id = p.product_id ")
           .append("    ORDER BY is_thumbnail DESC, display_order ASC")
           .append(") pi ")
           .append("OUTER APPLY (")
           .append("    SELECT TOP 1 variant_id FROM product_variants ")
           .append("    WHERE product_id = p.product_id AND is_active = 1 AND stock_quantity > 0 ")
           .append("    ORDER BY price ASC")
           .append(") dv ")
           .append("WHERE p.is_active = 1 AND p.shop_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(shopId);

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ? ");
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ? OR c.category_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) ASC, p.product_id DESC");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) DESC, p.product_id DESC");
        } else if ("newest".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY p.product_id DESC");
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY p.is_featured DESC, p.product_id DESC");
        } else {
            sql.append(" ORDER BY p.is_featured DESC, p.product_id ASC");
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapProductFromCatalogResultSet(rs);
                    p.setShopId(shopId);
                    list.add(p);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Category> getCategoriesByShopId(long shopId) {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.category_name, c.slug, c.icon_class, COUNT(p.product_id) AS product_count "
                + "FROM categories c "
                + "JOIN products p ON c.category_id = p.category_id "
                + "WHERE p.shop_id = ? AND p.is_active = 1 "
                + "GROUP BY c.category_id, c.category_name, c.slug, c.icon_class "
                + "ORDER BY product_count DESC, c.category_name ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category cat = new Category();
                    cat.setCategoryId(rs.getInt("category_id"));
                    cat.setCategoryName(rs.getString("category_name"));
                    cat.setSlug(rs.getString("slug"));
                    cat.setIconClass(rs.getString("icon_class"));
                    cat.setProductCount(rs.getInt("product_count"));
                    list.add(cat);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Product> getProductSummariesByShopId(long shopId) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.origin, p.certification, "
                + "(SELECT TOP 1 p2.storage_temp FROM products p2 WHERE p2.product_id = p.product_id) AS storage_temp, "
                + "(SELECT TOP 1 p2.description FROM products p2 WHERE p2.product_id = p.product_id) AS description, "
                + "c.category_name, "
                + "COALESCE(pi.image_url, 'https://images.unsplash.com/photo-1543528176-61b239494933?w=800') AS image_url, "
                + "COALESCE(MIN(pv.variant_id), 0) AS primary_variant_id, "
                + "COALESCE(MIN(pv.price), 0) AS min_price, COALESCE(MAX(pv.price), 0) AS max_price, "
                + "COALESCE(SUM(pv.stock_quantity), 0) AS total_stock, "
                + "(SELECT COUNT(*) FROM product_variants WHERE product_id = p.product_id) AS variant_count, "
                + "CASE WHEN p.is_active = 1 AND EXISTS (SELECT 1 FROM product_variants av WHERE av.product_id = p.product_id AND av.is_active = 1 AND av.stock_quantity > 0) THEN 1 ELSE 0 END AS active_for_sale "
                + "FROM products p "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN (SELECT product_id, MAX(image_url) AS image_url FROM product_images WHERE is_thumbnail = 1 GROUP BY product_id) pi ON p.product_id = pi.product_id "
                + "WHERE p.shop_id = ? "
                + "GROUP BY p.product_id, p.name, p.origin, p.certification, c.category_name, p.is_active, pi.image_url "
                + "ORDER BY p.product_id DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setOrigin(rs.getString("origin"));
                    product.setCertification(rs.getString("certification"));
                    product.setStorageTemp(rs.getString("storage_temp"));
                    product.setDescription(rs.getString("description"));
                    product.setCategoryName(rs.getString("category_name"));
                    product.setImage(rs.getString("image_url"));
                    product.setPrimaryVariantId(rs.getLong("primary_variant_id"));
                    product.setPrice(rs.getBigDecimal("min_price"));
                    product.setOldPrice(rs.getBigDecimal("max_price"));
                    product.setStockQuantity(rs.getInt("total_stock"));
                    product.setVariantCount(rs.getInt("variant_count"));
                    product.setActiveForSale(rs.getBoolean("active_for_sale"));
                    products.add(product);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return products;
    }

    public boolean softDeleteProductAndVariants(long productId, long shopId) {
        
        String updateProductSql = "UPDATE products SET is_active = 0, updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ? AND shop_id = ?";

        String updateVariantsSql = "UPDATE product_variants SET is_active = 0, updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try {
                
                try (PreparedStatement psProd = conn.prepareStatement(updateProductSql)) {
                    psProd.setLong(1, productId);
                    psProd.setLong(2, shopId);
                    int affectedRows = psProd.executeUpdate();
                    if (affectedRows == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                try (PreparedStatement psVar = conn.prepareStatement(updateVariantsSql)) {
                    psVar.setLong(1, productId);
                    psVar.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public int countProductsByStatusTab(long shopId, String statusTab) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT p.product_id) FROM products p WHERE p.shop_id = ?");

        if (statusTab != null && !statusTab.trim().isEmpty() && !statusTab.equalsIgnoreCase("all")) {
            if ("active".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 1 AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND pv.is_active = 1 AND pv.stock_quantity > 0)");
            } else if ("vietgap".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%')");
            } else if ("hidden".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (p.is_active = 0 OR NOT EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND pv.is_active = 1 AND pv.stock_quantity > 0))");
            } else if ("warning".equalsIgnoreCase(statusTab)) {
                sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND pv.is_active = 1 AND pv.stock_quantity <= 5)");
            }
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return 0;
    }

    public ProductVariant getShopVariantById(long variantId, long shopId) {
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, pv.price, pv.original_price, "
                + "pv.stock_quantity, pv.low_stock_threshold, pv.is_active, p.name AS product_name, p.origin, "
                + "p.storage_temp, p.certification, p.description, c.category_name, "
                + "COALESCE(pi.image_url, 'https://images.unsplash.com/photo-1543528176-61b239494933?w=800') AS image_url "
                + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE pv.variant_id = ? AND p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement statement = conn.prepareStatement(sql)) {
            statement.setLong(1, variantId);
            statement.setLong(2, shopId);
            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ProductVariant variant = new ProductVariant();
                variant.setVariantId(rs.getLong("variant_id"));
                variant.setProductId(rs.getLong("product_id"));
                variant.setSku(rs.getString("sku"));
                variant.setVariantName(rs.getString("variant_name"));
                variant.setUnit(rs.getString("unit"));
                variant.setPrice(rs.getBigDecimal("price"));
                variant.setOriginalPrice(rs.getBigDecimal("original_price"));
                variant.setStockQuantity(rs.getInt("stock_quantity"));
                variant.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                variant.setIsActive(rs.getBoolean("is_active"));
                variant.setProductName(rs.getString("product_name"));
                variant.setOrigin(rs.getString("origin"));
                variant.setStorageTemp(rs.getString("storage_temp"));
                variant.setCertification(rs.getString("certification"));
                variant.setDescription(rs.getString("description"));
                variant.setCategoryName(rs.getString("category_name"));
                variant.setImage(rs.getString("image_url"));
                return variant;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
            return null;
        }
    }

    public boolean isSkuUsedByAnotherVariant(String sku, long variantId) {
        String sql = "SELECT 1 FROM product_variants WHERE sku = ? AND variant_id <> ?";
        try (Connection conn = getConnection(); PreparedStatement statement = conn.prepareStatement(sql)) {
            statement.setString(1, sku);
            statement.setLong(2, variantId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
            return false;
        }
    }

    public List<Product> getHomeFeaturedTabs() {
        List<Product> list = new ArrayList<>();
        
        String query = "SELECT p.product_id, p.name, p.origin, c.category_name, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT MIN(original_price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS original_price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.is_active = 1 "
                + "ORDER BY p.product_id DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                long id = rs.getLong("product_id");
                String name = rs.getString("name");
                String origin = rs.getString("origin");
                String categoryName = rs.getString("category_name");
                String image = rs.getString("image_url");
                if (image == null || image.isEmpty()) {
                    image = "https://images.unsplash.com/photo-1610832958506-aa56368176cf"; 
                }

                BigDecimal price = rs.getBigDecimal("price");
                if (price == null) {
                    price = BigDecimal.ZERO;
                }

                BigDecimal oldPrice = rs.getBigDecimal("original_price");
                if (oldPrice == null) {
                    oldPrice = price;
                }

                int discountPercent = 0;

                Product product = new Product(id, name, categoryName, image, price, oldPrice, discountPercent, 0.0, 0);
                product.setOrigin(origin); 

                list.add(product);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<ProductVariant> getShopVariantsByProductId(long shopId, long productId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, pv.price, "
                + "pv.original_price, pv.stock_quantity, pv.is_active, p.name AS product_name "
                + "FROM product_variants pv JOIN products p ON p.product_id = pv.product_id "
                + "WHERE p.shop_id = ? AND p.product_id = ? ORDER BY pv.variant_id";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            ps.setLong(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant variant = new ProductVariant();
                    variant.setVariantId(rs.getLong("variant_id"));
                    variant.setProductId(rs.getLong("product_id"));
                    variant.setSku(rs.getString("sku"));
                    variant.setVariantName(rs.getString("variant_name"));
                    variant.setUnit(rs.getString("unit"));
                    variant.setPrice(rs.getBigDecimal("price"));
                    variant.setOriginalPrice(rs.getBigDecimal("original_price"));
                    variant.setStockQuantity(rs.getInt("stock_quantity"));
                    variant.setIsActive(rs.getBoolean("is_active"));
                    variant.setProductName(rs.getString("product_name"));
                    list.add(variant);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }

    public List<Product> getShopFilteredProducts(long shopId, String keyword, Long categoryId,
            String certification, String stockLevel) {
        List<Product> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.shop_id, p.name, p.category_id, c.category_name, "
                + "p.origin, p.certification, p.description, p.storage_temp, product_image.image_url, "
                + "cheapest.variant_id AS primary_variant_id, cheapest.price, "
                + "cheapest.original_price, cheapest.unit, "
                + "COALESCE(stock.total_stock, 0) AS total_stock, "
                + "COALESCE(stock.variant_count, 0) AS variant_count "
                + "FROM products p "
                + "LEFT JOIN categories c ON c.category_id = p.category_id "
                + "OUTER APPLY (SELECT TOP 1 pi.image_url FROM product_images pi "
                + "WHERE pi.product_id = p.product_id "
                + "ORDER BY pi.is_thumbnail DESC, pi.display_order ASC, pi.image_id ASC) product_image "
                + "OUTER APPLY (SELECT TOP 1 pv.variant_id, pv.price, pv.original_price, pv.unit "
                + "FROM product_variants pv WHERE pv.product_id = p.product_id AND pv.is_active = 1 "
                + "ORDER BY pv.price ASC, pv.variant_id ASC) cheapest "
                + "OUTER APPLY (SELECT SUM(CASE WHEN pv.is_active = 1 THEN pv.stock_quantity ELSE 0 END) AS total_stock, "
                + "COUNT(*) AS variant_count FROM product_variants pv WHERE pv.product_id = p.product_id) stock "
                + "WHERE p.shop_id = ? AND p.is_active = 1");

        List<Object> parameters = new ArrayList<>();
        parameters.add(shopId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchTerm = "%" + keyword.trim() + "%";
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ? OR EXISTS ("
                    + "SELECT 1 FROM product_variants pv "
                    + "WHERE pv.product_id = p.product_id AND pv.is_active = 1 AND pv.sku LIKE ?))");
            parameters.add(searchTerm);
            parameters.add(searchTerm);
            parameters.add(searchTerm);
        }

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            parameters.add(categoryId);
        }

        if (certification != null && !certification.trim().isEmpty()) {
            sql.append(" AND p.certification = ?");
            parameters.add(certification.trim());
        }

        if (stockLevel != null) {
            switch (stockLevel.trim().toLowerCase()) {
                case "critical":
                    sql.append(" AND COALESCE(stock.total_stock, 0) < 5");
                    break;
                case "low":
                    sql.append(" AND COALESCE(stock.total_stock, 0) BETWEEN 5 AND 15");
                    break;
                case "stable":
                    sql.append(" AND COALESCE(stock.total_stock, 0) BETWEEN 16 AND 40");
                    break;
                case "abundant":
                    sql.append(" AND COALESCE(stock.total_stock, 0) > 40");
                    break;
                default:
                    break;
            }
        }

        sql.append(" ORDER BY p.created_at DESC, p.product_id DESC");

        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                statement.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setId(rs.getLong("product_id"));
                    product.setShopId(rs.getLong("shop_id"));
                    product.setName(rs.getString("name"));
                    product.setCategoryId(rs.getInt("category_id"));
                    product.setCategoryName(rs.getString("category_name"));
                    product.setOrigin(rs.getString("origin"));
                    product.setCertification(rs.getString("certification"));
                    product.setDescription(rs.getString("description"));
                    product.setStorageTemp(rs.getString("storage_temp"));

                    String image = rs.getString("image_url");
                    if (image == null || image.trim().isEmpty()) {
                        image = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                    }
                    product.setImage(image);

                    product.setPrimaryVariantId(rs.getLong("primary_variant_id"));
                    BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = BigDecimal.ZERO;
                    }
                    product.setPrice(price);

                    BigDecimal originalPrice = rs.getBigDecimal("original_price");
                    if (originalPrice == null || originalPrice.compareTo(price) < 0) {
                        originalPrice = price;
                    }
                    product.setOldPrice(originalPrice);
                    if (originalPrice.compareTo(price) > 0) {
                        product.setDiscountPercent(originalPrice.subtract(price)
                                .multiply(new BigDecimal("100"))
                                .divide(originalPrice, 0, java.math.RoundingMode.HALF_UP)
                                .intValue());
                    }

                    product.setUnit(rs.getString("unit"));
                    product.setVariantCount(rs.getInt("variant_count"));
                    int totalStock = rs.getInt("total_stock");
                    product.setStockQuantity(totalStock);
                    product.setInStock(totalStock > 0);
                    product.setActiveForSale(totalStock > 0);
                    products.add(product);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return products;
    }

    public long addVariantToProduct(long shopId, long productId, String sku, String variantName, String unit,
            BigDecimal price, BigDecimal originalPrice, int stockQuantity, int lowStockThreshold, boolean isActive) {
        String sql = "INSERT INTO product_variants (product_id, sku, variant_name, unit, price, original_price, stock_quantity, low_stock_threshold, is_active, created_at, updated_at) "
                + "SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP "
                + "FROM products WHERE product_id = ? AND shop_id = ?";
        String finalSku = (sku == null || sku.trim().isEmpty()) ? "SKU-" + (System.currentTimeMillis() % 1000000) : sku.trim();
        int skuRetry = 1;
        while (isSkuExists(finalSku)) {
            finalSku = "SKU-" + (System.currentTimeMillis() % 1000000) + "-" + (skuRetry++);
        }

        try (Connection conn = getConnection(); PreparedStatement statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setLong(1, productId);
            statement.setString(2, finalSku);
            statement.setString(3, variantName.trim());
            statement.setString(4, unit.trim());
            statement.setBigDecimal(5, price);
            statement.setBigDecimal(6, originalPrice != null ? originalPrice : price);
            statement.setInt(7, stockQuantity);
            statement.setInt(8, lowStockThreshold);
            statement.setBoolean(9, isActive);
            statement.setLong(10, productId);
            statement.setLong(11, shopId);
            if (statement.executeUpdate() == 0) {
                return -1;
            }
            try (ResultSet keys = statement.getGeneratedKeys()) {
                return keys.next() ? keys.getLong(1) : -1;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
            return -1;
        }
    }

    public boolean updateVariantDetails(long shopId, long variantId, String sku, String variantName,
            String unit, BigDecimal price, BigDecimal originalPrice, int stockQuantity,
            int lowStockThreshold, boolean isActive) {
        String sql = "UPDATE pv SET pv.sku = ?, pv.variant_name = ?, pv.unit = ?, pv.price = ?, "
                + "pv.original_price = ?, pv.stock_quantity = ?, pv.low_stock_threshold = ?, pv.is_active = ?, "
                + "pv.updated_at = CURRENT_TIMESTAMP FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id WHERE pv.variant_id = ? AND p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement statement = conn.prepareStatement(sql)) {
            statement.setString(1, sku == null || sku.trim().isEmpty() ? "SKU-" + variantId : sku.trim());
            statement.setString(2, variantName.trim());
            statement.setString(3, unit.trim());
            statement.setBigDecimal(4, price);
            statement.setBigDecimal(5, originalPrice != null ? originalPrice : price);
            statement.setInt(6, stockQuantity);
            statement.setInt(7, lowStockThreshold);
            statement.setBoolean(8, isActive);
            statement.setLong(9, variantId);
            statement.setLong(10, shopId);
            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
            return false;
        }
    }

    public boolean updateFullProduct(long shopId, long variantId, String name, int categoryId, String origin,
            String storageTemp, String certification, String description,
            String sku, String variantName, String unit, BigDecimal price,
            BigDecimal originalPrice, int stockQuantity, boolean isActive,
            String coverImageUrl) {

        String sqlGetProductId = "SELECT pv.product_id FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ? AND p.shop_id = ?";

        String sqlUpdateProduct = "UPDATE products SET name = ?, category_id = ?, origin = ?, storage_temp = ?, certification = ?, description = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        String sqlCheckImage = "SELECT image_id FROM product_images WHERE product_id = ? AND is_thumbnail = 1";
        String sqlUpdateImage = "UPDATE product_images SET image_url = ? WHERE product_id = ? AND is_thumbnail = 1";
        String sqlInsertImage = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) VALUES (?, ?, 1, 1, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            long productId = -1;

            try (PreparedStatement ps = conn.prepareStatement(sqlGetProductId)) {
                ps.setLong(1, variantId);
                ps.setLong(2, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        productId = rs.getLong("product_id");
                    }
                }
            }

            if (productId == -1) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateProduct)) {
                ps.setString(1, name);
                if (categoryId > 0) {
                    ps.setInt(2, categoryId);
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }
                ps.setString(3, origin != null ? origin.trim() : "");
                ps.setString(4, storageTemp != null ? storageTemp.trim() : "");
                ps.setString(5, certification != null ? certification.trim() : "");
                ps.setString(6, description != null ? description : "");
                ps.setBoolean(7, isActive);
                ps.setLong(8, productId);
                ps.executeUpdate();
            }

            if (coverImageUrl != null && !coverImageUrl.trim().isEmpty()) {
                boolean hasThumbnail = false;
                try (PreparedStatement ps = conn.prepareStatement(sqlCheckImage)) {
                    ps.setLong(1, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            hasThumbnail = true;
                        }
                    }
                }

                if (hasThumbnail) {
                    try (PreparedStatement ps = conn.prepareStatement(sqlUpdateImage)) {
                        ps.setString(1, coverImageUrl.trim());
                        ps.setLong(2, productId);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsertImage)) {
                        ps.setLong(1, productId);
                        ps.setString(2, coverImageUrl.trim());
                        ps.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return false;
    }

    public List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin) {
        return searchAndFilterProducts(keyword, categoryId, minPriceStr, maxPriceStr, ratingStr, availability, origin, "default");
    }

    public List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin, String sortBy) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
                .append("p.origin, p.certification, pi.image_url, ")
                
                .append("(SELECT TOP 1 price FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY price ASC) AS price, ")
                .append("(SELECT TOP 1 original_price FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY price ASC) AS original_price, ")
                .append("(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, ")
                .append("(SELECT COALESCE(SUM(stock_quantity), 0) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock, ")
                .append("(SELECT AVG(CAST(r.rating AS DECIMAL(5,2))) FROM reviews r ")
                .append("JOIN order_items oi ON oi.order_item_id = r.order_item_id ")
                .append("JOIN product_variants rv ON rv.variant_id = oi.variant_id ")
                .append("WHERE rv.product_id = p.product_id AND r.status = 'APPROVED') AS avg_rating, ")
                .append("(SELECT COUNT(*) FROM reviews r ")
                .append("JOIN order_items oi ON oi.order_item_id = r.order_item_id ")
                .append("JOIN product_variants rv ON rv.variant_id = oi.variant_id ")
                .append("WHERE rv.product_id = p.product_id AND r.status = 'APPROVED') AS reviews_count, ")
                .append("(SELECT COALESCE(SUM(oi.quantity), 0) FROM order_items oi ")
                .append("JOIN product_variants soldv ON soldv.variant_id = oi.variant_id ")
                .append("WHERE soldv.product_id = p.product_id) AS popularity_count ")
                .append("FROM products p ")
                .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
                .append("OUTER APPLY ( ")
                .append("    SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC ")
                .append(") pi ")
                .append("WHERE p.is_active = 1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (categoryId != null && !categoryId.trim().isEmpty() && !categoryId.equals("0")) {
            try {
                int catId = Integer.parseInt(categoryId.trim());
                sql.append(" AND p.category_id = ? ");
                params.add(catId);
            } catch (NumberFormatException ignored) {
                sql.append(" AND c.slug = ? ");
                params.add(categoryId.trim());
            }
        }

        if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
            try {
                BigDecimal minPrice = new BigDecimal(minPriceStr.trim());
                sql.append(" AND (SELECT TOP 1 price FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY price ASC) >= ? ");
                params.add(minPrice);
            } catch (Exception ignored) {
            }
        }

        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try {
                BigDecimal maxPrice = new BigDecimal(maxPriceStr.trim());
                sql.append(" AND (SELECT TOP 1 price FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY price ASC) <= ? ");
                params.add(maxPrice);
            } catch (Exception ignored) {
            }
        }

        if (ratingStr != null && !ratingStr.trim().isEmpty()) {
            try {
                BigDecimal minRating = new BigDecimal(ratingStr.trim());
                sql.append(" AND (SELECT AVG(CAST(r.rating AS DECIMAL(5,2))) FROM reviews r ")
                        .append("JOIN order_items oi ON oi.order_item_id = r.order_item_id ")
                        .append("JOIN product_variants rv ON rv.variant_id = oi.variant_id ")
                        .append("WHERE rv.product_id = p.product_id AND r.status = 'APPROVED') >= ? ");
                params.add(minRating);
            } catch (NumberFormatException ignored) {
            }
        }

        if (availability != null && availability.equals("in_stock")) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants av WHERE av.product_id = p.product_id AND av.is_active = 1 AND av.stock_quantity > 0) ");
        } else if (availability != null && availability.equals("out_of_stock")) {
            sql.append(" AND NOT EXISTS (SELECT 1 FROM product_variants av WHERE av.product_id = p.product_id AND av.is_active = 1 AND av.stock_quantity > 0) ");
        }

        if (origin != null && !origin.trim().isEmpty()) {
            sql.append(" AND p.origin LIKE ? ");
            params.add("%" + origin.trim() + "%");
        }

        String orderBy;
        if ("newest".equals(sortBy)) {
            orderBy = "p.created_at DESC, p.product_id DESC";
        } else if ("popular".equals(sortBy)) {
            orderBy = "popularity_count DESC, p.product_id DESC";
        } else if ("price_asc".equals(sortBy)) {
            orderBy = "price ASC, p.product_id DESC";
        } else if ("price_desc".equals(sortBy)) {
            orderBy = "price DESC, p.product_id DESC";
        } else if ("rating_desc".equals(sortBy)) {
            orderBy = "avg_rating DESC, reviews_count DESC, p.product_id DESC";
        } else {
            orderBy = "p.is_featured DESC, p.product_id DESC";
        }
        sql.append(" ORDER BY ").append(orderBy);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setName(rs.getString("name"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                    }
                    p.setImage(img);

                    BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = BigDecimal.ZERO;
                    }
                    p.setPrice(price);

                    BigDecimal oldPrice = rs.getBigDecimal("original_price");
                    if (oldPrice == null || oldPrice.compareTo(price) < 0) {
                        oldPrice = price; 
                    }
                    p.setOldPrice(oldPrice);

                    int discountPercent = 0;
                    if (oldPrice.compareTo(price) > 0) {
                        BigDecimal discountAmount = oldPrice.subtract(price);
                        discountPercent = discountAmount.multiply(new BigDecimal("100"))
                                .divide(oldPrice, 0, java.math.RoundingMode.HALF_UP)
                                .intValue();
                    }
                    p.setDiscountPercent(discountPercent);

                    p.setRating(rs.getDouble("avg_rating"));
                    p.setReviewsCount(rs.getInt("reviews_count"));

                    p.setOrigin(rs.getString("origin"));
                    p.setCertification(rs.getString("certification"));
                    p.setUnit(rs.getString("unit"));

                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock);
                    p.setInStock(totalStock > 0);

                    list.add(p);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Database error in ProductDAO", e);
        }
        return list;
    }
}
