package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.DecimalFormat;

public class Dispute {

    private long disputeId;
    private String disputeCode;
    private long subOrderId;
    private String subOrderCode;
    private long customerId;
    private String customerName;
    private String customerPhone;
    private long shopId;
    private String shopName;
    private String reasonCategory;
    private String complaintText;
    private BigDecimal claimAmount = BigDecimal.ZERO;
    private String evidenceImageUrl;
    private String status = "OPEN"; // OPEN, MEDIATING, REFUNDED_BUYER, REJECTED, RESOLVED
    private String resolutionDecision;
    private String resolutionNote;
    private Long resolvedBy;
    private Timestamp resolvedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Dispute() {
    }

    public long getDisputeId() {
        return disputeId;
    }

    public void setDisputeId(long disputeId) {
        this.disputeId = disputeId;
    }

    public String getDisputeCode() {
        return disputeCode;
    }

    public void setDisputeCode(String disputeCode) {
        this.disputeCode = disputeCode;
    }

    public long getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(long subOrderId) {
        this.subOrderId = subOrderId;
    }

    public String getSubOrderCode() {
        return subOrderCode;
    }

    public void setSubOrderCode(String subOrderCode) {
        this.subOrderCode = subOrderCode;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public long getShopId() {
        return shopId;
    }

    public void setShopId(long shopId) {
        this.shopId = shopId;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getReasonCategory() {
        return reasonCategory;
    }

    public void setReasonCategory(String reasonCategory) {
        this.reasonCategory = reasonCategory;
    }

    public String getComplaintText() {
        return complaintText;
    }

    public void setComplaintText(String complaintText) {
        this.complaintText = complaintText;
    }

    public BigDecimal getClaimAmount() {
        return claimAmount;
    }

    public void setClaimAmount(BigDecimal claimAmount) {
        this.claimAmount = claimAmount;
    }

    public String getEvidenceImageUrl() {
        return evidenceImageUrl;
    }

    public void setEvidenceImageUrl(String evidenceImageUrl) {
        this.evidenceImageUrl = evidenceImageUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResolutionDecision() {
        return resolutionDecision;
    }

    public void setResolutionDecision(String resolutionDecision) {
        this.resolutionDecision = resolutionDecision;
    }

    public String getResolutionNote() {
        return resolutionNote;
    }

    public void setResolutionNote(String resolutionNote) {
        this.resolutionNote = resolutionNote;
    }

    public Long getResolvedBy() {
        return resolvedBy;
    }

    public void setResolvedBy(Long resolvedBy) {
        this.resolvedBy = resolvedBy;
    }

    public Timestamp getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getFormattedClaimAmount() {
        if (claimAmount == null) return "0₫";
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(claimAmount) + "₫";
    }

    public String getStatusBadgeClass() {
        if ("REFUNDED_BUYER".equalsIgnoreCase(status) || "RESOLVED".equalsIgnoreCase(status)) {
            return "badge bg-success";
        }
        if ("REJECTED".equalsIgnoreCase(status)) {
            return "badge bg-danger";
        }
        if ("MEDIATING".equalsIgnoreCase(status)) {
            return "badge bg-warning text-dark";
        }
        return "badge bg-primary";
    }

    public String getStatusText() {
        if ("REFUNDED_BUYER".equalsIgnoreCase(status)) {
            return "Đã Hoàn Tiền";
        }
        if ("RESOLVED".equalsIgnoreCase(status)) {
            return "Đã Giải Quyết";
        }
        if ("REJECTED".equalsIgnoreCase(status)) {
            return "Từ Chối Hoàn";
        }
        if ("MEDIATING".equalsIgnoreCase(status)) {
            return "Đang Thẩm Định";
        }
        return "Chờ Xử Lý";
    }
}

