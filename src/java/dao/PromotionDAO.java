package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Promotion;
import util.DBContext;

/**
 * Promotion = chương trình khuyến mãi tự động áp lên sản phẩm của shop trong một khoảng thời gian
 * (khác voucher: khách không cần nhập mã).
 * Bảng: promotions, promotion_products.
 */
public class PromotionDAO extends DBContext {

    private static final String STATUS_EXPR =
            "CASE WHEN p.terminated_at IS NOT NULL THEN 'ENDED' "
          + "     WHEN p.is_active = 0 THEN 'PAUSED' "
          + "     WHEN p.end_date < GETDATE() THEN 'EXPIRED' "
          + "     WHEN p.start_date > GETDATE() THEN 'UPCOMING' "
          + "     ELSE 'ONGOING' END";

    private static final String SELECT_COLS =
            "SELECT p.promotion_id, p.shop_id, p.name, p.description, p.promotion_type, p.discount_value, "
          + "p.max_discount_amount, p.start_date, p.end_date, p.is_active, p.terminated_at, p.created_at, "
          + STATUS_EXPR + " AS status, "
          + "(SELECT COUNT(*) FROM promotion_products pp WHERE pp.promotion_id = p.promotion_id) AS product_count "
          + "FROM promotions p ";

    private Promotion map(ResultSet rs) throws SQLException {
        Promotion p = new Promotion();
        p.setPromotionId(rs.getLong("promotion_id"));
        p.setShopId(rs.getLong("shop_id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setPromotionType(rs.getString("promotion_type"));
        p.setDiscountValue(rs.getBigDecimal("discount_value"));
        p.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
        p.setStartDate(rs.getTimestamp("start_date"));
        p.setEndDate(rs.getTimestamp("end_date"));
        p.setActive(rs.getBoolean("is_active"));
        p.setTerminatedAt(rs.getTimestamp("terminated_at"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setStatus(rs.getString("status"));
        p.setProductCount(rs.getInt("product_count"));
        return p;
    }

    // ------------------------------------------------------------------
    // DANH SÁCH / THỐNG KÊ
    // ------------------------------------------------------------------

    /** tab: ALL | ONGOING | UPCOMING | PAUSED | FINISHED (ENDED, EXPIRED) */
    public List<Promotion> listByShop(long shopId, String tab, String keyword) {
        List<Promotion> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT_COLS).append("WHERE p.shop_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(shopId);
        if ("ONGOING".equals(tab) || "UPCOMING".equals(tab) || "PAUSED".equals(tab)) {
            sql.append("AND ").append(STATUS_EXPR).append(" = '").append(tab).append("' ");
        } else if ("FINISHED".equals(tab)) {
            sql.append("AND ").append(STATUS_EXPR).append(" IN ('ENDED','EXPIRED') ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND p.name LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        sql.append("ORDER BY p.start_date DESC, p.promotion_id DESC");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
            // Tên vài sản phẩm đầu để xem nhanh trong danh sách
            for (Promotion p : list) {
                p.setProductNames(loadProductNames(conn, p.getPromotionId(), 3));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Integer> countByTab(long shopId) {
        Map<String, Integer> m = new LinkedHashMap<>();
        m.put("all", 0);
        m.put("ongoing", 0);
        m.put("upcoming", 0);
        m.put("paused", 0);
        m.put("finished", 0);
        String sql = "SELECT " + STATUS_EXPR + " AS st, COUNT(*) AS n FROM promotions p WHERE p.shop_id = ? GROUP BY " + STATUS_EXPR;
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

    /** Số sản phẩm đang được khuyến mãi + số lượng đã bán / tiền đã giảm nhờ promotion (từ order_items). */
    public Map<String, Object> getShopSummary(long shopId) {
        Map<String, Object> m = new HashMap<>();
        m.put("productsOnPromo", 0);
        m.put("unitsSold", 0);
        m.put("totalDiscount", BigDecimal.ZERO);
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(DISTINCT pp.product_id) FROM promotions p JOIN promotion_products pp ON pp.promotion_id = p.promotion_id "
                  + "WHERE p.shop_id = ? AND " + STATUS_EXPR + " = 'ONGOING'")) {
                ps.setLong(1, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) m.put("productsOnPromo", rs.getInt(1));
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COALESCE(SUM(oi.quantity), 0) AS units, COALESCE(SUM(oi.promotion_discount), 0) AS disc "
                  + "FROM order_items oi JOIN promotions p ON p.promotion_id = oi.promotion_id WHERE p.shop_id = ?")) {
                ps.setLong(1, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("unitsSold", rs.getInt("units"));
                        m.put("totalDiscount", rs.getBigDecimal("disc"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return m;
    }

    private List<String> loadProductNames(Connection conn, long promotionId, int limit) throws SQLException {
        List<String> names = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") pr.name FROM promotion_products pp JOIN products pr ON pr.product_id = pp.product_id "
                + "WHERE pp.promotion_id = ? ORDER BY pr.name";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, promotionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) names.add(rs.getString(1));
            }
        }
        return names;
    }

    // ------------------------------------------------------------------
    // CHI TIẾT / TẠO / SỬA
    // ------------------------------------------------------------------

    public Promotion findByIdAndShop(long promotionId, long shopId) {
        String sql = SELECT_COLS + "WHERE p.promotion_id = ? AND p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, promotionId);
            ps.setLong(2, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Promotion p = map(rs);
                    try (PreparedStatement ps2 = conn.prepareStatement("SELECT product_id FROM promotion_products WHERE promotion_id = ?")) {
                        ps2.setLong(1, promotionId);
                        try (ResultSet r2 = ps2.executeQuery()) {
                            while (r2.next()) p.getProductIds().add(r2.getLong(1));
                        }
                    }
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tên các sản phẩm đã nằm trong promotion khác trùng khoảng thời gian (mỗi sản phẩm chỉ tham gia
     * 1 promotion tại một thời điểm). excludeId = 0 khi tạo mới.
     */
    public List<String> findConflictingProducts(long shopId, List<Long> productIds, Timestamp start, Timestamp end, long excludeId) {
        List<String> names = new ArrayList<>();
        if (productIds == null || productIds.isEmpty()) {
            return names;
        }
        StringBuilder in = new StringBuilder();
        for (int i = 0; i < productIds.size(); i++) {
            in.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT DISTINCT pr.name FROM promotions p "
                + "JOIN promotion_products pp ON pp.promotion_id = p.promotion_id "
                + "JOIN products pr ON pr.product_id = pp.product_id "
                + "WHERE p.shop_id = ? AND p.promotion_id <> ? AND p.terminated_at IS NULL "
                + "AND p.start_date < ? AND p.end_date > ? AND pp.product_id IN (" + in + ")";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            ps.setLong(i++, shopId);
            ps.setLong(i++, excludeId);
            ps.setTimestamp(i++, end);
            ps.setTimestamp(i++, start);
            for (Long pid : productIds) {
                ps.setLong(i++, pid);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) names.add(rs.getString(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    /** Tạo promotion. Trả về promotion_id mới hoặc -1 nếu lỗi. */
    public long create(Promotion p) {
        String sql = "INSERT INTO promotions (shop_id, name, description, promotion_type, discount_value, max_discount_amount, "
                + "start_date, end_date, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, p.getShopId());
                ps.setString(2, p.getName());
                ps.setString(3, p.getDescription());
                ps.setString(4, p.getPromotionType());
                ps.setBigDecimal(5, p.getDiscountValue());
                ps.setBigDecimal(6, p.getMaxDiscountAmount());
                ps.setTimestamp(7, p.getStartDate());
                ps.setTimestamp(8, p.getEndDate());
                ps.setBoolean(9, p.isActive());
                ps.executeUpdate();
                long id = -1;
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) id = keys.getLong(1);
                }
                if (id <= 0) {
                    conn.rollback();
                    return -1;
                }
                saveProducts(conn, id, p.getShopId(), p.getProductIds());
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

    public boolean update(Promotion p) {
        String sql = "UPDATE promotions SET name = ?, description = ?, promotion_type = ?, discount_value = ?, max_discount_amount = ?, "
                + "start_date = ?, end_date = ?, is_active = ?, updated_at = GETDATE() "
                + "WHERE promotion_id = ? AND shop_id = ? AND terminated_at IS NULL";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, p.getName());
                ps.setString(2, p.getDescription());
                ps.setString(3, p.getPromotionType());
                ps.setBigDecimal(4, p.getDiscountValue());
                ps.setBigDecimal(5, p.getMaxDiscountAmount());
                ps.setTimestamp(6, p.getStartDate());
                ps.setTimestamp(7, p.getEndDate());
                ps.setBoolean(8, p.isActive());
                ps.setLong(9, p.getPromotionId());
                ps.setLong(10, p.getShopId());
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
                try (PreparedStatement del = conn.prepareStatement("DELETE FROM promotion_products WHERE promotion_id = ?")) {
                    del.setLong(1, p.getPromotionId());
                    del.executeUpdate();
                }
                saveProducts(conn, p.getPromotionId(), p.getShopId(), p.getProductIds());
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

    private void saveProducts(Connection conn, long promotionId, long shopId, List<Long> productIds) throws SQLException {
        if (productIds == null) return;
        // Chỉ nhận sản phẩm thuộc đúng shop
        String sql = "INSERT INTO promotion_products (promotion_id, product_id) "
                + "SELECT ?, p.product_id FROM products p WHERE p.product_id = ? AND p.shop_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Long pid : productIds) {
                ps.setLong(1, promotionId);
                ps.setLong(2, pid);
                ps.setLong(3, shopId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    // ------------------------------------------------------------------
    // KÍCH HOẠT / TẠM DỪNG / KẾT THÚC SỚM
    // ------------------------------------------------------------------

    public boolean setActive(long promotionId, long shopId, boolean active) {
        return exec("UPDATE promotions SET is_active = ?, updated_at = GETDATE() "
                + "WHERE promotion_id = ? AND shop_id = ? AND terminated_at IS NULL", active, promotionId, shopId);
    }

    public boolean terminate(long promotionId, long shopId) {
        return exec("UPDATE promotions SET terminated_at = GETDATE(), is_active = 0, updated_at = GETDATE(), "
                + "end_date = CASE WHEN end_date > GETDATE() THEN GETDATE() ELSE end_date END "
                + "WHERE promotion_id = ? AND shop_id = ? AND terminated_at IS NULL", promotionId, shopId);
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
    // DANH SÁCH SẢN PHẨM ĐỂ CHỌN (dùng chung cho form Promotion và Voucher)
    // ------------------------------------------------------------------

    public List<Map<String, Object>> getShopProductsForPicker(long shopId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, "
                + "(SELECT MIN(v.price) FROM product_variants v WHERE v.product_id = p.product_id AND v.is_active = 1) AS min_price, "
                + "(SELECT TOP 1 i.image_url FROM product_images i WHERE i.product_id = p.product_id "
                + "   ORDER BY i.is_thumbnail DESC, i.display_order) AS image "
                + "FROM products p WHERE p.shop_id = ? AND p.is_active = 1 ORDER BY p.name";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("productId", rs.getLong("product_id"));
                    m.put("name", rs.getString("name"));
                    m.put("minPrice", rs.getBigDecimal("min_price"));
                    m.put("image", rs.getString("image"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ------------------------------------------------------------------
    // DÙNG Ở TRANG SẢN PHẨM / GIỎ HÀNG / CHECKOUT
    // ------------------------------------------------------------------

    /**
     * Promotion đang chạy cho từng sản phẩm: productId -> Promotion.
     * Dùng Promotion.calcDiscount(unitPrice) / calcDiscountedPrice(unitPrice) để tính giá sau giảm.
     * (Mỗi sản phẩm chỉ có tối đa 1 promotion tại một thời điểm do đã chặn trùng lịch khi tạo.)
     */
    public Map<Long, Promotion> getActivePromotionsByProducts(Collection<Long> productIds) {
        Map<Long, Promotion> result = new HashMap<>();
        if (productIds == null || productIds.isEmpty()) {
            return result;
        }
        StringBuilder in = new StringBuilder();
        for (int i = 0; i < productIds.size(); i++) {
            in.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT pp.product_id, p.promotion_id, p.shop_id, p.name, p.promotion_type, p.discount_value, p.max_discount_amount, "
                + "p.start_date, p.end_date FROM promotions p JOIN promotion_products pp ON pp.promotion_id = p.promotion_id "
                + "WHERE p.is_active = 1 AND p.terminated_at IS NULL AND p.start_date <= GETDATE() AND p.end_date >= GETDATE() "
                + "AND pp.product_id IN (" + in + ") ORDER BY p.start_date";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            for (Long pid : productIds) {
                ps.setLong(i++, pid);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Promotion p = new Promotion();
                    p.setPromotionId(rs.getLong("promotion_id"));
                    p.setShopId(rs.getLong("shop_id"));
                    p.setName(rs.getString("name"));
                    p.setPromotionType(rs.getString("promotion_type"));
                    p.setDiscountValue(rs.getBigDecimal("discount_value"));
                    p.setMaxDiscountAmount(rs.getBigDecimal("max_discount_amount"));
                    p.setStartDate(rs.getTimestamp("start_date"));
                    p.setEndDate(rs.getTimestamp("end_date"));
                    p.setStatus("ONGOING");
                    result.put(rs.getLong("product_id"), p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
}
