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
import model.entity.cart.Cart;
import model.entity.cart.CartItem;
import model.dto.cart.CartMutationResult;
import model.dto.product.ProductVariantDetailDTO;
import util.DBContext;

/**
 * DAO tương tác với bảng carts và cart_items:
 * - Quản lý giỏ hàng của khách hàng (tạo giỏ, thêm/sửa/xóa sản phẩm).
 * - Tự động đối soát và điều chỉnh số lượng giỏ hàng theo tồn kho thực tế.
 * - Hỗ trợ đổi phân loại (variant) và gợi ý các phân loại thay thế khi hết hàng.
 * - Sử dụng các cơ chế khóa bi quan (UPDLOCK, HOLDLOCK) trong transaction để chống xung đột đồng thời.
 */
public class CartDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CartDAO.class.getName());

    /**
     * Tìm giỏ hàng của khách hàng hoặc tự động tạo mới nếu chưa có.
     *
     * @param customerId ID khách hàng
     * @return đối tượng Cart chứa cartId và customerId
     */
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

    /**
     * Đếm tổng số dòng sản phẩm trong giỏ hàng của khách hàng.
     *
     * @param customerId ID khách hàng
     * @return số lượng mục sản phẩm
     */
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

    /**
     * Nạp toàn bộ các mục trong giỏ hàng, đồng thời đối soát tồn kho (reconcile):
     * - Tự động giảm số lượng trong database nếu số lượng trong giỏ vượt quá tồn kho.
     * - Đánh giá trạng thái khả dụng (AVAILABLE, VARIANT_UNAVAILABLE, SOLD_OUT, NOT_FOUND).
     * - Gắn danh sách các phân loại thay thế của cùng sản phẩm để người dùng dễ chọn đổi.
     * - Sắp xếp theo mức độ khả dụng (sản phẩm còn hàng lên trên).
     *
     * @param cartId ID giỏ hàng
     * @return danh sách CartItem đã đối soát
     */
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

    /**
     * Thêm sản phẩm (biến thể) vào giỏ hàng:
     * - Nếu biến thể đã tồn tại trong giỏ thì tăng số lượng.
     * - Nếu chưa có thì chèn thêm dòng mới vào cart_items.
     * - Kiểm tra tồn kho trước khi thêm.
     *
     * @param customerId ID khách hàng
     * @param variantId  ID biến thể sản phẩm
     * @param quantity   số lượng muốn thêm
     * @return CartMutationResult chứa thông tin item vừa thêm/sửa và tổng số lượng mục trong giỏ
     */
    public CartMutationResult addCartItem(long customerId, long variantId, int quantity) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                Cart cart = findOrCreateCart(conn, customerId);
                CartItem existing = findItemByVariantId(conn, cart.getCartId(), variantId);
                long requestedQuantity = (existing == null ? 0L : existing.getQuantity()) + quantity;
                ProductVariantDetailDTO variant = findAvailableVariant(conn, variantId);
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

    /**
     * Cập nhật số lượng của một mục sản phẩm trong giỏ hàng.
     *
     * @param customerId ID khách hàng
     * @param cartItemId ID mục giỏ hàng
     * @param quantity   số lượng mới
     */
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

    /**
     * Xóa một mục sản phẩm khỏi giỏ hàng của khách hàng.
     *
     * @param customerId ID khách hàng
     * @param cartItemId ID mục giỏ hàng
     */
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

    /**
     * Đổi sang biến thể mới cho một mục sản phẩm trong giỏ:
     * - Kiểm tra cả biến thể cũ và mới cùng thuộc một sản phẩm.
     * - Nếu biến thể mới đã có trong giỏ: gộp số lượng (chặn không vượt quá tồn kho mới) và xóa dòng cũ.
     * - Nếu biến thể mới chưa có: cập nhật variant_id và số lượng trên dòng hiện tại.
     *
     * @param customerId   ID khách hàng
     * @param cartItemId   ID mục giỏ hàng cần đổi
     * @param newVariantId ID biến thể mới
     */
    public void changeCartItemVariant(long customerId, long cartItemId, long newVariantId) {
        try (Connection conn = requireConnection()) {
            conn.setAutoCommit(false);
            try {
                long cartId = requireOwnedCart(conn, customerId);
                CartItem current = findItemById(conn, cartId, cartItemId);
                if (current == null) {
                    throw itemNotFound();
                }

                ProductVariantDetailDTO currentVariant = findVariantIncludingUnavailable(conn,
                        current.getVariant().getVariantId());
                ProductVariantDetailDTO newVariant = findAvailableVariant(conn, newVariantId);
                if (currentVariant == null || newVariant == null
                        || currentVariant.getProductId() != newVariant.getProductId()) {
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

    /**
     * Tìm giỏ hàng hiện có của khách hoặc tạo mới bằng INSERT trong transaction (sử dụng HOLDLOCK tránh race condition).
     */
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

    /**
     * Xác thực giỏ hàng tồn tại và thuộc về đúng khách hàng, khóa dòng để thao tác an toàn.
     */
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

    /**
     * Nạp toàn bộ danh sách item trong giỏ cùng thông tin biến thể, sản phẩm, cửa hàng và khóa UPDLOCK, HOLDLOCK.
     */
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

    /**
     * Ánh xạ dòng dữ liệu ResultSet sang đối tượng CartItem kèm thông tin biến thể và shop.
     */
    private CartItem mapCartItem(ResultSet rs) throws SQLException {
        CartItem item = new CartItem(rs.getLong("cart_item_id"), mapVariant(rs), rs.getInt("quantity"));
        item.setPreviousQuantity(item.getQuantity());
        item.getVariant().setShopName(rs.getString("shop_name"));
        item.getVariant().setShopStatus(rs.getString("shop_status"));
        item.getVariant().setImage(rs.getString("thumbnail_url"));
        return item;
    }

    /**
     * Xác định trạng thái khả dụng của sản phẩm (hết hàng, ngừng bán, còn hàng) và tự động điều chỉnh số lượng nếu vượt quá tồn kho.
     */
    private void determineAvailability(CartItem item, ResultSet rs) throws SQLException {
        ProductVariantDetailDTO variant = item.getVariant();
        boolean productAvailable = variant.isProductActive()
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

    /**
     * Gắn danh sách các biến thể thay thế (cùng sản phẩm nhưng khác variantId) vào từng CartItem.
     */
    private void attachAlternativeVariants(Connection conn, List<CartItem> items) throws SQLException {
        List<Long> productIds = items.stream()
                .filter(item -> item.getAvailability() != CartItemAvailability.NOT_FOUND)
                .map(item -> item.getVariant().getProductId())
                .distinct()
                .toList();
        if (productIds.isEmpty()) {
            return;
        }
        Map<Long, List<ProductVariantDetailDTO>> variantsByProduct = findVariantsByProductIds(conn, productIds);
        for (CartItem item : items) {
            long currentVariantId = item.getVariant().getVariantId();
            List<ProductVariantDetailDTO> alternatives = variantsByProduct
                    .getOrDefault(item.getVariant().getProductId(), List.of())
                    .stream()
                    .filter(variant -> variant.getVariantId() != currentVariantId)
                    .collect(Collectors.toCollection(ArrayList::new));
            item.setAlternativeVariants(alternatives);
        }
    }

    /**
     * Lấy danh sách các biến thể còn khả dụng theo danh sách productId.
     */
    private Map<Long, List<ProductVariantDetailDTO>> findVariantsByProductIds(Connection conn,
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
        Map<Long, List<ProductVariantDetailDTO>> result = new LinkedHashMap<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            for (Long productId : productIds) {
                ps.setLong(index++, productId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariantDetailDTO variant = mapVariant(rs);
                    result.computeIfAbsent(variant.getProductId(), key -> new ArrayList<>())
                            .add(variant);
                }
            }
        }
        return result;
    }

    /**
     * Tìm biến thể đang hoạt động và shop đang hoạt động (có khóa UPDLOCK).
     */
    private ProductVariantDetailDTO findAvailableVariant(Connection conn, long variantId) throws SQLException {
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

    /**
     * Tìm thông tin biến thể không phân biệt trạng thái khả dụng.
     */
    private ProductVariantDetailDTO findVariantIncludingUnavailable(Connection conn, long variantId) throws SQLException {
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

    /**
     * Tìm mục giỏ hàng theo cartItemId.
     */
    private CartItem findItemById(Connection conn, long cartId, long cartItemId) throws SQLException {
        return findSingleItem(conn,
                "SELECT cart_item_id, variant_id, quantity FROM cart_items WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE cart_id = ? AND cart_item_id = ?", cartId, cartItemId);
    }

    /**
     * Tìm mục giỏ hàng theo variantId.
     */
    private CartItem findItemByVariantId(Connection conn, long cartId, long variantId) throws SQLException {
        return findSingleItem(conn,
                "SELECT cart_item_id, variant_id, quantity FROM cart_items WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE cart_id = ? AND variant_id = ?", cartId, variantId);
    }

    /**
     * Thực hiện truy vấn một dòng duy nhất trong cart_items.
     */
    private CartItem findSingleItem(Connection conn, String sql, long cartId, long id) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ProductVariantDetailDTO variant = new ProductVariantDetailDTO();
                variant.setVariantId(rs.getLong("variant_id"));
                CartItem item = new CartItem(rs.getLong("cart_item_id"), variant, rs.getInt("quantity"));
                if (rs.next()) {
                    throw new SQLException("Duplicate cart items for lookup");
                }
                return item;
            }
        }
    }

    /**
     * Chèn một dòng sản phẩm mới vào bảng cart_items.
     */
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

    /**
     * Đếm tổng số lượng dòng sản phẩm theo cartId.
     */
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

    /**
     * Cập nhật số lượng của một dòng cart_item.
     */
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

    /**
     * Xóa một dòng cart_item thuộc đúng cartId.
     */
    private boolean deleteItemByCart(Connection conn, long cartId, long cartItemId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_id = ? AND cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, cartItemId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Cập nhật phân loại mới và số lượng mới cho cart_item.
     */
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

    /**
     * Kiểm tra số lượng yêu cầu so với tồn kho của biến thể.
     */
    private void validateStock(ProductVariantDetailDTO variant, long quantity) {
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

    /**
     * Ánh xạ thông tin biến thể sản phẩm từ ResultSet sang ProductVariantDetailDTO.
     */
    private ProductVariantDetailDTO mapVariant(ResultSet rs) throws SQLException {
        ProductVariantDetailDTO variant = new ProductVariantDetailDTO();
        variant.setVariantId(rs.getLong("variant_id"));
        variant.setProductId(rs.getLong("product_id"));
        variant.setShopId(rs.getLong("shop_id"));
        variant.setProductName(rs.getString("product_name"));
        variant.setOrigin(rs.getString("origin"));
        variant.setProductActive(rs.getBoolean("product_active"));
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
