package enums;

/**
 * Trạng thái kỳ quyết toán doanh thu cho nhà vườn (vendor_payouts.status).
 */
public enum VendorPayoutStatus {
    PENDING("Chờ quyết toán", "bg-amber-100 text-amber-800 border-amber-200"),
    PROCESSING("Đang chuyển khoản", "bg-blue-100 text-blue-800 border-blue-200"),
    COMPLETED("Đã thanh toán", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    REJECTED("Từ chối quyết toán", "bg-rose-100 text-rose-800 border-rose-200");

    private final String displayName;
    private final String badgeClass;

    VendorPayoutStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static VendorPayoutStatus from(String value) {
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
