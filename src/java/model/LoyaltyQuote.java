package model;

/** Thông tin để hiển thị khung "Dùng điểm" ở trang thanh toán. */
public class LoyaltyQuote {

    private int balance;          // điểm khách đang có
    private int vndPerPoint;      // 1 điểm = bao nhiêu đồng
    private int capPercent;       // trần % giá trị đơn được trả bằng điểm
    private int maxPoints;        // số điểm tối đa dùng được cho đơn này
    private String tierName;

    public int getBalance() { return balance; }
    public void setBalance(int v) { this.balance = v; }
    public int getVndPerPoint() { return vndPerPoint; }
    public void setVndPerPoint(int v) { this.vndPerPoint = v; }
    public int getCapPercent() { return capPercent; }
    public void setCapPercent(int v) { this.capPercent = v; }
    public int getMaxPoints() { return maxPoints; }
    public void setMaxPoints(int v) { this.maxPoints = v; }
    public String getTierName() { return tierName; }
    public void setTierName(String v) { this.tierName = v; }
}
