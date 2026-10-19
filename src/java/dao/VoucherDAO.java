package dao;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Voucher;
import model.VoucherCheckResult;
import util.DBContext;

/**
 * Voucher = bảng coupons (khách nhập mã khi checkout).
 * Voucher của shop có coupons.shop_id = shop_id, sponsor_type = 'VENDOR'.
 * Voucher sàn có shop_id = NULL.
 *
 * Trạng thái (tính từ dữ liệu, không lưu cứng):
 *   ENDED    - shop kết thúc sớm (terminated_at != NULL)
 *   PAUSED   - đang tắt (is_active = 0)
 *   EXPIRED  - quá end_date
 *   UPCOMING - chưa tới start_date
 *   SOLD_OUT - đã dùng hết số lượt
 *   ONGOING  - đang áp dụng được
 */
public class VoucherDAO extends DBContext {

    private static final String STATUS_EXPR =
            "CASE WHEN c.terminated_at IS NOT NULL THEN 'ENDED' "
          + "     WHEN c.is_active = 0 THEN 'PAUSED' "
          + "     WHEN c.end_date < GETDATE() THEN 'EXPIRED' "
          + "     WHEN c.start_date > GETDATE() THEN 'UPCOMING' "
          + "     WHEN c.used_count >= c.usage_limit THEN 'SOLD_OUT' "
          + "     ELSE 'ONGOING' END";

    private static final String SELECT_COLS =
            "SELECT c.coupon_id, c.shop_id, c.code, c.title, c.description, c.discount_type, c.discount_value, "
          + "c.min_order_value, c.max_discount_amount, c.usage_limit, c.used_count, c.per_user_limit, c.applies_to, "
          + "c.sponsor_type, c.start_date, c.end_date, c.is_active, c.terminated_at, c.created_at, "
          + STATUS_EXPR + " AS status, "
          + "(SELECT COUNT(*) FROM coupon_products cp WHERE cp.coupon_id = c.coupon_id) AS product_count "
          + "FROM coupons c ";

    private Voucher map(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setCouponId(rs.getInt("coupon_id"));
        long sid = rs.getLong("shop_id");
        v.setShopId(rs.wasNull() ? null : sid);
        v.setCode(rs.getString("code"));
        v.setTitle(rs.getString("title"));
        v.setDescription(rs.getString("description"));
        v.setDiscountType(rs.getString("discount_type"));
        v.setDiscountValue(rs.getBigDecimal("discount_value"));
        v.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        v.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
        v.setUsageLimit(rs.getInt("usage_limit"));
        v.setUsedCount(rs.getInt("used_count"));
        v.setPerUserLimit(rs.getInt("per_user_limit"));
        v.setAppliesTo(rs.getString("applies_to"));
        v.setSponsorType(rs.getString("sponsor_type"));
        v.setStartDate(rs.getTimestamp("start_date"));
        v.setEndDate(rs.getTimestamp("end_date"));
        v.setActive(rs.getBoolean("is_active"));
        v.setTerminatedAt(rs.getTimestamp("terminated_at"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        v.setStatus(rs.getString("status"));
        v.setProductCount(rs.getInt("product_count"));
        return v;
    }

    // ------------------------------------------------------------------
    // DANH SÁCH / THỐNG KÊ CHO SHOP OWNER
    // ------------------------------------------------------------------

    /** tab: ALL | ONGOING | UPCOMING | PAUSED | FINISHED (ENDED, EXPIRED, SOLD_OUT) */
    public List<Voucher> listByShop(long shopId, String tab, String keyword) {
        List<Voucher> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_COLS).append("WHERE c.shop_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(shopId);

        if ("ONGOING".equals(tab) || "UPCOMING".equals(tab) || "PAUSED".equals(tab)) {
            sql.append("AND ").append(STATUS_EXPR).append(" = '").append(tab).append("' ");
        } else if ("FINISHED".equals(tab)) {
            sql.append("AND ").append(STATUS_EXPR).append(" IN ('ENDED','EXPIRED','SOLD_OUT') ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (c.code LIKE ? OR c.title LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        sql.append("ORDER BY c.created_at DESC, c.coupon_id DESC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Số voucher theo từng nhóm trạng thái: all, ongoing, upcoming, paused, finished. */
    public Map<String, Integer> countByTab(long shopId) {
        Map<String, Integer> m = new LinkedHashMap<>();
        m.put("all", 0);
        m.put("ongoing", 0);
        m.put("upcoming", 0);
        m.put("paused", 0);
        m.put("finished", 0);
        String sql = "SELECT " + STATUS_EXPR + " AS st, COUNT(*) AS n FROM coupons c WHERE c.shop_id = ? GROUP BY " + STATUS_EXPR;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String st = rs.getString("st");
                    int n = rs.getInt("n");
                    m.put("all", m.get("all") + n);
                    if ("ONGOING".equals(st)) m.put("ongoing", n);
                    else if ("UPCOMING".equals(st)) m.put("upcoming", n);
                    else if ("PAUSED".equals(st)) m.put("paused", n);
                    else m.put("finished", m.get("finished") + n);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return m;
    }

    /** Tổng lượt dùng, tổng tiền đã giảm, số khách đã dùng voucher của shop. */
    public Map<String, Object> getShopSummary(long shopId) {
        Map<String, Object> m = new HashMap<>();
        m.put("totalUsed", 0);
        m.put("totalDiscount", BigDecimal.ZERO);
        m.put("uniqueCustomers", 0);
        String sql = "SELECT COUNT(u.usage_id) AS used, COALESCE(SUM(u.discount_amount), 0) AS disc, "
                + "COUNT(DISTINCT u.customer_id) AS cust "
                + "FROM coupon_usages u JOIN coupons c ON c.coupon_id = u.coupon_id WHERE c.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.put("totalUsed", rs.getInt("used"));
                    m.put("totalDiscount", rs.getBigDecimal("disc"));
                    m.put("uniqueCustomers", rs.getInt("cust"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return m;
    }

    // ------------------------------------------------------------------
    // CHI TIẾT / TẠO / SỬA
    // ------------------------------------------------------------------

    /** Lấy voucher của đúng shop (kèm danh sách sản phẩm áp dụng). */
    public Voucher findByIdAndShop(int couponId, long shopId) {
        String sql = SELECT_COLS + "WHERE c.coupon_id = ? AND c.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            ps.setLong(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Voucher v = map(rs);
                    v.setProductIds(loadProductIds(conn, couponId));
                    return v;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private List<Long> loadProductIds(Connection conn, int couponId) throws SQLException {
        List<Long> ids = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement("SELECT product_id FROM coupon_products WHERE coupon_id = ?")) {
            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getLong(1));
                }
            }
        }
        return ids;
    }

    /** Mã voucher là duy nhất toàn sàn. excludeId = null khi tạo mới. */
    public boolean codeExists(String code, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM coupons WHERE code = ?" + (excludeId != null ? " AND coupon_id <> ?" : "");
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return true; // lỗi DB -> chặn để an toàn
    }

    /** Tạo voucher của shop. Trả về coupon_id mới hoặc -1 nếu lỗi. */
    public int create(Voucher v, long shopId) {
        String sql = "INSERT INTO coupons (shop_id, code, title, description, discount_type, discount_value, min_order_value, "
                + "max_discount_amount, usage_limit, used_count, per_user_limit, applies_to, sponsor_type, start_date, end_date, is_active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, 'VENDOR', ?, ?, ?)";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, shopId);
                ps.setString(2, v.getCode());
                ps.setString(3, v.getTitle());
                ps.setString(4, v.getDescription());
                ps.setString(5, v.getDiscountType());
                ps.setBigDecimal(6, v.getDiscountValue());
                ps.setBigDecimal(7, v.getMinOrderValue());
                ps.setBigDecimal(8, v.getMaxDiscountAmount());
                ps.setInt(9, v.getUsageLimit());
                ps.setInt(10, v.getPerUserLimit());
                ps.setString(11, v.getAppliesTo());
                ps.setTimestamp(12, v.getStartDate());
                ps.setTimestamp(13, v.getEndDate());
                ps.setBoolean(14, v.isActive());
                ps.executeUpdate();
                int id = -1;
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        id = keys.getInt(1);
                    }
                }
                if (id <= 0) {
                    conn.rollback();
                    return -1;
                }
                saveProducts(conn, id, v);
                conn.commit();
                return id;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /** Cập nhật voucher (chỉ của đúng shop). Không đổi mã và không đổi used_count. */
    public boolean update(Voucher v, long shopId) {
        String sql = "UPDATE coupons SET title = ?, description = ?, discount_type = ?, discount_value = ?, min_order_value = ?, "
                + "max_discount_amount = ?, usage_limit = ?, per_user_limit = ?, applies_to = ?, start_date = ?, end_date = ?, "
                + "is_active = ?, updated_at = GETDATE() WHERE coupon_id = ? AND shop_id = ? AND terminated_at IS NULL";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, v.getTitle());
                ps.setString(2, v.getDescription());
                ps.setString(3, v.getDiscountType());
                ps.setBigDecimal(4, v.getDiscountValue());
                ps.setBigDecimal(5, v.getMinOrderValue());
                ps.setBigDecimal(6, v.getMaxDiscountAmount());
                ps.setInt(7, v.getUsageLimit());
                ps.setInt(8, v.getPerUserLimit());
                ps.setString(9, v.getAppliesTo());
                ps.setTimestamp(10, v.getStartDate());
                ps.setTimestamp(11, v.getEndDate());
                ps.setBoolean(12, v.isActive());
                ps.setInt(13, v.getCouponId());
                ps.setLong(14, shopId);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
                try (PreparedStatement del = conn.prepareStatement("DELETE FROM coupon_products WHERE coupon_id = ?")) {
                    del.setInt(1, v.getCouponId());
                    del.executeUpdate();
                }
                saveProducts(conn, v.getCouponId(), v);
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void saveProducts(Connection conn, int couponId, Voucher v) throws SQLException {
        if (!"PRODUCTS".equals(v.getAppliesTo()) || v.getProductIds() == null) {
            return;
        }
        // Chỉ nhận sản phẩm thuộc đúng shop của voucher (chống gửi product_id của shop khác)
        String sql = "INSERT INTO coupon_products (coupon_id, product_id) "
                + "SELECT ?, p.product_id FROM products p JOIN coupons c ON c.shop_id = p.shop_id "
                + "WHERE c.coupon_id = ? AND p.product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Long pid : v.getProductIds()) {
                ps.setInt(1, couponId);
                ps.setInt(2, couponId);
                ps.setLong(3, pid);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    // ------------------------------------------------------------------
    // KÍCH HOẠT / TẠM DỪNG / KẾT THÚC SỚM
    // ------------------------------------------------------------------

    public boolean setActive(int couponId, long shopId, boolean active) {
        String sql = "UPDATE coupons SET is_active = ?, updated_at = GETDATE() "
                + "WHERE coupon_id = ? AND shop_id = ? AND terminated_at IS NULL";
        return exec(sql, active, couponId, shopId);
    }

    /** Kết thúc sớm: ngừng hẳn, không kích hoạt lại được; lịch sử sử dụng vẫn giữ nguyên. */
    public boolean terminate(int couponId, long shopId) {
        String sql = "UPDATE coupons SET terminated_at = GETDATE(), is_active = 0, updated_at = GETDATE(), "
                + "end_date = CASE WHEN end_date > GETDATE() THEN GETDATE() ELSE end_date END "
                + "WHERE coupon_id = ? AND shop_id = ? AND terminated_at IS NULL";
        return exec(sql, couponId, shopId);
    }

    private boolean exec(String sql, Object... params) {
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ------------------------------------------------------------------
    // LỊCH SỬ SỬ DỤNG
    // ------------------------------------------------------------------

    public List<Map<String, Object>> getUsageHistory(int couponId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") u.usage_id, u.used_at, u.discount_amount, o.order_code, o.final_amount, "
                + "us.full_name AS customer_name, us.email AS customer_email "
                + "FROM coupon_usages u "
                + "JOIN users us ON us.user_id = u.customer_id "
                + "LEFT JOIN orders o ON o.order_id = u.order_id "
                + "WHERE u.coupon_id = ? ORDER BY u.used_at DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("usedAt", rs.getTimestamp("used_at"));
                    m.put("discount", rs.getBigDecimal("discount_amount"));
                    m.put("orderCode", rs.getString("order_code"));
                    m.put("orderAmount", rs.getBigDecimal("final_amount"));
                    m.put("customerName", rs.getString("customer_name"));
                    m.put("customerEmail", rs.getString("customer_email"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** totalUsed, totalDiscount, uniqueCustomers, avgDiscount của 1 voucher. */
    public Map<String, Object> getUsageStats(int couponId) {
        Map<String, Object> m = new HashMap<>();
        m.put("totalUsed", 0);
        m.put("totalDiscount", BigDecimal.ZERO);
        m.put("uniqueCustomers", 0);
        m.put("avgDiscount", BigDecimal.ZERO);
        String sql = "SELECT COUNT(*) AS n, COALESCE(SUM(discount_amount), 0) AS disc, COUNT(DISTINCT customer_id) AS cust "
                + "FROM coupon_usages WHERE coupon_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int n = rs.getInt("n");
                    BigDecimal disc = rs.getBigDecimal("disc");
                    m.put("totalUsed", n);
                    m.put("totalDiscount", disc);
                    m.put("uniqueCustomers", rs.getInt("cust"));
                    m.put("avgDiscount", n > 0 ? disc.divide(BigDecimal.valueOf(n), 0, RoundingMode.HALF_UP) : BigDecimal.ZERO);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return m;
    }

    // ------------------------------------------------------------------
    // DÙNG Ở BƯỚC CHECKOUT
    // ------------------------------------------------------------------

    /**
     * Kiểm tra một mã voucher có dùng được cho đơn con của shop không và tính số tiền giảm.
     *
     * @param code        mã khách nhập (không phân biệt hoa thường)
     * @param shopId      shop của đơn con đang tính (voucher shop chỉ dùng cho đúng shop; voucher sàn dùng được mọi shop)
     * @param customerId  khách đang mua
     * @param subtotal    tiền hàng của đơn con (đã trừ promotion nếu có)
     * @param lineTotals  (tuỳ chọn) productId -> thành tiền của dòng; cần khi voucher chỉ áp cho một số sản phẩm.
     *                    Truyền null thì coi toàn bộ subtotal là hợp lệ.
     */
    public VoucherCheckResult validate(String code, long shopId, long customerId, BigDecimal subtotal,
                                       Map<Long, BigDecimal> lineTotals) {
        if (code == null || code.trim().isEmpty()) {
            return VoucherCheckResult.fail("Vui lòng nhập mã voucher.");
        }
        if (subtotal == null || subtotal.signum() <= 0) {
            return VoucherCheckResult.fail("Giỏ hàng trống.");
        }
        String sql = "SELECT c.*, " + STATUS_EXPR + " AS status FROM coupons c WHERE c.code = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return VoucherCheckResult.fail("Mã voucher không tồn tại.");
                }
                int couponId = rs.getInt("coupon_id");
                long cShop = rs.getLong("shop_id");
                boolean platform = rs.wasNull();
                String status = rs.getString("status");

                if (!platform && cShop != shopId) {
                    return VoucherCheckResult.fail("Voucher này không áp dụng cho gian hàng của đơn hàng.");
                }
                switch (status) {
                    case "UPCOMING": return VoucherCheckResult.fail("Voucher chưa đến thời gian sử dụng.");
                    case "EXPIRED":  return VoucherCheckResult.fail("Voucher đã hết hạn.");
                    case "SOLD_OUT": return VoucherCheckResult.fail("Voucher đã hết lượt sử dụng.");
                    case "PAUSED":
                    case "ENDED":    return VoucherCheckResult.fail("Voucher hiện không còn hiệu lực.");
                    default: break;
                }

                BigDecimal minOrder = rs.getBigDecimal("min_order_value");
                if (subtotal.compareTo(minOrder) < 0) {
                    return VoucherCheckResult.fail("Đơn hàng cần tối thiểu " + String.format("%,.0f", minOrder) + "đ để dùng voucher này.");
                }

                int perUser = rs.getInt("per_user_limit");
                try (PreparedStatement pu = conn.prepareStatement(
                        "SELECT COUNT(*) FROM coupon_usages WHERE coupon_id = ? AND customer_id = ?")) {
                    pu.setInt(1, couponId);
                    pu.setLong(2, customerId);
                    try (ResultSet r2 = pu.executeQuery()) {
                        if (r2.next() && r2.getInt(1) >= perUser) {
                            return VoucherCheckResult.fail("Bạn đã dùng hết số lần cho phép của voucher này.");
                        }
                    }
                }

                // Phần tiền hàng đủ điều kiện được giảm
                BigDecimal eligible = subtotal;
                if ("PRODUCTS".equals(rs.getString("applies_to"))) {
                    List<Long> allowed = loadProductIds(conn, couponId);
                    if (lineTotals == null) {
                        return VoucherCheckResult.fail("Không xác định được sản phẩm áp dụng voucher.");
                    }
                    eligible = BigDecimal.ZERO;
                    for (Map.Entry<Long, BigDecimal> e : lineTotals.entrySet()) {
                        if (allowed.contains(e.getKey())) {
                            eligible = eligible.add(e.getValue());
                        }
                    }
                    if (eligible.signum() <= 0) {
                        return VoucherCheckResult.fail("Giỏ hàng không có sản phẩm nào thuộc diện áp dụng voucher.");
                    }
                }

                String type = rs.getString("discount_type");
                BigDecimal value = rs.getBigDecimal("discount_value");
                BigDecimal maxDisc = rs.getBigDecimal("max_discount_amount");
                BigDecimal discount;
                if ("PERCENTAGE".equals(type)) {
                    discount = eligible.multiply(value).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                    if (maxDisc != null && maxDisc.signum() > 0 && discount.compareTo(maxDisc) > 0) {
                        discount = maxDisc;
                    }
                } else if ("FREESHIP".equals(type)) {
                    discount = value;   // trần giảm phí ship; checkout tự min với phí ship thực tế
                } else {
                    discount = value.min(eligible);
                }
                discount = discount.min(subtotal);

                VoucherCheckResult ok = new VoucherCheckResult();
                ok.setValid(true);
                ok.setMessage("Áp dụng voucher thành công.");
                ok.setCouponId(couponId);
                ok.setCode(rs.getString("code"));
                ok.setTitle(rs.getString("title"));
                ok.setDiscountType(type);
                ok.setShopId(platform ? null : cShop);
                ok.setDiscount(discount);
                return ok;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return VoucherCheckResult.fail("Không kiểm tra được voucher, vui lòng thử lại.");
        }
    }

    /**
     * Ghi nhận đã dùng voucher: tăng used_count (có chặn vượt usage_limit) và lưu lịch sử.
     * Gọi TRONG cùng transaction tạo đơn hàng ở checkout (truyền conn của transaction đó).
     *
     * @return true nếu ghi nhận thành công; false nếu voucher vừa hết lượt (checkout nên rollback/báo lỗi)
     */
    public boolean redeem(Connection conn, int couponId, long orderId, long customerId, BigDecimal discount) throws SQLException {
        try (PreparedStatement up = conn.prepareStatement(
                "UPDATE coupons SET used_count = used_count + 1 WHERE coupon_id = ? AND used_count < usage_limit")) {
            up.setInt(1, couponId);
            if (up.executeUpdate() == 0) {
                return false;
            }
        }
        try (PreparedStatement ins = conn.prepareStatement(
                "INSERT INTO coupon_usages (coupon_id, order_id, customer_id, discount_amount) VALUES (?, ?, ?, ?)")) {
            ins.setInt(1, couponId);
            ins.setLong(2, orderId);
            ins.setLong(3, customerId);
            ins.setBigDecimal(4, discount);
            ins.executeUpdate();
        }
        return true;
    }
}
