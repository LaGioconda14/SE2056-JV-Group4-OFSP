package model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Dữ liệu báo cáo phân tích thanh toán & dòng tiền cho Admin. */
public class CashflowReport {

    private BigDecimal collectedTotal = BigDecimal.ZERO;   // tổng tiền thu thành công
    private BigDecimal collectedCod = BigDecimal.ZERO;     // tiền mặt (COD)
    private BigDecimal collectedOnline = BigDecimal.ZERO;  // tiền điện tử (VNPay, chuyển khoản)
    private BigDecimal refundedTotal = BigDecimal.ZERO;    // tiền đã hoàn cho khách
    private BigDecimal payoutPaid = BigDecimal.ZERO;       // tiền đã chi trả cho shop
    private int totalTransactions;
    private int successCount;
    private int failedCount;
    private int pendingCount;
    private int codCount;
    private int onlineCount;
    private int onlineSuccess;
    private int onlineFailed;
    private final List<Map<String, Object>> daily = new ArrayList<>();
    private final List<Map<String, Object>> byMethod = new ArrayList<>();
    private final List<Map<String, Object>> failureReasons = new ArrayList<>();

    public BigDecimal getCollectedTotal() { return collectedTotal; }
    public void setCollectedTotal(BigDecimal v) { this.collectedTotal = v; }
    public BigDecimal getCollectedCod() { return collectedCod; }
    public void setCollectedCod(BigDecimal v) { this.collectedCod = v; }
    public BigDecimal getCollectedOnline() { return collectedOnline; }
    public void setCollectedOnline(BigDecimal v) { this.collectedOnline = v; }
    public BigDecimal getRefundedTotal() { return refundedTotal; }
    public void setRefundedTotal(BigDecimal v) { this.refundedTotal = v; }
    public BigDecimal getPayoutPaid() { return payoutPaid; }
    public void setPayoutPaid(BigDecimal v) { this.payoutPaid = v; }
    public int getTotalTransactions() { return totalTransactions; }
    public void setTotalTransactions(int v) { this.totalTransactions = v; }
    public int getSuccessCount() { return successCount; }
    public void setSuccessCount(int v) { this.successCount = v; }
    public int getFailedCount() { return failedCount; }
    public void setFailedCount(int v) { this.failedCount = v; }
    public int getPendingCount() { return pendingCount; }
    public void setPendingCount(int v) { this.pendingCount = v; }
    public int getCodCount() { return codCount; }
    public void setCodCount(int v) { this.codCount = v; }
    public int getOnlineCount() { return onlineCount; }
    public void setOnlineCount(int v) { this.onlineCount = v; }
    public int getOnlineSuccess() { return onlineSuccess; }
    public void setOnlineSuccess(int v) { this.onlineSuccess = v; }
    public int getOnlineFailed() { return onlineFailed; }
    public void setOnlineFailed(int v) { this.onlineFailed = v; }
    public List<Map<String, Object>> getDaily() { return daily; }
    public List<Map<String, Object>> getByMethod() { return byMethod; }
    public List<Map<String, Object>> getFailureReasons() { return failureReasons; }

    /** Dòng tiền ròng giữ lại tại sàn = thu - hoàn - đã chi trả cho shop. */
    public BigDecimal getNetCashflow() {
        return collectedTotal.subtract(refundedTotal).subtract(payoutPaid);
    }

    /** Tỉ lệ giao dịch online lỗi trên các giao dịch online đã có kết quả. */
    public int getOnlineFailureRate() {
        int finished = onlineSuccess + onlineFailed;
        return finished == 0 ? 0 : (int) Math.round(onlineFailed * 100.0 / finished);
    }

    public int getCodPercent() {
        return totalTransactions == 0 ? 0 : (int) Math.round(codCount * 100.0 / totalTransactions);
    }

    public int getOnlinePercent() {
        return totalTransactions == 0 ? 0 : 100 - getCodPercent();
    }

    public int getCashPercent() {
        BigDecimal total = collectedCod.add(collectedOnline);
        return total.signum() == 0 ? 0
                : collectedCod.multiply(BigDecimal.valueOf(100)).divide(total, 0, java.math.RoundingMode.HALF_UP).intValue();
    }

    public int getElectronicPercent() {
        return collectedCod.add(collectedOnline).signum() == 0 ? 0 : 100 - getCashPercent();
    }
}
