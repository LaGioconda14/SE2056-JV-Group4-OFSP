package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class Order {

    private long orderId;
    private String orderCode;
    private long customerId;
    private Integer couponId;
    private BigDecimal totalGoodsAmount = BigDecimal.ZERO;
    private BigDecimal totalShippingFee = BigDecimal.ZERO;
    private BigDecimal platformDiscount = BigDecimal.ZERO;
    private BigDecimal finalAmount = BigDecimal.ZERO;
    private String paymentStatus = "PENDING";
    private String paymentMethod;
    private String orderStatus;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String note;
    private String shopName;
    private String shopLogoUrl;

    private ShippingAddress shippingAddress;
    private List<SubOrder> subOrders = new ArrayList<>();
    private List<OrderItem> items = new ArrayList<>();

    public Order() {
    }

    public Order(long orderId, String orderCode, long customerId, Integer couponId,
                 double totalGoodsAmount, double totalShippingFee, double platformDiscount,
                 double finalAmount, String paymentStatus, String paymentMethod,
                 String orderStatus, Timestamp createdAt, Timestamp updatedAt, String note) {
        this.orderId = orderId;
        this.orderCode = orderCode;
        this.customerId = customerId;
        this.couponId = couponId;
        this.totalGoodsAmount = BigDecimal.valueOf(totalGoodsAmount);
        this.totalShippingFee = BigDecimal.valueOf(totalShippingFee);
        this.platformDiscount = BigDecimal.valueOf(platformDiscount);
        this.finalAmount = BigDecimal.valueOf(finalAmount);
        this.paymentStatus = paymentStatus;
        this.paymentMethod = paymentMethod;
        this.orderStatus = orderStatus;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.note = note;
    }

    public String getId() {
        return (orderCode != null && !orderCode.isEmpty()) ? orderCode : String.valueOf(orderId);
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
        this.totalGoodsAmount = totalGoodsAmount;
    }

    public void setTotalGoodsAmount(double totalGoodsAmount) {
        this.totalGoodsAmount = BigDecimal.valueOf(totalGoodsAmount);
    }

    public BigDecimal getTotalShippingFee() {
        return totalShippingFee;
    }

    public void setTotalShippingFee(BigDecimal totalShippingFee) {
        this.totalShippingFee = totalShippingFee;
    }

    public void setTotalShippingFee(double totalShippingFee) {
        this.totalShippingFee = BigDecimal.valueOf(totalShippingFee);
    }

    public BigDecimal getPlatformDiscount() {
        return platformDiscount;
    }

    public void setPlatformDiscount(BigDecimal platformDiscount) {
        this.platformDiscount = platformDiscount;
    }

    public void setPlatformDiscount(double platformDiscount) {
        this.platformDiscount = BigDecimal.valueOf(platformDiscount);
    }

    public BigDecimal getFinalAmount() {
        return finalAmount;
    }

    public void setFinalAmount(BigDecimal finalAmount) {
        this.finalAmount = finalAmount;
    }

    public void setFinalAmount(double finalAmount) {
        this.finalAmount = BigDecimal.valueOf(finalAmount);
    }

    public String getTotalAmount() {
        long a = finalAmount != null ? finalAmount.longValue() : 0L;
        return String.format("%,d", a).replace(',', '.');
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getStatus() {
        return orderStatus != null ? orderStatus : "PENDING";
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) {
            return "";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
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

    public String getNote() {
        if (note != null && !note.trim().isEmpty()) {
            return note;
        }
        return "Đơn hàng trái cây tươi FreshFruit";
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getShopName() {
        if (shopName != null && !shopName.trim().isEmpty()) {
            return shopName;
        }
        return "Nông Trại FreshFruit";
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

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }

    public boolean hasItems() {
        return items != null && !items.isEmpty();
    }
}
