package model;

import java.math.BigDecimal;

public class Product {
    private long id;
    private String name;
    private String categoryName;
    private String image;
    private BigDecimal price;
    private BigDecimal oldPrice;
    private int discountPercent;
    private double rating;
    private int reviewsCount;

    public Product() {}

    public Product(long id, String name, String categoryName, String image, BigDecimal price, BigDecimal oldPrice, int discountPercent, double rating, int reviewsCount) {
        this.id = id;
        this.name = name;
        this.categoryName = categoryName;
        this.image = image;
        this.price = price;
        this.oldPrice = oldPrice;
        this.discountPercent = discountPercent;
        this.rating = rating;
        this.reviewsCount = reviewsCount;
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

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
}
