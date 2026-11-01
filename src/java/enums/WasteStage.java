package enums;

/**
 * Công đoạn phát sinh hàng hao hụt / hư hỏng (inventory_waste_logs.waste_stage).
 */
public enum WasteStage {
    QC_PACKING("Hao hụt khâu kiểm định & đóng gói", "bg-amber-100 text-amber-800 border-amber-200"),
    TRANSIT_DAMAGE("Hư dập trong quá trình vận chuyển", "bg-rose-100 text-rose-800 border-rose-200"),
    WAREHOUSE_EXPIRED("Quá hạn sử dụng trong kho mát", "bg-orange-100 text-orange-800 border-orange-200"),
    CUSTOMER_RETURN("Khách hàng khiếu nại trả về", "bg-purple-100 text-purple-800 border-purple-200");

    private final String displayName;
    private final String badgeClass;

    WasteStage(String displayName, String badgeClass) {
        this.displayName = displayName;
        this.badgeClass = badgeClass;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public static WasteStage from(String value) {
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
