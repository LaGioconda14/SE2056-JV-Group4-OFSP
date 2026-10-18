package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SubOrder {

    private long subOrderId;
    private long orderId;
    private long shopId;
    private String shopName;
    private String deliverySlot;
    private BigDecimal shopSubtotal = BigDecimal.ZERO;
    private BigDecimal shopShippingFee = BigDecimal.ZERO;
    private BigDecimal shopDiscount = BigDecimal.ZERO;
    private BigDecimal shopTotal = BigDecimal.ZERO;
    private String status = "NEW";
    private String cancelReason;
    private Long cancelledBy;
    private Timestamp cancelledAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    private List<OrderItem> items = new ArrayList<>();

    public SubOrder() {
    }

    public long getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(long subOrderId) {
        this.subOrderId = subOrderId;
    }

    public long getOrderId() {
        return orderId;
    }

    public void setOrderId(long orderId) {
        this.orderId = orderId;
    }

    public long getShopId() {
        return shopId;
    }

    public void setShopId(long shopId) {
        this.shopId = shopId;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getDeliverySlot() {
        return deliverySlot;
    }

    public void setDeliverySlot(String deliverySlot) {
        this.deliverySlot = deliverySlot;
    }

    public BigDecimal getShopSubtotal() {
        return shopSubtotal;
    }

    public void setShopSubtotal(BigDecimal shopSubtotal) {
        this.shopSubtotal = shopSubtotal;
    }

    public BigDecimal getShopShippingFee() {
        return shopShippingFee;
    }

    public void setShopShippingFee(BigDecimal shopShippingFee) {
        this.shopShippingFee = shopShippingFee;
    }

    public BigDecimal getShopDiscount() {
        return shopDiscount;
    }

    public void setShopDiscount(BigDecimal shopDiscount) {
        this.shopDiscount = shopDiscount;
    }

    public BigDecimal getShopTotal() {
        return shopTotal;
    }

    public void setShopTotal(BigDecimal shopTotal) {
        this.shopTotal = shopTotal;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCancelReason() {
        return cancelReason;
    }

    public void setCancelReason(String cancelReason) {
        this.cancelReason = cancelReason;
    }

    public Long getCancelledBy() {
        return cancelledBy;
    }

    public void setCancelledBy(Long cancelledBy) {
        this.cancelledBy = cancelledBy;
    }

    public Timestamp getCancelledAt() {
        return cancelledAt;
    }

    public void setCancelledAt(Timestamp cancelledAt) {
        this.cancelledAt = cancelledAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }
}
