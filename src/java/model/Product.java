package model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Product {
    private long id;
    private String name;
    private String categoryName;
    private int categoryId;
    private String image;
    private BigDecimal price;
    private BigDecimal oldPrice;
    private int discountPercent;
    private double rating;
    private int reviewsCount;
    
    // Thuộc tính mở rộng chuẩn mẫu giao diện Shop Catalog & Detail
    private String origin;          // Xuất xứ: Yakima Valley Orchards, Washington State,...
    private String tag;             // Tag badge: LOCAL, ORGANIC, CRUNCHY, -17% SALE, SUPER SWEET
    private String unit;            // lb, kg, bunch, bag, box, clamshell
    private boolean inStock;        // Tồn kho còn hàng
    private int stockQuantity;
    private String description;
    private String storageTemp;
    private String certification;
    
    // Thuộc tính phục vụ trang Product Detail
    private List<String> images;             // Thư viện ảnh chi tiết
    private List<ProductVariant> variants;   // Các phiên bản kích cỡ/gói (1lb, 3lb bag, 5lb family box)

    public Product() {
        this.unit = "lb";
        this.inStock = true;
        this.images = new ArrayList<>();
        this.variants = new ArrayList<>();
    }

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
        this.unit = "lb";
        this.inStock = true;
        this.images = new ArrayList<>();
        this.variants = new ArrayList<>();
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

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

    public String getOrigin() { return origin; }
    public void setOrigin(String origin) { this.origin = origin; }

    public String getTag() { return tag; }
    public void setTag(String tag) { this.tag = tag; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public boolean isInStock() { return inStock; }
    public void setInStock(boolean inStock) { this.inStock = inStock; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStorageTemp() { return storageTemp; }
    public void setStorageTemp(String storageTemp) { this.storageTemp = storageTemp; }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    public List<String> getImages() { return images; }
    public void setImages(List<String> images) { this.images = images; }

    public List<ProductVariant> getVariants() { return variants; }
    public void setVariants(List<ProductVariant> variants) { this.variants = variants; }
}
