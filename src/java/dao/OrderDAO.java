package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Order;
import model.OrderItem;
import model.ShippingAddress;
import util.DBContext;

public class OrderDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

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
        String itemSql = "SELECT oi.order_item_id, oi.sub_order_id, oi.product_name_snapshot, "
                       + "       oi.variant_name_snapshot, oi.unit, oi.unit_price, oi.quantity, "
                       + "       oi.total_price, s.shop_name, s.logo_url "
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
                    OrderItem item = new OrderItem(
                        rs.getLong("order_item_id"),
                        rs.getLong("sub_order_id"),
                        rs.getString("product_name_snapshot"),
                        rs.getString("variant_name_snapshot"),
                        rs.getString("unit"),
                        rs.getDouble("unit_price"),
                        rs.getInt("quantity"),
                        rs.getDouble("total_price"),
                        rs.getString("logo_url")
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
}
