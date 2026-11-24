package enums;

import java.util.Locale;

public enum PaymentType {
    // Phân loại hình thức thu tiền (tiền mặt/online), khác với phương thức cụ thể như COD/VNPAY.
    CASH,
    ONLINE;

    public static PaymentType from(String value) {
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
