package service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import model.PayoutGenerationResult;
import model.VendorPayout;

public interface IPayoutService {

    PayoutGenerationResult generateSettlement(LocalDate start, LocalDate end, Long shopId) throws Exception;

    VendorPayout markCompleted(long payoutId, long adminId) throws Exception;

    void hold(long payoutId) throws Exception;

    void release(long payoutId) throws Exception;

    void delete(long payoutId) throws Exception;

    List<VendorPayout> search(Long shopId, String status, String keyword, int page, int pageSize);

    int count(Long shopId, String status, String keyword);

    Map<String, Object> getSummary(Long shopId);

    List<Map<String, Object>> listActiveShops();

    long findShopIdByOwner(long userId);

    Map<String, Object> getShopFinanceInfo(long shopId);

    void updateBankInfo(long shopId, long ownerId, String bankName, String account, String holder) throws Exception;
}
