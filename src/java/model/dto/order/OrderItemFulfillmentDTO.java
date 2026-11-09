package model.dto.order;

import java.math.BigDecimal;

/**
 * Data Transfer Object mở rộng cho quy trình đóng gói, QC và giao vận chuỗi lạnh
 * (chứa thêm dữ liệu hiện tại từ bảng product_variants và products).
 */
public class OrderItemFulfillmentDTO extends OrderItemDetailDTO {
    private static final long serialVersionUID = 1L;

    private int stockQuantity;
    private BigDecimal weightKg;
    private String origin;
    private String certification;
    private String storageTemp;

    public OrderItemFulfillmentDTO() {
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public BigDecimal getWeightKg() {
        return weightKg;
    }

    public void setWeightKg(BigDecimal weightKg) {
        this.weightKg = weightKg;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getCertification() {
        return certification;
    }

    public void setCertification(String certification) {
        this.certification = certification;
    }

    public String getStorageTemp() {
        return storageTemp;
    }

    public void setStorageTemp(String storageTemp) {
        this.storageTemp = storageTemp;
    }
}
