package service;

import java.math.BigDecimal;
import java.util.List;
import model.ProductVariant; 

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
     * Thêm mới sản phẩm, biến thể và lô hàng.
     */
    void addShopProduct(long shopId, String name, int categoryId, String origin, 
                        String storageTemp, String certification, String description,
                        String sku, String variantName, String unit, BigDecimal price, 
                        BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                        String batchCode, String harvestDate, String expiryDate, BigDecimal importCost) throws Exception;

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
    
    // Lấy tổng giá trị tồn kho của shop
    java.math.BigDecimal getTotalInventoryValueByShopId(long shopId);
    
    // Lấy số lượng sản phẩm sắp hết hàng (<= 10)
    int getLowStockCountByShopId(long shopId);
}