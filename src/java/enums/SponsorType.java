package enums;

/**
 * Đơn vị tài trợ cho Voucher (coupons.sponsor_type).
 */
public enum SponsorType {
    PLATFORM("Sàn tài trợ", "bg-purple-100 text-purple-800"),
    VENDOR("Nhà vườn tài trợ", "bg-emerald-100 text-emerald-800");

    private final String displayName;
    private final String badgeClass;

    SponsorType(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static SponsorType from(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return valueOf(value.trim().toUpperCase(java.util.Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
