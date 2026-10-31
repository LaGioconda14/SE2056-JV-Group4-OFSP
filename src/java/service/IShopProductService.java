package service;

import java.math.BigDecimal;
import java.util.List;
import model.Category;
import model.Product;
import model.ProductVariant;
import model.Review;
import model.Shop;

public interface IShopProductService {

    List<ProductVariant> getVariantsByShopId(long shopId) throws Exception;

    List<ProductVariant> getVariantsByShop(long shopId, String keyword, String categoryId, String stockLevel) throws Exception;

    List<ProductVariant> getFilteredVariants(long shopId, String keyword, String categoryId, 
                                            String certification, String stockLevel, 
                                            String statusTab, int page, int pageSize) throws Exception;

    int countFilteredVariants(long shopId, String keyword, String categoryId, 
                              String certification, String stockLevel, String statusTab) throws Exception;

    List<Category> getAllCategories() throws Exception;

    void addShopProduct(long shopId, String name, int categoryId, String origin, 
                        String storageTemp, String certification, String description,
                        String sku, String variantName, String unit, BigDecimal price, 
                        BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                        String batchCode, String harvestDate, String expiryDate, BigDecimal importCost) throws Exception;

    long addFullProduct(long shopId, String name, int categoryId, String origin,
                        String storageTemp, String certification, String description,
                        String sku, String variantName, String unit, BigDecimal price,
                        BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                        boolean isActive, String coverImageUrl, List<String> detailImageUrls,
                        String shippingStandard) throws Exception;

    ProductVariant getVariantDetailForEdit(long variantId, long shopId) throws Exception;

    boolean updateFullProduct(long shopId, long productId, long variantId, String name, int categoryId,
                             String origin, String storageTemp, String certification, String description,
                             String sku, String variantName, String unit, BigDecimal price,
                             BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                             boolean isActive, String coverImageUrl, List<String> detailImageUrls) throws Exception;

    void toggleVariantStatus(long variantId, long shopId) throws Exception;

    void deleteVariant(long variantId, long shopId) throws Exception;
    
    long getShopIDByOwnerID(long id);
    
    int getTotalSkusByShopId(long shopId);

    int getTotalProductsCountByShopId(long shopId);

    int getActiveSkusCountByShopId(long shopId);

    int getOcopOrVietgapCountByShopId(long shopId);

    int getTabCountByShopId(long shopId, String tab);
    
    BigDecimal getTotalInventoryValueByShopId(long shopId);
    
    int getLowStockCountByShopId(long shopId);

    Shop getShopById(long shopId);

    Shop getShopByOwnerId(long ownerId);

    Shop getShopBySlug(String slug);

    List<Shop> searchShops(String keyword);

    List<Product> getProductsByShopId(long shopId, Integer categoryId, String sort);

    List<Category> getCategoriesWithCountByShopId(long shopId);

    List<Review> getReviewsByShopId(long shopId);
}
