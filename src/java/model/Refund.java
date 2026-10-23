package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/** Một khoản hoàn tiền (một dòng trong bảng refunds). */
public class Refund {

    public static final String SOURCE_CANCEL = "CANCEL";
    public static final String SOURCE_DISPUTE = "DISPUTE";
    public static final String SOURCE_MANUAL = "MANUAL";

    public static final String TYPE_FULL = "FULL";
    public static final String TYPE_PARTIAL = "PARTIAL";

    private long refundId;
    private String refundCode;
    private long orderId;
    private String orderCode;
    private long subOrderId;
    private String subOrderCode;
    private long shopId;
    private String shopName;
    private long customerId;
    private String customerName;
    private Long disputeId;
    private String disputeCode;
    private String refundType;
    private String source;
    private BigDecimal amount = BigDecimal.ZERO;
    private String reason;
    private String refundMethod;
    private String status;
    private Long processedBy;
    private String processedByName;
    private Timestamp createdAt;

    public long getRefundId() { return refundId; }
    public void setRefundId(long v) { this.refundId = v; }
    public String getRefundCode() { return refundCode; }
    public void setRefundCode(String v) { this.refundCode = v; }
    public long getOrderId() { return orderId; }
    public void setOrderId(long v) { this.orderId = v; }
    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String v) { this.orderCode = v; }
    public long getSubOrderId() { return subOrderId; }
    public void setSubOrderId(long v) { this.subOrderId = v; }
    public String getSubOrderCode() { return subOrderCode; }
    public void setSubOrderCode(String v) { this.subOrderCode = v; }
    public long getShopId() { return shopId; }
    public void setShopId(long v) { this.shopId = v; }
    public String getShopName() { return shopName; }
    public void setShopName(String v) { this.shopName = v; }
    public long getCustomerId() { return customerId; }
    public void setCustomerId(long v) { this.customerId = v; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String v) { this.customerName = v; }
    public Long getDisputeId() { return disputeId; }
    public void setDisputeId(Long v) { this.disputeId = v; }
    public String getDisputeCode() { return disputeCode; }
    public void setDisputeCode(String v) { this.disputeCode = v; }
    public String getRefundType() { return refundType; }
    public void setRefundType(String v) { this.refundType = v; }
    public String getSource() { return source; }
    public void setSource(String v) { this.source = v; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal v) { this.amount = v; }
    public String getReason() { return reason; }
    public void setReason(String v) { this.reason = v; }
    public String getRefundMethod() { return refundMethod; }
    public void setRefundMethod(String v) { this.refundMethod = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public Long getProcessedBy() { return processedBy; }
    public void setProcessedBy(Long v) { this.processedBy = v; }
    public String getProcessedByName() { return processedByName; }
    public void setProcessedByName(String v) { this.processedByName = v; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp v) { this.createdAt = v; }

    // ---------- Helper cho JSP ----------
    public boolean isFull() { return TYPE_FULL.equalsIgnoreCase(refundType); }

    public String getTypeLabel() { return isFull() ? "Hoàn toàn phần" : "Hoàn một phần"; }

    public String getSourceLabel() {
        if (SOURCE_CANCEL.equalsIgnoreCase(source)) return "Hủy đơn";
        if (SOURCE_DISPUTE.equalsIgnoreCase(source)) return "Khiếu nại";
        if (SOURCE_MANUAL.equalsIgnoreCase(source)) return "Admin tạo tay";
        return source;
    }

    /** Người xử lý: tên Admin hoặc "Hệ thống" khi hoàn tự động. */
    public String getProcessorLabel() {
        return processedBy == null ? "Hệ thống (tự động)" : processedByName;
    }

    public String getCreatedAtFull() {
        return createdAt == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }
}
