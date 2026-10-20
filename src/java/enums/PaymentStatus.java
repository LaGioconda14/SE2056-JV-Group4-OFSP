package enums;

public enum PaymentStatus {
    PENDING,
    PAID,
    FAILED,
    REFUNDED;

    public static PaymentStatus from(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return PaymentStatus.valueOf(val.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}

