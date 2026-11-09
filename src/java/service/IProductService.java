package service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.dto.product.ProductCardDTO;
import model.dto.product.ProductDetailDTO;
import model.dto.product.ProductVariantDetailDTO;
import model.dto.product.ProductVariantStockDTO;
import model.entity.product.Category;
import model.entity.product.ProductVariant;
import model.entity.review.Review;

public interface IProductService {
    //lấy danh sách sản phẩm theo shopID
    List<ProductCardDTO> getProductSummariesByShopId(long shopId);
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
    ProductVariantDetailDTO getVariantById(long variantId);
    ProductVariantDetailDTO getShopVariantById(long variantId, long shopId);
    boolean updateVariantDetails(long shopId, long variantId, String sku, String variantName, String unit,
                                 String price, String originalPrice, String stockQuantity,
                                 String lowStockThreshold, boolean isActive) throws IllegalArgumentException;
    //sửa
    ProductDetailDTO getShopProductForEdit(long productId, long shopId);
    boolean updateFullProduct(long shopId, long productId, String name, int categoryId, String origin,
                              String storageTemp, String certification, String description,
                              boolean isActive, String coverImageUrl);
    
    /**
     * Lấy danh sách sản phẩm nổi bật hiển thị trên trang chủ.
     */
    List<ProductCardDTO> getHomeProducts();

    /**
     * Lấy danh sách danh mục theo cấu trúc phân cấp đa tầng (cha - con).
     */
    List<Category> getHierarchyCategories();
    
    // Thêm các phương thức cho tính năng Browse by Category
    List<ProductCardDTO> getProductsByCategorySlug(String categorySlug);
    
    // Các phương thức cho View Product Details
    ProductDetailDTO getProductById(int productId);
    List<ProductVariantDetailDTO> getVariantsByProductId(long productId);
    List<ProductVariant> getShopVariantsByProductId(long shopId, long productId);
    List<ProductVariantStockDTO> getVariantsByShopId(long shopId);
    List<String> getImagesByProductId(long productId);
    
    List<ProductCardDTO> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr);
    List<ProductCardDTO> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin);
    List<ProductCardDTO> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin, String sortBy);

    // Thanh tìm kiếm cho shop
    List<ProductCardDTO> getShopFilteredProducts(long shopId, String keyword, Long categoryId, String certification, String stockLevel);
    // Advanced Catalog methods
    List<Category> getAllCategoriesWithCount();
    Map<String, Integer> getOriginsWithCount();
    int countInStockProducts();
    BigDecimal[] getMinMaxProductPrices();
    List<ProductCardDTO> getFilteredCatalogProducts(String keyword, List<String> categoryParams,
                                            BigDecimal minPrice, BigDecimal maxPrice,
                                            Double minRating, List<String> origins,
                                            Boolean inStockOnly, String sortBy,
                                            int page, int pageSize);
    int countFilteredCatalogProducts(String keyword, List<String> categoryParams,
                                    BigDecimal minPrice, BigDecimal maxPrice,
                                    Double minRating, List<String> origins,
                                    Boolean inStockOnly);
    List<Review> getReviewsByProductId(long productId);
    double[] getProductRatingStats(long productId);
}
