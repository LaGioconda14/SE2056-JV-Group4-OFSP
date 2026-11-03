package enums;

/**
 * Trạng thái hoạt động của gian hàng (shops.status).
 */
public enum ShopStatus {
    ACTIVE("Đang hoạt động", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    PENDING_KYC("Chờ duyệt KYC", "bg-amber-100 text-amber-800 border-amber-200"),
    SUSPENDED("Tạm khóa", "bg-rose-100 text-rose-800 border-rose-200"),
    REJECTED("Bị từ chối", "bg-slate-100 text-slate-800 border-slate-200"),
    INACTIVE("Ngừng hoạt động", "bg-gray-100 text-gray-800 border-gray-200");

    private final String displayName;
    private final String badgeClass;

    ShopStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static ShopStatus from(String value) {
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
