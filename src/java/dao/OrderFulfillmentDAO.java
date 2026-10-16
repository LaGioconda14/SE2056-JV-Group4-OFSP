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
import model.Order;
import model.OrderItem;
import model.ShippingAddress;
import model.SubOrder;
import util.DBContext;

public class OrderFulfillmentDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(OrderFulfillmentDAO.class.getName());

    /**
     * Get SubOrder with Order and Shipping Address details by SubOrder Code or ID
     */
    public SubOrder getSubOrderDetails(String subOrderCode) {
        String sql = "SELECT so.sub_order_id, so.sub_order_code, so.order_id, so.shop_id, so.delivery_slot, "
                + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                + "       so.status, so.cancel_reason, so.created_at, so.updated_at, "
                + "       s.shop_name, "
                + "       o.order_code, o.payment_status, o.payment_method, o.created_at AS order_created_at, "
                + "       u.full_name AS customer_name, u.phone AS customer_phone, "
                + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city, "
                + "       d.tracking_number, d.delivery_status "
                + "FROM sub_orders so "
                + "JOIN orders o ON so.order_id = o.order_id "
                + "LEFT JOIN shops s ON so.shop_id = s.shop_id "
                + "LEFT JOIN users u ON o.customer_id = u.user_id "
                + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                + "LEFT JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
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
                    so.setPaymentMethod(rs.getString("payment_method"));
                    so.setPaymentStatus(rs.getString("payment_status"));
                    so.setCreatedAt(rs.getTimestamp("created_at"));
                    so.setUpdatedAt(rs.getTimestamp("updated_at"));

                    String tracking = rs.getString("tracking_number");
                    if (tracking != null && !tracking.trim().isEmpty()) {
                        so.setTrackingNumber(tracking);
                    }

                    // Shipping Address
                    ShippingAddress addr = new ShippingAddress();
                    addr.setOrderId(rs.getLong("order_id"));
                    addr.setRecipientName(rs.getString("recipient_name") != null ? rs.getString("recipient_name") : rs.getString("customer_name"));
                    addr.setRecipientPhone(rs.getString("recipient_phone") != null ? rs.getString("recipient_phone") : rs.getString("customer_phone"));
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

    /**
     * Get Order Items for a SubOrder with full product details, stock, images, and QC inspection data
     */
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
                            rs.getBigDecimal("total_price")
                    );

                    item.setStockQuantity(rs.getInt("stock_quantity"));
                    item.setWeightKg(rs.getBigDecimal("weight_kg"));
                    item.setOrigin(rs.getString("origin"));
                    item.setCertification(rs.getString("certification"));
                    item.setStorageTemp(rs.getString("storage_temp"));

                    String img = rs.getString("image_url");
                    if (img == null || img.trim().isEmpty()) {
                        img = "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=200&h=200&fit=crop";
                    }
                    item.setImageUrl(img);

                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting items for subOrderId " + subOrderId, ex);
        }
        return list;
    }

    /**
     * Update SubOrder Status
     */
    public boolean updateSubOrderStatus(String subOrderCode, String newStatus) {
        String sql = "UPDATE sub_orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_code = ?";
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, subOrderCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating sub_orders status to " + newStatus, ex);
            return false;
        }
    }

    /**
     * Get list of SubOrders by Shop, Status, and optional Keyword Search
     */
    public List<SubOrder> getSubOrdersByShop(long shopId, String status, String keyword) {
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
            + "WHERE 1=1 "
        );
        if (shopId > 0) {
            sql.append(" AND so.shop_id = ? ");
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND so.status = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (so.sub_order_code LIKE ? OR o.order_code LIKE ? OR osa.recipient_name LIKE ? OR osa.recipient_phone LIKE ?) ");
        }
        sql.append(" ORDER BY so.created_at DESC");

        Connection conn = getConnection();
        if (conn == null) return list;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (shopId > 0) {
                ps.setLong(paramIndex++, shopId);
            }
            if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
                ps.setString(paramIndex++, status);
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
                    so.setShopTotal(rs.getBigDecimal("shop_total"));
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

    /**
     * Backward-compatible overload without keyword
     */
    public List<SubOrder> getSubOrdersByShop(long shopId, String status) {
        return getSubOrdersByShop(shopId, status, null);
    }

    /**
     * Count SubOrders by Shop and Status
     */
    public int countSubOrdersByShop(long shopId, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM sub_orders WHERE 1=1 ");
        if (shopId > 0) {
            sql.append(" AND shop_id = ? ");
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sql.append(" AND status = ? ");
        }

        Connection conn = getConnection();
        if (conn == null) return 0;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (shopId > 0) {
                ps.setLong(paramIndex++, shopId);
            }
            if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
                ps.setString(paramIndex++, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting suborders for shop " + shopId, ex);
        }
        return 0;
    }

    /**
     * Get the latest active SubOrder code for a shop
     */
    public String getFirstSubOrderCode(long shopId) {
        String sql = "SELECT TOP 1 sub_order_code FROM sub_orders WHERE shop_id = ? "
                + "ORDER BY CASE WHEN status = 'NEW' THEN 1 WHEN status = 'PACKING' THEN 2 WHEN status = 'SHIPPING' THEN 3 ELSE 4 END ASC, sub_order_id DESC";
        Connection conn = getConnection();
        if (conn == null) return null;
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
}
