package service;

import java.math.BigDecimal;
import java.util.List;
import model.InventoryBatchItem;

public interface IInventoryService {

    List<InventoryBatchItem> getInventoryAlertItems(long shopId, String keyword, String riskLevel, 
                                                    String sortBy, String viewTab, int page, int pageSize) throws Exception;

    int countInventoryAlertItems(long shopId, String keyword, String riskLevel, String viewTab) throws Exception;

    int getCriticalStockCount(long shopId);

    String getCriticalItemNames(long shopId);

    int getExpiringFreshnessCount(long shopId);

    BigDecimal getTotalInventoryValue(long shopId);

    boolean restockVariant(long variantId, int addedQuantity) throws Exception;

    boolean applyFreshSaleDiscount(long variantId, int discountPercent) throws Exception;
}

