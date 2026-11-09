package enums;

import java.util.Locale;

public enum ApprovalStatus {
    PENDING,
    APPROVED,
    REJECTED,
    NEEDS_REVISION;

    public static ApprovalStatus from(String value) {
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