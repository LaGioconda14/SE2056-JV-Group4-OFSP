package model.dto.order;

import enums.DeliverySlot;
import enums.PaymentMethod;
import enums.PaymentStatus;
import enums.SubOrderStatus;
import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.entity.order.ShippingAddress;

/**
 * Data Transfer Object phục vụ danh sách đơn hàng con, bản nháp Checkout và xác nhận đơn hàng.
 */
public class SubOrderDTO implements Serializable {
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
    private String status = SubOrderStatus.NEW.name();
    private String cancelReason;
    private Long cancelledBy;
    private Timestamp cancelledAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined / Draft fields
    private String shopName;
    private String shopLogoUrl;
    private String orderCode;
    private String paymentMethod = PaymentMethod.COD.name();
    private String paymentStatus = PaymentStatus.PENDING.name();
    private Integer shopCouponId;
    private String shopCouponCode;
    private ShippingAddress shippingAddress;
    private DeliveryDTO delivery;
    private List<OrderItemDetailDTO> items = new ArrayList<>();

    public SubOrderDTO() {
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
        this.shopSubtotal = shopSubtotal != null ? shopSubtotal : BigDecimal.ZERO;
    }

    public BigDecimal getShopShippingFee() {
        return shopShippingFee;
    }

    public void setShopShippingFee(BigDecimal shopShippingFee) {
        this.shopShippingFee = shopShippingFee != null ? shopShippingFee : BigDecimal.ZERO;
    }

    public BigDecimal getShopDiscount() {
        return shopDiscount;
    }

    public void setShopDiscount(BigDecimal shopDiscount) {
        this.shopDiscount = shopDiscount != null ? shopDiscount : BigDecimal.ZERO;
    }

    public BigDecimal getShopTotal() {
        return shopTotal;
    }

    public void setShopTotal(BigDecimal shopTotal) {
        this.shopTotal = shopTotal != null ? shopTotal : BigDecimal.ZERO;
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

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getShopLogoUrl() {
        return shopLogoUrl;
    }

    public void setShopLogoUrl(String shopLogoUrl) {
        this.shopLogoUrl = shopLogoUrl;
    }

    public String getOrderCode() {
        return orderCode;
    }

    public void setOrderCode(String orderCode) {
        this.orderCode = orderCode;
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

    public void setPaymentMethod(PaymentMethod method) {
        this.paymentMethod = method != null ? method.name() : PaymentMethod.COD.name();
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public PaymentStatus getPaymentStatusEnum() {
        PaymentStatus statusEnum = PaymentStatus.from(paymentStatus);
        return statusEnum != null ? statusEnum : PaymentStatus.PENDING;
    }

    public void setPaymentStatus(PaymentStatus paymentStatus) {
        this.paymentStatus = paymentStatus != null ? paymentStatus.name() : PaymentStatus.PENDING.name();
    }

    public boolean isWaitingOnlinePayment() {
        boolean isOnline = PaymentMethod.VNPAY.name().equalsIgnoreCase(paymentMethod)
                || PaymentMethod.CARD.name().equalsIgnoreCase(paymentMethod);
        return isOnline && !PaymentStatus.PAID.name().equalsIgnoreCase(paymentStatus);
    }

    public boolean getWaitingOnlinePayment() {
        return isWaitingOnlinePayment();
    }

    public boolean isPaid() {
        return PaymentStatus.PAID.name().equalsIgnoreCase(paymentStatus);
    }

    public Integer getShopCouponId() {
        return shopCouponId;
    }

    public void setShopCouponId(Integer shopCouponId) {
        this.shopCouponId = shopCouponId;
    }

    public String getShopCouponCode() {
        return shopCouponCode;
    }

    public void setShopCouponCode(String shopCouponCode) {
        this.shopCouponCode = shopCouponCode;
    }

    public ShippingAddress getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(ShippingAddress shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public DeliveryDTO getDelivery() {
        return delivery;
    }

    public void setDelivery(DeliveryDTO delivery) {
        this.delivery = delivery;
    }

    public List<OrderItemDetailDTO> getItems() {
        return items;
    }

    public void setItems(List<OrderItemDetailDTO> items) {
        this.items = items != null ? items : new ArrayList<>();
    }
}
