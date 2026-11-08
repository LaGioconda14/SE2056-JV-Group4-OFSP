package enums;

import java.util.Locale;

public enum DiscountType {
    PERCENTAGE,
    FIXED_AMOUNT,
    FREESHIP;

    public static DiscountType from(String value) {
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