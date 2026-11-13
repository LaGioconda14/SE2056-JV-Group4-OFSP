package dao;

import enums.PaymentMethod;
import enums.PaymentStatus;
import enums.PaymentTransactionStatus;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.order.Order;
import util.DBContext;

/**
 * DAO xử lý truy vấn và cập nhật dữ liệu thanh toán cổng VNPAY trong cơ sở dữ liệu.
 */
public class VnpayPaymentDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(VnpayPaymentDAO.class.getName());

    /**
     * Enum định nghĩa các kết quả có thể xảy ra khi xử lý callback từ VNPAY.
     */
    public enum CallbackResult {
        /** Giao dịch thanh toán thành công và cập nhật trạng thái đơn thành công */
        SUCCESS,
        /** Đơn hàng đã được xác nhận thanh toán trước đó (idempotent callback) */
        ALREADY_CONFIRMED,
        /** Không tìm thấy mã đơn hàng trong hệ thống */
        ORDER_NOT_FOUND,
        /** Đơn hàng không sử dụng phương thức thanh toán VNPAY */
        INVALID_ORDER,
        /** Số tiền thanh toán không khớp với số tiền của đơn hàng */
        INVALID_AMOUNT,
        /** Thanh toán không thành công (người dùng hủy hoặc lỗi ngân hàng) */
        PAYMENT_FAILED,
        /** Xảy ra lỗi kết nối cơ sở dữ liệu hoặc ngoại lệ hệ thống */
        PROCESSING_ERROR
    }

    /**
     * Lấy thông tin cơ bản của đơn hàng phục vụ kiểm tra thanh toán VNPAY.
     *
     * @param orderId ID đơn hàng
     * @return Order chứa order_id, order_code, customer_id, final_amount, payment_status, payment_method; hoặc null nếu không tìm thấy
     */
    public Order getVnpayOrder(long orderId) {
        String sql = "SELECT order_id, order_code, customer_id, final_amount, payment_status, payment_method "
                + "FROM orders WHERE order_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) {
                return null;
            }
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    Order order = new Order();
                    order.setOrderId(rs.getLong("order_id"));
                    order.setOrderCode(rs.getString("order_code"));
                    order.setCustomerId(rs.getLong("customer_id"));
                    order.setFinalAmount(rs.getBigDecimal("final_amount"));
                    order.setPaymentStatus(rs.getString("payment_status"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    return order;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Cannot load VNPAY order " + orderId, ex);
            throw new IllegalStateException("Không thể tải đơn hàng thanh toán", ex);
        }
    }

    /**
     * Xử lý callback/IPN từ VNPAY trong một transaction:
     * - Khóa dòng đơn hàng với (UPDLOCK, HOLDLOCK) để tránh race condition khi cả Return và IPN cùng gửi đến.
     * - Kiểm tra tính hợp lệ của phương thức thanh toán, số tiền thanh toán (paidAmount so với final_amount).
     * - Đảm bảo tính Idempotency: nếu đơn đã PAID thì không ghi đè lại.
     * - Cập nhật trạng thái payment_status trong bảng orders và bảng payments.
     *
     * @param orderId    ID đơn hàng
     * @param paidAmount số tiền thực tế khách đã trả qua VNPAY
     * @param successful true nếu mã phản hồi VNPAY là thành công ("00")
     * @return CallbackResult phản ánh kết quả xử lý
     */
    public CallbackResult processCallback(long orderId, BigDecimal paidAmount, boolean successful) {
        String selectSql = "SELECT final_amount, payment_status, payment_method "
                + "FROM orders WITH (UPDLOCK, HOLDLOCK) WHERE order_id = ?";
        String updateOrderSql = "UPDATE orders SET payment_status = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE order_id = ?";
        String updatePaymentSql = "UPDATE payments SET payment_status = ?, "
                + "paid_at = CASE WHEN ? = 'SUCCESS' THEN CURRENT_TIMESTAMP ELSE paid_at END "
                + "WHERE order_id = ? AND payment_provider = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return CallbackResult.PROCESSING_ERROR;
        }
        try {
            conn.setAutoCommit(false);
            BigDecimal expectedAmount;
            String currentStatus;
            String paymentMethod;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return CallbackResult.ORDER_NOT_FOUND;
                    }
                    expectedAmount = rs.getBigDecimal("final_amount");
                    currentStatus = rs.getString("payment_status");
                    paymentMethod = rs.getString("payment_method");
                }
            }

            if (!PaymentMethod.VNPAY.name().equalsIgnoreCase(paymentMethod)) {
                conn.rollback();
                return CallbackResult.INVALID_ORDER;
            }
            if (expectedAmount == null || paidAmount == null
                    || expectedAmount.compareTo(paidAmount) != 0) {
                conn.rollback();
                return CallbackResult.INVALID_AMOUNT;
            }
            if (PaymentStatus.PAID.name().equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return CallbackResult.ALREADY_CONFIRMED;
            }

            String orderStatus = successful ? PaymentStatus.PAID.name() : PaymentStatus.FAILED.name();
            String transactionStatus = successful
                    ? PaymentTransactionStatus.SUCCESS.name() : PaymentTransactionStatus.FAILED.name();
            try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                ps.setString(1, orderStatus);
                ps.setLong(2, orderId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(updatePaymentSql)) {
                ps.setString(1, transactionStatus);
                ps.setString(2, transactionStatus);
                ps.setLong(3, orderId);
                ps.setString(4, PaymentMethod.VNPAY.name());
                ps.executeUpdate();
            }
            conn.commit();
            return successful ? CallbackResult.SUCCESS : CallbackResult.PAYMENT_FAILED;
        } catch (SQLException ex) {
            try {
                conn.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "VNPAY callback rollback failed", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Cannot process VNPAY callback for order " + orderId, ex);
            return CallbackResult.PROCESSING_ERROR;
        } finally {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ex) {
                LOGGER.log(Level.WARNING, "Cannot close VNPAY callback connection", ex);
            }
        }
    }
}
