package dao;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Refund;
import util.DBContext;

/**
 * Hoàn tiền toàn phần / một phần.
 *
 * Quy tắc chung (mọi nguồn hoàn tiền đều đi qua {@link #issue}):
 *  - Chỉ hoàn cho đơn đã thanh toán (orders.payment_status = PAID).
 *  - Tổng tiền hoàn của một sub-order không vượt quá sub_orders.shop_total.
 *  - Hoàn đủ -> sub_orders.status = REFUNDED (trừ sub-order đã CANCELLED).
 *  - Mọi sub-order của đơn đã CANCELLED/REFUNDED hoặc tổng hoàn >= final_amount
 *    -> orders.payment_status = REFUNDED.
 */
public class RefundDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(RefundDAO.class.getName());
    private static final SecureRandom RANDOM = new SecureRandom();

    private static final String SELECT_REFUND
            = "SELECT r.refund_id, r.refund_code, r.order_id, r.sub_order_id, r.shop_id, r.customer_id, "
            + "       r.dispute_id, r.refund_type, r.source, r.amount, r.reason, r.refund_method, r.status, "
            + "       r.processed_by, r.created_at, o.order_code, so.sub_order_code, s.shop_name, "
            + "       u.full_name AS customer_name, a.full_name AS admin_name, d.dispute_code "
            + "FROM refunds r "
            + "JOIN orders o ON o.order_id = r.order_id "
            + "JOIN sub_orders so ON so.sub_order_id = r.sub_order_id "
            + "JOIN shops s ON s.shop_id = r.shop_id "
            + "JOIN users u ON u.user_id = r.customer_id "
            + "LEFT JOIN users a ON a.user_id = r.processed_by "
            + "LEFT JOIN disputes d ON d.dispute_id = r.dispute_id ";

    // =====================================================================
    // 1. Admin tạo khoản hoàn tiền thủ công (hoàn một phần hoặc toàn phần)
    // =====================================================================
    public Refund issueManualRefund(String subOrderCode, BigDecimal amount, String reason, long adminId)
            throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                long subId = findSubOrderId(conn, subOrderCode);
                Refund refund = issue(conn, subId, amount, Refund.SOURCE_MANUAL, reason, null, adminId);
                conn.commit();
                return refund;
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
                return null;
            }
        }
    }

    // =====================================================================
    // 2. Admin phán quyết khiếu nại: hoàn 100% / hoàn một phần / bác bỏ
    // =====================================================================
    /**
     * @param decision REFUND_BUYER | PARTIAL_REFUND | REJECT_CLAIM
     * @param partialAmount bắt buộc khi PARTIAL_REFUND
     * @return khoản hoàn tiền vừa tạo, hoặc null nếu bác bỏ khiếu nại
     */
    public Refund resolveDispute(String disputeCode, String decision, BigDecimal partialAmount,
            String note, long adminId) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                long disputeId;
                long subOrderId;
                long customerId;
                long shopId;
                BigDecimal claim;
                String status;
                String sel = "SELECT dispute_id, sub_order_id, customer_id, shop_id, claim_amount, status "
                        + "FROM disputes WITH (UPDLOCK, ROWLOCK) WHERE dispute_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(sel)) {
                    ps.setString(1, disputeCode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Không tìm thấy khiếu nại " + disputeCode);
                        }
                        disputeId = rs.getLong("dispute_id");
                        subOrderId = rs.getLong("sub_order_id");
                        customerId = rs.getLong("customer_id");
                        shopId = rs.getLong("shop_id");
                        claim = rs.getBigDecimal("claim_amount");
                        status = rs.getString("status");
                    }
                }
                if (!"OPEN".equalsIgnoreCase(status) && !"MEDIATING".equalsIgnoreCase(status)) {
                    throw new IllegalStateException("Khiếu nại này đã được xử lý trước đó!");
                }

                String dec = decision == null ? "" : decision.trim().toUpperCase(Locale.ROOT);
                Refund refund = null;
                String newStatus;
                String cleanNote = (note == null || note.trim().isEmpty()) ? null : note.trim();

                switch (dec) {
                    case "REFUND_BUYER": {
                        BigDecimal remaining = remainingRefundable(conn, subOrderId);
                        if (remaining.signum() <= 0) {
                            throw new IllegalStateException("Sub-order này đã được hoàn tiền đủ trước đó!");
                        }
                        refund = issue(conn, subOrderId, claim.min(remaining), Refund.SOURCE_DISPUTE,
                                "Khiếu nại " + disputeCode + ": hoàn tiền theo phán quyết", disputeId, adminId);
                        newStatus = "REFUNDED_BUYER";
                        break;
                    }
                    case "PARTIAL_REFUND": {
                        if (partialAmount == null || partialAmount.signum() <= 0) {
                            throw new IllegalArgumentException("Vui lòng nhập số tiền hoàn một phần lớn hơn 0!");
                        }
                        if (partialAmount.compareTo(claim) > 0) {
                            throw new IllegalArgumentException(
                                    "Số tiền hoàn không được vượt quá số tiền khách yêu cầu (" + money(claim) + "đ)!");
                        }
                        refund = issue(conn, subOrderId, partialAmount, Refund.SOURCE_DISPUTE,
                                "Khiếu nại " + disputeCode + ": hoàn tiền một phần", disputeId, adminId);
                        newStatus = "REFUNDED_BUYER";
                        break;
                    }
                    case "REJECT_CLAIM":
                        newStatus = "REJECTED";
                        break;
                    default:
                        throw new IllegalArgumentException("Quyết định phán quyết không hợp lệ!");
                }

                String upd = "UPDATE disputes SET status = ?, resolution_decision = ?, resolution_note = ?, "
                        + "resolved_by = ?, resolved_at = CURRENT_TIMESTAMP WHERE dispute_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setString(1, newStatus);
                    ps.setString(2, dec);
                    if (cleanNote == null) {
                        ps.setNull(3, Types.NVARCHAR);
                    } else {
                        ps.setNString(3, cleanNote);
                    }
                    ps.setLong(4, adminId);
                    ps.setLong(5, disputeId);
                    ps.executeUpdate();
                }

                if ("REJECT_CLAIM".equals(dec)) {
                    notifyUser(conn, customerId, "Khiếu nại bị bác bỏ",
                            "Khiếu nại " + disputeCode + " không được chấp thuận. "
                            + (cleanNote != null ? "Lý do: " + cleanNote : ""), "DISPUTE", disputeId);
                    notifyShopOwner(conn, shopId, "Khiếu nại đã được bác bỏ",
                            "Khiếu nại " + disputeCode + " của khách đã bị bác bỏ, bạn không bị trừ tiền.",
                            "DISPUTE", disputeId);
                }
                conn.commit();
                return refund;
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
                return null;
            }
        }
    }

    /** Admin yêu cầu shop giải trình: chuyển khiếu nại sang MEDIATING. */
    public void requestMoreInfo(String disputeCode, String note, long adminId) throws SQLException {
        Connection conn = openTx();
        try (conn) {
            try {
                long disputeId;
                long shopId;
                String sel = "SELECT dispute_id, shop_id FROM disputes WITH (UPDLOCK, ROWLOCK) "
                        + "WHERE dispute_code = ? AND status = 'OPEN'";
                try (PreparedStatement ps = conn.prepareStatement(sel)) {
                    ps.setString(1, disputeCode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalStateException("Chỉ khiếu nại đang ở trạng thái OPEN mới có thể yêu cầu giải trình!");
                        }
                        disputeId = rs.getLong("dispute_id");
                        shopId = rs.getLong("shop_id");
                    }
                }
                String upd = "UPDATE disputes SET status = 'MEDIATING', resolution_note = ? WHERE dispute_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setNString(1, note == null || note.trim().isEmpty()
                            ? "Admin yêu cầu gian hàng bổ sung giải trình." : note.trim());
                    ps.setLong(2, disputeId);
                    ps.executeUpdate();
                }
                notifyShopOwner(conn, shopId, "Yêu cầu giải trình khiếu nại",
                        "Khiếu nại " + disputeCode + ": sàn yêu cầu bạn bổ sung giải trình"
                        + (note == null || note.trim().isEmpty() ? "." : ": " + note.trim()),
                        "DISPUTE", disputeId);
                conn.commit();
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
            }
        }
    }

    // =====================================================================
    // 3. Hoàn tiền toàn phần tự động khi hủy đơn đã thanh toán online
    // =====================================================================
    /**
     * Gọi sau khi hủy đơn thành công. Chỉ hoàn cho sub-order đã CANCELLED thuộc đơn đã thanh
     * toán online và chưa có khoản hoàn nào. Đơn COD chưa thu tiền nên không phát sinh hoàn.
     *
     * @param customerId null khi shop hủy (không lọc theo khách)
     * @param identifier mã sub-order hoặc mã đơn (giống cách OrderDAO.cancelOrderByCustomer tra cứu)
     */
    public List<Refund> autoRefundOnCancel(Long customerId, String identifier) throws SQLException {
        List<Refund> result = new ArrayList<>();
        if (identifier == null || identifier.trim().isEmpty()) {
            return result;
        }
        Connection conn = openTx();
        try (conn) {
            try {
                String id = identifier.trim();
                List<Long> subIds = findSubOrderIds(conn,
                        "(so.sub_order_code = ? OR CAST(so.sub_order_id AS VARCHAR(20)) = ?)", id, customerId);
                if (subIds.isEmpty()) {
                    subIds = findSubOrderIds(conn,
                            "(o.order_code = ? OR CAST(o.order_id AS VARCHAR(20)) = ?)", id, customerId);
                }
                String check = "SELECT 1 FROM sub_orders so JOIN orders o ON o.order_id = so.order_id "
                        + "WHERE so.sub_order_id = ? AND so.status = 'CANCELLED' AND o.payment_status = 'PAID' "
                        + "AND o.payment_method <> 'COD' "
                        + "AND NOT EXISTS (SELECT 1 FROM refunds r WHERE r.sub_order_id = so.sub_order_id)";
                for (long subId : subIds) {
                    boolean eligible;
                    try (PreparedStatement ps = conn.prepareStatement(check)) {
                        ps.setLong(1, subId);
                        try (ResultSet rs = ps.executeQuery()) {
                            eligible = rs.next();
                        }
                    }
                    if (eligible) {
                        Refund r = issue(conn, subId, null, Refund.SOURCE_CANCEL,
                                "Hoàn tiền do hủy đơn hàng", null, null);
                        if (r != null) {
                            result.add(r);
                        }
                    }
                }
                conn.commit();
                return result;
            } catch (Exception ex) {
                rollbackThenRethrow(conn, ex);
                return result;
            }
        }
    }

    // =====================================================================
    // Lõi hoàn tiền
    // =====================================================================
    /**
     * Ghi một khoản hoàn tiền trong transaction của người gọi.
     *
     * @param requestedAmount null = hoàn toàn bộ phần còn lại (bỏ qua với nguồn CANCEL, tự tính)
     * @param adminId null = hệ thống tự động
     * @return khoản hoàn vừa ghi, hoặc null nếu không có gì để hoàn (CANCEL mà khách trả 0đ)
     */
    private Refund issue(Connection conn, long subOrderId, BigDecimal requestedAmount, String source,
            String reason, Long disputeId, Long adminId) throws SQLException {

        long orderId;
        long shopId;
        long customerId;
        String orderCode;
        String subCode;
        String subStatus;
        String payStatus;
        String payMethod;
        BigDecimal shopTotal;
        BigDecimal platformDiscount;

        String sel = "SELECT so.sub_order_code, so.order_id, so.shop_id, so.shop_total, so.status AS sub_status, "
                + "o.order_code, o.customer_id, o.platform_discount, o.payment_status, o.payment_method "
                + "FROM sub_orders so JOIN orders o WITH (UPDLOCK, ROWLOCK) ON o.order_id = so.order_id "
                + "WHERE so.sub_order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sel)) {
            ps.setLong(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("Không tìm thấy đơn hàng cần hoàn tiền!");
                }
                subCode = rs.getString("sub_order_code");
                orderId = rs.getLong("order_id");
                shopId = rs.getLong("shop_id");
                shopTotal = rs.getBigDecimal("shop_total");
                subStatus = rs.getString("sub_status");
                orderCode = rs.getString("order_code");
                customerId = rs.getLong("customer_id");
                platformDiscount = rs.getBigDecimal("platform_discount");
                payStatus = rs.getString("payment_status");
                payMethod = rs.getString("payment_method");
            }
        }

        if (!"PAID".equalsIgnoreCase(payStatus)) {
            throw new IllegalStateException("Đơn hàng " + orderCode + " chưa thanh toán thành công nên không thể hoàn tiền!");
        }

        BigDecimal refundedBefore = sumRefunds(conn, "sub_order_id", subOrderId);
        BigDecimal remaining = shopTotal.subtract(refundedBefore);
        BigDecimal amount;

        if (Refund.SOURCE_CANCEL.equals(source)) {
            if (!"CANCELLED".equalsIgnoreCase(subStatus) || refundedBefore.signum() > 0) {
                return null;
            }
            // Khách chỉ được hoàn số tiền thực trả: trừ phần voucher sàn tài trợ theo tỉ lệ sub-order.
            BigDecimal orderTotal = sumShopTotals(conn, orderId);
            amount = shopTotal;
            if (platformDiscount != null && platformDiscount.signum() > 0 && orderTotal.signum() > 0) {
                amount = shopTotal.subtract(platformDiscount.multiply(shopTotal)
                        .divide(orderTotal, 0, RoundingMode.HALF_UP));
            }
            if (amount.signum() <= 0) {
                return null;
            }
        } else {
            if ("CANCELLED".equalsIgnoreCase(subStatus) || "REFUNDED".equalsIgnoreCase(subStatus)) {
                throw new IllegalStateException("Đơn " + subCode + " đã hủy hoặc đã hoàn tiền, không thể hoàn thêm!");
            }
            if (remaining.signum() <= 0) {
                throw new IllegalStateException("Đơn " + subCode + " đã được hoàn tiền đủ!");
            }
            amount = requestedAmount == null ? remaining : requestedAmount;
            if (amount.signum() <= 0) {
                throw new IllegalArgumentException("Số tiền hoàn phải lớn hơn 0!");
            }
            if (amount.compareTo(remaining) > 0) {
                throw new IllegalArgumentException("Số tiền hoàn vượt quá mức còn hoàn được của đơn "
                        + subCode + " (tối đa " + money(remaining) + "đ)!");
            }
        }

        boolean full = Refund.SOURCE_CANCEL.equals(source)
                || refundedBefore.add(amount).compareTo(shopTotal) >= 0;
        String type = full ? Refund.TYPE_FULL : Refund.TYPE_PARTIAL;
        String method = "COD".equalsIgnoreCase(payMethod) ? "BANK_TRANSFER" : payMethod;
        String code = "RF-" + new SimpleDateFormat("yyMMddHHmmss").format(new Date())
                + String.format("%03d", RANDOM.nextInt(1000));

        long refundId = -1;
        String ins = "INSERT INTO refunds (refund_code, order_id, sub_order_id, shop_id, customer_id, dispute_id, "
                + "refund_type, source, amount, reason, refund_method, status, processed_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'COMPLETED', ?)";
        try (PreparedStatement ps = conn.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, code);
            ps.setLong(2, orderId);
            ps.setLong(3, subOrderId);
            ps.setLong(4, shopId);
            ps.setLong(5, customerId);
            if (disputeId == null) {
                ps.setNull(6, Types.BIGINT);
            } else {
                ps.setLong(6, disputeId);
            }
            ps.setString(7, type);
            ps.setString(8, source);
            ps.setBigDecimal(9, amount);
            ps.setNString(10, reason);
            ps.setString(11, method);
            if (adminId == null) {
                ps.setNull(12, Types.BIGINT);
            } else {
                ps.setLong(12, adminId);
            }
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    refundId = rs.getLong(1);
                }
            }
        }

        // Hoàn đủ -> sub-order sang REFUNDED (sub-order đã hủy giữ nguyên CANCELLED).
        if (full && !"CANCELLED".equalsIgnoreCase(subStatus)) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE sub_orders SET status = 'REFUNDED', updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = ?")) {
                ps.setLong(1, subOrderId);
                ps.executeUpdate();
            }
        }

        // Cập nhật trạng thái thanh toán của đơn cha.
        String updOrder = "UPDATE orders SET payment_status = 'REFUNDED', updated_at = CURRENT_TIMESTAMP "
                + "WHERE order_id = ? AND payment_status = 'PAID' AND ("
                + "(SELECT COALESCE(SUM(amount), 0) FROM refunds WHERE order_id = ? AND status = 'COMPLETED') >= final_amount "
                + "OR NOT EXISTS (SELECT 1 FROM sub_orders WHERE order_id = ? AND status NOT IN ('CANCELLED', 'REFUNDED')))";
        try (PreparedStatement ps = conn.prepareStatement(updOrder)) {
            ps.setLong(1, orderId);
            ps.setLong(2, orderId);
            ps.setLong(3, orderId);
            ps.executeUpdate();
        }

        notifyUser(conn, customerId, "Hoàn tiền thành công",
                "Đơn hàng #" + orderCode + " được hoàn " + money(amount) + "đ về "
                + methodLabel(method) + ". Mã hoàn tiền: " + code + ".", "REFUND", refundId);
        if (!Refund.SOURCE_CANCEL.equals(source)) {
            notifyShopOwner(conn, shopId, "Khoản hoàn tiền cho khách",
                    "Đơn " + subCode + " đã hoàn " + money(amount)
                    + "đ cho khách, khoản này sẽ được trừ vào kỳ quyết toán gần nhất.", "REFUND", refundId);
        }

        Refund r = new Refund();
        r.setRefundId(refundId);
        r.setRefundCode(code);
        r.setOrderId(orderId);
        r.setOrderCode(orderCode);
        r.setSubOrderId(subOrderId);
        r.setSubOrderCode(subCode);
        r.setShopId(shopId);
        r.setCustomerId(customerId);
        r.setRefundType(type);
        r.setSource(source);
        r.setAmount(amount);
        r.setReason(reason);
        r.setRefundMethod(method);
        r.setStatus("COMPLETED");
        return r;
    }

    // =====================================================================
    // Truy vấn danh sách
    // =====================================================================
    public List<Refund> search(String keyword, String source, int page, int pageSize) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(keyword, source, params);
        String sql = SELECT_REFUND + where
                + " ORDER BY r.created_at DESC, r.refund_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(Math.max(0, page - 1) * pageSize);
        params.add(pageSize);

        List<Refund> list = new ArrayList<>();
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
            LOGGER.log(Level.SEVERE, "search refunds error", ex);
        }
        return list;
    }

    public int count(String keyword, String source) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(keyword, source, params);
        String sql = "SELECT COUNT(*) FROM refunds r JOIN orders o ON o.order_id = r.order_id "
                + "JOIN sub_orders so ON so.sub_order_id = r.sub_order_id JOIN shops s ON s.shop_id = r.shop_id "
                + "JOIN users u ON u.user_id = r.customer_id " + where;
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
            LOGGER.log(Level.SEVERE, "count refunds error", ex);
            return 0;
        }
    }

    public Map<String, Object> getSummary() {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("totalAmount", BigDecimal.ZERO);
        m.put("totalCount", 0);
        m.put("partialCount", 0);
        m.put("disputeCount", 0);
        m.put("cancelCount", 0);
        String sql = "SELECT COUNT(*) AS cnt, COALESCE(SUM(amount), 0) AS total, "
                + "SUM(CASE WHEN refund_type = 'PARTIAL' THEN 1 ELSE 0 END) AS partial_cnt, "
                + "SUM(CASE WHEN source = 'DISPUTE' THEN 1 ELSE 0 END) AS dispute_cnt, "
                + "SUM(CASE WHEN source = 'CANCEL' THEN 1 ELSE 0 END) AS cancel_cnt "
                + "FROM refunds WHERE status = 'COMPLETED'";
        Connection conn = getConnection();
        if (conn == null) {
            return m;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                m.put("totalAmount", rs.getBigDecimal("total"));
                m.put("totalCount", rs.getInt("cnt"));
                m.put("partialCount", rs.getInt("partial_cnt"));
                m.put("disputeCount", rs.getInt("dispute_cnt"));
                m.put("cancelCount", rs.getInt("cancel_cnt"));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "refund summary error", ex);
        }
        return m;
    }

    /** Khiếu nại đang chờ Admin phán quyết (OPEN / MEDIATING). */
    public List<Map<String, Object>> listPendingDisputes() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT d.dispute_code, d.reason_category, d.claim_amount, d.status, d.created_at, "
                + "u.full_name AS customer_name, s.shop_name, o.order_code, so.sub_order_code, "
                + "so.shop_total - COALESCE((SELECT SUM(r.amount) FROM refunds r "
                + "     WHERE r.sub_order_id = so.sub_order_id AND r.status = 'COMPLETED'), 0) AS refundable "
                + "FROM disputes d "
                + "JOIN users u ON u.user_id = d.customer_id "
                + "JOIN shops s ON s.shop_id = d.shop_id "
                + "JOIN sub_orders so ON so.sub_order_id = d.sub_order_id "
                + "JOIN orders o ON o.order_id = so.order_id "
                + "WHERE d.status IN ('OPEN', 'MEDIATING') ORDER BY d.created_at";
        Connection conn = getConnection();
        if (conn == null) {
            return list;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("code", rs.getString("dispute_code"));
                m.put("reason", rs.getString("reason_category"));
                m.put("claim", rs.getBigDecimal("claim_amount"));
                m.put("status", rs.getString("status"));
                m.put("createdAt", rs.getTimestamp("created_at"));
                m.put("customer", rs.getString("customer_name"));
                m.put("shop", rs.getString("shop_name"));
                m.put("orderCode", rs.getString("order_code"));
                m.put("subOrderCode", rs.getString("sub_order_code"));
                m.put("refundable", rs.getBigDecimal("refundable"));
                list.add(m);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "pending disputes error", ex);
        }
        return list;
    }

    // =====================================================================
    // Helpers
    // =====================================================================
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

    private long findSubOrderId(Connection conn, String subOrderCode) throws SQLException {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập mã đơn hàng cần hoàn tiền!");
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT sub_order_id FROM sub_orders WHERE sub_order_code = ?")) {
            ps.setString(1, subOrderCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("Không tìm thấy mã đơn con " + subOrderCode.trim()
                            + " (ví dụ: SUB-8821-1)");
                }
                return rs.getLong(1);
            }
        }
    }

    private List<Long> findSubOrderIds(Connection conn, String condition, String identifier, Long customerId)
            throws SQLException {
        String sql = "SELECT so.sub_order_id FROM sub_orders so JOIN orders o ON o.order_id = so.order_id WHERE "
                + condition + (customerId != null ? " AND o.customer_id = ?" : "");
        List<Long> ids = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            if (customerId != null) {
                ps.setLong(3, customerId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getLong(1));
                }
            }
        }
        return ids;
    }

    private BigDecimal remainingRefundable(Connection conn, long subOrderId) throws SQLException {
        BigDecimal total;
        try (PreparedStatement ps = conn.prepareStatement("SELECT shop_total FROM sub_orders WHERE sub_order_id = ?")) {
            ps.setLong(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("Không tìm thấy đơn hàng của khiếu nại!");
                }
                total = rs.getBigDecimal(1);
            }
        }
        return total.subtract(sumRefunds(conn, "sub_order_id", subOrderId));
    }

    private BigDecimal sumRefunds(Connection conn, String column, long id) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COALESCE(SUM(amount), 0) FROM refunds WHERE " + column + " = ? AND status = 'COMPLETED'")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    private BigDecimal sumShopTotals(Connection conn, long orderId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COALESCE(SUM(shop_total), 0) FROM sub_orders WHERE order_id = ?")) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    private String buildWhere(String keyword, String source, List<Object> params) {
        StringBuilder sb = new StringBuilder(" WHERE 1=1");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sb.append(" AND (r.refund_code LIKE ? OR o.order_code LIKE ? OR so.sub_order_code LIKE ? "
                    + "OR u.full_name LIKE ? OR s.shop_name LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            for (int i = 0; i < 5; i++) {
                params.add(like);
            }
        }
        if (source != null && !source.isEmpty() && !"ALL".equalsIgnoreCase(source)) {
            sb.append(" AND r.source = ?");
            params.add(source.toUpperCase(Locale.ROOT));
        }
        return sb.toString();
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof Integer) {
                ps.setInt(i + 1, (Integer) p);
            } else {
                ps.setNString(i + 1, String.valueOf(p));
            }
        }
    }

    private Refund map(ResultSet rs) throws SQLException {
        Refund r = new Refund();
        r.setRefundId(rs.getLong("refund_id"));
        r.setRefundCode(rs.getString("refund_code"));
        r.setOrderId(rs.getLong("order_id"));
        r.setOrderCode(rs.getString("order_code"));
        r.setSubOrderId(rs.getLong("sub_order_id"));
        r.setSubOrderCode(rs.getString("sub_order_code"));
        r.setShopId(rs.getLong("shop_id"));
        r.setShopName(rs.getString("shop_name"));
        r.setCustomerId(rs.getLong("customer_id"));
        r.setCustomerName(rs.getString("customer_name"));
        long disputeId = rs.getLong("dispute_id");
        r.setDisputeId(rs.wasNull() ? null : disputeId);
        r.setDisputeCode(rs.getString("dispute_code"));
        r.setRefundType(rs.getString("refund_type"));
        r.setSource(rs.getString("source"));
        r.setAmount(rs.getBigDecimal("amount"));
        r.setReason(rs.getString("reason"));
        r.setRefundMethod(rs.getString("refund_method"));
        r.setStatus(rs.getString("status"));
        long processedBy = rs.getLong("processed_by");
        r.setProcessedBy(rs.wasNull() ? null : processedBy);
        r.setProcessedByName(rs.getString("admin_name"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }

    private void notifyUser(Connection conn, long userId, String title, String message, String refType, long refId)
            throws SQLException {
        String sql = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setNString(2, title);
            ps.setNString(3, message);
            ps.setString(4, "DISPUTE".equals(refType) ? "DISPUTE" : "ORDER");
            ps.setString(5, refType);
            ps.setLong(6, refId);
            ps.executeUpdate();
        }
    }

    private void notifyShopOwner(Connection conn, long shopId, String title, String message, String refType, long refId)
            throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT owner_id FROM shops WHERE shop_id = ?")) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    notifyUser(conn, rs.getLong(1), title, message, refType, refId);
                }
            }
        }
    }

    private String money(BigDecimal v) {
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(v.setScale(0, RoundingMode.HALF_UP));
    }

    private String methodLabel(String method) {
        if ("VNPAY".equalsIgnoreCase(method)) {
            return "VNPay (phương thức thanh toán gốc)";
        }
        if ("BANK_TRANSFER".equalsIgnoreCase(method)) {
            return "tài khoản ngân hàng";
        }
        return method;
    }
}
