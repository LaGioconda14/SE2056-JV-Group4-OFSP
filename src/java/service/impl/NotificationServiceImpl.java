package service.impl;

import dao.NotificationDAO;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
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
    public long createNotification(long userId, String title, String message, String type, String refType, Long refId) {
        if (userId <= 0 || title == null || message == null) return -1;
        return notificationDAO.createNotification(userId, title, message, type, refType, refId);
    }

    @Override
    public List<Notification> getUserNotifications(long userId, int page, int pageSize) {
        if (userId <= 0) return List.of();
        return notificationDAO.getNotificationsByUserId(userId, page, pageSize);
    }

    @Override
    public int getUnreadCount(long userId) {
        if (userId <= 0) return 0;
        return notificationDAO.countUnread(userId);
    }

    @Override
    public boolean markAsRead(long notificationId, long userId) {
        if (notificationId <= 0 || userId <= 0) return false;
        return notificationDAO.markAsRead(notificationId, userId);
    }

    @Override
    public boolean markAllAsRead(long userId) {
        if (userId <= 0) return false;
        return notificationDAO.markAllAsRead(userId);
    }

    @Override
    public boolean deleteNotification(long notificationId, long userId) {
        if (notificationId <= 0 || userId <= 0) return false;
        return notificationDAO.deleteNotification(notificationId, userId);
    }

    @Override
    public void notifyNewOrder(long shopOwnerId, String subOrderCode, double amount) {
        NumberFormat fmt = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("vi-VN"));
        String formattedAmount = fmt.format(amount);
        String title = "📦 Đơn hàng mới #" + subOrderCode;
        String msg = "Gian hàng của bạn vừa có một đơn hàng mới trị giá " + formattedAmount + ". Vui lòng kiểm tra và chuẩn bị nông sản đóng gói.";
        createNotification(shopOwnerId, title, msg, "ORDER", "SUB_ORDER", null);
    }

    @Override
    public void notifyOrderStatusChange(long customerId, String subOrderCode, String status, String shopName) {
        String title;
        String msg;
        String shop = (shopName != null && !shopName.trim().isEmpty()) ? shopName : "Gian hàng";

        switch (status) {
            case "CONFIRMED":
            case "PACKING":
                title = "🌱 Đơn hàng đang được đóng gói #" + subOrderCode;
                msg = shop + " đang tiến hành tuyển chọn và đóng gói nông sản tươi sạch theo chuẩn chuỗi lạnh.";
                break;
            case "SHIPPING":
                title = "🚚 Đơn hàng đang trên đường giao #" + subOrderCode;
                msg = "Đơn hàng của bạn từ " + shop + " đang được tài xế giao tới địa chỉ nhận. Vui lòng chú ý điện thoại.";
                break;
            case "DELIVERED":
                title = "🎉 Đơn hàng đã giao thành công #" + subOrderCode;
                msg = "Nông sản tươi ngon từ " + shop + " đã được giao đến bạn. Hãy chia sẻ cảm nhận và đánh giá chất lượng sản phẩm nhé!";
                break;
            case "CANCELLED":
                title = "⚠️ Đơn hàng đã bị hủy #" + subOrderCode;
                msg = "Đơn hàng #" + subOrderCode + " từ " + shop + " đã bị hủy.";
                break;
            default:
                title = "Cập nhật đơn hàng #" + subOrderCode;
                msg = "Trạng thái đơn hàng của bạn tại " + shop + " đã được cập nhật sang: " + status;
                break;
        }

        createNotification(customerId, title, msg, "ORDER", "SUB_ORDER", null);
    }

    @Override
    public void notifyNewReview(long shopOwnerId, String productName, int rating, long reviewId) {
        String title = "⭐ Đánh giá mới (" + rating + " sao)";
        String msg = "Khách hàng vừa để lại đánh giá " + rating + " sao cho sản phẩm: " + productName + ". Xem và phản hồi khách hàng ngay.";
        createNotification(shopOwnerId, title, msg, "REVIEW", "REVIEW", reviewId);
    }

    @Override
    public void notifyReviewReply(long customerId, String shopName, String productName, long productId) {
        String title = "💬 " + shopName + " đã phản hồi đánh giá";
        String msg = shopName + " đã gửi phản hồi cho nhận xét của bạn về sản phẩm " + productName + ".";
        createNotification(customerId, title, msg, "REVIEW", "PRODUCT", productId);
    }
}
