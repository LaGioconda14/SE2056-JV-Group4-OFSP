package enums;

public enum SubOrderStatus {
    NEW,
    CONFIRMED,
    PACKING,
    SHIPPING,
    DELIVERED,
    FAILED,
    RETURNED,
    REFUNDED,
    CANCELLED;

    public static SubOrderStatus from(String value) {
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

