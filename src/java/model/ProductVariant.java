package model;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.List;

public class ProductVariant {
    private long variantId;
    private long productId;
    private Product product;
    private String sku;
    private String productName;
    private String variantName;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private BigDecimal weightKg;
    private int stockQuantity;
    private String unit;
    private String image;
    private String origin;
    private String categoryName;
    private String certification;
    private boolean isActive = true;
    private int totalVariantsCount;
    private int categoryId;
    private String storageTemp;
    private String description;
    private int lowStockThreshold;
    private List<String> galleryImages;

    public ProductVariant() {}

    public ProductVariant(long variantId, Product product, String sku, String variantName,
            String unit, BigDecimal weightKg, BigDecimal price, int stockQuantity,
            int lowStockThreshold, boolean active) {
        this.variantId = variantId;
        this.product = product;
        if (product != null) {
            this.productId = product.getId();
            this.productName = product.getName();
        }
        this.sku = sku;
        this.variantName = variantName;
        this.unit = unit;
        this.weightKg = weightKg;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.lowStockThreshold = lowStockThreshold;
        this.isActive = active;
    }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getStorageTemp() { return storageTemp; }
    public void setStorageTemp(String storageTemp) { this.storageTemp = storageTemp; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getLowStockThreshold() { return lowStockThreshold; }
    public void setLowStockThreshold(int lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public List<String> getGalleryImages() { return galleryImages; }
    public void setGalleryImages(List<String> galleryImages) { this.galleryImages = galleryImages; }

    // Getters and Setters
    public long getVariantId() { return variantId; }
    public void setVariantId(long variantId) { this.variantId = variantId; }

    public long getProductId() {
        if (productId == 0 && product != null) {
            return product.getId();
        }
        return productId;
    }
    public void setProductId(long productId) { this.productId = productId; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) {
        this.product = product;
        if (product != null && this.productId == 0) {
            this.productId = product.getId();
            if (this.productName == null) {
                this.productName = product.getName();
            }
        }
    }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getVariantName() { return variantName; }
    public void setVariantName(String variantName) { this.variantName = variantName; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public BigDecimal getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }

    public BigDecimal getWeightKg() { return weightKg; }
    public void setWeightKg(BigDecimal weightKg) { this.weightKg = weightKg; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    public boolean isIsActive() { return isActive; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { this.isActive = active; }
    public void setIsActive(boolean active) { this.isActive = active; }

    public int getTotalVariantsCount() { return totalVariantsCount; }
    public void setTotalVariantsCount(int totalVariantsCount) { this.totalVariantsCount = totalVariantsCount; }

    // Helpers for UI display
    public String getFormattedPrice() {
        if (price == null) return "0";
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(price).replace(',', '.');
    }

    public String getFormattedOriginalPrice() {
        if (originalPrice == null || originalPrice.compareTo(BigDecimal.ZERO) <= 0) {
            return "";
        }
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(originalPrice).replace(',', '.');
    }

    public String getStockStatusText() {
        if (stockQuantity <= 5) return "Nguy cấp";
        if (stockQuantity <= 15) return "Sắp hết";
        if (stockQuantity <= 40) return "Ổn định";
        return "Dồi dào";
    }

    public int getStockProgressPercent() {
        if (stockQuantity <= 5) return 15;
        if (stockQuantity <= 15) return 32;
        if (stockQuantity <= 40) return 60;
        return 88;
    }

    public String getStockStatusColor() {
        if (stockQuantity <= 5) return "text-red-600";
        if (stockQuantity <= 15) return "text-amber-600";
        return "text-emerald-600";
    }

    public String getStockBarColor() {
        if (stockQuantity <= 5) return "bg-red-500";
        if (stockQuantity <= 15) return "bg-amber-500";
        return "bg-emerald-600";
    }
}
