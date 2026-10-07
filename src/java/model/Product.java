package model;

import java.math.BigDecimal;

public class Product {

    private long id;
    private long shopId;
    private String shopName;
    private String shopStatus;
    private int categoryId;
    private String name;
    private String categoryName;
    private String image;
    private String thumbnailUrl;
    private String origin;
    private String description;
    private boolean active;
    private BigDecimal price;
    private BigDecimal oldPrice;
    private BigDecimal minPrice;
    private int discountPercent;
    private double rating;
    private int reviewsCount;

    public Product() {
    }

    public Product(long id, String name, String categoryName, String image, BigDecimal price,
            BigDecimal oldPrice, int discountPercent, double rating, int reviewsCount) {
        this.id = id;
        this.name = name;
        this.categoryName = categoryName;
        this.image = image;
        this.thumbnailUrl = image;
        this.price = price;
        this.oldPrice = oldPrice;
        this.discountPercent = discountPercent;
        this.rating = rating;
        this.reviewsCount = reviewsCount;
        this.active = true;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getProductId() {
        return id;
    }

    public void setProductId(long productId) {
        this.id = productId;
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

    public String getShopStatus() {
        return shopStatus;
    }

    public void setShopStatus(String shopStatus) {
        this.shopStatus = shopStatus;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getImage() {
        return image != null ? image : thumbnailUrl;
    }

    public void setImage(String image) {
        this.image = image;
        if (this.thumbnailUrl == null) {
            this.thumbnailUrl = image;
        }
    }

    public String getThumbnailUrl() {
        return thumbnailUrl != null ? thumbnailUrl : image;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
        if (this.image == null) {
            this.image = thumbnailUrl;
        }
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public BigDecimal getOldPrice() {
        return oldPrice;
    }

    public void setOldPrice(BigDecimal oldPrice) {
        this.oldPrice = oldPrice;
    }

    public BigDecimal getMinPrice() {
        return minPrice;
    }

    public void setMinPrice(BigDecimal minPrice) {
        this.minPrice = minPrice;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(int discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewsCount() {
        return reviewsCount;
    }

    public void setReviewsCount(int reviewsCount) {
        this.reviewsCount = reviewsCount;
    }
}
