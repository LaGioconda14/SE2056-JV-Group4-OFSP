package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/** Một dòng lịch sử điểm (bảng loyalty_transactions). */
public class LoyaltyTransaction {

    public static final String EARN = "EARN";
    public static final String REDEEM = "REDEEM";
    public static final String RESTORE = "RESTORE";
    public static final String REVERSE = "REVERSE";
    public static final String ADJUST = "ADJUST";

    private long transactionId;
    private long accountId;
    private Long orderId;
    private String orderCode;
    private int pointsDelta;
    private String txType;
    private String description;
    private Integer balanceAfter;
    private Timestamp createdAt;

    public long getTransactionId() { return transactionId; }
    public void setTransactionId(long v) { this.transactionId = v; }
    public long getAccountId() { return accountId; }
    public void setAccountId(long v) { this.accountId = v; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long v) { this.orderId = v; }
    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String v) { this.orderCode = v; }
    public int getPointsDelta() { return pointsDelta; }
    public void setPointsDelta(int v) { this.pointsDelta = v; }
    public String getTxType() { return txType; }
    public void setTxType(String v) { this.txType = v; }
    public String getDescription() { return description; }
    public void setDescription(String v) { this.description = v; }
    public Integer getBalanceAfter() { return balanceAfter; }
    public void setBalanceAfter(Integer v) { this.balanceAfter = v; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp v) { this.createdAt = v; }

    public boolean isPositive() { return pointsDelta > 0; }

    public String getTypeLabel() {
        if (EARN.equals(txType)) return "Tích điểm";
        if (REDEEM.equals(txType)) return "Dùng điểm";
        if (RESTORE.equals(txType)) return "Hoàn điểm";
        if (REVERSE.equals(txType)) return "Thu hồi điểm";
        return "Điều chỉnh";
    }

    public String getCreatedAtFull() {
        return createdAt == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }
}
