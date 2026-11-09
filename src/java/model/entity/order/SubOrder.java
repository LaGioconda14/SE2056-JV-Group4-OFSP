package model.entity.order;

import enums.DeliverySlot;
import enums.SubOrderStatus;
import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Entity ánh xạ trực tiếp bảng [dbo].[sub_orders].
 */
public class SubOrder implements Serializable {
    private static final long serialVersionUID = 1L;

    private long subOrderId;
    private String subOrderCode;
    private long orderId;
    private long shopId;
    private String deliverySlot;
    private BigDecimal shopSubtotal = BigDecimal.ZERO;
    private BigDecimal shopShippingFee = BigDecimal.ZERO;
    private BigDecimal shopDiscount = BigDecimal.ZERO;
    private BigDecimal shopTotal = BigDecimal.ZERO;
    private BigDecimal commissionRate = new BigDecimal("8.00");
    private BigDecimal commissionAmount = BigDecimal.ZERO;
    private String status = SubOrderStatus.NEW.name();
    private String cancelReason;
    private Long cancelledBy;
    private Timestamp cancelledAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public SubOrder() {
    }

    public long getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(long subOrderId) {
        this.subOrderId = subOrderId;
    }

    public String getSubOrderCode() {
        return subOrderCode;
    }

    public void setSubOrderCode(String subOrderCode) {
        this.subOrderCode = subOrderCode;
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

    public String getDeliverySlot() {
        return deliverySlot;
    }

    public void setDeliverySlot(String deliverySlot) {
        this.deliverySlot = deliverySlot;
    }

    public DeliverySlot getDeliverySlotEnum() {
        return DeliverySlot.from(deliverySlot);
    }

    public void setDeliverySlot(DeliverySlot deliverySlot) {
        this.deliverySlot = deliverySlot != null ? deliverySlot.name() : null;
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

    public BigDecimal getCommissionRate() {
        return commissionRate;
    }

    public void setCommissionRate(BigDecimal commissionRate) {
        this.commissionRate = commissionRate;
    }

    public BigDecimal getCommissionAmount() {
        return commissionAmount;
    }

    public void setCommissionAmount(BigDecimal commissionAmount) {
        this.commissionAmount = commissionAmount;
    }

    public String getStatus() {
        return status != null ? status : SubOrderStatus.NEW.name();
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public SubOrderStatus getStatusEnum() {
        return SubOrderStatus.from(status);
    }

    public void setStatus(SubOrderStatus status) {
        this.status = status != null ? status.name() : SubOrderStatus.NEW.name();
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
}
