package enums;

public enum SubOrderStatus {
    NEW,
    PACKING,
    SHIPPING,
    DELIVERED,
    FAILED,
    RETURNED,
    CANCELLED;

    public static SubOrderStatus from(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return SubOrderStatus.valueOf(val.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}

