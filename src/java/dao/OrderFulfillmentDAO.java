package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.OrderItem;
import model.ShippingAddress;
import model.SubOrder;
import enums.SubOrderStatus;
import util.DBContext;

public class OrderFulfillmentDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(OrderFulfillmentDAO.class.getName());

    public SubOrder getSubOrderDetails(String subOrderCode) {
        String sql = "SELECT so.sub_order_id, so.sub_order_code, so.order_id, so.shop_id, so.delivery_slot, "
                + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                + "       so.status, so.cancel_reason, so.cancelled_at, so.created_at, so.updated_at, "
                + "       s.shop_name, "
                + "       o.order_code, o.payment_status, o.payment_method, o.created_at AS order_created_at, "
                + "       u.full_name AS customer_name, u.phone AS customer_phone, "
                + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city, "
                + "       d.tracking_number, d.delivery_status, d.failure_reason, d.proof_image_url, d.delivered_at, "
                + "       d.driver_id, "
                + "       u_driver.full_name AS driver_name, u_driver.phone AS driver_phone, u_driver.avatar_url AS driver_avatar, "
                + "       dp.vehicle_plate AS driver_vehicle_plate, dp.vehicle_type AS driver_vehicle_type "
                + "FROM sub_orders so "
                + "JOIN orders o ON so.order_id = o.order_id "
                + "LEFT JOIN shops s ON so.shop_id = s.shop_id "
                + "LEFT JOIN users u ON o.customer_id = u.user_id "
                + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                + "LEFT JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
                + "LEFT JOIN users u_driver ON d.driver_id = u_driver.user_id "
                + "LEFT JOIN driver_profiles dp ON dp.user_id = d.driver_id "
                + "WHERE so.sub_order_code = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return null;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subOrderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SubOrder so = new SubOrder();
                    so.setSubOrderId(rs.getLong("sub_order_id"));
                    so.setSubOrderCode(rs.getString("sub_order_code"));
                    so.setOrderId(rs.getLong("order_id"));
                    so.setOrderCode(rs.getString("order_code"));
                    so.setShopId(rs.getLong("shop_id"));
                    so.setShopName(rs.getString("shop_name"));
                    so.setDeliverySlot(rs.getString("delivery_slot"));
                    so.setShopSubtotal(rs.getBigDecimal("shop_subtotal"));
                    so.setShopShippingFee(rs.getBigDecimal("shop_shipping_fee"));
                    so.setShopDiscount(rs.getBigDecimal("shop_discount"));
                    so.setShopTotal(rs.getBigDecimal("shop_total"));
                    so.setStatus(rs.getString("status"));
                    so.setCancelReason(rs.getString("cancel_reason"));
                    so.setCancelledAt(rs.getTimestamp("cancelled_at"));
                    so.setPaymentMethod(rs.getString("payment_method"));
                    so.setPaymentStatus(rs.getString("payment_status"));
                    so.setCreatedAt(rs.getTimestamp("created_at"));
                    so.setUpdatedAt(rs.getTimestamp("updated_at"));

                    so.setTrackingNumber(rs.getString("tracking_number"));
                    so.setDeliveryStatus(rs.getString("delivery_status"));
                    so.setFailureReason(rs.getString("failure_reason"));
                    so.setProofImageUrl(rs.getString("proof_image_url"));
                    so.setDeliveredAt(rs.getTimestamp("delivered_at"));
                    so.setDriverName(rs.getString("driver_name"));
                    so.setDriverPhone(rs.getString("driver_phone"));

                    // Shipping Address
                    ShippingAddress addr = new ShippingAddress();
                    addr.setOrderId(rs.getLong("order_id"));
                    addr.setRecipientName(rs.getString("recipient_name"));
                    addr.setRecipientPhone(rs.getString("recipient_phone"));
                    addr.setStreetAddress(rs.getString("street_address"));
                    addr.setWard(rs.getString("ward"));
                    addr.setDistrict(rs.getString("district"));
                    addr.setCity(rs.getString("city"));
                    so.setShippingAddress(addr);

                    so.setItems(getOrderItemsBySubOrderId(so.getSubOrderId()));
                    return so;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting suborder details for " + subOrderCode, ex);
        }
        return null;
    }

    public List<OrderItem> getOrderItemsBySubOrderId(long subOrderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = "SELECT oi.order_item_id, oi.sub_order_id, oi.variant_id, oi.product_name_snapshot, "
                + "       oi.variant_name_snapshot, oi.sku_snapshot, oi.unit, oi.unit_price, oi.quantity, oi.total_price, "
                + "       pv.stock_quantity, pv.weight_kg, "
                + "       p.origin, p.certification, p.storage_temp, "
                + "       (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = p.product_id ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) AS image_url "
                + "FROM order_items oi "
                + "LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "LEFT JOIN products p ON pv.product_id = p.product_id "
                + "WHERE oi.sub_order_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem(
                            rs.getLong("order_item_id"),
                            rs.getLong("sub_order_id"),
                            rs.getLong("variant_id"),
                            rs.getString("product_name_snapshot"),
                            rs.getString("variant_name_snapshot"),
                            rs.getString("sku_snapshot"),
                            rs.getString("unit"),
                            rs.getBigDecimal("unit_price"),
                            rs.getInt("quantity"),
                            rs.getBigDecimal("total_price"));

                    item.setStockQuantity(rs.getInt("stock_quantity"));
                    item.setWeightKg(rs.getBigDecimal("weight_kg"));
                    item.setOrigin(rs.getString("origin"));
                    item.setCertification(rs.getString("certification"));
                    item.setStorageTemp(rs.getString("storage_temp"));
                    item.setImageUrl(rs.getString("image_url"));

                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting items for subOrderId " + subOrderId, ex);
        }
        return list;
    }

    public boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus) {
        if (newStatus == null)
            return false;
        String sql = "UPDATE sub_orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_code = ?";
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus.name());
            ps.setString(2, subOrderCode);
            int updated = ps.executeUpdate();
            if (updated > 0) {
                // Synchronize parent order status
                if (newStatus == SubOrderStatus.SHIPPING) {
                    String syncShipping = "UPDATE o SET o.order_status = 'SHIPPING', o.updated_at = CURRENT_TIMESTAMP "
                            + "FROM orders o JOIN sub_orders so ON o.order_id = so.order_id WHERE so.sub_order_code = ?";
                    try (PreparedStatement psSync = conn.prepareStatement(syncShipping)) {
                        psSync.setString(1, subOrderCode);
                        psSync.executeUpdate();
                    }

                    // Auto-assign delivery task to optimal online cold-chain driver
                    String getSubIdSql = "SELECT sub_order_id FROM sub_orders WHERE sub_order_code = ?";
                    try (PreparedStatement psSubId = conn.prepareStatement(getSubIdSql)) {
                        psSubId.setString(1, subOrderCode);
                        try (ResultSet rsSubId = psSubId.executeQuery()) {
                            if (rsSubId.next()) {
                                long subOrderId = rsSubId.getLong("sub_order_id");
                                new DriverDAO().autoAssignDelivery(subOrderId);
                            }
                        }
                    }
                } else if (newStatus == SubOrderStatus.DELIVERED) {
                    String syncDelivered = "UPDATE o SET o.order_status = 'COMPLETED', o.updated_at = CURRENT_TIMESTAMP "
                            + "FROM orders o JOIN sub_orders so ON o.order_id = so.order_id "
                            + "WHERE so.sub_order_code = ? "
                            + "  AND NOT EXISTS (SELECT 1 FROM sub_orders other WHERE other.order_id = o.order_id AND other.status <> '"
                            + SubOrderStatus.DELIVERED.name() + "')";
                    try (PreparedStatement psSync = conn.prepareStatement(syncDelivered)) {
                        psSync.setString(1, subOrderCode);
                        psSync.executeUpdate();
                    }
                }
                return true;
            }
            return false;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating sub_orders status to " + newStatus, ex);
            return false;
        }
    }

    public List<SubOrder> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword) {
        List<SubOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT so.sub_order_id, so.sub_order_code, so.order_id, so.shop_id, so.delivery_slot, "
                        + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                        + "       so.status, so.cancel_reason, so.created_at, so.updated_at, "
                        + "       o.order_code, o.payment_status, o.payment_method, "
                        + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.city "
                        + "FROM sub_orders so "
                        + "JOIN orders o ON so.order_id = o.order_id "
                        + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                        + "WHERE 1=1 ");
        if (shopId > 0) {
            sql.append(" AND so.shop_id = ? ");
        }
        if (status != null) {
            sql.append(" AND so.status = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (so.sub_order_code LIKE ? OR o.order_code LIKE ? OR osa.recipient_name LIKE ? OR osa.recipient_phone LIKE ?) ");
        }
        sql.append(" ORDER BY so.created_at DESC");

        Connection conn = getConnection();
        if (conn == null)
            return list;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (shopId > 0) {
                ps.setLong(paramIndex++, shopId);
            }
            if (status != null) {
                ps.setString(paramIndex++, status.name());
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SubOrder so = new SubOrder();
                    so.setSubOrderId(rs.getLong("sub_order_id"));
                    so.setSubOrderCode(rs.getString("sub_order_code"));
                    so.setOrderId(rs.getLong("order_id"));
                    so.setOrderCode(rs.getString("order_code"));
                    so.setShopId(rs.getLong("shop_id"));
                    so.setDeliverySlot(rs.getString("delivery_slot"));
                    so.setShopSubtotal(rs.getBigDecimal("shop_subtotal"));
                    so.setShopShippingFee(rs.getBigDecimal("shop_shipping_fee"));
                    so.setShopDiscount(rs.getBigDecimal("shop_discount"));

                    BigDecimal total = rs.getBigDecimal("shop_total");
                    if (total != null) {
                        // so.setShopTotal(total.add(new BigDecimal("10000")));
                        so.setShopTotal(rs.getBigDecimal("shop_total"));
                    }

                    so.setStatus(rs.getString("status"));
                    so.setCancelReason(rs.getString("cancel_reason"));
                    so.setPaymentMethod(rs.getString("payment_method"));
                    so.setPaymentStatus(rs.getString("payment_status"));
                    so.setCreatedAt(rs.getTimestamp("created_at"));
                    so.setUpdatedAt(rs.getTimestamp("updated_at"));

                    ShippingAddress addr = new ShippingAddress();
                    addr.setRecipientName(rs.getString("recipient_name"));
                    addr.setRecipientPhone(rs.getString("recipient_phone"));
                    addr.setStreetAddress(rs.getString("street_address"));
                    addr.setCity(rs.getString("city"));
                    so.setShippingAddress(addr);

                    so.setItems(getOrderItemsBySubOrderId(so.getSubOrderId()));
                    list.add(so);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting suborders for shop " + shopId, ex);
        }
        return list;
    }

    public int countSubOrdersByShop(long shopId, SubOrderStatus status) {
        boolean isAll = (status == null);

        String sql = isAll
                ? "SELECT COUNT(*) FROM sub_orders WHERE shop_id = ?"
                : "SELECT COUNT(*) FROM sub_orders WHERE shop_id = ? AND status = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return 0;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            if (!isAll) {
                ps.setString(2, status.name());
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting suborders for shop " + shopId, ex);
        }
        return 0;
    }

    public String getFirstSubOrderCode(long shopId) {
        String sql = "SELECT TOP 1 sub_order_code FROM sub_orders WHERE shop_id = ? "
                + "ORDER BY CASE "
                + "  WHEN status = '" + SubOrderStatus.NEW.name() + "' THEN 1 "
                + "  WHEN status = '" + SubOrderStatus.PACKING.name() + "' THEN 2 "
                + "  WHEN status = '" + SubOrderStatus.SHIPPING.name() + "' THEN 3 "
                + "  ELSE 4 END ASC, sub_order_id DESC";
        Connection conn = getConnection();
        if (conn == null)
            return null;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("sub_order_code");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting first suborder code for shop " + shopId, ex);
        }
        return null;
    }

    public boolean cancelSubOrder(String subOrderCode, String cancelReason, Long cancelledBy) {
        String sql = "UPDATE sub_orders SET status = '" + SubOrderStatus.CANCELLED.name()
                + "', cancel_reason = ?, cancelled_by = ?, "
                + "       cancelled_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP "
                + "WHERE sub_order_code = ?";
        Connection conn = getConnection();
        if (conn == null)
            return false;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, cancelReason);
            if (cancelledBy != null) {
                ps.setLong(2, cancelledBy);
            } else {
                ps.setNull(2, java.sql.Types.BIGINT);
            }
            ps.setString(3, subOrderCode);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Synchronize parent order status if all sub_orders are CANCELLED
                String syncSql = "UPDATE o SET o.order_status = '" + SubOrderStatus.CANCELLED.name()
                        + "', o.updated_at = CURRENT_TIMESTAMP "
                        + "FROM orders o "
                        + "JOIN sub_orders so ON o.order_id = so.order_id "
                        + "WHERE so.sub_order_code = ? "
                        + "  AND NOT EXISTS ( "
                        + "      SELECT 1 FROM sub_orders other "
                        + "      WHERE other.order_id = o.order_id "
                        + "        AND other.status <> '" + SubOrderStatus.CANCELLED.name() + "' "
                        + "  )";
                try (PreparedStatement psSync = conn.prepareStatement(syncSql)) {
                    psSync.setString(1, subOrderCode);
                    psSync.executeUpdate();
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error cancelling sub order: " + subOrderCode, e);
            return false;
        }
    }

    public boolean isSubOrderOwnedByShop(long subOrderId, long shopId) {
        String sql = "SELECT 1 FROM sub_orders WHERE sub_order_id = ? AND shop_id = ?";
        Connection conn = getConnection();
        if (conn == null)
            return false;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, subOrderId);
            ps.setLong(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking suborder shop ownership", e);
            return false;
        }
    }
}
