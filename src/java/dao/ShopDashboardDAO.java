package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import util.DBContext;

/**
 * Truy vấn số liệu tổng hợp cho trang Tổng quan Shop (Seller Dashboard).
 * Bảng dùng: sub_orders, orders, order_items, product_variants, products, product_images,
 *            reviews, disputes, vendor_payouts, users.
 *
 * Quy ước:
 *  - Doanh thu = tổng shop_total của sub_orders có status = 'DELIVERED'.
 *  - Số đơn    = sub_orders KHÔNG ở trạng thái CANCELLED / REFUNDED.
 */
public class ShopDashboardDAO extends DBContext {

    private static final String NOT_CANCELLED = "('CANCELLED','REFUNDED')";

    private static Timestamp ts(LocalDate d) {
        return Timestamp.valueOf(d.atStartOfDay());
    }

    /** Chỉ số tổng hợp trong khoảng [from, to). */
    public Map<String, Object> getSummary(long shopId, LocalDate from, LocalDate to) {
        Map<String, Object> m = new HashMap<>();
        m.put("revenue", 0.0);
        m.put("commission", 0.0);
        m.put("orders", 0);
        m.put("delivered", 0);
        m.put("cancelled", 0);
        m.put("itemsSold", 0);

        String sql = "SELECT "
                + "COALESCE(SUM(CASE WHEN so.status = 'DELIVERED' THEN so.shop_total END), 0) AS revenue, "
                + "COALESCE(SUM(CASE WHEN so.status = 'DELIVERED' THEN so.commission_amount END), 0) AS commission, "
                + "COALESCE(SUM(CASE WHEN so.status NOT IN " + NOT_CANCELLED + " THEN 1 ELSE 0 END), 0) AS orders, "
                + "COALESCE(SUM(CASE WHEN so.status = 'DELIVERED' THEN 1 ELSE 0 END), 0) AS delivered, "
                + "COALESCE(SUM(CASE WHEN so.status IN " + NOT_CANCELLED + " THEN 1 ELSE 0 END), 0) AS cancelled "
                + "FROM sub_orders so WHERE so.shop_id = ? AND so.created_at >= ? AND so.created_at < ?";
        String sqlItems = "SELECT COALESCE(SUM(oi.quantity), 0) FROM order_items oi "
                + "JOIN sub_orders so ON so.sub_order_id = oi.sub_order_id "
                + "WHERE so.shop_id = ? AND so.status NOT IN " + NOT_CANCELLED
                + " AND so.created_at >= ? AND so.created_at < ?";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, shopId);
                ps.setTimestamp(2, ts(from));
                ps.setTimestamp(3, ts(to));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("revenue", rs.getBigDecimal("revenue").doubleValue());
                        m.put("commission", rs.getBigDecimal("commission").doubleValue());
                        m.put("orders", rs.getInt("orders"));
                        m.put("delivered", rs.getInt("delivered"));
                        m.put("cancelled", rs.getInt("cancelled"));
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                ps.setLong(1, shopId);
                ps.setTimestamp(2, ts(from));
                ps.setTimestamp(3, ts(to));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) m.put("itemsSold", rs.getInt(1));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return m;
    }

    /** Ngày của đơn hàng đầu tiên (dùng cho chế độ "Toàn thời gian"); null nếu chưa có đơn. */
    public LocalDate getFirstOrderDate(long shopId) {
        String sql = "SELECT MIN(created_at) FROM sub_orders WHERE shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getTimestamp(1) != null) {
                    return rs.getTimestamp(1).toLocalDateTime().toLocalDate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Chuỗi doanh thu + số đơn theo thời gian (đã điền đủ các mốc rỗng bằng 0).
     * monthly = false: theo ngày; true: theo tháng.
     * Trả về: labels (List<String>), revenue (List<Double>), orders (List<Integer>).
     */
    public Map<String, List<?>> getTrend(long shopId, LocalDate from, LocalDate to, boolean monthly) {
        Map<String, double[]> data = new HashMap<>();
        String keyExpr = monthly
                ? "CONVERT(VARCHAR(7), so.created_at, 120)"      // yyyy-MM
                : "CONVERT(VARCHAR(10), so.created_at, 120)";    // yyyy-MM-dd
        String sql = "SELECT " + keyExpr + " AS k, "
                + "COALESCE(SUM(CASE WHEN so.status = 'DELIVERED' THEN so.shop_total END), 0) AS revenue, "
                + "COALESCE(SUM(CASE WHEN so.status NOT IN " + NOT_CANCELLED + " THEN 1 ELSE 0 END), 0) AS orders "
                + "FROM sub_orders so WHERE so.shop_id = ? AND so.created_at >= ? AND so.created_at < ? "
                + "GROUP BY " + keyExpr;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            ps.setTimestamp(2, ts(from));
            ps.setTimestamp(3, ts(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    data.put(rs.getString("k"), new double[]{rs.getBigDecimal("revenue").doubleValue(), rs.getInt("orders")});
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<String> labels = new ArrayList<>();
        List<Double> revenue = new ArrayList<>();
        List<Integer> orders = new ArrayList<>();
        LocalDate lastDay = to.minusDays(1);
        if (monthly) {
            YearMonth cur = YearMonth.from(from);
            YearMonth end = YearMonth.from(lastDay);
            while (!cur.isAfter(end)) {
                String key = String.format("%04d-%02d", cur.getYear(), cur.getMonthValue());
                double[] v = data.getOrDefault(key, new double[]{0, 0});
                labels.add(String.format("%02d/%04d", cur.getMonthValue(), cur.getYear()));
                revenue.add(v[0]);
                orders.add((int) v[1]);
                cur = cur.plusMonths(1);
            }
        } else {
            LocalDate d = from;
            while (!d.isAfter(lastDay)) {
                double[] v = data.getOrDefault(d.toString(), new double[]{0, 0});
                labels.add(String.format("%02d/%02d", d.getDayOfMonth(), d.getMonthValue()));
                revenue.add(v[0]);
                orders.add((int) v[1]);
                d = d.plusDays(1);
            }
        }
        Map<String, List<?>> out = new LinkedHashMap<>();
        out.put("labels", labels);
        out.put("revenue", revenue);
        out.put("orders", orders);
        return out;
    }

    /** Số đơn theo từng trạng thái trong kỳ. */
    public Map<String, Integer> getStatusBreakdown(long shopId, LocalDate from, LocalDate to) {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS c FROM sub_orders "
                + "WHERE shop_id = ? AND created_at >= ? AND created_at < ? GROUP BY status";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            ps.setTimestamp(2, ts(from));
            ps.setTimestamp(3, ts(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) map.put(rs.getString("status"), rs.getInt("c"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    /** Top sản phẩm bán chạy trong kỳ (gộp các biến thể theo tên sản phẩm). */
    public List<Map<String, Object>> getBestSellers(long shopId, LocalDate from, LocalDate to, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") oi.product_name_snapshot AS name, "
                + "SUM(oi.quantity) AS qty, SUM(oi.total_price) AS revenue, COUNT(DISTINCT so.sub_order_id) AS orders, "
                + "MAX(img.image_url) AS image "
                + "FROM order_items oi "
                + "JOIN sub_orders so ON so.sub_order_id = oi.sub_order_id "
                + "LEFT JOIN product_variants v ON v.variant_id = oi.variant_id "
                + "OUTER APPLY (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = v.product_id "
                + "             ORDER BY pi.is_thumbnail DESC, pi.display_order) img "
                + "WHERE so.shop_id = ? AND so.status NOT IN " + NOT_CANCELLED
                + " AND so.created_at >= ? AND so.created_at < ? "
                + "GROUP BY oi.product_name_snapshot ORDER BY SUM(oi.quantity) DESC, SUM(oi.total_price) DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            ps.setTimestamp(2, ts(from));
            ps.setTimestamp(3, ts(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("name"));
                    m.put("qty", rs.getInt("qty"));
                    m.put("revenue", rs.getBigDecimal("revenue").doubleValue());
                    m.put("orders", rs.getInt("orders"));
                    m.put("image", rs.getString("image"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Đơn hàng gần đây của shop. */
    public List<Map<String, Object>> getRecentOrders(long shopId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") so.sub_order_code, o.order_code, so.shop_total, so.status, so.created_at, "
                + "u.full_name AS customer, "
                + "(SELECT COALESCE(SUM(oi.quantity), 0) FROM order_items oi WHERE oi.sub_order_id = so.sub_order_id) AS items "
                + "FROM sub_orders so "
                + "JOIN orders o ON o.order_id = so.order_id "
                + "JOIN users u ON u.user_id = o.customer_id "
                + "WHERE so.shop_id = ? ORDER BY so.created_at DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("subOrderCode", rs.getString("sub_order_code"));
                    m.put("orderCode", rs.getString("order_code"));
                    m.put("total", rs.getBigDecimal("shop_total").doubleValue());
                    m.put("status", rs.getString("status"));
                    m.put("createdAt", rs.getTimestamp("created_at"));
                    m.put("customer", rs.getString("customer"));
                    m.put("items", rs.getInt("items"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Số đơn đang chờ shop xử lý (NEW / CONFIRMED / PACKING), không phụ thuộc kỳ lọc. */
    public int countPendingOrders(long shopId) {
        return scalarInt("SELECT COUNT(*) FROM sub_orders WHERE shop_id = ? AND status IN ('NEW','CONFIRMED','PACKING')", shopId);
    }

    /** Số đơn đang giao. */
    public int countShippingOrders(long shopId) {
        return scalarInt("SELECT COUNT(*) FROM sub_orders WHERE shop_id = ? AND status = 'SHIPPING'", shopId);
    }

    /** Số khiếu nại đang mở (OPEN / MEDIATING). */
    public int countOpenDisputes(long shopId) {
        return scalarInt("SELECT COUNT(*) FROM disputes WHERE shop_id = ? AND status IN ('OPEN','MEDIATING')", shopId);
    }

    /** Số SKU sắp hết hàng. */
    public int countLowStock(long shopId) {
        return scalarInt("SELECT COUNT(*) FROM product_variants v JOIN products p ON p.product_id = v.product_id "
                + "WHERE p.shop_id = ? AND v.is_active = 1 AND v.stock_quantity <= v.low_stock_threshold", shopId);
    }

    /** Số đánh giá chưa phản hồi. */
    public int countUnrepliedReviews(long shopId) {
        return scalarInt("SELECT COUNT(*) FROM reviews WHERE shop_id = ? AND status = 'APPROVED' "
                + "AND (reply_comment IS NULL OR LTRIM(RTRIM(reply_comment)) = '')", shopId);
    }

    private int scalarInt(String sql, long shopId) {
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Danh sách SKU sắp hết hàng (ít nhất trước). */
    public List<Map<String, Object>> getLowStockItems(long shopId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") p.name, v.variant_name, v.sku, v.stock_quantity, v.low_stock_threshold "
                + "FROM product_variants v JOIN products p ON p.product_id = v.product_id "
                + "WHERE p.shop_id = ? AND v.is_active = 1 AND v.stock_quantity <= v.low_stock_threshold "
                + "ORDER BY v.stock_quantity ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("name"));
                    m.put("variant", rs.getString("variant_name"));
                    m.put("sku", rs.getString("sku"));
                    m.put("stock", rs.getInt("stock_quantity"));
                    m.put("threshold", rs.getInt("low_stock_threshold"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thống kê đánh giá: avg, total, c1..c5, newInPeriod.
     */
    public Map<String, Object> getRatingStats(long shopId, LocalDate from, LocalDate to) {
        Map<String, Object> m = new HashMap<>();
        int[] dist = new int[6];
        int total = 0;
        double sum = 0;
        String sql = "SELECT rating, COUNT(*) AS c FROM reviews WHERE shop_id = ? AND status = 'APPROVED' GROUP BY rating";
        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, shopId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int r = rs.getInt("rating");
                        int c = rs.getInt("c");
                        if (r >= 1 && r <= 5) {
                            dist[r] = c;
                            total += c;
                            sum += (double) r * c;
                        }
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM reviews WHERE shop_id = ? AND status = 'APPROVED' AND created_at >= ? AND created_at < ?")) {
                ps.setLong(1, shopId);
                ps.setTimestamp(2, ts(from));
                ps.setTimestamp(3, ts(to));
                try (ResultSet rs = ps.executeQuery()) {
                    m.put("newInPeriod", rs.next() ? rs.getInt(1) : 0);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            m.putIfAbsent("newInPeriod", 0);
        }
        m.put("total", total);
        m.put("avg", total > 0 ? sum / total : 0.0);
        for (int i = 1; i <= 5; i++) {
            m.put("c" + i, dist[i]);
            m.put("p" + i, total > 0 ? (int) Math.round(dist[i] * 100.0 / total) : 0);
        }
        return m;
    }

    /** Đánh giá mới nhất. */
    public List<Map<String, Object>> getLatestReviews(long shopId, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") r.rating, r.comment, r.reply_comment, r.created_at, "
                + "u.full_name AS customer, oi.product_name_snapshot AS product "
                + "FROM reviews r "
                + "JOIN users u ON u.user_id = r.customer_id "
                + "JOIN order_items oi ON oi.order_item_id = r.order_item_id "
                + "WHERE r.shop_id = ? AND r.status = 'APPROVED' ORDER BY r.created_at DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("rating", rs.getInt("rating"));
                    m.put("comment", rs.getString("comment"));
                    m.put("reply", rs.getString("reply_comment"));
                    m.put("createdAt", rs.getTimestamp("created_at"));
                    m.put("customer", rs.getString("customer"));
                    m.put("product", rs.getString("product"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Kỳ quyết toán gần nhất (ưu tiên kỳ đang xử lý). */
    public Map<String, Object> getLatestPayout(long shopId) {
        String sql = "SELECT TOP 1 cycle_name, net_payout, gross_sales, commission_withheld, status, paid_at, period_end "
                + "FROM vendor_payouts WHERE shop_id = ? "
                + "ORDER BY CASE WHEN status = 'PROCESSING' THEN 0 ELSE 1 END, period_end DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("cycle", rs.getString("cycle_name"));
                    m.put("net", rs.getBigDecimal("net_payout").doubleValue());
                    m.put("gross", rs.getBigDecimal("gross_sales").doubleValue());
                    m.put("commission", rs.getBigDecimal("commission_withheld").doubleValue());
                    m.put("status", rs.getString("status"));
                    m.put("paidAt", rs.getTimestamp("paid_at"));
                    return m;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
