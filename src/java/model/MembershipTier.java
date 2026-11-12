package model;

import java.math.BigDecimal;

/** Một hạng thành viên (bảng membership_tiers). */
public class MembershipTier {

    private int tierId;
    private String tierCode;
    private String tierName;
    private int minPoints;
    private BigDecimal pointMultiplier = BigDecimal.ONE;
    private BigDecimal redeemCapPercent;     // null = dùng trần chung trong loyalty_settings
    private String badgeColor = "#16a34a";
    private String description;
    private boolean active = true;
    private int memberCount;                 // chỉ dùng ở màn hình Admin

    public int getTierId() { return tierId; }
    public void setTierId(int v) { this.tierId = v; }
    public String getTierCode() { return tierCode; }
    public void setTierCode(String v) { this.tierCode = v; }
    public String getTierName() { return tierName; }
    public void setTierName(String v) { this.tierName = v; }
    public int getMinPoints() { return minPoints; }
    public void setMinPoints(int v) { this.minPoints = v; }
    public BigDecimal getPointMultiplier() { return pointMultiplier; }
    public void setPointMultiplier(BigDecimal v) { this.pointMultiplier = v; }
    public BigDecimal getRedeemCapPercent() { return redeemCapPercent; }
    public void setRedeemCapPercent(BigDecimal v) { this.redeemCapPercent = v; }
    public String getBadgeColor() { return badgeColor; }
    public void setBadgeColor(String v) { this.badgeColor = v; }
    public String getDescription() { return description; }
    public void setDescription(String v) { this.description = v; }
    public boolean isActive() { return active; }
    public void setActive(boolean v) { this.active = v; }
    public int getMemberCount() { return memberCount; }
    public void setMemberCount(int v) { this.memberCount = v; }

    /** Hiển thị hệ số nhân, ví dụ "x1.25". */
    public String getMultiplierLabel() {
        return "x" + pointMultiplier.stripTrailingZeros().toPlainString();
    }

    /** Hiển thị trần dùng điểm; null nghĩa là theo quy định chung. */
    public String getRedeemCapLabel() {
        return redeemCapPercent == null ? "Theo quy định chung"
                : "Tối đa " + redeemCapPercent.stripTrailingZeros().toPlainString() + "% đơn hàng";
    }
}
