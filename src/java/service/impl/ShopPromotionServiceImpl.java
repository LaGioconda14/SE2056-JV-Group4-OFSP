package service.impl;

import dao.PromotionDAO;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import model.Promotion;
import service.IShopPromotionService;

/** DAO access for shop promotion management. */
public class ShopPromotionServiceImpl implements IShopPromotionService {
    private final PromotionDAO promotionDAO = new PromotionDAO();

    @Override
    public List<Promotion> listByShop(long shopId, String tab, String keyword) { return promotionDAO.listByShop(shopId, tab, keyword); }
    @Override
    public Map<String, Integer> countByTab(long shopId) { return promotionDAO.countByTab(shopId); }
    @Override
    public Map<String, Object> getShopSummary(long shopId) { return promotionDAO.getShopSummary(shopId); }
    @Override
    public Promotion findByIdAndShop(long promotionId, long shopId) { return promotionDAO.findByIdAndShop(promotionId, shopId); }
    @Override
    public List<String> findConflictingProducts(long shopId, List<Long> productIds, Timestamp start, Timestamp end, long excludeId) { return promotionDAO.findConflictingProducts(shopId, productIds, start, end, excludeId); }
    @Override
    public long create(Promotion promotion) { return promotionDAO.create(promotion); }
    @Override
    public boolean update(Promotion promotion) { return promotionDAO.update(promotion); }
    @Override
    public boolean setActive(long promotionId, long shopId, boolean active) { return promotionDAO.setActive(promotionId, shopId, active); }
    @Override
    public boolean terminate(long promotionId, long shopId) { return promotionDAO.terminate(promotionId, shopId); }
    @Override
    public List<Map<String, Object>> getShopProductsForPicker(long shopId) { return promotionDAO.getShopProductsForPicker(shopId); }
}
