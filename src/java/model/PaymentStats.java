package model;

import java.math.BigDecimal;

/** Số liệu tổng hợp hiển thị ở đầu trang Lịch sử thanh toán. */
public class PaymentStats {

    private BigDecimal totalPaidAmount = BigDecimal.ZERO;
    private BigDecimal totalPendingAmount = BigDecimal.ZERO;
    private int totalCount;
    private int successCount;
    private int pendingCount;
    private int failedCount;
    private int codCount;
    private int onlineCount;

    public BigDecimal getTotalPaidAmount() { return totalPaidAmount; }
    public void setTotalPaidAmount(BigDecimal v) { this.totalPaidAmount = v; }

    public BigDecimal getTotalPendingAmount() { return totalPendingAmount; }
    public void setTotalPendingAmount(BigDecimal v) { this.totalPendingAmount = v; }

    public int getTotalCount() { return totalCount; }
    public void setTotalCount(int v) { this.totalCount = v; }

    public int getSuccessCount() { return successCount; }
    public void setSuccessCount(int v) { this.successCount = v; }

    public int getPendingCount() { return pendingCount; }
    public void setPendingCount(int v) { this.pendingCount = v; }

    public int getFailedCount() { return failedCount; }
    public void setFailedCount(int v) { this.failedCount = v; }

    public int getCodCount() { return codCount; }
    public void setCodCount(int v) { this.codCount = v; }

    public int getOnlineCount() { return onlineCount; }
    public void setOnlineCount(int v) { this.onlineCount = v; }

    /** Tỉ lệ thành công trên các giao dịch đã có kết quả (thành công + thất bại). */
    public int getSuccessRate() {
        int finished = successCount + failedCount;
        return finished == 0 ? 0 : (int) Math.round(successCount * 100.0 / finished);
    }

    public int getOnlinePercent() {
        return totalCount == 0 ? 0 : (int) Math.round(onlineCount * 100.0 / totalCount);
    }

    public int getCodPercent() {
        return totalCount == 0 ? 0 : 100 - getOnlinePercent();
    }
}
