package enums;

import java.util.Locale;

public enum PaymentType {
    CASH,
    ONLINE;

    public static PaymentType from(String value) {
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
