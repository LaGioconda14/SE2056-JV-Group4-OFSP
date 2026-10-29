package model;

import java.math.BigDecimal;

/** Kết quả kiểm tra một mã voucher ở bước checkout. */
public class VoucherCheckResult {

    private boolean valid;
    private String message;
    private int couponId;
    private String code;
    private String title;
    private String discountType;
    private Long shopId;            // null = voucher sàn
    private BigDecimal discount = BigDecimal.ZERO;

    public static VoucherCheckResult fail(String message) {
        VoucherCheckResult r = new VoucherCheckResult();
        r.valid = false;
        r.message = message;
        return r;
    }

    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public int getCouponId() { return couponId; }
    public void setCouponId(int couponId) { this.couponId = couponId; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }
    public Long getShopId() { return shopId; }
    public void setShopId(Long shopId) { this.shopId = shopId; }
    public BigDecimal getDiscount() { return discount; }
    public void setDiscount(BigDecimal discount) { this.discount = discount; }
}
