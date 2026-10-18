package model;

import java.math.BigDecimal;

public class OrderItem {

    private long orderItemId;
    private long subOrderId;
    private Long variantId;
    private String productNameSnapshot;
    private String variantNameSnapshot;
    private String skuSnapshot;
    private String unit;
    private BigDecimal unitPrice = BigDecimal.ZERO;
    private int quantity;
    private BigDecimal totalPrice = BigDecimal.ZERO;

    // Joined Product & Variant fields for Fulfillment & QC
    private String imageUrl;
    private int stockQuantity = 10;
    private BigDecimal weightKg;
    private String origin;
    private String certification;
    private String storageTemp;
    private String qcBrix;
    private String qcStatus;
    private String qcNote;
    private String qcPackagingNote;

    public OrderItem() {
    }

    /**
     * Constructor for customer purchase history (feature/auth)
     */
    public OrderItem(long orderItemId, long subOrderId, String productName, String variantName,
                     String unit, double unitPrice, int quantity, double totalPrice, String imageUrl) {
        this.orderItemId = orderItemId;
        this.subOrderId = subOrderId;
        this.productNameSnapshot = productName;
        this.variantNameSnapshot = variantName;
        this.unit = unit;
        this.unitPrice = BigDecimal.valueOf(unitPrice);
        this.quantity = quantity;
        this.totalPrice = BigDecimal.valueOf(totalPrice);
        this.imageUrl = imageUrl;
    }

    /**
     * Full constructor for shop order fulfillment (feature/order_fulfillment)
     */
    public OrderItem(long orderItemId, long subOrderId, Long variantId, String productNameSnapshot,
            String variantNameSnapshot, String skuSnapshot, String unit, BigDecimal unitPrice,
            int quantity, BigDecimal totalPrice) {
        this.orderItemId = orderItemId;
        this.subOrderId = subOrderId;
        this.variantId = variantId;
        this.productNameSnapshot = productNameSnapshot;
        this.variantNameSnapshot = variantNameSnapshot;
        this.skuSnapshot = skuSnapshot;
        this.unit = unit;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
    }

    public long getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(long orderItemId) {
        this.orderItemId = orderItemId;
    }

    public long getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(long subOrderId) {
        this.subOrderId = subOrderId;
    }

    public Long getVariantId() {
        return variantId;
    }

    public void setVariantId(Long variantId) {
        this.variantId = variantId;
    }

    public String getProductNameSnapshot() {
        return productNameSnapshot;
    }

    public void setProductNameSnapshot(String productNameSnapshot) {
        this.productNameSnapshot = productNameSnapshot;
    }

    public String getProductName() {
        return productNameSnapshot;
    }

    public void setProductName(String productName) {
        this.productNameSnapshot = productName;
    }

    public String getVariantNameSnapshot() {
        return variantNameSnapshot;
    }

    public void setVariantNameSnapshot(String variantNameSnapshot) {
        this.variantNameSnapshot = variantNameSnapshot;
    }

    public String getVariantName() {
        return variantNameSnapshot;
    }

    public void setVariantName(String variantName) {
        this.variantNameSnapshot = variantName;
    }

    public String getSkuSnapshot() {
        return skuSnapshot;
    }

    public void setSkuSnapshot(String skuSnapshot) {
        this.skuSnapshot = skuSnapshot;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = BigDecimal.valueOf(unitPrice);
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = BigDecimal.valueOf(totalPrice);
    }

    public String getImageUrl() {
        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            return imageUrl;
        }
        return "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop";
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
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

    public String getQcBrix() {
        return qcBrix;
    }

    public void setQcBrix(String qcBrix) {
        this.qcBrix = qcBrix;
    }

    public String getQcStatus() {
        return qcStatus;
    }

    public void setQcStatus(String qcStatus) {
        this.qcStatus = qcStatus;
    }

    public String getQcNote() {
        return qcNote;
    }

    public void setQcNote(String qcNote) {
        this.qcNote = qcNote;
    }

    public String getQcPackagingNote() {
        return qcPackagingNote;
    }

    public void setQcPackagingNote(String qcPackagingNote) {
        this.qcPackagingNote = qcPackagingNote;
    }

    public String getFormattedUnitPrice() {
        return String.format("%,d", unitPrice != null ? unitPrice.longValue() : 0).replace(',', '.') + "₫";
    }

    public String getFormattedTotalPrice() {
        return String.format("%,d", totalPrice != null ? totalPrice.longValue() : 0).replace(',', '.') + "₫";
    }
}
