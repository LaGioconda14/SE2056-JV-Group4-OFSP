package dao;

import java.lang.System.Logger;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.ProductVariant;
import util.DBContext;

public class ProductDAO extends DBContext {
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

    public List<Product> getTop8Products() {
        List<Product> list = new ArrayList<>();
        String query = "SELECT TOP 8 p.product_id, p.name, c.category_name, "
                + "pi.image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "OUTER APPLY ("
                + "    SELECT TOP 1 image_url FROM product_images "
                + "    WHERE product_id = p.product_id "
                + "    ORDER BY is_thumbnail DESC, display_order ASC"
                + ") pi "
                + "WHERE p.is_active = 1 "
                + "ORDER BY p.product_id DESC";

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

    public List<Product> searchByFilter(String txtSearch, String categoryId, Double minPrice, Double maxPrice, Integer rating) {
        List<Product> list = new ArrayList<>();

        StringBuilder query = new StringBuilder("SELECT p.product_id, p.name, c.category_name, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.is_active = 1");

        if (txtSearch != null && !txtSearch.trim().isEmpty()) {
            query.append(" AND p.name LIKE ?");
        }
        if (categoryId != null && !categoryId.trim().isEmpty()) {
            query.append(" AND p.category_id = ?");
        }
        if (minPrice != null) {
            query.append(" AND (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) >= ?");
        }
        if (maxPrice != null) {
            query.append(" AND (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) <= ?");
        }

        try {
            Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement(query.toString());

            int index = 1;
            if (txtSearch != null && !txtSearch.trim().isEmpty()) {
                ps.setString(index++, "%" + txtSearch + "%");
            }
            if (categoryId != null && !categoryId.trim().isEmpty()) {
                ps.setString(index++, categoryId);
            }
            if (minPrice != null) {
                ps.setDouble(index++, minPrice);
            }
            if (maxPrice != null) {
                ps.setDouble(index++, maxPrice);
            }

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
    
    // ========================= PHẦN QUẢN LÝ SẢN PHẨM & KHO HÀNG (SHOP PORTAL) =========================
    
    public List<ProductVariant> getVariantsByShopId(long shopId) {
        List<ProductVariant> list = new ArrayList<>();
        
        String sql = "SELECT " +
                     "    pv.variant_id, " +
                     "    pv.sku, " +
                     "    pv.variant_name, " +
                     "    pv.price, " +
                     "    pv.original_price, " +
                     "    pv.stock_quantity, " +
                     "    pv.unit, " +
                     "    pi.image_url, " +
                     "    pv.is_active, " +
                     "    p.name AS product_name, " +
                     "    p.origin, " +
                     "    c.category_name, " +
                     "    p.certification " +
                     "FROM product_variants pv " +
                     "JOIN products p ON pv.product_id = p.product_id " +
                     "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE p.shop_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, shopId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    // Khớp đúng kiểu int theo model của ông
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    
                    // Khớp đúng kiểu double theo model của ông
                    v.setPrice(rs.getDouble("price"));
                    v.setOriginalPrice(rs.getDouble("original_price"));
                    
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));
                    
                    // Xử lý ảnh (nếu null thì dùng ảnh mặc định)
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
                    
                    list.add(v);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return list;
    }   

    public boolean isSkuExists(String sku) {
        String sql = "SELECT 1 FROM product_variants WHERE sku = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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
}