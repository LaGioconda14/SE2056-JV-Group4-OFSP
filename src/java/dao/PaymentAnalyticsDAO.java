package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.CashflowReport;
import util.DBContext;

/** Báo cáo phân tích thanh toán & dòng tiền (chỉ đọc, toàn bộ là các câu SELECT ... GROUP BY). */
public class PaymentAnalyticsDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(PaymentAnalyticsDAO.class.getName());

    /** @param days số ngày gần nhất; 0 = toàn bộ thời gian */
    public CashflowReport getReport(int days) {
        CashflowReport r = new CashflowReport();
        Timestamp from = days > 0
                ? new Timestamp(System.currentTimeMillis() - days * 86_400_000L)
                : Timestamp.valueOf("1900-01-01 00:00:00");

        Connection conn = getConnection();
        if (conn == null) {
            return r;
        }
        try (conn) {
            // 1) Tổng quan giao dịch + tiền thu
            String totals = "SELECT COUNT(*) AS total_cnt, "
                    + "SUM(CASE WHEN payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS ok_cnt, "
                    + "SUM(CASE WHEN payment_status = 'FAILED' THEN 1 ELSE 0 END) AS fail_cnt, "
                    + "SUM(CASE WHEN payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pend_cnt, "
                    + "SUM(CASE WHEN payment_provider = 'COD' THEN 1 ELSE 0 END) AS cod_cnt, "
                    + "SUM(CASE WHEN payment_provider <> 'COD' THEN 1 ELSE 0 END) AS online_cnt, "
                    + "SUM(CASE WHEN payment_provider <> 'COD' AND payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS online_ok, "
                    + "SUM(CASE WHEN payment_provider <> 'COD' AND payment_status = 'FAILED' THEN 1 ELSE 0 END) AS online_fail, "
                    + "COALESCE(SUM(CASE WHEN payment_status = 'SUCCESS' THEN amount END), 0) AS collected, "
                    + "COALESCE(SUM(CASE WHEN payment_status = 'SUCCESS' AND payment_provider = 'COD' THEN amount END), 0) AS cod_amt, "
                    + "COALESCE(SUM(CASE WHEN payment_status = 'SUCCESS' AND payment_provider <> 'COD' THEN amount END), 0) AS online_amt "
                    + "FROM payments WHERE created_at >= ?";
            try (PreparedStatement ps = conn.prepareStatement(totals)) {
                ps.setTimestamp(1, from);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        r.setTotalTransactions(rs.getInt("total_cnt"));
                        r.setSuccessCount(rs.getInt("ok_cnt"));
                        r.setFailedCount(rs.getInt("fail_cnt"));
                        r.setPendingCount(rs.getInt("pend_cnt"));
                        r.setCodCount(rs.getInt("cod_cnt"));
                        r.setOnlineCount(rs.getInt("online_cnt"));
                        r.setOnlineSuccess(rs.getInt("online_ok"));
                        r.setOnlineFailed(rs.getInt("online_fail"));
                        r.setCollectedTotal(rs.getBigDecimal("collected"));
                        r.setCollectedCod(rs.getBigDecimal("cod_amt"));
                        r.setCollectedOnline(rs.getBigDecimal("online_amt"));
                    }
                }
            }

            // 2) Tiền hoàn cho khách và tiền đã chi trả cho shop trong kỳ
            r.setRefundedTotal(scalar(conn,
                    "SELECT COALESCE(SUM(amount), 0) FROM refunds WHERE status = 'COMPLETED' AND created_at >= ?", from));
            r.setPayoutPaid(scalar(conn,
                    "SELECT COALESCE(SUM(net_payout), 0) FROM vendor_payouts WHERE status = 'COMPLETED' AND paid_at >= ?", from));

            // 3) Thu theo ngày: tiền mặt vs tiền điện tử
            String daily = "SELECT CAST(created_at AS DATE) AS d, "
                    + "SUM(CASE WHEN payment_provider = 'COD' AND payment_status = 'SUCCESS' THEN amount ELSE 0 END) AS cash, "
                    + "SUM(CASE WHEN payment_provider <> 'COD' AND payment_status = 'SUCCESS' THEN amount ELSE 0 END) AS electronic "
                    + "FROM payments WHERE created_at >= ? GROUP BY CAST(created_at AS DATE) ORDER BY d";
            try (PreparedStatement ps = conn.prepareStatement(daily)) {
                ps.setTimestamp(1, from);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> m = new LinkedHashMap<>();
                        m.put("date", rs.getDate("d").toString());
                        m.put("cash", rs.getBigDecimal("cash"));
                        m.put("electronic", rs.getBigDecimal("electronic"));
                        r.getDaily().add(m);
                    }
                }
            }

            // 4) Theo phương thức
            String byMethod = "SELECT payment_provider, COUNT(*) AS cnt, "
                    + "SUM(CASE WHEN payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS ok_cnt, "
                    + "SUM(CASE WHEN payment_status = 'FAILED' THEN 1 ELSE 0 END) AS fail_cnt, "
                    + "SUM(CASE WHEN payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pend_cnt, "
                    + "COALESCE(SUM(CASE WHEN payment_status = 'SUCCESS' THEN amount END), 0) AS amt "
                    + "FROM payments WHERE created_at >= ? GROUP BY payment_provider ORDER BY amt DESC";
            try (PreparedStatement ps = conn.prepareStatement(byMethod)) {
                ps.setTimestamp(1, from);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> m = new LinkedHashMap<>();
                        m.put("provider", rs.getString("payment_provider"));
                        m.put("count", rs.getInt("cnt"));
                        m.put("success", rs.getInt("ok_cnt"));
                        m.put("failed", rs.getInt("fail_cnt"));
                        m.put("pending", rs.getInt("pend_cnt"));
                        m.put("amount", rs.getBigDecimal("amt"));
                        r.getByMethod().add(m);
                    }
                }
            }

            // 5) Top lý do lỗi
            String reasons = "SELECT TOP 5 failure_reason, COUNT(*) AS cnt FROM payments "
                    + "WHERE payment_status = 'FAILED' AND failure_reason IS NOT NULL AND created_at >= ? "
                    + "GROUP BY failure_reason ORDER BY COUNT(*) DESC";
            try (PreparedStatement ps = conn.prepareStatement(reasons)) {
                ps.setTimestamp(1, from);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> m = new LinkedHashMap<>();
                        m.put("reason", rs.getString("failure_reason"));
                        m.put("count", rs.getInt("cnt"));
                        r.getFailureReasons().add(m);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "getReport error", ex);
        }
        return r;
    }

    private BigDecimal scalar(Connection conn, String sql, Timestamp from) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, from);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }
}
