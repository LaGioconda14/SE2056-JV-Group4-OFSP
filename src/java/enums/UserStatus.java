package enums;

/**
 * Trạng thái tài khoản người dùng (users.status).
 */
public enum UserStatus {
    ACTIVE("Hoạt động", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    BLOCKED("Đã khóa", "bg-rose-100 text-rose-800 border-rose-200"),
    INACTIVE("Chưa kích hoạt", "bg-slate-100 text-slate-800 border-slate-200");

    private final String displayName;
    private final String badgeClass;

    UserStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static UserStatus from(String value) {
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
