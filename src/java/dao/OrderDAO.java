package dao;

import enums.OrderStatus;
import enums.PaymentMethod;
import enums.PaymentStatus;
import enums.PaymentTransactionStatus;
import enums.PaymentType;
import enums.SubOrderStatus;
import java.math.BigDecimal;
import java.math.RoundingMode;
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

    // 1. Láº¤Y CÃC CART ITEMS ÄÆ¯á»¢C CHá»ŒN Cá»¦A KHÃCH HÃ€NG
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
            throw new IllegalStateException("KhÃ´ng thá»ƒ táº£i sáº£n pháº©m thanh toÃ¡n. Vui lÃ²ng thá»­ láº¡i!");
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
            throw new IllegalStateException("KhÃ´ng thá»ƒ táº£i sáº£n pháº©m thanh toÃ¡n. Vui lÃ²ng thá»­ láº¡i!", ex);
        }
        return items;
    }

    // 2. Láº¤Y Äá»ŠA CHá»ˆ Máº¶C Äá»ŠNH HOáº¶C Äá»ŠA CHá»ˆ Gáº¦N NHáº¤T Cá»¦A KHÃCH HÃ€NG
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
            throw new IllegalStateException("KhÃ´ng thá»ƒ táº£i danh sÃ¡ch Ä‘á»‹a chá»‰. Vui lÃ²ng thá»­ láº¡i!");
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
            throw new IllegalStateException("KhÃ´ng thá»ƒ táº£i danh sÃ¡ch Ä‘á»‹a chá»‰. Vui lÃ²ng thá»­ láº¡i!", ex);
        }
        return addresses;
    }

    public CustomerAddress getCustomerAddressById(long customerId, long addressId) {
        String sql = "SELECT address_id, user_id, recipient_name, recipient_phone, "
                + "street_address, ward, district, city, is_default, created_at, updated_at "
                + "FROM customer_addresses WHERE address_id = ? AND user_id = ?";
        Connection conn = getConnection();
        if (conn == null) {
            throw new IllegalStateException("KhÃ´ng thá»ƒ táº£i Ä‘á»‹a chá»‰ giao hÃ ng. Vui lÃ²ng thá»­ láº¡i!");
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCustomerAddress(rs) : null;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting customer address " + addressId, ex);
            throw new IllegalStateException("KhÃ´ng thá»ƒ táº£i Ä‘á»‹a chá»‰ giao hÃ ng. Vui lÃ²ng thá»­ láº¡i!", ex);
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

    // 3. Táº O ÄÆ N HÃ€NG TOÃ€N DIá»†N (TRANSACTION AN TOÃ€N)
    public long createOrder(Order order, ShippingAddress address, List<Long> cartItemIdsToDelete,
            String paymentMethod, boolean saveCustomerAddress) throws Exception {
        String insertOrderSql = "INSERT INTO orders (order_code, customer_id, coupon_id, total_goods_amount, "
                + "total_shipping_fee, platform_discount, final_amount, payment_status, payment_method, order_status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String insertAddressSql = "INSERT INTO order_shipping_addresses "
                + "(order_id, recipient_name, recipient_phone, street_address, ward, district, city) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        String insertSubOrderSql = "INSERT INTO sub_orders "
                + "(sub_order_code, order_id, shop_id, delivery_slot, shop_subtotal, shop_shipping_fee, "
                + "shop_discount, shop_total, commission_rate, commission_amount, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

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
            throw new Exception("KhÃ´ng thá»ƒ káº¿t ná»‘i Ä‘áº¿n cÆ¡ sá»Ÿ dá»¯ liá»‡u!");
        }

        try {
            conn.setAutoCommit(false); // Báº®T Äáº¦U TRANSACTION

            lockAndValidateCartItems(conn, order, cartItemIdsToDelete);

            if (saveCustomerAddress) {
                insertCustomerAddress(conn, insertCustomerAddressSql,
                        order.getCustomerId(), address);
            }

            // Khóa và kiểm tra lại voucher trong cùng transaction để tránh vượt lượt dùng.
            BigDecimal totalShopDiscounts = BigDecimal.ZERO;
            for (SubOrder sub : order.getSubOrders()) {
                if (sub.getShopCouponId() != null) {
                    Coupon sc = couponDAO.findByIdForUpdate(conn, sub.getShopCouponId());
                    validateCouponForShop(sc, sub.getShopId(), sub.getShopSubtotal());
                    BigDecimal sDiscount = calculateCouponDiscount(sc, sub.getShopSubtotal());
                    sub.setShopDiscount(sDiscount);
                    sub.setShopTotal(sub.getShopSubtotal().add(sub.getShopShippingFee()).subtract(sDiscount).max(BigDecimal.ZERO));
                    totalShopDiscounts = totalShopDiscounts.add(sDiscount);
                } else {
                    if (sub.getShopDiscount() == null) {
                        sub.setShopDiscount(BigDecimal.ZERO);
                    }
                    totalShopDiscounts = totalShopDiscounts.add(sub.getShopDiscount());
                }
            }

            if (order.getCouponId() != null) {
                Coupon coupon = couponDAO.findByIdForUpdate(conn, order.getCouponId());
                validateCouponForOrder(coupon, order.getTotalGoodsAmount());
                BigDecimal discount = calculateCouponDiscount(coupon, order.getTotalGoodsAmount());
                order.setPlatformDiscount(discount);
            } else {
                order.setPlatformDiscount(BigDecimal.ZERO);
            }

            BigDecimal totalDiscounts = totalShopDiscounts.add(order.getPlatformDiscount());
            order.setFinalAmount(order.getTotalGoodsAmount()
                    .add(order.getTotalShippingFee())
                    .subtract(totalDiscounts)
                    .max(BigDecimal.ZERO));

            long orderId;
            String orderCode = "ORD-" + System.currentTimeMillis() + "-" + (int) (Math.random() * 9000 + 1000);
            order.setOrderCode(orderCode);

            // A. INSERT ORDERS
            try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, orderCode);
                ps.setLong(2, order.getCustomerId());
                if (order.getCouponId() != null) {
                    ps.setInt(3, order.getCouponId());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setBigDecimal(4, order.getTotalGoodsAmount());
                ps.setBigDecimal(5, order.getTotalShippingFee());
                ps.setBigDecimal(6, order.getPlatformDiscount());
                ps.setBigDecimal(7, order.getFinalAmount());
                ps.setString(8, order.getPaymentStatus() != null
                        ? order.getPaymentStatus() : PaymentStatus.PENDING.name());
                ps.setString(9, paymentMethod != null && !paymentMethod.trim().isEmpty()
                        ? paymentMethod : PaymentMethod.COD.name());
                ps.setString(10, order.getOrderStatus() != null
                        ? order.getOrderStatus() : OrderStatus.PROCESSING.name());

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
                String subCode = "SUB-" + System.currentTimeMillis() + "-" + sub.getShopId() + "-" + (int) (Math.random() * 900 + 100);
                sub.setSubOrderCode(subCode);
                BigDecimal commissionRate = new BigDecimal("8.00");
                BigDecimal commissionAmount = sub.getShopSubtotal().multiply(new BigDecimal("0.08")).setScale(2, RoundingMode.HALF_UP);

                try (PreparedStatement ps = conn.prepareStatement(insertSubOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, subCode);
                    ps.setLong(2, orderId);
                    ps.setLong(3, sub.getShopId());
                    ps.setString(4, sub.getDeliverySlot());
                    ps.setBigDecimal(5, sub.getShopSubtotal());
                    ps.setBigDecimal(6, sub.getShopShippingFee());
                    ps.setBigDecimal(7, sub.getShopDiscount());
                    ps.setBigDecimal(8, sub.getShopTotal());
                    ps.setBigDecimal(9, commissionRate);
                    ps.setBigDecimal(10, commissionAmount);
                    ps.setString(11, sub.getStatus() != null
                            ? sub.getStatus() : SubOrderStatus.NEW.name());

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

                // D. INSERT Tá»ªNG ORDER_ITEM
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

                    // E. TRá»ª Tá»’N KHO NGUYÃŠN Tá»¬
                    if (item.getVariantId() != null) {
                        try (PreparedStatement ps = conn.prepareStatement(deductStockSql)) {
                            ps.setInt(1, item.getQuantity());
                            ps.setLong(2, item.getVariantId());
                            ps.setInt(3, item.getQuantity());
                            ps.setBigDecimal(4, item.getUnitPrice());

                            int updated = ps.executeUpdate();
                            if (updated == 0) {
                                throw new SQLException("Sáº£n pháº©m '" + item.getProductNameSnapshot()
                                        + "' vá»«a háº¿t hÃ ng, Ä‘á»•i giÃ¡ hoáº·c cá»­a hÃ ng Ä‘Ã£ ngá»«ng hoáº¡t Ä‘á»™ng. "
                                        + "Vui lÃ²ng quay láº¡i giá» hÃ ng Ä‘á»ƒ kiá»ƒm tra!");
                            }
                        }
                    }
                }
            }

            // F. XÃ“A CÃC Sáº¢N PHáº¨M ÄÃƒ MUA KHá»ŽI GIá»Ž HÃ€NG
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
                            throw new SQLException("CÃ³ sáº£n pháº©m khÃ´ng cÃ²n thuá»™c giá» hÃ ng cá»§a báº¡n!");
                        }
                    }
                }
            }

            // Chá»‰ tÄƒng used_count náº¿u má»i bÆ°á»›c táº¡o Ä‘Æ¡n, trá»« kho vÃ  xÃ³a giá» Ä‘á»u thÃ nh cÃ´ng.
            if (order.getCouponId() != null) {
                couponDAO.incrementUsage(conn, order.getCouponId());
            }
            for (SubOrder sub : order.getSubOrders()) {
                if (sub.getShopCouponId() != null) {
                    couponDAO.incrementUsage(conn, sub.getShopCouponId());
                }
            }

            // Ghi nháº­n phÆ°Æ¡ng thá»©c thanh toÃ¡n trong cÃ¹ng transaction.
            try (PreparedStatement ps = conn.prepareStatement(insertPaymentSql)) {
                ps.setLong(1, orderId);
                ps.setString(2, paymentMethod);
                ps.setString(3, PaymentMethod.COD.name().equals(paymentMethod)
                        ? PaymentType.CASH.name() : PaymentType.ONLINE.name());
                ps.setBigDecimal(4, order.getFinalAmount());
                ps.setString(5, PaymentTransactionStatus.PENDING.name());
                ps.executeUpdate();
            }

            conn.commit(); // THÃ€NH CÃ”NG -> COMMIT!
            return orderId;

        } catch (Exception ex) {
            try {
                conn.rollback(); // Lá»–I -> HOÃ€N TÃC TOÃ€N Bá»˜!
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
            throw new SQLException("KhÃ´ng cÃ³ sáº£n pháº©m nÃ o Ä‘Æ°á»£c chá»n Ä‘á»ƒ Ä‘áº·t hÃ ng!");
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
            throw new SQLException("Giá» hÃ ng vá»«a thay Ä‘á»•i. Vui lÃ²ng quay láº¡i giá» hÃ ng vÃ  kiá»ƒm tra láº¡i!");
        }
    }

    private void validateCouponForShop(Coupon coupon, long shopId, BigDecimal eligibleAmount) throws SQLException {
        if (coupon == null) {
            throw new SQLException("Mã giảm giá của cửa hàng không còn tồn tại!");
        }
        if (coupon.getShopId() == null || coupon.getShopId() != shopId) {
            throw new SQLException("Mã giảm giá không thuộc cửa hàng này!");
        }
        validateCouponForOrder(coupon, eligibleAmount);
    }

    private void validateCouponForOrder(Coupon coupon, BigDecimal eligibleAmount) throws SQLException {
        if (coupon == null) {
            throw new SQLException("MÃ£ giáº£m giÃ¡ khÃ´ng cÃ²n tá»“n táº¡i!");
        }
        if (!coupon.isActive()) {
            throw new SQLException("MÃ£ giáº£m giÃ¡ hiá»‡n khÃ´ng hoáº¡t Ä‘á»™ng!");
        }

        java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
        if (coupon.getStartDate() == null || now.before(coupon.getStartDate())) {
            throw new SQLException("MÃ£ giáº£m giÃ¡ chÆ°a Ä‘áº¿n thá»i gian sá»­ dá»¥ng!");
        }
        if (coupon.getEndDate() == null || now.after(coupon.getEndDate())) {
            throw new SQLException("MÃ£ giáº£m giÃ¡ Ä‘Ã£ háº¿t háº¡n!");
        }
        if (coupon.getUsedCount() >= coupon.getUsageLimit()) {
            throw new SQLException("MÃ£ giáº£m giÃ¡ Ä‘Ã£ háº¿t lÆ°á»£t sá»­ dá»¥ng!");
        }

        BigDecimal minimum = coupon.getMinOrderValue() != null
                ? coupon.getMinOrderValue() : BigDecimal.ZERO;
        if (eligibleAmount.compareTo(minimum) < 0) {
            throw new SQLException("ÄÆ¡n hÃ ng khÃ´ng cÃ²n Ä‘á»§ Ä‘iá»u kiá»‡n giÃ¡ trá»‹ tá»‘i thiá»ƒu cá»§a mÃ£ giáº£m giÃ¡!");
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
            throw new SQLException("Loáº¡i mÃ£ giáº£m giÃ¡ khÃ´ng há»£p lá»‡!");
        }

        if (coupon.getMaxDiscountAmount() != null
                && discount.compareTo(coupon.getMaxDiscountAmount()) > 0) {
            discount = coupon.getMaxDiscountAmount();
        }
        return discount.min(eligibleAmount).max(BigDecimal.ZERO)
                .setScale(2, java.math.RoundingMode.HALF_UP);
    }

    // 4. Láº¤Y CHI TIáº¾T ÄÆ N HÃ€NG THEO ID
    public Order getOrderById(long orderId) {
        String sqlOrder = "SELECT o.order_id, o.customer_id, o.coupon_id, o.total_goods_amount, "
                + "o.total_shipping_fee, o.platform_discount, o.final_amount, o.payment_status, o.payment_method, "
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
                        order.setPaymentMethod(rs.getString("payment_method"));
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
                // Láº¥y sub_orders
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

                            // Láº¥y order_items cá»§a tá»«ng sub_order
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

    public List<Order> getOrdersByCustomerId(long customerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.order_id, o.order_code, o.customer_id, o.coupon_id, "
                   + "       o.total_goods_amount, o.total_shipping_fee, o.platform_discount, "
                   + "       o.final_amount, o.payment_status, o.payment_method, "
                   + "       CASE "
                   + "           WHEN EXISTS (SELECT 1 FROM sub_orders so_c WHERE so_c.order_id = o.order_id) "
                   + "                AND NOT EXISTS (SELECT 1 FROM sub_orders so_nc WHERE so_nc.order_id = o.order_id AND so_nc.status <> 'CANCELLED') THEN 'CANCELLED' "
                   + "           ELSE o.order_status "
                   + "       END AS order_status, o.created_at, o.updated_at, "
                   + "       (SELECT STRING_AGG(CONCAT(oi.product_name_snapshot, ' (x', oi.quantity, ')'), ', ') "
                   + "        FROM order_items oi "
                   + "        JOIN sub_orders so ON oi.sub_order_id = so.sub_order_id "
                   + "        WHERE so.order_id = o.order_id) AS items_summary "
                   + "FROM orders o "
                   + "WHERE o.customer_id = ? "
                   + "ORDER BY o.created_at DESC";

        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order(
                        rs.getLong("order_id"),
                        rs.getString("order_code"),
                        rs.getLong("customer_id"),
                        rs.getObject("coupon_id") != null ? rs.getInt("coupon_id") : null,
                        rs.getDouble("total_goods_amount"),
                        rs.getDouble("total_shipping_fee"),
                        rs.getDouble("platform_discount"),
                        rs.getDouble("final_amount"),
                        rs.getString("payment_status"),
                        rs.getString("payment_method"),
                        rs.getString("order_status"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at"),
                        rs.getString("items_summary")
                    );

                    loadOrderItemsAndShop(order);
                    loadShippingAddress(order);
                    list.add(order);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getOrdersByCustomerId for customerId: " + customerId, ex);
        }
        return list;
    }

    private void loadOrderItemsAndShop(Order order) {
        String itemSql = "SELECT oi.order_item_id, oi.sub_order_id, oi.variant_id, oi.product_name_snapshot, "
                       + "       oi.variant_name_snapshot, oi.unit, oi.unit_price, oi.quantity, "
                       + "       oi.total_price, s.shop_name, s.logo_url, "
                       + "       (SELECT TOP 1 pi.image_url FROM product_images pi "
                       + "        JOIN product_variants pv ON pi.product_id = pv.product_id "
                       + "        WHERE pv.variant_id = oi.variant_id ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) AS product_image "
                       + "FROM order_items oi "
                       + "JOIN sub_orders so ON oi.sub_order_id = so.sub_order_id "
                       + "JOIN shops s ON so.shop_id = s.shop_id "
                       + "WHERE so.order_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(itemSql)) {
            ps.setLong(1, order.getOrderId());
            try (ResultSet rs = ps.executeQuery()) {
                List<OrderItem> items = new ArrayList<>();
                String firstShopName = null;
                String firstShopLogo = null;

                while (rs.next()) {
                    String prodImg = rs.getString("product_image");
                    if (prodImg == null || prodImg.trim().isEmpty()) {
                        prodImg = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop";
                    }
                    OrderItem item = new OrderItem(
                        rs.getLong("order_item_id"),
                        rs.getLong("sub_order_id"),
                        rs.getString("product_name_snapshot"),
                        rs.getString("variant_name_snapshot"),
                        rs.getString("unit"),
                        rs.getDouble("unit_price"),
                        rs.getInt("quantity"),
                        rs.getDouble("total_price"),
                        prodImg
                    );
                    items.add(item);

                    if (firstShopName == null) {
                        firstShopName = rs.getString("shop_name");
                        firstShopLogo = rs.getString("logo_url");
                    }
                }

                order.setItems(items);
                if (firstShopName != null) {
                    order.setShopName(firstShopName);
                    order.setShopLogoUrl(firstShopLogo);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in loadOrderItemsAndShop for orderId: " + order.getOrderId(), ex);
        }
    }

    private void loadShippingAddress(Order order) {
        String sql = "SELECT recipient_name, recipient_phone, street_address, ward, district, city "
                   + "FROM order_shipping_addresses WHERE order_id = ?";
        Connection conn = getConnection();
        if (conn == null) return;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, order.getOrderId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ShippingAddress addr = new ShippingAddress(
                        order.getOrderId(),
                        rs.getString("recipient_name"),
                        rs.getString("recipient_phone"),
                        rs.getString("street_address"),
                        rs.getString("ward"),
                        rs.getString("district"),
                        rs.getString("city")
                    );
                    order.setShippingAddress(addr);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading shipping address for orderId: " + order.getOrderId(), ex);
        }
    }

    public List<SubOrder> getSubOrdersByCustomerId(long customerId) {
        List<SubOrder> list = new ArrayList<>();
        String sql = "SELECT so.sub_order_id, so.sub_order_code, so.order_id, o.order_code, o.customer_id, "
                   + "       so.shop_id, sh.shop_name, sh.logo_url, so.delivery_slot, "
                   + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                   + "       so.status AS sub_order_status, so.cancel_reason, so.cancelled_by, so.cancelled_at, "
                   + "       so.created_at, so.updated_at, "
                   + "       o.payment_method, o.payment_status, o.platform_discount, "
                   + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city, "
                   + "       drv.full_name AS driver_name, drv.phone AS driver_phone "
                   + "FROM sub_orders so "
                   + "JOIN orders o ON so.order_id = o.order_id "
                   + "JOIN shops sh ON so.shop_id = sh.shop_id "
                   + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                   + "LEFT JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
                   + "LEFT JOIN users drv ON d.driver_id = drv.user_id "
                   + "WHERE o.customer_id = ? "
                   + "ORDER BY so.created_at DESC, so.sub_order_id DESC";

        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SubOrder so = new SubOrder();
                    so.setSubOrderId(rs.getLong("sub_order_id"));
                    so.setSubOrderCode(rs.getString("sub_order_code"));
                    so.setOrderId(rs.getLong("order_id"));
                    so.setOrderCode(rs.getString("order_code"));
                    so.setShopId(rs.getLong("shop_id"));
                    so.setShopName(rs.getString("shop_name"));
                    so.setShopLogoUrl(rs.getString("logo_url"));
                    so.setDeliverySlot(rs.getString("delivery_slot"));
                    so.setShopSubtotal(rs.getBigDecimal("shop_subtotal"));
                    so.setShopShippingFee(rs.getBigDecimal("shop_shipping_fee"));
                    so.setShopDiscount(rs.getBigDecimal("shop_discount"));
                    so.setShopTotal(rs.getBigDecimal("shop_total"));
                    so.setStatus(rs.getString("sub_order_status"));
                    so.setCancelReason(rs.getString("cancel_reason"));
                    so.setCancelledBy(rs.getObject("cancelled_by") != null ? rs.getLong("cancelled_by") : null);
                    so.setCancelledAt(rs.getTimestamp("cancelled_at"));
                    so.setCreatedAt(rs.getTimestamp("created_at"));
                    so.setUpdatedAt(rs.getTimestamp("updated_at"));
                    so.setPaymentMethod(rs.getString("payment_method"));
                    so.setPaymentStatus(rs.getString("payment_status"));
                    so.setDriverName(rs.getString("driver_name"));
                    so.setDriverPhone(rs.getString("driver_phone"));

                    if (rs.getString("recipient_name") != null) {
                        ShippingAddress addr = new ShippingAddress(
                            rs.getLong("order_id"),
                            rs.getString("recipient_name"),
                            rs.getString("recipient_phone"),
                            rs.getString("street_address"),
                            rs.getString("ward"),
                            rs.getString("district"),
                            rs.getString("city")
                        );
                        so.setShippingAddress(addr);
                    }

                    list.add(so);
                }
            }

            // Tải chi tiết sản phẩm cho từng subOrder
            String itemSql = "SELECT oi.order_item_id, oi.sub_order_id, oi.variant_id, oi.product_name_snapshot, "
                           + "       oi.variant_name_snapshot, oi.unit, oi.unit_price, oi.quantity, "
                           + "       oi.total_price, "
                           + "       (SELECT TOP 1 pi.image_url FROM product_images pi "
                           + "        JOIN product_variants pv ON pi.product_id = pv.product_id "
                           + "        WHERE pv.variant_id = oi.variant_id ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) AS product_image "
                           + "FROM order_items oi "
                           + "WHERE oi.sub_order_id = ?";

            try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                for (SubOrder so : list) {
                    psItem.setLong(1, so.getSubOrderId());
                    try (ResultSet rsItem = psItem.executeQuery()) {
                        List<OrderItem> items = new ArrayList<>();
                        while (rsItem.next()) {
                            String prodImg = rsItem.getString("product_image");
                            if (prodImg == null || prodImg.trim().isEmpty()) {
                                prodImg = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop";
                            }
                            OrderItem item = new OrderItem(
                                rsItem.getLong("order_item_id"),
                                rsItem.getLong("sub_order_id"),
                                rsItem.getString("product_name_snapshot"),
                                rsItem.getString("variant_name_snapshot"),
                                rsItem.getString("unit"),
                                rsItem.getDouble("unit_price"),
                                rsItem.getInt("quantity"),
                                rsItem.getDouble("total_price"),
                                prodImg
                            );
                            items.add(item);
                        }
                        so.setItems(items);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getSubOrdersByCustomerId for customerId: " + customerId, ex);
        }
        return list;
    }

    public boolean cancelOrderByCustomer(long customerId, String orderIdentifier, String cancelReason) throws Exception {
        String findSubSql = "SELECT so.sub_order_id, so.order_id, so.status AS sub_status, o.customer_id, o.coupon_id "
                          + "FROM sub_orders so "
                          + "JOIN orders o ON so.order_id = o.order_id "
                          + "WHERE (so.sub_order_code = ? OR CAST(so.sub_order_id AS VARCHAR) = ?) AND o.customer_id = ?";

        String findOrdSql = "SELECT order_id, order_code, customer_id, coupon_id, order_status "
                          + "FROM orders "
                          + "WHERE (order_code = ? OR CAST(order_id AS VARCHAR) = ?) AND customer_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }

        try {
            conn.setAutoCommit(false);

            long matchedSubOrderId = -1;
            long matchedOrderId = -1;
            String status = null;
            Integer couponId = null;

            // 1. Thử tìm theo SubOrder trước
            try (PreparedStatement psSub = conn.prepareStatement(findSubSql)) {
                psSub.setString(1, orderIdentifier);
                psSub.setString(2, orderIdentifier);
                psSub.setLong(3, customerId);
                try (ResultSet rsSub = psSub.executeQuery()) {
                    if (rsSub.next()) {
                        matchedSubOrderId = rsSub.getLong("sub_order_id");
                        matchedOrderId = rsSub.getLong("order_id");
                        status = (rsSub.getString("sub_status") != null ? rsSub.getString("sub_status") : "").toUpperCase();
                        if (rsSub.getObject("coupon_id") != null) {
                            couponId = rsSub.getInt("coupon_id");
                        }
                    }
                }
            }

            // 2. Nếu không tìm thấy SubOrder, thử tìm theo Parent Order
            if (matchedSubOrderId == -1) {
                try (PreparedStatement psOrd = conn.prepareStatement(findOrdSql)) {
                    psOrd.setString(1, orderIdentifier);
                    psOrd.setString(2, orderIdentifier);
                    psOrd.setLong(3, customerId);
                    try (ResultSet rsOrd = psOrd.executeQuery()) {
                        if (rsOrd.next()) {
                            matchedOrderId = rsOrd.getLong("order_id");
                            status = (rsOrd.getString("order_status") != null ? rsOrd.getString("order_status") : "").toUpperCase();
                            if (rsOrd.getObject("coupon_id") != null) {
                                couponId = rsOrd.getInt("coupon_id");
                            }
                        } else {
                            throw new IllegalArgumentException("Không tìm thấy đơn hàng hoặc bạn không có quyền hủy đơn này!");
                        }
                    }
                }
            }

            if ("SHIPPING".equals(status) || "DELIVERING".equals(status) || "IN_TRANSIT".equals(status)) {
                throw new IllegalStateException("Đơn hàng đang trong quá trình vận chuyển giao hàng, không thể hủy!");
            }
            if (OrderStatus.COMPLETED.name().equals(status) || SubOrderStatus.DELIVERED.name().equals(status)) {
                throw new IllegalStateException("Đơn hàng đã được giao thành công, không thể hủy!");
            }
            if ("CANCELLED".equals(status) || "CANCELED".equals(status)) {
                throw new IllegalStateException("Đơn hàng này đã được hủy trước đó!");
            }

            String reasonToSave = (cancelReason != null && !cancelReason.trim().isEmpty()) ? cancelReason.trim() : "Người mua hủy đơn trực tiếp";

            if (matchedSubOrderId != -1) {
                // Hủy cụ thể 1 SubOrder
                String restoreStockSql = "UPDATE pv SET pv.stock_quantity = pv.stock_quantity + oi.quantity, "
                                       + "       pv.updated_at = CURRENT_TIMESTAMP "
                                       + "FROM product_variants pv "
                                       + "INNER JOIN order_items oi ON pv.variant_id = oi.variant_id "
                                       + "WHERE oi.sub_order_id = ? AND oi.variant_id IS NOT NULL";
                try (PreparedStatement psStock = conn.prepareStatement(restoreStockSql)) {
                    psStock.setLong(1, matchedSubOrderId);
                    psStock.executeUpdate();
                }

                String cancelSubSql = "UPDATE sub_orders SET status = 'CANCELLED', cancel_reason = ?, "
                                    + "       cancelled_by = ?, cancelled_at = CURRENT_TIMESTAMP, "
                                    + "       updated_at = CURRENT_TIMESTAMP "
                                    + "WHERE sub_order_id = ?";
                try (PreparedStatement psCancelSub = conn.prepareStatement(cancelSubSql)) {
                    psCancelSub.setNString(1, reasonToSave);
                    psCancelSub.setLong(2, customerId);
                    psCancelSub.setLong(3, matchedSubOrderId);
                    psCancelSub.executeUpdate();
                }

                // Đồng bộ trạng thái đơn cha nếu tất cả sub_orders đều đã CANCELLED
                String syncParentSql = "UPDATE o SET o.order_status = '" + OrderStatus.CANCELLED.name()
                                     + "', o.updated_at = CURRENT_TIMESTAMP "
                                     + "FROM orders o "
                                     + "WHERE o.order_id = ? "
                                     + "  AND NOT EXISTS ( "
                                     + "      SELECT 1 FROM sub_orders other "
                                     + "      WHERE other.order_id = o.order_id "
                                     + "        AND other.status <> 'CANCELLED' "
                                     + "  )";
                try (PreparedStatement psSync = conn.prepareStatement(syncParentSql)) {
                    psSync.setLong(1, matchedOrderId);
                    psSync.executeUpdate();
                }
            } else {
                // Hủy toàn bộ đơn cha
                String restoreStockSql = "UPDATE pv SET pv.stock_quantity = pv.stock_quantity + oi.quantity, "
                                       + "       pv.updated_at = CURRENT_TIMESTAMP "
                                       + "FROM product_variants pv "
                                       + "INNER JOIN order_items oi ON pv.variant_id = oi.variant_id "
                                       + "INNER JOIN sub_orders so ON oi.sub_order_id = so.sub_order_id "
                                       + "WHERE so.order_id = ? AND oi.variant_id IS NOT NULL";
                try (PreparedStatement psStock = conn.prepareStatement(restoreStockSql)) {
                    psStock.setLong(1, matchedOrderId);
                    psStock.executeUpdate();
                }

                String cancelSubsSql = "UPDATE sub_orders SET status = 'CANCELLED', cancel_reason = ?, "
                                     + "       cancelled_by = ?, cancelled_at = CURRENT_TIMESTAMP, "
                                     + "       updated_at = CURRENT_TIMESTAMP "
                                     + "WHERE order_id = ?";
                try (PreparedStatement psSubs = conn.prepareStatement(cancelSubsSql)) {
                    psSubs.setNString(1, reasonToSave);
                    psSubs.setLong(2, customerId);
                    psSubs.setLong(3, matchedOrderId);
                    psSubs.executeUpdate();
                }

                String cancelOrderSql = "UPDATE orders SET order_status = '" + OrderStatus.CANCELLED.name()
                                      + "', updated_at = CURRENT_TIMESTAMP "
                                      + "WHERE order_id = ?";
                try (PreparedStatement psOrder = conn.prepareStatement(cancelOrderSql)) {
                    psOrder.setLong(1, matchedOrderId);
                    psOrder.executeUpdate();
                }

                if (couponId != null) {
                    String restoreCouponSql = "UPDATE coupons SET used_count = CASE WHEN used_count > 0 THEN used_count - 1 ELSE 0 END "
                                            + "WHERE coupon_id = ?";
                    try (PreparedStatement psCoupon = conn.prepareStatement(restoreCouponSql)) {
                        psCoupon.setInt(1, couponId);
                        psCoupon.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception ex) {
            try {
                conn.rollback();
            } catch (SQLException rEx) {
                LOGGER.log(Level.SEVERE, "Rollback failed during cancelOrderByCustomer", rEx);
            }
            LOGGER.log(Level.SEVERE, "Error in cancelOrderByCustomer for order: " + orderIdentifier, ex);
            throw ex;
        } finally {
            try {
                conn.close();
            } catch (SQLException cEx) {
                LOGGER.log(Level.SEVERE, "Error closing connection", cEx);
            }
        }
    }
}
