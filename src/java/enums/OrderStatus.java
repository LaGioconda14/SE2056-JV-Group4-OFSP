package enums;

import java.util.Locale;

public enum OrderStatus {
    // Tiến trình đơn tổng độc lập với PaymentStatus và trạng thái giao hàng từng shop.
    PENDING,
    CONFIRMED,
    PROCESSING,
    SHIPPING,
    COMPLETED,
    CANCELLED;

    public static OrderStatus from(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return valueOf(value.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
