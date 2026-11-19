package enums;

import java.util.Locale;

public enum TransactionType {
    // 1. Giao dịch kinh doanh
    SALE,             // Bán hàng xuất kho
    RESTOCK,          // Nhập thêm hàng mới vào kho

    // 2. Phân loại nông sản lỗi / hư hỏng / hao hụt
    DAMAGED,          // Trái cây dập nát, hư hỏng cơ học
    QUALITY_FAIL,     // Không đạt tiêu chuẩn ATVSTP kiểm định
    STORAGE_ISSUE,    // Sự cố kho mát / Sốc nhiệt / Mất điện
    EXPIRED,          // Hết hạn sử dụng / Quá date
    LOST,             // Hao hụt tự nhiên (bay hơi nước) / Thất thoát
    DISPOSAL;         // Tiêu hủy nông sản

    public static TransactionType from(String value) {
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
