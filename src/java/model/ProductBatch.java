package model;

import java.sql.Date;

public class ProductBatch {

    private long batchId;
    private String batchCode;
    private long variantId;
    private int initialQuantity;
    private int currentQuantity;
    private Date expiryDate;
    private String status; // 'ACTIVE', 'EXPIRED', 'DEPLETED'

    // Các thuộc tính hỗ trợ hiển thị trên JSP (Join dữ liệu từ bảng khác)
    private String productName;
    private String variantName;
    private String sku;
    private String imageUrl;
    private String categoryName;

    public ProductBatch() {
    }

    public ProductBatch(long batchId, String batchCode, long variantId, int initialQuantity, int currentQuantity, Date expiryDate, String status) {
        this.batchId = batchId;
        this.batchCode = batchCode;
        this.variantId = variantId;
        this.initialQuantity = initialQuantity;
        this.currentQuantity = currentQuantity;
        this.expiryDate = expiryDate;
        this.status = status;
    }

    // Getters and Setters
    public long getBatchId() {
        return batchId;
    }

    public void setBatchId(long batchId) {
        this.batchId = batchId;
    }

    public String getBatchCode() {
        return batchCode;
    }

    public void setBatchCode(String batchCode) {
        this.batchCode = batchCode;
    }

    public long getVariantId() {
        return variantId;
    }

    public void setVariantId(long variantId) {
        this.variantId = variantId;
    }

    public int getInitialQuantity() {
        return initialQuantity;
    }

    public void setInitialQuantity(int initialQuantity) {
        this.initialQuantity = initialQuantity;
    }

    public int getCurrentQuantity() {
        return currentQuantity;
    }

    public void setCurrentQuantity(int currentQuantity) {
        this.currentQuantity = currentQuantity;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getVariantName() {
        return variantName;
    }

    public void setVariantName(String variantName) {
        this.variantName = variantName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
}
