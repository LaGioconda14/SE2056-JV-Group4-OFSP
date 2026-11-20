package dao.product;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import model.dto.product.ProductCardDTO;
import model.dto.product.ProductDetailDTO;
import model.dto.product.ProductVariantDetailDTO;
import model.dto.product.ProductVariantStockDTO;
import model.entity.product.ProductVariant;
import model.entity.product.Category;
import model.entity.review.Review;
import model.dto.review.ReviewSummary;
import java.util.logging.Level;
import java.util.logging.Logger;
import service.IProductService;
import service.impl.ProductServiceImpl;
import util.DBContext;

public class ProductDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    public static final String DEFAULT_PRODUCT_IMAGE = "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=800&fit=crop";

    public static String getDefaultFruitImage(String productName) {
        return DEFAULT_PRODUCT_IMAGE;
    }

    public double[] getProductRatingStats(long productId) {
        ReviewSummary summary = new ReviewDAO().getReviewSummary(productId);
        return new double[]{summary.getAverageRating(), summary.getTotalReviews()};
    }

    public List<Review> getReviewsByProductId(long productId) {
        return new ReviewDAO().getReviewsByProduct(productId, 1, 50);
    }

    public List<ProductVariantStockDTO> getVariantsByShopId(long shopId) {
        List<ProductVariantStockDTO> list = new ArrayList<>();
        String sql = "SELECT "
                + "    COALESCE(pv.variant_id, 0) AS variant_id, "
                + "    p.product_id, "
                + "    COALESCE(pv.sku, 'CHUA-CO-SKU') AS sku, "
                + "    COALESCE(pv.variant_name, N'Chưa phân loại') AS variant_name, "
                + "    COALESCE(pv.price, 0) AS price, "
                + "    COALESCE(pv.original_price, 0) AS original_price, "
                + "    COALESCE(pv.stock_quantity, 0) AS stock_quantity, "
                + "    COALESCE(pv.low_stock_threshold, 10) AS low_stock_threshold, "
                + "    COALESCE(pv.unit, 'kg') AS unit, "
                + "    pi.image_url AS image_url, "
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
                    ProductVariantStockDTO v = new ProductVariantStockDTO();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setOriginalPrice(rs.getBigDecimal("original_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                    v.setUnit(rs.getString("unit"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = getDefaultFruitImage(rs.getString("product_name"));
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
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return 0;
    }

    public ProductVariantDetailDTO getVariantDetailForEdit(long variantId, long shopId) {
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, "
                + "       pv.price, pv.original_price, pv.stock_quantity, pv.low_stock_threshold, pv.is_active, "
                + "       p.name AS product_name, p.category_id, p.origin, p.storage_temp, p.certification, p.description, "
                + "       c.category_name, "
                + "       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC) AS cover_image "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE pv.variant_id = ? AND p.shop_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            ps.setLong(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductVariantDetailDTO v = new ProductVariantDetailDTO();
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
                        cover = getDefaultFruitImage(v.getProductName());
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
            e.printStackTrace();
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
            } catch (Exception ignored) {
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
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
            e.printStackTrace();
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
        String sqlBatch = "INSERT INTO product_batches (batch_code, variant_id, harvest_date, expiry_date, initial_quantity, current_quantity, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE')";

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
                    if (rs.next()) {
                        productId = rs.getLong(1);
                    }
                }
            }

            if (productId == -1) {
                conn.rollback();
                return false;
            }

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
                    if (rs.next()) {
                        variantId = rs.getLong(1);
                    }
                }
            }

            if (variantId == -1) {
                conn.rollback();
                return false;
            }

            if (batchCode != null && !batchCode.trim().isEmpty() && harvestDate != null && expiryDate != null) {
                try (PreparedStatement ps = conn.prepareStatement(sqlBatch)) {
                    ps.setString(1, batchCode);
                    ps.setLong(2, variantId);
                    ps.setDate(3, harvestDate);
                    ps.setDate(4, expiryDate);
                    ps.setInt(5, stockQuantity);
                    ps.setInt(6, stockQuantity);
                    ps.executeUpdate();
                } catch (Exception ignored) {

                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return false;
    }

    public List<ProductVariantStockDTO> getFilteredVariantsByShop(long shopId, String keyword, String categoryId, String certification, String stockLevel, String statusTab, int page, int pageSize) {
        List<ProductVariantStockDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("    pv.variant_id, ")
                .append("    pv.product_id, ")
                .append("    pv.sku, ")
                .append("    pv.variant_name, ")
                .append("    pv.price, ")
                .append("    pv.original_price, ")
                .append("    pv.stock_quantity, ")
                .append("    COALESCE(pv.low_stock_threshold, 10) AS low_stock_threshold, ")
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
                    ProductVariantStockDTO v = new ProductVariantStockDTO();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setOriginalPrice(rs.getBigDecimal("original_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setLowStockThreshold(rs.getInt("low_stock_threshold"));
                    v.setUnit(rs.getString("unit"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = getDefaultFruitImage(rs.getString("product_name"));
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
            e.printStackTrace();
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

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return list;
    }

    public List<Category> getAllCategories() {
        return new CategoryDAO().getAllCategoriesWithCount();
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
            e.printStackTrace();
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
        String sqlBatch = "INSERT INTO product_batches (batch_code, variant_id, harvest_date, expiry_date, initial_quantity, current_quantity, status, created_at, updated_at) "
                + "VALUES (?, ?, CURRENT_TIMESTAMP, DATEADD(day, 7, CURRENT_TIMESTAMP), ?, ?, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

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
                ps.setInt(3, stockQuantity);
                ps.setInt(4, stockQuantity);
                ps.executeUpdate();
            } catch (Exception batchEx) {
                batchEx.printStackTrace();
            }

            conn.commit();
            return productId;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    private static String generateProductSlug(String input) {
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

    public ProductVariantDetailDTO getVariantById(long variantId) {
        ProductVariantDetailDTO pv = null;
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, "
                + "pv.price, pv.original_price, pv.stock_quantity, pv.is_active, "
                + "p.name AS product_name, p.category_id, p.origin, p.storage_temp, "
                + "p.certification, p.description, "
                + "pi.image_url AS image_url "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE pv.variant_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    pv = new ProductVariantDetailDTO();

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
                    String vImg = rs.getString("image_url");
                    if (vImg == null || vImg.trim().isEmpty()) {
                        vImg = getDefaultFruitImage(pv.getProductName());
                    }
                    pv.setImage(vImg);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return pv;
    }

    public List<Category> getHierarchyCategories() {
        List<Category> list = new ArrayList<>();
        String queryParents = "SELECT category_id, category_name, slug, description, icon_class "
                + "FROM categories WHERE parent_id IS NULL AND is_active = 1 "
                + "ORDER BY category_id ASC";
        String querySubs = "SELECT category_id, parent_id, category_name, slug, description, icon_class "
                + "FROM categories WHERE parent_id IS NOT NULL AND is_active = 1 "
                + "ORDER BY category_id ASC";

        try (Connection conn = getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(queryParents); ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Category c = new Category();
                        c.setCategoryId(rs.getInt("category_id"));
                        c.setCategoryName(rs.getString("category_name"));
                        c.setSlug(rs.getString("slug"));
                        c.setDescription(rs.getString("description"));
                        c.setIconClass(rs.getString("icon_class"));
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
                        sub.setIconClass(rs.getString("icon_class"));
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
            e.printStackTrace();
        }
        return list;
    }

    public List<ProductCardDTO> getHomeProducts() {

        List<ProductCardDTO> list = new ArrayList<>();

        String query = "SELECT "
                + "    p.product_id, p.name, p.category_id, "
                + "    COALESCE(c.category_name, N'Trái Cây Tươi') AS category_name, "
                + "    c.slug AS category_slug, "
                + "    p.origin, p.certification, p.storage_temp, "
                + "    pi.image_url, "
                + "    dv.variant_id AS default_variant_id, "
                + "    COALESCE(v_stat.min_price, 100000) AS price, "
                + "    v_stat.unit, "
            + "    COALESCE(v_stat.total_stock, 0) AS total_stock "
            + "FROM products p "
            + "INNER JOIN shops s ON s.shop_id = p.shop_id AND s.status = 'ACTIVE' "
            + "LEFT JOIN categories c ON p.category_id = c.category_id "

                + "LEFT JOIN ( "
                + "    SELECT product_id, "
                + "           MIN(price) AS min_price, "
                + "           MAX(unit) AS unit, "
                + "           SUM(stock_quantity) AS total_stock "
                + "    FROM product_variants "
                + "    WHERE is_active = 1 "
                + "    GROUP BY product_id "
                + ") v_stat ON v_stat.product_id = p.product_id "

                + "OUTER APPLY ( "
                + "    SELECT TOP 1 image_url "
                + "    FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC "
                + ") pi "

                + "OUTER APPLY ( "
                + "    SELECT TOP 1 variant_id "
                + "    FROM product_variants "
                + "    WHERE product_id = p.product_id AND is_active = 1 AND stock_quantity > 0 "
                + "    ORDER BY price ASC, variant_id ASC "
                + ") dv "
                + "WHERE p.is_active = 1 AND COALESCE(v_stat.total_stock, 0) > 0 "
                + "ORDER BY p.is_featured DESC, p.product_id DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                long id = rs.getLong("product_id");

                String name = rs.getString("name");

                String categoryName = rs.getString("category_name");

                String categorySlug = rs.getString("category_slug");

                String image = rs.getString("image_url");

                if (image == null || image.trim().isEmpty()) {

                    image = getDefaultFruitImage(name);

                }

                BigDecimal price = rs.getBigDecimal("price");

                int totalStock = rs.getInt("total_stock");

                ProductCardDTO p = new ProductCardDTO(id, name, categoryName, image, price, price, 0, 5.0, 0);

                p.setCategoryId(rs.getInt("category_id"));

                p.setCategorySlug(categorySlug);

                p.setOrigin(rs.getString("origin"));

                p.setCertification(rs.getString("certification"));

                p.setStorageTemp(rs.getString("storage_temp"));

                p.setDefaultVariantId(rs.getLong("default_variant_id"));

                p.setUnit(rs.getString("unit"));

                p.setStockQuantity(totalStock);

                p.setInStock(totalStock > 0);

                list.add(p);

            }

        } catch (Exception e) {

            LOGGER.log(Level.SEVERE, "Lỗi khi lấy sản phẩm trang chủ", e);

        }

        if (!list.isEmpty()) {

            util.PromotionPricing.applyToProducts(list);

        }

        return list;

    }

    public List<ProductCardDTO> getProductsByCategorySlug(String categorySlug) {
        List<ProductCardDTO> list = new ArrayList<>();
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
                        image = getDefaultFruitImage(name);
                    }

                    BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = new BigDecimal("100000");
                    }

                    ProductCardDTO p = new ProductCardDTO(id, name, categoryName, image, price, price, 0, 4.9, 32);
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
            e.printStackTrace();
        }
        util.PromotionPricing.applyToProducts(list); 
        return list;
    }

    public ProductDetailDTO getProductById(int productId) {
        ProductDetailDTO p = null;
        String sql = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.shop_id, p.origin, p.description, p.storage_temp, p.certification, "
                + "COALESCE(pi.image_url, 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop') AS image_url, "
                + "COALESCE(dv.price, 750000) AS price, "
                + "COALESCE(dv.unit, 'kg') AS unit, "
                + "(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 image_url FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC"
                + ") pi "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 price, unit FROM product_variants "
                + "    WHERE product_id = p.product_id AND is_active = 1 "
                + "    ORDER BY price ASC, variant_id ASC"
                + ") dv "
                + "WHERE p.product_id = ? AND p.is_active = 1";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new ProductDetailDTO();
                    p.setId(rs.getLong("product_id"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setCategorySlug(rs.getString("category_slug"));
                    p.setShopId(rs.getLong("shop_id"));

                    p.setName(rs.getString("name"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = getDefaultFruitImage(p.getName());
                    }
                    p.setImage(img);

                    java.math.BigDecimal price = rs.getBigDecimal("price");
                    p.setPrice(price != null ? price : new java.math.BigDecimal("750000"));
                    p.setUnit(rs.getString("unit"));

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

                    List<ProductVariantDetailDTO> variants = getVariantsByProductId(productId);
                    p.setVariants(variants);
                    if (variants != null && !variants.isEmpty()) {
                        p.setDefaultVariantId(variants.get(0).getVariantId());
                    }

                    p.setOldPrice(price);
                    p.setDiscountPercent(0);
                    if (variants != null && !variants.isEmpty()) {
                        ProductVariantDetailDTO firstV = variants.get(0);
                        if (firstV.getOriginalPrice() != null && firstV.getOriginalPrice().compareTo(price) > 0) {
                            p.setOldPrice(firstV.getOriginalPrice());
                            double disc = (p.getOldPrice().doubleValue() - price.doubleValue()) / p.getOldPrice().doubleValue() * 100.0;
                            p.setDiscountPercent((int) Math.round(disc));
                            p.setTag("-" + p.getDiscountPercent() + "% SALE");
                        }
                    }

                    List<String> imgs = getImagesByProductId(productId);
                    if (imgs == null) {
                        imgs = new ArrayList<>();
                    }
                    if (!imgs.contains(img)) {
                        imgs.add(0, img);
                    }
                    p.setImages(imgs);
                    util.PromotionPricing.applyToProductDetail(p); 
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi tại getProductById:");
            e.printStackTrace();
        }
        return p;
    }

    public List<ProductVariantDetailDTO> getVariantsByProductId(long productId) {
        List<ProductVariantDetailDTO> list = new ArrayList<>();

        String sql = "SELECT variant_id, product_id, sku, variant_name, unit, "
                + "       weight_kg, price, original_price, stock_quantity, is_active "
                + "FROM product_variants "
                + "WHERE product_id = ? AND is_active = 1 "
                + "ORDER BY price ASC, variant_id ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariantDetailDTO v = new ProductVariantDetailDTO();
                    v.setVariantId(rs.getLong("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setOriginalPrice(rs.getBigDecimal("original_price") != null
                            ? rs.getBigDecimal("original_price") : rs.getBigDecimal("price"));
                    v.setWeightKg(rs.getBigDecimal("weight_kg"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));
                    v.setIsActive(rs.getBoolean("is_active"));

                    list.add(v);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
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
            e.printStackTrace();
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
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String origin = rs.getString("origin").trim();
                map.put(origin, rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public int countInStockProducts() {
        String sql = "SELECT COUNT(DISTINCT p.product_id) "
                + "FROM products p "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE p.is_active = 1 AND pv.is_active = 1 AND pv.stock_quantity > 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public BigDecimal[] getMinMaxProductPrices() {
        BigDecimal[] minMax = new BigDecimal[]{new BigDecimal("10000"), new BigDecimal("500000")};
        String sql = "SELECT MIN(pv.price) AS min_p, MAX(pv.price) AS max_p "
                + "FROM products p "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE p.is_active = 1 AND pv.is_active = 1 AND pv.price > 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                BigDecimal minP = rs.getBigDecimal("min_p");
                BigDecimal maxP = rs.getBigDecimal("max_p");
                if (minP != null) {
                    minMax[0] = minP;
                }
                if (maxP != null) {
                    minMax[1] = maxP;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return minMax;
    }

    public List<ProductCardDTO> getFilteredCatalogProducts(String keyword, List<String> categoryParams,
            BigDecimal minPrice, BigDecimal maxPrice,
            Double minRating, List<String> origins,
            Boolean inStockOnly, String sortBy,
            int page, int pageSize) {
        List<ProductCardDTO> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
                .append("p.origin, p.certification, p.storage_temp, pi.image_url, ")
                .append("dv.variant_id AS default_variant_id, dv.price, dv.original_price, dv.unit, ")
                .append("(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock, ")
                .append("(SELECT COALESCE(AVG(CAST(r.rating AS DECIMAL(5,2))), 0.0) FROM reviews r ")
                .append(" JOIN order_items oi ON oi.order_item_id = r.order_item_id ")
                .append(" JOIN product_variants rv ON rv.variant_id = oi.variant_id ")
                .append(" WHERE rv.product_id = p.product_id AND r.status = 'APPROVED') AS avg_rating, ")
                .append("(SELECT COUNT(*) FROM reviews r ")
                .append(" JOIN order_items oi ON oi.order_item_id = r.order_item_id ")
                .append(" JOIN product_variants rv ON rv.variant_id = oi.variant_id ")
                .append(" WHERE rv.product_id = p.product_id AND r.status = 'APPROVED') AS reviews_count ")
                .append("FROM products p ")
                .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
                .append("OUTER APPLY ( ")
                .append("    SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC ")
                .append(") pi ")
                .append("OUTER APPLY ( ")
                .append("    SELECT TOP 1 variant_id, price, original_price, unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY (CASE WHEN stock_quantity > 0 THEN 0 ELSE 1 END), price ASC, variant_id ASC ")
                .append(") dv ")
                .append("WHERE p.is_active = 1");

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ? OR c.category_name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (categoryParams != null && !categoryParams.isEmpty()) {
            List<Integer> ids = new ArrayList<>();
            List<String> slugs = new ArrayList<>();
            for (String c : categoryParams) {
                if (c == null || c.trim().isEmpty() || "all".equalsIgnoreCase(c) || "0".equals(c)) {
                    continue;
                }
                try {
                    ids.add(Integer.parseInt(c.trim()));
                } catch (Exception e) {
                    slugs.add(c.trim());
                }
            }
            if (!ids.isEmpty() || !slugs.isEmpty()) {
                sql.append(" AND (");
                if (!ids.isEmpty()) {
                    sql.append("p.category_id IN (");
                    for (int i = 0; i < ids.size(); i++) {
                        sql.append(i == 0 ? "?" : ", ?");
                        params.add(ids.get(i));
                    }
                    sql.append(")");
                }
                if (!slugs.isEmpty()) {
                    if (!ids.isEmpty()) {
                        sql.append(" OR ");
                    }
                    sql.append("c.slug IN (");
                    for (int i = 0; i < slugs.size(); i++) {
                        sql.append(i == 0 ? "?" : ", ?");
                        params.add(slugs.get(i));
                    }
                    sql.append(")");
                }
                sql.append(")");
            }
        }

        if (minPrice != null && minPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append(" AND dv.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null && maxPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append(" AND dv.price <= ?");
            params.add(maxPrice);
        }

        if (origins != null && !origins.isEmpty()) {
            sql.append(" AND p.origin IN (").append(String.join(",", Collections.nCopies(origins.size(), "?"))).append(")");
            params.addAll(origins);
        }

        switch (sortBy != null ? sortBy.toLowerCase() : "") {
            case "price_asc":
                sql.append(" ORDER BY dv.price ASC, p.product_id DESC");
                break;
            case "price_desc":
                sql.append(" ORDER BY dv.price DESC, p.product_id DESC");
                break;
            case "newest":
                sql.append(" ORDER BY p.product_id DESC");
                break;
            default:
                sql.append(" ORDER BY p.is_featured DESC, p.product_id DESC");
                break;
        }

        if (page > 0 && pageSize > 0) {
            sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
            params.add((page - 1) * pageSize);
            params.add(pageSize);
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProductFromCatalogResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        util.PromotionPricing.applyToProducts(list);
        return list;
    }

    public int countFilteredCatalogProducts(String keyword, List<String> categoryParams,
            BigDecimal minPrice, BigDecimal maxPrice,
            Double minRating, List<String> origins,
            Boolean inStockOnly) {
        return getFilteredCatalogProducts(keyword, categoryParams, minPrice, maxPrice, minRating, origins, inStockOnly, null, 0, 0).size();
    }

    private ProductCardDTO mapProductFromCatalogResultSet(ResultSet rs) throws SQLException {
        ProductCardDTO p = new ProductCardDTO();
        p.setId(rs.getLong("product_id"));
        p.setName(rs.getString("name"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(rs.getString("category_name") != null ? rs.getString("category_name") : "Trái Cây Tươi");
        p.setCategorySlug(rs.getString("category_slug"));
        p.setOrigin(rs.getString("origin"));
        p.setCertification(rs.getString("certification"));
        p.setStorageTemp(rs.getString("storage_temp"));

        String img = rs.getString("image_url");
        if (img == null || img.trim().isEmpty()) {
            img = getDefaultFruitImage(p.getName());
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

        try {
            p.setRating(rs.getDouble("avg_rating"));
            p.setReviewsCount(rs.getInt("reviews_count"));
        } catch (SQLException ignored) {
            double[] rStats = getProductRatingStats(p.getId());
            p.setRating(rStats[0]);
            p.setReviewsCount((int) rStats[1]);
        }

        p.setDefaultVariantId(rs.getLong("default_variant_id"));
        String unit = rs.getString("unit");
        p.setUnit(unit != null && !unit.trim().isEmpty() ? unit : "kg");

        int totalStock = rs.getInt("total_stock");
        p.setStockQuantity(totalStock);
        p.setInStock(totalStock > 0);

        return p;
    }

    public List<ProductCardDTO> getProductsByShop(long shopId, String sortBy) {
        List<ProductCardDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
                .append("    p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
                .append("    p.origin, p.certification, p.storage_temp, ")
                .append("    pi.image_url, ")
                .append("    dv.variant_id AS default_variant_id, ")
                .append("    COALESCE(dv.unit, 'kg') AS unit, ")
                .append("    COALESCE(pv.price, 0) AS price, ")
                .append("    COALESCE(pv.original_price, pv.price, 0) AS original_price, ")
                .append("    COALESCE(pv.total_stock, 0) AS total_stock, ")
                .append("    COALESCE(rev.avg_rating, 0.0) AS avg_rating, ")
                .append("    COALESCE(rev.reviews_count, 0) AS reviews_count ")
                .append("FROM products p ")
                .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
                .append("OUTER APPLY (")
                .append("    SELECT TOP 1 image_url FROM product_images ")
                .append("    WHERE product_id = p.product_id ")
                .append("    ORDER BY is_thumbnail DESC, display_order ASC")
                .append(") pi ")
                .append("OUTER APPLY (")
                .append("    SELECT ")
                .append("        MIN(price) AS price, ")
                .append("        MIN(original_price) AS original_price, ")
                .append("        SUM(stock_quantity) AS total_stock ")
                .append("    FROM product_variants ")
                .append("    WHERE product_id = p.product_id AND is_active = 1")
                .append(") pv ")
                .append("OUTER APPLY (")
                .append("    SELECT TOP 1 variant_id, unit ")
                .append("    FROM product_variants ")
                .append("    WHERE product_id = p.product_id AND is_active = 1 ")
                .append("    ORDER BY CASE WHEN stock_quantity > 0 THEN 0 ELSE 1 END, price ASC")
                .append(") dv ")
                .append("OUTER APPLY (")
                .append("    SELECT ")
                .append("        COALESCE(AVG(CAST(r.rating AS DECIMAL(5,2))), 0.0) AS avg_rating, ")
                .append("        COUNT(r.review_id) AS reviews_count ")
                .append("    FROM reviews r ")
                .append("    JOIN order_items oi ON oi.order_item_id = r.order_item_id ")
                .append("    JOIN product_variants rv ON rv.variant_id = oi.variant_id ")
                .append("    WHERE rv.product_id = p.product_id AND r.status = 'APPROVED'")
                .append(") rev ")
                .append("WHERE p.is_active = 1 AND p.shop_id = ? ");

        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY pv.price ASC, p.product_id DESC");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY pv.price DESC, p.product_id DESC");
        } else if ("newest".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY p.product_id DESC");
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY rev.avg_rating DESC, p.is_featured DESC, p.product_id DESC");
        } else {
            sql.append(" ORDER BY p.is_featured DESC, p.product_id ASC");
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductCardDTO p = mapProductFromCatalogResultSet(rs);
                    p.setShopId(shopId);
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        util.PromotionPricing.applyToProducts(list); 
        return list;
    }

    public List<ProductCardDTO> getProductSummariesByShopId(long shopId) {
        return getProductSummariesByShopId(shopId, null);
    }

    public List<ProductCardDTO> getProductSummariesByShopId(long shopId, String statusTab) {
        List<ProductCardDTO> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.product_id, p.name, p.origin, p.certification, "
                + "p.storage_temp, p.description, c.category_name, p.is_active, "
                + "pi.image_url AS image_url, "
                + "COALESCE(stats.min_price, 0) AS min_price, "
                + "COALESCE(stats.max_price, 0) AS max_price, "
                + "COALESCE(stats.total_stock, 0) AS total_stock, "
                + "COALESCE(stats.variant_count, 0) AS variant_count "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 image_url FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC"
                + ") pi "
                + "OUTER APPLY ("
                + "    SELECT "
                + "        MIN(price) AS min_price, "
                + "        MAX(price) AS max_price, "
                + "        SUM(CASE WHEN is_active = 1 THEN stock_quantity ELSE 0 END) AS total_stock, "
                + "        COUNT(variant_id) AS variant_count "
                + "    FROM product_variants "
                + "    WHERE product_id = p.product_id"
                + ") stats "
                + "WHERE p.shop_id = ? ");

        if (statusTab != null && !statusTab.trim().isEmpty() && !statusTab.equalsIgnoreCase("all")) {
            if ("active".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 1 AND COALESCE(stats.total_stock, 0) > 5 ");
            } else if ("low_stock".equalsIgnoreCase(statusTab) || "warning".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 1 AND COALESCE(stats.total_stock, 0) > 0 AND COALESCE(stats.total_stock, 0) <= 5 ");
            } else if ("out_of_stock".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 1 AND COALESCE(stats.total_stock, 0) = 0 ");
            } else if ("hidden".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 0 ");
            } else if ("vietgap".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%') ");
            }
        }

        sql.append(" ORDER BY p.product_id DESC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductCardDTO product = new ProductCardDTO();
                    product.setId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setOrigin(rs.getString("origin"));
                    product.setCertification(rs.getString("certification"));
                    product.setStorageTemp(rs.getString("storage_temp"));
                    product.setDescription(rs.getString("description"));
                    product.setCategoryName(rs.getString("category_name"));
                    String pImg = rs.getString("image_url");
                    if (pImg == null || pImg.trim().isEmpty()) {
                        pImg = getDefaultFruitImage(product.getName());
                    }
                    product.setImage(pImg);
                    product.setPrice(rs.getBigDecimal("min_price"));
                    product.setOldPrice(rs.getBigDecimal("max_price"));
                    product.setStockQuantity(rs.getInt("total_stock"));
                    product.setVariantCount(rs.getInt("variant_count"));
                    product.setActive(rs.getBoolean("is_active"));
                    products.add(product);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
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
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countProductsByStatusTab(long shopId, String statusTab) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(DISTINCT p.product_id) FROM products p "
                + "OUTER APPLY ("
                + "    SELECT SUM(CASE WHEN is_active = 1 THEN stock_quantity ELSE 0 END) AS total_stock "
                + "    FROM product_variants WHERE product_id = p.product_id"
                + ") stats "
                + "WHERE p.shop_id = ?");

        if (statusTab != null && !statusTab.trim().isEmpty() && !statusTab.equalsIgnoreCase("all")) {
            if ("active".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 1 AND COALESCE(stats.total_stock, 0) > 5 ");
            } else if ("low_stock".equalsIgnoreCase(statusTab) || "warning".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 1 AND COALESCE(stats.total_stock, 0) > 0 AND COALESCE(stats.total_stock, 0) <= 5 ");
            } else if ("out_of_stock".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 1 AND COALESCE(stats.total_stock, 0) = 0 ");
            } else if ("hidden".equalsIgnoreCase(statusTab)) {
                sql.append(" AND p.is_active = 0 ");
            } else if ("vietgap".equalsIgnoreCase(statusTab)) {
                sql.append(" AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%') ");
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
            e.printStackTrace();
        }
        return 0;
    }

    public ProductVariantDetailDTO getShopVariantById(long variantId, long shopId) {
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, pv.price, pv.original_price, "
                + "pv.stock_quantity, pv.low_stock_threshold, pv.is_active, p.name AS product_name, p.origin, "
                + "p.storage_temp, p.certification, p.description, c.category_name, "
                + "pi.image_url AS image_url "
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
                ProductVariantDetailDTO variant = new ProductVariantDetailDTO();
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
                String vImg = rs.getString("image_url");
                if (vImg == null || vImg.trim().isEmpty()) {
                    vImg = getDefaultFruitImage(variant.getProductName());
                }
                variant.setImage(vImg);
                return variant;
            }
        } catch (Exception e) {
            e.printStackTrace();
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
            e.printStackTrace();
            return false;
        }
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
                    variant.setActive(rs.getBoolean("is_active"));
                    list.add(variant);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ProductCardDTO> getShopFilteredProducts(long shopId, String keyword, Long categoryId,
            String certification, String stockLevel) {
        List<ProductCardDTO> products = new ArrayList<>();
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

        try (Connection connection = getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                statement.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    ProductCardDTO product = new ProductCardDTO();
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
                        image = getDefaultFruitImage(product.getName());
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
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
            return false;
        }
    }

    public ProductDetailDTO getShopProductForEdit(long productId, long shopId) {
        String sql = "SELECT p.product_id, p.name, p.category_id, p.origin, p.storage_temp, "
                + "p.certification, p.description, p.is_active, "
                + "pi.image_url AS image_url "
                + "FROM products p LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE p.product_id = ? AND p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setLong(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ProductDetailDTO product = new ProductDetailDTO();
                product.setId(rs.getLong("product_id"));
                product.setName(rs.getString("name"));
                product.setCategoryId(rs.getInt("category_id"));
                product.setOrigin(rs.getString("origin"));
                product.setStorageTemp(rs.getString("storage_temp"));
                product.setCertification(rs.getString("certification"));
                product.setDescription(rs.getString("description"));
                product.setActive(rs.getBoolean("is_active"));
                String editImg = rs.getString("image_url");
                if (editImg == null || editImg.trim().isEmpty()) {
                    editImg = getDefaultFruitImage(product.getName());
                }
                product.setImage(editImg);
                return product;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean updateFullProduct(long shopId, long productId, String name, int categoryId, String origin,
            String storageTemp, String certification, String description, boolean isActive, String coverImageUrl) {
        return updateFullProduct(shopId, productId, name, categoryId, origin, storageTemp, certification, description, isActive, coverImageUrl, null);
    }

    public boolean updateFullProduct(long shopId, long productId, String name, int categoryId, String origin,
            String storageTemp, String certification, String description, boolean isActive, String coverImageUrl, List<String> detailImageUrls) {
        String sqlProduct = "UPDATE products SET name = ?, category_id = ?, origin = ?, storage_temp = ?, "
                + "certification = ?, description = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE product_id = ? AND shop_id = ?";
        String sqlUpdateImage = "UPDATE product_images SET image_url = ? WHERE product_id = ? AND is_thumbnail = 1";
        String sqlInsertImage = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) VALUES (?, ?, 1, 1, CURRENT_TIMESTAMP)";
        String sqlDeleteDetailImages = "DELETE FROM product_images WHERE product_id = ? AND is_thumbnail = 0";
        String sqlInsertDetailImage = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) VALUES (?, ?, 0, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlProduct)) {
                    ps.setString(1, name);
                    if (categoryId > 0) {
                        ps.setInt(2, categoryId);
                    } else {
                        ps.setNull(2, java.sql.Types.INTEGER);
                    }
                    ps.setString(3, origin == null ? "" : origin.trim());
                    ps.setString(4, storageTemp == null ? "" : storageTemp.trim());
                    ps.setString(5, certification == null ? "" : certification.trim());
                    ps.setString(6, description == null ? "" : description);
                    ps.setBoolean(7, isActive);
                    ps.setLong(8, productId);
                    ps.setLong(9, shopId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }
                if (coverImageUrl != null && !coverImageUrl.trim().isEmpty()) {
                    int changed;
                    try (PreparedStatement ps = conn.prepareStatement(sqlUpdateImage)) {
                        ps.setString(1, coverImageUrl.trim());
                        ps.setLong(2, productId);
                        changed = ps.executeUpdate();
                    }
                    if (changed == 0) {
                        try (PreparedStatement ps = conn.prepareStatement(sqlInsertImage)) {
                            ps.setLong(1, productId);
                            ps.setString(2, coverImageUrl.trim());
                            ps.executeUpdate();
                        }
                    }
                }
                if (detailImageUrls != null) {
                    try (PreparedStatement ps = conn.prepareStatement(sqlDeleteDetailImages)) {
                        ps.setLong(1, productId);
                        ps.executeUpdate();
                    }
                    int order = 2;
                    for (String dImg : detailImageUrls) {
                        if (dImg != null && !dImg.trim().isEmpty()) {
                            try (PreparedStatement ps = conn.prepareStatement(sqlInsertDetailImage)) {
                                ps.setLong(1, productId);
                                ps.setString(2, dImg.trim());
                                ps.setInt(3, order++);
                                ps.executeUpdate();
                            }
                        }
                    }
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<ProductCardDTO> searchAndFilterProducts(String keyword, String categorySlug, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin) {
        return searchAndFilterProducts(keyword, categorySlug, minPriceStr, maxPriceStr, ratingStr, availability, origin, "default");
    }

    public List<ProductCardDTO> searchAndFilterProducts(String keyword, String categorySlug, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin, String sortBy) {

        List<ProductCardDTO> productList = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        boolean filterByCategory = categorySlug != null && !categorySlug.trim().isEmpty() && !"0".equals(categorySlug.trim());

        if (filterByCategory) {
            String categoryValue = categorySlug.trim();
            try {
                params.add(Integer.parseInt(categoryValue));
                sql.append("WITH CategoryTree AS (SELECT category_id FROM categories WHERE category_id = ? ")
                        .append("UNION ALL SELECT child.category_id FROM categories child ")
                        .append("INNER JOIN CategoryTree parent ON child.parent_id = parent.category_id) ");
            } catch (NumberFormatException e) {
                params.add(categoryValue);
                sql.append("WITH CategoryTree AS (SELECT category_id FROM categories WHERE slug = ? ")
                        .append("UNION ALL SELECT child.category_id FROM categories child ")
                        .append("INNER JOIN CategoryTree parent ON child.parent_id = parent.category_id) ");
            }
        }

        sql.append("SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
                .append("p.origin, p.certification, pi.image_url, ")
                .append("v.price, v.original_price, v.unit, ") 
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
                .append("OUTER APPLY ( ")
                .append("    SELECT TOP 1 price, original_price, unit FROM product_variants ")
                .append("    WHERE product_id = p.product_id AND is_active = 1 ")
                .append("    ORDER BY price ASC ")
                .append(") v ") 
                .append("WHERE p.is_active = 1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND p.name LIKE ? ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
        }

        if (filterByCategory) {
            sql.append(" AND p.category_id IN (SELECT category_id FROM CategoryTree) ");
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

        if ("in_stock".equals(availability)) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants av WHERE av.product_id = p.product_id AND av.is_active = 1 AND av.stock_quantity > 0) ");
        } else if ("out_of_stock".equals(availability)) {
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
                    ProductCardDTO p = new ProductCardDTO();
                    p.setId(rs.getLong("product_id"));
                    p.setName(rs.getString("name"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = getDefaultFruitImage(p.getName());
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

                    productList.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return productList;
    }
}
