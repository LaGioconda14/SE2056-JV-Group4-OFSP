package model;

import java.text.DecimalFormat;
public class ProductVariant {
    private int variantId;
    private long productId;
    private String sku;
    private String productName;
    private String variantName;
    private double price;
    private double originalPrice;
    private int stockQuantity;
    private String unit;
    private String image;
    private String origin;
    private String categoryName;
    private String certification;
    private boolean isActive;
    private int totalVariantsCount;
    private int categoryId;
    private String storageTemp;
    private String description;
    private int lowStockThreshold;
    private java.util.List<String> galleryImages;

    public ProductVariant() {}

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getStorageTemp() { return storageTemp; }
    public void setStorageTemp(String storageTemp) { this.storageTemp = storageTemp; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getLowStockThreshold() { return lowStockThreshold; }
    public void setLowStockThreshold(int lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public java.util.List<String> getGalleryImages() { return galleryImages; }
    public void setGalleryImages(java.util.List<String> galleryImages) { this.galleryImages = galleryImages; }

    // Getters and Setters
    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getVariantName() { return variantName; }
    public void setVariantName(String variantName) { this.variantName = variantName; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public double getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(double originalPrice) { this.originalPrice = originalPrice; }

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
    public void setIsActive(boolean active) { isActive = active; }

    public int getTotalVariantsCount() { return totalVariantsCount; }
    public void setTotalVariantsCount(int totalVariantsCount) { this.totalVariantsCount = totalVariantsCount; }

    // Helpers for UI display
    public String getFormattedPrice() {
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(price).replace(',', '.');
    }

    public String getFormattedOriginalPrice() {
        if (originalPrice <= 0) return "";
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