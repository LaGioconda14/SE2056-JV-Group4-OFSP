package model;

public class ProductVariant {
    private int variantId;
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

    public ProductVariant() {}

    // Getters và Setters đầy đủ
    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }
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
    public void setIsActive(boolean active) { isActive = active; }
}