package model;

/** Luật của chương trình điểm thưởng (bảng loyalty_settings). */
public class LoyaltySettings {

    private int earnVndPerPoint = 10000;
    private int redeemVndPerPoint = 100;
    private int maxRedeemPercent = 50;
    private String earnStartDate;

    public int getEarnVndPerPoint() { return earnVndPerPoint; }
    public void setEarnVndPerPoint(int v) { this.earnVndPerPoint = v; }
    public int getRedeemVndPerPoint() { return redeemVndPerPoint; }
    public void setRedeemVndPerPoint(int v) { this.redeemVndPerPoint = v; }
    public int getMaxRedeemPercent() { return maxRedeemPercent; }
    public void setMaxRedeemPercent(int v) { this.maxRedeemPercent = v; }
    public String getEarnStartDate() { return earnStartDate; }
    public void setEarnStartDate(String v) { this.earnStartDate = v; }
}
