package service.impl;

import dao.VoucherDAO;
import java.util.List;
import java.util.Map;
import model.dto.promotion.Voucher;
import service.IShopVoucherService;

/** DAO access for shop voucher management. */
public class ShopVoucherServiceImpl implements IShopVoucherService {
    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    public List<Voucher> listByShop(long shopId, String tab, String keyword) { return voucherDAO.listByShop(shopId, tab, keyword); }
    @Override
    public Map<String, Integer> countByTab(long shopId) { return voucherDAO.countByTab(shopId); }
    @Override
    public Map<String, Object> getShopSummary(long shopId) { return voucherDAO.getShopSummary(shopId); }
    @Override
    public Voucher findByIdAndShop(int couponId, long shopId) { return voucherDAO.findByIdAndShop(couponId, shopId); }
    @Override
    public boolean codeExists(String code, Integer excludeId) { return voucherDAO.codeExists(code, excludeId); }
    @Override
    public int create(Voucher voucher, long shopId) { return voucherDAO.create(voucher, shopId); }
    @Override
    public boolean update(Voucher voucher, long shopId) { return voucherDAO.update(voucher, shopId); }
    @Override
    public boolean setActive(int couponId, long shopId, boolean active) { return voucherDAO.setActive(couponId, shopId, active); }
    @Override
    public boolean terminate(int couponId, long shopId) { return voucherDAO.terminate(couponId, shopId); }
    @Override
    public List<Map<String, Object>> getUsageHistory(int couponId, int limit) { return voucherDAO.getUsageHistory(couponId, limit); }
    @Override
    public Map<String, Object> getUsageStats(int couponId) { return voucherDAO.getUsageStats(couponId); }
}
