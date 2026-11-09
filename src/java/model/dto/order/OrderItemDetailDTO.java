package model.dto.order;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Data Transfer Object phục vụ hiển thị chi tiết dòng sản phẩm trong đơn hàng
 * (Checkout, Order Confirmation, Lịch sử mua hàng của khách).
 */
public class OrderItemDetailDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private long orderItemId;
    private long subOrderId;
    private Long variantId;
    private Long productId;
    private String productNameSnapshot;
    private String variantNameSnapshot;
    private String skuSnapshot;
    private String unit;
    private BigDecimal unitPrice = BigDecimal.ZERO;
    private int quantity;
    private BigDecimal totalPrice = BigDecimal.ZERO;
    private Long promotionId;
    private BigDecimal promotionDiscount = BigDecimal.ZERO;
    private int promotionUnits;
    private String imageUrl;

    public OrderItemDetailDTO() {
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

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getProductNameSnapshot() {
        return productNameSnapshot;
    }

    public void setProductNameSnapshot(String productNameSnapshot) {
        this.productNameSnapshot = productNameSnapshot;
    }

    public String getVariantNameSnapshot() {
        return variantNameSnapshot;
    }

    public void setVariantNameSnapshot(String variantNameSnapshot) {
        this.variantNameSnapshot = variantNameSnapshot;
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
        this.unitPrice = unitPrice != null ? unitPrice : BigDecimal.ZERO;
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
        this.totalPrice = totalPrice != null ? totalPrice : BigDecimal.ZERO;
    }

    public Long getPromotionId() {
        return promotionId;
    }

    public void setPromotionId(Long promotionId) {
        this.promotionId = promotionId;
    }

    public BigDecimal getPromotionDiscount() {
        return promotionDiscount;
    }

    public void setPromotionDiscount(BigDecimal promotionDiscount) {
        this.promotionDiscount = promotionDiscount == null ? BigDecimal.ZERO : promotionDiscount;
    }

    public int getPromotionUnits() {
        return promotionUnits;
    }

    public void setPromotionUnits(int promotionUnits) {
        this.promotionUnits = promotionUnits;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}
