package enums;

public enum PaymentMethod {
    COD,
    CARD,
    VNPAY,
    BANK_TRANSFER,
    MOMO;

    public static PaymentMethod from(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return valueOf(value.trim().toUpperCase(java.util.Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}

