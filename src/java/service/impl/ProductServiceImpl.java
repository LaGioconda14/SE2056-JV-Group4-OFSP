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
    public List<Product> getProductSummariesByShopId(long shopId) {
        return productDAO.getProductSummariesByShopId(shopId);
    }

    @Override
    public int countProductsByShopId(long shopId) {
        return productDAO.countProductsByShopId(shopId);
    }

    @Override
    public int countProductsByStatusTab(long shopId, String statusTab) {
        return productDAO.countProductsByStatusTab(shopId, statusTab);
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
        
        if (price.compareTo(BigDecimal.ZERO) <= 0) {
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
    public long addVariantToProduct(long shopId, long productId, String sku, String variantName, String unit,
            String priceValue, String originalPriceValue, String stockQuantityValue,
            String lowStockThresholdValue, boolean isActive) {
        if (shopId <= 0 || productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm hoặc cửa hàng không hợp lệ.");
        }
        if (variantName == null || variantName.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên biến thể không được để trống.");
        }
        if (unit == null || unit.trim().isEmpty()) {
            throw new IllegalArgumentException("Đơn vị tính không được để trống.");
        }
        BigDecimal price = parseRequiredPrice(priceValue);
        BigDecimal originalPrice = parseOptionalPrice(originalPriceValue);
        int stockQuantity = parseNonNegativeInteger(stockQuantityValue, "Số lượng tồn kho");
        int lowStockThreshold = parseOptionalPositiveInteger(lowStockThresholdValue, 10);
        if (price.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá bán phải lớn hơn 0.");
        }
        if (originalPrice != null && originalPrice.compareTo(price) < 0) {
            throw new IllegalArgumentException("Giá gốc không được thấp hơn giá bán.");
        }
        if (sku != null && !sku.trim().isEmpty() && productDAO.isSkuExists(sku.trim())) {
            throw new IllegalArgumentException("Mã SKU đã tồn tại, vui lòng nhập mã khác.");
        }
        long variantId = productDAO.addVariantToProduct(shopId, productId, sku, variantName, unit, price,
                originalPrice, stockQuantity, lowStockThreshold > 0 ? lowStockThreshold : 10, isActive);
        if (variantId <= 0) {
            throw new IllegalArgumentException("Không thể thêm biến thể. Vui lòng kiểm tra lại thông tin.");
        }
        return variantId;
    }

    private BigDecimal parseRequiredPrice(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Giá bán không được để trống.");
        }
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Giá bán không hợp lệ.");
        }
    }

    private BigDecimal parseOptionalPrice(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Giá gốc không hợp lệ.");
        }
    }

    private int parseNonNegativeInteger(String value, String fieldName) {
        try {
            int parsedValue = Integer.parseInt(value);
            if (parsedValue < 0) {
                throw new IllegalArgumentException(fieldName + " không được nhỏ hơn 0.");
            }
            return parsedValue;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(fieldName + " không hợp lệ.");
        }
    }

    private int parseOptionalPositiveInteger(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            int parsedValue = Integer.parseInt(value.trim());
            if (parsedValue <= 0) {
                throw new IllegalArgumentException("Ngưỡng cảnh báo kho phải lớn hơn 0.");
            }
            return parsedValue;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Ngưỡng cảnh báo kho không hợp lệ.");
        }
    }
    
    @Override
    public boolean softDeleteVariant(long variantId, long shopId) {
        if (variantId <= 0 || shopId <= 0) {
            throw new IllegalArgumentException("Mã sản phẩm hoặc cửa hàng không hợp lệ!");
        }
        return productDAO.softDeleteVariant(variantId, shopId);
    }

    @Override
    public boolean softDeleteProductAndVariants(long productId, long shopId) {
        if (productId <= 0 || shopId <= 0) {
            throw new IllegalArgumentException("Mã sản phẩm hoặc cửa hàng không hợp lệ!");
        }
        return productDAO.softDeleteProductAndVariants(productId, shopId);
    }
    
    @Override
    public ProductVariant getVariantById(long variantId) {
        return productDAO.getVariantById(variantId);
    }

    @Override
    public ProductVariant getShopVariantById(long variantId, long shopId) {
        if (variantId <= 0 || shopId <= 0) {
            return null;
        }
        return productDAO.getShopVariantById(variantId, shopId);
    }

    @Override
    public boolean updateVariantDetails(long shopId, long variantId, String sku, String variantName, String unit,
            String priceValue, String originalPriceValue, String stockQuantityValue,
            String lowStockThresholdValue, boolean isActive) {
        if (shopId <= 0 || variantId <= 0) {
            throw new IllegalArgumentException("Biến thể hoặc cửa hàng không hợp lệ.");
        }
        if (variantName == null || variantName.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên biến thể không được để trống.");
        }
        if (unit == null || unit.trim().isEmpty()) {
            throw new IllegalArgumentException("Đơn vị tính không được để trống.");
        }
        BigDecimal price = parseRequiredPrice(priceValue);
        BigDecimal originalPrice = parseOptionalPrice(originalPriceValue);
        int stockQuantity = parseNonNegativeInteger(stockQuantityValue, "Số lượng tồn kho");
        int lowStockThreshold = parseOptionalPositiveInteger(lowStockThresholdValue, 10);
        if (price.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá bán phải lớn hơn 0.");
        }
        if (originalPrice != null && originalPrice.compareTo(price) < 0) {
            throw new IllegalArgumentException("Giá gốc không được thấp hơn giá bán.");
        }
        ProductVariant existingVariant = productDAO.getShopVariantById(variantId, shopId);
        if (existingVariant == null) {
            throw new IllegalArgumentException("Không tìm thấy biến thể thuộc cửa hàng này.");
        }
        String updatedSku = sku == null || sku.trim().isEmpty() ? existingVariant.getSku() : sku.trim();
        if (updatedSku != null && productDAO.isSkuUsedByAnotherVariant(updatedSku, variantId)) {
            throw new IllegalArgumentException("Mã SKU đã tồn tại, vui lòng nhập mã khác.");
        }
        boolean updated = productDAO.updateVariantDetails(shopId, variantId, updatedSku, variantName, unit, price,
                originalPrice, stockQuantity, lowStockThreshold, isActive);
        if (!updated) {
            throw new IllegalArgumentException("Cập nhật biến thể thất bại.");
        }
        return true;
    }
    
    @Override
    public model.Product getShopProductForEdit(long productId, long shopId) {
        if (productId <= 0 || shopId <= 0) return null;
        return productDAO.getShopProductForEdit(productId, shopId);
    }

    @Override
    public boolean updateFullProduct(long shopId, long productId, String name, int categoryId, String origin,
                                     String storageTemp, String certification, String description,
                                     boolean isActive, String coverImageUrl) {
        
        // 1. Validate dữ liệu đầu vào cơ bản
        if (productId <= 0 || shopId <= 0) {
            return false;
        }
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        // 2. Gọi DAO thực thi sau khi đã qua cửa kiểm duyệt
        return productDAO.updateFullProduct(shopId, productId, name, categoryId, origin, storageTemp, certification, description, isActive, coverImageUrl);
    }

    @Override
    public List<Product> getHomeProducts() {
        return productDAO.getHomeProducts();
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
    public List<ProductVariant> getShopVariantsByProductId(long shopId, long productId) {
        if (shopId <= 0 || productId <= 0) {
            return Collections.emptyList();
        }
        return productDAO.getShopVariantsByProductId(shopId, productId);
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

    @Override
    public List<Product> getShopFilteredProducts(long shopId, String keyword, Long categoryId, String certification, String stockLevel) {
        return productDAO.getShopFilteredProducts(shopId, keyword, categoryId, certification, stockLevel);
    }
}
