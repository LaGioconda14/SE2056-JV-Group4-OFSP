package enums;

import java.util.Locale;

public enum ShopStatus {
    ACTIVE,
    PENDING_KYC,
    SUSPENDED,
    REJECTED,
    INACTIVE;

    public static ShopStatus from(String value) {
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