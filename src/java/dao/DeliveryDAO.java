package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Delivery;
import model.OrderItem;
import util.DBContext;

public class DeliveryDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(DeliveryDAO.class.getName());

    /**
     * Get list of deliveries assigned to a driver with status filter and keyword search
     */
    public List<Delivery> getDeliveriesByDriver(long driverId, String statusFilter, String keyword) {
        List<Delivery> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT d.delivery_id, d.sub_order_id, d.driver_id, d.tracking_number, d.delivery_status, "
            + "       d.proof_image_url, d.failure_reason, d.assigned_at, d.delivered_at, "
            + "       so.sub_order_code, so.shop_id, so.shop_total, so.delivery_slot, so.status AS sub_order_status, "
            + "       s.shop_name, s.phone AS shop_phone, s.address AS shop_address, s.province AS shop_province, "
            + "       o.payment_method, o.payment_status, "
            + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city "
            + "FROM deliveries d "
            + "JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
            + "JOIN orders o ON so.order_id = o.order_id "
            + "LEFT JOIN shops s ON so.shop_id = s.shop_id "
            + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
            + "WHERE d.driver_id = ? "
        );

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            if ("pickup".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND d.delivery_status IN ('ASSIGNING', 'ASSIGNED') ");
            } else if ("delivering".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND d.delivery_status IN ('DELIVERING', 'IN_TRANSIT', 'PICKED_UP') ");
            } else if ("completed".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND d.delivery_status IN ('DELIVERED', 'SUCCESS') ");
            } else if ("failed".equalsIgnoreCase(statusFilter)) {
                sql.append(" AND d.delivery_status IN ('FAILED', 'CANCELLED') ");
            }
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (d.tracking_number LIKE ? OR so.sub_order_code LIKE ? OR osa.recipient_name LIKE ? OR osa.recipient_phone LIKE ? OR s.shop_name LIKE ?) ");
        }

        sql.append(" ORDER BY CASE WHEN d.delivery_status IN ('DELIVERING', 'IN_TRANSIT') THEN 1 WHEN d.delivery_status IN ('ASSIGNING', 'ASSIGNED') THEN 2 ELSE 3 END, d.delivery_id DESC");

        Connection conn = getConnection();
        if (conn == null) return list;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setLong(idx++, driverId);

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Delivery del = extractDeliveryFromResultSet(rs);
                    loadDeliveryItems(del);
                    list.add(del);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting deliveries for driver " + driverId, ex);
        }
        return list;
    }

    /**
     * Get single delivery details by ID
     */
    public Delivery getDeliveryById(long deliveryId, long driverId) {
        String sql = "SELECT d.delivery_id, d.sub_order_id, d.driver_id, d.tracking_number, d.delivery_status, "
            + "       d.proof_image_url, d.failure_reason, d.assigned_at, d.delivered_at, "
            + "       so.sub_order_code, so.shop_id, so.shop_total, so.delivery_slot, so.status AS sub_order_status, "
            + "       s.shop_name, s.phone AS shop_phone, s.address AS shop_address, s.province AS shop_province, "
            + "       o.payment_method, o.payment_status, "
            + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city "
            + "FROM deliveries d "
            + "JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
            + "JOIN orders o ON so.order_id = o.order_id "
            + "LEFT JOIN shops s ON so.shop_id = s.shop_id "
            + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
            + "WHERE d.delivery_id = ? AND d.driver_id = ?";

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, deliveryId);
            ps.setLong(2, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Delivery del = extractDeliveryFromResultSet(rs);
                    loadDeliveryItems(del);
                    return del;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting delivery details " + deliveryId, ex);
        }
        return null;
    }

    /**
     * Driver confirms package pickup at the Shop (Confirm Package Pickup -> status='DELIVERING')
     */
    public boolean confirmPickup(long deliveryId, long driverId) {
        String updateDel = "UPDATE deliveries SET delivery_status = 'DELIVERING' WHERE delivery_id = ? AND driver_id = ?";
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn; PreparedStatement ps = conn.prepareStatement(updateDel)) {
            ps.setLong(1, deliveryId);
            ps.setLong(2, driverId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Update sub_order and order to SHIPPING
                String syncSubOrder = "UPDATE so SET so.status = 'SHIPPING', so.updated_at = CURRENT_TIMESTAMP "
                    + "FROM sub_orders so JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
                    + "WHERE d.delivery_id = ?";
                try (PreparedStatement psSub = conn.prepareStatement(syncSubOrder)) {
                    psSub.setLong(1, deliveryId);
                    psSub.executeUpdate();
                }

                String syncOrder = "UPDATE o SET o.order_status = 'SHIPPING', o.updated_at = CURRENT_TIMESTAMP "
                    + "FROM orders o "
                    + "JOIN sub_orders so ON o.order_id = so.order_id "
                    + "JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
                    + "WHERE d.delivery_id = ?";
                try (PreparedStatement psOrd = conn.prepareStatement(syncOrder)) {
                    psOrd.setLong(1, deliveryId);
                    psOrd.executeUpdate();
                }
                return true;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error confirming package pickup for delivery " + deliveryId, ex);
        }
        return false;
    }

    /**
     * Driver completes delivery successfully, collects cash if COD, and uploads PoD
     */
    public boolean completeDelivery(long deliveryId, long driverId, String proofImageUrl) {
        String updateDel = "UPDATE deliveries SET delivery_status = 'DELIVERED', proof_image_url = ?, delivered_at = CURRENT_TIMESTAMP "
            + "WHERE delivery_id = ? AND driver_id = ?";
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn; PreparedStatement ps = conn.prepareStatement(updateDel)) {
            ps.setString(1, proofImageUrl != null && !proofImageUrl.trim().isEmpty() ? proofImageUrl.trim() : "https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600");
            ps.setLong(2, deliveryId);
            ps.setLong(3, driverId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Update sub_orders to DELIVERED
                String syncSub = "UPDATE so SET so.status = 'DELIVERED', so.updated_at = CURRENT_TIMESTAMP "
                    + "FROM sub_orders so JOIN deliveries d ON so.sub_order_id = d.sub_order_id WHERE d.delivery_id = ?";
                try (PreparedStatement psSub = conn.prepareStatement(syncSub)) {
                    psSub.setLong(1, deliveryId);
                    psSub.executeUpdate();
                }

                // Increment total_trips in driver_profiles
                String incTrips = "UPDATE driver_profiles SET total_trips = total_trips + 1 WHERE driver_id = ?";
                try (PreparedStatement psTrip = conn.prepareStatement(incTrips)) {
                    psTrip.setLong(1, driverId);
                    psTrip.executeUpdate();
                }

                // If all sub_orders of order are DELIVERED, set order to COMPLETED
                String syncOrd = "UPDATE o SET o.order_status = 'COMPLETED', o.updated_at = CURRENT_TIMESTAMP "
                    + "FROM orders o "
                    + "JOIN sub_orders so ON o.order_id = so.order_id "
                    + "JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
                    + "WHERE d.delivery_id = ? "
                    + "  AND NOT EXISTS (SELECT 1 FROM sub_orders other WHERE other.order_id = o.order_id AND other.status <> 'DELIVERED')";
                try (PreparedStatement psOrd = conn.prepareStatement(syncOrd)) {
                    psOrd.setLong(1, deliveryId);
                    psOrd.executeUpdate();
                }

                // If payment method is COD, mark payment as PAID
                String syncPayment = "UPDATE o SET o.payment_status = 'PAID' "
                    + "FROM orders o "
                    + "JOIN sub_orders so ON o.order_id = so.order_id "
                    + "JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
                    + "WHERE d.delivery_id = ? AND o.payment_method = 'COD'";
                try (PreparedStatement psPay = conn.prepareStatement(syncPayment)) {
                    psPay.setLong(1, deliveryId);
                    psPay.executeUpdate();
                }
                return true;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error completing delivery " + deliveryId, ex);
        }
        return false;
    }

    /**
     * Driver reports failed delivery / rejection by customer (Record Failed Delivery)
     * Triggers Return and Refund flow
     */
    public boolean recordFailedDelivery(long deliveryId, long driverId, String failureReason) {
        String updateDel = "UPDATE deliveries SET delivery_status = 'FAILED', failure_reason = ?, delivered_at = CURRENT_TIMESTAMP "
            + "WHERE delivery_id = ? AND driver_id = ?";
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn; PreparedStatement ps = conn.prepareStatement(updateDel)) {
            ps.setNString(1, failureReason != null ? failureReason : "Khách hàng từ chối nhận hoa quả");
            ps.setLong(2, deliveryId);
            ps.setLong(3, driverId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Update sub_order to RETURNED with cancel_reason
                String syncSub = "UPDATE so SET so.status = 'RETURNED', so.cancel_reason = ?, so.updated_at = CURRENT_TIMESTAMP "
                    + "FROM sub_orders so JOIN deliveries d ON so.sub_order_id = d.sub_order_id WHERE d.delivery_id = ?";
                try (PreparedStatement psSub = conn.prepareStatement(syncSub)) {
                    psSub.setNString(1, failureReason);
                    psSub.setLong(2, deliveryId);
                    psSub.executeUpdate();
                }

                // Automatically record in disputes table to initiate return/refund workflow
                String createDispute = "INSERT INTO disputes (dispute_code, sub_order_id, customer_id, shop_id, reason_category, complaint_text, claim_amount, status, created_at) "
                    + "SELECT 'DIS-' + CAST(d.delivery_id AS VARCHAR(10)) + '-' + CAST(DATEDIFF(s, '1970-01-01', CURRENT_TIMESTAMP) % 10000 AS VARCHAR(5)), "
                    + "       so.sub_order_id, o.customer_id, so.shop_id, N'Từ chối nhận khi đồng kiểm với Shipper', ?, so.shop_total, 'OPEN', CURRENT_TIMESTAMP "
                    + "FROM deliveries d "
                    + "JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
                    + "JOIN orders o ON so.order_id = o.order_id "
                    + "WHERE d.delivery_id = ?";
                try (PreparedStatement psDisp = conn.prepareStatement(createDispute)) {
                    psDisp.setNString(1, failureReason);
                    psDisp.setLong(2, deliveryId);
                    psDisp.executeUpdate();
                }
                return true;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error recording failed delivery " + deliveryId, ex);
        }
        return false;
    }

    /**
     * Count deliveries by Driver and Status
     */
    public int countDeliveries(long driverId, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM deliveries d WHERE d.driver_id = ? ");
        if ("pickup".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND d.delivery_status IN ('ASSIGNING', 'ASSIGNED') ");
        } else if ("delivering".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND d.delivery_status IN ('DELIVERING', 'IN_TRANSIT', 'PICKED_UP') ");
        } else if ("completed".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND d.delivery_status IN ('DELIVERED', 'SUCCESS') ");
        } else if ("failed".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND d.delivery_status IN ('FAILED', 'CANCELLED') ");
        }

        Connection conn = getConnection();
        if (conn == null) return 0;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("total");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting deliveries for driver " + driverId, ex);
        }
        return 0;
    }

    /**
     * Calculate total COD cash collected by driver for completed deliveries
     */
    public BigDecimal getTotalCodCollected(long driverId) {
        String sql = "SELECT SUM(so.shop_total) AS total_cod "
            + "FROM deliveries d "
            + "JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
            + "JOIN orders o ON so.order_id = o.order_id "
            + "WHERE d.driver_id = ? AND d.delivery_status IN ('DELIVERED', 'SUCCESS') AND o.payment_method = 'COD'";
        Connection conn = getConnection();
        if (conn == null) return BigDecimal.ZERO;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal("total_cod");
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting total COD for driver " + driverId, ex);
        }
        return BigDecimal.ZERO;
    }

    private Delivery extractDeliveryFromResultSet(ResultSet rs) throws SQLException {
        Delivery del = new Delivery();
        del.setDeliveryId(rs.getLong("delivery_id"));
        del.setSubOrderId(rs.getLong("sub_order_id"));
        del.setDriverId(rs.getLong("driver_id"));
        del.setTrackingNumber(rs.getString("tracking_number"));
        del.setDeliveryStatus(rs.getString("delivery_status"));
        del.setProofImageUrl(rs.getString("proof_image_url"));
        del.setFailureReason(rs.getString("failure_reason"));
        del.setAssignedAt(rs.getTimestamp("assigned_at"));
        del.setDeliveredAt(rs.getTimestamp("delivered_at"));

        del.setSubOrderCode(rs.getString("sub_order_code"));
        del.setShopId(rs.getLong("shop_id"));
        del.setShopName(rs.getString("shop_name"));
        del.setShopPhone(rs.getString("shop_phone"));
        del.setShopAddress(rs.getString("shop_address"));
        del.setShopProvince(rs.getString("shop_province"));
        del.setShopTotal(rs.getBigDecimal("shop_total"));
        del.setDeliverySlot(rs.getString("delivery_slot"));

        del.setPaymentMethod(rs.getString("payment_method"));
        del.setPaymentStatus(rs.getString("payment_status"));

        del.setRecipientName(rs.getString("recipient_name"));
        del.setRecipientPhone(rs.getString("recipient_phone"));
        del.setStreetAddress(rs.getString("street_address"));
        del.setWard(rs.getString("ward"));
        del.setDistrict(rs.getString("district"));
        del.setCity(rs.getString("city"));
        return del;
    }

    private void loadDeliveryItems(Delivery del) {
        if (del == null || del.getSubOrderId() <= 0) return;
        String sql = "SELECT oi.order_item_id, oi.sub_order_id, oi.variant_id, oi.product_name_snapshot, "
            + "       oi.variant_name_snapshot, oi.sku_snapshot, oi.unit, oi.unit_price, oi.quantity, oi.total_price, "
            + "       p.storage_temp, "
            + "       (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = p.product_id ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) AS image_url "
            + "FROM order_items oi "
            + "LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id "
            + "LEFT JOIN products p ON pv.product_id = p.product_id "
            + "WHERE oi.sub_order_id = ?";

        Connection conn = getConnection();
        if (conn == null) return;
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, del.getSubOrderId());
            try (ResultSet rs = ps.executeQuery()) {
                List<OrderItem> items = new ArrayList<>();
                while (rs.next()) {
                    OrderItem it = new OrderItem(
                        rs.getLong("order_item_id"),
                        rs.getLong("sub_order_id"),
                        rs.getLong("variant_id"),
                        rs.getString("product_name_snapshot"),
                        rs.getString("variant_name_snapshot"),
                        rs.getString("sku_snapshot"),
                        rs.getString("unit"),
                        rs.getBigDecimal("unit_price"),
                        rs.getInt("quantity"),
                        rs.getBigDecimal("total_price")
                    );
                    it.setStorageTemp(rs.getString("storage_temp"));
                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=200&h=200&fit=crop";
                    }
                    it.setImageUrl(img);
                    items.add(it);
                }
                del.setItems(items);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading items for delivery " + del.getDeliveryId(), ex);
        }
    }
}
