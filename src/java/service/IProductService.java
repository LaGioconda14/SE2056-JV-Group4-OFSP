package service;

import java.math.BigDecimal;
import java.util.List;
import model.Category;
import model.ProductVariant;

public interface IProductService {
    //lấy list sản phẩm
    List<ProductVariant> getVariantsByShopId(long shopId);
    int countProductsByShopId(long shopId);
    int countVariantsByShopId(long shopId);
    int countVariantsByStatusTab(long shopId, String statusTab);
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
    
    boolean softDeleteVariant(long variantId, long shopId);
    // Lấy thông tin biến thể sản phẩm theo ID để sửa
    ProductVariant getVariantById(long variantId);
    //sửa
    public boolean updateFullProduct(long variantId, String name, int categoryId, String origin, 
                                     String storageTemp, String certification, String description, 
                                     String sku, String variantName, String unit, BigDecimal price, 
                                     BigDecimal originalPrice, int stockQuantity, boolean isActive, 
                                     String coverImageUrl);
    
}