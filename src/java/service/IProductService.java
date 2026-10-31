package service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.Category;
import model.Product;
import model.ProductVariant;

public interface IProductService {

    List<Product> getProductSummariesByShopId(long shopId);

    int countProductsByShopId(long shopId);

    int countVariantsByShopId(long shopId);

    int countVariantsByStatusTab(long shopId, String tab);

    int countProductsByStatusTab(long shopId, String statusTab);

    List<Category> getAllCategories();

    List<String> getAllCertifications();

    List<String> getAllStorageTemps();

    List<String> getAllUnits();

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

    ProductVariant getVariantById(long variantId);

    ProductVariant getShopVariantById(long variantId, long shopId);

    boolean updateVariantDetails(long shopId, long variantId, String sku, String variantName, String unit,
                                 String price, String originalPrice, String stockQuantity,
                                 String lowStockThreshold, boolean isActive) throws IllegalArgumentException;

    boolean updateFullProduct(long shopId, long variantId, String name, int categoryId, String origin, 
                             String storageTemp, String certification, String description, 
                             String sku, String variantName, String unit, BigDecimal price, 
                             BigDecimal originalPrice, int stockQuantity, boolean isActive, 
                             String coverImageUrl);
    
    List<Product> getHomeProducts();

    List<Product> getHomeFeaturedTabs();

    List<Category> getHierarchyCategories();
    
    List<Product> getProductsByCategorySlug(String categorySlug);
    
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

    List<Product> getShopFilteredProducts(long shopId, String keyword, Long categoryId, String certification, String stockLevel);

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
