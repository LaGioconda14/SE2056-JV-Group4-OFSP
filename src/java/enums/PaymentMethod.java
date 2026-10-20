package enums;

public enum PaymentMethod {
    COD,
    CARD,
    VNPAY,
    MOMO;

    public static PaymentMethod from(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return PaymentMethod.valueOf(val.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}

