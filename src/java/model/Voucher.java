package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class Voucher {

    private int couponId;
    private Long shopId;
    private String code;
    private String title;
    private String description;
    private String discountType;
    private BigDecimal discountValue;
    private BigDecimal minOrderValue = BigDecimal.ZERO;
    private BigDecimal maxDiscountAmount;
    private int usageLimit = 100;
    private int usedCount;
    private int perUserLimit = 1;
    private String appliesTo = "ALL";
    private String sponsorType = "VENDOR";
    private Timestamp startDate;
    private Timestamp endDate;
    private boolean active = true;
    private Timestamp terminatedAt;
    private Timestamp createdAt;
    private String status;
    private int productCount;
    private List<Long> productIds = new ArrayList<>();

    public int getCouponId() { return couponId; }
    public void setCouponId(int couponId) { this.couponId = couponId; }
    public Long getShopId() { return shopId; }
    public void setShopId(Long shopId) { this.shopId = shopId; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }
    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }
    public BigDecimal getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(BigDecimal minOrderValue) { this.minOrderValue = minOrderValue; }
    public BigDecimal getMaxDiscountAmount() { return maxDiscountAmount; }
    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }
    public int getUsageLimit() { return usageLimit; }
    public void setUsageLimit(int usageLimit) { this.usageLimit = usageLimit; }
    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }
    public int getPerUserLimit() { return perUserLimit; }
    public void setPerUserLimit(int perUserLimit) { this.perUserLimit = perUserLimit; }
    public String getAppliesTo() { return appliesTo; }
    public void setAppliesTo(String appliesTo) { this.appliesTo = appliesTo; }
    public String getSponsorType() { return sponsorType; }
    public void setSponsorType(String sponsorType) { this.sponsorType = sponsorType; }
    public Timestamp getStartDate() { return startDate; }
    public void setStartDate(Timestamp startDate) { this.startDate = startDate; }
    public Timestamp getEndDate() { return endDate; }
    public void setEndDate(Timestamp endDate) { this.endDate = endDate; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Timestamp getTerminatedAt() { return terminatedAt; }
    public void setTerminatedAt(Timestamp terminatedAt) { this.terminatedAt = terminatedAt; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getProductCount() { return productCount; }
    public void setProductCount(int productCount) { this.productCount = productCount; }
    public List<Long> getProductIds() { return productIds; }
    public void setProductIds(List<Long> productIds) { this.productIds = productIds; }

    private static String fmt(Timestamp t) {
        return t == null ? "" : new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(t);
    }

    /** Giá trị cho thẻ input type="datetime-local". */
    public String getStartDateInput() { return fmt(startDate); }
    public String getEndDateInput() { return fmt(endDate); }

    public int getRemaining() { return Math.max(0, usageLimit - usedCount); }
    public int getUsedPercent() { return usageLimit > 0 ? (int) Math.min(100, Math.round(usedCount * 100.0 / usageLimit)) : 0; }
    public boolean isPercentage() { return "PERCENTAGE".equals(discountType); }
    public boolean isEnded() { return "ENDED".equals(status) || "EXPIRED".equals(status) || "SOLD_OUT".equals(status); }

}
