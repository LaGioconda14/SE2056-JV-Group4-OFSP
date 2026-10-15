package model;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;

public record CartVoucher(String couponId, String code, String issuerType, String shopId,
        String shopName, String applyTo, String discountType, BigDecimal discountValue,
        BigDecimal minOrderValue, BigDecimal maxDiscountAmount, String endDate,
        BigDecimal discountAmount, boolean eligible, String reason) {

    private static final DateTimeFormatter END_DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    public static CartVoucher from(VoucherCoupon coupon, BigDecimal discountAmount) {
        return from(coupon, discountAmount, true, "");
    }

    public static CartVoucher from(VoucherCoupon coupon, BigDecimal discountAmount,
            boolean eligible, String reason) {
        return new CartVoucher(Long.toString(coupon.couponId()), coupon.code(), coupon.issuerType(),
                coupon.shopId() == null ? null : coupon.shopId().toString(), coupon.shopName(),
                coupon.applyTo(), coupon.discountType(), coupon.discountValue(), coupon.minOrderValue(),
                coupon.maxDiscountAmount(), coupon.endDate().format(END_DATE_FORMAT), discountAmount,
                eligible, reason);
    }
}
