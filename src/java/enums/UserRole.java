package enums;

import java.util.Locale;

public enum UserRole {
    ADMIN,
    SHOP_OWNER,
    DRIVER,
    CUSTOMER;

    public static UserRole from(String value) {
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