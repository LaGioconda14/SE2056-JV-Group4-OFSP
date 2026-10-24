package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.ProductVariant;
import model.Category;
import util.DBContext;

public class ProductDAO extends DBContext {

    // Returns one product summary per shop product, with variant-derived totals.
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
            e.printStackTrace();
        }
        return products;
    }

    // 2. Đếm tổng số sản phẩm gốc của shop
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

    // 4. Kiểm tra SKU đã tồn tại chưa
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

    // Xóa mềm biến thể (Chuyển trạng thái is_active về 0 thay vì xóa vĩnh viễn)
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

    public boolean softDeleteProduct(long productId, long shopId) {
        String updateProduct = "UPDATE products SET is_active = 0 WHERE product_id = ? AND shop_id = ?";
        String updateVariants = "UPDATE product_variants SET is_active = 0 WHERE product_id = ?";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement productStatement = conn.prepareStatement(updateProduct)) {
                productStatement.setLong(1, productId);
                productStatement.setLong(2, shopId);
                if (productStatement.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }
            try (PreparedStatement variantStatement = conn.prepareStatement(updateVariants)) {
                variantStatement.setLong(1, productId);
                variantStatement.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Đếm số lượng sản phẩm theo từng tab trạng thái của shop

    // Đếm số lượng biến thể theo từng tab trạng thái của shop
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
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy danh sách các chứng nhận (certification) phân biệt từ bảng products
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

    // Lấy danh sách nhiệt độ bảo quản gợi ý     từ DB
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

    //lấy unit đưa lên form để người dùng chọn chính xác
    public List<String> getAllUnits() {
        List<String> list = new ArrayList<>();

        // 1. Thêm các đơn vị tiêu chuẩn lên đầu
        list.add("hộp");
        list.add("kg");
        list.add("túi");
        list.add("thùng");
        list.add("gram");
        list.add("giỏ");
        list.add("nải");
        list.add("quả");

        // 2. Lấy thêm từ Database, nếu chưa có trong list thì mới thêm vào
        String sql = "SELECT DISTINCT unit FROM product_variants WHERE unit IS NOT NULL AND unit != '' ORDER BY unit ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String u = rs.getString("unit");
                if (u != null && !u.trim().isEmpty()) {
                    String unitLower = u.trim().toLowerCase();
                    // Nếu list chưa chứa đơn vị này thì mới add vào để tránh bị trùng
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

    // 7. Thêm mới đầy đủ sản phẩm, biến thể, hình ảnh và lô hàng
    // 7. Thêm mới đầy đủ sản phẩm, biến thể và hình ảnh
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

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            long productId = -1;
            long variantId = -1;

            String slug = generateProductSlug(name);

            // 1. Insert product
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

            // 2. Validate/generate SKU
            String finalSku = (sku != null && !sku.trim().isEmpty()) ? sku.trim() : ("SKU-" + (System.currentTimeMillis() % 1000000));
            int skuRetry = 1;
            while (isSkuExists(finalSku)) {
                finalSku = "SKU-" + (System.currentTimeMillis() % 1000000) + "-" + (skuRetry++);
            }

            // 3. Insert variant
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

            // 4. Insert images
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

            conn.commit();
            return productId;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public long addVariantToProduct(long shopId, long productId, String sku, String variantName, String unit,
            BigDecimal price, BigDecimal originalPrice, int stockQuantity, int lowStockThreshold, boolean isActive) {
        String sql = "INSERT INTO product_variants (product_id, sku, variant_name, unit, price, original_price, stock_quantity, low_stock_threshold, is_active, created_at, updated_at) "
                + "SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP "
                + "FROM products WHERE product_id = ? AND shop_id = ?";
        String finalSku = (sku == null || sku.trim().isEmpty())? "SKU-" + (System.currentTimeMillis() % 1000000) : sku.trim();
        int skuRetry = 1;
        while (isSkuExists(finalSku)) {
            finalSku = "SKU-" + (System.currentTimeMillis() % 1000000) + "-" + (skuRetry++);
        }

        try (Connection conn = getConnection();
                PreparedStatement statement = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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

    // Helper: Tạo Slug chuẩn không dấu
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

    // =========================================================================
    // 1. LẤY THÔNG TIN CHI TIẾT SẢN PHẨM & BIẾN THỂ ĐỂ ĐỔ RA FORM SỬA
    // =========================================================================
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
                    // Thông tin biến thể (Variant)
                    pv.setVariantId(rs.getLong("variant_id"));
                    pv.setProductId(rs.getLong("product_id"));
                    pv.setSku(rs.getString("sku"));
                    pv.setVariantName(rs.getString("variant_name"));
                    pv.setUnit(rs.getString("unit"));
                    pv.setPrice(rs.getBigDecimal("price"));
                    pv.setOriginalPrice(rs.getBigDecimal("original_price"));
                    pv.setStockQuantity(rs.getInt("stock_quantity"));
                    pv.setIsActive(rs.getBoolean("is_active"));

                    // Thông tin chung sản phẩm (Product)
                    pv.setProductName(rs.getString("product_name"));
                    pv.setCategoryId(rs.getInt("category_id"));
                    pv.setOrigin(rs.getString("origin"));
                    pv.setStorageTemp(rs.getString("storage_temp"));
                    pv.setCertification(rs.getString("certification"));
                    pv.setDescription(rs.getString("description"));
                    pv.setImage(rs.getString("image_url")); // Map đúng vào trường ảnh qua LEFT JOIN
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return pv;
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
    //Chỉnh sửa biến thể theo variantID 
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

    // =========================================================================
    // 8. CẬP NHẬT ĐẦY ĐỦ THÔNG TIN SẢN PHẨM, BIẾN THỂ VÀ ẢNH BÌA
    // =========================================================================
    public boolean updateFullProduct(long shopId, long variantId, String name, int categoryId, String origin,
            String storageTemp, String certification, String description,
            String sku, String variantName, String unit, BigDecimal price,
            BigDecimal originalPrice, int stockQuantity, boolean isActive,
            String coverImageUrl) {

        // Bổ sung JOIN sang bảng products để khóa chặt quyền sở hữu theo shopId
        String sqlGetProductId = "SELECT pv.product_id FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ? AND p.shop_id = ?";

        String sqlUpdateProduct = "UPDATE products SET name = ?, category_id = ?, origin = ?, storage_temp = ?, certification = ?, description = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        String sqlUpdateVariant = "UPDATE product_variants SET sku = ?, variant_name = ?, unit = ?, price = ?, original_price = ?, stock_quantity = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE variant_id = ?";
        String sqlCheckImage = "SELECT image_id FROM product_images WHERE product_id = ? AND is_thumbnail = 1";
        String sqlUpdateImage = "UPDATE product_images SET image_url = ? WHERE product_id = ? AND is_thumbnail = 1";
        String sqlInsertImage = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) VALUES (?, ?, 1, 1, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            long productId = -1;

            // 1. Kiểm tra quyền sở hữu và lấy product_id (Chống IDOR tuyệt đối)
            try (PreparedStatement ps = conn.prepareStatement(sqlGetProductId)) {
                ps.setLong(1, variantId);
                ps.setLong(2, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        productId = rs.getLong("product_id");
                    }
                }
            }

            // Nếu variant_id không tồn tại HOẶC không thuộc về shopId này -> Đá văng luôn
            if (productId == -1) {
                conn.rollback();
                return false;
            }

            // 2. Cập nhật thông tin chung ở bảng products
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

            // 3. Cập nhật thông tin biến thể ở bảng product_variants
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

            // 4. Cập nhật hoặc thêm mới ảnh bìa (thumbnail) trong product_images
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
            e.printStackTrace();
        }
        return false;
    }

    public List<Category> getHierarchyCategories() {
        List<Category> list = new ArrayList<>();
        String queryParents = "SELECT category_id, category_name, slug, image_url, display_order "
                + "FROM categories "
                + "WHERE category_id IN (5, 6, 7, 8, 9) "
                + "ORDER BY display_order ASC";

        String querySubs = "SELECT category_id, parent_id, category_name, slug, display_order "
                + "FROM categories "
                + "WHERE parent_id IN (5, 6) AND is_active = 1 "
                + "ORDER BY display_order ASC";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(queryParents); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category c = new Category();
                    c.setCategoryId(rs.getInt("category_id"));
                    c.setCategoryName(rs.getString("category_name"));
                    c.setSlug(rs.getString("slug"));
                    c.setImageUrl(rs.getString("image_url"));
                    c.setDisplayOrder(rs.getInt("display_order"));
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
                    sub.setDisplayOrder(rs.getInt("display_order"));

                    for (Category parent : list) {
                        if (parent.getCategoryId() == parentId) {
                            parent.addSubCategory(sub);
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getHomeProducts() {
        List<Product> list = new ArrayList<>();
        String query = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.origin, p.certification, pi.image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT MIN(original_price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS original_price, " // <-- Đã thêm đoạn này vào SQL
                + "(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, "
                + "(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 image_url FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC"
                + ") pi "
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

                // Lấy đúng nguyên bản giá gốc từ DB, nếu null thì gán bằng giá bán luôn
                BigDecimal oldPrice = rs.getBigDecimal("original_price");
                if (oldPrice == null) {
                    oldPrice = price;
                }

                // Không nhân phần trăm hay gán cứng 20% nữa, để bằng 0 hoặc tự tính
                int discountPercent = 0;
                if (oldPrice.compareTo(price) > 0) {
                    BigDecimal discountAmount = oldPrice.subtract(price);
                    discountPercent = discountAmount.multiply(new BigDecimal("100"))
                            .divide(oldPrice, 0, java.math.RoundingMode.HALF_UP)
                            .intValue();
                }

                Product p = new Product(id, name, categoryName, image, price, oldPrice, discountPercent, 4.9, 32);
                p.setCategoryId(catId);
                p.setCategorySlug(categorySlug);
                p.setOrigin(rs.getString("origin"));
                p.setCertification(rs.getString("certification"));
                p.setUnit(rs.getString("unit"));
                int totalStock = rs.getInt("total_stock");
                p.setStockQuantity(totalStock);
                p.setInStock(totalStock > 0);
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 9. Lấy danh sách sản phẩm theo category slug (Dùng cho trang danh mục sản phẩm)
    public List<Product> getProductsByCategorySlug(String categorySlug) {
        List<Product> list = new ArrayList<>();
        String query = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.origin, p.certification, pi.image_url, "
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
        return list;
    }

    // 1. Lấy thông tin chi tiết sản phẩm theo ID chuẩn theo model Product
    public Product getProductById(int productId) {
        Product p = null;
        String sql = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.shop_id, p.origin, p.description, p.storage_temp, p.certification, "
                + "COALESCE(pi.image_url, 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop') AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT MIN(original_price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS old_price, "
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

                    // Lấy ảnh chuẩn
                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                    }
                    p.setImage(img);

                    // Lấy giá chuẩn từ product_variants
                    java.math.BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = new java.math.BigDecimal("750000"); // Giá mặc định nếu DB trống
                    }
                    p.setPrice(price);

                    java.math.BigDecimal oldPrice = rs.getBigDecimal("old_price");
                    if (oldPrice == null) {
                        oldPrice = price.multiply(new java.math.BigDecimal("1.2"));
                    }
                    p.setOldPrice(oldPrice);

                    String unit = rs.getString("unit");
                    p.setUnit(unit != null ? unit : "giỏ");

                    p.setOrigin(rs.getString("origin"));
                    p.setDescription(rs.getString("description"));
                    p.setStorageTemp(rs.getString("storage_temp"));
                    p.setCertification(rs.getString("certification"));

                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock);
                    p.setInStock(totalStock > 0);

                    // Gắn danh sách ảnh chi tiết và biến thể
                    p.setImages(getImagesByProductId(productId));
                    p.setVariants(getVariantsByProductId(productId));
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi tại getProductById:");
            e.printStackTrace();
        }
        return p;
    }

    // 2. Lấy danh sách biến thể (variants) khớp chuẩn model ProductVariant
    public List<ProductVariant> getVariantsByProductId(long productId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT pv.*, p.name AS product_name, p.origin, c.category_name, p.certification, p.storage_temp, p.description, pi.image_url "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN Categories c ON p.category_id = c.category_id "
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
                    v.setOriginalPrice(rs.getBigDecimal("original_price")); // Hoặc old_price tùy tên cột trong DB của ông
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
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return list;
    }

    // 3. Lấy danh sách ảnh chi tiết của sản phẩm (List<String>)
    public List<String> getImagesByProductId(long productId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT image_url FROM product_images WHERE product_id = ? "
                + "ORDER BY is_thumbnail DESC, display_order ASC";

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
                // Lấy giá bán và giá gốc của CÙNG biến thể có giá rẻ nhất (ORDER BY price ASC)
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

        // 1. Lọc theo từ khóa tìm kiếm (tên sản phẩm hoặc xuất xứ)
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        // 2. Lọc theo danh mục
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

        // 3. Lọc theo khoảng giá (dựa vào giá của biến thể nhỏ nhất)
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

        // 4. Lọc theo Đánh giá (Rating)
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

        // 5. Lọc theo Tình trạng kho (Availability)
        if (availability != null && availability.equals("in_stock")) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants av WHERE av.product_id = p.product_id AND av.is_active = 1 AND av.stock_quantity > 0) ");
        } else if (availability != null && availability.equals("out_of_stock")) {
            sql.append(" AND NOT EXISTS (SELECT 1 FROM product_variants av WHERE av.product_id = p.product_id AND av.is_active = 1 AND av.stock_quantity > 0) ");
        }

        // 6. Lọc theo Xuất xứ
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
                    p.setCategoryName(rs.getString("category_name") != null ? rs.getString("category_name") : "Trái Cây Tươi");

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

                    // Đọc đúng giá gốc từ DB
                    BigDecimal oldPrice = rs.getBigDecimal("original_price");
                    if (oldPrice == null || oldPrice.compareTo(price) < 0) {
                        oldPrice = price; // Nếu giá gốc rỗng hoặc nhỏ hơn giá bán thì mặc định bằng giá bán
                    }
                    p.setOldPrice(oldPrice);

                    // Tính % giảm giá thực tế
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
            e.printStackTrace();
        }
        return list;
    }

    // Ví dụ hàm lấy thông tin biến thể để đưa lên form sửa

    public List<Product> getHomeFeaturedTabs() {
        List<Product> list = new ArrayList<>();
        // Câu lệnh SQL tối ưu: Lấy thông tin sản phẩm, danh mục, ảnh đại diện thumbnail, 
        // và giá bán/giá gốc nhỏ nhất từ các biến thể đang hoạt động (is_active = 1)
        String query = "SELECT p.product_id, p.name, p.origin, c.category_name, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT MIN(original_price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS original_price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.is_active = 1 "
                + "ORDER BY p.product_id DESC"; // Lấy danh sách sản phẩm mới nhất hoặc nổi bật

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                long id = rs.getLong("product_id");
                String name = rs.getString("name");
                String origin = rs.getString("origin");
                String categoryName = rs.getString("category_name");
                if (categoryName == null) {
                    categoryName = "Trái Cây Tươi";
                }

                String image = rs.getString("image_url");
                if (image == null || image.isEmpty()) {
                    image = "https://images.unsplash.com/photo-1610832958506-aa56368176cf"; // Ảnh mặc định dự phòng
                }

                BigDecimal price = rs.getBigDecimal("price");
                if (price == null) {
                    price = BigDecimal.ZERO;
                }

                // Lấy đúng giá gốc từ DB, nếu không có thì gán bằng giá bán
                BigDecimal oldPrice = rs.getBigDecimal("original_price");
                if (oldPrice == null) {
                    oldPrice = price;
                }

                int discountPercent = 0; // Không tính giảm giá ảo, để mặc định hoặc tự tính nếu cần

                // Khởi tạo đối tượng Product khớp với Constructor của ông
                Product product = new Product(id, name, categoryName, image, price, oldPrice, discountPercent, 4.9, 18);
                product.setOrigin(origin); // Gắn thêm xuất xứ nếu model có thuộc tính này

                list.add(product);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
