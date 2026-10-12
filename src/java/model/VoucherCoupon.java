package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record VoucherCoupon(long couponId, String code, String issuerType, Long shopId,
        String shopName, String applyTo, String discountType, BigDecimal discountValue,
        BigDecimal minOrderValue, BigDecimal maxDiscountAmount, LocalDateTime endDate) {
}
