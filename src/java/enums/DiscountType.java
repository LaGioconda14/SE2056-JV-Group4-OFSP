package enums;

/**
 * Loại hình giảm giá của mã khuyến mãi/Voucher (coupons.discount_type).
 */
public enum DiscountType {
    PERCENTAGE("Giảm theo %", "%"),
    FIXED_AMOUNT("Giảm số tiền cố định", "₫"),
    FREESHIP("Miễn phí vận chuyển", "Freeship");

    private final String displayName;
    private final String symbol;

    DiscountType(String displayName, String symbol) {
        this.displayName = displayName;
        this.symbol = symbol;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getSymbol() {
        return symbol;
    }

    public static DiscountType from(String value) {
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
