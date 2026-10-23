package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Payment;
import model.PaymentStats;
import util.DBContext;

/**
 * Truy cập dữ liệu thanh toán (bảng payments, đồng bộ với orders và notifications).
 *
 * Vòng đời một giao dịch online:
 *   PENDING --(cổng báo thành công)--> SUCCESS  (orders: PAID + CONFIRMED)
 *   PENDING --(thất bại / hủy / hết hạn)--> FAILED (orders: payment_status FAILED, order vẫn PENDING)
 * Thanh toán lại sẽ tạo một dòng payments mới, các dòng cũ giữ nguyên làm lịch sử.
 */
public class PaymentDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(PaymentDAO.class.getName());

    private static final String SELECT_PAYMENT
            = "SELECT p.payment_id, p.order_id, p.payment_provider, p.payment_type, p.transaction_code, "
            + "       p.amount, p.payment_status, p.failure_reason, p.created_at, p.paid_at, "
            + "       o.order_code, o.customer_id, o.order_status, o.payment_status AS order_payment_status, "
            + "       u.full_name AS customer_name, "
            + "       (SELECT COALESCE(SUM(r.amount), 0) FROM refunds r "
            + "        WHERE r.order_id = p.order_id AND r.status = 'COMPLETED') AS refunded_amount, "
            + "       STUFF((SELECT ', ' + oi.product_name_snapshot "
            + "              FROM sub_orders so JOIN order_items oi ON oi.sub_order_id = so.sub_order_id "
            + "              WHERE so.order_id = p.order_id "
            + "              FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS item_summary "
            + "FROM payments p "
            + "JOIN orders o ON o.order_id = p.order_id "
            + "JOIN users u ON u.user_id = o.customer_id ";

    // =====================================================================
    // 1. KHỞI TẠO GIAO DỊCH (System: Initialize payment transaction)
    // =====================================================================
    /**
     * Tạo (hoặc tái sử dụng) bản ghi giao dịch PENDING cho đơn hàng đang chờ thanh toán.
     *
     * @throws IllegalArgumentException nếu đơn không tồn tại / không thuộc khách
     * @throws IllegalStateException nếu đơn không còn ở trạng thái chờ thanh toán
     */
    public Payment initiateTransaction(long orderId, long customerId, String provider, String transactionCode)
            throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }
        try (conn) {
            conn.setAutoCommit(false);
            try {
                String orderCode;
                BigDecimal amount;
                String orderStatus;
                String orderPaymentStatus;

                String lockSql = "SELECT order_code, final_amount, order_status, payment_status "
                        + "FROM orders WITH (UPDLOCK, ROWLOCK) WHERE order_id = ? AND customer_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                    ps.setLong(1, orderId);
                    ps.setLong(2, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Không tìm thấy đơn hàng cần thanh toán!");
                        }
                        orderCode = rs.getString("order_code");
                        amount = rs.getBigDecimal("final_amount");
                        orderStatus = rs.getString("order_status");
                        orderPaymentStatus = rs.getString("payment_status");
                    }
                }
                if (!"PENDING".equalsIgnoreCase(orderStatus) || "PAID".equalsIgnoreCase(orderPaymentStatus)) {
                    throw new IllegalStateException("Đơn hàng này không còn ở trạng thái chờ thanh toán!");
                }

                // Các lần thử cũ đã chuyển sang cổng nhưng khách bỏ dở -> đóng lại, giữ làm lịch sử.
                String closeStaleSql = "UPDATE payments SET payment_status = 'FAILED', "
                        + "failure_reason = ? WHERE order_id = ? AND payment_status = 'PENDING' "
                        + "AND transaction_code IS NOT NULL";
                try (PreparedStatement ps = conn.prepareStatement(closeStaleSql)) {
                    ps.setNString(1, "Giao dịch cũ bị thay thế bởi lần thanh toán mới");
                    ps.setLong(2, orderId);
                    ps.executeUpdate();
                }

                // Dòng PENDING do lúc đặt hàng tạo ra (chưa có mã giao dịch) -> dùng lại.
                long paymentId = -1;
                String findSql = "SELECT TOP 1 payment_id FROM payments WHERE order_id = ? "
                        + "AND payment_status = 'PENDING' AND transaction_code IS NULL ORDER BY payment_id DESC";
                try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                    ps.setLong(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            paymentId = rs.getLong(1);
                        }
                    }
                }

                if (paymentId > 0) {
                    String updSql = "UPDATE payments SET payment_provider = ?, payment_type = 'ONLINE', "
                            + "transaction_code = ?, amount = ? WHERE payment_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updSql)) {
                        ps.setString(1, provider);
                        ps.setString(2, transactionCode);
                        ps.setBigDecimal(3, amount);
                        ps.setLong(4, paymentId);
                        ps.executeUpdate();
                    }
                } else {
                    String insSql = "INSERT INTO payments (order_id, payment_provider, payment_type, "
                            + "transaction_code, amount, payment_status) VALUES (?, ?, 'ONLINE', ?, ?, 'PENDING')";
                    try (PreparedStatement ps = conn.prepareStatement(insSql, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setLong(1, orderId);
                        ps.setString(2, provider);
                        ps.setString(3, transactionCode);
                        ps.setBigDecimal(4, amount);
                        ps.executeUpdate();
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (rs.next()) {
                                paymentId = rs.getLong(1);
                            }
                        }
                    }
                }

                String ordSql = "UPDATE orders SET payment_status = 'PENDING', payment_method = ?, "
                        + "updated_at = CURRENT_TIMESTAMP WHERE order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(ordSql)) {
                    ps.setString(1, provider);
                    ps.setLong(2, orderId);
                    ps.executeUpdate();
                }

                conn.commit();

                Payment payment = new Payment();
                payment.setPaymentId(paymentId);
                payment.setOrderId(orderId);
                payment.setOrderCode(orderCode);
                payment.setCustomerId(customerId);
                payment.setPaymentProvider(provider);
                payment.setPaymentType("ONLINE");
                payment.setTransactionCode(transactionCode);
                payment.setAmount(amount);
                payment.setPaymentStatus(Payment.STATUS_PENDING);
                return payment;
            } catch (Exception ex) {
                rollbackQuietly(conn);
                if (ex instanceof SQLException) {
                    throw (SQLException) ex;
                }
                throw (RuntimeException) ex;
            }
        }
    }

    // =====================================================================
    // 2. XÁC NHẬN KẾT QUẢ (System: Update payment status & record history)
    // =====================================================================
    /**
     * Ghi nhận thanh toán thành công: payments SUCCESS, orders PAID + CONFIRMED,
     * thông báo cho chủ shop và khách hàng. Chỉ xử lý được 1 lần cho mỗi giao dịch.
     *
     * @return false nếu giao dịch không còn ở trạng thái PENDING (đã xử lý rồi)
     */
    public boolean markSuccess(String transactionCode) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn) {
            conn.setAutoCommit(false);
            try {
                long orderId;
                long customerId;
                String orderCode;
                BigDecimal amount;

                String updPay = "UPDATE payments SET payment_status = 'SUCCESS', failure_reason = NULL, "
                        + "paid_at = CURRENT_TIMESTAMP WHERE transaction_code = ? AND payment_status = 'PENDING'";
                try (PreparedStatement ps = conn.prepareStatement(updPay)) {
                    ps.setString(1, transactionCode);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                String info = "SELECT p.order_id, p.amount, o.customer_id, o.order_code FROM payments p "
                        + "JOIN orders o ON o.order_id = p.order_id WHERE p.transaction_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(info)) {
                    ps.setString(1, transactionCode);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        orderId = rs.getLong("order_id");
                        amount = rs.getBigDecimal("amount");
                        customerId = rs.getLong("customer_id");
                        orderCode = rs.getString("order_code");
                    }
                }

                String updOrd = "UPDATE orders SET payment_status = 'PAID', "
                        + "order_status = CASE WHEN order_status = 'PENDING' THEN 'CONFIRMED' ELSE order_status END, "
                        + "updated_at = CURRENT_TIMESTAMP WHERE order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updOrd)) {
                    ps.setLong(1, orderId);
                    ps.executeUpdate();
                }

                // Báo cho chủ shop: đơn đã được thanh toán, có thể chuẩn bị hàng.
                String shopSql = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id) "
                        + "SELECT DISTINCT s.owner_id, ?, ?, 'ORDER', 'ORDER', ? "
                        + "FROM sub_orders so JOIN shops s ON s.shop_id = so.shop_id WHERE so.order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(shopSql)) {
                    ps.setNString(1, "Đơn hàng mới đã thanh toán");
                    ps.setNString(2, "Đơn hàng #" + orderCode + " đã được thanh toán online ("
                            + amount.setScale(0, java.math.RoundingMode.HALF_UP).toPlainString()
                            + "đ). Vui lòng xác nhận và chuẩn bị hàng.");
                    ps.setLong(3, orderId);
                    ps.setLong(4, orderId);
                    ps.executeUpdate();
                }

                insertNotification(conn, customerId, "Thanh toán thành công",
                        "Đơn hàng #" + orderCode + " đã được thanh toán thành công. Nhà vườn đang chuẩn bị hàng cho bạn.",
                        orderId);

                conn.commit();
                return true;
            } catch (Exception ex) {
                rollbackQuietly(conn);
                LOGGER.log(Level.SEVERE, "markSuccess failed for " + transactionCode, ex);
                return false;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "markSuccess connection error", ex);
            return false;
        }
    }

    /**
     * Ghi nhận thanh toán thất bại: payments FAILED (kèm lý do), orders.payment_status = FAILED,
     * đơn vẫn PENDING để khách thanh toán lại hoặc hủy. Thông báo cho khách.
     *
     * @return false nếu giao dịch không còn PENDING
     */
    public boolean markFailed(String transactionCode, String reason) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }
        try (conn) {
            conn.setAutoCommit(false);
            try {
                String updPay = "UPDATE payments SET payment_status = 'FAILED', failure_reason = ? "
                        + "WHERE transaction_code = ? AND payment_status = 'PENDING'";
                try (PreparedStatement ps = conn.prepareStatement(updPay)) {
                    ps.setNString(1, reason);
                    ps.setString(2, transactionCode);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                long orderId;
                long customerId;
                String orderCode;
                String info = "SELECT p.order_id, o.customer_id, o.order_code FROM payments p "
                        + "JOIN orders o ON o.order_id = p.order_id WHERE p.transaction_code = ?";
                try (PreparedStatement ps = conn.prepareStatement(info)) {
                    ps.setString(1, transactionCode);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        orderId = rs.getLong("order_id");
                        customerId = rs.getLong("customer_id");
                        orderCode = rs.getString("order_code");
                    }
                }

                String updOrd = "UPDATE orders SET payment_status = 'FAILED', updated_at = CURRENT_TIMESTAMP "
                        + "WHERE order_id = ? AND order_status = 'PENDING' AND payment_status <> 'PAID'";
                try (PreparedStatement ps = conn.prepareStatement(updOrd)) {
                    ps.setLong(1, orderId);
                    ps.executeUpdate();
                }

                insertNotification(conn, customerId, "Thanh toán không thành công",
                        "Thanh toán đơn hàng #" + orderCode + " chưa hoàn tất: " + reason
                        + ". Bạn có thể thanh toán lại hoặc hủy đơn.", orderId);

                conn.commit();
                return true;
            } catch (Exception ex) {
                rollbackQuietly(conn);
                LOGGER.log(Level.SEVERE, "markFailed failed for " + transactionCode, ex);
                return false;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "markFailed connection error", ex);
            return false;
        }
    }

    /** Đóng mọi giao dịch đang chờ của đơn (dùng khi khách hủy đơn chưa thanh toán). */
    public void failPendingForOrder(long orderId, String reason) {
        Connection conn = getConnection();
        if (conn == null) {
            return;
        }
        try (conn) {
            String sqlPay = "UPDATE payments SET payment_status = 'FAILED', failure_reason = ? "
                    + "WHERE order_id = ? AND payment_status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(sqlPay)) {
                ps.setNString(1, reason);
                ps.setLong(2, orderId);
                ps.executeUpdate();
            }
            String sqlOrd = "UPDATE orders SET payment_status = 'FAILED', updated_at = CURRENT_TIMESTAMP "
                    + "WHERE order_id = ? AND payment_status <> 'PAID'";
            try (PreparedStatement ps = conn.prepareStatement(sqlOrd)) {
                ps.setLong(1, orderId);
                ps.executeUpdate();
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "failPendingForOrder error, orderId=" + orderId, ex);
        }
    }

    // =====================================================================
    // 3. TRUY VẤN (Track payment status / View payment history)
    // =====================================================================
    // =====================================================================
    // 2b. THANH TOÁN LẠI BẰNG PHƯƠNG THỨC KHÁC: chuyển đơn online chưa trả tiền sang COD
    // =====================================================================
    /**
     * Khách đổi sang thanh toán khi nhận hàng cho đơn đang chờ thanh toán online
     * (lỗi / tự hủy / hết hạn). Giữ nguyên đơn và giỏ hàng, không phải đặt lại.
     * payments: đóng các lần online còn treo, tạo dòng COD mới; orders: COD + CONFIRMED;
     * thông báo cho chủ shop vì đơn bắt đầu hiện trong danh sách xử lý của shop.
     *
     * @return mã đơn hàng
     */
    public String switchToCod(long orderId, long customerId) throws SQLException {
        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu!");
        }
        try (conn) {
            conn.setAutoCommit(false);
            try {
                String orderCode;
                BigDecimal amount;
                String orderStatus;
                String orderPaymentStatus;
                String lockSql = "SELECT order_code, final_amount, order_status, payment_status "
                        + "FROM orders WITH (UPDLOCK, ROWLOCK) WHERE order_id = ? AND customer_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                    ps.setLong(1, orderId);
                    ps.setLong(2, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Không tìm thấy đơn hàng cần thanh toán!");
                        }
                        orderCode = rs.getString("order_code");
                        amount = rs.getBigDecimal("final_amount");
                        orderStatus = rs.getString("order_status");
                        orderPaymentStatus = rs.getString("payment_status");
                    }
                }
                if (!"PENDING".equalsIgnoreCase(orderStatus) || "PAID".equalsIgnoreCase(orderPaymentStatus)) {
                    throw new IllegalStateException("Đơn hàng này không còn ở trạng thái chờ thanh toán!");
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE payments SET payment_status = 'FAILED', failure_reason = ? "
                        + "WHERE order_id = ? AND payment_status = 'PENDING'")) {
                    ps.setNString(1, "Khách đổi sang thanh toán khi nhận hàng (COD)");
                    ps.setLong(2, orderId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO payments (order_id, payment_provider, payment_type, amount, payment_status) "
                        + "VALUES (?, 'COD', 'CASH', ?, 'PENDING')")) {
                    ps.setLong(1, orderId);
                    ps.setBigDecimal(2, amount);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE orders SET payment_method = 'COD', payment_status = 'PENDING', "
                        + "order_status = 'CONFIRMED', updated_at = CURRENT_TIMESTAMP WHERE order_id = ?")) {
                    ps.setLong(1, orderId);
                    ps.executeUpdate();
                }

                String shopSql = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id) "
                        + "SELECT DISTINCT s.owner_id, ?, ?, 'ORDER', 'ORDER', ? "
                        + "FROM sub_orders so JOIN shops s ON s.shop_id = so.shop_id WHERE so.order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(shopSql)) {
                    ps.setNString(1, "Đơn hàng mới (COD)");
                    ps.setNString(2, "Đơn hàng #" + orderCode + " thanh toán khi nhận hàng. Vui lòng xác nhận và chuẩn bị hàng.");
                    ps.setLong(3, orderId);
                    ps.setLong(4, orderId);
                    ps.executeUpdate();
                }
                conn.commit();
                return orderCode;
            } catch (Exception ex) {
                rollbackQuietly(conn);
                if (ex instanceof SQLException) {
                    throw (SQLException) ex;
                }
                throw (RuntimeException) ex;
            }
        }
    }

    public Payment findByTransactionCode(String transactionCode) {
        return findOne(SELECT_PAYMENT + "WHERE p.transaction_code = ?", transactionCode);
    }

    /** Lần thanh toán gần nhất của một đơn hàng. */
    public Payment findLatestByOrderId(long orderId) {
        return findOne(SELECT_PAYMENT + "WHERE p.order_id = ? ORDER BY p.payment_id DESC", orderId);
    }

    public List<Payment> search(Long customerId, String keyword, String provider, String status,
            int days, int page, int pageSize) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(customerId, keyword, provider, status, days, params);
        String sql = SELECT_PAYMENT + where
                + " ORDER BY p.created_at DESC, p.payment_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(Math.max(0, (page - 1)) * pageSize);
        params.add(pageSize);

        List<Payment> list = new ArrayList<>();
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
            LOGGER.log(Level.SEVERE, "search payments error", ex);
        }
        return list;
    }

    public int count(Long customerId, String keyword, String provider, String status, int days) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(customerId, keyword, provider, status, days, params);
        String sql = "SELECT COUNT(*) FROM payments p JOIN orders o ON o.order_id = p.order_id "
                + "JOIN users u ON u.user_id = o.customer_id " + where;
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
            LOGGER.log(Level.SEVERE, "count payments error", ex);
            return 0;
        }
    }

    /** customerId = null để thống kê toàn sàn (Admin). */
    public PaymentStats getStats(Long customerId) {
        PaymentStats stats = new PaymentStats();
        String sql = "SELECT COUNT(*) AS total_cnt, "
                + "SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS success_cnt, "
                + "SUM(CASE WHEN p.payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_cnt, "
                + "SUM(CASE WHEN p.payment_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_cnt, "
                + "SUM(CASE WHEN p.payment_provider = 'COD' THEN 1 ELSE 0 END) AS cod_cnt, "
                + "SUM(CASE WHEN p.payment_provider <> 'COD' THEN 1 ELSE 0 END) AS online_cnt, "
                + "COALESCE(SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.amount END), 0) AS paid_amount, "
                + "COALESCE(SUM(CASE WHEN p.payment_status = 'PENDING' THEN p.amount END), 0) AS pending_amount "
                + "FROM payments p JOIN orders o ON o.order_id = p.order_id"
                + (customerId != null ? " WHERE o.customer_id = ?" : "");
        Connection conn = getConnection();
        if (conn == null) {
            return stats;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            if (customerId != null) {
                ps.setLong(1, customerId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setTotalCount(rs.getInt("total_cnt"));
                    stats.setSuccessCount(rs.getInt("success_cnt"));
                    stats.setPendingCount(rs.getInt("pending_cnt"));
                    stats.setFailedCount(rs.getInt("failed_cnt"));
                    stats.setCodCount(rs.getInt("cod_cnt"));
                    stats.setOnlineCount(rs.getInt("online_cnt"));
                    stats.setTotalPaidAmount(rs.getBigDecimal("paid_amount"));
                    stats.setTotalPendingAmount(rs.getBigDecimal("pending_amount"));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getStats payments error", ex);
        }
        return stats;
    }

    // =====================================================================
    // Helpers
    // =====================================================================
    private String buildWhere(Long customerId, String keyword, String provider, String status,
            int days, List<Object> params) {
        StringBuilder sb = new StringBuilder(" WHERE 1=1");
        if (customerId != null) {
            sb.append(" AND o.customer_id = ?");
            params.add(customerId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.trim();
            if (kw.startsWith("#")) {
                kw = kw.substring(1);
            }
            sb.append(" AND (p.transaction_code LIKE ? OR o.order_code LIKE ? OR u.full_name LIKE ?)");
            String like = "%" + kw + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (provider != null && !provider.isEmpty() && !"ALL".equalsIgnoreCase(provider)) {
            if ("ONLINE".equalsIgnoreCase(provider)) {
                sb.append(" AND p.payment_provider <> 'COD'");
            } else {
                sb.append(" AND p.payment_provider = ?");
                params.add(provider.toUpperCase());
            }
        }
        if (status != null && !status.isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            sb.append(" AND p.payment_status = ?");
            params.add(status.toUpperCase());
        }
        if (days > 0) {
            sb.append(" AND p.created_at >= DATEADD(DAY, ?, CURRENT_TIMESTAMP)");
            params.add(-days);
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

    private Payment findOne(String sql, Object param) {
        Connection conn = getConnection();
        if (conn == null) {
            return null;
        }
        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            if (param instanceof Long) {
                ps.setLong(1, (Long) param);
            } else {
                ps.setString(1, String.valueOf(param));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "findOne payment error", ex);
            return null;
        }
    }

    private Payment map(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getLong("payment_id"));
        p.setOrderId(rs.getLong("order_id"));
        p.setOrderCode(rs.getString("order_code"));
        p.setCustomerId(rs.getLong("customer_id"));
        p.setCustomerName(rs.getString("customer_name"));
        p.setPaymentProvider(rs.getString("payment_provider"));
        p.setPaymentType(rs.getString("payment_type"));
        p.setTransactionCode(rs.getString("transaction_code"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setPaymentStatus(rs.getString("payment_status"));
        p.setFailureReason(rs.getString("failure_reason"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setPaidAt(rs.getTimestamp("paid_at"));
        p.setOrderStatus(rs.getString("order_status"));
        p.setOrderPaymentStatus(rs.getString("order_payment_status"));
        p.setItemSummary(rs.getString("item_summary"));
        p.setRefundedAmount(rs.getBigDecimal("refunded_amount"));
        return p;
    }

    private void insertNotification(Connection conn, long userId, String title, String message, long orderId)
            throws SQLException {
        String sql = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id) "
                + "VALUES (?, ?, ?, 'ORDER', 'ORDER', ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setNString(2, title);
            ps.setNString(3, message);
            ps.setLong(4, orderId);
            ps.executeUpdate();
        }
    }

    private void rollbackQuietly(Connection conn) {
        try {
            conn.rollback();
        } catch (SQLException rEx) {
            LOGGER.log(Level.SEVERE, "Rollback failed", rEx);
        }
    }
}
