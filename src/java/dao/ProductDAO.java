package dao;

import java.lang.System.Logger;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.*;
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
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
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
        String queryParents = "SELECT category_id, category_name, slug, image_url, display_order "
                + "FROM categories "
                + "WHERE category_id IN (5, 6, 7, 8, 9) "
                + "ORDER BY display_order ASC";
        
        String querySubs = "SELECT category_id, parent_id, category_name, slug, display_order "
                + "FROM categories "
                + "WHERE parent_id IN (5, 6) AND is_active = 1 "
                + "ORDER BY display_order ASC";
        
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(queryParents);
                 ResultSet rs = ps.executeQuery()) {
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

            try (PreparedStatement ps = conn.prepareStatement(querySubs);
                 ResultSet rs = ps.executeQuery()) {
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

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

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

    public List<Product> getTop8Products() {
        return getHomeProducts();
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
            query.append(" AND (p.name COLLATE SQL_Latin1_General_CP1_CI_AI LIKE ? OR p.name LIKE ?)");
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
                String searchPattern = "%" + txtSearch.trim() + "%";
                ps.setString(index++, searchPattern);
                ps.setString(index++, searchPattern);
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
                Category cat = new Category(
                    rs.getInt("category_id"),
                    rs.getString("category_name"),
                    rs.getString("slug"),
                    rs.getInt("product_count")
                );
                cat.setImageUrl(rs.getString("image_url"));
                cat.setIconClass(rs.getString("icon_class"));
                list.add(cat);
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
            List<String> validCats = new ArrayList<>();
            for (String cat : categories) {
                if (cat != null && !cat.trim().isEmpty()) {
                    validCats.add(cat.trim());
                }
            }
            if (!validCats.isEmpty()) {
                sql.append(" AND (");
                for (int i = 0; i < validCats.size(); i++) {
                    if (i > 0) {
                        sql.append(" OR ");
                    }
                    sql.append("(c.slug = ? OR CAST(c.category_id AS VARCHAR(50)) = ? OR c.parent_id IN (SELECT category_id FROM categories WHERE slug = ? OR CAST(category_id AS VARCHAR(50)) = ?))");
                    String catVal = validCats.get(i);
                    params.add(catVal);
                    params.add(catVal);
                    params.add(catVal);
                    params.add(catVal);
                }
                sql.append(")");
            }
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
        String sql = "SELECT p.product_id, p.shop_id, p.name, p.origin, p.certification, p.description, p.storage_temp, "
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
                   + "GROUP BY p.product_id, p.shop_id, p.name, p.origin, p.certification, p.description, p.storage_temp, p.category_id, c.category_name";

        Product p = null;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setShopId(rs.getLong("shop_id"));
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
    //Lấy ra list sản phẩm 
    public List<ProductVariant> getVariantsByShopId(long shopId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT "
                   + "    pv.variant_id, "
                   + "    pv.product_id, "
                   + "    pv.sku, "
                   + "    pv.variant_name, "
                   + "    pv.price, "
                   + "    pv.original_price, "
                   + "    pv.stock_quantity, "
                   + "    pv.unit, "
                   + "    COALESCE(pi.image_url, (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, image_id ASC)) AS image_url, "
                   + "    pv.is_active, "
                   + "    p.name AS product_name, "
                   + "    p.origin, "
                   + "    c.category_name, "
                   + "    p.certification, "
                   + "    (SELECT COUNT(*) FROM product_variants WHERE product_id = p.product_id) AS total_variants_count "
                   + "FROM product_variants pv "
                   + "JOIN products p ON pv.product_id = p.product_id "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                   + "WHERE p.shop_id = ? "
                   + "ORDER BY pv.variant_id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, shopId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductId(rs.getLong("product_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setPrice(rs.getDouble("price"));
                    v.setOriginalPrice(rs.getDouble("original_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setUnit(rs.getString("unit"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-14 64965911861-746a04b4bca6?w=100&h=100&fit=crop";
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

    public List<ProductVariant> getFilteredVariantsByShop(long shopId, String keyword, String categoryId, 
                                                          String certification, String stockLevel, 
                                                          String statusTab, int page, int pageSize) {
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

        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        sql.append(" ORDER BY pv.variant_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
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
                    v.setPrice(rs.getDouble("price"));
                    v.setOriginalPrice(rs.getDouble("original_price"));
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
            e.printStackTrace();
        }

        return count;
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
        if (slug.startsWith("-")) slug = slug.substring(1);
        if (slug.endsWith("-")) slug = slug.substring(0, slug.length() - 1);
        return slug + "-" + (System.currentTimeMillis() % 100000);
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
                    ps.setBoolean(3, true); // thumbnail
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

            // 5. Insert initial batch in product_batches
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
                    v.setPrice(rs.getDouble("price"));
                    v.setOriginalPrice(rs.getDouble("original_price"));
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

                    // Fetch detail images
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

            // 1. Update product
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

            // 2. Update variant
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

            // 3. Update images: clear and re-insert if cover image provided
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

            // 4. Update batch
            try (PreparedStatement psBatch = conn.prepareStatement(sqlUpdateBatch)) {
                psBatch.setInt(1, stockQuantity);
                psBatch.setLong(2, variantId);
                psBatch.executeUpdate();
            } catch (Exception ignored) {}

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách sản phẩm hiển thị trên trang chủ của Shop (Storefront)
     */
    public List<Product> getProductsByShopId(long shopId, Integer categoryId, String sort) {
        List<Product> list = new ArrayList<>();
        StringBuilder query = new StringBuilder(
                "SELECT p.product_id, p.name, p.category_id, c.category_name, p.origin, p.certification, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT TOP 1 weight_kg FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS weight_kg, "
                + "(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.shop_id = ? AND p.is_active = 1 "
        );

        if (categoryId != null && categoryId > 0) {
            query.append("AND p.category_id = ? ");
        }

        if ("price_asc".equalsIgnoreCase(sort)) {
            query.append("ORDER BY (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) ASC");
        } else if ("price_desc".equalsIgnoreCase(sort)) {
            query.append("ORDER BY (SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) DESC");
        } else if ("newest".equalsIgnoreCase(sort)) {
            query.append("ORDER BY p.product_id DESC");
        } else {
            // featured
            query.append("ORDER BY p.product_id ASC");
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(query.toString())) {
            ps.setLong(1, shopId);
            if (categoryId != null && categoryId > 0) {
                ps.setInt(2, categoryId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long id = rs.getLong("product_id");
                    String name = rs.getString("name");
                    int catId = rs.getInt("category_id");
                    String categoryName = rs.getString("category_name");
                    if (categoryName == null) categoryName = "Trái Cây Tươi";

                    String image = rs.getString("image_url");
                    if (image == null || image.isEmpty()) {
                        image = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";
                    }

                    BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = new BigDecimal("120000");
                    }
                    BigDecimal oldPrice = price.multiply(new BigDecimal("1.25"));
                    int discountPercent = 20;

                    Product p = new Product(id, name, categoryName, image, price, oldPrice, discountPercent, 4.9, 128);
                    p.setCategoryId(catId);
                    
                    String origin = rs.getString("origin");
                    p.setOrigin(origin != null ? origin : "Mộc Châu Highlands");

                    String cert = rs.getString("certification");
                    p.setCertification(cert != null ? cert : "VietGAP");
                    p.setTag(cert != null && cert.toLowerCase().contains("organic") ? "Organic" : "VietGAP");

                    String unit = rs.getString("unit");
                    BigDecimal weight = rs.getBigDecimal("weight_kg");
                    if (weight != null && unit != null) {
                        p.setUnit(weight.stripTrailingZeros().toPlainString() + " " + unit + " • Chuẩn Vườn");
                    } else if (unit != null) {
                        p.setUnit("1 " + unit + " • Chuẩn Vườn");
                    } else {
                        p.setUnit("Hộp 500g • Chuẩn Vườn");
                    }

                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh mục các sản phẩm của shop cùng với số lượng sản phẩm của từng danh mục
     */
    public List<Category> getCategoriesWithCountByShopId(long shopId) {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.category_name, c.slug, COUNT(p.product_id) AS product_count "
                   + "FROM products p "
                   + "JOIN categories c ON p.category_id = c.category_id "
                   + "WHERE p.shop_id = ? AND p.is_active = 1 "
                   + "GROUP BY c.category_id, c.category_name, c.slug "
                   + "ORDER BY product_count DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Category cat = new Category();
                    cat.setCategoryId(rs.getInt("category_id"));
                    cat.setCategoryName(rs.getString("category_name"));
                    cat.setSlug(rs.getString("slug"));
                    cat.setProductCount(rs.getInt("product_count"));
                    list.add(cat);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // 1: thêm sản phẩm, trả về product_id vừa tạo
    private long insertProduct(Connection conn, long shopId, String name, int categoryId,
            String origin, String storageTemp, String certification,
            String description, boolean isActive) throws SQLException {

        String sql = "INSERT INTO products (shop_id, category_id, name, slug, origin, storage_temp, "
                + "certification, description, is_active, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, shopId);
            if (categoryId > 0) {
                ps.setInt(2, categoryId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);   // không chọn danh mục -> NULL
            }
            ps.setString(3, name);
            ps.setString(4, generateProductSlug(name));   // slug tự sinh từ tên
            ps.setString(5, valueOrDefault(origin, "Đà Lạt, Lâm Đồng"));
            ps.setString(6, valueOrDefault(storageTemp, "Kho lạnh 2°C - 8°C"));
            ps.setString(7, valueOrDefault(certification, "VietGAP"));
            ps.setString(8, description != null ? description : "");
            ps.setBoolean(9, isActive);
            ps.executeUpdate();

            return getGeneratedId(ps);
        }
    }
    
    // ----------2: thêm biến thể, trả về variant_id vừa tạo ----------
    private long insertVariant(Connection conn, long productId, String sku, String variantName,
                               String unit, BigDecimal price, BigDecimal originalPrice,
                               int stockQuantity, int lowStockThreshold, boolean isActive) throws SQLException {
 
        String sql = "INSERT INTO product_variants (product_id, sku, variant_name, unit, price, "
                   + "original_price, stock_quantity, low_stock_threshold, is_active, created_at, updated_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
 
        BigDecimal finalPrice = (price != null) ? price : BigDecimal.ZERO;
 
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, productId);
            ps.setString(2, makeUniqueSku(sku));
            ps.setString(3, valueOrDefault(variantName, "Tiêu chuẩn"));
            ps.setString(4, valueOrDefault(unit, "Hộp (500g - 1kg)"));
            ps.setBigDecimal(5, finalPrice);
            ps.setBigDecimal(6, originalPrice != null ? originalPrice : finalPrice);
            ps.setInt(7, stockQuantity);
            ps.setInt(8, lowStockThreshold > 0 ? lowStockThreshold : 10);
            ps.setBoolean(9, isActive);
            ps.executeUpdate();
 
            return getGeneratedId(ps);
        }
    }
    
    // ---------- Bước 3: thêm ảnh (1 ảnh bìa + các ảnh chi tiết) ----------
    private void insertImages(Connection conn, long productId, String coverImageUrl,
                              List<String> detailImageUrls) throws SQLException {
 
        String defaultCover = "https://images.unsplash.com/photo-1543528176-61b239494933?w=800&auto=format&fit=crop&q=80";
 
        // Ảnh bìa: thứ tự 1, là thumbnail. Không có ảnh thì dùng ảnh mặc định.
        insertOneImage(conn, productId, valueOrDefault(coverImageUrl, defaultCover), true, 1);
 
        // Ảnh chi tiết: thứ tự từ 2 trở đi, không phải thumbnail
        if (detailImageUrls != null) {
            int order = 2;
            for (String url : detailImageUrls) {
                if (url != null && !url.trim().isEmpty()) {
                    insertOneImage(conn, productId, url.trim(), false, order);
                    order++;
                }
            }
        }
    }
 
    private void insertOneImage(Connection conn, long productId, String url,
                                boolean isThumbnail, int displayOrder) throws SQLException {
        String sql = "INSERT INTO product_images (product_id, image_url, is_thumbnail, display_order, created_at) "
                   + "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setString(2, url);
            ps.setBoolean(3, isThumbnail);
            ps.setInt(4, displayOrder);
            ps.executeUpdate();
        }
    }
    
    // ---------- Bước 4: thêm lô hàng đầu tiên (tồn kho ban đầu) ----------
    private void insertFirstBatch(Connection conn, long productId, long variantId, String origin,
                                  int stockQuantity, BigDecimal originalPrice) throws SQLException {
 
        String sql = "INSERT INTO product_batches (batch_code, variant_id, farm_source, harvest_date, expiry_date, "
                   + "initial_quantity, current_quantity, import_cost, freshness_score, harvest_time_label, "
                   + "freshness_note, batch_type, pending_packing_text, status, created_at, updated_at) "
                   + "VALUES (?, ?, ?, CURRENT_TIMESTAMP, DATEADD(day, 7, CURRENT_TIMESTAMP), ?, ?, ?, 98, "
                   + "N'05:30 Sáng nay', N'Độ tươi 98% (Vừa hái sáng nay)', N'Hái sáng', "
                   + "N'0 Đơn chờ đóng gói', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
 
        // Mã lô dạng: LH-yyMMdd-<chữ cái>, ví dụ LH-261015-C
        String today = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyMMdd"));
        String batchCode = "LH-" + today + "-" + (char) ('A' + (productId % 26));
 
        // Giá nhập tạm tính = 65% giá gốc
        BigDecimal importCost = (originalPrice != null)
                ? originalPrice.multiply(new BigDecimal("0.65"))
                : BigDecimal.ZERO;
 
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, batchCode);
            ps.setLong(2, variantId);
            ps.setString(3, valueOrDefault(origin, "Vườn Đà Lạt"));
            ps.setInt(4, stockQuantity);   // số lượng ban đầu
            ps.setInt(5, stockQuantity);   // số lượng hiện tại (lúc đầu bằng nhau)
            ps.setBigDecimal(6, importCost);
            ps.executeUpdate();
        }
    }
    // ---------- Các hàm phụ dùng chung ----------
 
    // Lấy id do DB tự sinh sau khi INSERT. Không lấy được thì ném lỗi để transaction rollback.
    private long getGeneratedId(PreparedStatement ps) throws SQLException {
        try (ResultSet rs = ps.getGeneratedKeys()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        throw new SQLException("Không lấy được id vừa tạo");
    }
 
    // Chuỗi null hoặc rỗng thì dùng giá trị mặc định, ngược lại cắt khoảng trắng hai đầu
    private String valueOrDefault(String value, String defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }
 
    // Nếu người dùng không nhập SKU hoặc SKU đã tồn tại thì tự sinh SKU mới
    private String makeUniqueSku(String sku) {
        String result = valueOrDefault(sku, "SKU-" + (System.currentTimeMillis() % 1000000));
        int retry = 1;
        while (isSkuExists(result)) {
            result = "SKU-" + (System.currentTimeMillis() % 1000000) + "-" + retry;//SKU-123456-1,2,3,4,5
            retry++;
        }
        return result;
    }
}
