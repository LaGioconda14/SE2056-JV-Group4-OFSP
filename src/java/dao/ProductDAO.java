package dao;

import util.DBContext; // Thay đổi theo class kết nối JDBC của bạn
import model.Product;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import util.DBContext;

public class ProductDAO extends DBContext {

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        // Câu lệnh truy vấn khớp với cấu trúc bảng trong SQL script[cite: 9]
        String query = "SELECT p.product_id, p.name, c.category_name, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.is_active = 1";

        try {
            Connection conn = new DBContext().getConnection();
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

                // Giả lập giá cũ và % giảm để hiển thị đẹp trên giao diện
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

    public List<Product> getTop8Productsll() {
        List<Product> list = new ArrayList<>();
        String query = "SELECT TOP 8 p.product_id, p.name, c.category_name, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.is_active = 1 "
                + "ORDER BY p.product_id DESC";

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                long id = rs.getLong("product_id");
                String name = rs.getString("name");
                String categoryName = rs.getString("category_name");

                // Sửa thành nháy kép ("") ở đây:
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
            Connection conn = new DBContext().getConnection();
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

    //=========================Thanh tìm kiếm & Bộ lọc==========================================================
    public List<Product> searchByFilter(String txtSearch, String categoryId, Double minPrice, Double maxPrice, Integer rating) {
        List<Product> list = new ArrayList<>();

        // Xây dựng câu lệnh SQL khớp với cấu trúc bảng normalized (giống getAllProducts)
        StringBuilder query = new StringBuilder("SELECT p.product_id, p.name, c.category_name, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_thumbnail = 1) AS image_url, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "WHERE p.is_active = 1");

        // Thêm các điều kiện lọc động
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
            Connection conn = new DBContext().getConnection();
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

                // Giả lập giá cũ và % giảm giống các hàm khác
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
}
