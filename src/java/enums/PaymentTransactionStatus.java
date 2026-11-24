package enums;

import java.util.Locale;

public enum PaymentTransactionStatus {
    // Mỗi lần thử thanh toán có kết quả riêng; cần đối chiếu với đơn trước khi cập nhật PaymentStatus.
    PENDING,
    SUCCESS,
    FAILED;

    public static PaymentTransactionStatus from(String value) {
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
