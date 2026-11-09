package model.entity.product;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductVariant implements Serializable {
    private static final long serialVersionUID = 1L;

    private long variantId;
    private long productId;
    private String sku;
    private String variantName;
    private String unit;
    private BigDecimal weightKg;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private int stockQuantity;
    private int lowStockThreshold;
    private boolean active = true;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public ProductVariant() {
    }

    public long getVariantId() { return variantId; }
    public void setVariantId(long variantId) { this.variantId = variantId; }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getVariantName() { return variantName; }
    public void setVariantName(String variantName) { this.variantName = variantName; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public BigDecimal getWeightKg() { return weightKg; }
    public void setWeightKg(BigDecimal weightKg) { this.weightKg = weightKg; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public BigDecimal getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public int getLowStockThreshold() { return lowStockThreshold; }
    public void setLowStockThreshold(int lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
