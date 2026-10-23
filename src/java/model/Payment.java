package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * Một lần thanh toán (một dòng trong bảng payments).
 * Mỗi lần khách thử thanh toán online (kể cả thanh toán lại) là một dòng riêng,
 * nhờ vậy lịch sử giao dịch giữ nguyên các lần thất bại.
 */
public class Payment {

    public static final String PROVIDER_COD = "COD";
    public static final String PROVIDER_VNPAY = "VNPAY";
    public static final String PROVIDER_BANK_TRANSFER = "BANK_TRANSFER";

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_FAILED = "FAILED";

    private long paymentId;
    private long orderId;
    private String orderCode;
    private long customerId;
    private String customerName;
    private String paymentProvider;
    private String paymentType;
    private String transactionCode;
    private BigDecimal amount = BigDecimal.ZERO;
    private String paymentStatus = STATUS_PENDING;
    private String failureReason;
    private Timestamp createdAt;
    private Timestamp paidAt;
    private String orderStatus;
    private String orderPaymentStatus;
    private String itemSummary;
    private BigDecimal refundedAmount = BigDecimal.ZERO;

    public long getPaymentId() { return paymentId; }
    public void setPaymentId(long paymentId) { this.paymentId = paymentId; }

    public long getOrderId() { return orderId; }
    public void setOrderId(long orderId) { this.orderId = orderId; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }

    public long getCustomerId() { return customerId; }
    public void setCustomerId(long customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getPaymentProvider() { return paymentProvider; }
    public void setPaymentProvider(String paymentProvider) { this.paymentProvider = paymentProvider; }

    public String getPaymentType() { return paymentType; }
    public void setPaymentType(String paymentType) { this.paymentType = paymentType; }

    public String getTransactionCode() { return transactionCode; }
    public void setTransactionCode(String transactionCode) { this.transactionCode = transactionCode; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

    public String getOrderPaymentStatus() { return orderPaymentStatus; }
    public void setOrderPaymentStatus(String orderPaymentStatus) { this.orderPaymentStatus = orderPaymentStatus; }

    public BigDecimal getRefundedAmount() { return refundedAmount; }
    public void setRefundedAmount(BigDecimal refundedAmount) {
        this.refundedAmount = refundedAmount == null ? BigDecimal.ZERO : refundedAmount;
    }

    /** Đơn đã hoàn tiền toàn bộ (orders.payment_status = REFUNDED). */
    public boolean isRefunded() { return "REFUNDED".equalsIgnoreCase(orderPaymentStatus); }

    /** Đã hoàn một phần: có tiền hoàn nhưng đơn chưa REFUNDED. */
    public boolean isPartiallyRefunded() { return !isRefunded() && refundedAmount.signum() > 0; }

    public String getItemSummary() { return itemSummary; }
    public void setItemSummary(String itemSummary) { this.itemSummary = itemSummary; }

    // ---------- Helper cho JSP ----------

    public boolean isCod() { return PROVIDER_COD.equalsIgnoreCase(paymentProvider); }

    public boolean isOnline() { return !isCod(); }

    public boolean isSuccess() { return STATUS_SUCCESS.equalsIgnoreCase(paymentStatus); }

    public boolean isPending() { return STATUS_PENDING.equalsIgnoreCase(paymentStatus); }

    public boolean isFailed() { return STATUS_FAILED.equalsIgnoreCase(paymentStatus); }

    /** Đơn online còn chờ thanh toán nên khách có thể thanh toán lại. */
    public boolean isRetryable() {
        return isOnline() && !isSuccess()
                && "PENDING".equalsIgnoreCase(orderStatus)
                && !"PAID".equalsIgnoreCase(orderPaymentStatus);
    }

    public String getProviderLabel() {
        if (paymentProvider == null) {
            return "";
        }
        switch (paymentProvider.toUpperCase()) {
            case PROVIDER_COD:
                return "COD (Tiền mặt)";
            case PROVIDER_VNPAY:
                return "VNPay-QR";
            case PROVIDER_BANK_TRANSFER:
                return "Chuyển khoản";
            default:
                return paymentProvider;
        }
    }

    public String getStatusLabel() {
        if (isRefunded()) {
            return "Đã hoàn tiền";
        }
        if (isSuccess()) {
            return "Thành công";
        }
        if (isFailed()) {
            return "Thất bại";
        }
        return "Đang xử lý";
    }

    /** Tên sản phẩm rút gọn để hiển thị trong bảng lịch sử. */
    public String getItemSummaryShort() {
        if (itemSummary == null) {
            return "";
        }
        return itemSummary.length() > 48 ? itemSummary.substring(0, 45) + "..." : itemSummary;
    }

    /** Dòng ghi chú dưới số tiền trong bảng lịch sử. */
    public String getNote() {
        if (isRefunded()) {
            return "Đã hoàn toàn bộ tiền cho khách";
        }
        if (isPartiallyRefunded()) {
            return "Đã hoàn một phần: " + String.format("%,d", refundedAmount.longValue()).replace(',', '.') + "đ";
        }
        if (isFailed() && failureReason != null && !failureReason.trim().isEmpty()) {
            return failureReason;
        }
        if (isSuccess()) {
            return isCod() ? "Đã thu bởi shipper" : "Thanh toán trực tuyến thành công";
        }
        if (isPending()) {
            return isCod() ? "Thu tiền khi nhận hàng" : "Đang chờ cổng thanh toán";
        }
        return "";
    }

    public String getCreatedTime() {
        return createdAt == null ? "" : new SimpleDateFormat("HH:mm").format(createdAt);
    }

    public String getCreatedDate() {
        return createdAt == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(createdAt);
    }

    public String getPaidTime() {
        return paidAt == null ? "" : new SimpleDateFormat("HH:mm:ss").format(paidAt);
    }

    public String getPaidDate() {
        return paidAt == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(paidAt);
    }

    public String getCreatedAtFull() {
        return createdAt == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(createdAt);
    }
}
