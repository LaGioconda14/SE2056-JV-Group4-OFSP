package enums;

/**
 * Trạng thái khiếu nại / tranh chấp đơn hàng (disputes.status).
 */
public enum DisputeStatus {
    OPEN("Mới mở khiếu nại", "bg-amber-100 text-amber-800 border-amber-200"),
    MEDIATING("Đang hòa giải", "bg-blue-100 text-blue-800 border-blue-200"),
    REFUNDED_BUYER("Đã hoàn tiền cho khách", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    RESOLVED("Đã giải quyết", "bg-indigo-100 text-indigo-800 border-indigo-200"),
    REJECTED("Từ chối khiếu nại", "bg-rose-100 text-rose-800 border-rose-200"),
    CLOSED("Đã đóng", "bg-slate-100 text-slate-800 border-slate-200");

    private final String displayName;
    private final String badgeClass;

    DisputeStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static DisputeStatus from(String value) {
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
