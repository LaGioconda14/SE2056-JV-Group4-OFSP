package service;

import java.util.List;
import java.util.Map;
import model.dto.promotion.Voucher;

/** Service boundary for shop voucher management. */
public interface IShopVoucherService {
    List<Voucher> listByShop(long shopId, String tab, String keyword);
    Map<String, Integer> countByTab(long shopId);
    Map<String, Object> getShopSummary(long shopId);
    Voucher findByIdAndShop(int couponId, long shopId);
    boolean codeExists(String code, Integer excludeId);
    int create(Voucher voucher, long shopId);
    boolean update(Voucher voucher, long shopId);
    boolean setActive(int couponId, long shopId, boolean active);
    boolean terminate(int couponId, long shopId);
    List<Map<String, Object>> getUsageHistory(int couponId, int limit);
    Map<String, Object> getUsageStats(int couponId);
}
