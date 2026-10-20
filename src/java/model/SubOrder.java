package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import enums.SubOrderStatus;
import enums.DeliveryStatus;
import enums.PaymentStatus;
import enums.PaymentMethod;

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
    private String status = SubOrderStatus.NEW.name();
    private String cancelReason;
    private Long cancelledBy;
    private Timestamp cancelledAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    private String subOrderCode;
    private String orderCode;
    private String paymentMethod = PaymentMethod.COD.name();
    private String paymentStatus = PaymentStatus.PENDING.name();
    private String trackingNumber;
    private String carrierName;
    private String driverName;
    private String driverPhone;
    private String deliveryStatus;
    private String failureReason;
    private String proofImageUrl;
    private Timestamp deliveredAt;
    private ShippingAddress shippingAddress;
    private List<OrderItem> items = new ArrayList<>();
    private Integer shopCouponId;
    private String shopCouponCode;

    public String getDeliveryStatus() {
        return deliveryStatus;
    }

    public void setDeliveryStatus(String deliveryStatus) {
        this.deliveryStatus = deliveryStatus;
    }

    public DeliveryStatus getDeliveryStatusEnum() {
        if (deliveryStatus == null) return null;
        try {
            return DeliveryStatus.valueOf(deliveryStatus.trim().toUpperCase());
        } catch (Exception e) {
            return null;
        }
    }

    public void setDeliveryStatus(DeliveryStatus deliveryStatus) {
        this.deliveryStatus = deliveryStatus != null ? deliveryStatus.name() : null;
    }

    public String getFailureReason() {
        return failureReason;
    }

    public void setFailureReason(String failureReason) {
        this.failureReason = failureReason;
    }

    public String getProofImageUrl() {
        return proofImageUrl;
    }

    public void setProofImageUrl(String proofImageUrl) {
        this.proofImageUrl = proofImageUrl;
    }

    public Timestamp getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(Timestamp deliveredAt) {
        this.deliveredAt = deliveredAt;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getDriverPhone() {
        return driverPhone;
    }

    public void setDriverPhone(String driverPhone) {
        this.driverPhone = driverPhone;
    }

    public SubOrder() {
    }

    public String getSubOrderCode() {
        return subOrderCode != null ? subOrderCode : ("SUB-" + subOrderId);
    }

    public void setSubOrderCode(String subOrderCode) {
        this.subOrderCode = subOrderCode;
    }

    public String getOrderCode() {
        return orderCode != null ? orderCode : ("ORD-" + orderId);
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
        if (paymentMethod == null) return PaymentMethod.COD;
        try {
            return PaymentMethod.valueOf(paymentMethod.trim().toUpperCase());
        } catch (Exception e) {
            return PaymentMethod.COD;
        }
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
        if (paymentStatus == null) return PaymentStatus.PENDING;
        try {
            return PaymentStatus.valueOf(paymentStatus.trim().toUpperCase());
        } catch (Exception e) {
            return PaymentStatus.PENDING;
        }
    }

    public void setPaymentStatus(PaymentStatus paymentStatus) {
        this.paymentStatus = paymentStatus != null ? paymentStatus.name() : PaymentStatus.PENDING.name();
    }

    public String getTrackingNumber() {
        return trackingNumber != null ? trackingNumber : ("FFX-" + (subOrderCode != null ? subOrderCode.replace("SUB-", "") : subOrderId) + "-VN");
    }

    public void setTrackingNumber(String trackingNumber) {
        this.trackingNumber = trackingNumber;
    }

    public String getCarrierName() {
        return carrierName;
    }

    public void setCarrierName(String carrierName) {
        this.carrierName = carrierName;
    }

    public ShippingAddress getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(ShippingAddress shippingAddress) {
        this.shippingAddress = shippingAddress;
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

    private String shopLogoUrl;

    public String getId() {
        return (subOrderCode != null && !subOrderCode.isEmpty()) ? subOrderCode : ("SUB-" + subOrderId);
    }

    public String getShopLogoUrl() {
        return shopLogoUrl;
    }

    public void setShopLogoUrl(String shopLogoUrl) {
        this.shopLogoUrl = shopLogoUrl;
    }

    public String getTotalAmount() {
        return String.format("%,d", shopTotal != null ? shopTotal.longValue() : 0).replace(',', '.');
    }

    public BigDecimal getTotalGoodsAmount() {
        return shopSubtotal != null ? shopSubtotal : BigDecimal.ZERO;
    }

    public BigDecimal getTotalShippingFee() {
        return shopShippingFee != null ? shopShippingFee : BigDecimal.ZERO;
    }

    public BigDecimal getPlatformDiscount() {
        return shopDiscount != null ? shopDiscount : BigDecimal.ZERO;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public String getCreatedAtFormatted() {
        if (createdAt == null) {
            return "";
        }
        return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }

    public Timestamp getCreatedAtTimestamp() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean hasItems() {
        return items != null && !items.isEmpty();
    }

    public String getNote() {
        return deliverySlot != null && !deliverySlot.trim().isEmpty() ? ("Khung giờ giao: " + deliverySlot) : "Đơn hàng nông sản chuỗi lạnh FreshFruit";
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
}
