package service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.Category;
import model.Product;
import model.ProductVariant;

public interface IProductService {
    //lấy danh sách sản phẩm theo shopID
    List<Product> getProductSummariesByShopId(long shopId);
    int countProductsByShopId(long shopId);
    int countVariantsByShopId(long shopId);
    int countVariantsByStatusTab(long shopId, String tab);
    int countProductsByStatusTab(long shopId, String statusTab);
    //lấy danh mục
    List<Category> getAllCategories();
    //Lấy chứng nhận
    List<String> getAllCertifications();
    // Bổ sung lấy danh sách nhiệt độ bảo quản
    List<String> getAllStorageTemps();
    // unit
    List<String> getAllUnits();
    //insert sản phẩm
    // Hàm thêm sản phẩm mới (có xử lý validation nghiệp vụ tại tầng Service)
    long insertFullProduct(long shopId, String name, int categoryId, String origin, 
                           String storageTemp, String certification, String description,
                           String sku, String variantName, String unit, BigDecimal price, 
                           BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                           boolean isActive, String coverImageUrl, List<String> detailImages, String batchCode) throws IllegalArgumentException;
    long addVariantToProduct(long shopId, long productId, String sku, String variantName, String unit,
                             String price, String originalPrice, String stockQuantity,
                             String lowStockThreshold, boolean isActive) throws IllegalArgumentException;
    
    boolean softDeleteVariant(long variantId, long shopId);
    
    boolean softDeleteProductAndVariants(long productId, long shopId);
    boolean softDeleteProduct(long productId, long shopId);
    // Lấy thông tin biến thể sản phẩm theo ID để sửa
    ProductVariant getVariantById(long variantId);
    ProductVariant getShopVariantById(long variantId, long shopId);
    boolean updateVariantDetails(long shopId, long variantId, String sku, String variantName, String unit,
                                 String price, String originalPrice, String stockQuantity,
                                 String lowStockThreshold, boolean isActive) throws IllegalArgumentException;
    //sửa
    public boolean updateFullProduct(long shopId,long variantId, String name, int categoryId, String origin, 
                                     String storageTemp, String certification, String description, 
                                     String sku, String variantName, String unit, BigDecimal price, 
                                     BigDecimal originalPrice, int stockQuantity, boolean isActive, 
                                     String coverImageUrl);
    
    /**
     * Lấy danh sách sản phẩm nổi bật hiển thị trên trang chủ.
     */
    List<Product> getHomeProducts();
    /**
     * Lấy danh sách các tab danh mục hiển thị trên trang chủ.
     */
    List<Product> getHomeFeaturedTabs();

    /**
     * Lấy danh sách danh mục theo cấu trúc phân cấp đa tầng (cha - con).
     */
    List<Category> getHierarchyCategories();
    
    // Thêm các phương thức cho tính năng Browse by Category
    List<Product> getProductsByCategorySlug(String categorySlug);
    
    // Các phương thức cho View Product Details
    Product getProductById(int productId);
    List<ProductVariant> getVariantsByProductId(long productId);
    List<ProductVariant> getShopVariantsByProductId(long shopId, long productId);
    List<ProductVariant> getVariantsByShopId(long shopId);
    List<String> getImagesByProductId(long productId);
    
    List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr);
    List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin);
    List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin, String sortBy);

    // Thanh tìm kiếm cho shop
    List<Product> getShopFilteredProducts(long shopId, String keyword, Long categoryId, String certification, String stockLevel);

    // Advanced Catalog methods
    List<Category> getAllCategoriesWithCount();
    Map<String, Integer> getOriginsWithCount();
    int countInStockProducts();
    BigDecimal[] getMinMaxProductPrices();
    List<Product> getFilteredCatalogProducts(String keyword, List<String> categoryParams,
                                            BigDecimal minPrice, BigDecimal maxPrice,
                                            Double minRating, List<String> origins,
                                            Boolean inStockOnly, String sortBy,
                                            int page, int pageSize);
    int countFilteredCatalogProducts(String keyword, List<String> categoryParams,
                                    BigDecimal minPrice, BigDecimal maxPrice,
                                    Double minRating, List<String> origins,
                                    Boolean inStockOnly);
}
