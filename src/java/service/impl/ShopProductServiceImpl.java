package service.impl;

import dao.ProductDAO;
import dao.ReviewDAO;
import dao.ShopDAO;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import java.util.logging.Logger;
import model.Category;
import model.Product;
import model.ProductVariant;
import model.Review;
import model.Shop;
import service.IShopProductService;

public class ShopProductServiceImpl implements IShopProductService {

    private static final Logger LOGGER = Logger.getLogger(ShopProductServiceImpl.class.getName());
    private final ProductDAO productDAO;
    private final ShopDAO shopDAO;
    private final ReviewDAO reviewDAO;

    public ShopProductServiceImpl() {
        this.productDAO = new ProductDAO();
        this.shopDAO = new ShopDAO();
        this.reviewDAO = new ReviewDAO();
    }

    @Override
    public List<ProductVariant> getVariantsByShopId(long shopId) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return productDAO.getVariantsByShopId(shopId);
    }

    @Override
    public List<ProductVariant> getVariantsByShop(long shopId, String keyword, String categoryId, String stockLevel) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return productDAO.getFilteredVariantsByShop(shopId, keyword, categoryId, null, stockLevel, null, 1, 100);
    }

    @Override
    public List<ProductVariant> getFilteredVariants(long shopId, String keyword, String categoryId, 
                                                    String certification, String stockLevel, 
                                                    String statusTab, int page, int pageSize) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return productDAO.getFilteredVariantsByShop(shopId, keyword, categoryId, certification, stockLevel, statusTab, page, pageSize);
    }

    @Override
    public int countFilteredVariants(long shopId, String keyword, String categoryId, 
                                     String certification, String stockLevel, String statusTab) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return productDAO.countFilteredVariants(shopId, keyword, categoryId, certification, stockLevel, statusTab);
    }

    @Override
    public List<Category> getAllCategories() throws Exception {
        return productDAO.getAllCategories();
    }

    @Override
    public void addShopProduct(long shopId, String name, int categoryId, String origin, 
                               String storageTemp, String certification, String description,
                               String sku, String variantName, String unit, BigDecimal price, 
                               BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                               String batchCode, String harvestDate, String expiryDate, BigDecimal importCost) throws Exception {
        
        if (name == null || name.trim().isEmpty()) {
            throw new Exception("Tên sản phẩm không được để trống!");
        }
        if (sku == null || sku.trim().isEmpty()) {
            throw new Exception("Mã SKU biến thể không được để trống!");
        }
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            throw new Exception("Giá bán lẻ phải lớn hơn 0!");
        }
        if (stockQuantity < 0) {
            throw new Exception("Số lượng tồn kho không được âm!");
        }

        if (productDAO.isSkuExists(sku.trim())) {
            throw new Exception("Mã SKU '" + sku + "' đã tồn tại trên hệ thống!");
        }

        Date sqlHarvestDate = null;
        Date sqlExpiryDate = null;
        try {
            if (harvestDate != null && !harvestDate.trim().isEmpty()) {
                sqlHarvestDate = Date.valueOf(harvestDate.trim());
            }
            if (expiryDate != null && !expiryDate.trim().isEmpty()) {
                sqlExpiryDate = Date.valueOf(expiryDate.trim());
            }
        } catch (IllegalArgumentException e) {
            throw new Exception("Định dạng ngày không hợp lệ (YYYY-MM-DD)!");
        }

        boolean success = productDAO.insertProductWithVariantAndBatch(
            shopId, name.trim(), categoryId, origin, storageTemp, certification, description,
            sku.trim(), variantName, unit, price, originalPrice, stockQuantity, lowStockThreshold,
            batchCode, sqlHarvestDate, sqlExpiryDate, importCost
        );

        if (!success) {
            throw new Exception("Thêm sản phẩm mới thất bại!");
        }
    }

    @Override
    public long addFullProduct(long shopId, String name, int categoryId, String origin,
                               String storageTemp, String certification, String description,
                               String sku, String variantName, String unit, BigDecimal price,
                               BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                               boolean isActive, String coverImageUrl, List<String> detailImageUrls,
                               String shippingStandard) throws Exception {

        if (name == null || name.trim().isEmpty()) {
            throw new Exception("Tên sản phẩm nông sản không được để trống!");
        }
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            price = BigDecimal.ZERO;
        }
        if (originalPrice == null || originalPrice.compareTo(BigDecimal.ZERO) < 0) {
            originalPrice = price;
        }
        if (stockQuantity < 0) {
            stockQuantity = 0;
        }
        if (lowStockThreshold <= 0) {
            lowStockThreshold = 10;
        }

        long productId = productDAO.insertFullProduct(
            shopId, name.trim(), categoryId, origin, storageTemp, certification, description,
            sku, variantName, unit, price, originalPrice, stockQuantity, lowStockThreshold,
            isActive, coverImageUrl, detailImageUrls, shippingStandard
        );

        if (productId <= 0) {
            throw new Exception("Không thể lưu sản phẩm vào cơ sở dữ liệu. Vui lòng kiểm tra lại thông tin!");
        }

        return productId;
    }

    @Override
    public ProductVariant getVariantDetailForEdit(long variantId, long shopId) throws Exception {
        if (variantId <= 0 || shopId <= 0) {
            throw new Exception("Mã sản phẩm hoặc cửa hàng không hợp lệ!");
        }
        ProductVariant variant = productDAO.getVariantDetailForEdit(variantId, shopId);
        if (variant == null) {
            throw new Exception("Không tìm thấy sản phẩm nông sản tương ứng!");
        }
        return variant;
    }

    @Override
    public boolean updateFullProduct(long shopId, long productId, long variantId, String name, int categoryId,
                                     String origin, String storageTemp, String certification, String description,
                                     String sku, String variantName, String unit, BigDecimal price,
                                     BigDecimal originalPrice, int stockQuantity, int lowStockThreshold,
                                     boolean isActive, String coverImageUrl, List<String> detailImageUrls) throws Exception {

        if (name == null || name.trim().isEmpty()) {
            throw new Exception("Tên sản phẩm nông sản không được để trống!");
        }
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            price = BigDecimal.ZERO;
        }
        if (originalPrice == null || originalPrice.compareTo(BigDecimal.ZERO) < 0) {
            originalPrice = price;
        }
        if (stockQuantity < 0) {
            stockQuantity = 0;
        }
        if (lowStockThreshold <= 0) {
            lowStockThreshold = 10;
        }

        boolean updated = productDAO.updateFullProduct(
            shopId, productId, variantId, name.trim(), categoryId, origin, storageTemp,
            certification, description, sku, variantName, unit, price, originalPrice,
            stockQuantity, lowStockThreshold, isActive, coverImageUrl, detailImageUrls
        );

        if (!updated) {
            throw new Exception("Cập nhật thông tin sản phẩm thất bại. Vui lòng kiểm tra lại!");
        }
        return true;
    }

    @Override
    public void toggleVariantStatus(long variantId, long shopId) throws Exception {
        if (variantId <= 0 || shopId <= 0) {
            throw new Exception("Thông tin sản phẩm không hợp lệ!");
        }
        
        boolean updated = productDAO.toggleVariantActiveStatus(variantId, shopId);
        if (!updated) {
            throw new Exception("Không thể thay đổi trạng thái sản phẩm lúc này!");
        }
    }

    @Override
    public void deleteVariant(long variantId, long shopId) throws Exception {
        if (variantId <= 0 || shopId <= 0) {
            throw new Exception("Thông tin sản phẩm không hợp lệ!");
        }

        boolean deleted = productDAO.deleteVariantById(variantId, shopId);
        if (!deleted) {
            throw new Exception("Xóa sản phẩm thất bại!");
        }
    }

    @Override
    public long getShopIDByOwnerID(long id) {
        return shopDAO.getShopIdByOwnerId(id);
    }
    
    @Override
    public int getTotalSkusByShopId(long shopId) {
        return shopDAO.getTotalSkusByShopId(shopId);
    }

    @Override
    public int getTotalProductsCountByShopId(long shopId) {
        return shopDAO.getTotalProductsCountByShopId(shopId);
    }

    @Override
    public int getActiveSkusCountByShopId(long shopId) {
        return shopDAO.getActiveSkusCountByShopId(shopId);
    }

    @Override
    public int getOcopOrVietgapCountByShopId(long shopId) {
        return shopDAO.getOcopOrVietgapCountByShopId(shopId);
    }

    @Override
    public int getTabCountByShopId(long shopId, String tab) {
        return shopDAO.getTabCountByShopId(shopId, tab);
    }

    @Override
    public java.math.BigDecimal getTotalInventoryValueByShopId(long shopId) {
        return shopDAO.getTotalInventoryValueByShopId(shopId);
    }

    @Override
    public int getLowStockCountByShopId(long shopId) {
        return shopDAO.getLowStockCountByShopId(shopId);
    }

    @Override
    public Shop getShopById(long shopId) {
        return shopDAO.getShopById(shopId);
    }

    @Override
    public Shop getShopByOwnerId(long ownerId) {
        return shopDAO.getShopByOwnerId(ownerId);
    }

    @Override
    public Shop getShopBySlug(String slug) {
        return shopDAO.getShopBySlug(slug);
    }

    @Override
    public List<Shop> searchShops(String keyword) {
        return shopDAO.searchShops(keyword);
    }

    @Override
    public List<Product> getProductsByShopId(long shopId, Integer categoryId, String sort) {
        return productDAO.getProductsByShopId(shopId, categoryId, sort);
    }

    @Override
    public List<Category> getCategoriesWithCountByShopId(long shopId) {
        return productDAO.getCategoriesWithCountByShopId(shopId);
    }

    @Override
    public List<Review> getReviewsByShopId(long shopId) {
        return reviewDAO.getReviewsByShopId(shopId);
    }
}