package model;

import java.math.BigDecimal;

public record VoucherCartItem(long itemId, long shopId, BigDecimal price,
        int stockQuantity, boolean available) {
}
