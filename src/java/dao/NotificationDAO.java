package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Notification;
import util.DBContext;

public class NotificationDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    public NotificationDAO() {
        initTable();
    }

    private void initTable() {
        String sql = "IF OBJECT_ID(N'dbo.notifications', N'U') IS NULL "
                + "BEGIN "
                + "    CREATE TABLE [dbo].[notifications] ( "
                + "        [notification_id]   BIGINT IDENTITY(1,1) PRIMARY KEY, "
                + "        [user_id]           BIGINT NOT NULL, "
                + "        [title]             NVARCHAR(150) NOT NULL, "
                + "        [message]           NVARCHAR(MAX) NOT NULL, "
                + "        [type]              VARCHAR(50) NOT NULL DEFAULT 'SYSTEM', "
                + "        [reference_type]    VARCHAR(50) NULL, "
                + "        [reference_id]      BIGINT NULL, "
                + "        [is_read]           BIT NOT NULL DEFAULT 0, "
                + "        [created_at]        DATETIME DEFAULT CURRENT_TIMESTAMP, "
                + "        CONSTRAINT FK_notifications_user FOREIGN KEY ([user_id]) REFERENCES [dbo].[users]([user_id]) ON DELETE CASCADE "
                + "    ); "
                + "    CREATE INDEX IX_notifications_user_read ON [dbo].[notifications]([user_id], [is_read], [created_at] DESC); "
                + "END";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error initializing notifications table", e);
        }
    }

    public long insertNotification(Notification noti) {
        String sql = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id, is_read, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, 0, GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, noti.getUserId());
            ps.setString(2, noti.getTitle());
            ps.setString(3, noti.getMessage());
            ps.setString(4, noti.getType() != null ? noti.getType() : "SYSTEM");
            ps.setString(5, noti.getReferenceType());
            if (noti.getReferenceId() != null) {
                ps.setLong(6, noti.getReferenceId());
            } else {
                ps.setNull(6, Types.BIGINT);
            }

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting notification for userId: " + noti.getUserId(), e);
        }
        return -1;
    }

    public long createNotification(long userId, String title, String message, String type, String refType, Long refId) {
        Notification noti = new Notification(userId, title, message, type, refType, refId);
        return insertNotification(noti);
    }

    public List<Notification> getNotificationsByUserId(long userId, int page, int pageSize) {
        List<Notification> list = new ArrayList<>();
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        String sql = "SELECT notification_id, user_id, title, message, type, reference_type, reference_id, is_read, created_at "
                + "FROM notifications "
                + "WHERE user_id = ? "
                + "ORDER BY created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
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
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting notifications for userId: " + userId, e);
        }
        return list;
    }

    public int countUnread(long userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting unread notifications for userId: " + userId, e);
        }
        return 0;
    }

    public boolean markAsRead(long notificationId, long userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, notificationId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking notification as read: " + notificationId, e);
        }
        return false;
    }

    public boolean markAllAsRead(long userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications as read for userId: " + userId, e);
        }
        return false;
    }

    public boolean deleteNotification(long notificationId, long userId) {
        String sql = "DELETE FROM notifications WHERE notification_id = ? AND user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, notificationId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting notification: " + notificationId, e);
        }
        return false;
    }
}

