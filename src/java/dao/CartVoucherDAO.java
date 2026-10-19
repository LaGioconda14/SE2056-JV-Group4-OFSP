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

    public List<VoucherCoupon> findActiveCoupons(long customerId, String scope, Long shopId) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT c.coupon_id, c.code, c.shop_id, s.shop_name, ")
                .append("c.discount_type, c.discount_value, c.min_order_value, ")
                .append("c.max_discount_amount, c.end_date, ")
                .append("CASE WHEN c.shop_id IS NULL THEN 'PLATFORM' ELSE 'SHOP' END AS issuer_type, ")
                .append("CASE WHEN c.discount_type = 'FREESHIP' THEN 'SHIPPING' ELSE 'PRODUCT' END AS apply_to ")
                .append("FROM coupons c ")
                .append("LEFT JOIN shops s ON s.shop_id = c.shop_id ")
                .append("WHERE c.is_active = 1 AND c.start_date <= CURRENT_TIMESTAMP ")
                .append("AND c.end_date > CURRENT_TIMESTAMP AND c.used_count < c.usage_limit ");

        if ("PLATFORM".equalsIgnoreCase(scope)) {
            sql.append("AND c.shop_id IS NULL ");
        } else if ("SHOP".equalsIgnoreCase(scope)) {
            sql.append("AND c.shop_id IS NOT NULL AND (s.status = 'ACTIVE' OR s.status IS NULL) ");
            if (shopId != null && shopId > 0) {
                sql.append("AND c.shop_id = ? ");
            }
        } else {
            sql.append("AND (c.shop_id IS NULL OR (c.shop_id IS NOT NULL AND (s.status = 'ACTIVE' OR s.status IS NULL))) ");
        }
        sql.append("ORDER BY c.end_date, c.coupon_id");

        List<VoucherCoupon> coupons = new ArrayList<>();
        try (Connection connection = requireConnection();
                PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            if ("SHOP".equalsIgnoreCase(scope) && shopId != null && shopId > 0) {
                statement.setLong(1, shopId);
            }
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    long sId = result.getLong("shop_id");
                    Long nullableShopId = result.wasNull() ? null : sId;
                    coupons.add(new VoucherCoupon(result.getLong("coupon_id"), result.getString("code"),
                            result.getString("issuer_type"), nullableShopId, result.getString("shop_name"),
                            result.getString("apply_to"), result.getString("discount_type"),
                            result.getBigDecimal("discount_value"), result.getBigDecimal("min_order_value"),
                            result.getBigDecimal("max_discount_amount"),
                            result.getTimestamp("end_date").toLocalDateTime(),
                            true, 1, 0));
                }
            }
        }
        return coupons;
    }

    public List<VoucherCoupon> findActiveCoupons(long customerId) throws SQLException {
        return findActiveCoupons(customerId, null, null);
    }

    public List<VoucherCoupon> findActiveCoupons() throws SQLException {
        return findActiveCoupons(0, null, null);
    }

    private Connection requireConnection() throws SQLException {
        Connection connection = getConnection();
        if (connection == null) {
            throw new SQLException("Voucher lookup unavailable");
        }
        return connection;
    }
}
