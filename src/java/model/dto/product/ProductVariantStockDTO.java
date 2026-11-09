package model.dto.product;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Data Transfer Object phục vụ màn hình Quản lý sản phẩm, Tồn kho & Hao hụt của Gian hàng.
 * Chứa các chỉ số hiển thị trạng thái tồn kho được tính từ tầng Service/Mapper.
 */
public class ProductVariantStockDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private long variantId;
    private long productId;
    private String productName;
    private String sku;
    private String variantName;
    private String unit;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private int stockQuantity;
    private int lowStockThreshold;
    private boolean active = true;

    // Joined display fields
    private String image;
    private String origin;
    private String categoryName;
    private String certification;
    private int totalVariantsCount;

    // Precomputed stock display metrics (populated outside Entity)
    private String stockStatusText;
    private String stockBarColor;
    private int stockProgressPercent;

    public ProductVariantStockDTO() {
    }

    public long getVariantId() { return variantId; }
    public void setVariantId(long variantId) { this.variantId = variantId; }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getVariantName() { return variantName; }
    public void setVariantName(String variantName) { this.variantName = variantName; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

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

    /** Alias cho JSP EL ${v.isActive}. */
    public boolean getIsActive() { return active; }
    public boolean isIsActive() { return active; }
    public void setIsActive(boolean active) { this.active = active; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    public int getTotalVariantsCount() { return totalVariantsCount; }
    public void setTotalVariantsCount(int totalVariantsCount) { this.totalVariantsCount = totalVariantsCount; }

    public String getStockStatusText() { return stockStatusText; }
    public void setStockStatusText(String stockStatusText) { this.stockStatusText = stockStatusText; }

    public String getStockBarColor() { return stockBarColor; }
    public void setStockBarColor(String stockBarColor) { this.stockBarColor = stockBarColor; }

    public int getStockProgressPercent() { return stockProgressPercent; }
    public void setStockProgressPercent(int stockProgressPercent) { this.stockProgressPercent = stockProgressPercent; }
}
