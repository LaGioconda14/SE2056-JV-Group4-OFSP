package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Cart;
import model.CartItem;
import model.Product;
import model.ProductVariant;
import util.DBContext;

public class CartDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CartDAO.class.getName());

    public Cart getCartByCustomerId(long customerId) {
        String sqlSelect = "SELECT cart_id FROM carts WITH (UPDLOCK, HOLDLOCK) WHERE customer_id = ?";
        String sqlInsert = "INSERT INTO carts (customer_id) VALUES (?)";
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                Cart cart = null;
                try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                    ps.setLong(1, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            cart = new Cart(rs.getLong("cart_id"), customerId);
                        }
                    }
                }
                if (cart == null) {
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setLong(1, customerId);
                        if (ps.executeUpdate() != 1) {
                            throw new SQLException("Cart insert affected an unexpected number of rows");
                        }
                        try (ResultSet keys = ps.getGeneratedKeys()) {
                            if (!keys.next()) {
                                throw new SQLException("Cart insert did not return a generated key");
                            }
                            cart = new Cart(keys.getLong(1), customerId);
                        }
                    }
                }
                conn.commit();
                return cart;
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public List<CartItem> getCartItems(long cartId) {
        String sql = "SELECT ci.cart_item_id, ci.quantity, "
                + "pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "p.product_id, p.shop_id, p.name AS product_name, p.origin, p.is_active AS product_active, "
                + "(SELECT TOP 1 pi2.image_url FROM product_images pi2 "
                + " WHERE pi2.product_id = p.product_id AND pi2.is_thumbnail = 1 "
                + " ORDER BY pi2.display_order) AS thumbnail_url "
                + "FROM cart_items ci "
                + "INNER JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "INNER JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.cart_id = ? ORDER BY ci.created_at DESC";
        List<CartItem> items = new ArrayList<>();
        try (Connection conn = requireConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemID(rs.getLong("cart_item_id"));
                    item.setVariant(mapVariant(rs));
                    item.getVariant().getProduct().setThumbnailUrl(rs.getString("thumbnail_url"));
                    item.setQuantity(rs.getInt("quantity"));
                    items.add(item);
                }
            }
            return items;
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public ProductVariant findAvailableVariant(long variantId) {
        try (Connection conn = requireConnection()) {
            return findAvailableVariant(conn, variantId);
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    private ProductVariant findAvailableVariant(Connection conn, long variantId) throws SQLException {
        String sql = "SELECT pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "p.product_id, p.shop_id, p.name AS product_name, p.origin, p.is_active AS product_active "
                + "FROM product_variants pv WITH (HOLDLOCK) "
                + "INNER JOIN products p WITH (HOLDLOCK) ON pv.product_id = p.product_id "
                + "INNER JOIN shops s WITH (HOLDLOCK) ON p.shop_id = s.shop_id "
                + "WHERE pv.variant_id = ? AND pv.is_active = 1 AND p.is_active = 1 AND s.status = 'ACTIVE'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapVariant(rs) : null;
            }
        }
    }

    public CartItem findCartItem(long cartId, long variantId) {
        try (Connection conn = requireConnection()) {
            return findCartItem(conn, cartId, variantId, false);
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public CartItem findCartItemById(long cartId, long cartItemId) {
        try (Connection conn = requireConnection()) {
            return findCartItem(conn, cartId, cartItemId, true);
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    private CartItem findCartItem(Connection conn, long cartId, long id, boolean byItemId) throws SQLException {
        String sql = "SELECT cart_item_id, variant_id, quantity FROM cart_items WHERE cart_id = ? AND "
                + (byItemId ? "cart_item_id = ?" : "variant_id = ?");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ProductVariant variant = new ProductVariant();
                variant.setVariantId(rs.getLong("variant_id"));
                CartItem item = new CartItem(rs.getLong("cart_item_id"), variant, rs.getInt("quantity"));
                if (rs.next()) {
                    throw new SQLException("Duplicate cart items for a variant");
                }
                return item;
            }
        }
    }

    public boolean addCartItem(long customerId, long cartId, long variantId, int quantity) {
        validateQuantity(quantity);
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                if (!lockCart(conn, customerId, cartId)) {
                    conn.rollback();
                    return false;
                }
                CartItem existing = findCartItem(conn, cartId, variantId, false);
                long total = (existing == null ? 0L : existing.getQuantity()) + quantity;
                validateStock(findAvailableVariant(conn, variantId), total);
                boolean changed;
                if (existing == null) {
                    String sql = "INSERT INTO cart_items (cart_id, variant_id, quantity) "
                            + "SELECT cart_id, ?, ? FROM carts WHERE cart_id = ? AND customer_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setLong(1, variantId);
                        ps.setInt(2, (int) total);
                        ps.setLong(3, cartId);
                        ps.setLong(4, customerId);
                        changed = ps.executeUpdate() == 1;
                    }
                } else {
                    changed = updateQuantity(conn, customerId, cartId, existing.getCartItemID(), (int) total);
                }
                if (!changed) {
                    throw new SQLException("Cart add affected an unexpected number of rows");
                }
                conn.commit();
                return true;
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public boolean updateCartItemQuantity(long customerId, long cartId, long cartItemId, int quantity) {
        validateQuantity(quantity);
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                if (!lockCart(conn, customerId, cartId)) {
                    conn.rollback();
                    return false;
                }
                CartItem item = findCartItem(conn, cartId, cartItemId, true);
                if (item == null) {
                    conn.rollback();
                    return false;
                }
                validateStock(findAvailableVariant(conn, item.getVariant().getVariantId()), quantity);
                if (!updateQuantity(conn, customerId, cartId, cartItemId, quantity)) {
                    throw new SQLException("Cart update affected an unexpected number of rows");
                }
                conn.commit();
                return true;
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    private boolean updateQuantity(Connection conn, long customerId, long cartId, long cartItemId, int quantity)
            throws SQLException {
        String sql = "UPDATE ci SET quantity = ?, updated_at = GETDATE() FROM cart_items ci "
                + "INNER JOIN carts c ON ci.cart_id = c.cart_id "
                + "WHERE ci.cart_item_id = ? AND ci.cart_id = ? AND c.customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setLong(2, cartItemId);
            ps.setLong(3, cartId);
            ps.setLong(4, customerId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean deleteCartItem(long customerId, long cartId, long cartItemId) {
        String sql = "DELETE ci FROM cart_items ci INNER JOIN carts c ON ci.cart_id = c.cart_id "
                + "WHERE ci.cart_item_id = ? AND ci.cart_id = ? AND c.customer_id = ?";
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                if (!lockCart(conn, customerId, cartId)) {
                    conn.rollback();
                    return false;
                }
                boolean deleted;
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, cartItemId);
                    ps.setLong(2, cartId);
                    ps.setLong(3, customerId);
                    deleted = ps.executeUpdate() == 1;
                }
                conn.commit();
                return deleted;
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public boolean clearCart(long cartId) {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";
        try (Connection conn = requireConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    private boolean lockCart(Connection conn, long customerId, long cartId) throws SQLException {
        String sql = "SELECT cart_id FROM carts WITH (UPDLOCK, HOLDLOCK) WHERE cart_id = ? AND customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void validateQuantity(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0!");
        }
    }

    private void validateStock(ProductVariant variant, long quantity) {
        if (variant == null) {
            throw new IllegalArgumentException("Sản phẩm hiện không khả dụng!");
        }
        if (quantity <= 0 || quantity > variant.getStockQuantity()) {
            throw new IllegalArgumentException("Số lượng vượt quá tồn kho!");
        }
    }

    private Connection requireConnection() throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Cannot establish database connection");
        }
        return conn;
    }

    private void rollback(Connection conn, Exception cause) {
        try {
            conn.rollback();
        } catch (SQLException ex) {
            cause.addSuppressed(ex);
            LOGGER.log(Level.SEVERE, "Cannot roll back cart operation", ex);
        }
    }

    private IllegalStateException databaseFailure(SQLException cause) {
        LOGGER.log(Level.SEVERE, "Cart database operation failed", cause);
        return new IllegalStateException("Không thể xử lý giỏ hàng. Vui lòng thử lại sau!", cause);
    }

    private ProductVariant mapVariant(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getLong("product_id"));
        product.setShopId(rs.getLong("shop_id"));
        product.setName(rs.getString("product_name"));
        product.setOrigin(rs.getString("origin"));
        product.setActive(rs.getBoolean("product_active"));

        ProductVariant variant = new ProductVariant();
        variant.setVariantId(rs.getLong("variant_id"));
        variant.setProduct(product);
        variant.setSku(rs.getString("sku"));
        variant.setVariantName(rs.getString("variant_name"));
        variant.setUnit(rs.getString("unit"));
        variant.setWeightKg(rs.getBigDecimal("weight_kg"));
        variant.setPrice(rs.getBigDecimal("price"));
        variant.setStockQuantity(rs.getInt("stock_quantity"));
        variant.setActive(rs.getBoolean("variant_active"));
        return variant;
    }
}
