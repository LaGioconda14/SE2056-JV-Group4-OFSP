package enums;

/**
 * Trạng thái hiệu lực của Voucher / Mã giảm giá.
 */
public enum VoucherStatus {
    UPCOMING("Sắp diễn ra", "bg-blue-100 text-blue-800 border-blue-200"),
    ACTIVE("Đang diễn ra", "bg-emerald-100 text-emerald-800 border-emerald-200"),
    EXPIRED("Đã hết hạn", "bg-slate-100 text-slate-800 border-slate-200"),
    OUT_OF_STOCK("Đã hết lượt", "bg-amber-100 text-amber-800 border-amber-200"),
    DISABLED("Tạm dừng", "bg-rose-100 text-rose-800 border-rose-200");

    private final String displayName;
    private final String badgeClass;

    VoucherStatus(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static VoucherStatus from(String value) {
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
