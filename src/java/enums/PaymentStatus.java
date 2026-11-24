package enums;

import java.util.Locale;

public enum PaymentStatus {
    // Trạng thái thanh toán của đơn, không phải trạng thái của một lần thử giao dịch VNPAY.
    PENDING,
    PAID,
    FAILED,
    REFUNDED;

    public static PaymentStatus from(String value) {
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
