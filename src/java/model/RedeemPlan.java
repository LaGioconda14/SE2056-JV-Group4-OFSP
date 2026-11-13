package model;

import java.math.BigDecimal;

/** Kết quả kiểm tra dùng điểm: số điểm hợp lệ và số tiền được giảm. */
public class RedeemPlan {

    private final int points;
    private final BigDecimal discount;

    public RedeemPlan(int points, BigDecimal discount) {
        this.points = points;
        this.discount = discount;
    }

    public int getPoints() { return points; }
    public BigDecimal getDiscount() { return discount; }
}
