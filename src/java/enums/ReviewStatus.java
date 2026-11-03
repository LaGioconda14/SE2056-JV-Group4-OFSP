package enums;

/**
 * Trạng thái kiểm duyệt đánh giá sản phẩm (reviews.status).
 */
public enum ReviewStatus {
    PENDING("Chờ kiểm duyệt", "bg-amber-100 text-amber-800 border-amber-200"),
    APPROVED("Đã duyệt", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    REJECTED("Bị từ chối", "bg-rose-100 text-rose-800 border-rose-200"),
    HIDDEN("Tạm ẩn", "bg-slate-100 text-slate-800 border-slate-200");

    private final String displayName;
    private final String badgeClass;

    ReviewStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static ReviewStatus from(String value) {
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
