package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Coupon;
import util.DBContext;

public class CouponDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CouponDAO.class.getName());

    public Coupon findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT coupon_id, code, discount_type, discount_value, min_order_value, "
                + "max_discount_amount, usage_limit, used_count, start_date, end_date, "
                + "is_active, created_at FROM coupons WHERE UPPER(code) = ?";
        Connection conn = getConnection();
        if (conn == null) {
            throw new IllegalStateException("Không thể kiểm tra mã giảm giá. Vui lòng thử lại!");
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase(Locale.ROOT));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCoupon(rs) : null;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding coupon by code", ex);
            throw new IllegalStateException("Không thể kiểm tra mã giảm giá. Vui lòng thử lại!", ex);
        }
    }

    public List<Coupon> findAvailableForAmount(java.math.BigDecimal orderAmount) {
        String sql = "SELECT coupon_id, code, discount_type, discount_value, min_order_value, "
                + "max_discount_amount, usage_limit, used_count, start_date, end_date, "
                + "is_active, created_at FROM coupons "
                + "WHERE is_active = 1 AND GETDATE() BETWEEN start_date AND end_date "
                + "AND used_count < usage_limit AND min_order_value <= ? "
                + "ORDER BY min_order_value, discount_value DESC";
        List<Coupon> coupons = new ArrayList<>();
        Connection conn = getConnection();
        if (conn == null) {
            throw new IllegalStateException("Không thể tải danh sách mã giảm giá. Vui lòng thử lại!");
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, orderAmount);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) coupons.add(mapCoupon(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading available coupons", ex);
            throw new IllegalStateException("Không thể tải danh sách mã giảm giá. Vui lòng thử lại!", ex);
        }
        return coupons;
    }

    public Coupon findByIdForUpdate(Connection conn, int couponId) throws SQLException {
        String sql = "SELECT coupon_id, code, discount_type, discount_value, min_order_value, "
                + "max_discount_amount, usage_limit, used_count, start_date, end_date, "
                + "is_active, created_at FROM coupons WITH (UPDLOCK, HOLDLOCK) "
                + "WHERE coupon_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCoupon(rs) : null;
            }
        }
    }

    public void incrementUsage(Connection conn, int couponId) throws SQLException {
        String sql = "UPDATE coupons SET used_count = used_count + 1 "
                + "WHERE coupon_id = ? AND is_active = 1 "
                + "AND GETDATE() BETWEEN start_date AND end_date "
                + "AND used_count < usage_limit";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Mã giảm giá đã hết hạn hoặc hết lượt sử dụng!");
            }
        }
    }

    private Coupon mapCoupon(ResultSet rs) throws SQLException {
        Coupon coupon = new Coupon();
        coupon.setCouponId(rs.getInt("coupon_id"));
        coupon.setCode(rs.getString("code"));
        coupon.setDiscountType(rs.getString("discount_type"));
        coupon.setDiscountValue(rs.getBigDecimal("discount_value"));
        coupon.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        coupon.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
        coupon.setUsageLimit(rs.getInt("usage_limit"));
        coupon.setUsedCount(rs.getInt("used_count"));
        coupon.setStartDate(rs.getTimestamp("start_date"));
        coupon.setEndDate(rs.getTimestamp("end_date"));
        coupon.setActive(rs.getBoolean("is_active"));
        coupon.setCreatedAt(rs.getTimestamp("created_at"));
        return coupon;
    }
}
