package service;

import java.util.List;
import model.Notification;

public interface INotificationService {

    long send(long userId, String title, String message, String type, String referenceType, Long referenceId);

    List<Notification> getRecent(long userId, int limit);

    int getUnreadCount(long userId);

    boolean markRead(long notificationId, long userId);

    boolean markAllRead(long userId);

    boolean delete(long notificationId, long userId);

    boolean deleteAllRead(long userId);

    // Business helper triggers
    void notifyOrderDeliveredBySubOrder(long subOrderId, String subOrderCode);
    void notifyShopReviewCreated(long reviewId);
    void notifyOrderPlaced(long customerId, long orderId, String orderCode, double finalAmount);

    void notifyShopNewOrder(long shopOwnerId, String orderCode, String shopName);

    void notifyOrderDelivered(long customerId, String orderCode);

    void notifyReviewReceived(long shopOwnerId, String productName, int rating, String customerName);

    void notifyPaymentStatus(long customerId, long orderId, String orderCode, boolean success, java.math.BigDecimal amount, String paymentMethod);

    void notifyCustomerReviewReplied(long reviewId);

    void notifyShopOrderCancelled(long shopOwnerId, String subOrderCode, String reason);

    void notifyShopLowStock(long shopOwnerId, String productName, String variantName, int remainingStock);

    void notifyPromotionToCustomers(long shopId, String promotionTitle, String code);

    void checkAndNotifyExpiringBatches(long shopId, long ownerId);

    void notifyShopsNewOrder(long orderId);

    void notifyShopsOrderCancelled(long orderId, String cancelReason);

    void notifyShopSubOrderCancelled(long subOrderId, String cancelReason);

    void checkAndNotifyLowStock(long orderId);
}
