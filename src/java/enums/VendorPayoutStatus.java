package enums;

import java.util.Locale;

public enum VendorPayoutStatus {
    PENDING,
    PROCESSING,
    COMPLETED,
    REJECTED;

    public static VendorPayoutStatus from(String value) {
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