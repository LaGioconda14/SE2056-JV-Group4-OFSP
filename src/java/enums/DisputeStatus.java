package enums;

import java.util.Locale;

public enum DisputeStatus {
    OPEN,
    MEDIATING,
    REFUNDED_BUYER,
    RESOLVED,
    REJECTED,
    CLOSED;

    public static DisputeStatus from(String value) {
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