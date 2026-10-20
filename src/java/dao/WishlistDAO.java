package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Product;
import util.DBContext;

/**
 * Truy cập bảng wishlists (danh sách sản phẩm yêu thích của khách hàng).
 * Các hàm ném RuntimeException khi lỗi DB để tầng trên quyết định cách báo lỗi.
 */
public class WishlistDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(WishlistDAO.class.getName());

    private static final String DEFAULT_IMAGE
            = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop";

    private Connection openConnection() throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối cơ sở dữ liệu");
        }
        return conn;
    }

    private RuntimeException failure(String action, SQLException ex) {
        LOGGER.log(Level.SEVERE, "Wishlist - lỗi khi " + action, ex);
        return new IllegalStateException("Lỗi cơ sở dữ liệu khi " + action, ex);
    }

    /** Sản phẩm đã có trong wishlist của user chưa? */
    public boolean exists(long userId, long productId) {
        String sql = "SELECT 1 FROM wishlists WHERE user_id = ? AND product_id = ?";
        try (Connection conn = openConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            throw failure("kiểm tra yêu thích", ex);
        }
    }

    /**
     * Thêm sản phẩm vào wishlist.
     *
     * @return true nếu sản phẩm đang nằm trong wishlist sau khi gọi (thêm mới
     * hoặc đã có sẵn); false nếu sản phẩm không tồn tại / đã ngừng bán.
     */
    public boolean add(long userId, long productId) {
        String sql = "IF NOT EXISTS (SELECT 1 FROM wishlists WHERE user_id = ? AND product_id = ?) "
                + "INSERT INTO wishlists (user_id, product_id) "
                + "SELECT ?, p.product_id FROM products p WHERE p.product_id = ? AND p.is_active = 1";
        try (Connection conn = openConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, productId);
            ps.setLong(3, userId);
            ps.setLong(4, productId);
            if (ps.executeUpdate() > 0) {
                return true;
            }
        } catch (SQLException ex) {
            // 2627 / 2601: trùng khóa UNIQUE (bấm 2 lần cùng lúc) -> coi như đã có trong danh sách
            if (ex.getErrorCode() == 2627 || ex.getErrorCode() == 2601) {
                return true;
            }
            throw failure("thêm vào yêu thích", ex);
        }
        // Không chèn được dòng nào: hoặc đã có sẵn, hoặc sản phẩm không hợp lệ
        return exists(userId, productId);
    }

    /** Xóa sản phẩm khỏi wishlist. @return true nếu có xóa được dòng nào. */
    public boolean remove(long userId, long productId) {
        String sql = "DELETE FROM wishlists WHERE user_id = ? AND product_id = ?";
        try (Connection conn = openConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            throw failure("xóa khỏi yêu thích", ex);
        }
    }

    /** Tập id sản phẩm (đang bán) mà user đã thích - dùng để tô sáng trái tim ở trang chủ. */
    public Set<Long> getProductIds(long userId) {
        String sql = "SELECT w.product_id FROM wishlists w "
                + "JOIN products p ON p.product_id = w.product_id AND p.is_active = 1 "
                + "WHERE w.user_id = ?";
        Set<Long> ids = new LinkedHashSet<>();
        try (Connection conn = openConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getLong(1));
                }
            }
        } catch (SQLException ex) {
            throw failure("tải danh sách yêu thích", ex);
        }
        return ids;
    }

    /** Số sản phẩm (đang bán) trong wishlist - hiện trên badge của nút trái tim nổi. */
    public int count(long userId) {
        String sql = "SELECT COUNT(*) FROM wishlists w "
                + "JOIN products p ON p.product_id = w.product_id AND p.is_active = 1 "
                + "WHERE w.user_id = ?";
        try (Connection conn = openConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException ex) {
            throw failure("đếm yêu thích", ex);
        }
    }

    /** Danh sách sản phẩm yêu thích (mới thêm nằm trên cùng), cùng định dạng dữ liệu với trang chủ. */
    public List<Product> getProducts(long userId) {
        String sql = "SELECT p.product_id, p.name, p.category_id, c.category_name, p.origin, "
                + "pi.image_url, dv.variant_id AS default_variant_id, "
                + "(SELECT MIN(price) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS price, "
                + "(SELECT TOP 1 unit FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS unit, "
                + "(SELECT SUM(stock_quantity) FROM product_variants WHERE product_id = p.product_id AND is_active = 1) AS total_stock "
                + "FROM wishlists w "
                + "JOIN products p ON p.product_id = w.product_id AND p.is_active = 1 "
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
                + "WHERE w.user_id = ? "
                + "ORDER BY w.created_at DESC, w.wishlist_id DESC";

        List<Product> list = new ArrayList<>();
        try (Connection conn = openConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String categoryName = rs.getString("category_name");
                    if (categoryName == null) {
                        categoryName = "Trái Cây Tươi";
                    }
                    String image = rs.getString("image_url");
                    if (image == null || image.isEmpty()) {
                        image = DEFAULT_IMAGE;
                    }
                    BigDecimal price = rs.getBigDecimal("price");
                    if (price == null) {
                        price = BigDecimal.ZERO;
                    }

                    Product p = new Product(rs.getLong("product_id"), rs.getString("name"),
                            categoryName, image, price, price, 0, 0, 0);
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setOrigin(rs.getString("origin"));
                    p.setDefaultVariantId(rs.getLong("default_variant_id"));
                    p.setUnit(rs.getString("unit"));
                    int totalStock = rs.getInt("total_stock");
                    p.setStockQuantity(totalStock);
                    p.setInStock(totalStock > 0);
                    list.add(p);
                }
            }
        } catch (SQLException ex) {
            throw failure("tải sản phẩm yêu thích", ex);
        }
        return list;
    }
}
