package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.CartItem;
import model.Coupon;
import model.CustomerAddress;
import model.Order;
import model.OrderItem;
import model.Product;
import model.ProductVariant;
import model.ShippingAddress;
import model.SubOrder;
import util.DBContext;

public class OrderDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());
    private final CouponDAO couponDAO = new CouponDAO();

    // 1. LẤY CÁC CART ITEMS ĐƯỢC CHỌN CỦA KHÁCH HÀNG
    public List<CartItem> getSelectedCartItems(long customerId, List<Long> cartItemIds) {
        if (cartItemIds == null || cartItemIds.isEmpty()) {
            return Collections.emptyList();
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < cartItemIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }

        String sql = "SELECT ci.cart_item_id, ci.quantity, "
                + "       pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.weight_kg, "
                + "       pv.price, pv.stock_quantity, pv.is_active AS variant_active, "
                + "       p.product_id, p.name AS product_name, p.origin, p.is_active AS product_active, "
                + "       s.shop_id, s.shop_name, s.status AS shop_status, "
                + "       (SELECT TOP 1 pi2.image_url FROM product_images pi2 "
                + "        WHERE pi2.product_id = p.product_id AND pi2.is_thumbnail = 1 "
                + "        ORDER BY pi2.display_order) AS thumbnail_url "
                + "FROM cart_items ci "
                + "INNER JOIN carts c ON ci.cart_id = c.cart_id "
                + "INNER JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "INNER JOIN products p ON pv.product_id = p.product_id "
                + "INNER JOIN shops s ON p.shop_id = s.shop_id "
                + "WHERE c.customer_id = ? AND ci.cart_item_id IN (" + placeholders + ") "
                + "ORDER BY s.shop_id, ci.cart_item_id";

        List<CartItem> items = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in getSelectedCartItems");
            throw new IllegalStateException("Không thể tải sản phẩm thanh toán. Vui lòng thử lại!");
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            for (int i = 0; i < cartItemIds.size(); i++) {
                ps.setLong(i + 2, cartItemIds.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getLong("product_id"));
                    p.setName(rs.getString("product_name"));
                    p.setOrigin(rs.getString("origin"));
                    p.setActive(rs.getBoolean("product_active"));
                    p.setShopId(rs.getLong("shop_id"));
                    p.setShopName(rs.getString("shop_name"));
                    p.setShopStatus(rs.getString("shop_status"));
                    p.setThumbnailUrl(rs.getString("thumbnail_url"));
                    p.setImage(rs.getString("thumbnail_url"));

                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getLong("variant_id"));
                    v.setSku(rs.getString("sku"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setUnit(rs.getString("unit"));
                    v.setWeightKg(rs.getBigDecimal("weight_kg"));
                    v.setPrice(rs.getBigDecimal("price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setActive(rs.getBoolean("variant_active"));
                    v.setProduct(p);

                    CartItem item = new CartItem();
                    item.setCartItemID(rs.getLong("cart_item_id"));
                    item.setVariant(v);
                    item.setQuantity(rs.getInt("quantity"));

                    items.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting selected cart items for customer " + customerId, ex);
            throw new IllegalStateException("Không thể tải sản phẩm thanh toán. Vui lòng thử lại!", ex);
        }
        return items;
    }

    // 2. LẤY ĐỊA CHỈ MẶC ĐỊNH HOẶC ĐỊA CHỈ GẦN NHẤT CỦA KHÁCH HÀNG
    public CustomerAddress getDefaultAddress(long customerId) {
        String sql = "SELECT TOP 1 address_id, user_id, recipient_name, recipient_phone, "
                + "street_address, ward, district, city, is_default "
                + "FROM customer_addresses "
                + "WHERE user_id = ? "
                + "ORDER BY is_default DESC, updated_at DESC";

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomerAddress addr = new CustomerAddress();
                    addr.setAddressId(rs.getLong("address_id"));
                    addr.setUserId(rs.getLong("user_id"));
                    addr.setRecipientName(rs.getString("recipient_name"));
                    addr.setRecipientPhone(rs.getString("recipient_phone"));
                    addr.setStreetAddress(rs.getString("street_address"));
                    addr.setWard(rs.getString("ward"));
                    addr.setDistrict(rs.getString("district"));
                    addr.setCity(rs.getString("city"));
                    addr.setDefaultAddress(rs.getBoolean("is_default"));
                    return addr;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting default address for customer " + customerId, ex);
        }
        return null;
    }

    public List<CustomerAddress> getCustomerAddresses(long customerId) {
        String sql = "SELECT address_id, user_id, recipient_name, recipient_phone, "
                + "street_address, ward, district, city, is_default, created_at, updated_at "
                + "FROM customer_addresses WHERE user_id = ? "
                + "ORDER BY is_default DESC, updated_at DESC";

        List<CustomerAddress> addresses = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            throw new IllegalStateException("Không thể tải danh sách địa chỉ. Vui lòng thử lại!");
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerAddress address = mapCustomerAddress(rs);
                    addresses.add(address);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting addresses for customer " + customerId, ex);
            throw new IllegalStateException("Không thể tải danh sách địa chỉ. Vui lòng thử lại!", ex);
        }
        return addresses;
    }

    public CustomerAddress getCustomerAddressById(long customerId, long addressId) {
        String sql = "SELECT address_id, user_id, recipient_name, recipient_phone, "
                + "street_address, ward, district, city, is_default, created_at, updated_at "
                + "FROM customer_addresses WHERE address_id = ? AND user_id = ?";
        Connection conn = getConnection();
        if (conn == null) {
            throw new IllegalStateException("Không thể tải địa chỉ giao hàng. Vui lòng thử lại!");
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCustomerAddress(rs) : null;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting customer address " + addressId, ex);
            throw new IllegalStateException("Không thể tải địa chỉ giao hàng. Vui lòng thử lại!", ex);
        }
    }

    private CustomerAddress mapCustomerAddress(ResultSet rs) throws SQLException {
        CustomerAddress address = new CustomerAddress();
        address.setAddressId(rs.getLong("address_id"));
        address.setUserId(rs.getLong("user_id"));
        address.setRecipientName(rs.getString("recipient_name"));
        address.setRecipientPhone(rs.getString("recipient_phone"));
        address.setStreetAddress(rs.getString("street_address"));
        address.setWard(rs.getString("ward"));
        address.setDistrict(rs.getString("district"));
        address.setCity(rs.getString("city"));
        address.setDefaultAddress(rs.getBoolean("is_default"));
        address.setCreatedAt(rs.getTimestamp("created_at"));
        address.setUpdatedAt(rs.getTimestamp("updated_at"));
        return address;
    }

    // 3. TẠO ĐƠN HÀNG TOÀN DIỆN (TRANSACTION AN TOÀN)
    public long createOrder(Order order, ShippingAddress address, List<Long> cartItemIdsToDelete,
            String paymentMethod, boolean saveCustomerAddress) throws Exception {
        String insertOrderSql = "INSERT INTO orders (customer_id, coupon_id, total_goods_amount, "
                + "total_shipping_fee, platform_discount, final_amount, payment_status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String insertAddressSql = "INSERT INTO order_shipping_addresses "
                + "(order_id, recipient_name, recipient_phone, street_address, ward, district, city) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String insertSubOrderSql = "INSERT INTO sub_orders "
                + "(order_id, shop_id, delivery_slot, shop_subtotal, shop_shipping_fee, "
                + "shop_discount, shop_total, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        String insertOrderItemSql = "INSERT INTO order_items "
                + "(sub_order_id, variant_id, product_name_snapshot, variant_name_snapshot, "
                + "sku_snapshot, unit, unit_price, quantity, total_price) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String deductStockSql = "UPDATE pv SET pv.stock_quantity = pv.stock_quantity - ? "
                + "FROM product_variants pv "
                + "INNER JOIN products p ON p.product_id = pv.product_id "
                + "INNER JOIN shops s ON s.shop_id = p.shop_id "
                + "WHERE pv.variant_id = ? AND pv.stock_quantity >= ? "
                + "AND pv.price = ? AND pv.is_active = 1 AND p.is_active = 1 "
                + "AND s.status = 'ACTIVE'";

        String deleteCartItemsSql = "DELETE ci FROM cart_items ci "
                + "INNER JOIN carts c ON c.cart_id = ci.cart_id "
                + "WHERE ci.cart_item_id = ? AND c.customer_id = ?";

        String insertPaymentSql = "INSERT INTO payments "
                + "(order_id, payment_provider, payment_type, amount, payment_status) "
                + "VALUES (?, ?, ?, ?, ?)";

        String insertCustomerAddressSql = "INSERT INTO customer_addresses "
                + "(user_id, recipient_name, recipient_phone, street_address, ward, district, city, is_default) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, CASE WHEN EXISTS "
                + "(SELECT 1 FROM customer_addresses WHERE user_id = ?) THEN 0 ELSE 1 END)";

        Connection conn = getConnection();
        if (conn == null) {
            throw new Exception("Không thể kết nối đến cơ sở dữ liệu!");
        }

        try {
            conn.setAutoCommit(false); // BẮT ĐẦU TRANSACTION

            lockAndValidateCartItems(conn, order, cartItemIdsToDelete);

            if (saveCustomerAddress) {
                insertCustomerAddress(conn, insertCustomerAddressSql,
                        order.getCustomerId(), address);
            }

            // Khóa và kiểm tra lại voucher trong cùng transaction để tránh vượt lượt dùng.
            if (order.getCouponId() != null) {
                Coupon coupon = couponDAO.findByIdForUpdate(conn, order.getCouponId());
                validateCouponForOrder(coupon, order.getTotalGoodsAmount());
                BigDecimal discount = calculateCouponDiscount(coupon, order.getTotalGoodsAmount());
                order.setPlatformDiscount(discount);
                order.setFinalAmount(order.getTotalGoodsAmount()
                        .add(order.getTotalShippingFee())
                        .subtract(discount)
                        .max(BigDecimal.ZERO));
            } else {
                order.setPlatformDiscount(BigDecimal.ZERO);
                order.setFinalAmount(order.getTotalGoodsAmount()
                        .add(order.getTotalShippingFee()));
            }

            long orderId;
            // A. INSERT ORDERS
            try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, order.getCustomerId());
                if (order.getCouponId() != null) {
                    ps.setInt(2, order.getCouponId());
                } else {
                    ps.setNull(2, Types.INTEGER);
                }
                ps.setBigDecimal(3, order.getTotalGoodsAmount());
                ps.setBigDecimal(4, order.getTotalShippingFee());
                ps.setBigDecimal(5, order.getPlatformDiscount());
                ps.setBigDecimal(6, order.getFinalAmount());
                ps.setString(7, order.getPaymentStatus());

                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        orderId = rs.getLong(1);
                        order.setOrderId(orderId);
                    } else {
                        throw new SQLException("Tạo hóa đơn thất bại, không nhận được Order ID.");
                    }
                }
            }

            // B. INSERT SHIPPING ADDRESS
            try (PreparedStatement ps = conn.prepareStatement(insertAddressSql)) {
                ps.setLong(1, orderId);
                ps.setString(2, address.getRecipientName());
                ps.setString(3, address.getRecipientPhone());
                ps.setString(4, address.getStreetAddress());
                ps.setString(5, address.getWard());
                ps.setString(6, address.getDistrict());
                ps.setString(7, address.getCity());
                ps.executeUpdate();
            }

            // C. INSERT SUB_ORDERS & ORDER_ITEMS & DEDUCT STOCK
            for (SubOrder sub : order.getSubOrders()) {
                long subOrderId;
                try (PreparedStatement ps = conn.prepareStatement(insertSubOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setLong(1, orderId);
                    ps.setLong(2, sub.getShopId());
                    ps.setString(3, sub.getDeliverySlot());
                    ps.setBigDecimal(4, sub.getShopSubtotal());
                    ps.setBigDecimal(5, sub.getShopShippingFee());
                    ps.setBigDecimal(6, sub.getShopDiscount());
                    ps.setBigDecimal(7, sub.getShopTotal());
                    ps.setString(8, sub.getStatus());

                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            subOrderId = rs.getLong(1);
                            sub.setSubOrderId(subOrderId);
                        } else {
                            throw new SQLException("Tạo Sub-Order thất bại, không nhận được ID.");
                        }
                    }
                }

                // D. INSERT TỪNG ORDER_ITEM
                for (OrderItem item : sub.getItems()) {
                    try (PreparedStatement ps = conn.prepareStatement(insertOrderItemSql)) {
                        ps.setLong(1, subOrderId);
                        if (item.getVariantId() != null) {
                            ps.setLong(2, item.getVariantId());
                        } else {
                            ps.setNull(2, Types.BIGINT);
                        }
                        ps.setString(3, item.getProductNameSnapshot());
                        ps.setString(4, item.getVariantNameSnapshot());
                        ps.setString(5, item.getSkuSnapshot());
                        ps.setString(6, item.getUnit());
                        ps.setBigDecimal(7, item.getUnitPrice());
                        ps.setInt(8, item.getQuantity());
                        ps.setBigDecimal(9, item.getTotalPrice());
                        ps.executeUpdate();
                    }

                    // E. TRỪ TỒN KHO NGUYÊN TỬ
                    if (item.getVariantId() != null) {
                        try (PreparedStatement ps = conn.prepareStatement(deductStockSql)) {
                            ps.setInt(1, item.getQuantity());
                            ps.setLong(2, item.getVariantId());
                            ps.setInt(3, item.getQuantity());
                            ps.setBigDecimal(4, item.getUnitPrice());

                            int updated = ps.executeUpdate();
                            if (updated == 0) {
                                throw new SQLException("Sản phẩm '" + item.getProductNameSnapshot()
                                        + "' vừa hết hàng, đổi giá hoặc cửa hàng đã ngừng hoạt động. "
                                        + "Vui lòng quay lại giỏ hàng để kiểm tra!");
                            }
                        }
                    }
                }
            }

            // F. XÓA CÁC SẢN PHẨM ĐÃ MUA KHỎI GIỎ HÀNG
            if (cartItemIdsToDelete != null && !cartItemIdsToDelete.isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(deleteCartItemsSql)) {
                    for (Long itemId : cartItemIdsToDelete) {
                        ps.setLong(1, itemId);
                        ps.setLong(2, order.getCustomerId());
                        ps.addBatch();
                    }
                    int[] deletedRows = ps.executeBatch();
                    for (int deleted : deletedRows) {
                        if (deleted == 0) {
                            throw new SQLException("Có sản phẩm không còn thuộc giỏ hàng của bạn!");
                        }
                    }
                }
            }

            // Chỉ tăng used_count nếu mọi bước tạo đơn, trừ kho và xóa giỏ đều thành công.
            if (order.getCouponId() != null) {
                couponDAO.incrementUsage(conn, order.getCouponId());
            }

            // Ghi nhận phương thức thanh toán trong cùng transaction.
            try (PreparedStatement ps = conn.prepareStatement(insertPaymentSql)) {
                ps.setLong(1, orderId);
                ps.setString(2, paymentMethod);
                ps.setString(3, "COD".equals(paymentMethod) ? "CASH" : "ONLINE");
                ps.setBigDecimal(4, order.getFinalAmount());
                ps.setString(5, "PENDING");
                ps.executeUpdate();
            }

            conn.commit(); // THÀNH CÔNG -> COMMIT!
            return orderId;

        } catch (Exception ex) {
            try {
                conn.rollback(); // LỖI -> HOÀN TÁC TOÀN BỘ!
            } catch (SQLException rEx) {
                LOGGER.log(Level.SEVERE, "Rollback failed", rEx);
            }
            LOGGER.log(Level.SEVERE, "Create order failed", ex);
            throw ex;
        } finally {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException cEx) {
                LOGGER.log(Level.SEVERE, "Close connection failed", cEx);
            }
        }
    }

    private void insertCustomerAddress(Connection conn, String sql, long customerId,
            ShippingAddress address) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setString(2, address.getRecipientName());
            ps.setString(3, address.getRecipientPhone());
            ps.setString(4, address.getStreetAddress());
            ps.setString(5, address.getWard());
            ps.setString(6, address.getDistrict());
            ps.setString(7, address.getCity());
            ps.setLong(8, customerId);
            ps.executeUpdate();
        }
    }

    private void lockAndValidateCartItems(Connection conn, Order order,
            List<Long> cartItemIds) throws SQLException {
        if (cartItemIds == null || cartItemIds.isEmpty()) {
            throw new SQLException("Không có sản phẩm nào được chọn để đặt hàng!");
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < cartItemIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }

        String sql = "SELECT ci.cart_item_id, ci.variant_id, ci.quantity "
                + "FROM cart_items ci WITH (UPDLOCK, HOLDLOCK) "
                + "INNER JOIN carts c ON c.cart_id = ci.cart_id "
                + "WHERE c.customer_id = ? AND ci.cart_item_id IN (" + placeholders + ")";

        Map<Long, Integer> expectedQuantities = new HashMap<>();
        for (SubOrder sub : order.getSubOrders()) {
            for (OrderItem item : sub.getItems()) {
                if (item.getVariantId() != null) {
                    expectedQuantities.merge(item.getVariantId(), item.getQuantity(), Integer::sum);
                }
            }
        }

        Map<Long, Integer> actualQuantities = new HashMap<>();
        int rowCount = 0;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, order.getCustomerId());
            for (int i = 0; i < cartItemIds.size(); i++) {
                ps.setLong(i + 2, cartItemIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rowCount++;
                    actualQuantities.merge(rs.getLong("variant_id"),
                            rs.getInt("quantity"), Integer::sum);
                }
            }
        }

        if (rowCount != cartItemIds.size() || !actualQuantities.equals(expectedQuantities)) {
            throw new SQLException("Giỏ hàng vừa thay đổi. Vui lòng quay lại giỏ hàng và kiểm tra lại!");
        }
    }

    private void validateCouponForOrder(Coupon coupon, BigDecimal eligibleAmount) throws SQLException {
        if (coupon == null) {
            throw new SQLException("Mã giảm giá không còn tồn tại!");
        }
        if (!coupon.isActive()) {
            throw new SQLException("Mã giảm giá hiện không hoạt động!");
        }

        java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
        if (coupon.getStartDate() == null || now.before(coupon.getStartDate())) {
            throw new SQLException("Mã giảm giá chưa đến thời gian sử dụng!");
        }
        if (coupon.getEndDate() == null || now.after(coupon.getEndDate())) {
            throw new SQLException("Mã giảm giá đã hết hạn!");
        }
        if (coupon.getUsedCount() >= coupon.getUsageLimit()) {
            throw new SQLException("Mã giảm giá đã hết lượt sử dụng!");
        }

        BigDecimal minimum = coupon.getMinOrderValue() != null
                ? coupon.getMinOrderValue() : BigDecimal.ZERO;
        if (eligibleAmount.compareTo(minimum) < 0) {
            throw new SQLException("Đơn hàng không còn đủ điều kiện giá trị tối thiểu của mã giảm giá!");
        }
    }

    private BigDecimal calculateCouponDiscount(Coupon coupon, BigDecimal eligibleAmount)
            throws SQLException {
        BigDecimal discount;
        String type = coupon.getDiscountType() == null
                ? "" : coupon.getDiscountType().trim().toUpperCase(java.util.Locale.ROOT);

        if ("PERCENTAGE".equals(type)) {
            discount = eligibleAmount.multiply(coupon.getDiscountValue())
                    .divide(new BigDecimal("100"), 2, java.math.RoundingMode.HALF_UP);
        } else if ("FIXED_AMOUNT".equals(type)) {
            discount = coupon.getDiscountValue();
        } else {
            throw new SQLException("Loại mã giảm giá không hợp lệ!");
        }

        if (coupon.getMaxDiscountAmount() != null
                && discount.compareTo(coupon.getMaxDiscountAmount()) > 0) {
            discount = coupon.getMaxDiscountAmount();
        }
        return discount.min(eligibleAmount).max(BigDecimal.ZERO)
                .setScale(2, java.math.RoundingMode.HALF_UP);
    }

    // 4. LẤY CHI TIẾT ĐƠN HÀNG THEO ID
    public Order getOrderById(long orderId) {
        String sqlOrder = "SELECT o.order_id, o.customer_id, o.coupon_id, o.total_goods_amount, "
                + "o.total_shipping_fee, o.platform_discount, o.final_amount, o.payment_status, "
                + "o.created_at, o.updated_at, "
                + "sa.recipient_name, sa.recipient_phone, sa.street_address, sa.ward, sa.district, sa.city "
                + "FROM orders o "
                + "LEFT JOIN order_shipping_addresses sa ON o.order_id = sa.order_id "
                + "WHERE o.order_id = ?";

        String sqlSub = "SELECT so.sub_order_id, so.order_id, so.shop_id, s.shop_name, "
                + "so.delivery_slot, so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, "
                + "so.shop_total, so.status, so.created_at "
                + "FROM sub_orders so "
                + "INNER JOIN shops s ON so.shop_id = s.shop_id "
                + "WHERE so.order_id = ?";

        String sqlItems = "SELECT oi.order_item_id, oi.sub_order_id, oi.variant_id, "
                + "oi.product_name_snapshot, oi.variant_name_snapshot, oi.sku_snapshot, "
                + "oi.unit, oi.unit_price, oi.quantity, oi.total_price "
                + "FROM order_items oi "
                + "WHERE oi.sub_order_id = ?";

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn) {
            Order order = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        order = new Order();
                        order.setOrderId(rs.getLong("order_id"));
                        order.setCustomerId(rs.getLong("customer_id"));
                        int cId = rs.getInt("coupon_id");
                        order.setCouponId(rs.wasNull() ? null : cId);
                        order.setTotalGoodsAmount(rs.getBigDecimal("total_goods_amount"));
                        order.setTotalShippingFee(rs.getBigDecimal("total_shipping_fee"));
                        order.setPlatformDiscount(rs.getBigDecimal("platform_discount"));
                        order.setFinalAmount(rs.getBigDecimal("final_amount"));
                        order.setPaymentStatus(rs.getString("payment_status"));
                        order.setCreatedAt(rs.getTimestamp("created_at"));
                        order.setUpdatedAt(rs.getTimestamp("updated_at"));

                        ShippingAddress addr = new ShippingAddress();
                        addr.setOrderId(orderId);
                        addr.setRecipientName(rs.getString("recipient_name"));
                        addr.setRecipientPhone(rs.getString("recipient_phone"));
                        addr.setStreetAddress(rs.getString("street_address"));
                        addr.setWard(rs.getString("ward"));
                        addr.setDistrict(rs.getString("district"));
                        addr.setCity(rs.getString("city"));
                        order.setShippingAddress(addr);
                    }
                }
            }

            if (order != null) {
                // Lấy sub_orders
                try (PreparedStatement psSub = conn.prepareStatement(sqlSub)) {
                    psSub.setLong(1, orderId);
                    try (ResultSet rsSub = psSub.executeQuery()) {
                        while (rsSub.next()) {
                            SubOrder sub = new SubOrder();
                            sub.setSubOrderId(rsSub.getLong("sub_order_id"));
                            sub.setOrderId(orderId);
                            sub.setShopId(rsSub.getLong("shop_id"));
                            sub.setShopName(rsSub.getString("shop_name"));
                            sub.setDeliverySlot(rsSub.getString("delivery_slot"));
                            sub.setShopSubtotal(rsSub.getBigDecimal("shop_subtotal"));
                            sub.setShopShippingFee(rsSub.getBigDecimal("shop_shipping_fee"));
                            sub.setShopDiscount(rsSub.getBigDecimal("shop_discount"));
                            sub.setShopTotal(rsSub.getBigDecimal("shop_total"));
                            sub.setStatus(rsSub.getString("status"));
                            sub.setCreatedAt(rsSub.getTimestamp("created_at"));

                            // Lấy order_items của từng sub_order
                            try (PreparedStatement psItem = conn.prepareStatement(sqlItems)) {
                                psItem.setLong(1, sub.getSubOrderId());
                                try (ResultSet rsItem = psItem.executeQuery()) {
                                    while (rsItem.next()) {
                                        OrderItem item = new OrderItem();
                                        item.setOrderItemId(rsItem.getLong("order_item_id"));
                                        item.setSubOrderId(sub.getSubOrderId());
                                        long vId = rsItem.getLong("variant_id");
                                        item.setVariantId(rsItem.wasNull() ? null : vId);
                                        item.setProductNameSnapshot(rsItem.getString("product_name_snapshot"));
                                        item.setVariantNameSnapshot(rsItem.getString("variant_name_snapshot"));
                                        item.setSkuSnapshot(rsItem.getString("sku_snapshot"));
                                        item.setUnit(rsItem.getString("unit"));
                                        item.setUnitPrice(rsItem.getBigDecimal("unit_price"));
                                        item.setQuantity(rsItem.getInt("quantity"));
                                        item.setTotalPrice(rsItem.getBigDecimal("total_price"));
                                        sub.getItems().add(item);
                                    }
                                }
                            }
                            order.getSubOrders().add(sub);
                        }
                    }
                }
            }
            return order;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting order by id: " + orderId, ex);
        }
        return null;
    }
}
