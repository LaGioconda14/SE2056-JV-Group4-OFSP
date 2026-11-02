package enums;

/**
 * Trạng thái của đơn hàng tổng (orders.order_status).
 */
public enum OrderStatus {
    PENDING("Chờ xác nhận", "bg-amber-100 text-amber-800 border-amber-200"),
    CONFIRMED("Đã xác nhận", "bg-blue-100 text-blue-800 border-blue-200"),
    PROCESSING("Đang xử lý", "bg-sky-100 text-sky-800 border-sky-200"),
    SHIPPING("Đang giao hàng", "bg-indigo-100 text-indigo-800 border-indigo-200"),
    COMPLETED("Hoàn tất", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    CANCELLED("Đã hủy", "bg-rose-100 text-rose-800 border-rose-200");

    private final String displayName;
    private final String badgeClass;

    OrderStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static OrderStatus from(String value) {
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
