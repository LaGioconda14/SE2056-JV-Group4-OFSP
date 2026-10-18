package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.ProductVariant;
import model.Category;
import service.IProductService;
import service.impl.ProductServiceImpl;
import util.DBContext;

public class ProductDAO extends DBContext {

    // 1. Lấy danh sách sản phẩm/biến thể theo shopId
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
            e.printStackTrace();
        }
        return list;
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

    // 3. Đếm tổng số biến thể (SKUs) của shop
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

    // 5. Bật/Tắt trạng thái hoạt động của biến thể
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

    // Xóa biến thể theo id và shopid
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

    // Đếm số lượng biến thể theo từng tab trạng thái của shop
    public List<ProductVariant> getFilteredVariantsByShop(long shopId, String keyword, String categoryId,
            String certification, String stockLevel,
            String statusTab) {
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
            e.printStackTrace();
        }
        return list;
    }

    // Đếm số lượng biến thể theo từng tab trạng thái của shop
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

            // 5. Insert batch
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
                batchEx.printStackTrace();
            }

            conn.commit();
            return productId;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
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

    // =========================================================================
    // 8. CẬP NHẬT ĐẦY ĐỦ THÔNG TIN SẢN PHẨM, BIẾN THỂ VÀ ẢNH BÌA
    // =========================================================================
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

            // 1. Lấy product_id tương ứng với variantId đang sửa
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
            e.printStackTrace();
        }
        return list;
    }

    public List<Category> getHomeFeaturedTabs() {
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
            e.printStackTrace();
        }
        return list;
    }

    public List<Category> getHierarchyCategories() {
        List<Category> list = new ArrayList<>();
        String query = "SELECT category_id, category_name, slug, description, is_active "
                + "FROM categories WHERE is_active = 1 ORDER BY category_id ASC";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("category_id"));
                category.setParentId(null);
                category.setCategoryName(rs.getString("category_name"));
                category.setSlug(rs.getString("slug"));
                category.setDescription(rs.getString("description"));
                category.setDisplayOrder(rs.getInt("category_id"));
                category.setIsActive(rs.getBoolean("is_active"));
                list.add(category);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getHomeProducts() {
        List<Product> list = new ArrayList<>();
        String query = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.origin, pi.image_url, "
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
                + "ORDER BY p.product_id DESC";

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
                p.setCertification(null);
                p.setDefaultVariantId(rs.getLong("default_variant_id"));
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
                + "p.origin, pi.image_url, dv.variant_id AS default_variant_id, "
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
                    p.setCertification(null);
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
        return list;
    }

    // 1. Lấy thông tin chi tiết sản phẩm theo ID chuẩn theo model Product
    public Product getProductById(int productId) {
        Product p = null;
        String sql = "SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, "
                + "p.shop_id, p.origin, p.description, "
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

                    p.setOldPrice(price);

                    String unit = rs.getString("unit");
                    p.setUnit(unit != null ? unit : "giỏ");

                    p.setOrigin(rs.getString("origin"));
                    p.setDescription(rs.getString("description"));
                    p.setStorageTemp(null);
                    p.setCertification(null);

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
        String sql = "SELECT pv.variant_id, pv.product_id, pv.sku, pv.variant_name, pv.unit, "
                + "pv.weight_kg, pv.price, pv.stock_quantity, pv.is_active, "
                + "p.name AS product_name, p.origin, p.description, c.category_name, pi.image_url "
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
                    v.setOriginalPrice(rs.getBigDecimal("price"));
                    v.setWeightKg(rs.getBigDecimal("weight_kg"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));
                    v.setImage(rs.getString("image_url"));
                    v.setOrigin(rs.getString("origin"));
                    v.setCategoryName(rs.getString("category_name"));
                    v.setCertification(null);
                    v.setIsActive(rs.getBoolean("is_active"));
                    v.setStorageTemp(null);
                    v.setDescription(rs.getString("description"));

                    list.add(v);
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

    public List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_id, p.name, p.category_id, c.category_name, c.slug AS category_slug, ")
                .append("p.origin, pi.image_url, dv.variant_id AS default_variant_id, ")
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
            }
        }

        // 3. Lọc theo khoảng giá (dựa vào giá nhỏ nhất của biến thể sản phẩm)
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
                    p.setCertification(null);
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
        return list;
    }
}
