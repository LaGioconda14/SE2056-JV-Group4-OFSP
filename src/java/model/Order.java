package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Order {

    private long orderId;
    private long customerId;
    private Integer couponId;
    private BigDecimal totalGoodsAmount = BigDecimal.ZERO;
    private BigDecimal totalShippingFee = BigDecimal.ZERO;
    private BigDecimal platformDiscount = BigDecimal.ZERO;
    private BigDecimal finalAmount = BigDecimal.ZERO;
    private String paymentStatus = "PENDING";
    private Timestamp createdAt;
    private Timestamp updatedAt;

    private ShippingAddress shippingAddress;
    private List<SubOrder> subOrders = new ArrayList<>();

    public Order() {
    }

    public long getOrderId() {
        return orderId;
    }

    public void setOrderId(long orderId) {
        this.orderId = orderId;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public Integer getCouponId() {
        return couponId;
    }

    public void setCouponId(Integer couponId) {
        this.couponId = couponId;
    }

    public BigDecimal getTotalGoodsAmount() {
        return totalGoodsAmount;
    }

    public void setTotalGoodsAmount(BigDecimal totalGoodsAmount) {
        this.totalGoodsAmount = totalGoodsAmount;
    }

    public BigDecimal getTotalShippingFee() {
        return totalShippingFee;
    }

    public void setTotalShippingFee(BigDecimal totalShippingFee) {
        this.totalShippingFee = totalShippingFee;
    }

    public BigDecimal getPlatformDiscount() {
        return platformDiscount;
    }

    public void setPlatformDiscount(BigDecimal platformDiscount) {
        this.platformDiscount = platformDiscount;
    }

    public BigDecimal getFinalAmount() {
        return finalAmount;
    }

    public void setFinalAmount(BigDecimal finalAmount) {
        this.finalAmount = finalAmount;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
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

    public ShippingAddress getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(ShippingAddress shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public List<SubOrder> getSubOrders() {
        return subOrders;
    }

    public void setSubOrders(List<SubOrder> subOrders) {
        this.subOrders = subOrders;
    }
}
