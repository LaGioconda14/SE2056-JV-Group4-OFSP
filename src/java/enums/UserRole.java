package enums;

/**
 * Vai trò của người dùng trong hệ thống sàn (roles.role_name).
 */
public enum UserRole {
    ADMIN("Quản trị viên sàn", "bg-purple-100 text-purple-800 border-purple-200"),
    SHOP_OWNER("Chủ gian hàng", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    DRIVER("Tài xế giao hàng", "bg-blue-100 text-blue-800 border-blue-200"),
    CUSTOMER("Khách hàng", "bg-slate-100 text-slate-800 border-slate-200");

    private final String displayName;
    private final String badgeClass;

    UserRole(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static UserRole from(String value) {
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
