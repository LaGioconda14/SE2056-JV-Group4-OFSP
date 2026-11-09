package enums;

import java.util.Locale;

public enum AvailabilityStatus {
    OFFLINE,
    AVAILABLE,
    BUSY;

    public static AvailabilityStatus from(String value) {
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