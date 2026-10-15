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
    private String imageUrl;

    public OrderItem() {
    }

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

    public String getFormattedUnitPrice() {
        long p = unitPrice != null ? unitPrice.longValue() : 0L;
        return String.format("%,d", p).replace(',', '.') + "₫";
    }

    public String getFormattedTotalPrice() {
        long p = totalPrice != null ? totalPrice.longValue() : 0L;
        return String.format("%,d", p).replace(',', '.') + "₫";
    }
}
