package service.impl;

import dao.PayoutDAO;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import model.PayoutGenerationResult;
import model.VendorPayout;
import service.IPayoutService;

public class PayoutServiceImpl implements IPayoutService {

    private final PayoutDAO payoutDAO = new PayoutDAO();

    @Override
    public PayoutGenerationResult generateSettlement(LocalDate start, LocalDate end, Long shopId) throws Exception {
        return payoutDAO.generate(start, end, shopId);
    }

    @Override
    public VendorPayout markCompleted(long payoutId, long adminId) throws Exception {
        return payoutDAO.markCompleted(payoutId, adminId);
    }

    @Override
    public void hold(long payoutId) throws Exception {
        payoutDAO.hold(payoutId);
    }

    @Override
    public void release(long payoutId) throws Exception {
        payoutDAO.release(payoutId);
    }

    @Override
    public void delete(long payoutId) throws Exception {
        payoutDAO.delete(payoutId);
    }

    @Override
    public List<VendorPayout> search(Long shopId, String status, String keyword, int page, int pageSize) {
        return payoutDAO.search(shopId, status, keyword, page, pageSize);
    }

    @Override
    public int count(Long shopId, String status, String keyword) {
        return payoutDAO.count(shopId, status, keyword);
    }

    @Override
    public Map<String, Object> getSummary(Long shopId) {
        return payoutDAO.getSummary(shopId);
    }

    @Override
    public List<Map<String, Object>> listActiveShops() {
        return payoutDAO.listActiveShops();
    }

    @Override
    public long findShopIdByOwner(long userId) {
        return payoutDAO.findShopIdByOwner(userId);
    }

    @Override
    public Map<String, Object> getShopFinanceInfo(long shopId) {
        return payoutDAO.getShopFinanceInfo(shopId);
    }

    @Override
    public void updateBankInfo(long shopId, long ownerId, String bankName, String account, String holder)
            throws Exception {
        String bank = bankName == null ? "" : bankName.trim();
        String acc = account == null ? "" : account.trim();
        String name = holder == null ? "" : holder.trim();
        if (bank.isEmpty() || name.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ tên ngân hàng và chủ tài khoản!");
        }
        if (!acc.matches("\\d{6,20}")) {
            throw new IllegalArgumentException("Số tài khoản chỉ gồm 6-20 chữ số!");
        }
        payoutDAO.updateBankInfo(shopId, ownerId, bank, acc, name.toUpperCase());
    }
}
