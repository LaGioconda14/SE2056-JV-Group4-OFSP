package service;

import java.math.BigDecimal;
import java.util.List;
import model.Category;
import model.Product;
import model.ProductVariant; 
import model.Review;
import model.Shop;

public interface IShopProductService {

    /**
     * Lấy danh sách sản phẩm & biến thể theo shopId đơn giản.
     */
    List<ProductVariant> getVariantsByShopId(long shopId) throws Exception;

    /**
     * Lấy danh sách sản phẩm & biến thể kèm bộ lọc tìm kiếm và tồn kho.
     */
    List<ProductVariant> getVariantsByShop(long shopId, String keyword, String categoryId, String stockLevel) throws Exception;

    /**
     * Lọc nâng cao theo đầy đủ tiêu chí và phân trang.
     */
    List<ProductVariant> getFilteredVariants(long shopId, String keyword, String categoryId, 
                                            String certification, String stockLevel, 
                                            String statusTab, int page, int pageSize) throws Exception;

    int countFilteredVariants(long shopId, String keyword, String categoryId, 
                              String certification, String stockLevel, String statusTab) throws Exception;

    List<Category> getAllCategories() throws Exception;

    /**
     * Thêm mới sản phẩm, biến thể và lô hàng.
     */
    void addShopProduct(long shopId, String name, int categoryId, String origin, 
                        String storageTemp, String certification, String description,
                        String sku, String variantName, String unit, BigDecimal price, 
                        BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                        String batchCode, String harvestDate, String expiryDate, BigDecimal importCost) throws Exception;

    /**
     * Thêm mới toàn diện sản phẩm từ màn hình Thêm mới nông sản.
     */
    long addFullProduct(long shopId, String name, int categoryId, String origin,
                        String storageTemp, String certification, String description,
                        String sku, String variantName, String unit, BigDecimal price,
                        BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                        boolean isActive, String coverImageUrl, List<String> detailImageUrls,
                        String shippingStandard) throws Exception;

    /**
     * Lấy thông tin chi tiết của sản phẩm/biến thể phục vụ màn hình Chỉnh sửa.
     */
    ProductVariant getVariantDetailForEdit(long variantId, long shopId) throws Exception;

    /**
     * Cập nhật thông tin toàn diện của sản phẩm nông sản.
     */
    boolean updateFullProduct(long shopId, long productId, long variantId, String name, int categoryId,
                             String origin, String storageTemp, String certification, String description,
                             String sku, String variantName, String unit, BigDecimal price,
                             BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                             boolean isActive, String coverImageUrl, List<String> detailImageUrls) throws Exception;

    /**
     * Bật/tắt trạng thái kinh doanh của biến thể.
     */
    void toggleVariantStatus(long variantId, long shopId) throws Exception;

    /**
     * Xóa biến thể của shop.
     */
    void deleteVariant(long variantId, long shopId) throws Exception;
    
    long getShopIDByOwnerID(long id);
    
    // Lấy tổng số lượng SKU của shop
    int getTotalSkusByShopId(long shopId);

    // Lấy tổng số lượng mặt hàng (sản phẩm cha)
    int getTotalProductsCountByShopId(long shopId);

    // Lấy số SKU đang mở bán
    int getActiveSkusCountByShopId(long shopId);

    // Lấy số sản phẩm OCOP / VietGAP
    int getOcopOrVietgapCountByShopId(long shopId);

    // Lấy số lượng theo tab trạng thái
    int getTabCountByShopId(long shopId, String tab);
    
    // Lấy tổng giá trị tồn kho của shop
    java.math.BigDecimal getTotalInventoryValueByShopId(long shopId);
    
    // Lấy số lượng sản phẩm sắp hết hàng (<= 10)
    int getLowStockCountByShopId(long shopId);

    Shop getShopById(long shopId);

    Shop getShopByOwnerId(long ownerId);

    Shop getShopBySlug(String slug);

    List<Shop> searchShops(String keyword);

    List<Product> getProductsByShopId(long shopId, Integer categoryId, String sort);

    List<Category> getCategoriesWithCountByShopId(long shopId);

    List<Review> getReviewsByShopId(long shopId);
}