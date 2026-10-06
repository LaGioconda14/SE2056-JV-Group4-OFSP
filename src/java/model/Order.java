/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.security.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Admin
 */
public class Order {

    private long orderId;
    private long customerId;
    private int couponId;

    private BigDecimal totalGoodAmount;
    private BigDecimal totalShippingFee;

    private BigDecimal platformDiscount;
    private BigDecimal finalAmount;

    private String paymentStatus;

    private Timestamp createAt;
    private Timestamp updateAt;
    
    private List<SubOrder> subOrders = new ArrayList<>();

    public Order() {
    }

    public Order(long orderId, long customerId, int couponId, BigDecimal totalGoodAmount, BigDecimal totalShippingFee, BigDecimal platformDiscount, BigDecimal finalAmount, String paymentStatus, Timestamp createAt, Timestamp updateAt) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.couponId = couponId;
        this.totalGoodAmount = totalGoodAmount;
        this.totalShippingFee = totalShippingFee;
        this.platformDiscount = platformDiscount;
        this.finalAmount = finalAmount;
        this.paymentStatus = paymentStatus;
        this.createAt = createAt;
        this.updateAt = updateAt;
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

    public int getCouponId() {
        return couponId;
    }

    public void setCouponId(int couponId) {
        this.couponId = couponId;
    }

    public BigDecimal getTotalGoodAmount() {
        return totalGoodAmount;
    }

    public void setTotalGoodAmount(BigDecimal totalGoodAmount) {
        this.totalGoodAmount = totalGoodAmount;
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

    public Timestamp getCreateAt() {
        return createAt;
    }

    public void setCreateAt(Timestamp createAt) {
        this.createAt = createAt;
    }

    public Timestamp getUpdateAt() {
        return updateAt;
    }

    public void setUpdateAt(Timestamp updateAt) {
        this.updateAt = updateAt;
    }

    public List<SubOrder> getSubOrders() {
        return subOrders;
    }

    public void setSubOrders(List<SubOrder> subOrders) {
        this.subOrders = subOrders;
    }

}
