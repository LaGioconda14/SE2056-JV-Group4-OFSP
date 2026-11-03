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
}
