package service;

import java.util.List;
import model.Notification;

public interface INotificationService {

    long createNotification(long userId, String title, String message, String type, String refType, Long refId);

    List<Notification> getUserNotifications(long userId, int page, int pageSize);

    int getUnreadCount(long userId);

    boolean markAsRead(long notificationId, long userId);

    boolean markAllAsRead(long userId);

    boolean deleteNotification(long notificationId, long userId);

    void notifyNewOrder(long shopOwnerId, String subOrderCode, double amount);

    void notifyOrderStatusChange(long customerId, String subOrderCode, String status, String shopName);

    void notifyNewReview(long shopOwnerId, String productName, int rating, long reviewId);

    void notifyReviewReply(long customerId, String shopName, String productName, long productId);
}

