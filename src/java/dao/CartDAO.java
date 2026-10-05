/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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

/**
 *
 * @author Admin
 */
public class CartDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CartDAO.class.getName());

    // Get Cart by Customer id (tao moi neu chua co)
    public Cart getCartByCustomerId(long customerId) {
        String sqlSelect = "SELECT cart_id FROM carts WHERE customer_id = ?";
        String sqlInsert = "INSERT INTO carts (customer_id) VALUES (?)";

        Connection conn = getConnection();

        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in getCartByCustomerId");
            return null;
        }
        try (conn) {
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setLong(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Cart cart = new Cart();
                        cart.setCartId(rs.getLong("cart_id"));
                        cart.setCustomerId(customerId);
                        return cart;
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, customerId);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet gk = ps.getGeneratedKeys()) {
                        if (gk.next()) {
                            Cart cart = new Cart();
                            cart.setCartId(gk.getLong(1));
                            cart.setCustomerId(customerId);
                            return cart;
                        }
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getCartByCustomerId for customer: " + customerId, ex);
        }
        return null;
    }

    // get all cart items (+ variant + product)
    public List<CartItem> getCartItems(long cartId) {
        String sql = "SELECT ci.cart_item_id, ci.quantity, "
                + "       pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "       pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "       p.product_id, p.name AS product_name, p.origin, p.is_active AS product_active, "
                + "       (SELECT TOP 1 pi2.image_url FROM product_images pi2 "
                + "        WHERE pi2.product_id = p.product_id AND pi2.is_thumbnail = 1 "
                + "        ORDER BY pi2.display_order) AS thumbnail_url "
                + "FROM cart_items ci "
                + "INNER JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "INNER JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.cart_id = ? "
                + "ORDER BY ci.created_at DESC";
        List<CartItem> items = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in getCartItems");
            return items;
        }
        try (conn;
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToCartItem(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting cart items for cart_id: " + cartId, ex);
        }
        return items;
    }

    // find 1 cart item (kiem tra variant da co trong gio chua)
    public CartItem findCartItem(long cartId, long variantId) {
        String sql = "SELECT cart_item_id, quantity "
                + "FROM cart_items "
                + "WHERE cart_id = ? AND variant_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in findCartItem");
            return null;
        }
        try (conn;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemID(rs.getLong("cart_item_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    return item;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding cart item for cart_id=" + cartId + ", variant_id=" + variantId, ex);
        }

        return null;
    }

    // insert a new item into cart
    public boolean insertCartItem(long cartId, long variantId, int quantity) {
        String sql = "INSERT INTO cart_items (cart_id, variant_id, quantity) "
                + "VALUES (?, ?, ?)";
        Connection conn = getConnection();

        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in insertCartItem");
            return false;
        }
        try (conn;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, variantId);
            ps.setInt(3, quantity);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error inserting cart item: cart_id=" + cartId + ", variant_id=" + variantId, ex);
        }
        return false;
    }

    // update so luong
    public boolean updateCartItemQuantity(long cartItemId, int quantity) {
        String sql = "UPDATE cart_items SET quantity = ?, updated_at = GETDATE() WHERE cart_item_id = ?";
        Connection conn = getConnection();

        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in updateCartItemQuantity");
            return false;
        }
        try (conn;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setLong(2, cartItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating quantity for cart_item_id: " + cartItemId, ex);
        }
        return false;
    }

    // xoa 1 san pham khoi gio
    public boolean deleteCartItem(long cartItemId) {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";
        Connection conn = getConnection();

        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in deleteCartItem");
            return false;
        }
        try (conn;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting cart_item_id: " + cartItemId, ex);
        }
        return false;
    }

    // xoa toan bo gio (sau checkout)
    public boolean clearCart(long cartId) {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";
        Connection conn = getConnection();

        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in clearCart");
            return false;
        }
        try (conn;
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error clearing cart_id: " + cartId, ex);
        }
        return false;
    }

    // map ResultSet -> CartItem (kem Product + Variant)
    private CartItem mapResultSetToCartItem(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getLong("product_id"));
        product.setName(rs.getString("product_name"));
        product.setOrigin(rs.getString("origin"));
        product.setActive(rs.getBoolean("product_active"));
        product.setThumbnailUrl(rs.getString("thumbnail_url"));

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

        CartItem item = new CartItem();
        item.setCartItemID(rs.getLong("cart_item_id"));
        item.setVariant(variant);
        item.setQuantity(rs.getInt("quantity"));

        return item;
    }
}
