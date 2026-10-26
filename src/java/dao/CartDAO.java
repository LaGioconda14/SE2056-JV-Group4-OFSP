package dao;

import enums.CartItemAvailability;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import model.Cart;
import model.CartItem;
import model.CartMutationResult;
import model.Product;
import model.ProductVariant;
import util.DBContext;

public class CartDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CartDAO.class.getName());

    public Cart findOrCreateCartByCustomerId(long customerId) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                Cart cart = findOrCreateCart(conn, customerId);
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

    public int countItemsByCustomerId(long customerId) {
        String sql = "SELECT COUNT(ci.cart_item_id) AS item_count "
                + "FROM carts c LEFT JOIN cart_items ci ON ci.cart_id = c.cart_id "
                + "WHERE c.customer_id = ?";
        try (Connection conn = requireConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("item_count") : 0;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public List<CartItem> loadAndReconcileItems(long cartId) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                // Khóa các dòng trong lúc đối chiếu để quantity trả về luôn khớp với dữ liệu đã commit.
                List<CartItem> items = loadItemsForReconciliation(conn, cartId);
                for (CartItem item : items) {
                    if (item.isQuantityAdjusted()
                            && !updateQuantityByCart(conn, cartId, item.getCartItemId(), item.getQuantity())) {
                        throw new SQLException("Cart quantity reconciliation failed");
                    }
                }
                attachAlternativeVariants(conn, items);
                conn.commit();
                items.sort(Comparator.comparing(CartItem::getAvailability));
                return items;
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public CartMutationResult addCartItem(long customerId, long variantId, int quantity) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                Cart cart = findOrCreateCart(conn, customerId);
                CartItem existing = findItemByVariantId(conn, cart.getCartId(), variantId);
                long requestedQuantity = (existing == null ? 0L : existing.getQuantity()) + quantity;
                ProductVariant variant = findAvailableVariant(conn, variantId);
                validateStock(variant, requestedQuantity);

                long cartItemId;
                if (existing == null) {
                    cartItemId = insertItem(conn, cart.getCartId(), variantId, (int) requestedQuantity);
                } else {
                    cartItemId = existing.getCartItemId();
                    if (!updateQuantityByCart(conn, cart.getCartId(), cartItemId, (int) requestedQuantity)) {
                        throw new SQLException("Cart add update affected an unexpected number of rows");
                    }
                }
                int cartItemCount = countItemsByCartId(conn, cart.getCartId());
                conn.commit();
                return new CartMutationResult(
                        new CartItem(cartItemId, variant, (int) requestedQuantity), cartItemCount);
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public void updateCartItemQuantity(long customerId, long cartItemId, int quantity) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                long cartId = requireOwnedCart(conn, customerId);
                CartItem item = findItemById(conn, cartId, cartItemId);
                if (item == null) {
                    throw itemNotFound();
                }
                validateStock(findAvailableVariant(conn, item.getVariant().getVariantId()), quantity);
                if (!updateQuantityByCart(conn, cartId, cartItemId, quantity)) {
                    throw new SQLException("Cart update affected an unexpected number of rows");
                }
                conn.commit();
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public void deleteCartItem(long customerId, long cartItemId) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                long cartId = requireOwnedCart(conn, customerId);
                if (!deleteItemByCart(conn, cartId, cartItemId)) {
                    throw itemNotFound();
                }
                conn.commit();
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    public void changeCartItemVariant(long customerId, long cartItemId, long newVariantId) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                long cartId = requireOwnedCart(conn, customerId);
                CartItem current = findItemById(conn, cartId, cartItemId);
                if (current == null) {
                    throw itemNotFound();
                }

                ProductVariant currentVariant = findVariantIncludingUnavailable(conn,
                        current.getVariant().getVariantId());
                ProductVariant newVariant = findAvailableVariant(conn, newVariantId);
                if (currentVariant == null || newVariant == null
                        || currentVariant.getProduct().getProductId()
                        != newVariant.getProduct().getProductId()) {
                    throw new IllegalArgumentException("Biến thể thay thế không hợp lệ!");
                }
                if (current.getVariant().getVariantId() == newVariantId) {
                    conn.commit();
                    return;
                }

                CartItem target = findItemByVariantId(conn, cartId, newVariantId);
                long combinedQuantity = current.getQuantity()
                        + (target != null ? target.getQuantity() : 0L);
                int finalQuantity = (int) Math.min(combinedQuantity,
                        (long) newVariant.getStockQuantity());
                if (finalQuantity <= 0) {
                    throw new IllegalArgumentException("Biến thể thay thế đã hết hàng!");
                }

                if (target != null && target.getCartItemId() != cartItemId) {
                    // Hai dòng cùng biến thể không được tồn tại; gộp số lượng rồi xóa dòng nguồn trong cùng transaction.
                    if (!updateQuantityByCart(conn, cartId, target.getCartItemId(), finalQuantity)
                            || !deleteItemByCart(conn, cartId, cartItemId)) {
                        throw new SQLException("Cart variant merge failed");
                    }
                } else {
                    updateVariant(conn, cartId, cartItemId, newVariantId, finalQuantity);
                }
                conn.commit();
            } catch (SQLException | RuntimeException ex) {
                rollback(conn, ex);
                throw ex;
            }
        } catch (SQLException ex) {
            throw databaseFailure(ex);
        }
    }

    private Cart findOrCreateCart(Connection conn, long customerId) throws SQLException {
        // HOLDLOCK bảo đảm hai request đồng thời không cùng tạo cart cho một khách hàng.
        String selectSql = "SELECT cart_id FROM carts WITH (UPDLOCK, HOLDLOCK) WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Cart(rs.getLong("cart_id"), customerId);
                }
            }
        }

        String insertSql = "INSERT INTO carts (customer_id) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, customerId);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Cart insert affected an unexpected number of rows");
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Cart insert did not return a generated key");
                }
                return new Cart(keys.getLong(1), customerId);
            }
        }
    }

    private long requireOwnedCart(Connection conn, long customerId) throws SQLException {
        // Mutation khóa cart theo owner để item không thể bị sửa qua customer khác.
        String sql = "SELECT cart_id FROM carts WITH (UPDLOCK, HOLDLOCK) WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("Giỏ hàng không tồn tại!");
                }
                return rs.getLong("cart_id");
            }
        }
    }

    private List<CartItem> loadItemsForReconciliation(Connection conn, long cartId) throws SQLException {
        String sql = "SELECT ci.cart_item_id, ci.quantity, "
                + "pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "p.product_id, p.shop_id, p.name AS product_name, p.origin, p.is_active AS product_active, "
                + "s.shop_name, s.status AS shop_status, "
                + "(SELECT COUNT(*) FROM product_variants pv2 WHERE pv2.product_id = p.product_id "
                + "AND pv2.is_active = 1 AND pv2.stock_quantity > 0) AS available_variant_count, "
                + "(SELECT TOP 1 pi2.image_url FROM product_images pi2 WHERE pi2.product_id = p.product_id "
                + "AND pi2.is_thumbnail = 1 ORDER BY pi2.display_order) AS thumbnail_url "
                + "FROM cart_items ci WITH (UPDLOCK, HOLDLOCK) "
                + "INNER JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "INNER JOIN products p ON pv.product_id = p.product_id "
                + "INNER JOIN shops s ON p.shop_id = s.shop_id "
                + "WHERE ci.cart_id = ? ORDER BY ci.created_at DESC";
        List<CartItem> items = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = mapCartItem(rs);
                    determineAvailability(item, rs);
                    items.add(item);
                }
            }
        }
        return items;
    }

    private CartItem mapCartItem(ResultSet rs) throws SQLException {
        CartItem item = new CartItem(rs.getLong("cart_item_id"), mapVariant(rs), rs.getInt("quantity"));
        item.setPreviousQuantity(item.getQuantity());
        item.getVariant().getProduct().setShopName(rs.getString("shop_name"));
        item.getVariant().getProduct().setThumbnailUrl(rs.getString("thumbnail_url"));
        return item;
    }

    private void determineAvailability(CartItem item, ResultSet rs) throws SQLException {
        ProductVariant variant = item.getVariant();
        boolean productAvailable = variant.getProduct().isActive()
                && "ACTIVE".equalsIgnoreCase(rs.getString("shop_status"));
        if (!productAvailable) {
            item.setAvailability(CartItemAvailability.NOT_FOUND);
        } else if (rs.getInt("available_variant_count") == 0) {
            item.setAvailability(CartItemAvailability.SOLD_OUT);
        } else if (!variant.isActive() || variant.getStockQuantity() <= 0) {
            item.setAvailability(CartItemAvailability.VARIANT_UNAVAILABLE);
        } else {
            item.setAvailability(CartItemAvailability.AVAILABLE);
            if (item.getQuantity() > variant.getStockQuantity()) {
                item.setQuantityAdjusted(true);
                item.setQuantity(variant.getStockQuantity());
            }
        }
    }

    private void attachAlternativeVariants(Connection conn, List<CartItem> items) throws SQLException {
        List<Long> productIds = items.stream()
                .filter(item -> item.getAvailability() != CartItemAvailability.NOT_FOUND)
                .map(item -> item.getVariant().getProduct().getProductId())
                .distinct()
                .toList();
        if (productIds.isEmpty()) {
            return;
        }
        Map<Long, List<ProductVariant>> variantsByProduct = findVariantsByProductIds(conn, productIds);
        for (CartItem item : items) {
            long currentVariantId = item.getVariant().getVariantId();
            List<ProductVariant> alternatives = variantsByProduct
                    .getOrDefault(item.getVariant().getProduct().getProductId(), List.of())
                    .stream()
                    .filter(variant -> variant.getVariantId() != currentVariantId)
                    .collect(Collectors.toCollection(ArrayList::new));
            item.setAlternativeVariants(alternatives);
        }
    }

    private Map<Long, List<ProductVariant>> findVariantsByProductIds(Connection conn,
            Collection<Long> productIds) throws SQLException {
        String placeholders = productIds.stream().map(id -> "?").collect(Collectors.joining(","));
        String sql = "SELECT pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "p.product_id, p.shop_id, p.name AS product_name, p.origin, p.is_active AS product_active "
                + "FROM product_variants pv INNER JOIN products p ON p.product_id = pv.product_id "
                + "INNER JOIN shops s ON s.shop_id = p.shop_id "
                + "WHERE pv.product_id IN (" + placeholders + ") "
                + "AND p.is_active = 1 AND s.status = 'ACTIVE' "
                + "ORDER BY p.product_id, CASE WHEN pv.is_active = 1 AND pv.stock_quantity > 0 THEN 0 ELSE 1 END, pv.price";
        Map<Long, List<ProductVariant>> result = new LinkedHashMap<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            for (Long productId : productIds) {
                ps.setLong(index++, productId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant variant = mapVariant(rs);
                    result.computeIfAbsent(variant.getProduct().getProductId(), key -> new ArrayList<>())
                            .add(variant);
                }
            }
        }
        return result;
    }

    private ProductVariant findAvailableVariant(Connection conn, long variantId) throws SQLException {
        String sql = "SELECT pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "p.product_id, p.shop_id, p.name AS product_name, p.origin, p.is_active AS product_active "
                + "FROM product_variants pv WITH (UPDLOCK, HOLDLOCK) "
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

    private ProductVariant findVariantIncludingUnavailable(Connection conn, long variantId) throws SQLException {
        String sql = "SELECT pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "p.product_id, p.shop_id, p.name AS product_name, p.origin, p.is_active AS product_active "
                + "FROM product_variants pv INNER JOIN products p ON p.product_id = pv.product_id "
                + "WHERE pv.variant_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapVariant(rs) : null;
            }
        }
    }

    private CartItem findItemById(Connection conn, long cartId, long cartItemId) throws SQLException {
        return findSingleItem(conn,
                "SELECT cart_item_id, variant_id, quantity FROM cart_items WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE cart_id = ? AND cart_item_id = ?", cartId, cartItemId);
    }

    private CartItem findItemByVariantId(Connection conn, long cartId, long variantId) throws SQLException {
        return findSingleItem(conn,
                "SELECT cart_item_id, variant_id, quantity FROM cart_items WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE cart_id = ? AND variant_id = ?", cartId, variantId);
    }

    private CartItem findSingleItem(Connection conn, String sql, long cartId, long id) throws SQLException {
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
                    throw new SQLException("Duplicate cart items for lookup");
                }
                return item;
            }
        }
    }

    private long insertItem(Connection conn, long cartId, long variantId, int quantity) throws SQLException {
        String sql = "INSERT INTO cart_items (cart_id, variant_id, quantity) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, cartId);
            ps.setLong(2, variantId);
            ps.setInt(3, quantity);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Cart item insert affected an unexpected number of rows");
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Cart item insert did not return a generated key");
                }
                return keys.getLong(1);
            }
        }
    }

    private int countItemsByCartId(Connection conn, long cartId) throws SQLException {
        String sql = "SELECT COUNT(*) AS item_count FROM cart_items WHERE cart_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("Cart item count returned no row");
                }
                return rs.getInt("item_count");
            }
        }
    }

    private boolean updateQuantityByCart(Connection conn, long cartId, long cartItemId,
            int quantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ?, updated_at = GETDATE() "
                + "WHERE cart_id = ? AND cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setLong(2, cartId);
            ps.setLong(3, cartItemId);
            return ps.executeUpdate() == 1;
        }
    }

    private boolean deleteItemByCart(Connection conn, long cartId, long cartItemId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_id = ? AND cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, cartItemId);
            return ps.executeUpdate() == 1;
        }
    }

    private void updateVariant(Connection conn, long cartId, long cartItemId,
            long variantId, int quantity) throws SQLException {
        String sql = "UPDATE cart_items SET variant_id = ?, quantity = ?, updated_at = GETDATE() "
                + "WHERE cart_id = ? AND cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            ps.setInt(2, quantity);
            ps.setLong(3, cartId);
            ps.setLong(4, cartItemId);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Cart variant update failed");
            }
        }
    }

    private void validateStock(ProductVariant variant, long quantity) {
        if (variant == null) {
            throw new IllegalArgumentException("Sản phẩm hiện không khả dụng!");
        }
        if (quantity > variant.getStockQuantity()) {
            throw new IllegalArgumentException("Số lượng vượt quá tồn kho!");
        }
    }

    private IllegalArgumentException itemNotFound() {
        return new IllegalArgumentException("Sản phẩm không có trong giỏ hàng!");
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
        return new IllegalStateException(
                "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!", cause);
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
