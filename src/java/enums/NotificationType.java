package enums;

/**
 * Phân loại thông báo hệ thống (notifications.type).
 */
public enum NotificationType {
    ORDER("Đơn hàng", "bi-box-seam", "text-emerald-600 bg-emerald-50"),
    KYC("Hồ sơ gian hàng", "bi-shield-check", "text-blue-600 bg-blue-50"),
    DISPUTE("Khiếu nại", "bi-exclamation-triangle", "text-rose-600 bg-rose-50"),
    PROMOTION("Khuyến mãi", "bi-ticket-perforated", "text-purple-600 bg-purple-50"),
    SYSTEM("Hệ thống", "bi-bell", "text-slate-600 bg-slate-50");

    private final String displayName;
    private final String iconClass;
    private final String styleClass;

    NotificationType(String displayName, String iconClass, String styleClass) {
        this.displayName = displayName;
        this.iconClass = iconClass;
        this.styleClass = styleClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getIconClass() {
        return iconClass;
    }

    public String getStyleClass() {
        return styleClass;
    }

    public static NotificationType from(String value) {
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
