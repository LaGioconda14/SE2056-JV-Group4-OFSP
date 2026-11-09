package enums;

import java.util.Locale;

public enum VoucherStatus {
    UPCOMING,
    ACTIVE,
    EXPIRED,
    OUT_OF_STOCK,
    DISABLED;

    public static VoucherStatus from(String value) {
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