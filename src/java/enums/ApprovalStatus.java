package enums;

public enum ApprovalStatus {
    PENDING,
    APPROVED,
    REJECTED,
    NEEDS_REVISION;

    public static ApprovalStatus from(String value) {
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
