package enums;

import java.util.Locale;

public enum ProductStatus {
    ACTIVE,        // Đang mở bán
    LOW_STOCK,     // Sắp hết hàng (tồn kho <= 5)
    OUT_OF_STOCK,  // Hết hàng (tồn kho == 0)
    HIDDEN;        // Tạm ẩn / Ngừng kinh doanh

    public static ProductStatus from(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return valueOf(value.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
