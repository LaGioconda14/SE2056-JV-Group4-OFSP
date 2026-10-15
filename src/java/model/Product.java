package model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Product {
    private long id;
    private long shopId;
    private int categoryId;
    private String name;
    private String categoryName;
    private String image;
    private String thumbnailUrl;
    private BigDecimal price;
    private BigDecimal oldPrice;
    private BigDecimal minPrice;
    private int discountPercent;
    private double rating;
    private int reviewsCount;
    
    // Thuộc tính mở rộng chuẩn mẫu giao diện Shop Catalog & Detail
    private String origin;          // Xuất xứ: Yakima Valley Orchards, Washington State,...
    private String tag;             // Tag badge: LOCAL, ORGANIC, CRUNCHY, -17% SALE, SUPER SWEET
    private String unit;            // lb, kg, bunch, bag, box, clamshell
    private boolean inStock;        // Tồn kho còn hàng
    private boolean active;
    private int stockQuantity;
    private String description;
    private String storageTemp;
    private String certification;
    private String categorySlug;
    private String filterSlugs;
    
    // Thuộc tính phục vụ trang Product Detail
    private List<String> images;             // Thư viện ảnh chi tiết
    private List<ProductVariant> variants;   // Các phiên bản kích cỡ/gói (1lb, 3lb bag, 5lb family box)

    public Product() {
        this.unit = "lb";
        this.inStock = true;
        this.active = true;
        this.images = new ArrayList<>();
        this.variants = new ArrayList<>();
    }

    public Product(long id, String name, String categoryName, String image, BigDecimal price, BigDecimal oldPrice, int discountPercent, double rating, int reviewsCount) {
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
        this.unit = "lb";
        this.inStock = true;
        this.active = true;
        this.images = new ArrayList<>();
        this.variants = new ArrayList<>();
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public long getProductId() { return id; }
    public void setProductId(long productId) { this.id = productId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getImage() { return image != null ? image : thumbnailUrl; }
    public void setImage(String image) {
        this.image = image;
        if (this.thumbnailUrl == null) {
            this.thumbnailUrl = image;
        }
    }

    public String getThumbnailUrl() { return thumbnailUrl != null ? thumbnailUrl : image; }
    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
        if (this.image == null) {
            this.image = thumbnailUrl;
        }
    }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public BigDecimal getOldPrice() { return oldPrice; }
    public void setOldPrice(BigDecimal oldPrice) { this.oldPrice = oldPrice; }

    public BigDecimal getMinPrice() { return minPrice; }
    public void setMinPrice(BigDecimal minPrice) { this.minPrice = minPrice; }

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

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

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

    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }

    public String getCategorySlug() { return categorySlug; }
    public void setCategorySlug(String categorySlug) { this.categorySlug = categorySlug; }

    public void setFilterSlugs(String filterSlugs) { this.filterSlugs = filterSlugs; }
    public String getFilterSlugs() {
        if (filterSlugs != null && !filterSlugs.trim().isEmpty()) {
            return filterSlugs;
        }
        StringBuilder sb = new StringBuilder();
        if (categorySlug != null && !categorySlug.trim().isEmpty()) {
            sb.append(categorySlug).append(" ");
        }
        // Phân loại Trái Cây Nhập Khẩu
        if (categoryId == 5 || (categorySlug != null && categorySlug.contains("nhap-khau"))
                || (origin != null && (origin.contains("Mỹ") || origin.contains("Úc") || origin.contains("New Zealand") || origin.contains("Nhật Bản") || origin.contains("Hàn Quốc")))) {
            sb.append("trai-cay-nhap-khau ");
        }
        // Phân loại Trái Cây Việt Nam
        if (categoryId == 6 || (categorySlug != null && categorySlug.contains("viet-nam"))
                || (origin != null && (origin.contains("Việt Nam") || origin.contains("Đà Lạt") || origin.contains("Tiền Giang") || origin.contains("Bến Tre") || origin.contains("Lào Cai") || origin.contains("Sapa") || origin.contains("Long An") || origin.contains("Đồng Tháp") || origin.contains("Đắk Lắk") || origin.contains("Sơn La")))) {
            sb.append("trai-cay-viet-nam ");
        }
        // Phân loại Trái Cây Mùa Hè
        if (categoryId == 9 || (categorySlug != null && categorySlug.contains("mua-he"))
                || (name != null && (name.contains("Dưa") || name.contains("Xoài") || name.contains("Mận") || name.contains("Sầu Riêng") || name.contains("Thanh Long")))) {
            sb.append("trai-cay-mua-he ");
        }
        // Phân loại Trái Cây Đóng Thùng
        if (categoryId == 8 || (categorySlug != null && (categorySlug.contains("thung") || categorySlug.contains("dong-thung")))
                || (unit != null && unit.toLowerCase().contains("thùng"))
                || (name != null && name.toLowerCase().contains("thùng"))) {
            sb.append("trai-cay-dong-thung ");
        }
        // Phân loại Trái Cây Có Sẵn (còn hàng tồn kho)
        if (inStock || stockQuantity > 0) {
            sb.append("trai-cay-co-san ");
        }
        return sb.toString().trim();
    }
}
