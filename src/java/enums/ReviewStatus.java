package enums;

import java.util.Locale;

public enum ReviewStatus {
    PENDING,
    APPROVED,
    REJECTED,
    HIDDEN;

    public static ReviewStatus from(String value) {
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