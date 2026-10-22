package enums;

public enum AvailabilityStatus {
    OFFLINE,
    AVAILABLE,
    BUSY;

    public static AvailabilityStatus from(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return valueOf(value.trim().toUpperCase(java.util.Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
