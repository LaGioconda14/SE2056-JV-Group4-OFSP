package enums;

import java.util.Locale;

public enum DeliveryStatus {
    ASSIGNING,
    ASSIGNED,
    PICKED_UP,
    IN_TRANSIT,
    DELIVERING,
    DELIVERED,
    FAILED,
    CANCELLED;

    public static DeliveryStatus from(String value) {
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