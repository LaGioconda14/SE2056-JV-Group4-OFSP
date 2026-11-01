package enums;

/**
 * Trạng thái hồ sơ đăng ký mở gian hàng (shop_requests.status).
 */
public enum ShopRequestStatus {
    PENDING("Chờ duyệt", "bg-amber-100 text-amber-800 border-amber-200"),
    PENDING_KYC("Chờ xác thực KYC", "bg-blue-100 text-blue-800 border-blue-200"),
    APPROVED("Đã phê duyệt", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    REJECTED("Bị từ chối", "bg-rose-100 text-rose-800 border-rose-200");

    private final String displayName;
    private final String badgeClass;

    ShopRequestStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static ShopRequestStatus from(String value) {
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
