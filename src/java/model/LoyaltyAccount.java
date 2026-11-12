package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/** Tài khoản điểm thưởng của khách hàng (bảng loyalty_accounts) kèm hạng hiện tại và hạng kế tiếp. */
public class LoyaltyAccount {

    private long accountId;
    private long customerId;
    private int currentPoints;       // điểm đang có, dùng được
    private int lifetimePoints;      // tổng điểm đã tích luỹ, dùng để xét hạng
    private MembershipTier tier;
    private MembershipTier nextTier; // null nếu đã ở hạng cao nhất
    private BigDecimal pointValueVnd = BigDecimal.ZERO; // giá trị quy đổi của điểm hiện có
    private Timestamp createdAt;

    public long getAccountId() { return accountId; }
    public void setAccountId(long v) { this.accountId = v; }
    public long getCustomerId() { return customerId; }
    public void setCustomerId(long v) { this.customerId = v; }
    public int getCurrentPoints() { return currentPoints; }
    public void setCurrentPoints(int v) { this.currentPoints = v; }
    public int getLifetimePoints() { return lifetimePoints; }
    public void setLifetimePoints(int v) { this.lifetimePoints = v; }
    public MembershipTier getTier() { return tier; }
    public void setTier(MembershipTier v) { this.tier = v; }
    public MembershipTier getNextTier() { return nextTier; }
    public void setNextTier(MembershipTier v) { this.nextTier = v; }
    public BigDecimal getPointValueVnd() { return pointValueVnd; }
    public void setPointValueVnd(BigDecimal v) { this.pointValueVnd = v; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp v) { this.createdAt = v; }

    public boolean isTopTier() { return nextTier == null; }

    /** Số điểm tích luỹ còn thiếu để lên hạng kế tiếp (0 nếu đã ở hạng cao nhất). */
    public int getPointsToNextTier() {
        return nextTier == null ? 0 : Math.max(0, nextTier.getMinPoints() - lifetimePoints);
    }

    /** Phần trăm tiến độ trong khoảng từ hạng hiện tại tới hạng kế tiếp (0 - 100). */
    public int getProgressPercent() {
        if (nextTier == null || tier == null) {
            return 100;
        }
        int span = nextTier.getMinPoints() - tier.getMinPoints();
        if (span <= 0) {
            return 100;
        }
        int done = lifetimePoints - tier.getMinPoints();
        return Math.max(0, Math.min(100, (int) Math.round(done * 100.0 / span)));
    }

    public String getMemberSince() {
        return createdAt == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(createdAt);
    }
}
