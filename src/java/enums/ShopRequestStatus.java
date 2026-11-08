package enums;

import java.util.Locale;

public enum ShopRequestStatus {
    PENDING,
    PENDING_KYC,
    APPROVED,
    REJECTED;

    public static ShopRequestStatus from(String value) {
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