package service.impl;

import dao.CategoryDAO;
import dao.ProductDAO;
import java.math.BigDecimal;
import java.util.*;
import model.Category;
import model.Product;
import model.ProductVariant;
import service.IProductService;

public class ProductServiceImpl implements IProductService {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override//lấy danh sách sản phẩm theo shopID 
    public List<ProductVariant> getVariantsByShopId(long shopId) {
        return productDAO.getVariantsByShopId(shopId);
    }

    @Override
    public int countProductsByShopId(long shopId) {
        return productDAO.countProductsByShopId(shopId);
    }

    @Override
    public int countVariantsByShopId(long shopId) {
        return productDAO.countVariantsByShopId(shopId);
    }

    @Override
    public int countVariantsByStatusTab(long shopId, String statusTab) {
        return productDAO.countVariantsByStatusTab(shopId, statusTab);
    }
    
    @Override
    public List<Category> getAllCategories() {
        return categoryDAO.getAllCategories(); // Gọi qua DAO lấy toàn bộ danh mục
    }
    
    @Override
    public List<String> getAllCertifications() {
        return productDAO.getAllCertifications();
    }
    
    @Override
    public List<String> getAllStorageTemps() {
        return productDAO.getAllStorageTemps();
    }

    @Override
    public List<String> getAllUnits() {
        return productDAO.getAllUnits();
    }
    
    @Override
    public long insertFullProduct(long shopId, String name, int categoryId, String origin, 
                                  String storageTemp, String certification, String description,
                                  String sku, String variantName, String unit, BigDecimal price, 
                                  BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                                  boolean isActive, String coverImageUrl, List<String> detailImages, String batchCode) throws IllegalArgumentException {
        
        // --- 1. VALIDATION NGHIỆP VỤ TẠI TẦNG SERVICE ---
        
        if (shopId <= 0) {
            throw new IllegalArgumentException("Mã cửa hàng không hợp lệ!");
        }
        
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên nông sản không được để trống!");
        }
        
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá bán lẻ phải lớn hơn 0!");
        }
        
        if (originalPrice != null && originalPrice.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Giá gốc niêm yết không được là số âm!");
        }
        
        if (stockQuantity < 0) {
            throw new IllegalArgumentException("Số lượng tồn kho ban đầu không được nhỏ hơn 0!");
        }
        
        if (unit == null || unit.trim().isEmpty()) {
            throw new IllegalArgumentException("Đơn vị tính không được để trống!");
        }

        // Kiểm tra nếu SKU do người dùng tự nhập nhưng đã tồn tại trong hệ thống
        if (sku != null && !sku.trim().isEmpty() && productDAO.isSkuExists(sku.trim())) {
            throw new IllegalArgumentException("Mã SKU '" + sku.trim() + "' đã tồn tại trên hệ thống, vui lòng nhập mã khác!");
        }

        // --- 2. XỬ LÝ MẶC ĐỊNH DỮ LIỆU NẾU THIẾU ---
        if (originalPrice == null || originalPrice.compareTo(BigDecimal.ZERO) == 0) {
            // Nếu không nhập giá gốc, mặc định để bằng giá bán lẻ nhân 1.2 (+20%)
            originalPrice = price.multiply(new BigDecimal("1.2"));
        }

        if (lowStockThreshold <= 0) {
            lowStockThreshold = 10; // Ngưỡng cảnh báo tồn kho thấp mặc định là 10
        }

        // --- 3. GỌI DAO ĐỂ THỰC THI TRANSACTION ---
        return productDAO.insertFullProduct(
                shopId, name.trim(), categoryId, origin, storageTemp, certification, description,
                sku, variantName, unit, price, originalPrice, stockQuantity, lowStockThreshold,
                isActive, coverImageUrl, detailImages, batchCode
        );
    }
    
    @Override
    public boolean softDeleteVariant(long variantId, long shopId) {
        if (variantId <= 0 || shopId <= 0) {
            throw new IllegalArgumentException("Mã sản phẩm hoặc cửa hàng không hợp lệ!");
        }
        return productDAO.softDeleteVariant(variantId, shopId);
    }
    
    @Override
    public ProductVariant getVariantById(long variantId) {
        return productDAO.getVariantById(variantId);
    }
    
    @Override
    public boolean updateFullProduct(long shopId,long variantId, String name, int categoryId, String origin, 
                                     String storageTemp, String certification, String description, 
                                     String sku, String variantName, String unit, BigDecimal price, 
                                     BigDecimal originalPrice, int stockQuantity, boolean isActive, 
                                     String coverImageUrl) {
        
        // 1. Validate dữ liệu đầu vào cơ bản
        if (variantId <= 0) {
            return false;
        }
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            return false; // Không cho phép giá bán âm
        }
        if (stockQuantity < 0) {
            return false; // Không cho phép tồn kho âm
        }
        if (unit == null || unit.trim().isEmpty()) {
            unit = "kg"; // Gán mặc định nếu người dùng lỡ để trống
        }

        // 2. Gọi DAO thực thi sau khi đã qua cửa kiểm duyệt
        return productDAO.updateFullProduct(shopId, variantId, name, categoryId, origin, storageTemp, certification, description, sku, variantName, unit, price, originalPrice, stockQuantity, isActive, coverImageUrl);
    }

    @Override
    public List<Product> getHomeProducts() {
        return productDAO.getHomeProducts();
    }

    @Override
    public List<Product> getHomeFeaturedTabs() {
        return productDAO.getHomeFeaturedTabs();
    }

    @Override
    public List<Category> getHierarchyCategories() {
        return productDAO.getHierarchyCategories();
    }
    

    @Override
    public List<Product> getProductsByCategorySlug(String categorySlug) {
        return productDAO.getProductsByCategorySlug(categorySlug);
    }
    
    @Override
    public Product getProductById(int productId) {
        return productDAO.getProductById(productId);
    }

    @Override
    public List<ProductVariant> getVariantsByProductId(long productId) {
        return productDAO.getVariantsByProductId(productId);
    }

    @Override
    public List<String> getImagesByProductId(long productId) {
        return productDAO.getImagesByProductId(productId);
    }

    @Override
    public List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin) {
        return productDAO.searchAndFilterProducts(keyword, categoryId, minPriceStr, maxPriceStr, ratingStr, availability, origin);
    }

    @Override
    public List<Product> searchAndFilterProducts(String keyword, String categoryId, String minPriceStr, String maxPriceStr,
            String ratingStr, String availability, String origin, String sortBy) {
        return productDAO.searchAndFilterProducts(keyword, categoryId, minPriceStr, maxPriceStr,
                ratingStr, availability, origin, sortBy);
    }
}
