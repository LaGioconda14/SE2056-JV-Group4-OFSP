package model.dto.product;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Transfer Object phục vụ trang Chi tiết sản phẩm (Product Detail) và Chỉnh sửa sản phẩm (Shop Edit Product).
 */
public class ProductDetailDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    // Product core info
    private long id;
    private long shopId;
    private int categoryId;
    private String name;
    private String slug;
    private String origin;
    private String storageTemp;
    private String certification;
    private String description;
    private boolean active = true;

    // Joined Category & Shop info
    private String categoryName;
    private String categorySlug;
    private String shopName;
    private String shopStatus;

    // Media & Variants
    private String thumbnailUrl;
    private List<String> images = new ArrayList<>();
    private List<ProductVariantDetailDTO> variants = new ArrayList<>();

    // Display & Pricing summary
    private BigDecimal price;
    private BigDecimal oldPrice;
    private int discountPercent;
    private double rating = 5.0;
    private int reviewsCount = 0;
    private long defaultVariantId;
    private boolean inStock = true;
    private int stockQuantity;
    private String unit = "kg";
    private String tag;

    // Promotion details
    private long promotionId;
    private String promotionName;
    private String promotionLabel;
    private String promotionCondition;
    private String promotionType;
    private String promotionSchedule;
    private Timestamp promotionEndDate;

    public ProductDetailDTO() {
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public long getProductId() { return id; }
    public void setProductId(long productId) { this.id = productId; }

    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getProductName() { return name; }
    public void setProductName(String productName) { this.name = productName; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }

    public String getStorageTemp() { return storageTemp; }
    public void setStorageTemp(String storageTemp) { this.storageTemp = storageTemp; }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCategorySlug() { return categorySlug; }
    public void setCategorySlug(String categorySlug) { this.categorySlug = categorySlug; }

    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }

    public String getShopStatus() { return shopStatus; }
    public void setShopStatus(String shopStatus) { this.shopStatus = shopStatus; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getImage() { return thumbnailUrl; }
    public void setImage(String image) { this.thumbnailUrl = image; }

    public List<String> getImages() { return images; }
    public void setImages(List<String> images) { this.images = images != null ? images : new ArrayList<>(); }

    public List<ProductVariantDetailDTO> getVariants() { return variants; }
    public void setVariants(List<ProductVariantDetailDTO> variants) {
        this.variants = variants != null ? variants : new ArrayList<>();
    }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public BigDecimal getOldPrice() { return oldPrice; }
    public void setOldPrice(BigDecimal oldPrice) { this.oldPrice = oldPrice; }

    public int getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(int discountPercent) { this.discountPercent = discountPercent; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public int getReviewsCount() { return reviewsCount; }
    public void setReviewsCount(int reviewsCount) { this.reviewsCount = reviewsCount; }

    public long getDefaultVariantId() { return defaultVariantId; }
    public void setDefaultVariantId(long defaultVariantId) { this.defaultVariantId = defaultVariantId; }

    public boolean isInStock() { return inStock; }
    public void setInStock(boolean inStock) { this.inStock = inStock; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getUnit() {
        return (unit == null || unit.trim().isEmpty()) ? "kg" : unit.trim();
    }
    public void setUnit(String unit) { this.unit = unit; }

    public String getTag() {
        if (promotionLabel != null && !promotionLabel.trim().isEmpty()) {
            return promotionLabel;
        }
        if (tag != null && !tag.trim().isEmpty()) {
            return tag;
        }
        if (discountPercent > 0) {
            return "-" + discountPercent + "%";
        }
        if (certification != null && !certification.trim().isEmpty()) {
            return certification.toUpperCase();
        }
        if (origin != null && (origin.toLowerCase().contains("đà lạt") || origin.toLowerCase().contains("nội địa"))) {
            return "ĐẶC SẢN";
        }
        return "TƯƠI SẠCH";
    }
    public void setTag(String tag) { this.tag = tag; }

    public String getSecondaryTag() {
        if (tag != null && !tag.trim().isEmpty() && !tag.contains("%") && discountPercent > 0) {
            return "-" + discountPercent + "%";
        }
        if (certification != null && certification.toLowerCase().contains("vietgap") && discountPercent > 0) {
            return "VIETGAP";
        }
        return null;
    }

    public long getPromotionId() { return promotionId; }
    public void setPromotionId(long promotionId) { this.promotionId = promotionId; }

    public String getPromotionName() { return promotionName; }
    public void setPromotionName(String promotionName) { this.promotionName = promotionName; }

    public String getPromotionLabel() { return promotionLabel; }
    public void setPromotionLabel(String promotionLabel) { this.promotionLabel = promotionLabel; }

    public String getPromotionCondition() { return promotionCondition; }
    public void setPromotionCondition(String promotionCondition) { this.promotionCondition = promotionCondition; }

    public String getPromotionType() { return promotionType; }
    public void setPromotionType(String promotionType) { this.promotionType = promotionType; }

    public String getPromotionSchedule() { return promotionSchedule; }
    public void setPromotionSchedule(String promotionSchedule) { this.promotionSchedule = promotionSchedule; }

    public Timestamp getPromotionEndDate() { return promotionEndDate; }
    public void setPromotionEndDate(Timestamp promotionEndDate) { this.promotionEndDate = promotionEndDate; }

    public boolean isOnPromotion() { return promotionId > 0; }
}
