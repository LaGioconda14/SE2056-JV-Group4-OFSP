package enums;

import java.util.Locale;

public enum CartItemAvailability {
    AVAILABLE,
    VARIANT_UNAVAILABLE,
    SOLD_OUT,
    NOT_FOUND;

    public static CartItemAvailability from(String value) {
        if (value == null || value.isBlank()) {
            return NOT_FOUND;
        }
        try {
            return valueOf(value.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return NOT_FOUND;
        }
    }
}
