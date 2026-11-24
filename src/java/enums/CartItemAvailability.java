package enums;

import java.util.Locale;

public enum CartItemAvailability {
    // Chỉ AVAILABLE được tính vào tổng giỏ và được chọn; trạng thái khác giữ dòng để khách xử lý.
    AVAILABLE,
    VARIANT_UNAVAILABLE,
    SOLD_OUT,
    NOT_FOUND;

    /** Giá trị thiếu/lạ được coi là NOT_FOUND thay vì mặc định cho phép mua. */
    public static CartItemAvailability from(String value) {
        if (value == null || value.isBlank()) {
            return NOT_FOUND;
        }
        try {
            return valueOf(value.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return NOT_FOUND;
        }
    }
}
