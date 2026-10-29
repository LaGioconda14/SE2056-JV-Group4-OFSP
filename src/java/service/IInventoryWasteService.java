package service;

import java.util.List;
import java.util.Map;
import model.InventoryWasteLog;
import model.WasteStatisticDTO;

public interface IInventoryWasteService {

    List<InventoryWasteLog> getWasteLogsByShop(long shopId, String stageFilter, String keyword, int page, int pageSize);

    int countWasteLogsByShop(long shopId, String stageFilter, String keyword);

    WasteStatisticDTO getWasteStatisticsByShop(long shopId);

    boolean recordManualWaste(long shopId, long variantId, int quantity, String reasonNote, Long loggedBy);

    boolean logOrderCancellationWaste(long subOrderId, String reason, Long loggedBy);

    boolean logOrderCancellationWaste(long subOrderId, String reason, Long loggedBy, Map<Long, Integer> wastedQtyMap);

    boolean logTransitDamageWaste(long subOrderId, String note, Long loggedBy, Map<Long, Integer> wastedQtyMap);
}
