package service;

import java.math.BigDecimal;
import java.util.List;
import model.dto.inventory.InventoryBatchItem;
import model.entity.inventory.InventoryTransaction;
import model.entity.inventory.ProductBatch;

public interface IInventoryService {

    // Alert & analytics methods
    List<InventoryBatchItem> getInventoryAlertItems(long shopId, String keyword, String riskLevel, 
                                                    String sortBy, String viewTab, int page, int pageSize) throws Exception;

    int countInventoryAlertItems(long shopId, String keyword, String riskLevel, String viewTab) throws Exception;

    int getCriticalStockCount(long shopId);

    String getCriticalItemNames(long shopId);

    int getExpiringFreshnessCount(long shopId);

    BigDecimal getTotalInventoryValue(long shopId);

    boolean restockVariant(long variantId, int addedQuantity) throws Exception;

    boolean applyFreshSaleDiscount(long variantId, int discountPercent) throws Exception;

    // Batch & transaction operations
    List<ProductBatch> getBatchesByShopId(long shopId);
    
    boolean restockBatch(long variantId, long shopId, long userId, int quantity, String expiryDate, String note) throws Exception;
    
    boolean adjustBatch(int batchId, int variantId, int shopId, int userId, int deductQuantity,
            String transactionType, String reason) throws Exception;

    boolean disposeBatch(long batchId, long variantId, long shopId, long userId, String reasonCode, String description) throws Exception;

    List<InventoryTransaction> getInventoryHistory(int variantId, int batchId, int shopId);
}
