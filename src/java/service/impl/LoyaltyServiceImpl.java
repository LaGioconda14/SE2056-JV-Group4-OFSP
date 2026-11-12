package service.impl;

import dao.LoyaltyDAO;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.LoyaltyAccount;
import model.LoyaltyQuote;
import model.LoyaltySettings;
import model.LoyaltyTransaction;
import model.MembershipTier;
import model.dto.order.OrderDetailDTO;
import service.ILoyaltyService;
import service.INotificationService;

public class LoyaltyServiceImpl implements ILoyaltyService {

    private final LoyaltyDAO loyaltyDAO = new LoyaltyDAO();
    private final INotificationService notificationService = new NotificationServiceImpl();

    @Override
    public void syncOrders(Long customerId) {
        try {
            notifyAll(loyaltyDAO.reconcileCancelledOrders(customerId));
            notifyAll(loyaltyDAO.awardCompletedOrders(customerId));
        } catch (RuntimeException ex) {
            // Điểm thưởng không được làm hỏng luồng chính (giao hàng, hủy đơn, xem trang).
            java.util.logging.Logger.getLogger(LoyaltyServiceImpl.class.getName())
                    .log(java.util.logging.Level.SEVERE, "syncOrders failed", ex);
        }
    }

    private void notifyAll(List<LoyaltyDAO.LoyaltyEvent> events) {
        for (LoyaltyDAO.LoyaltyEvent e : events) {
            notificationService.send(e.getUserId(), e.getTitle(), e.getMessage(), "PROMOTION", "LOYALTY", null);
        }
    }

    @Override
    public LoyaltyAccount getAccount(long customerId) {
        syncOrders(customerId);
        return loyaltyDAO.getOrCreateAccount(customerId);
    }

    @Override
    public List<LoyaltyTransaction> history(long customerId, String type, java.sql.Date from, java.sql.Date to,
            int page, int pageSize) {
        return loyaltyDAO.history(customerId, type, from, to, page, pageSize);
    }

    @Override
    public int countHistory(long customerId, String type, java.sql.Date from, java.sql.Date to) {
        return loyaltyDAO.countHistory(customerId, type, from, to);
    }

    @Override
    public int[] historyTotals(long customerId) {
        return loyaltyDAO.historyTotals(customerId);
    }

    @Override
    public List<MembershipTier> listTiers(boolean activeOnly, String keyword) {
        return loyaltyDAO.listTiers(activeOnly, keyword);
    }

    @Override
    public LoyaltyQuote quote(long customerId, BigDecimal payable) {
        syncOrders(customerId);
        return loyaltyDAO.quote(customerId, payable);
    }

    @Override
    public void applyToDraft(OrderDetailDTO draft, long customerId, int points) {
        draft.setLoyaltyPointsUsed(0);
        draft.setLoyaltyDiscount(BigDecimal.ZERO);
        if (points <= 0) {
            return;
        }
        LoyaltyQuote q = loyaltyDAO.quote(customerId, draft.getFinalAmount());
        if (points > q.getBalance()) {
            throw new IllegalArgumentException("Bạn chỉ có " + q.getBalance() + " điểm, không đủ để dùng " + points + " điểm!");
        }
        if (points > q.getMaxPoints()) {
            throw new IllegalArgumentException("Đơn hàng này chỉ được dùng tối đa " + q.getMaxPoints()
                    + " điểm (giới hạn " + q.getCapPercent() + "% giá trị đơn)!");
        }
        BigDecimal discount = BigDecimal.valueOf((long) points * q.getVndPerPoint());
        draft.setLoyaltyPointsUsed(points);
        draft.setLoyaltyDiscount(discount);
        draft.setFinalAmount(draft.getFinalAmount().subtract(discount).max(BigDecimal.ZERO));
    }

    @Override
    public LoyaltySettings getSettings() {
        return loyaltyDAO.getSettings();
    }

    @Override
    public void updateSettings(int earnVndPerPoint, int redeemVndPerPoint, int maxRedeemPercent) throws Exception {
        if (earnVndPerPoint < 1000 || earnVndPerPoint > 1_000_000) {
            throw new IllegalArgumentException("Số tiền cho 1 điểm phải từ 1.000đ đến 1.000.000đ!");
        }
        if (redeemVndPerPoint < 1 || redeemVndPerPoint > 10_000) {
            throw new IllegalArgumentException("Giá trị 1 điểm khi dùng phải từ 1đ đến 10.000đ!");
        }
        if (maxRedeemPercent < 0 || maxRedeemPercent > 100) {
            throw new IllegalArgumentException("Trần dùng điểm phải từ 0% đến 100%!");
        }
        loyaltyDAO.updateSettings(earnVndPerPoint, redeemVndPerPoint, maxRedeemPercent);
    }

    @Override
    public List<Map<String, Object>> searchCustomers(String keyword) {
        return loyaltyDAO.searchCustomers(keyword);
    }

    @Override
    public Map<String, Object> getCustomerBrief(long customerId) {
        return loyaltyDAO.getCustomerBrief(customerId);
    }

    @Override
    public int adjustPoints(long customerId, int delta, String reason) throws Exception {
        if (delta == 0) {
            throw new IllegalArgumentException("Số điểm điều chỉnh phải khác 0!");
        }
        if (Math.abs(delta) > 1_000_000) {
            throw new IllegalArgumentException("Mỗi lần chỉ được điều chỉnh tối đa 1.000.000 điểm!");
        }
        if (reason == null || reason.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập lý do điều chỉnh!");
        }
        String cleanReason = reason.trim().length() > 200 ? reason.trim().substring(0, 200) : reason.trim();
        int balance = loyaltyDAO.adjustPoints(customerId, delta, cleanReason);
        notificationService.send(customerId,
                delta > 0 ? "Bạn được cộng " + delta + " điểm" : "Điểm thưởng bị trừ " + (-delta) + " điểm",
                "Admin đã điều chỉnh điểm của bạn: " + cleanReason + ". Số dư hiện tại: " + balance + " điểm.",
                "PROMOTION", "LOYALTY", null);
        return balance;
    }

    @Override
    public MembershipTier findTier(int tierId) {
        return loyaltyDAO.findTier(tierId);
    }

    @Override
    public int createTier(MembershipTier tier) throws Exception {
        return loyaltyDAO.createTier(tier);
    }

    @Override
    public void updateTier(MembershipTier tier) throws Exception {
        loyaltyDAO.updateTier(tier);
    }

    @Override
    public void deleteTier(int tierId) throws Exception {
        loyaltyDAO.deleteTier(tierId);
    }
}
