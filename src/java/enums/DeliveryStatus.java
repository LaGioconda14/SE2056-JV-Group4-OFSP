package enums;

public enum DeliveryStatus {
    ASSIGNING,
    ASSIGNED,
    DELIVERING,
    DELIVERED,
    FAILED,
    CANCELLED;

    public static DeliveryStatus from(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return DeliveryStatus.valueOf(val.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}

