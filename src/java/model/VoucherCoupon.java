package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record VoucherCoupon(long couponId, String code, String issuerType, Long shopId,
        String shopName, String applyTo, String discountType, BigDecimal discountValue,
        BigDecimal minOrderValue, BigDecimal maxDiscountAmount, LocalDateTime endDate,
        boolean inWallet, int perUserLimit, int userUsedCount) {

    public VoucherCoupon(long couponId, String code, String issuerType, Long shopId,
            String shopName, String applyTo, String discountType, BigDecimal discountValue,
            BigDecimal minOrderValue, BigDecimal maxDiscountAmount, LocalDateTime endDate) {
        this(couponId, code, issuerType, shopId, shopName, applyTo, discountType,
                discountValue, minOrderValue, maxDiscountAmount, endDate, true, 1, 0);
    }
}

