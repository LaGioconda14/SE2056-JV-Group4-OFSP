package model.dto.product;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Data Transfer Object phục vụ thẻ sản phẩm trên Catalog, Trang chủ, Tìm kiếm,
 * Danh sách yêu thích (Wishlist), Gian hàng (Storefront) và bảng tổng hợp Shop.
 */
public class ProductCardDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private long productId;
    private long shopId;
    private int categoryId;
    private String productName;
    private String thumbnailUrl;
    private String categoryName;
    private String categorySlug;
    private String shopName;
    private String shopStatus;
    private String origin;
    private String certification;
    private String storageTemp;
    private String description;
    private boolean active = true;

    private BigDecimal price;
    private BigDecimal oldPrice;
    private int discountPercent;
    private BigDecimal minPrice;
    private double rating = 5.0;
    private int reviewsCount = 0;

    private long defaultVariantId;
    private int variantCount;
    private boolean inStock = true;
    private int stockQuantity;
    private String unit = "kg";
    private String tag;

    // Promotion summary fields attached dynamically by PromotionPricing
    private long promotionId;
    private String promotionName;
    private String promotionLabel;
    private String promotionType;

    public ProductCardDTO() {
    }

    public ProductCardDTO(long productId, String productName, String categoryName, String thumbnailUrl,
            BigDecimal price, BigDecimal oldPrice, int discountPercent, double rating, int reviewsCount) {
        this.productId = productId;
        this.productName = productName;
        this.categoryName = categoryName;
        this.thumbnailUrl = thumbnailUrl;
        this.price = price;
        this.oldPrice = oldPrice;
        this.discountPercent = discountPercent;
        this.rating = rating;
        this.reviewsCount = reviewsCount;
    }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    /** Alias cho getProductId() để tương thích JSP EL ${p.id}. */
    public long getId() { return productId; }
    public void setId(long id) { this.productId = id; }

    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    /** Alias cho getProductName() để tương thích JSP EL ${p.name}. */
    public String getName() { return productName; }
    public void setName(String name) { this.productName = name; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    /** Alias cho getThumbnailUrl() để tương thích JSP EL ${p.image}. */
    public String getImage() { return thumbnailUrl; }
    public void setImage(String image) { this.thumbnailUrl = image; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCategorySlug() { return categorySlug; }
    public void setCategorySlug(String categorySlug) { this.categorySlug = categorySlug; }

    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }

    public String getShopStatus() { return shopStatus; }
    public void setShopStatus(String shopStatus) { this.shopStatus = shopStatus; }

    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    public String getStorageTemp() { return storageTemp; }
    public void setStorageTemp(String storageTemp) { this.storageTemp = storageTemp; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public boolean isActiveForSale() { return active; }
    public void setActiveForSale(boolean activeForSale) { this.active = activeForSale; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public BigDecimal getOldPrice() { return oldPrice; }
    public void setOldPrice(BigDecimal oldPrice) { this.oldPrice = oldPrice; }

    public int getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(int discountPercent) { this.discountPercent = discountPercent; }

    public BigDecimal getMinPrice() { return minPrice != null ? minPrice : price; }
    public void setMinPrice(BigDecimal minPrice) { this.minPrice = minPrice; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public int getReviewsCount() { return reviewsCount; }
    public void setReviewsCount(int reviewsCount) { this.reviewsCount = reviewsCount; }

    public long getDefaultVariantId() { return defaultVariantId; }
    public void setDefaultVariantId(long defaultVariantId) { this.defaultVariantId = defaultVariantId; }

    public long getPrimaryVariantId() { return defaultVariantId; }
    public void setPrimaryVariantId(long primaryVariantId) { this.defaultVariantId = primaryVariantId; }

    public int getVariantCount() { return variantCount; }
    public void setVariantCount(int variantCount) { this.variantCount = variantCount; }

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

    public String getPromotionType() { return promotionType; }
    public void setPromotionType(String promotionType) { this.promotionType = promotionType; }

    public boolean isOnPromotion() { return promotionId > 0; }
}
