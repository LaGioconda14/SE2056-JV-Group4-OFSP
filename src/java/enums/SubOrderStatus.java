package enums;

import java.util.Locale;

public enum SubOrderStatus {
    // Mỗi shop xử lý phần đơn của mình; DELIVERED không đồng nghĩa đơn tổng đã thanh toán.
    NEW,
    CONFIRMED,
    PACKING,
    SHIPPING,
    DELIVERED,
    FAILED,
    CANCELLED;

    public static SubOrderStatus from(String value) {
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
