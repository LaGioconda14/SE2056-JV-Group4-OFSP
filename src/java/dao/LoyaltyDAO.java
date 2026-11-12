package dao;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.LoyaltyAccount;
import model.LoyaltyQuote;
import model.LoyaltySettings;
import model.LoyaltyTransaction;
import model.MembershipTier;
import model.RedeemPlan;
import util.DBContext;

/**
 * Điểm thưởng & hạng thành viên (FE-14).
 *
 * Quy tắc:
 *  - Tích điểm (EARN): đơn COMPLETED + PAID, điểm = floor(floor(final_amount / EARN_VND_PER_POINT) x hệ số hạng).
 *    Mỗi đơn chỉ được cộng một lần (kiểm tra bảng loyalty_transactions).
 *  - Dùng điểm (REDEEM): trừ điểm trong CÙNG transaction tạo đơn; giảm giá = điểm x REDEEM_VND_PER_POINT,
 *    không vượt trần % giá trị đơn (theo hạng hoặc trần chung) và không vượt số dư.
 *  - Hủy đơn -> hoàn điểm đã dùng (RESTORE); đơn đã tích điểm mà bị hoàn tiền -> thu hồi (REVERSE).
 *  - Hạng xét theo TỔNG ĐIỂM TÍCH LUỸ (lifetime_points) nên tiêu điểm không làm tụt hạng.
 */
public class LoyaltyDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(LoyaltyDAO.class.getName());
    private static volatile Boolean HAS_ORDER_LOYALTY_COLS = null;

    /** Thông báo cần gửi cho khách sau khi giao dịch điểm đã commit. */
    public static class LoyaltyEvent {

        private final long userId;
        private final String title;
        private final String message;

        public LoyaltyEvent(long userId, String title, String message) {
            this.userId = userId;
            this.title = title;
            this.message = message;
        }

        public long getUserId() { return userId; }
        public String getTitle() { return title; }
        public String getMessage() { return message; }
    }

    // =====================================================================
    // 1. LUẬT CHƯƠNG TRÌNH
    // =====================================================================
    public LoyaltySettings getSettings() {
        Connection conn = getConnection();
        if (conn == null) {
            return new LoyaltySettings();
        }
        try (conn) {
            return readSettings(conn);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getSettings error", ex);
            return new LoyaltySettings();
        }
    }

    public void updateSettings(int earnVndPerPoint, int redeemVndPerPoint, int maxRedeemPercent) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                upsertSetting(conn, "EARN_VND_PER_POINT", String.valueOf(earnVndPerPoint));
                upsertSetting(conn, "REDEEM_VND_PER_POINT", String.valueOf(redeemVndPerPoint));
                upsertSetting(conn, "MAX_REDEEM_PERCENT", String.valueOf(maxRedeemPercent));
                conn.commit();
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
            }
        }
    }

    private void upsertSetting(Connection conn, String key, String value) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE loyalty_settings SET setting_value = ?, updated_at = CURRENT_TIMESTAMP WHERE setting_key = ?")) {
            ps.setString(1, value);
            ps.setString(2, key);
            if (ps.executeUpdate() > 0) {
                return;
            }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO loyalty_settings (setting_key, setting_value) VALUES (?, ?)")) {
            ps.setString(1, key);
            ps.setString(2, value);
            ps.executeUpdate();
        }
    }

    private LoyaltySettings readSettings(Connection conn) throws SQLException {
        LoyaltySettings s = new LoyaltySettings();
        try (PreparedStatement ps = conn.prepareStatement("SELECT setting_key, setting_value FROM loyalty_settings");
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String key = rs.getString(1);
                String val = rs.getString(2);
                try {
                    switch (key) {
                        case "EARN_VND_PER_POINT": s.setEarnVndPerPoint(Math.max(1, Integer.parseInt(val.trim()))); break;
                        case "REDEEM_VND_PER_POINT": s.setRedeemVndPerPoint(Math.max(1, Integer.parseInt(val.trim()))); break;
                        case "MAX_REDEEM_PERCENT": s.setMaxRedeemPercent(Math.max(0, Math.min(100, Integer.parseInt(val.trim())))); break;
                        case "EARN_START_DATE": s.setEarnStartDate(val); break;
                        default: break;
                    }
                } catch (NumberFormatException ignored) {
                    // giữ giá trị mặc định nếu cấu hình bị sai định dạng
                }
            }
        }
        return s;
    }

    // =====================================================================
    // 2. HẠNG THÀNH VIÊN (CRUD)
    // =====================================================================
    public List<MembershipTier> listTiers(boolean activeOnly, String keyword) {
        List<MembershipTier> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT t.tier_id, t.tier_code, t.tier_name, t.min_points, t.point_multiplier, "
                + "t.redeem_cap_percent, t.badge_color, t.description, t.is_active, "
                + "(SELECT COUNT(*) FROM loyalty_accounts a WHERE a.membership_tier = t.tier_code) AS member_count "
                + "FROM membership_tiers t WHERE 1=1");
        if (activeOnly) {
            sql.append(" AND t.is_active = 1");
        }
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        if (hasKeyword) {
            sql.append(" AND (t.tier_name LIKE ? OR t.tier_code LIKE ?)");
        }
        sql.append(" ORDER BY t.min_points ASC");
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (hasKeyword) {
                String like = "%" + keyword.trim() + "%";
                ps.setNString(1, like);
                ps.setNString(2, like);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTier(rs, true));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "listTiers error", ex);
        }
        return list;
    }

    public MembershipTier findTier(int tierId) {
        Connection conn = getConnection();
        if (conn == null) {
            return null;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT t.tier_id, t.tier_code, t.tier_name, t.min_points, t.point_multiplier, t.redeem_cap_percent, "
                + "t.badge_color, t.description, t.is_active, "
                + "(SELECT COUNT(*) FROM loyalty_accounts a WHERE a.membership_tier = t.tier_code) AS member_count "
                + "FROM membership_tiers t WHERE t.tier_id = ?")) {
            ps.setInt(1, tierId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapTier(rs, true) : null;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "findTier error", ex);
            return null;
        }
    }

    public int createTier(MembershipTier tier) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                validateTier(conn, tier, 0);
                String code = uniqueTierCode(conn, tier.getTierName());
                int id = -1;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO membership_tiers (tier_code, tier_name, min_points, point_multiplier, "
                        + "redeem_cap_percent, badge_color, description, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    bindTier(ps, tier, code);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            id = rs.getInt(1);
                        }
                    }
                }
                ensureBaseTierExists(conn);
                recomputeAllTiers(conn);
                conn.commit();
                return id;
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
                return -1;
            }
        }
    }

    public void updateTier(MembershipTier tier) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                validateTier(conn, tier, tier.getTierId());
                int rows;
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE membership_tiers SET tier_name = ?, min_points = ?, point_multiplier = ?, "
                        + "redeem_cap_percent = ?, badge_color = ?, description = ?, is_active = ?, "
                        + "updated_at = CURRENT_TIMESTAMP WHERE tier_id = ?")) {
                    ps.setNString(1, tier.getTierName().trim());
                    ps.setInt(2, tier.getMinPoints());
                    ps.setBigDecimal(3, tier.getPointMultiplier());
                    if (tier.getRedeemCapPercent() == null) {
                        ps.setNull(4, java.sql.Types.DECIMAL);
                    } else {
                        ps.setBigDecimal(4, tier.getRedeemCapPercent());
                    }
                    ps.setString(5, tier.getBadgeColor());
                    ps.setNString(6, tier.getDescription());
                    ps.setBoolean(7, tier.isActive());
                    ps.setInt(8, tier.getTierId());
                    rows = ps.executeUpdate();
                }
                if (rows == 0) {
                    throw new IllegalArgumentException("Không tìm thấy hạng thành viên cần sửa!");
                }
                ensureBaseTierExists(conn);
                recomputeAllTiers(conn);
                conn.commit();
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
            }
        }
    }

    public void deleteTier(int tierId) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                String code = null;
                try (PreparedStatement ps = conn.prepareStatement("SELECT tier_code FROM membership_tiers WHERE tier_id = ?")) {
                    ps.setInt(1, tierId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            code = rs.getString(1);
                        }
                    }
                }
                if (code == null) {
                    throw new IllegalArgumentException("Không tìm thấy hạng thành viên cần xóa!");
                }
                int members;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM loyalty_accounts WHERE membership_tier = ?")) {
                    ps.setString(1, code);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        members = rs.getInt(1);
                    }
                }
                if (members > 0) {
                    throw new IllegalStateException("Hạng này đang có " + members
                            + " thành viên nên không thể xóa. Hãy ngừng kích hoạt hạng thay vì xóa.");
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM membership_tiers WHERE tier_id = ?")) {
                    ps.setInt(1, tierId);
                    ps.executeUpdate();
                }
                ensureBaseTierExists(conn);
                conn.commit();
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
            }
        }
    }

    private void validateTier(Connection conn, MembershipTier t, int excludeId) throws SQLException {
        if (t.getTierName() == null || t.getTierName().trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập tên hạng!");
        }
        if (t.getMinPoints() < 0) {
            throw new IllegalArgumentException("Điểm tối thiểu không được âm!");
        }
        if (t.getPointMultiplier() == null || t.getPointMultiplier().compareTo(new BigDecimal("0.5")) < 0
                || t.getPointMultiplier().compareTo(new BigDecimal("5")) > 0) {
            throw new IllegalArgumentException("Hệ số nhân điểm phải nằm trong khoảng 0.5 đến 5!");
        }
        if (t.getRedeemCapPercent() != null && (t.getRedeemCapPercent().signum() < 0
                || t.getRedeemCapPercent().compareTo(new BigDecimal("100")) > 0)) {
            throw new IllegalArgumentException("Trần dùng điểm phải từ 0% đến 100%!");
        }
        if (t.getBadgeColor() == null || !t.getBadgeColor().matches("^#[0-9a-fA-F]{6}$")) {
            throw new IllegalArgumentException("Màu huy hiệu không hợp lệ!");
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM membership_tiers WHERE tier_id <> ? AND (min_points = ? OR LOWER(tier_name) = LOWER(?))")) {
            ps.setInt(1, excludeId);
            ps.setInt(2, t.getMinPoints());
            ps.setNString(3, t.getTierName().trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    throw new IllegalArgumentException("Tên hạng hoặc mức điểm tối thiểu đã tồn tại ở hạng khác!");
                }
            }
        }
    }

    private void bindTier(PreparedStatement ps, MembershipTier t, String code) throws SQLException {
        ps.setString(1, code);
        ps.setNString(2, t.getTierName().trim());
        ps.setInt(3, t.getMinPoints());
        ps.setBigDecimal(4, t.getPointMultiplier());
        if (t.getRedeemCapPercent() == null) {
            ps.setNull(5, java.sql.Types.DECIMAL);
        } else {
            ps.setBigDecimal(5, t.getRedeemCapPercent());
        }
        ps.setString(6, t.getBadgeColor());
        ps.setNString(7, t.getDescription());
        ps.setBoolean(8, t.isActive());
    }

    /** Luôn phải còn ít nhất một hạng đang kích hoạt có min_points = 0 để mọi khách đều có hạng. */
    private void ensureBaseTierExists(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM membership_tiers WHERE is_active = 1 AND min_points = 0")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalStateException(
                            "Phải còn ít nhất một hạng đang kích hoạt có điểm tối thiểu bằng 0 (hạng khởi đầu)!");
                }
            }
        }
    }

    private String uniqueTierCode(Connection conn, String name) throws SQLException {
        String base = Normalizer.normalize(name.trim(), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "").replace('đ', 'd').replace('Đ', 'D')
                .replaceAll("[^A-Za-z0-9]+", "_").replaceAll("^_+|_+$", "").toUpperCase(Locale.ROOT);
        if (base.isEmpty()) {
            base = "TIER";
        }
        if (base.length() > 24) {
            base = base.substring(0, 24);
        }
        String code = base;
        int n = 1;
        while (true) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM membership_tiers WHERE tier_code = ?")) {
                ps.setString(1, code);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return code;
                    }
                }
            }
            code = base + "_" + (++n);
        }
    }

    /** Xét lại hạng của mọi tài khoản theo bảng hạng hiện tại. */
    private void recomputeAllTiers(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE a SET a.membership_tier = ISNULL((SELECT TOP 1 t.tier_code FROM membership_tiers t "
                + "WHERE t.is_active = 1 AND t.min_points <= a.lifetime_points ORDER BY t.min_points DESC), a.membership_tier) "
                + "FROM loyalty_accounts a")) {
            ps.executeUpdate();
        }
    }

    private MembershipTier mapTier(ResultSet rs, boolean withCount) throws SQLException {
        MembershipTier t = new MembershipTier();
        t.setTierId(rs.getInt("tier_id"));
        t.setTierCode(rs.getString("tier_code"));
        t.setTierName(rs.getString("tier_name"));
        t.setMinPoints(rs.getInt("min_points"));
        t.setPointMultiplier(rs.getBigDecimal("point_multiplier"));
        t.setRedeemCapPercent(rs.getBigDecimal("redeem_cap_percent"));
        t.setBadgeColor(rs.getString("badge_color"));
        t.setDescription(rs.getString("description"));
        t.setActive(rs.getBoolean("is_active"));
        if (withCount) {
            t.setMemberCount(rs.getInt("member_count"));
        }
        return t;
    }

    private MembershipTier tierForLifetime(Connection conn, int lifetime) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 1 tier_id, tier_code, tier_name, min_points, point_multiplier, redeem_cap_percent, "
                + "badge_color, description, is_active FROM membership_tiers "
                + "WHERE is_active = 1 AND min_points <= ? ORDER BY min_points DESC")) {
            ps.setInt(1, lifetime);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapTier(rs, false) : null;
            }
        }
    }

    private MembershipTier nextTierAfter(Connection conn, int lifetime) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 1 tier_id, tier_code, tier_name, min_points, point_multiplier, redeem_cap_percent, "
                + "badge_color, description, is_active FROM membership_tiers "
                + "WHERE is_active = 1 AND min_points > ? ORDER BY min_points ASC")) {
            ps.setInt(1, lifetime);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapTier(rs, false) : null;
            }
        }
    }

    // =====================================================================
    // 3. TÀI KHOẢN ĐIỂM
    // =====================================================================
    /** Lấy tài khoản điểm; chưa có thì tự tạo (hạng khởi đầu, 0 điểm). */
    public LoyaltyAccount getOrCreateAccount(long customerId) {
        Connection conn = getConnection();
        if (conn == null) {
            return null;
        }
        try (conn) {
            ensureAccount(conn, customerId);
            LoyaltyAccount acc = new LoyaltyAccount();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT account_id, customer_id, current_points, lifetime_points, created_at "
                    + "FROM loyalty_accounts WHERE customer_id = ?")) {
                ps.setLong(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    acc.setAccountId(rs.getLong("account_id"));
                    acc.setCustomerId(rs.getLong("customer_id"));
                    acc.setCurrentPoints(rs.getInt("current_points"));
                    acc.setLifetimePoints(rs.getInt("lifetime_points"));
                    acc.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
            acc.setTier(tierForLifetime(conn, acc.getLifetimePoints()));
            acc.setNextTier(nextTierAfter(conn, acc.getLifetimePoints()));
            LoyaltySettings st = readSettings(conn);
            acc.setPointValueVnd(BigDecimal.valueOf((long) acc.getCurrentPoints() * st.getRedeemVndPerPoint()));
            return acc;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getOrCreateAccount error, customer=" + customerId, ex);
            return null;
        }
    }

    private void ensureAccount(Connection conn, long customerId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO loyalty_accounts (customer_id, current_points, lifetime_points, membership_tier) "
                + "SELECT ?, 0, 0, ISNULL((SELECT TOP 1 tier_code FROM membership_tiers WHERE is_active = 1 "
                + "ORDER BY min_points ASC), 'BRONZE') "
                + "WHERE NOT EXISTS (SELECT 1 FROM loyalty_accounts WHERE customer_id = ?)")) {
            ps.setLong(1, customerId);
            ps.setLong(2, customerId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            // Hai request tạo cùng lúc: bản ghi thứ hai vi phạm UNIQUE, coi như đã có tài khoản.
            if (ex.getErrorCode() != 2627 && ex.getErrorCode() != 2601) {
                throw ex;
            }
        }
    }

    /** Khóa dòng tài khoản; trả {accountId, currentPoints, lifetimePoints}. */
    private long[] lockAccount(Connection conn, long customerId) throws SQLException {
        ensureAccount(conn, customerId);
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT account_id, current_points, lifetime_points FROM loyalty_accounts "
                + "WITH (UPDLOCK, ROWLOCK) WHERE customer_id = ?")) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("Không tạo được tài khoản điểm thưởng!");
                }
                return new long[]{rs.getLong(1), rs.getLong(2), rs.getLong(3)};
            }
        }
    }

    private void saveBalance(Connection conn, long accountId, int current, int lifetime) throws SQLException {
        MembershipTier tier = tierForLifetime(conn, lifetime);
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE loyalty_accounts SET current_points = ?, lifetime_points = ?, "
                + "membership_tier = ISNULL(?, membership_tier), updated_at = CURRENT_TIMESTAMP WHERE account_id = ?")) {
            ps.setInt(1, current);
            ps.setInt(2, lifetime);
            ps.setString(3, tier == null ? null : tier.getTierCode());
            ps.setLong(4, accountId);
            ps.executeUpdate();
        }
    }

    private void insertTx(Connection conn, long accountId, Long orderId, int delta, String type,
            String description, int balanceAfter) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO loyalty_transactions (account_id, order_id, points_delta, description, tx_type, balance_after) "
                + "VALUES (?, ?, ?, ?, ?, ?)")) {
            ps.setLong(1, accountId);
            if (orderId == null) {
                ps.setNull(2, java.sql.Types.BIGINT);
            } else {
                ps.setLong(2, orderId);
            }
            ps.setInt(3, delta);
            ps.setNString(4, description);
            ps.setString(5, type);
            ps.setInt(6, balanceAfter);
            ps.executeUpdate();
        }
    }

    // =====================================================================
    // 4. LỊCH SỬ ĐIỂM
    // =====================================================================
    public List<LoyaltyTransaction> history(long customerId, String type, java.sql.Date from, java.sql.Date to,
            int page, int pageSize) {
        List<Object> params = new ArrayList<>();
        String where = historyWhere(customerId, type, from, to, params);
        String sql = "SELECT t.transaction_id, t.account_id, t.order_id, o.order_code, t.points_delta, t.tx_type, "
                + "t.description, t.balance_after, t.created_at "
                + "FROM loyalty_transactions t JOIN loyalty_accounts a ON a.account_id = t.account_id "
                + "LEFT JOIN orders o ON o.order_id = t.order_id " + where
                + " ORDER BY t.created_at DESC, t.transaction_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(Math.max(0, page - 1) * pageSize);
        params.add(pageSize);
        List<LoyaltyTransaction> list = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LoyaltyTransaction t = new LoyaltyTransaction();
                    t.setTransactionId(rs.getLong("transaction_id"));
                    t.setAccountId(rs.getLong("account_id"));
                    long orderId = rs.getLong("order_id");
                    t.setOrderId(rs.wasNull() ? null : orderId);
                    t.setOrderCode(rs.getString("order_code"));
                    t.setPointsDelta(rs.getInt("points_delta"));
                    t.setTxType(rs.getString("tx_type"));
                    t.setDescription(rs.getString("description"));
                    int bal = rs.getInt("balance_after");
                    t.setBalanceAfter(rs.wasNull() ? null : bal);
                    t.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(t);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "history error", ex);
        }
        return list;
    }

    public int countHistory(long customerId, String type, java.sql.Date from, java.sql.Date to) {
        List<Object> params = new ArrayList<>();
        String where = historyWhere(customerId, type, from, to, params);
        Connection conn = getConnection();
        if (conn == null) {
            return 0;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM loyalty_transactions t JOIN loyalty_accounts a ON a.account_id = t.account_id " + where)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "countHistory error", ex);
            return 0;
        }
    }

    /** @return {tổng điểm đã nhận (EARN + RESTORE + ADJUST dương), tổng điểm đã dùng (giá trị dương)} */
    public int[] historyTotals(long customerId) {
        int[] totals = new int[]{0, 0};
        Connection conn = getConnection();
        if (conn == null) {
            return totals;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT COALESCE(SUM(CASE WHEN t.points_delta > 0 THEN t.points_delta END), 0), "
                + "COALESCE(SUM(CASE WHEN t.points_delta < 0 THEN -t.points_delta END), 0) "
                + "FROM loyalty_transactions t JOIN loyalty_accounts a ON a.account_id = t.account_id "
                + "WHERE a.customer_id = ?")) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totals[0] = rs.getInt(1);
                    totals[1] = rs.getInt(2);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "historyTotals error", ex);
        }
        return totals;
    }

    private String historyWhere(long customerId, String type, java.sql.Date from, java.sql.Date to, List<Object> params) {
        StringBuilder sb = new StringBuilder(" WHERE a.customer_id = ?");
        params.add(customerId);
        if (type != null && !type.isEmpty() && !"ALL".equalsIgnoreCase(type)) {
            sb.append(" AND t.tx_type = ?");
            params.add(type.toUpperCase(Locale.ROOT));
        }
        if (from != null) {
            sb.append(" AND t.created_at >= ?");
            params.add(new Timestamp(from.getTime()));
        }
        if (to != null) {
            sb.append(" AND t.created_at < ?");
            params.add(new Timestamp(to.getTime() + 86_400_000L));
        }
        return sb.toString();
    }

    // =====================================================================
    // 5. TÍCH ĐIỂM TỰ ĐỘNG (đơn hoàn tất)
    // =====================================================================
    /**
     * Cộng điểm cho các đơn COMPLETED + PAID chưa được cộng. Gọi sau khi giao hàng thành công và mỗi khi
     * khách mở trang điểm thưởng; an toàn khi gọi nhiều lần (mỗi đơn chỉ cộng một lần).
     *
     * @param customerId null = xử lý cho mọi khách
     */
    public List<LoyaltyEvent> awardCompletedOrders(Long customerId) {
        List<LoyaltyEvent> events = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return events;
        }
        try (conn) {
            LoyaltySettings st = readSettings(conn);
            Timestamp since = parseStart(st.getEarnStartDate());
            String sql = "SELECT o.order_id, o.order_code, o.customer_id, o.final_amount FROM orders o "
                    + "WHERE o.order_status = 'COMPLETED' AND o.payment_status = 'PAID' AND o.updated_at >= ? "
                    + "AND NOT EXISTS (SELECT 1 FROM loyalty_transactions t WHERE t.order_id = o.order_id AND t.tx_type = 'EARN')"
                    + (customerId != null ? " AND o.customer_id = ?" : "") + " ORDER BY o.order_id";
            List<Object[]> candidates = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setTimestamp(1, since);
                if (customerId != null) {
                    ps.setLong(2, customerId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        candidates.add(new Object[]{rs.getLong(1), rs.getString(2), rs.getLong(3), rs.getBigDecimal(4)});
                    }
                }
            }
            for (Object[] c : candidates) {
                try {
                    LoyaltyEvent ev = earnForOrder(conn, st, (Long) c[0], (String) c[1], (Long) c[2], (BigDecimal) c[3]);
                    if (ev != null) {
                        events.add(ev);
                    }
                } catch (SQLException ex) {
                    safeRollback(conn);
                    LOGGER.log(Level.SEVERE, "earn failed for order " + c[1], ex);
                } finally {
                    safeAutoCommit(conn);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "awardCompletedOrders error", ex);
        }
        return events;
    }

    private LoyaltyEvent earnForOrder(Connection conn, LoyaltySettings st, long orderId, String orderCode,
            long customerId, BigDecimal finalAmount) throws SQLException {
        conn.setAutoCommit(false);
        long[] acc = lockAccount(conn, customerId);
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM loyalty_transactions WHERE order_id = ? AND tx_type = 'EARN'")) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    conn.rollback();
                    return null;
                }
            }
        }
        int lifetime = (int) acc[2];
        MembershipTier tier = tierForLifetime(conn, lifetime);
        BigDecimal multiplier = tier == null ? BigDecimal.ONE : tier.getPointMultiplier();
        long base = finalAmount.divideToIntegralValue(BigDecimal.valueOf(st.getEarnVndPerPoint())).longValue();
        int points = BigDecimal.valueOf(base).multiply(multiplier).setScale(0, RoundingMode.FLOOR).intValue();
        if (points <= 0) {
            conn.rollback();
            return null;
        }
        int newCurrent = (int) acc[1] + points;
        int newLifetime = lifetime + points;
        saveBalance(conn, acc[0], newCurrent, newLifetime);
        insertTx(conn, acc[0], orderId, points, LoyaltyTransaction.EARN,
                "Tích điểm từ đơn hàng #" + orderCode + (multiplier.compareTo(BigDecimal.ONE) != 0
                        ? " (hạng " + tier.getTierName() + " x" + multiplier.stripTrailingZeros().toPlainString() + ")" : ""),
                newCurrent);
        MembershipTier after = tierForLifetime(conn, newLifetime);
        conn.commit();

        String msg = "Đơn hàng #" + orderCode + " đã hoàn tất, bạn nhận được " + points + " điểm thưởng.";
        if (after != null && tier != null && after.getMinPoints() > tier.getMinPoints()) {
            msg += " Chúc mừng, bạn đã lên hạng " + after.getTierName() + "!";
        }
        return new LoyaltyEvent(customerId, "Bạn nhận được " + points + " điểm thưởng", msg);
    }

    // =====================================================================
    // 6. HOÀN / THU HỒI ĐIỂM (hủy đơn, hoàn tiền)
    // =====================================================================
    /**
     * - Đơn đã HỦY có dùng điểm  -> hoàn lại điểm đã dùng (RESTORE).
     * - Đơn đã tích điểm mà bị hoàn tiền (payment_status = REFUNDED) -> thu hồi điểm đã tích (REVERSE).
     */
    public List<LoyaltyEvent> reconcileCancelledOrders(Long customerId) {
        List<LoyaltyEvent> events = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            return events;
        }
        try (conn) {
            if (!hasOrderLoyaltyCols(conn)) {
                return events;
            }
            String restoreSql = "SELECT o.order_id, o.order_code, o.customer_id, o.loyalty_points_used FROM orders o "
                    + "WHERE o.loyalty_points_used > 0 AND o.order_status = 'CANCELLED' "
                    + "AND NOT EXISTS (SELECT 1 FROM loyalty_transactions t WHERE t.order_id = o.order_id AND t.tx_type = 'RESTORE')"
                    + (customerId != null ? " AND o.customer_id = ?" : "");
            List<Object[]> restores = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(restoreSql)) {
                if (customerId != null) {
                    ps.setLong(1, customerId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        restores.add(new Object[]{rs.getLong(1), rs.getString(2), rs.getLong(3), rs.getInt(4)});
                    }
                }
            }
            for (Object[] r : restores) {
                try {
                    conn.setAutoCommit(false);
                    long[] acc = lockAccount(conn, (Long) r[2]);
                    int pts = (Integer) r[3];
                    int newCurrent = (int) acc[1] + pts;
                    saveBalance(conn, acc[0], newCurrent, (int) acc[2]);
                    insertTx(conn, acc[0], (Long) r[0], pts, LoyaltyTransaction.RESTORE,
                            "Hoàn điểm do hủy đơn hàng #" + r[1], newCurrent);
                    conn.commit();
                    events.add(new LoyaltyEvent((Long) r[2], "Đã hoàn " + pts + " điểm",
                            "Đơn hàng #" + r[1] + " đã hủy, " + pts + " điểm bạn dùng đã được hoàn lại."));
                } catch (SQLException ex) {
                    safeRollback(conn);
                    LOGGER.log(Level.SEVERE, "restore failed for order " + r[1], ex);
                } finally {
                    safeAutoCommit(conn);
                }
            }

            String reverseSql = "SELECT o.order_id, o.order_code, o.customer_id, t.points_delta FROM orders o "
                    + "JOIN loyalty_transactions t ON t.order_id = o.order_id AND t.tx_type = 'EARN' "
                    + "WHERE o.payment_status = 'REFUNDED' "
                    + "AND NOT EXISTS (SELECT 1 FROM loyalty_transactions x WHERE x.order_id = o.order_id AND x.tx_type = 'REVERSE')"
                    + (customerId != null ? " AND o.customer_id = ?" : "");
            List<Object[]> reverses = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(reverseSql)) {
                if (customerId != null) {
                    ps.setLong(1, customerId);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        reverses.add(new Object[]{rs.getLong(1), rs.getString(2), rs.getLong(3), rs.getInt(4)});
                    }
                }
            }
            for (Object[] r : reverses) {
                try {
                    conn.setAutoCommit(false);
                    long[] acc = lockAccount(conn, (Long) r[2]);
                    int earned = (Integer) r[3];
                    int removed = Math.min(earned, (int) acc[1]);       // điểm không bao giờ âm
                    int newCurrent = (int) acc[1] - removed;
                    int newLifetime = Math.max(0, (int) acc[2] - earned);
                    saveBalance(conn, acc[0], newCurrent, newLifetime);
                    insertTx(conn, acc[0], (Long) r[0], -removed, LoyaltyTransaction.REVERSE,
                            "Thu hồi điểm do đơn hàng #" + r[1] + " được hoàn tiền", newCurrent);
                    conn.commit();
                    events.add(new LoyaltyEvent((Long) r[2], "Điểm thưởng bị thu hồi",
                            "Đơn hàng #" + r[1] + " đã hoàn tiền nên " + removed + " điểm đã tích từ đơn này được thu hồi."));
                } catch (SQLException ex) {
                    safeRollback(conn);
                    LOGGER.log(Level.SEVERE, "reverse failed for order " + r[1], ex);
                } finally {
                    safeAutoCommit(conn);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "reconcileCancelledOrders error", ex);
        }
        return events;
    }

    // =====================================================================
    // 7. DÙNG ĐIỂM KHI THANH TOÁN
    // =====================================================================
    /** Thông tin cho khung "Dùng điểm" ở trang thanh toán (chỉ đọc, không đổi dữ liệu điểm). */
    public LoyaltyQuote quote(long customerId, BigDecimal payable) {
        LoyaltyQuote q = new LoyaltyQuote();
        LoyaltyAccount acc = getOrCreateAccount(customerId);
        LoyaltySettings st = getSettings();
        q.setVndPerPoint(st.getRedeemVndPerPoint());
        if (acc == null) {
            q.setCapPercent(st.getMaxRedeemPercent());
            return q;
        }
        int cap = capPercent(acc.getTier(), st);
        q.setBalance(acc.getCurrentPoints());
        q.setCapPercent(cap);
        q.setTierName(acc.getTier() == null ? "" : acc.getTier().getTierName());
        q.setMaxPoints(maxRedeemablePoints(acc.getCurrentPoints(), payable, cap, st.getRedeemVndPerPoint()));
        return q;
    }

    /**
     * Gọi TRONG transaction tạo đơn, trước khi ghi đơn: khóa tài khoản và kiểm tra số điểm muốn dùng.
     *
     * @throws IllegalArgumentException nếu vượt số dư hoặc vượt trần cho phép
     */
    public RedeemPlan lockAndPlanRedeem(Connection conn, long customerId, int points, BigDecimal payable)
            throws SQLException {
        if (points <= 0) {
            return new RedeemPlan(0, BigDecimal.ZERO);
        }
        if (!hasOrderLoyaltyCols(conn)) {
            throw new IllegalStateException(
                    "Cơ sở dữ liệu chưa có cột điểm thưởng. Hãy chạy script 06_loyalty_membership.sql!");
        }
        LoyaltySettings st = readSettings(conn);
        long[] acc = lockAccount(conn, customerId);
        int balance = (int) acc[1];
        MembershipTier tier = tierForLifetime(conn, (int) acc[2]);
        int cap = capPercent(tier, st);
        int max = maxRedeemablePoints(balance, payable, cap, st.getRedeemVndPerPoint());
        if (points > balance) {
            throw new IllegalArgumentException("Bạn chỉ có " + balance + " điểm, không đủ để dùng " + points + " điểm!");
        }
        if (points > max) {
            throw new IllegalArgumentException("Đơn hàng này chỉ được dùng tối đa " + max + " điểm (giới hạn "
                    + cap + "% giá trị đơn)!");
        }
        return new RedeemPlan(points, BigDecimal.valueOf((long) points * st.getRedeemVndPerPoint()));
    }

    /** Gọi TRONG transaction tạo đơn, sau khi đã có order_id: trừ điểm, ghi lịch sử, lưu điểm đã dùng vào đơn. */
    public void commitRedeem(Connection conn, long customerId, long orderId, int points, BigDecimal discount)
            throws SQLException {
        long[] acc = lockAccount(conn, customerId);
        int newCurrent;
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE loyalty_accounts SET current_points = current_points - ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE account_id = ? AND current_points >= ?")) {
            ps.setInt(1, points);
            ps.setLong(2, acc[0]);
            ps.setInt(3, points);
            if (ps.executeUpdate() == 0) {
                throw new IllegalArgumentException("Số dư điểm không đủ để dùng " + points + " điểm!");
            }
            newCurrent = (int) acc[1] - points;
        }
        insertTx(conn, acc[0], orderId, -points, LoyaltyTransaction.REDEEM,
                "Dùng " + points + " điểm cho đơn hàng (giảm " + discount.setScale(0, RoundingMode.HALF_UP).toPlainString() + "đ)",
                newCurrent);
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE orders SET loyalty_points_used = ?, loyalty_discount = ? WHERE order_id = ?")) {
            ps.setInt(1, points);
            ps.setBigDecimal(2, discount);
            ps.setLong(3, orderId);
            ps.executeUpdate();
        }
    }

    private int capPercent(MembershipTier tier, LoyaltySettings st) {
        if (tier != null && tier.getRedeemCapPercent() != null) {
            return tier.getRedeemCapPercent().setScale(0, RoundingMode.FLOOR).intValue();
        }
        return st.getMaxRedeemPercent();
    }

    /** Số điểm tối đa dùng được = min(số dư, trần % giá trị đơn quy ra điểm). */
    public static int maxRedeemablePoints(int balance, BigDecimal payable, int capPercent, int vndPerPoint) {
        if (payable == null || vndPerPoint <= 0 || capPercent <= 0 || balance <= 0) {
            return 0;
        }
        long capDiscount = payable.multiply(BigDecimal.valueOf(capPercent))
                .divideToIntegralValue(BigDecimal.valueOf(100)).longValue();
        long byCap = capDiscount / vndPerPoint;
        return (int) Math.max(0, Math.min(balance, byCap));
    }

    /** Chỉ lưu kết quả "đã có cột"; nếu chưa có thì kiểm tra lại lần sau (chạy script SQL xong không cần khởi động lại). */
    private boolean hasOrderLoyaltyCols(Connection conn) {
        if (Boolean.TRUE.equals(HAS_ORDER_LOYALTY_COLS)) {
            return true;
        }
        try (Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery("SELECT COL_LENGTH('dbo.orders', 'loyalty_points_used')")) {
            boolean exists = rs.next() && rs.getObject(1) != null;
            if (exists) {
                HAS_ORDER_LOYALTY_COLS = true;
            }
            return exists;
        } catch (SQLException ex) {
            return false;
        }
    }

    // =====================================================================
    // 8. ADMIN: tìm khách và điều chỉnh điểm
    // =====================================================================
    public List<Map<String, Object>> searchCustomers(String keyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (keyword == null || keyword.trim().isEmpty()) {
            return list;
        }
        String like = "%" + keyword.trim() + "%";
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 8 u.user_id, u.full_name, u.email, u.phone, COALESCE(a.current_points, 0) AS pts "
                + "FROM users u LEFT JOIN loyalty_accounts a ON a.customer_id = u.user_id "
                + "WHERE u.email LIKE ? OR u.full_name LIKE ? OR u.phone LIKE ? ORDER BY u.full_name")) {
            ps.setNString(1, like);
            ps.setNString(2, like);
            ps.setNString(3, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("userId", rs.getLong("user_id"));
                    m.put("fullName", rs.getString("full_name"));
                    m.put("email", rs.getString("email"));
                    m.put("phone", rs.getString("phone"));
                    m.put("points", rs.getInt("pts"));
                    list.add(m);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "searchCustomers error", ex);
        }
        return list;
    }

    public Map<String, Object> getCustomerBrief(long customerId) {
        Map<String, Object> m = new LinkedHashMap<>();
        Connection conn = getConnection();
        if (conn == null) {
            return m;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(
                "SELECT user_id, full_name, email, phone FROM users WHERE user_id = ?")) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("userId", rs.getLong("user_id"));
                    m.put("fullName", rs.getString("full_name"));
                    m.put("email", rs.getString("email"));
                    m.put("phone", rs.getString("phone"));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getCustomerBrief error", ex);
        }
        return m;
    }

    /**
     * Admin cộng / trừ điểm kèm lý do. Điểm cộng được tính vào tổng tích luỹ; điểm trừ không làm âm số dư.
     *
     * @return số dư mới
     */
    public int adjustPoints(long customerId, int delta, String reason) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try (PreparedStatement chk = conn.prepareStatement("SELECT 1 FROM users WHERE user_id = ?")) {
                chk.setLong(1, customerId);
                try (ResultSet rs = chk.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException("Không tìm thấy khách hàng!");
                    }
                }
            }
            try {
                long[] acc = lockAccount(conn, customerId);
                int newCurrent = (int) acc[1] + delta;
                if (newCurrent < 0) {
                    throw new IllegalArgumentException("Khách chỉ có " + acc[1] + " điểm, không thể trừ " + (-delta) + " điểm!");
                }
                int newLifetime = (int) acc[2] + Math.max(delta, 0);
                saveBalance(conn, acc[0], newCurrent, newLifetime);
                insertTx(conn, acc[0], null, delta, LoyaltyTransaction.ADJUST, "Admin điều chỉnh: " + reason, newCurrent);
                conn.commit();
                return newCurrent;
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
                return 0;
            }
        }
    }

    // =====================================================================
    // Helpers
    // =====================================================================
    private Timestamp parseStart(String value) {
        try {
            return Timestamp.valueOf(value.trim());
        } catch (Exception ex) {
            return new Timestamp(0);
        }
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
        safeRollback(conn);
        if (ex instanceof SQLException) {
            throw (SQLException) ex;
        }
        throw (RuntimeException) ex;
    }

    private void safeRollback(Connection conn) {
        try {
            conn.rollback();
        } catch (SQLException rEx) {
            LOGGER.log(Level.SEVERE, "Rollback failed", rEx);
        }
    }

    private void safeAutoCommit(Connection conn) {
        try {
            conn.setAutoCommit(true);
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Reset auto-commit failed", ex);
        }
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Long) {
                ps.setLong(i + 1, (Long) p);
            } else if (p instanceof Integer) {
                ps.setInt(i + 1, (Integer) p);
            } else if (p instanceof Timestamp) {
                ps.setTimestamp(i + 1, (Timestamp) p);
            } else {
                ps.setString(i + 1, String.valueOf(p));
            }
        }
    }
}
