package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Notification;
import util.DBContext;

public class NotificationDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    public long createNotification(long userId, String title, String message, String type,
                                   String referenceType, Long referenceId) {
        String sql = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id, is_read, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, 0, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            if (conn == null) return -1;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, userId);
                ps.setString(2, title);
                ps.setString(3, message);
                ps.setString(4, type != null ? type : "SYSTEM");
                if (referenceType != null) {
                    ps.setString(5, referenceType);
                } else {
                    ps.setNull(5, java.sql.Types.VARCHAR);
                }
                if (referenceId != null) {
                    ps.setLong(6, referenceId);
                } else {
                    ps.setNull(6, java.sql.Types.BIGINT);
                }

                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating notification for user " + userId, ex);
        }
        return -1;
    }

    public List<Notification> getNotificationsByUserId(long userId, int limit) {
        List<Notification> list = new ArrayList<>();
        if (limit <= 0) limit = 20;

        String sql = "SELECT TOP (?) notification_id, user_id, title, message, type, "
                   + "       reference_type, reference_id, is_read, created_at "
                   + "FROM notifications "
                   + "WHERE user_id = ? "
                   + "ORDER BY created_at DESC";

        try (Connection conn = getConnection()) {
            if (conn == null) return list;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, limit);
                ps.setLong(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Notification n = new Notification();
                        n.setNotificationId(rs.getLong("notification_id"));
                        n.setUserId(rs.getLong("user_id"));
                        n.setTitle(rs.getString("title"));
                        n.setMessage(rs.getString("message"));
                        n.setType(rs.getString("type"));
                        n.setReferenceType(rs.getString("reference_type"));
                        long refId = rs.getLong("reference_id");
                        n.setReferenceId(rs.wasNull() ? null : refId);
                        n.setRead(rs.getBoolean("is_read"));
                        n.setCreatedAt(rs.getTimestamp("created_at"));
                        list.add(n);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading notifications for user " + userId, ex);
        }
        return list;
    }

    public int countUnreadByUserId(long userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = getConnection()) {
            if (conn == null) return 0;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting unread notifications for user " + userId, ex);
        }
        return 0;
    }

    public boolean markAsRead(long notificationId, long userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, notificationId);
                ps.setLong(2, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error marking notification as read " + notificationId, ex);
            return false;
        }
    }

    public void notifyOrderDeliveredBySubOrder(long subOrderId, String subOrderCode) {
        String sql = "SELECT o.customer_id FROM sub_orders so JOIN orders o ON so.order_id = o.order_id WHERE so.sub_order_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, subOrderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long customerId = rs.getLong(1);
                        String title = "Đơn hàng #" + (subOrderCode != null ? subOrderCode : subOrderId) + " đã được giao thành công!";
                        String message = "Hoa quả tươi đã được giao tận tay bạn. Hãy đánh giá chất lượng sản phẩm để chia sẻ trải nghiệm nhé!";
                        createNotification(customerId, title, message, "ORDER", "SUB_ORDER", subOrderId);
                    }
                }
            }
        } catch (SQLException ignored) {}
    }
    public void notifyShopReviewCreated(long reviewId) {
        String sql = "SELECT s.owner_id, oi.product_name_snapshot, r.rating, u.full_name "
                   + "FROM reviews r "
                   + "JOIN shops s ON r.shop_id = s.shop_id "
                   + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                   + "JOIN users u ON r.customer_id = u.user_id "
                   + "WHERE r.review_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, reviewId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long ownerId = rs.getLong("owner_id");
                        String prodName = rs.getString("product_name_snapshot");
                        int rating = rs.getInt("rating");
                        String customerName = rs.getString("full_name");
                        String title = "Đánh giá mới (" + rating + "★) từ " + customerName;
                        String message = "Sản phẩm '" + prodName + "' vừa nhận được đánh giá " + rating + " sao. Hãy vào xem và phản hồi khách hàng nhé!";
                        createNotification(ownerId, title, message, "ORDER", "REVIEW", reviewId);
                    }
                }
            }
        } catch (SQLException ignored) {}
    }

    public boolean markAllAsRead(long userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection conn = getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, userId);
                return ps.executeUpdate() >= 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications as read for user " + userId, ex);
            return false;
        }
    }

    public boolean deleteNotification(long notificationId, long userId) {
        String sql = "DELETE FROM notifications WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, notificationId);
                ps.setLong(2, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting notification " + notificationId, ex);
            return false;
        }
    }

    public boolean deleteAllRead(long userId) {
        String sql = "DELETE FROM notifications WHERE user_id = ? AND is_read = 1";
        try (Connection conn = getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, userId);
                return ps.executeUpdate() >= 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting all read notifications for user " + userId, ex);
            return false;
        }
    }

    public void notifyCustomerReviewReplied(long reviewId) {
        String sql = "SELECT r.customer_id, oi.product_name_snapshot, s.shop_name "
                   + "FROM reviews r "
                   + "JOIN shops s ON r.shop_id = s.shop_id "
                   + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                   + "WHERE r.review_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, reviewId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long customerId = rs.getLong("customer_id");
                        String prodName = rs.getString("product_name_snapshot");
                        String shopName = rs.getString("shop_name");
                        String title = "Phản hồi đánh giá từ gian hàng " + shopName;
                        String message = "Gian hàng '" + shopName + "' vừa gửi phản hồi cho đánh giá của bạn về sản phẩm '" + prodName + "'.";
                        createNotification(customerId, title, message, "ORDER", "REVIEW", reviewId);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in notifyCustomerReviewReplied", ex);
        }
    }

    public void checkAndNotifyExpiringBatches(long shopId, long ownerId) {
        String sql = "SELECT TOP 5 pb.batch_code, p.name, pb.expiry_date, pb.current_quantity "
                   + "FROM product_batches pb "
                   + "JOIN product_variants pv ON pb.variant_id = pv.variant_id "
                   + "JOIN products p ON pv.product_id = p.product_id "
                   + "WHERE p.shop_id = ? AND pb.current_quantity > 0 "
                   + "  AND pb.expiry_date <= DATEADD(day, 2, GETDATE()) "
                   + "  AND NOT EXISTS ( "
                   + "      SELECT 1 FROM notifications n "
                   + "      WHERE n.user_id = ? AND n.type = 'SYSTEM' "
                   + "        AND n.message LIKE '%' + pb.batch_code + '%' "
                   + "        AND n.created_at >= DATEADD(hour, -24, GETDATE()) "
                   + "  )";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, shopId);
                ps.setLong(2, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String batchCode = rs.getString("batch_code");
                        String prodName = rs.getString("name");
                        int qty = rs.getInt("current_quantity");
                        java.sql.Date exp = rs.getDate("expiry_date");
                        String title = "Cảnh báo hạn dùng: Lô " + batchCode;
                        String message = "Sản phẩm '" + prodName + "' (Lô " + batchCode + ", còn " + qty
                                + " sản phẩm) có hạn dùng đến " + exp + ". Vui lòng kiểm tra và xử lý sớm!";
                        createNotification(ownerId, title, message, "SYSTEM", "BATCH", null);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error checking expiring batches", ex);
        }
    }

    public void notifyShopsNewOrder(long orderId) {
        String sql = "SELECT s.owner_id, so.sub_order_id, so.sub_order_code, s.shop_name "
                   + "FROM sub_orders so "
                   + "JOIN shops s ON so.shop_id = s.shop_id "
                   + "WHERE so.order_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        long ownerId = rs.getLong("owner_id");
                        long subOrderId = rs.getLong("sub_order_id");
                        String code = rs.getString("sub_order_code");
                        String sName = rs.getString("shop_name");
                        String title = "Đơn hàng mới cần đóng gói #" + (code != null ? code : subOrderId);
                        String message = "Gian hàng " + (sName != null ? sName : "")
                                + " vừa nhận được đơn hàng mới #" + (code != null ? code : subOrderId)
                                + ". Vui lòng vào xác nhận và chuẩn bị đóng gói hoa quả tươi!";
                        createNotification(ownerId, title, message, "ORDER", "SUB_ORDER", subOrderId);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error notifying shops for new order " + orderId, ex);
        }
    }

    public void notifyShopsOrderCancelled(long orderId, String cancelReason) {
        String sql = "SELECT s.owner_id, so.sub_order_id, so.sub_order_code, s.shop_name "
                   + "FROM sub_orders so "
                   + "JOIN shops s ON so.shop_id = s.shop_id "
                   + "WHERE so.order_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        long ownerId = rs.getLong("owner_id");
                        long subOrderId = rs.getLong("sub_order_id");
                        String code = rs.getString("sub_order_code");
                        String title = "Đơn hàng #" + (code != null ? code : subOrderId) + " đã bị hủy";
                        String reasonText = (cancelReason != null && !cancelReason.isBlank()) ? cancelReason : "Khách hàng hủy đơn";
                        String message = "Khách hàng đã hủy đơn #" + (code != null ? code : subOrderId)
                                + ". Lý do: " + reasonText + ". Số lượng sản phẩm đã được tự động hoàn lại kho.";
                        createNotification(ownerId, title, message, "ORDER", "SUB_ORDER", subOrderId);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error notifying shops for cancelled order " + orderId, ex);
        }
    }

    public void notifyShopSubOrderCancelled(long subOrderId, String cancelReason) {
        String sql = "SELECT s.owner_id, so.sub_order_code, s.shop_name "
                   + "FROM sub_orders so "
                   + "JOIN shops s ON so.shop_id = s.shop_id "
                   + "WHERE so.sub_order_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, subOrderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long ownerId = rs.getLong("owner_id");
                        String code = rs.getString("sub_order_code");
                        String title = "Đơn hàng #" + (code != null ? code : subOrderId) + " đã bị hủy";
                        String reasonText = (cancelReason != null && !cancelReason.isBlank()) ? cancelReason : "Khách hàng hủy đơn";
                        String message = "Khách hàng đã hủy đơn #" + (code != null ? code : subOrderId)
                                + ". Lý do: " + reasonText + ". Số lượng sản phẩm đã được tự động hoàn lại kho.";
                        createNotification(ownerId, title, message, "ORDER", "SUB_ORDER", subOrderId);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error notifying shop for cancelled sub-order " + subOrderId, ex);
        }
    }

    public void checkAndNotifyLowStock(long orderId) {
        String sql = "SELECT DISTINCT s.owner_id, p.name, pv.variant_name, pv.stock_quantity, pv.low_stock_threshold "
                   + "FROM order_items oi "
                   + "JOIN sub_orders so ON oi.sub_order_id = so.sub_order_id "
                   + "JOIN shops s ON so.shop_id = s.shop_id "
                   + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                   + "JOIN products p ON pv.product_id = p.product_id "
                   + "WHERE so.order_id = ? AND pv.stock_quantity <= pv.low_stock_threshold";
        try (Connection conn = getConnection()) {
            if (conn == null) return;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        long ownerId = rs.getLong("owner_id");
                        String pName = rs.getString("name");
                        String vName = rs.getString("variant_name");
                        int stock = rs.getInt("stock_quantity");
                        String label = (vName != null && !vName.isBlank()) ? (pName + " - " + vName) : pName;
                        String title = "Cảnh báo tồn kho thấp: " + label;
                        String message = "Sản phẩm '" + label + "' sau đơn hàng vừa tạo chỉ còn lại " + stock
                                + " sản phẩm trong kho. Vui lòng bổ sung thêm hàng!";
                        createNotification(ownerId, title, message, "SYSTEM", "PRODUCT", null);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error checking low stock after order " + orderId, ex);
        }
    }
}
