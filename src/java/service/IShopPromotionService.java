package service;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import model.entity.promotion.Promotion;

/** Service boundary for shop promotion management. */
public interface IShopPromotionService {
    List<Promotion> listByShop(long shopId, String tab, String keyword);
    Map<String, Integer> countByTab(long shopId);
    Map<String, Object> getShopSummary(long shopId);
    Promotion findByIdAndShop(long promotionId, long shopId);
    List<String> findConflictingProducts(long shopId, List<Long> productIds, Timestamp start, Timestamp end, long excludeId);
    long create(Promotion promotion);
    boolean update(Promotion promotion);
    boolean setActive(long promotionId, long shopId, boolean active);
    boolean terminate(long promotionId, long shopId);
    List<Map<String, Object>> getShopProductsForPicker(long shopId);
}
