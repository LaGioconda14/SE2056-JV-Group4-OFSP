package model.dto.order;

import enums.OrderStatus;
import enums.PaymentMethod;
import enums.PaymentStatus;
import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.entity.order.ShippingAddress;

/**
 * Data Transfer Object phục vụ bản nháp Checkout và màn hình Xác nhận đơn hàng (Order Confirmation).
 */
public class OrderDetailDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private long orderId;
    private String orderCode;
    private long customerId;
    private Integer couponId;
    private BigDecimal totalGoodsAmount = BigDecimal.ZERO;
    private BigDecimal totalShippingFee = BigDecimal.ZERO;
    private BigDecimal platformDiscount = BigDecimal.ZERO;
    private int loyaltyPointsUsed = 0;                          // FE-14: điểm thưởng đã dùng
    private BigDecimal loyaltyDiscount = BigDecimal.ZERO;       // FE-14: số tiền giảm từ điểm
    private BigDecimal finalAmount = BigDecimal.ZERO;
    private String paymentStatus = PaymentStatus.PENDING.name();
    private String paymentMethod = PaymentMethod.COD.name();
    private String orderStatus = OrderStatus.PROCESSING.name();
    private Timestamp createdAt;
    private Timestamp updatedAt;

    private ShippingAddress shippingAddress;
    private List<SubOrderDTO> subOrders = new ArrayList<>();

    public OrderDetailDTO() {
    }

    public long getOrderId() {
        return orderId;
    }

    public void setOrderId(long orderId) {
        this.orderId = orderId;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
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
        this.totalGoodsAmount = totalGoodsAmount != null ? totalGoodsAmount : BigDecimal.ZERO;
    }

    public BigDecimal getTotalShippingFee() {
        return totalShippingFee;
    }

    public void setTotalShippingFee(BigDecimal totalShippingFee) {
        this.totalShippingFee = totalShippingFee != null ? totalShippingFee : BigDecimal.ZERO;
    }

    public BigDecimal getPlatformDiscount() {
        return platformDiscount;
    }

    public void setPlatformDiscount(BigDecimal platformDiscount) {
        this.platformDiscount = platformDiscount != null ? platformDiscount : BigDecimal.ZERO;
    }

    public int getLoyaltyPointsUsed() {
        return loyaltyPointsUsed;
    }

    public void setLoyaltyPointsUsed(int loyaltyPointsUsed) {
        this.loyaltyPointsUsed = loyaltyPointsUsed;
    }

    public BigDecimal getLoyaltyDiscount() {
        return loyaltyDiscount;
    }

    public void setLoyaltyDiscount(BigDecimal loyaltyDiscount) {
        this.loyaltyDiscount = loyaltyDiscount == null ? BigDecimal.ZERO : loyaltyDiscount;
    }

    public BigDecimal getFinalAmount() {
        return finalAmount;
    }

    public void setFinalAmount(BigDecimal finalAmount) {
        this.finalAmount = finalAmount != null ? finalAmount : BigDecimal.ZERO;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public PaymentStatus getPaymentStatusEnum() {
        PaymentStatus status = PaymentStatus.from(paymentStatus);
        return status != null ? status : PaymentStatus.PENDING;
    }

    public void setPaymentStatus(PaymentStatus paymentStatus) {
        this.paymentStatus = paymentStatus != null ? paymentStatus.name() : PaymentStatus.PENDING.name();
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public PaymentMethod getPaymentMethodEnum() {
        PaymentMethod method = PaymentMethod.from(paymentMethod);
        return method != null ? method : PaymentMethod.COD;
    }

    public void setPaymentMethod(PaymentMethod paymentMethod) {
        this.paymentMethod = paymentMethod != null ? paymentMethod.name() : PaymentMethod.COD.name();
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public OrderStatus getOrderStatusEnum() {
        OrderStatus status = OrderStatus.from(orderStatus);
        return status != null ? status : OrderStatus.PROCESSING;
    }

    public void setOrderStatus(OrderStatus orderStatus) {
        this.orderStatus = orderStatus != null ? orderStatus.name() : OrderStatus.PROCESSING.name();
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

    public List<SubOrderDTO> getSubOrders() {
        return subOrders;
    }

    public void setSubOrders(List<SubOrderDTO> subOrders) {
        this.subOrders = subOrders != null ? subOrders : new ArrayList<>();
    }
}
