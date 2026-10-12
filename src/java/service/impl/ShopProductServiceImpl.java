package service.impl;

import dao.ProductDAO;
import dao.ShopDAO;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import java.util.logging.Logger;
import model.ProductVariant;
import service.IShopProductService;

public class ShopProductServiceImpl implements IShopProductService {

    private static final Logger LOGGER = Logger.getLogger(ShopProductServiceImpl.class.getName());
    private final ProductDAO productDAO;

    public ShopProductServiceImpl() {
        this.productDAO = new ProductDAO();
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
        return productDAO.getVariantsByShopId(shopId);
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
        ShopDAO dao = new ShopDAO();
        long shopID = dao.getShopIdByOwnerId(id);
        return shopID;
    }
    
    @Override
    public int getTotalSkusByShopId(long shopId) {
        ShopDAO dao = new ShopDAO();
        int totalSKU = dao.getTotalSkusByShopId(shopId);
        return totalSKU;
    }

    @Override
    public java.math.BigDecimal getTotalInventoryValueByShopId(long shopId) {
        ShopDAO dao = new ShopDAO();
        BigDecimal totalInventory = dao.getTotalInventoryValueByShopId(shopId);
        return totalInventory;
    }

    @Override
    public int getLowStockCountByShopId(long shopId) {
        ShopDAO dao = new ShopDAO();
        int lowStock = dao.getLowStockCountByShopId(shopId);
        return lowStock;
    }
}