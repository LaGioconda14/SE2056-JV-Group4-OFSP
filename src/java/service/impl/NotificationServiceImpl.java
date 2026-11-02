package service.impl;

import dao.NotificationDAO;
import java.text.DecimalFormat;
import java.util.List;
import model.Notification;
import service.INotificationService;

public class NotificationServiceImpl implements INotificationService {

    private final NotificationDAO notificationDAO;

    public NotificationServiceImpl() {
        this.notificationDAO = new NotificationDAO();
    }

    public NotificationServiceImpl(NotificationDAO notificationDAO) {
        this.notificationDAO = notificationDAO;
    }

    @Override
    public long send(long userId, String title, String message, String type, String referenceType, Long referenceId) {
        return notificationDAO.createNotification(userId, title, message, type, referenceType, referenceId);
    }

    @Override
    public List<Notification> getRecent(long userId, int limit) {
        return notificationDAO.getNotificationsByUserId(userId, limit);
    }

    @Override
    public int getUnreadCount(long userId) {
        return notificationDAO.countUnreadByUserId(userId);
    }

    @Override
    public boolean markRead(long notificationId, long userId) {
        return notificationDAO.markAsRead(notificationId, userId);
    }

    @Override
    public void notifyOrderDeliveredBySubOrder(long subOrderId, String subOrderCode) {
        notificationDAO.notifyOrderDeliveredBySubOrder(subOrderId, subOrderCode);
    }
    @Override
    public void notifyShopReviewCreated(long reviewId) {
        notificationDAO.notifyShopReviewCreated(reviewId);
    }


    public boolean markAllRead(long userId) {
        return notificationDAO.markAllAsRead(userId);
    }

    @Override
    public void notifyOrderPlaced(long customerId, long orderId, String orderCode, double finalAmount) {
        DecimalFormat df = new DecimalFormat("#,###");
        String formatted = df.format(finalAmount) + "₫";
        String title = "Đặt hàng thành công #" + (orderCode != null ? orderCode : orderId);
        String message = "Đơn hàng của bạn trị giá " + formatted + " đã được Gốc Vườn tiếp nhận và chuyển đến nhà vườn chuẩn bị.";
        send(customerId, title, message, "ORDER", "ORDER", orderId);
    }

    @Override
    public void notifyShopNewOrder(long shopOwnerId, String orderCode, String shopName) {
        String title = "Đơn hàng mới cần đóng gói #" + orderCode;
        String message = "Gian hàng " + (shopName != null ? shopName : "") + " vừa nhận được một đơn hàng mới. Vui lòng xác nhận và đóng gói quả tươi.";
        send(shopOwnerId, title, message, "ORDER", "SUB_ORDER", null);
    }

    @Override
    public void notifyOrderDelivered(long customerId, String orderCode) {
        String title = "Đơn hàng #" + orderCode + " đã được giao thành công!";
        String message = "Hoa quả tươi đã được giao tận tay bạn. Hãy đánh giá chất lượng sản phẩm để nhận ưu đãi cho lần mua sau nhé!";
        send(customerId, title, message, "ORDER", "ORDER", null);
    }

    @Override
    public void notifyReviewReceived(long shopOwnerId, String productName, int rating, String customerName) {
        String title = "Đánh giá mới (" + rating + "★) từ " + (customerName != null ? customerName : "khách hàng");
        String message = "Sản phẩm '" + productName + "' vừa nhận được đánh giá " + rating + " sao. Nhấn để xem và phản hồi khách hàng.";
        send(shopOwnerId, title, message, "ORDER", "REVIEW", null);
    }
}
