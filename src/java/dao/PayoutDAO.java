package dao;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.PayoutGenerationResult;
import model.VendorPayout;
import util.DBContext;

/**
 * Quyết toán doanh thu gian hàng (Settlement) và chi trả (Withdrawal / Payout).
 *
 * Công thức một kỳ (khớp dữ liệu seed vendor_payouts):
 *   Net = Gross - Hoa hồng sàn - Khấu trừ khiếu nại
 *   - Gross      : tổng shop_total của các sub-order DELIVERED có ngày giao trong kỳ
 *                  (đơn đã thanh toán PAID)
 *   - Hoa hồng   : tổng sub_orders.commission_amount của các sub-order đó
 *   - Khấu trừ   : tổng refunds (DISPUTE / MANUAL) tạo trong kỳ của shop,
 *                  cho sub-order vẫn còn DELIVERED (hoàn đủ thì sub-order đã REFUNDED nên
 *                  không còn nằm trong Gross, tránh trừ hai lần)
 * Vòng đời kỳ: PROCESSING -> COMPLETED (Admin xác nhận đã chuyển tiền);
 *              PROCESSING <-> ON_HOLD (tạm giữ khi shop có khiếu nại chưa xử lý).
 */
public class PayoutDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(PayoutDAO.class.getName());
    private static final SecureRandom RANDOM = new SecureRandom();

    private static final String SELECT_PAYOUT
            = "SELECT p.payout_id, p.payout_code, p.shop_id, s.shop_name, p.cycle_name, p.period_start, "
            + "       p.period_end, p.gross_sales, p.total_orders_count, p.commission_rate, "
            + "       p.commission_withheld, p.dispute_deductions, p.net_payout, p.bank_account_number, "
            + "       p.bank_name, p.status, p.processed_by, a.full_name AS admin_name, p.paid_at, p.created_at "
            + "FROM vendor_payouts p "
            + "JOIN shops s ON s.shop_id = p.shop_id "
            + "LEFT JOIN users a ON a.user_id = p.processed_by ";

    // =====================================================================
    // 1. SETTLEMENT: tính kỳ quyết toán cho các shop
    // =====================================================================
    /**
     * @param shopId null = tất cả shop đang ACTIVE
     * @return số kỳ đã tạo và lý do các shop bị bỏ qua
     */
    public PayoutGenerationResult generate(LocalDate start, LocalDate end, Long shopId) throws SQLException {
        if (start == null || end == null || end.isBefore(start)) {
            throw new IllegalArgumentException("Khoảng thời gian quyết toán không hợp lệ!");
        }
        if (end.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Không thể quyết toán cho ngày chưa diễn ra!");
        }
        Timestamp startTs = Timestamp.valueOf(start.atStartOfDay());
        Timestamp endTs = Timestamp.valueOf(end.atTime(23, 59, 59));
        Timestamp endExclusive = Timestamp.valueOf(end.plusDays(1).atStartOfDay());

        PayoutGenerationResult result = new PayoutGenerationResult();
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }
        try (conn) {
            String shopSql = "SELECT shop_id, shop_name, commission_rate, bank_name, bank_account_number "
                    + "FROM shops WHERE status = 'ACTIVE'" + (shopId != null ? " AND shop_id = ?" : "")
                    + " ORDER BY shop_id";
            List<Object[]> shops = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(shopSql)) {
                if (shopId != null) {
                    ps.setLong(1, shopId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        shops.add(new Object[]{rs.getLong(1), rs.getString(2), rs.getBigDecimal(3),
                            rs.getString(4), rs.getString(5)});
                    }
                }
            }
            if (shops.isEmpty()) {
                throw new IllegalArgumentException("Không tìm thấy gian hàng đang hoạt động để quyết toán!");
            }

            for (Object[] sh : shops) {
                long sid = (Long) sh[0];
                String shopName = (String) sh[1];
                try {
                    String skip = settleOneShop(conn, sid, (BigDecimal) sh[2], (String) sh[3], (String) sh[4],
                            start, end, startTs, endTs, endExclusive);
                    if (skip == null) {
                        result.incrementCreated();
                    } else {
                        result.getSkipped().add(shopName + ": " + skip);
                    }
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "settle shop " + sid + " failed", ex);
                    result.getSkipped().add(shopName + ": lỗi hệ thống khi tính quyết toán");
                }
            }
        }
        return result;
    }

    /** @return null nếu đã tạo kỳ, ngược lại là lý do bỏ qua shop. */
    private String settleOneShop(Connection conn, long shopId, BigDecimal shopRate, String bankName,
            String bankAccount, LocalDate start, LocalDate end, Timestamp startTs, Timestamp endTs,
            Timestamp endExclusive) throws SQLException {

        // Chống quyết toán trùng: không cho hai kỳ của cùng shop chồng lấn thời gian.
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 1 payout_code FROM vendor_payouts WHERE shop_id = ? AND period_start <= ? AND period_end >= ?")) {
            ps.setLong(1, shopId);
            ps.setTimestamp(2, endTs);
            ps.setTimestamp(3, startTs);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "đã có kỳ " + rs.getString(1) + " trùng khoảng thời gian";
                }
            }
        }

        int orders;
        BigDecimal gross;
        BigDecimal commission;
        String aggSql = "SELECT COUNT(*), COALESCE(SUM(so.shop_total), 0), COALESCE(SUM(so.commission_amount), 0) "
                + "FROM sub_orders so "
                + "JOIN orders o ON o.order_id = so.order_id AND o.payment_status = 'PAID' "
                + "LEFT JOIN deliveries d ON d.sub_order_id = so.sub_order_id "
                + "WHERE so.shop_id = ? AND so.status = 'DELIVERED' "
                + "AND COALESCE(d.delivered_at, so.updated_at) >= ? AND COALESCE(d.delivered_at, so.updated_at) < ?";
        try (PreparedStatement ps = conn.prepareStatement(aggSql)) {
            ps.setLong(1, shopId);
            ps.setTimestamp(2, startTs);
            ps.setTimestamp(3, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                orders = rs.getInt(1);
                gross = rs.getBigDecimal(2);
                commission = rs.getBigDecimal(3);
            }
        }

        BigDecimal deductions;
        String dedSql = "SELECT COALESCE(SUM(r.amount), 0) FROM refunds r "
                + "JOIN sub_orders so ON so.sub_order_id = r.sub_order_id "
                + "WHERE r.shop_id = ? AND r.status = 'COMPLETED' AND r.source IN ('DISPUTE', 'MANUAL') "
                + "AND so.status = 'DELIVERED' AND r.created_at >= ? AND r.created_at < ?";
        try (PreparedStatement ps = conn.prepareStatement(dedSql)) {
            ps.setLong(1, shopId);
            ps.setTimestamp(2, startTs);
            ps.setTimestamp(3, endExclusive);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                deductions = rs.getBigDecimal(1);
            }
        }

        if (orders == 0 && deductions.signum() == 0) {
            return "không có đơn giao thành công trong kỳ";
        }

        BigDecimal net = gross.subtract(commission).subtract(deductions);
        boolean hasOpenDispute;
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 1 1 FROM disputes WHERE shop_id = ? AND status IN ('OPEN', 'MEDIATING')")) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                hasOpenDispute = rs.next();
            }
        }
        // Net <= 0 hoặc shop đang có khiếu nại chưa xử lý -> tạm giữ để Admin xem xét.
        // Net âm được giữ nguyên (không ép về 0) để thể hiện khoản shop còn nợ sàn.
        String status = (net.signum() <= 0 || hasOpenDispute)
                ? VendorPayout.STATUS_ON_HOLD : VendorPayout.STATUS_PROCESSING;

        DateTimeFormatter shortFmt = DateTimeFormatter.ofPattern("dd/MM");
        DateTimeFormatter fullFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String cycle = "Kỳ quyết toán " + start.format(shortFmt) + " - " + end.format(fullFmt);
        String code = "PAY-" + start.format(DateTimeFormatter.ofPattern("yyMMdd")) + "-S" + shopId
                + "-" + String.format("%04d", RANDOM.nextInt(10000));

        String ins = "INSERT INTO vendor_payouts (payout_code, shop_id, cycle_name, period_start, period_end, "
                + "gross_sales, total_orders_count, commission_rate, commission_withheld, dispute_deductions, "
                + "net_payout, bank_account_number, bank_name, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(ins)) {
            ps.setString(1, code);
            ps.setLong(2, shopId);
            ps.setNString(3, cycle);
            ps.setTimestamp(4, startTs);
            ps.setTimestamp(5, endTs);
            ps.setBigDecimal(6, gross);
            ps.setInt(7, orders);
            ps.setBigDecimal(8, shopRate);
            ps.setBigDecimal(9, commission);
            ps.setBigDecimal(10, deductions);
            ps.setBigDecimal(11, net);
            ps.setString(12, bankAccount);
            ps.setNString(13, bankName);
            ps.setString(14, status);
            ps.executeUpdate();
        }
        return null;
    }

    // =====================================================================
    // 2. WITHDRAWAL: Admin xử lý chi trả
    // =====================================================================
    /** Admin xác nhận đã chuyển tiền cho chủ shop. PROCESSING -> COMPLETED. */
    public VendorPayout markCompleted(long payoutId, long adminId) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                String status;
                BigDecimal net;
                long shopId;
                String code;
                String pBank;
                String pAccount;
                String sBank;
                String sAccount;
                long ownerId;
                String sel = "SELECT p.status, p.net_payout, p.shop_id, p.payout_code, p.bank_name, p.bank_account_number, "
                        + "s.bank_name AS s_bank, s.bank_account_number AS s_account, s.owner_id "
                        + "FROM vendor_payouts p WITH (UPDLOCK, ROWLOCK) JOIN shops s ON s.shop_id = p.shop_id "
                        + "WHERE p.payout_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sel)) {
                    ps.setLong(1, payoutId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Không tìm thấy kỳ quyết toán!");
                        }
                        status = rs.getString("status");
                        net = rs.getBigDecimal("net_payout");
                        shopId = rs.getLong("shop_id");
                        code = rs.getString("payout_code");
                        pBank = rs.getString("bank_name");
                        pAccount = rs.getString("bank_account_number");
                        sBank = rs.getString("s_bank");
                        sAccount = rs.getString("s_account");
                        ownerId = rs.getLong("owner_id");
                    }
                }
                if (VendorPayout.STATUS_COMPLETED.equalsIgnoreCase(status)) {
                    throw new IllegalStateException("Kỳ " + code + " đã được chi trả trước đó!");
                }
                if (VendorPayout.STATUS_ON_HOLD.equalsIgnoreCase(status)) {
                    throw new IllegalStateException("Kỳ " + code + " đang tạm giữ. Hãy gỡ tạm giữ trước khi chi trả!");
                }
                if (net.signum() <= 0) {
                    throw new IllegalStateException("Kỳ " + code + " không có số tiền cần chi trả!");
                }

                // Ưu tiên tài khoản hiện tại của shop (shop có thể vừa cập nhật), dự phòng bản chụp lúc tạo kỳ.
                String bank = notBlank(sBank) ? sBank : pBank;
                String account = notBlank(sAccount) ? sAccount : pAccount;
                if (!notBlank(bank) || !notBlank(account)) {
                    throw new IllegalArgumentException(
                            "Gian hàng chưa cập nhật tài khoản ngân hàng nhận tiền. Hãy yêu cầu chủ shop bổ sung tại mục Doanh thu & Rút tiền.");
                }

                String upd = "UPDATE vendor_payouts SET status = 'COMPLETED', bank_name = ?, bank_account_number = ?, "
                        + "processed_by = ?, paid_at = CURRENT_TIMESTAMP WHERE payout_id = ? AND status = 'PROCESSING'";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setNString(1, bank);
                    ps.setString(2, account);
                    ps.setLong(3, adminId);
                    ps.setLong(4, payoutId);
                    if (ps.executeUpdate() == 0) {
                        throw new IllegalStateException("Trạng thái kỳ quyết toán vừa thay đổi, vui lòng tải lại trang!");
                    }
                }

                insertNotification(conn, ownerId, "Đã chuyển tiền quyết toán",
                        "Sàn đã chuyển " + money(net) + "đ (kỳ " + code + ") vào tài khoản " + bank + " ••••"
                        + account.substring(Math.max(0, account.length() - 4)) + ".", payoutId);
                conn.commit();
                return findById(conn, payoutId);
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
                return null;
            }
        }
    }

    /** PROCESSING -> ON_HOLD. */
    public void hold(long payoutId) throws SQLException {
        changeStatus(payoutId, "PROCESSING", "ON_HOLD",
                "Chỉ kỳ đang chờ chi trả mới có thể tạm giữ!");
    }

    /** ON_HOLD -> PROCESSING. */
    public void release(long payoutId) throws SQLException {
        changeStatus(payoutId, "ON_HOLD", "PROCESSING",
                "Chỉ kỳ đang tạm giữ mới có thể gỡ tạm giữ!");
    }

    private void changeStatus(long payoutId, String from, String to, String errorMessage) throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "UPDATE vendor_payouts SET status = ? WHERE payout_id = ? AND status = ? AND "
                + "(? <> 'PROCESSING' OR net_payout > 0)")) {
            ps.setString(1, to);
            ps.setLong(2, payoutId);
            ps.setString(3, from);
            ps.setString(4, to);
            if (ps.executeUpdate() == 0) {
                throw new IllegalStateException(errorMessage + " (hoặc kỳ không có tiền để chi trả)");
            }
        }
    }

    /** Hủy kỳ chưa chi trả để tính lại. Kỳ đã COMPLETED không được xóa. */
    public void delete(long payoutId) throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM vendor_payouts WHERE payout_id = ? AND status <> 'COMPLETED'")) {
            ps.setLong(1, payoutId);
            if (ps.executeUpdate() == 0) {
                throw new IllegalStateException("Không thể xóa: kỳ không tồn tại hoặc đã được chi trả!");
            }
        }
    }

    // =====================================================================
    // 3. Truy vấn
    // =====================================================================
    public List<VendorPayout> search(Long shopId, String status, String keyword, int page, int pageSize) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(shopId, status, keyword, params);
        String sql = SELECT_PAYOUT + where
                + " ORDER BY p.created_at DESC, p.payout_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(Math.max(0, page - 1) * pageSize);
        params.add(pageSize);

        List<VendorPayout> list = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "search payouts error", ex);
        }
        return list;
    }

    public int count(Long shopId, String status, String keyword) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(shopId, status, keyword, params);
        String sql = "SELECT COUNT(*) FROM vendor_payouts p JOIN shops s ON s.shop_id = p.shop_id " + where;
        Connection conn = getConnection();
        if (conn == null) {
            return 0;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "count payouts error", ex);
            return 0;
        }
    }

    /** Tổng hợp theo trạng thái; shopId null = toàn sàn. */
    public Map<String, Object> getSummary(Long shopId) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("processingNet", BigDecimal.ZERO);
        m.put("processingCount", 0);
        m.put("holdNet", BigDecimal.ZERO);
        m.put("holdCount", 0);
        m.put("paidNet", BigDecimal.ZERO);
        m.put("paidCount", 0);
        m.put("commissionPaid", BigDecimal.ZERO);
        String sql = "SELECT "
                + "COALESCE(SUM(CASE WHEN status = 'PROCESSING' THEN net_payout END), 0) AS p_net, "
                + "SUM(CASE WHEN status = 'PROCESSING' THEN 1 ELSE 0 END) AS p_cnt, "
                + "COALESCE(SUM(CASE WHEN status = 'ON_HOLD' THEN net_payout END), 0) AS h_net, "
                + "SUM(CASE WHEN status = 'ON_HOLD' THEN 1 ELSE 0 END) AS h_cnt, "
                + "COALESCE(SUM(CASE WHEN status = 'COMPLETED' THEN net_payout END), 0) AS c_net, "
                + "SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS c_cnt, "
                + "COALESCE(SUM(CASE WHEN status = 'COMPLETED' THEN commission_withheld END), 0) AS c_comm "
                + "FROM vendor_payouts" + (shopId != null ? " WHERE shop_id = ?" : "");
        Connection conn = getConnection();
        if (conn == null) {
            return m;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            if (shopId != null) {
                ps.setLong(1, shopId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("processingNet", rs.getBigDecimal("p_net"));
                    m.put("processingCount", rs.getInt("p_cnt"));
                    m.put("holdNet", rs.getBigDecimal("h_net"));
                    m.put("holdCount", rs.getInt("h_cnt"));
                    m.put("paidNet", rs.getBigDecimal("c_net"));
                    m.put("paidCount", rs.getInt("c_cnt"));
                    m.put("commissionPaid", rs.getBigDecimal("c_comm"));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "payout summary error", ex);
        }
        return m;
    }

    /** Danh sách shop đang hoạt động cho ô chọn shop khi tạo kỳ quyết toán. */
    public List<Map<String, Object>> listActiveShops() {
        List<Map<String, Object>> list = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT shop_id, shop_name FROM shops WHERE status = 'ACTIVE' ORDER BY shop_name");
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("shopId", rs.getLong(1));
                m.put("shopName", rs.getString(2));
                list.add(m);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "list active shops error", ex);
        }
        return list;
    }

    // =====================================================================
    // 4. Chủ shop: tài khoản nhận tiền
    // =====================================================================
    /** @return shop_id của shop do user làm chủ, hoặc -1 nếu không có. */
    public long findShopIdByOwner(long userId) {
        Connection conn = getConnection();
        if (conn == null) {
            return -1;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 1 shop_id FROM shops WHERE owner_id = ? ORDER BY shop_id")) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : -1;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "findShopIdByOwner error", ex);
            return -1;
        }
    }

    /** Thông tin shop + tài khoản ngân hàng hiện tại. */
    public Map<String, Object> getShopFinanceInfo(long shopId) {
        Map<String, Object> m = new LinkedHashMap<>();
        Connection conn = getConnection();
        if (conn == null) {
            return m;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT shop_name, commission_rate, bank_name, bank_account_number, bank_account_holder "
                + "FROM shops WHERE shop_id = ?")) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("shopName", rs.getString("shop_name"));
                    m.put("commissionRate", rs.getBigDecimal("commission_rate"));
                    m.put("bankName", rs.getString("bank_name"));
                    m.put("bankAccount", rs.getString("bank_account_number"));
                    m.put("bankHolder", rs.getString("bank_account_holder"));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getShopFinanceInfo error", ex);
        }
        return m;
    }

    public void updateBankInfo(long shopId, long ownerId, String bankName, String account, String holder)
            throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "UPDATE shops SET bank_name = ?, bank_account_number = ?, bank_account_holder = ?, "
                + "updated_at = CURRENT_TIMESTAMP WHERE shop_id = ? AND owner_id = ?")) {
            ps.setNString(1, bankName);
            ps.setString(2, account);
            ps.setNString(3, holder);
            ps.setLong(4, shopId);
            ps.setLong(5, ownerId);
            if (ps.executeUpdate() == 0) {
                throw new IllegalStateException("Bạn không có quyền cập nhật tài khoản của gian hàng này!");
            }
        }
    }

    // =====================================================================
    // Helpers
    // =====================================================================
    private VendorPayout findById(Connection conn, long payoutId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(SELECT_PAYOUT + "WHERE p.payout_id = ?")) {
            ps.setLong(1, payoutId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    private String buildWhere(Long shopId, String status, String keyword, List<Object> params) {
        StringBuilder sb = new StringBuilder(" WHERE 1=1");
        if (shopId != null) {
            sb.append(" AND p.shop_id = ?");
            params.add(shopId);
        }
        if (status != null && !status.isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sb.append(" AND p.status = ?");
            params.add(status.toUpperCase(Locale.ROOT));
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sb.append(" AND (p.payout_code LIKE ? OR s.shop_name LIKE ? OR p.cycle_name LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        return sb.toString();
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Long) {
                ps.setLong(i + 1, (Long) p);
            } else if (p instanceof Integer) {
                ps.setInt(i + 1, (Integer) p);
            } else {
                ps.setNString(i + 1, String.valueOf(p));
            }
        }
    }

    private VendorPayout map(ResultSet rs) throws SQLException {
        VendorPayout p = new VendorPayout();
        p.setPayoutId(rs.getLong("payout_id"));
        p.setPayoutCode(rs.getString("payout_code"));
        p.setShopId(rs.getLong("shop_id"));
        p.setShopName(rs.getString("shop_name"));
        p.setCycleName(rs.getString("cycle_name"));
        p.setPeriodStart(rs.getTimestamp("period_start"));
        p.setPeriodEnd(rs.getTimestamp("period_end"));
        p.setGrossSales(rs.getBigDecimal("gross_sales"));
        p.setTotalOrdersCount(rs.getInt("total_orders_count"));
        p.setCommissionRate(rs.getBigDecimal("commission_rate"));
        p.setCommissionWithheld(rs.getBigDecimal("commission_withheld"));
        p.setDisputeDeductions(rs.getBigDecimal("dispute_deductions"));
        p.setNetPayout(rs.getBigDecimal("net_payout"));
        p.setBankAccountNumber(rs.getString("bank_account_number"));
        p.setBankName(rs.getString("bank_name"));
        p.setStatus(rs.getString("status"));
        long by = rs.getLong("processed_by");
        p.setProcessedBy(rs.wasNull() ? null : by);
        p.setProcessedByName(rs.getString("admin_name"));
        p.setPaidAt(rs.getTimestamp("paid_at"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }

    private Connection openTx() throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }
        conn.setAutoCommit(false);
        return conn;
    }

    private void rollbackThenRethrow(Connection conn, Exception ex) throws SQLException {
        try {
            conn.rollback();
        } catch (SQLException rEx) {
            LOGGER.log(Level.SEVERE, "Rollback failed", rEx);
        }
        if (ex instanceof SQLException) {
            throw (SQLException) ex;
        }
        throw (RuntimeException) ex;
    }

    private void insertNotification(Connection conn, long userId, String title, String message, long refId)
            throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id) "
                + "VALUES (?, ?, ?, 'SETTLEMENT', 'PAYOUT', ?)")) {
            ps.setLong(1, userId);
            ps.setNString(2, title);
            ps.setNString(3, message);
            ps.setLong(4, refId);
            ps.executeUpdate();
        }
    }

    private boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }

    private String money(BigDecimal v) {
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(v.setScale(0, RoundingMode.HALF_UP));
    }
}
