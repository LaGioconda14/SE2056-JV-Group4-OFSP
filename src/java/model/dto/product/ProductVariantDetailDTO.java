package model.dto.product;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 * Data Transfer Object chứa thông tin chi tiết của Biến thể sản phẩm (JOIN từ products, categories, shops, product_images).
 * Phục vụ cho: Form chỉnh sửa biến thể, Chọn biến thể ở Product Detail, Giỏ hàng (Cart), và Đặt hàng (Checkout/Order).
 */
public class ProductVariantDetailDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    // Variant core fields
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

    // Joined Product, Category & Image fields
    private String productName;
    private int categoryId;
    private String categoryName;
    private String origin;
    private String certification;
    private String storageTemp;
    private String description;
    private String image;
    private List<String> galleryImages;
    private int totalVariantsCount;

    // Joined Shop & Product status fields (for Cart & Checkout)
    private long shopId;
    private String shopName;
    private String shopStatus;
    private boolean productActive = true;

    public ProductVariantDetailDTO() {
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

    public boolean isIsActive() { return active; }
    public void setIsActive(boolean active) { this.active = active; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    public String getStorageTemp() { return storageTemp; }
    public void setStorageTemp(String storageTemp) { this.storageTemp = storageTemp; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public List<String> getGalleryImages() { return galleryImages; }
    public void setGalleryImages(List<String> galleryImages) { this.galleryImages = galleryImages; }

    public int getTotalVariantsCount() { return totalVariantsCount; }
    public void setTotalVariantsCount(int totalVariantsCount) { this.totalVariantsCount = totalVariantsCount; }

    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }

    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }

    public String getShopStatus() { return shopStatus; }
    public void setShopStatus(String shopStatus) { this.shopStatus = shopStatus; }

    public boolean isProductActive() { return productActive; }
    public void setProductActive(boolean productActive) { this.productActive = productActive; }
}
