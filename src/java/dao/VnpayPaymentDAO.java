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
import model.Order;
import util.DBContext;

public class VnpayPaymentDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(VnpayPaymentDAO.class.getName());

    public enum CallbackResult {
        SUCCESS,
        ALREADY_CONFIRMED,
        ORDER_NOT_FOUND,
        INVALID_ORDER,
        INVALID_AMOUNT,
        PAYMENT_FAILED,
        PROCESSING_ERROR
    }

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
