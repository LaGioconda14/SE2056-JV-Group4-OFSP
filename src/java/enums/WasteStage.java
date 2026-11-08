package enums;

import java.util.Locale;

public enum WasteStage {
    QC_PACKING,
    TRANSIT_DAMAGE,
    WAREHOUSE_EXPIRED,
    CUSTOMER_RETURN;

    public static WasteStage from(String value) {
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