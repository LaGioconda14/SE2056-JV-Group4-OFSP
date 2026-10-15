package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.VoucherCartItem;
import model.VoucherCoupon;
import util.DBContext;

public class CartVoucherDAO extends DBContext {

    public Map<Long, VoucherCartItem> findCartItems(long customerId) throws SQLException {
        String sql = "SELECT ci.cart_item_id, p.shop_id, pv.price, pv.stock_quantity, "
                + "pv.is_active AS variant_active, p.is_active AS product_active, s.status AS shop_status "
                + "FROM carts c INNER JOIN cart_items ci ON ci.cart_id = c.cart_id "
                + "INNER JOIN product_variants pv ON pv.variant_id = ci.variant_id "
                + "INNER JOIN products p ON p.product_id = pv.product_id "
                + "INNER JOIN shops s ON s.shop_id = p.shop_id "
                + "WHERE c.customer_id = ? ORDER BY ci.cart_item_id";
        Map<Long, VoucherCartItem> items = new LinkedHashMap<>();
        try (Connection connection = requireConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, customerId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    long itemId = result.getLong("cart_item_id");
                    items.put(itemId, new VoucherCartItem(itemId, result.getLong("shop_id"),
                            result.getBigDecimal("price"), result.getInt("stock_quantity"),
                            result.getBoolean("variant_active") && result.getBoolean("product_active")
                            && "ACTIVE".equalsIgnoreCase(result.getString("shop_status"))));
                }
            }
        }
        return items;
    }

    public List<VoucherCoupon> findActiveCoupons(long customerId) throws SQLException {
        String sql = "SELECT c.coupon_id, c.code, c.issuer_type, c.shop_id, s.shop_name, "
                + "c.apply_to, c.discount_type, c.discount_value, c.min_order_value, "
                + "c.max_discount_amount, c.end_date, "
                + "uc.user_coupon_id, uc.per_user_limit, uc.used_count AS user_used_count "
                + "FROM coupons c "
                + "LEFT JOIN shops s ON s.shop_id = c.shop_id "
                + "LEFT JOIN user_coupons uc ON uc.coupon_id = c.coupon_id AND uc.user_id = ? "
                + "WHERE c.is_active = 1 AND c.start_date <= CURRENT_TIMESTAMP "
                + "AND c.end_date > CURRENT_TIMESTAMP AND c.used_count < c.usage_limit "
                + "AND (c.issuer_type = 'PLATFORM' OR (c.issuer_type = 'SHOP' AND s.status = 'ACTIVE')) "
                + "ORDER BY c.end_date, c.coupon_id";
        List<VoucherCoupon> coupons = new ArrayList<>();
        try (Connection connection = requireConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, customerId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    long shopId = result.getLong("shop_id");
                    Long nullableShopId = result.wasNull() ? null : shopId;
                    result.getLong("user_coupon_id");
                    boolean inWallet = !result.wasNull();
                    int perUserLimit = inWallet ? result.getInt("per_user_limit") : 1;
                    int userUsedCount = inWallet ? result.getInt("user_used_count") : 0;
                    coupons.add(new VoucherCoupon(result.getLong("coupon_id"), result.getString("code"),
                            result.getString("issuer_type"), nullableShopId, result.getString("shop_name"),
                            result.getString("apply_to"), result.getString("discount_type"),
                            result.getBigDecimal("discount_value"), result.getBigDecimal("min_order_value"),
                            result.getBigDecimal("max_discount_amount"),
                            result.getTimestamp("end_date").toLocalDateTime(),
                            inWallet, perUserLimit, userUsedCount));
                }
            }
        }
        return coupons;
    }

    public List<VoucherCoupon> findActiveCoupons() throws SQLException {
        return findActiveCoupons(0);
    }

    private Connection requireConnection() throws SQLException {
        Connection connection = getConnection();
        if (connection == null) {
            throw new SQLException("Voucher lookup unavailable");
        }
        return connection;
    }
}
