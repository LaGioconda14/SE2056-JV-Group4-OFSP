package service.impl;

import dao.InventoryWasteDAO;
import java.util.List;
import java.util.Map;
import model.InventoryWasteLog;
import model.WasteStatisticDTO;
import service.IInventoryWasteService;

public class InventoryWasteServiceImpl implements IInventoryWasteService {

    private final InventoryWasteDAO wasteDAO = new InventoryWasteDAO();

    @Override
    public List<InventoryWasteLog> getWasteLogsByShop(long shopId, String stageFilter, String keyword, int page, int pageSize) {
        return wasteDAO.getWasteLogsByShop(shopId, stageFilter, keyword, page, pageSize);
    }

    @Override
    public int countWasteLogsByShop(long shopId, String stageFilter, String keyword) {
        return wasteDAO.countWasteLogsByShop(shopId, stageFilter, keyword);
    }

    @Override
    public WasteStatisticDTO getWasteStatisticsByShop(long shopId) {
        return wasteDAO.getWasteStatisticsByShop(shopId);
    }

    @Override
    public boolean recordManualWaste(long shopId, long variantId, int quantity, String reasonNote, Long loggedBy) {
        return wasteDAO.recordManualWaste(shopId, variantId, quantity, reasonNote, loggedBy);
    }

    @Override
    public boolean logOrderCancellationWaste(long subOrderId, String reason, Long loggedBy) {
        return wasteDAO.logOrderCancellationWaste(subOrderId, reason, loggedBy);
    }

    @Override
    public boolean logOrderCancellationWaste(long subOrderId, String reason, Long loggedBy, Map<Long, Integer> wastedQtyMap) {
        return wasteDAO.logOrderCancellationWaste(subOrderId, reason, loggedBy, wastedQtyMap);
    }

    @Override
    public boolean logTransitDamageWaste(long subOrderId, String note, Long loggedBy, Map<Long, Integer> wastedQtyMap) {
        return wasteDAO.logTransitDamageWaste(subOrderId, note, loggedBy, wastedQtyMap);
    }
}
