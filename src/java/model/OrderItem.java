package model;

public class OrderItem {

    private long orderItemId;
    private long subOrderId;
    private String productName;
    private String variantName;
    private String unit;
    private double unitPrice;
    private int quantity;
    private double totalPrice;
    private String imageUrl;

    public OrderItem() {
    }

    public OrderItem(long orderItemId, long subOrderId, String productName, String variantName,
                     String unit, double unitPrice, int quantity, double totalPrice, String imageUrl) {
        this.orderItemId = orderItemId;
        this.subOrderId = subOrderId;
        this.productName = productName;
        this.variantName = variantName;
        this.unit = unit;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
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

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
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
        return String.format("%,d", (long) unitPrice).replace(',', '.') + "₫";
    }

    public String getFormattedTotalPrice() {
        return String.format("%,d", (long) totalPrice).replace(',', '.') + "₫";
    }
}

