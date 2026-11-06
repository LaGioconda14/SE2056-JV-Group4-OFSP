package service.impl;

import dao.NotificationDAO;
import java.math.BigDecimal;
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
    public boolean markAllRead(long userId) {
        return notificationDAO.markAllAsRead(userId);
    }

    @Override
    public boolean delete(long notificationId, long userId) {
        return notificationDAO.deleteNotification(notificationId, userId);
    }

    @Override
    public boolean deleteAllRead(long userId) {
        return notificationDAO.deleteAllRead(userId);
    }

    @Override
    public void notifyOrderDeliveredBySubOrder(long subOrderId, String subOrderCode) {
        notificationDAO.notifyOrderDeliveredBySubOrder(subOrderId, subOrderCode);
    }

    @Override
    public void notifyShopReviewCreated(long reviewId) {
        notificationDAO.notifyShopReviewCreated(reviewId);
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

    @Override
    public void notifyPaymentStatus(long customerId, long orderId, String orderCode, boolean success, BigDecimal amount, String paymentMethod) {
        DecimalFormat df = new DecimalFormat("#,###");
        String formatted = (amount != null ? df.format(amount) : "0") + "₫";
        String codeStr = (orderCode != null && !orderCode.isBlank()) ? orderCode : String.valueOf(orderId);
        String methodStr = (paymentMethod != null && !paymentMethod.isBlank()) ? paymentMethod : "cổng thanh toán";
        if (success) {
            String title = "Thanh toán thành công đơn hàng #" + codeStr;
            String message = "Đơn hàng #" + codeStr + " trị giá " + formatted + " đã được thanh toán thành công qua " + methodStr + ". Gốc Vườn đang chuẩn bị chuyển hàng cho bạn.";
            send(customerId, title, message, "ORDER", "ORDER", orderId);
        } else {
            String title = "Thanh toán chưa hoàn tất #" + codeStr;
            String message = "Giao dịch thanh toán qua " + methodStr + " cho đơn hàng #" + codeStr + " chưa thành công. Vui lòng thử lại hoặc chọn hình thức trả tiền mặt (COD).";
            send(customerId, title, message, "ORDER", "ORDER", orderId);
        }
    }

    @Override
    public void notifyCustomerReviewReplied(long reviewId) {
        notificationDAO.notifyCustomerReviewReplied(reviewId);
    }

    @Override
    public void notifyShopOrderCancelled(long shopOwnerId, String subOrderCode, String reason) {
        String title = "Đơn hàng #" + subOrderCode + " đã bị hủy";
        String reasonText = (reason != null && !reason.isBlank()) ? reason : "Khách hàng hủy đơn";
        String message = "Đơn hàng #" + subOrderCode + " đã được khách hủy. Lý do: " + reasonText + ". Số lượng sản phẩm đã được tự động hoàn lại kho.";
        send(shopOwnerId, title, message, "ORDER", "SUB_ORDER", null);
    }

    @Override
    public void notifyShopLowStock(long shopOwnerId, String productName, String variantName, int remainingStock) {
        String label = (variantName != null && !variantName.isBlank()) ? (productName + " - " + variantName) : productName;
        String title = "Cảnh báo tồn kho thấp: " + label;
        String message = "Sản phẩm '" + label + "' chỉ còn lại " + remainingStock + " sản phẩm trong kho bán. Vui lòng bổ sung thêm hàng sớm để tránh bị gián đoạn đơn!";
        send(shopOwnerId, title, message, "SYSTEM", "PRODUCT", null);
    }

    @Override
    public void notifyPromotionToCustomers(long shopId, String promotionTitle, String code) {
        // Notify shop owner confirmation and record promotional event
        String title = "Ưu đãi mới được kích hoạt: " + code;
        String message = "Chương trình ưu đãi '" + promotionTitle + "' (Mã: " + code + ") đã bắt đầu có hiệu lực và hiển thị cho khách hàng.";
        send(shopId, title, message, "PROMOTION", "COUPON", null);
    }

    @Override
    public void checkAndNotifyExpiringBatches(long shopId, long ownerId) {
        notificationDAO.checkAndNotifyExpiringBatches(shopId, ownerId);
    }

    @Override
    public void notifyShopsNewOrder(long orderId) {
        notificationDAO.notifyShopsNewOrder(orderId);
    }

    @Override
    public void notifyShopsOrderCancelled(long orderId, String cancelReason) {
        notificationDAO.notifyShopsOrderCancelled(orderId, cancelReason);
    }

    @Override
    public void notifyShopSubOrderCancelled(long subOrderId, String cancelReason) {
        notificationDAO.notifyShopSubOrderCancelled(subOrderId, cancelReason);
    }

    @Override
    public void checkAndNotifyLowStock(long orderId) {
        notificationDAO.checkAndNotifyLowStock(orderId);
    }
}
