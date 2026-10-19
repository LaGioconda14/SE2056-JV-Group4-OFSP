package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;


public class Promotion {

    private long promotionId;
    private long shopId;
    private String name;
    private String description;
    private String promotionType;
    private BigDecimal discountValue;
    private BigDecimal maxDiscountAmount;
    private Timestamp startDate;
    private Timestamp endDate;
    private boolean active = true;
    private Timestamp terminatedAt;
    private Timestamp createdAt;
    private String status;
    private int productCount;
    private List<Long> productIds = new ArrayList<>();
    private List<String> productNames = new ArrayList<>();

    public long getPromotionId() { return promotionId; }
    public void setPromotionId(long promotionId) { this.promotionId = promotionId; }
    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getPromotionType() { return promotionType; }
    public void setPromotionType(String promotionType) { this.promotionType = promotionType; }
    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }
    public BigDecimal getMaxDiscountAmount() { return maxDiscountAmount; }
    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) { this.maxDiscountAmount = maxDiscountAmount; }
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
    public List<String> getProductNames() { return productNames; }
    public void setProductNames(List<String> productNames) { this.productNames = productNames; }


    private static String fmt(Timestamp t) {
        return t == null ? "" : new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(t);
    }

    public String getStartDateInput() { return fmt(startDate); }
    public String getEndDateInput() { return fmt(endDate); }
    public boolean isPercentage() { return "PERCENTAGE".equals(promotionType); }
    public boolean isEnded() { return "ENDED".equals(status) || "EXPIRED".equals(status); }

    /** Tiền giảm trên MỘT đơn vị sản phẩm có đơn giá unitPrice. */
    public BigDecimal calcDiscount(BigDecimal unitPrice) {
        if (unitPrice == null || discountValue == null) {
            return BigDecimal.ZERO;
        }
        BigDecimal d;
        if (isPercentage()) {
            d = unitPrice.multiply(discountValue).divide(BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP);
            if (maxDiscountAmount != null && maxDiscountAmount.signum() > 0 && d.compareTo(maxDiscountAmount) > 0) {
                d = maxDiscountAmount;
            }
        } else {
            d = discountValue;
        }
        return d.min(unitPrice).max(BigDecimal.ZERO);
    }

    /** Giá sau khuyến mãi của một đơn vị sản phẩm. */
    public BigDecimal calcDiscountedPrice(BigDecimal unitPrice) {
        return unitPrice.subtract(calcDiscount(unitPrice));
    }

}
