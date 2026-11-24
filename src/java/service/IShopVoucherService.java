package service;

import java.util.List;
import java.util.Map;
import model.dto.promotion.Voucher;

/** Service boundary for shop voucher management. */
public interface IShopVoucherService {
    List<Voucher> listByShop(long shopId, String tab, String keyword);
    Map<String, Integer> countByTab(long shopId);
    Map<String, Object> getShopSummary(long shopId);
    List<Voucher> listPlatform(String tab, String keyword);
    Map<String, Integer> countPlatformByTab();
    Map<String, Object> getPlatformSummary();
    Voucher findPlatformById(int couponId);
    Voucher findByIdAndShop(int couponId, long shopId);
    boolean codeExists(String code, Integer excludeId);
    int create(Voucher voucher, long shopId);
    int createPlatform(Voucher voucher);
    boolean update(Voucher voucher, long shopId);
    boolean updatePlatform(Voucher voucher);
    boolean setActive(int couponId, long shopId, boolean active);
    boolean setPlatformActive(int couponId, boolean active);
    boolean terminate(int couponId, long shopId);
    boolean terminatePlatform(int couponId);
    List<Map<String, Object>> getUsageHistory(int couponId, int limit);
    Map<String, Object> getUsageStats(int couponId);
}
