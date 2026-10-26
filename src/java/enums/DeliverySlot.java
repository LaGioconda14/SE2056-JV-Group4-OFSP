package enums;

import java.util.Locale;

public enum DeliverySlot {
    MORNING,
    AFTERNOON,
    EVENING;

    public static DeliverySlot from(String value) {
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
