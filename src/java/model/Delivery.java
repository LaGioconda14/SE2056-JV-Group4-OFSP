package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import enums.DeliveryStatus;
import enums.PaymentStatus;
import enums.PaymentMethod;

public class Delivery {

    private long deliveryId;
    private long subOrderId;
    private String subOrderCode;
    private Long driverId;
    private String driverName;
    private String driverPhone;
    private String trackingNumber;
    private String deliveryStatus = DeliveryStatus.ASSIGNING.name(); // ASSIGNING, DELIVERING, DELIVERED, FAILED
    private String proofImageUrl;
    private String failureReason;
    private Timestamp assignedAt;
    private Timestamp deliveredAt;

    // Shop Info (Pickup point)
    private long shopId;
    private String shopName;
    private String shopPhone;
    private String shopAddress;
    private String shopProvince;

    // Recipient Info (Delivery destination)
    private String recipientName;
    private String recipientPhone;
    private String streetAddress;
    private String ward;
    private String district;
    private String city;
    private String deliverySlot;
    private String deliveryNote;

    // Financial Info
    private BigDecimal shopTotal = BigDecimal.ZERO;
    private String paymentMethod = PaymentMethod.COD.name();
    private String paymentStatus = PaymentStatus.PENDING.name();

    // Products in package
    private List<OrderItem> items = new ArrayList<>();

    public Delivery() {
    }

    public long getDeliveryId() {
        return deliveryId;
    }

    public void setDeliveryId(long deliveryId) {
        this.deliveryId = deliveryId;
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

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
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

    public String getTrackingNumber() {
        return trackingNumber;
    }

    public void setTrackingNumber(String trackingNumber) {
        this.trackingNumber = trackingNumber;
    }

    public String getDeliveryStatus() {
        return deliveryStatus;
    }

    public void setDeliveryStatus(String deliveryStatus) {
        this.deliveryStatus = deliveryStatus;
    }

    public DeliveryStatus getDeliveryStatusEnum() {
        DeliveryStatus status = DeliveryStatus.from(deliveryStatus);
        return status != null ? status : DeliveryStatus.ASSIGNING;
    }

    public void setDeliveryStatus(DeliveryStatus deliveryStatus) {
        this.deliveryStatus = deliveryStatus != null ? deliveryStatus.name() : DeliveryStatus.ASSIGNING.name();
    }

    public String getProofImageUrl() {
        return proofImageUrl;
    }

    public void setProofImageUrl(String proofImageUrl) {
        this.proofImageUrl = proofImageUrl;
    }

    public String getFailureReason() {
        return failureReason;
    }

    public void setFailureReason(String failureReason) {
        this.failureReason = failureReason;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }

    public Timestamp getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(Timestamp deliveredAt) {
        this.deliveredAt = deliveredAt;
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

    public String getShopPhone() {
        return shopPhone;
    }

    public void setShopPhone(String shopPhone) {
        this.shopPhone = shopPhone;
    }

    public String getShopAddress() {
        return shopAddress;
    }

    public void setShopAddress(String shopAddress) {
        this.shopAddress = shopAddress;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getRecipientPhone() {
        return recipientPhone;
    }

    public void setRecipientPhone(String recipientPhone) {
        this.recipientPhone = recipientPhone;
    }

    public String getStreetAddress() {
        return streetAddress;
    }

    public void setStreetAddress(String streetAddress) {
        this.streetAddress = streetAddress;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDeliverySlot() {
        return deliverySlot;
    }

    public void setDeliverySlot(String deliverySlot) {
        this.deliverySlot = deliverySlot;
    }

    public String getDeliveryNote() {
        return deliveryNote;
    }

    public void setDeliveryNote(String deliveryNote) {
        this.deliveryNote = deliveryNote;
    }

    public BigDecimal getShopTotal() {
        return shopTotal;
    }

    public void setShopTotal(BigDecimal shopTotal) {
        this.shopTotal = shopTotal;
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

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }

    // Helper methods
    public String getFormattedTotal() {
        if (shopTotal == null) return "0₫";
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(shopTotal) + "₫";
    }

    public boolean isCOD() {
        return "COD".equalsIgnoreCase(paymentMethod);
    }

    public String getFullDeliveryAddress() {
        StringBuilder sb = new StringBuilder();
        if (streetAddress != null && !streetAddress.trim().isEmpty()) sb.append(streetAddress.trim());
        if (ward != null && !ward.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(ward.trim());
        }
        if (district != null && !district.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(district.trim());
        }
        if (city != null && !city.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(city.trim());
        }
        return sb.length() > 0 ? sb.toString() : "Địa chỉ giao hàng";
    }

    public String getStorageTemp() {
        if (items != null && !items.isEmpty()) {
            for (OrderItem it : items) {
                if (it.getStorageTemp() != null && !it.getStorageTemp().trim().isEmpty()) {
                    return it.getStorageTemp();
                }
            }
        }
        return "2-5°C (Thùng chuỗi lạnh)";
    }

    public String getShopProvince() {
        return shopProvince;
    }

    public void setShopProvince(String shopProvince) {
        this.shopProvince = shopProvince;
    }

    public String getPickupPointTitle() {
        return (shopName != null && !shopName.isEmpty()) ? shopName : "Cửa hàng Nông sản";
    }

    public String getPickupPointSub() {
        return (shopAddress != null && !shopAddress.isEmpty()) ? shopAddress : "Địa chỉ cửa hàng";
    }
}

