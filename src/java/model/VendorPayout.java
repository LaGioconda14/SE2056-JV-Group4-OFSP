package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/** Một kỳ quyết toán doanh thu của gian hàng (một dòng trong bảng vendor_payouts). */
public class VendorPayout {

    public static final String STATUS_PROCESSING = "PROCESSING";
    public static final String STATUS_COMPLETED = "COMPLETED";
    public static final String STATUS_ON_HOLD = "ON_HOLD";

    private long payoutId;
    private String payoutCode;
    private long shopId;
    private String shopName;
    private String cycleName;
    private Timestamp periodStart;
    private Timestamp periodEnd;
    private BigDecimal grossSales = BigDecimal.ZERO;
    private int totalOrdersCount;
    private BigDecimal commissionRate = BigDecimal.ZERO;
    private BigDecimal commissionWithheld = BigDecimal.ZERO;
    private BigDecimal disputeDeductions = BigDecimal.ZERO;
    private BigDecimal netPayout = BigDecimal.ZERO;
    private String bankAccountNumber;
    private String bankName;
    private String status;
    private Long processedBy;
    private String processedByName;
    private Timestamp paidAt;
    private Timestamp createdAt;

    public long getPayoutId() { return payoutId; }
    public void setPayoutId(long v) { this.payoutId = v; }
    public String getPayoutCode() { return payoutCode; }
    public void setPayoutCode(String v) { this.payoutCode = v; }
    public long getShopId() { return shopId; }
    public void setShopId(long v) { this.shopId = v; }
    public String getShopName() { return shopName; }
    public void setShopName(String v) { this.shopName = v; }
    public String getCycleName() { return cycleName; }
    public void setCycleName(String v) { this.cycleName = v; }
    public Timestamp getPeriodStart() { return periodStart; }
    public void setPeriodStart(Timestamp v) { this.periodStart = v; }
    public Timestamp getPeriodEnd() { return periodEnd; }
    public void setPeriodEnd(Timestamp v) { this.periodEnd = v; }
    public BigDecimal getGrossSales() { return grossSales; }
    public void setGrossSales(BigDecimal v) { this.grossSales = v; }
    public int getTotalOrdersCount() { return totalOrdersCount; }
    public void setTotalOrdersCount(int v) { this.totalOrdersCount = v; }
    public BigDecimal getCommissionRate() { return commissionRate; }
    public void setCommissionRate(BigDecimal v) { this.commissionRate = v; }
    public BigDecimal getCommissionWithheld() { return commissionWithheld; }
    public void setCommissionWithheld(BigDecimal v) { this.commissionWithheld = v; }
    public BigDecimal getDisputeDeductions() { return disputeDeductions; }
    public void setDisputeDeductions(BigDecimal v) { this.disputeDeductions = v; }
    public BigDecimal getNetPayout() { return netPayout; }
    public void setNetPayout(BigDecimal v) { this.netPayout = v; }
    public String getBankAccountNumber() { return bankAccountNumber; }
    public void setBankAccountNumber(String v) { this.bankAccountNumber = v; }
    public String getBankName() { return bankName; }
    public void setBankName(String v) { this.bankName = v; }
    public String getStatus() { return status; }
    public void setStatus(String v) { this.status = v; }
    public Long getProcessedBy() { return processedBy; }
    public void setProcessedBy(Long v) { this.processedBy = v; }
    public String getProcessedByName() { return processedByName; }
    public void setProcessedByName(String v) { this.processedByName = v; }
    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp v) { this.paidAt = v; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp v) { this.createdAt = v; }

    // ---------- Helper cho JSP ----------
    public boolean isProcessing() { return STATUS_PROCESSING.equalsIgnoreCase(status); }
    public boolean isCompleted() { return STATUS_COMPLETED.equalsIgnoreCase(status); }
    public boolean isOnHold() { return STATUS_ON_HOLD.equalsIgnoreCase(status); }

    public String getStatusLabel() {
        if (isCompleted()) return "Đã chi trả";
        if (isOnHold()) return "Tạm giữ";
        return "Chờ chi trả";
    }

    public String getPeriodLabel() {
        SimpleDateFormat f = new SimpleDateFormat("dd/MM/yyyy");
        if (periodStart == null || periodEnd == null) return "";
        return f.format(periodStart) + " - " + f.format(periodEnd);
    }

    public String getPaidAtFull() {
        return paidAt == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(paidAt);
    }

    /** Số tài khoản che bớt, chỉ hiện 4 số cuối. */
    public String getMaskedAccount() {
        if (bankAccountNumber == null || bankAccountNumber.length() < 5) return bankAccountNumber == null ? "" : bankAccountNumber;
        return "••••" + bankAccountNumber.substring(bankAccountNumber.length() - 4);
    }
}
