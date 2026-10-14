package dao;

import java.lang.System.Logger;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Category;
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

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.category_name, c.slug, "
                   + "       COUNT(p.product_id) AS product_count "
                   + "FROM categories c "
                   + "LEFT JOIN products p ON c.category_id = p.category_id AND p.is_active = 1 "
                   + "WHERE c.is_active = 1 "
                   + "GROUP BY c.category_id, c.category_name, c.slug "
                   + "ORDER BY product_count DESC, c.category_name ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Category(
                    rs.getInt("category_id"),
                    rs.getString("category_name"),
                    rs.getString("slug"),
                    rs.getInt("product_count")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countCatalogProducts(String keyword, String[] categories, Double minPrice, Double maxPrice, Integer rating, String availability, String origin, String tag) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(DISTINCT p.product_id) "
            + "FROM products p "
            + "LEFT JOIN categories c ON p.category_id = c.category_id "
            + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
            + "WHERE p.is_active = 1"
        );
        List<Object> params = new ArrayList<>();
        buildCatalogFilterSql(sql, params, keyword, categories, minPrice, maxPrice, rating, availability, origin, tag);

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
            e.printStackTrace();
        }
        return 0;
    }

    public List<Product> getCatalogProducts(String keyword, String[] categories, Double minPrice, Double maxPrice, Integer rating, String availability, String origin, String tag, String sortBy, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder(
            "SELECT p.product_id, p.name, p.origin, p.certification, "
            + "       c.category_name, "
            + "       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC) AS image_url, "
            + "       MIN(pv.price) AS min_price, "
            + "       MAX(pv.original_price) AS max_old_price, "
            + "       SUM(ISNULL(pv.stock_quantity, 0)) AS total_stock, "
            + "       (SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY price ASC) AS unit "
            + "FROM products p "
            + "LEFT JOIN categories c ON p.category_id = c.category_id "
            + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
            + "WHERE p.is_active = 1"
        );

        List<Object> params = new ArrayList<>();
        buildCatalogFilterSql(sql, params, keyword, categories, minPrice, maxPrice, rating, availability, origin, tag);

        sql.append(" GROUP BY p.product_id, p.name, p.origin, p.certification, c.category_name, p.created_at");

        // Sort by
        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY MIN(pv.price) ASC");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY MIN(pv.price) DESC");
        } else if ("rating".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY p.name ASC");
        } else {
            // Default "featured" / "newest"
            sql.append(" ORDER BY p.product_id DESC");
        }

        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    long id = rs.getLong("product_id");
                    p.setId(id);
                    p.setName(rs.getString("name"));
                    
                    String originVal = rs.getString("origin");
                    p.setOrigin((originVal != null && !originVal.trim().isEmpty()) ? originVal : "Nông Trại Đà Lạt");
                    
                    String catName = rs.getString("category_name");
                    p.setCategoryName((catName != null) ? catName : "Trái Cây Tươi");
                    
                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf";
                    }
                    p.setImage(img);

                    BigDecimal price = rs.getBigDecimal("min_price");
                    if (price == null) {
                        price = new BigDecimal("100000");
                    }
                    p.setPrice(price);

                    BigDecimal oldPrice = rs.getBigDecimal("max_old_price");
                    if (oldPrice == null || oldPrice.compareTo(price) <= 0) {
                        oldPrice = price.multiply(new BigDecimal("1.20"));
                    }
                    p.setOldPrice(oldPrice);

                    if (oldPrice.compareTo(price) > 0) {
                        int discount = oldPrice.subtract(price).multiply(new BigDecimal("100")).divide(oldPrice, 0, java.math.RoundingMode.HALF_UP).intValue();
                        p.setDiscountPercent(discount);
                    } else {
                        p.setDiscountPercent(0);
                    }

                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock);
                    p.setInStock(totalStock > 0);

                    String unit = rs.getString("unit");
                    p.setUnit((unit != null && !unit.trim().isEmpty()) ? unit.toUpperCase() : "KG");

                    // Mock rating & review count for aesthetic consistency
                    double computedRating = 4.7 + ((id % 4) * 0.1);
                    int computedReviews = 40 + (int)(id * 17 % 160);
                    p.setRating(Math.round(computedRating * 10.0) / 10.0);
                    p.setReviewsCount(computedReviews);

                    // Badge tag determination
                    String cert = rs.getString("certification");
                    if (cert != null && cert.toLowerCase().contains("organic")) {
                        p.setTag("HỮU CƠ");
                    } else if (p.getDiscountPercent() >= 18) {
                        p.setTag("-" + p.getDiscountPercent() + "%");
                    } else if (id % 3 == 0) {
                        p.setTag("ĐỊA PHƯƠNG");
                    } else if (id % 4 == 0) {
                        p.setTag("NGỌT THANH");
                    } else {
                        p.setTag("MỚI HÁI");
                    }

                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void buildCatalogFilterSql(StringBuilder sql, List<Object> params, String keyword, String[] categories, Double minPrice, Double maxPrice, Integer rating, String availability, String origin, String tag) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.origin LIKE ? OR p.description LIKE ?)");
            String k = "%" + keyword.trim() + "%";
            params.add(k);
            params.add(k);
            params.add(k);
        }

        if (categories != null && categories.length > 0) {
            sql.append(" AND p.category_id IN (");
            for (int i = 0; i < categories.length; i++) {
                sql.append(i > 0 ? ",?" : "?");
                params.add(Integer.parseInt(categories[i]));
            }
            sql.append(")");
        }

        if (minPrice != null && minPrice > 0) {
            sql.append(" AND pv.price >= ?");
            params.add(minPrice);
        }

        if (maxPrice != null && maxPrice > 0) {
            sql.append(" AND pv.price <= ?");
            params.add(maxPrice);
        }

        if (origin != null && !origin.trim().isEmpty()) {
            sql.append(" AND p.origin LIKE ?");
            params.add("%" + origin.trim() + "%");
        }

        if ("in_stock".equalsIgnoreCase(availability)) {
            sql.append(" AND pv.stock_quantity > 0");
        }

        if (tag != null && !tag.trim().isEmpty()) {
            if ("organic".equalsIgnoreCase(tag)) {
                sql.append(" AND (p.certification LIKE '%Organic%' OR p.name LIKE '%Organic%')");
            } else if ("sale".equalsIgnoreCase(tag)) {
                sql.append(" AND pv.original_price > pv.price");
            } else if ("under5".equalsIgnoreCase(tag)) {
                sql.append(" AND pv.price <= 50000");
            }
        }
    }

    public Product getProductById(long productId) {
        String sql = "SELECT p.product_id, p.name, p.origin, p.certification, p.description, p.storage_temp, "
                   + "       p.category_id, c.category_name, "
                   + "       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC) AS image_url, "
                   + "       MIN(pv.price) AS min_price, "
                   + "       MAX(pv.original_price) AS max_old_price, "
                   + "       SUM(ISNULL(pv.stock_quantity, 0)) AS total_stock, "
                   + "       (SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY price ASC) AS unit "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                   + "WHERE p.product_id = ? "
                   + "GROUP BY p.product_id, p.name, p.origin, p.certification, p.description, p.storage_temp, p.category_id, c.category_name";

        Product p = null;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setName(rs.getString("name"));
                    p.setOrigin(rs.getString("origin"));
                    p.setCertification(rs.getString("certification"));
                    p.setDescription(rs.getString("description"));
                    p.setStorageTemp(rs.getString("storage_temp"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800&auto=format&fit=crop";
                    }
                    p.setImage(img);

                    BigDecimal price = rs.getBigDecimal("min_price");
                    if (price == null) {
                        price = new BigDecimal("3.49");
                    }
                    p.setPrice(price);

                    BigDecimal oldPrice = rs.getBigDecimal("max_old_price");
                    if (oldPrice == null || oldPrice.compareTo(price) <= 0) {
                        oldPrice = price.multiply(new BigDecimal("1.21"));
                    }
                    p.setOldPrice(oldPrice);

                    if (oldPrice.compareTo(price) > 0) {
                        int discount = oldPrice.subtract(price).multiply(new BigDecimal("100")).divide(oldPrice, 0, java.math.RoundingMode.HALF_UP).intValue();
                        p.setDiscountPercent(discount);
                    }

                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock);
                    p.setInStock(totalStock > 0);

                    String unit = rs.getString("unit");
                    p.setUnit((unit != null && !unit.trim().isEmpty()) ? unit : "lb");

                    p.setRating(4.9);
                    p.setReviewsCount(128);
                    p.setTag("-17% SALE");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (p != null) {
            // Lấy danh sách ảnh phụ
            p.setImages(getProductImages(productId, p.getImage()));
            // Lấy danh sách biến thể đóng gói (1lb, 3lb Bag, 5lb Family Box)
            p.setVariants(getProductVariants(productId));
        }
        return p;
    }

    public List<String> getProductImages(long productId, String mainImage) {
        List<String> list = new ArrayList<>();
        if (mainImage != null) {
            list.add(mainImage);
        }
        String sql = "SELECT image_url FROM product_images WHERE product_id = ? ORDER BY display_order ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String img = rs.getString("image_url");
                    if (img != null && !list.contains(img)) {
                        list.add(img);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Bổ sung ảnh gallery demo chất lượng cao nếu chưa đủ 4 ảnh
        String[] demoGallery = new String[]{
            "https://images.unsplash.com/photo-1579613832125-5d34a13ffe0a?w=400&fit=crop",
            "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&fit=crop",
            "https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&fit=crop",
            "https://images.unsplash.com/photo-1590005354167-6da97870c757?w=400&fit=crop"
        };
        for (String g : demoGallery) {
            if (list.size() < 4 && !list.contains(g)) {
                list.add(g);
            }
        }
        return list;
    }

    public List<ProductVariant> getProductVariants(long productId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT variant_id, sku, variant_name, price, original_price, stock_quantity, unit "
                   + "FROM product_variants WHERE product_id = ? AND is_active = 1 ORDER BY price ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getDouble("price"));
                    v.setOriginalPrice(rs.getDouble("original_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));
                    list.add(v);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Nếu database chưa tạo biến thể cho sản phẩm này, tạo 3 phiên bản mặc định chuẩn (1kg, Túi 3kg, Thùng 5kg)
        if (list.isEmpty()) {
            ProductVariant v1 = new ProductVariant();
            v1.setVariantId(1);
            v1.setVariantName("1 kg");
            v1.setPrice(75000.0);
            v1.setOriginalPrice(90000.0);
            v1.setUnit("kg");
            list.add(v1);

            ProductVariant v2 = new ProductVariant();
            v2.setVariantId(2);
            v2.setVariantName("Túi 3 kg [Bán Chạy]");
            v2.setPrice(210000.0);
            v2.setOriginalPrice(260000.0);
            v2.setUnit("túi");
            list.add(v2);

            ProductVariant v3 = new ProductVariant();
            v3.setVariantId(3);
            v3.setVariantName("Thùng 5 kg Gia Đình");
            v3.setPrice(340000.0);
            v3.setOriginalPrice(420000.0);
            v3.setUnit("thùng");
            list.add(v3);
        }
        return list;
    }

    public List<Product> getRelatedProducts(long currentProductId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.product_id, p.name, p.origin, p.certification, "
                   + "       c.category_name, "
                   + "       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, display_order ASC) AS image_url, "
                   + "       MIN(pv.price) AS min_price, "
                   + "       (SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1 ORDER BY price ASC) AS unit "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id AND pv.is_active = 1 "
                   + "WHERE p.is_active = 1 AND p.product_id != ? "
                   + "GROUP BY p.product_id, p.name, p.origin, p.certification, c.category_name, p.created_at "
                   + "ORDER BY p.product_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setLong(2, currentProductId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    long id = rs.getLong("product_id");
                    p.setId(id);
                    p.setName(rs.getString("name"));
                    p.setOrigin(rs.getString("origin") != null ? rs.getString("origin") : "Đà Lạt, Lâm Đồng");
                    p.setCategoryName(rs.getString("category_name"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1546548970-71785318a17b?w=400&fit=crop";
                    }
                    p.setImage(img);

                    BigDecimal price = rs.getBigDecimal("min_price");
                    p.setPrice(price != null ? price : new BigDecimal("75000"));

                    String unit = rs.getString("unit");
                    p.setUnit(unit != null ? unit : "kg");

                    if (id % 2 == 0) {
                        p.setTag("HỮU CƠ");
                    } else if (id % 3 == 0) {
                        p.setTag("TẠI VƯỜN");
                    } else {
                        p.setTag("BÁN CHẠY");
                    }
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
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