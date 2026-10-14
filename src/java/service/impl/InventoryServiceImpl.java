package service.impl;

import dao.InventoryDAO;
import java.math.BigDecimal;
import java.util.List;
import model.InventoryBatchItem;
import service.IInventoryService;

public class InventoryServiceImpl implements IInventoryService {

    private final InventoryDAO inventoryDAO;

    public InventoryServiceImpl() {
        this.inventoryDAO = new InventoryDAO();
    }

    @Override
    public List<InventoryBatchItem> getInventoryAlertItems(long shopId, String keyword, String riskLevel, 
                                                          String sortBy, String viewTab, int page, int pageSize) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return inventoryDAO.getInventoryAlertItems(shopId, keyword, riskLevel, sortBy, viewTab, page, pageSize);
    }

    @Override
    public int countInventoryAlertItems(long shopId, String keyword, String riskLevel, String viewTab) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return inventoryDAO.countInventoryAlertItems(shopId, keyword, riskLevel, viewTab);
    }

    @Override
    public int getCriticalStockCount(long shopId) {
        return inventoryDAO.getCriticalStockCount(shopId);
    }

    @Override
    public String getCriticalItemNames(long shopId) {
        return inventoryDAO.getCriticalItemNames(shopId);
    }

    @Override
    public int getExpiringFreshnessCount(long shopId) {
        return inventoryDAO.getExpiringFreshnessCount(shopId);
    }

    @Override
    public BigDecimal getTotalInventoryValue(long shopId) {
        return inventoryDAO.getTotalInventoryValue(shopId);
    }

    @Override
    public boolean restockVariant(long variantId, int addedQuantity) throws Exception {
        if (variantId <= 0 || addedQuantity <= 0) {
            throw new Exception("Thông tin nhập kho không hợp lệ!");
        }
        return inventoryDAO.restockVariant(variantId, addedQuantity);
    }

    @Override
    public boolean applyFreshSaleDiscount(long variantId, int discountPercent) throws Exception {
        if (variantId <= 0 || discountPercent <= 0 || discountPercent > 90) {
            throw new Exception("Mức chiết khấu không hợp lệ!");
        }
        return inventoryDAO.applyFreshSaleDiscount(variantId, discountPercent);
    }
}

