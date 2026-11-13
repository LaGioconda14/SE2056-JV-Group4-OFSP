package service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.LoyaltyAccount;
import model.LoyaltyQuote;
import model.LoyaltySettings;
import model.LoyaltyTransaction;
import model.MembershipTier;
import model.dto.order.OrderDetailDTO;

public interface ILoyaltyService {

    // ---------- Khách hàng ----------
    /** Cộng điểm cho đơn đã hoàn tất / hoàn điểm đơn đã hủy (idempotent), rồi gửi thông báo cho khách. */
    void syncOrders(Long customerId);

    /** Tài khoản điểm kèm hạng hiện tại và hạng kế tiếp (đã đồng bộ đơn hàng trước khi trả về). */
    LoyaltyAccount getAccount(long customerId);

    List<LoyaltyTransaction> history(long customerId, String type, java.sql.Date from, java.sql.Date to, int page, int pageSize);

    int countHistory(long customerId, String type, java.sql.Date from, java.sql.Date to);

    /** {tổng điểm đã nhận, tổng điểm đã dùng} */
    int[] historyTotals(long customerId);

    List<MembershipTier> listTiers(boolean activeOnly, String keyword);

    // ---------- Thanh toán ----------
    LoyaltyQuote quote(long customerId, BigDecimal payable);

    /** Áp điểm vào đơn nháp để hiển thị ở trang thanh toán. @throws IllegalArgumentException nếu điểm không hợp lệ. */
    void applyToDraft(OrderDetailDTO draft, long customerId, int points);

    // ---------- Admin ----------
    LoyaltySettings getSettings();

    void updateSettings(int earnVndPerPoint, int redeemVndPerPoint, int maxRedeemPercent) throws Exception;

    List<Map<String, Object>> searchCustomers(String keyword);

    Map<String, Object> getCustomerBrief(long customerId);

    /** @return số dư mới sau khi điều chỉnh */
    int adjustPoints(long customerId, int delta, String reason) throws Exception;

    MembershipTier findTier(int tierId);

    int createTier(MembershipTier tier) throws Exception;

    void updateTier(MembershipTier tier) throws Exception;

    void deleteTier(int tierId) throws Exception;
}
