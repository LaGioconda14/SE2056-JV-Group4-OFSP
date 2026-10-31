package dao;

import model.ShopRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.DBContext;

/**
 * Data Access Object for Admin subpages (Shops, Users, Categories, Vouchers, Disputes, Settlements, Products, Orders).
 */
public class AdminManagementDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(AdminManagementDAO.class.getName());
    private static final DecimalFormat CURRENCY_FORMAT = new DecimalFormat("#,### ₫");
private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy");
    private static final SimpleDateFormat DATETIME_FORMAT = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    // -------------------------------------------------------------------------
    // 1. SHOPS & VENDORS
    // -------------------------------------------------------------------------
    /** Biểu thức trạng thái "hiệu lực" của 1 hồ sơ: đã duyệt thì lấy trạng thái thật của shop (shops.status). */
    private static final String EFF_STATUS =
            "CASE WHEN sr.status = 'APPROVED' THEN COALESCE(s.status, 'ACTIVE') "
          + "     WHEN sr.status = 'PENDING_KYC' THEN 'PENDING' ELSE sr.status END";

    /**
     * Thống kê gian hàng - tính trên cùng nguồn dữ liệu với danh sách (shop_requests + shops)
     * nên số trên thẻ / tab luôn khớp với số dòng hiển thị.
     */
    public Map<String, Object> getShopStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalShops", 0);
        stats.put("approvedShops", 0);
        stats.put("activeShops", 0);
        stats.put("pendingKyc", 0);
        stats.put("rejected", 0);
        stats.put("suspended", 0);
        stats.put("paused", 0);
        stats.put("avgComm", "0.0%");
        stats.put("openDisputes", 0);
        stats.put("oldestPendingDays", -1);
        stats.put("suspendRate", "0.0");

        String sql = "SELECT COUNT(*) AS total, "
                + "COALESCE(SUM(CASE WHEN sr.status IN ('PENDING','PENDING_KYC') THEN 1 ELSE 0 END), 0) AS pending, "
                + "COALESCE(SUM(CASE WHEN sr.status = 'REJECTED' THEN 1 ELSE 0 END), 0) AS rejected, "
                + "COALESCE(SUM(CASE WHEN sr.status = 'APPROVED' THEN 1 ELSE 0 END), 0) AS approved, "
                + "COALESCE(SUM(CASE WHEN " + EFF_STATUS + " = 'ACTIVE' THEN 1 ELSE 0 END), 0) AS active, "
                + "COALESCE(SUM(CASE WHEN " + EFF_STATUS + " = 'SUSPENDED' THEN 1 ELSE 0 END), 0) AS suspended, "
                + "COALESCE(SUM(CASE WHEN " + EFF_STATUS + " IN ('PAUSED','CLOSED') THEN 1 ELSE 0 END), 0) AS paused, "
                + "MIN(CASE WHEN sr.status IN ('PENDING','PENDING_KYC') THEN sr.created_at END) AS oldest_pending "
                + "FROM shop_requests sr LEFT JOIN shops s ON s.owner_id = sr.user_id";
        try (Connection conn = getConnection()) {
            try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
                if (rs.next()) {
                    int approved = rs.getInt("approved");
                    int suspended = rs.getInt("suspended");
                    stats.put("totalShops", rs.getInt("total"));
                    stats.put("approvedShops", approved);
                    stats.put("activeShops", rs.getInt("active"));
                    stats.put("pendingKyc", rs.getInt("pending"));
                    stats.put("rejected", rs.getInt("rejected"));
                    stats.put("suspended", suspended);
                    stats.put("paused", rs.getInt("paused"));
                    stats.put("suspendRate", String.format(java.util.Locale.US, "%.1f",
                            approved > 0 ? suspended * 100.0 / approved : 0.0));
                    Timestamp oldest = rs.getTimestamp("oldest_pending");
                    if (oldest != null) {
                        long days = java.time.temporal.ChronoUnit.DAYS.between(
                                oldest.toLocalDateTime().toLocalDate(), java.time.LocalDate.now());
                        stats.put("oldestPendingDays", (int) Math.max(days, 0));
                    }
                }
            }
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT AVG(commission_rate) FROM shops WHERE status <> 'PENDING_KYC'")) {
                if (rs.next()) {
                    stats.put("avgComm", String.format(java.util.Locale.US, "%.1f%%", rs.getDouble(1)));
                }
            }
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM disputes WHERE status IN ('OPEN','MEDIATING')")) {
                if (rs.next()) {
                    stats.put("openDisputes", rs.getInt(1));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getShopStats: " + ex.getMessage());
        }
        return stats;
    }

    /** Các loại hình kinh doanh đang có trong DB (cho ô lọc). */
    public List<String> getShopBusinessTypes() {
        List<String> types = new ArrayList<>();
        String sql = "SELECT DISTINCT business_type FROM shop_requests WHERE business_type IS NOT NULL ORDER BY business_type";
        try (Connection conn = getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                types.add(rs.getString(1));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getShopBusinessTypes: " + ex.getMessage());
        }
        return types;
    }

    /**
     * Danh sách hồ sơ/gian hàng. statusFilter: ALL | ACTIVE | PENDING_KYC | SUSPENDED | REJECTED.
     * Trường "status" trả về là trạng thái hiệu lực: ACTIVE / PAUSED / CLOSED / SUSPENDED / PENDING / REJECTED.
     */
    public List<Map<String, Object>> getShopsList(String statusFilter, String typeFilter, String certFilter, String searchKeyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT sr.request_id, sr.user_id, sr.shop_name, sr.business_type, sr.province, sr.district, sr.ward, ")
           .append("       sr.street_address, sr.pickup_address, sr.return_address, sr.id_card_number, sr.tax_code, ")
           .append("       sr.id_card_front_url, sr.id_card_back_url, sr.shop_description, sr.shop_logo_url, sr.shop_banner_url, ")
           .append("       sr.bank_name, sr.bank_account_number, sr.bank_account_holder, sr.reason, sr.created_at, sr.reviewed_at, ")
           .append("       ").append(EFF_STATUS).append(" AS eff_status, ")
           .append("       u.full_name AS owner_name, u.email AS owner_email, u.phone AS owner_phone, u.birth_date AS owner_birth, ")
           .append("       rv.full_name AS reviewer_name, s.commission_rate, s.rating, ")
           .append("       sus.message AS suspend_message, sus.created_at AS suspended_at ")
           .append("FROM shop_requests sr ")
           .append("JOIN users u ON sr.user_id = u.user_id ")
           .append("LEFT JOIN users rv ON rv.user_id = sr.reviewed_by ")
           .append("LEFT JOIN shops s ON s.owner_id = sr.user_id ")
           .append("OUTER APPLY (SELECT TOP 1 n.message, n.created_at FROM notifications n ")
           .append("             WHERE n.user_id = sr.user_id AND n.type = 'SHOP_SUSPENDED' ")
           .append("             ORDER BY n.created_at DESC) sus ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        String st = statusFilter == null ? "ALL" : statusFilter.trim().toUpperCase();
        if ("ACTIVE".equals(st)) {
            conditions.add(EFF_STATUS + " = 'ACTIVE'");
        } else if ("PENDING_KYC".equals(st) || "PENDING".equals(st)) {
            conditions.add(EFF_STATUS + " = 'PENDING'");
        } else if ("SUSPENDED".equals(st)) {
            conditions.add(EFF_STATUS + " = 'SUSPENDED'");
        } else if ("REJECTED".equals(st)) {
            conditions.add(EFF_STATUS + " = 'REJECTED'");
        }

        if (typeFilter != null && !typeFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(typeFilter.trim())) {
            conditions.add("sr.business_type = ?");
            params.add(typeFilter.trim());
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(sr.shop_name) LIKE ? OR LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ? "
                    + "OR LOWER(sr.province) LIKE ? OR sr.id_card_number LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }
        sql.append("ORDER BY sr.request_id DESC");

        SimpleDateFormat dt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        SimpleDateFormat d = new SimpleDateFormat("dd/MM/yyyy");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    long reqId = rs.getLong("request_id");
                    String eff = rs.getString("eff_status");
                    item.put("requestId", reqId);
                    item.put("shopId", reqId);
                    item.put("status", eff);
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("businessType", rs.getString("business_type"));
                    item.put("province", rs.getString("province"));
                    item.put("district", rs.getString("district"));
                    item.put("ward", rs.getString("ward"));
                    item.put("streetAddress", rs.getString("street_address"));
                    item.put("pickupAddress", rs.getString("pickup_address"));
                    item.put("returnAddress", rs.getString("return_address"));
                    item.put("idCardNumber", rs.getString("id_card_number"));
                    item.put("taxCode", rs.getString("tax_code"));
                    item.put("idCardFrontUrl", rs.getString("id_card_front_url"));
                    item.put("idCardBackUrl", rs.getString("id_card_back_url"));
                    item.put("shopDescription", rs.getString("shop_description"));
                    item.put("shopLogoUrl", rs.getString("shop_logo_url"));
                    item.put("shopBannerUrl", rs.getString("shop_banner_url"));
                    item.put("bankName", rs.getString("bank_name"));
                    item.put("bankAccountNumber", rs.getString("bank_account_number"));
                    item.put("bankAccountHolder", rs.getString("bank_account_holder"));
                    item.put("ownerName", rs.getString("owner_name"));
                    item.put("ownerEmail", rs.getString("owner_email"));
                    item.put("ownerPhone", rs.getString("owner_phone"));
                    item.put("reviewerName", rs.getString("reviewer_name"));
                    java.sql.Date birth = rs.getDate("owner_birth");
                    item.put("ownerBirth", birth != null ? d.format(birth) : null);
                    Timestamp created = rs.getTimestamp("created_at");
                    item.put("createdAt", created != null ? dt.format(created) : null);
                    Timestamp reviewed = rs.getTimestamp("reviewed_at");
                    item.put("reviewedAt", reviewed != null ? dt.format(reviewed) : null);
                    item.put("rejectReason", "REJECTED".equals(eff) ? rs.getString("reason") : null);

                    if ("SUSPENDED".equals(eff)) {
                        String msg = rs.getString("suspend_message");
                        if (msg != null) {
                            int idx = msg.indexOf("Lý do: ");
                            item.put("suspendReason", idx >= 0 ? msg.substring(idx + 7) : msg);
                        }
                        Timestamp sAt = rs.getTimestamp("suspended_at");
                        item.put("suspendedAt", sAt != null ? dt.format(sAt) : null);
                    }
                    java.math.BigDecimal comm = rs.getBigDecimal("commission_rate");
                    item.put("commissionRate", comm != null ? comm.toPlainString() + "%" : null);
                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            System.err.println("Lỗi SQL tại getShopsList: " + ex.getMessage());
            ex.printStackTrace();
        }
        return list;
    }

    /** Tạm khóa gian hàng đã duyệt + gửi thông báo (kèm lý do) tới chủ shop. */
    public boolean suspendShop(int requestId, String reason, int adminId) {
        String sqlShop = "UPDATE shops SET status = 'SUSPENDED', updated_at = GETDATE() "
                + "WHERE owner_id = (SELECT user_id FROM shop_requests WHERE request_id = ?) "
                + "AND status IN ('ACTIVE','PAUSED','CLOSED')";
        String sqlNoti = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id, is_read) "
                + "SELECT sr.user_id, N'Gian hàng của bạn đã bị tạm khóa', "
                + "CONCAT(N'Gian hàng \"', sr.shop_name, N'\" đã bị Ban quản trị sàn tạm khóa. Lý do: ', ?), "
                + "'SHOP_SUSPENDED', 'SHOP_REQUEST', sr.request_id, 0 "
                + "FROM shop_requests sr WHERE sr.request_id = ?";
        return changeShopStatus(requestId, sqlShop, sqlNoti, reason);
    }

    /** Mở khóa gian hàng đang bị tạm khóa + gửi thông báo. */
    public boolean unlockShop(int requestId, int adminId) {
        String sqlShop = "UPDATE shops SET status = 'ACTIVE', updated_at = GETDATE() "
                + "WHERE owner_id = (SELECT user_id FROM shop_requests WHERE request_id = ?) "
                + "AND status = 'SUSPENDED'";
        String sqlNoti = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id, is_read) "
                + "SELECT sr.user_id, N'Gian hàng của bạn đã được mở khóa', "
                + "CONCAT(N'Gian hàng \"', sr.shop_name, N'\" đã được mở khóa và có thể hoạt động trở lại.', ?), "
                + "'SHOP_UNLOCKED', 'SHOP_REQUEST', sr.request_id, 0 "
                + "FROM shop_requests sr WHERE sr.request_id = ?";
        return changeShopStatus(requestId, sqlShop, sqlNoti, "");
    }

    private boolean changeShopStatus(int requestId, String sqlShop, String sqlNoti, String notiParam) {
        try (Connection conn = getConnection()) {
            if (conn == null) {
                return false;
            }
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlShop)) {
                    ps.setInt(1, requestId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(sqlNoti)) {
                    ps.setString(1, notiParam == null ? "" : notiParam);
                    ps.setInt(2, requestId);
                    ps.executeUpdate();
                }
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

    /** Duyệt tất cả hồ sơ đang chờ. Trả về số hồ sơ đã duyệt thành công. */
    public int approveAllPending(int adminId) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT request_id FROM shop_requests WHERE status IN ('PENDING','PENDING_KYC') ORDER BY request_id";
        try (Connection conn = getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                ids.add(rs.getInt(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        int ok = 0;
        for (int id : ids) {
            if (updateRequestStatus(id, "APPROVED", null, adminId)) {
                ok++;
            }
        }
        return ok;
    }

    /** Gửi thông báo kết quả duyệt / từ chối hồ sơ cho chủ shop (cùng transaction với việc cập nhật). */
    private void notifyRequestResult(Connection conn, int requestId, String status, String reason) throws SQLException {
        boolean approved = "APPROVED".equalsIgnoreCase(status);
        String sql = "INSERT INTO notifications (user_id, title, message, type, reference_type, reference_id, is_read) "
                + "SELECT sr.user_id, "
                + (approved ? "N'Gian hàng đã được duyệt', " : "N'Hồ sơ đăng ký gian hàng bị từ chối', ")
                + (approved
                    ? "CONCAT(N'Chúc mừng! Gian hàng \"', sr.shop_name, N'\" đã được phê duyệt và có thể bắt đầu kinh doanh trên sàn.'), "
                    : "CONCAT(N'Hồ sơ đăng ký gian hàng \"', sr.shop_name, N'\" đã bị từ chối. Lý do: ', ?), ")
                + "'KYC', 'SHOP_REQUEST', sr.request_id, 0 "
                + "FROM shop_requests sr WHERE sr.request_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            if (!approved) {
                ps.setString(i++, reason == null ? "" : reason);
            }
            ps.setInt(i, requestId);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------------------------
    // 2. USERS & ROLES
    // -------------------------------------------------------------------------
    public Map<String, Integer> getUserRoleCounts() {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("total", 0);
        counts.put("adminStaff", 0);
        counts.put("shopOwner", 0);
        counts.put("driver", 0);
        counts.put("customer", 0);
        counts.put("admin", 0);
        counts.put("staff", 0);

        String sql = "SELECT COALESCE(r.role_name, 'CUSTOMER') as role_name, COUNT(DISTINCT u.user_id) as cnt "
                   + "FROM users u "
                   + "LEFT JOIN user_roles ur ON u.user_id = ur.user_id "
                   + "LEFT JOIN roles r ON ur.role_id = r.role_id "
                   + "GROUP BY COALESCE(r.role_name, 'CUSTOMER')";

        int total = 0;
        int adminStaff = 0;
        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                String role = rs.getString("role_name");
                int cnt = rs.getInt("cnt");
                total += cnt;
                if ("ADMIN".equalsIgnoreCase(role)) {
                    counts.put("admin", cnt);
                    adminStaff += cnt;
                } else if ("STAFF".equalsIgnoreCase(role)) {
                    counts.put("staff", cnt);
                    adminStaff += cnt;
                } else if ("SHOP_OWNER".equalsIgnoreCase(role)) {
                    counts.put("shopOwner", cnt);
                } else if ("DRIVER".equalsIgnoreCase(role)) {
                    counts.put("driver", cnt);
                } else {
                    counts.put("customer", counts.getOrDefault("customer", 0) + cnt);
                }
            }
            counts.put("total", total);
            counts.put("adminStaff", adminStaff);
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getUserRoleCounts: " + ex.getMessage());
        }
        return counts;
    }

    public List<Map<String, Object>> getUsersList() {
        return getUsersList(null, null, null);
    }

    public List<Map<String, Object>> getUsersList(String roleFilter) {
        return getUsersList(roleFilter, null, null);
    }

    public List<Map<String, Object>> getUsersList(String roleFilter, String statusFilter, String searchKeyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT u.user_id, u.full_name, u.email, u.phone, u.avatar_url, u.gender, u.birth_date, ")
           .append("       u.status, u.created_at, u.decision_reason, u.decision_at, ")
           .append("       COALESCE(r.role_name, 'CUSTOMER') as role_name, ")
           .append("       s.shop_id, s.shop_name, s.status as shop_status, ")
           .append("       COALESCE(o.order_count, 0) as order_count, ")
           .append("       COALESCE(o.total_spent, 0) as total_spent, ")
           .append("       COALESCE(so.vendor_order_count, 0) as vendor_order_count, ")
           .append("       COALESCE(so.vendor_total_sales, 0) as vendor_total_sales ")
           .append("FROM users u ")
           .append("LEFT JOIN user_roles ur ON u.user_id = ur.user_id ")
           .append("LEFT JOIN roles r ON ur.role_id = r.role_id ")
           .append("LEFT JOIN shops s ON u.user_id = s.owner_id ")
           .append("LEFT JOIN (")
           .append("    SELECT customer_id, COUNT(order_id) as order_count, SUM(final_amount) as total_spent ")
           .append("    FROM orders GROUP BY customer_id")
           .append(") o ON u.user_id = o.customer_id ")
           .append("LEFT JOIN (")
           .append("    SELECT sh.owner_id, COUNT(sub_o.sub_order_id) as vendor_order_count, SUM(sub_o.shop_total) as vendor_total_sales ")
           .append("    FROM shops sh JOIN sub_orders sub_o ON sh.shop_id = sub_o.shop_id GROUP BY sh.owner_id")
           .append(") so ON u.user_id = so.owner_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter.trim())) {
            String rf = roleFilter.trim();
            if ("ADMIN_STAFF".equalsIgnoreCase(rf)) {
                conditions.add("r.role_name IN ('ADMIN', 'STAFF')");
            } else if ("ADMIN".equalsIgnoreCase(rf)) {
                conditions.add("r.role_name = 'ADMIN'");
            } else if ("STAFF".equalsIgnoreCase(rf)) {
                conditions.add("r.role_name = 'STAFF'");
            } else if ("SHOP_OWNER".equalsIgnoreCase(rf)) {
                conditions.add("r.role_name = 'SHOP_OWNER'");
            } else if ("DRIVER".equalsIgnoreCase(rf)) {
                conditions.add("r.role_name = 'DRIVER'");
            } else if ("CUSTOMER".equalsIgnoreCase(rf)) {
                conditions.add("(r.role_name = 'CUSTOMER' OR r.role_name IS NULL)");
            } else {
                conditions.add("r.role_name = ?");
                params.add(rf);
            }
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            conditions.add("u.status = ?");
            params.add(statusFilter.trim());
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(COALESCE(u.phone, '')) LIKE ? OR LOWER(COALESCE(s.shop_name, '')) LIKE ? OR CAST(u.user_id AS VARCHAR(20)) LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }
        sql.append("ORDER BY u.user_id ASC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("userId", rs.getLong("user_id"));
                    item.put("fullName", rs.getString("full_name"));
                    item.put("email", rs.getString("email"));
                    item.put("phone", rs.getString("phone") != null ? rs.getString("phone") : "Chưa cập nhật");
                    item.put("avatarUrl", rs.getString("avatar_url"));
                    item.put("gender", rs.getString("gender"));
                    item.put("roleName", rs.getString("role_name"));
                    item.put("status", rs.getString("status"));
                    item.put("shopId", rs.getObject("shop_id"));
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("shopStatus", rs.getString("shop_status"));
                    item.put("decisionReason", rs.getString("decision_reason"));

                    Timestamp decisionAt = rs.getTimestamp("decision_at");
                    item.put("decisionAtFormatted", decisionAt != null ? DATETIME_FORMAT.format(decisionAt) : null);

                    Timestamp createdAt = rs.getTimestamp("created_at");
                    item.put("createdAtFormatted", createdAt != null ? DATE_FORMAT.format(createdAt) : "-");

                    int orderCount = rs.getInt("order_count");
                    double spent = rs.getDouble("total_spent");
                    int vendorOrderCount = rs.getInt("vendor_order_count");
                    double vendorTotalSales = rs.getDouble("vendor_total_sales");

                    item.put("orderCount", orderCount);
                    item.put("totalSpent", spent);
                    item.put("totalSpentFormatted", spent > 0 ? CURRENCY_FORMAT.format(spent) : "0 ₫");
                    item.put("vendorOrderCount", vendorOrderCount);
                    item.put("vendorTotalSalesFormatted", vendorTotalSales > 0 ? CURRENCY_FORMAT.format(vendorTotalSales) : "0 ₫");

                    // Tier determination
                    String role = rs.getString("role_name");
                    if ("ADMIN".equalsIgnoreCase(role)) {
                        item.put("membershipTier", "Ban Quản Trị");
                    } else if ("STAFF".equalsIgnoreCase(role)) {
                        item.put("membershipTier", "Nhân Viên Sàn");
                    } else if ("SHOP_OWNER".equalsIgnoreCase(role)) {
                        item.put("membershipTier", "Chủ Gian Hàng");
                    } else if ("DRIVER".equalsIgnoreCase(role)) {
                        item.put("membershipTier", "Tài Xế Chuỗi Lạnh");
                    } else {
                        if (spent >= 1000000) {
                            item.put("membershipTier", "VIP Gold");
                        } else if (spent > 0) {
                            item.put("membershipTier", "Silver Member");
                        } else {
                            item.put("membershipTier", "Standard Buyer");
                        }
                    }
                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getUsersList: " + ex.getMessage());
        }
        return list;
    }

    /**
     * Get detailed information of a user: personal details, addresses, shop (if any), and transaction history.
     */
    public Map<String, Object> getUserDetail(long userId) {
        Map<String, Object> detail = new HashMap<>();

        // 1. Fetch User and Shop info
        String userSql = "SELECT u.user_id, u.full_name, u.email, u.phone, u.avatar_url, u.gender, u.birth_date, "
                       + "       u.status, u.created_at, u.updated_at, u.decision_reason, u.decision_at, "
                       + "       COALESCE(r.role_name, 'CUSTOMER') as role_name, "
                       + "       s.shop_id, s.shop_name, s.slug as shop_slug, s.business_type, s.province as shop_province, "
                       + "       s.address as shop_address, s.certification_name, s.commission_rate, s.rating as shop_rating, "
                       + "       s.total_sales_amount, s.total_orders_count, s.status as shop_status "
                       + "FROM users u "
                       + "LEFT JOIN user_roles ur ON u.user_id = ur.user_id "
                       + "LEFT JOIN roles r ON ur.role_id = r.role_id "
                       + "LEFT JOIN shops s ON u.user_id = s.owner_id "
                       + "WHERE u.user_id = ?";

        Map<String, Object> userMap = new HashMap<>();
        Map<String, Object> shopMap = null;
        String roleName = "CUSTOMER";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(userSql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userMap.put("userId", rs.getLong("user_id"));
                        userMap.put("fullName", rs.getString("full_name"));
                        userMap.put("email", rs.getString("email"));
                        userMap.put("phone", rs.getString("phone") != null ? rs.getString("phone") : "Chưa cập nhật");
                        userMap.put("avatarUrl", rs.getString("avatar_url"));
                        
                        String gender = rs.getString("gender");
                        if ("MALE".equalsIgnoreCase(gender)) {
                            userMap.put("gender", "Nam");
                        } else if ("FEMALE".equalsIgnoreCase(gender)) {
                            userMap.put("gender", "Nữ");
                        } else {
                            userMap.put("gender", "Khác");
                        }

                        java.sql.Date birthDate = rs.getDate("birth_date");
                        userMap.put("birthDate", birthDate != null ? DATE_FORMAT.format(birthDate) : "Chưa cập nhật");
                        userMap.put("status", rs.getString("status"));

                        Timestamp createdAt = rs.getTimestamp("created_at");
                        userMap.put("createdAtFormatted", createdAt != null ? DATETIME_FORMAT.format(createdAt) : "-");

                        Timestamp updatedAt = rs.getTimestamp("updated_at");
                        userMap.put("updatedAtFormatted", updatedAt != null ? DATETIME_FORMAT.format(updatedAt) : "-");

                        userMap.put("decisionReason", rs.getString("decision_reason"));
                        Timestamp decisionAt = rs.getTimestamp("decision_at");
                        userMap.put("decisionAtFormatted", decisionAt != null ? DATETIME_FORMAT.format(decisionAt) : null);

                        roleName = rs.getString("role_name");
                        userMap.put("roleName", roleName);

                        if ("ADMIN".equalsIgnoreCase(roleName)) {
                            userMap.put("roleTitle", "Quản Trị Viên Hệ Thống (SuperAdmin)");
                            userMap.put("membershipTier", "Ban Quản Trị");
                        } else if ("STAFF".equalsIgnoreCase(roleName)) {
                            userMap.put("roleTitle", "Nhân Viên Vận Hành Sàn (Staff)");
                            userMap.put("membershipTier", "Nhân Viên Sàn");
                        } else if ("SHOP_OWNER".equalsIgnoreCase(roleName)) {
                            userMap.put("roleTitle", "Chủ Gian Hàng / Đối Tác Nhà Vườn (Shop Owner)");
                            userMap.put("membershipTier", "Chủ Gian Hàng");
                        } else if ("DRIVER".equalsIgnoreCase(roleName)) {
                            userMap.put("roleTitle", "Tài Xế Giao Nhận Chuỗi Lạnh (Driver)");
                            userMap.put("membershipTier", "Tài Xế Chuỗi Lạnh");
                        } else {
                            userMap.put("roleTitle", "Khách Hàng Mua Sắm (Customer)");
                            userMap.put("membershipTier", "Standard Buyer");
                        }

                        // Shop info
                        if (rs.getObject("shop_id") != null) {
                            shopMap = new HashMap<>();
                            shopMap.put("shopId", rs.getLong("shop_id"));
                            shopMap.put("shopName", rs.getString("shop_name"));
                            shopMap.put("slug", rs.getString("shop_slug"));
                            shopMap.put("businessType", rs.getString("business_type"));
                            shopMap.put("province", rs.getString("shop_province"));
                            shopMap.put("address", rs.getString("shop_address"));
                            shopMap.put("certificationName", rs.getString("certification_name"));
                            shopMap.put("commissionRate", String.format("%.1f%%", rs.getDouble("commission_rate")));
                            shopMap.put("rating", String.format("%.2f", rs.getDouble("shop_rating")));
                            shopMap.put("totalSalesFormatted", CURRENCY_FORMAT.format(rs.getDouble("total_sales_amount")));
                            shopMap.put("totalOrdersCount", rs.getInt("total_orders_count"));
                            shopMap.put("status", rs.getString("shop_status"));
                        }
                    } else {
                        return null; // User not found
                    }
                }
            }

            detail.put("user", userMap);
            detail.put("shop", shopMap);

            // 2. Fetch Customer Addresses
            List<Map<String, Object>> addresses = new ArrayList<>();
            String addrSql = "SELECT address_id, recipient_name, recipient_phone, street_address, ward, district, city, is_default, created_at "
                           + "FROM customer_addresses WHERE user_id = ? ORDER BY is_default DESC, address_id ASC";
            try (PreparedStatement ps = conn.prepareStatement(addrSql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> addr = new HashMap<>();
                        addr.put("addressId", rs.getLong("address_id"));
                        addr.put("recipientName", rs.getString("recipient_name"));
                        addr.put("recipientPhone", rs.getString("recipient_phone"));
                        addr.put("streetAddress", rs.getString("street_address"));
                        addr.put("ward", rs.getString("ward"));
                        addr.put("district", rs.getString("district"));
                        addr.put("city", rs.getString("city"));
                        addr.put("fullAddress", rs.getString("street_address") + ", " + rs.getString("ward") + ", " + rs.getString("district") + ", " + rs.getString("city"));
                        addr.put("isDefault", rs.getBoolean("is_default"));
                        addresses.add(addr);
                    }
                }
            }
            detail.put("addresses", addresses);

            // 3. Fetch Orders History (as Customer)
            List<Map<String, Object>> orders = new ArrayList<>();
            double totalSpent = 0;
            int completedCount = 0;
            int cancelledCount = 0;

            String orderSql = "SELECT o.order_id, o.order_code, o.total_goods_amount, o.total_shipping_fee, "
                            + "       o.platform_discount, o.final_amount, o.payment_status, o.payment_method, "
                            + "       o.order_status, o.created_at, "
                            + "       (SELECT COUNT(*) FROM sub_orders so JOIN order_items oi ON so.sub_order_id = oi.sub_order_id WHERE so.order_id = o.order_id) as items_count "
                            + "FROM orders o "
                            + "WHERE o.customer_id = ? "
                            + "ORDER BY o.created_at DESC";

            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> o = new HashMap<>();
                        o.put("orderId", rs.getLong("order_id"));
                        o.put("orderCode", rs.getString("order_code"));
                        double amt = rs.getDouble("final_amount");
                        totalSpent += amt;
                        o.put("finalAmount", amt);
                        o.put("finalAmountFormatted", CURRENCY_FORMAT.format(amt));
                        o.put("paymentStatus", rs.getString("payment_status"));
                        o.put("paymentMethod", rs.getString("payment_method"));
                        String oStatus = rs.getString("order_status");
                        o.put("orderStatus", oStatus);
                        if ("COMPLETED".equalsIgnoreCase(oStatus)) {
                            completedCount++;
                        } else if ("CANCELLED".equalsIgnoreCase(oStatus)) {
                            cancelledCount++;
                        }
                        o.put("itemsCount", rs.getInt("items_count"));
                        Timestamp oct = rs.getTimestamp("created_at");
                        o.put("createdAtFormatted", oct != null ? DATETIME_FORMAT.format(oct) : "-");
                        orders.add(o);
                    }
                }
            }
            detail.put("orders", orders);

            // Update membership tier if customer spent
            if ("CUSTOMER".equalsIgnoreCase(roleName)) {
                if (totalSpent >= 1000000) {
                    userMap.put("membershipTier", "VIP Gold");
                } else if (totalSpent > 0) {
                    userMap.put("membershipTier", "Silver Member");
                } else {
                    userMap.put("membershipTier", "Standard Buyer");
                }
            }

            // 4. Fetch Vendor Orders (if Shop Owner)
            List<Map<String, Object>> vendorOrders = new ArrayList<>();
            if (shopMap != null) {
                String vendorOrderSql = "SELECT so.sub_order_id, so.sub_order_code, so.order_id, so.delivery_slot, "
                                      + "       so.shop_total, so.commission_rate, so.commission_amount, so.status, so.created_at, "
                                      + "       u.full_name as buyer_name, u.phone as buyer_phone "
                                      + "FROM sub_orders so "
                                      + "JOIN shops s ON so.shop_id = s.shop_id "
                                      + "JOIN orders o ON so.order_id = o.order_id "
                                      + "JOIN users u ON o.customer_id = u.user_id "
                                      + "WHERE s.owner_id = ? "
                                      + "ORDER BY so.created_at DESC";

                try (PreparedStatement ps = conn.prepareStatement(vendorOrderSql)) {
                    ps.setLong(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> vo = new HashMap<>();
                            vo.put("subOrderId", rs.getLong("sub_order_id"));
                            vo.put("subOrderCode", rs.getString("sub_order_code"));
                            vo.put("orderId", rs.getLong("order_id"));
                            double shopTotal = rs.getDouble("shop_total");
                            vo.put("shopTotalFormatted", CURRENCY_FORMAT.format(shopTotal));
                            vo.put("commissionAmountFormatted", CURRENCY_FORMAT.format(rs.getDouble("commission_amount")));
                            vo.put("status", rs.getString("status"));
                            vo.put("buyerName", rs.getString("buyer_name"));
                            vo.put("buyerPhone", rs.getString("buyer_phone"));
                            Timestamp voTime = rs.getTimestamp("created_at");
                            vo.put("createdAtFormatted", voTime != null ? DATETIME_FORMAT.format(voTime) : "-");
                            vendorOrders.add(vo);
                        }
                    }
                }
            }
            detail.put("vendorOrders", vendorOrders);

            // 5. Fetch Status Logs
            List<Map<String, Object>> statusLogs = new ArrayList<>();
            String logSql = "SELECT log_id, old_status, new_status, decision_reason, changed_by, created_at "
                          + "FROM user_status_logs WHERE user_id = ? ORDER BY created_at DESC";
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> l = new HashMap<>();
                        l.put("logId", rs.getLong("log_id"));
                        l.put("oldStatus", rs.getString("old_status"));
                        l.put("newStatus", rs.getString("new_status"));
                        l.put("decisionReason", rs.getString("decision_reason"));
                        l.put("changedBy", rs.getString("changed_by"));
                        Timestamp lt = rs.getTimestamp("created_at");
                        l.put("createdAtFormatted", lt != null ? DATETIME_FORMAT.format(lt) : "-");
                        statusLogs.add(l);
                    }
                }
            } catch (SQLException ex) {
                LOGGER.log(Level.INFO, "Note: user_status_logs query skipped or empty: " + ex.getMessage());
            }
            detail.put("statusLogs", statusLogs);

            // 6. Aggregate Stats
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalOrders", orders.size());
            stats.put("totalSpent", totalSpent);
            stats.put("totalSpentFormatted", CURRENCY_FORMAT.format(totalSpent));
            stats.put("completedOrders", completedCount);
            stats.put("cancelledOrders", cancelledCount);
            stats.put("pendingOrders", orders.size() - completedCount - cancelledCount);
            detail.put("stats", stats);

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getUserDetail for userId=" + userId, ex);
        }

        return detail;
    }

    /**
     * Lock or unlock a user (Soft Delete / Recovery) with mandatory decision reason for audit logging.
     */
    public boolean updateUserStatus(long userId, String newStatus, String decisionReason, String adminIdentifier) {
        if (newStatus == null || (!"ACTIVE".equalsIgnoreCase(newStatus) && !"BLOCKED".equalsIgnoreCase(newStatus) && !"INACTIVE".equalsIgnoreCase(newStatus))) {
            return false;
        }

        String getOldStatusSql = "SELECT status FROM users WHERE user_id = ?";
        String updateUserSql = "UPDATE users SET status = ?, decision_reason = ?, decision_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        String insertLogSql = "INSERT INTO user_status_logs (user_id, old_status, new_status, decision_reason, changed_by, created_at) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            String oldStatus = null;

            try (PreparedStatement psOld = conn.prepareStatement(getOldStatusSql)) {
                psOld.setLong(1, userId);
                try (ResultSet rs = psOld.executeQuery()) {
                    if (rs.next()) {
                        oldStatus = rs.getString("status");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(updateUserSql)) {
                psUpdate.setString(1, newStatus.toUpperCase());
                psUpdate.setString(2, decisionReason);
                psUpdate.setLong(3, userId);
                psUpdate.executeUpdate();
            }

            try (PreparedStatement psLog = conn.prepareStatement(insertLogSql)) {
                psLog.setLong(1, userId);
                psLog.setString(2, oldStatus);
                psLog.setString(3, newStatus.toUpperCase());
                psLog.setString(4, decisionReason);
                psLog.setString(5, adminIdentifier != null ? adminIdentifier : "admin@freshfruit.com");
                psLog.executeUpdate();
            } catch (SQLException logEx) {
                LOGGER.log(Level.WARNING, "Warning inserting user_status_logs: " + logEx.getMessage());
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating status for user_id=" + userId, ex);
            return false;
        }
    }

    // -------------------------------------------------------------------------
    // 3. CATEGORIES
    // -------------------------------------------------------------------------
    public List<Map<String, Object>> getCategoriesList() {
        return getCategoriesList(null, null, null);
    }

    public List<Map<String, Object>> getCategoriesList(String statusFilter, String searchKeyword) {
        return getCategoriesList(statusFilter, searchKeyword, null);
    }

    public List<Map<String, Object>> getCategoriesList(String statusFilter, String searchKeyword, String parentIdFilter) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.category_id, c.parent_id, c.category_name, c.slug, c.description, c.image_url, c.icon_class, c.display_order, c.is_active, ")
           .append("       pcat.category_name as parent_name, ")
           .append("       COALESCE(p.active_skus, 0) as active_skus ")
           .append("FROM categories c ")
           .append("LEFT JOIN categories pcat ON c.parent_id = pcat.category_id ")
           .append("LEFT JOIN (")
           .append("    SELECT category_id, COUNT(product_id) as active_skus ")
           .append("    FROM products WHERE is_active = 1 GROUP BY category_id")
           .append(") p ON c.category_id = p.category_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (parentIdFilter != null && !parentIdFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(parentIdFilter.trim())) {
            try {
                int pid = Integer.parseInt(parentIdFilter.trim());
                conditions.add("c.parent_id = ?");
                params.add(pid);
            } catch (NumberFormatException ignored) {}
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            if ("ACTIVE".equalsIgnoreCase(statusFilter.trim()) || "1".equals(statusFilter.trim())) {
                conditions.add("c.is_active = 1");
            } else if ("INACTIVE".equalsIgnoreCase(statusFilter.trim()) || "0".equals(statusFilter.trim())) {
                conditions.add("c.is_active = 0");
            }
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(c.category_name) LIKE ? OR LOWER(c.slug) LIKE ? OR LOWER(c.description) LIKE ? OR LOWER(pcat.category_name) LIKE ? OR CAST(c.category_id AS VARCHAR(20)) LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }
        sql.append("ORDER BY COALESCE(c.parent_id, c.category_id) ASC, c.display_order ASC, c.category_id ASC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    int id = rs.getInt("category_id");
                    item.put("categoryId", id);
                    item.put("parentId", rs.getObject("parent_id"));
                    item.put("parentName", rs.getString("parent_name"));
                    item.put("categoryName", rs.getString("category_name"));
                    item.put("slug", rs.getString("slug"));
                    item.put("description", rs.getString("description"));
                    item.put("imageUrl", rs.getString("image_url"));
                    item.put("iconClass", rs.getString("icon_class"));
                    item.put("activeSkus", rs.getInt("active_skus"));
                    item.put("displayOrder", rs.getInt("display_order"));
                    item.put("isActive", rs.getBoolean("is_active"));

                    // Cold Storage details by category group
                    int pid = rs.getInt("parent_id");
                    if (id == 5 || pid == 5) {
                        item.put("tempRange", "1°C – 3°C");
                        item.put("recommendedStorage", "Kho lạnh ngoại nhập Hub A");
                    } else if (id == 6 || pid == 6) {
                        item.put("tempRange", "10°C – 14°C");
                        item.put("recommendedStorage", "Kho thoáng mát Vùng 3");
                    } else if (id == 7 || pid == 7) {
                        item.put("tempRange", "0°C – 2°C");
                        item.put("recommendedStorage", "Hầm lạnh sơ chế Eat-Clean");
                    } else if (id == 8 || pid == 8) {
                        item.put("tempRange", "4°C – 8°C");
                        item.put("recommendedStorage", "Kho đóng gói nguyên kiện Hub C");
                    } else if (id == 9 || pid == 9) {
                        item.put("tempRange", "8°C – 12°C");
                        item.put("recommendedStorage", "Kho trữ mát mùa hè");
                    } else {
                        item.put("tempRange", "2°C – 5°C");
                        item.put("recommendedStorage", "Kho lạnh tiêu chuẩn");
                    }
                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getCategoriesList: " + ex.getMessage());
        }
        return list;
    }

    public List<Map<String, Object>> getFruitMegaMenuCategories() {
        List<Map<String, Object>> list = new ArrayList<>();
        // Select Level 1 root categories (parent_id IS NULL)
        String sql = "SELECT c.category_id, c.category_name, c.slug, c.description, c.image_url, c.icon_class, c.is_active "
                   + "FROM categories c WHERE c.parent_id IS NULL ORDER BY c.display_order ASC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                int catId = rs.getInt("category_id");
                item.put("categoryId", catId);
                item.put("categoryName", rs.getString("category_name"));
                item.put("slug", rs.getString("slug"));
                item.put("description", rs.getString("description"));
                item.put("imageUrl", rs.getString("image_url"));
                item.put("iconClass", rs.getString("icon_class"));
                item.put("isActive", rs.getBoolean("is_active"));

                // Load sub-items (Level 3)
                List<Map<String, Object>> subItems = new ArrayList<>();
                String subSql = "SELECT c.category_id, c.category_name, c.slug, COALESCE(p.active_skus, 0) as active_skus "
                              + "FROM categories c "
                              + "LEFT JOIN ("
                              + "    SELECT category_id, COUNT(product_id) as active_skus "
                              + "    FROM products WHERE is_active = 1 GROUP BY category_id"
                              + ") p ON c.category_id = p.category_id "
                              + "WHERE c.parent_id = ? ORDER BY c.display_order ASC";
                try (PreparedStatement subPs = conn.prepareStatement(subSql)) {
                    subPs.setInt(1, catId);
                    try (ResultSet subRs = subPs.executeQuery()) {
                        int totalGroupSkus = 0;
                        while (subRs.next()) {
                            Map<String, Object> sub = new HashMap<>();
                            sub.put("categoryId", subRs.getInt("category_id"));
                            sub.put("categoryName", subRs.getString("category_name"));
                            sub.put("slug", subRs.getString("slug"));
                            int skus = subRs.getInt("active_skus");
                            sub.put("activeSkus", skus);
                            totalGroupSkus += skus;
                            subItems.add(sub);
                        }
                        item.put("subCategories", subItems);
                        item.put("totalSkus", totalGroupSkus);
                    }
                }
                list.add(item);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getFruitMegaMenuCategories: " + ex.getMessage());
        }
        return list;
    }

    public static String toSlug(String input) {
        if (input == null || input.trim().isEmpty()) {
            return "";
        }
        String text = input.trim();
        text = text.replaceAll("[đĐ]", "d");
        String normalized = Normalizer.normalize(text, Normalizer.Form.NFD);
        return normalized.replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                         .toLowerCase()
                         .replaceAll("[^a-z0-9]+", "-")
                         .replaceAll("^-+|-+$", "");
    }

    public Map<String, Object> getCategoryDetail(int categoryId) {
        String sql = "SELECT c.category_id, c.parent_id, c.category_name, c.slug, c.description, c.image_url, c.icon_class, c.display_order, c.is_active, "
                   + "       pcat.category_name as parent_name, "
                   + "       (SELECT COUNT(*) FROM products WHERE category_id = c.category_id) as total_products, "
                   + "       (SELECT COUNT(*) FROM categories WHERE parent_id = c.category_id) as child_categories_count "
                   + "FROM categories c "
                   + "LEFT JOIN categories pcat ON c.parent_id = pcat.category_id "
                   + "WHERE c.category_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("categoryId", rs.getInt("category_id"));
                    map.put("parentId", rs.getObject("parent_id"));
                    map.put("parentName", rs.getString("parent_name"));
                    map.put("categoryName", rs.getString("category_name"));
                    map.put("slug", rs.getString("slug"));
                    map.put("description", rs.getString("description"));
                    map.put("imageUrl", rs.getString("image_url"));
                    map.put("iconClass", rs.getString("icon_class"));
                    map.put("displayOrder", rs.getInt("display_order"));
                    map.put("isActive", rs.getBoolean("is_active"));
                    map.put("totalProducts", rs.getInt("total_products"));
                    map.put("childCategoriesCount", rs.getInt("child_categories_count"));
                    return map;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getCategoryDetail: " + ex.getMessage());
        }
        return null;
    }

    public boolean addCategory(String name, String slug, String description, Integer parentId, String iconClass, String imageUrl, int displayOrder, boolean isActive) {
        if (slug == null || slug.trim().isEmpty()) {
            slug = toSlug(name);
        } else {
            slug = toSlug(slug);
        }
        String sql = "INSERT INTO categories (category_name, slug, description, parent_id, icon_class, image_url, display_order, is_active) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name != null ? name.trim() : "");
            ps.setString(2, slug);
            ps.setString(3, description != null && !description.trim().isEmpty() ? description.trim() : null);
            if (parentId != null && parentId > 0) {
                ps.setInt(4, parentId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setString(5, iconClass != null && !iconClass.trim().isEmpty() ? iconClass.trim() : "bi-folder");
            ps.setString(6, imageUrl != null && !imageUrl.trim().isEmpty() ? imageUrl.trim() : null);
            ps.setInt(7, displayOrder);
            ps.setBoolean(8, isActive);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in addCategory: " + ex.getMessage(), ex);
            return false;
        }
    }

    public boolean updateCategory(int categoryId, String name, String slug, String description, Integer parentId, String iconClass, String imageUrl, int displayOrder, boolean isActive) {
        if (slug == null || slug.trim().isEmpty()) {
            slug = toSlug(name);
        } else {
            slug = toSlug(slug);
        }
        String sql = "UPDATE categories SET category_name = ?, slug = ?, description = ?, parent_id = ?, icon_class = ?, image_url = ?, display_order = ?, is_active = ? "
                   + "WHERE category_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name != null ? name.trim() : "");
            ps.setString(2, slug);
            ps.setString(3, description != null && !description.trim().isEmpty() ? description.trim() : null);
            if (parentId != null && parentId > 0 && parentId != categoryId) {
                ps.setInt(4, parentId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setString(5, iconClass != null && !iconClass.trim().isEmpty() ? iconClass.trim() : "bi-folder");
            ps.setString(6, imageUrl != null && !imageUrl.trim().isEmpty() ? imageUrl.trim() : null);
            ps.setInt(7, displayOrder);
            ps.setBoolean(8, isActive);
            ps.setInt(9, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in updateCategory: " + ex.getMessage(), ex);
            return false;
        }
    }

    public boolean toggleCategoryStatus(int categoryId, boolean isActive) {
        String sql = "UPDATE categories SET is_active = ? WHERE category_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in toggleCategoryStatus: " + ex.getMessage());
            return false;
        }
    }

    public boolean deleteCategory(int categoryId) throws IllegalStateException, SQLException {
        try (Connection conn = getConnection()) {
            // 1. Kiểm tra ràng buộc dữ liệu: Chặn xóa cứng nếu đã có sản phẩm thuộc danh mục đó
            String checkProductsSql = "SELECT COUNT(*) FROM products WHERE category_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkProductsSql)) {
                ps.setInt(1, categoryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int prodCount = rs.getInt(1);
                        if (prodCount > 0) {
                            throw new IllegalStateException("Không thể xóa danh mục này vì đang có " + prodCount + " sản phẩm trực thuộc! Vui lòng chuyển các sản phẩm sang danh mục khác hoặc chỉ tắt hiển thị (is_active = 0).");
                        }
                    }
                }
            }

            // 2. Chặn xóa nếu đang có danh mục con trực thuộc
            String checkChildSql = "SELECT COUNT(*) FROM categories WHERE parent_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkChildSql)) {
                ps.setInt(1, categoryId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int childCount = rs.getInt(1);
                        if (childCount > 0) {
                            throw new IllegalStateException("Không thể xóa danh mục này vì đang có " + childCount + " danh mục con trực thuộc! Vui lòng xóa hoặc di chuyển các danh mục con trước.");
                        }
                    }
                }
            }

            // 3. Thực hiện xóa danh mục nếu không vướng ràng buộc
            String deleteSql = "DELETE FROM categories WHERE category_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setInt(1, categoryId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. VOUCHERS / COUPONS (QUẢN LÝ KHUYẾN MÃI TOÀN SÀN & GIÁM SÁT VOUCHER SHOP)
    // -------------------------------------------------------------------------

    /**
     * Get aggregate statistics for platform & shop vouchers.
     */
    public Map<String, Object> getVoucherStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                   + "    COUNT(*) as total_count, "
                   + "    SUM(CASE WHEN shop_id IS NULL OR sponsor_type = 'PLATFORM' THEN 1 ELSE 0 END) as platform_count, "
                   + "    SUM(CASE WHEN shop_id IS NOT NULL OR sponsor_type = 'VENDOR' THEN 1 ELSE 0 END) as shop_count, "
                   + "    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active_count, "
                   + "    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive_count, "
                   + "    COALESCE(SUM(used_count), 0) as total_used, "
                   + "    SUM(CASE WHEN (shop_id IS NOT NULL OR sponsor_type = 'VENDOR') AND ((discount_type = 'PERCENTAGE' AND discount_value > 50) OR (discount_type = 'FIXED_AMOUNT' AND (discount_value >= min_order_value OR discount_value > 200000))) THEN 1 ELSE 0 END) as flagged_count, "
                   + "    COALESCE((SELECT SUM(o.platform_discount) FROM orders o WHERE o.coupon_id IS NOT NULL), 0) as total_discount_granted "
                   + "FROM coupons";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                stats.put("totalVouchers", rs.getInt("total_count"));
                stats.put("platformCount", rs.getInt("platform_count"));
                stats.put("shopCount", rs.getInt("shop_count"));
                stats.put("activeCount", rs.getInt("active_count"));
                stats.put("inactiveCount", rs.getInt("inactive_count"));
                stats.put("totalUsed", rs.getInt("total_used"));
                stats.put("flaggedCount", rs.getInt("flagged_count"));
                
                double granted = rs.getDouble("total_discount_granted");
                stats.put("totalDiscountGranted", granted);
                stats.put("totalDiscountGrantedFormatted", granted > 0 ? CURRENCY_FORMAT.format(granted) : "130,000 ₫");
                
                // Estimated GMV generated through coupons
                double gmv = rs.getInt("total_used") * 320000.0;
                stats.put("totalGmvFormatted", CURRENCY_FORMAT.format(gmv));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getVoucherStats: " + ex.getMessage());
        }
        return stats;
    }

    public List<Map<String, Object>> getVouchersList() {
        return getVouchersList(null, null, null);
    }

    /**
     * Get list of vouchers with filtering by sponsor (PLATFORM vs VENDOR/SHOP), status, and keyword.
     */
    public List<Map<String, Object>> getVouchersList(String sponsorFilter, String statusFilter, String searchKeyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.coupon_id, c.shop_id, c.code, c.title, c.discount_type, c.discount_value, ")
           .append("       c.min_order_value, c.max_discount_amount, c.usage_limit, c.used_count, ")
           .append("       c.sponsor_type, c.start_date, c.end_date, c.is_active, c.created_at, ")
           .append("       s.shop_name, s.phone as shop_phone, s.province as shop_province ")
           .append("FROM coupons c ")
           .append("LEFT JOIN shops s ON c.shop_id = s.shop_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (sponsorFilter != null && !sponsorFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(sponsorFilter.trim())) {
            String sf = sponsorFilter.trim();
            if ("PLATFORM".equalsIgnoreCase(sf)) {
                conditions.add("(c.shop_id IS NULL OR c.sponsor_type = 'PLATFORM')");
            } else if ("VENDOR".equalsIgnoreCase(sf) || "SHOP".equalsIgnoreCase(sf)) {
                conditions.add("(c.shop_id IS NOT NULL OR c.sponsor_type = 'VENDOR')");
            } else if ("FLAGGED".equalsIgnoreCase(sf)) {
                conditions.add("(c.shop_id IS NOT NULL OR c.sponsor_type = 'VENDOR') AND ((c.discount_type = 'PERCENTAGE' AND c.discount_value > 50) OR (c.discount_type = 'FIXED_AMOUNT' AND (c.discount_value >= c.min_order_value OR c.discount_value > 200000)))");
            }
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            if ("ACTIVE".equalsIgnoreCase(statusFilter.trim())) {
                conditions.add("c.is_active = 1");
            } else if ("INACTIVE".equalsIgnoreCase(statusFilter.trim()) || "PAUSED".equalsIgnoreCase(statusFilter.trim()) || "BLOCKED".equalsIgnoreCase(statusFilter.trim())) {
                conditions.add("c.is_active = 0");
            }
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(c.code) LIKE ? OR LOWER(c.title) LIKE ? OR LOWER(COALESCE(s.shop_name, '')) LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }

        sql.append("ORDER BY (CASE WHEN (c.shop_id IS NOT NULL AND ((c.discount_type = 'PERCENTAGE' AND c.discount_value > 50) OR (c.discount_value >= c.min_order_value))) THEN 0 ELSE 1 END) ASC, c.coupon_id DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    int cid = rs.getInt("coupon_id");
                    item.put("couponId", cid);
                    Long shopId = rs.getObject("shop_id") != null ? rs.getLong("shop_id") : null;
                    item.put("shopId", shopId);
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("shopPhone", rs.getString("shop_phone"));
                    item.put("shopProvince", rs.getString("shop_province"));
                    boolean isShopVoucher = shopId != null;
                    item.put("isShopVoucher", isShopVoucher);

                    String code = rs.getString("code");
                    item.put("code", code);
                    item.put("couponCode", code);
                    item.put("title", rs.getString("title"));

                    String type = rs.getString("discount_type");
                    item.put("rawDiscountType", type);
                    double val = rs.getDouble("discount_value");
                    item.put("discountValue", val);
                    double minOrder = rs.getDouble("min_order_value");
                    item.put("minOrderValue", minOrder);
                    Double maxDiscount = rs.getObject("max_discount_amount") != null ? rs.getDouble("max_discount_amount") : null;
                    item.put("maxDiscountAmount", maxDiscount);

                    int used = rs.getInt("used_count");
                    int limit = rs.getInt("usage_limit");
                    item.put("usedCount", used);
                    item.put("usageLimit", limit);
                    item.put("remainingCount", Math.max(0, limit - used));
                    item.put("usageFormatted", used + " / " + limit + " mã");

                    String sponsor = rs.getString("sponsor_type");
                    item.put("rawSponsorType", sponsor);
                    boolean isActive = rs.getBoolean("is_active");
                    item.put("isActive", isActive);

                    Timestamp sDate = rs.getTimestamp("start_date");
                    Timestamp eDate = rs.getTimestamp("end_date");
                    item.put("startDateFormatted", sDate != null ? DATE_FORMAT.format(sDate) : "-");
                    item.put("endDateFormatted", eDate != null ? DATE_FORMAT.format(eDate) : "-");
                    item.put("startDateInput", sDate != null ? new SimpleDateFormat("yyyy-MM-dd").format(sDate) : "");
                    item.put("endDateInput", eDate != null ? new SimpleDateFormat("yyyy-MM-dd").format(eDate) : "");

                    // Fraud detection heuristic for shop vouchers:
                    // 1. Discount percentage > 50%
                    // 2. Fixed amount discount >= min_order_value (free orders abuse)
                    // 3. Fixed amount > 200,000 VND
                    boolean isSuspicious = false;
                    String fraudReason = null;
                    if (isShopVoucher) {
                        if ("PERCENTAGE".equalsIgnoreCase(type) && val > 50) {
                            isSuspicious = true;
                            fraudReason = "Chiết khấu quá cao (" + String.format("%.0f%%", val) + " > 50%). Nghi vấn tạo mã ảo lách phí!";
                        } else if ("FIXED_AMOUNT".equalsIgnoreCase(type) && val >= minOrder && minOrder > 0) {
                            isSuspicious = true;
                            fraudReason = "Mức giảm (" + CURRENCY_FORMAT.format(val) + ") lớn hơn hoặc bằng giá trị đơn (" + CURRENCY_FORMAT.format(minOrder) + "). Nguy cơ gian lận đơn 0 đồng!";
                        } else if (val > 200000) {
                            isSuspicious = true;
                            fraudReason = "Giá trị giảm tiền mặt bất thường (> 200,000 ₫). Cần kiểm tra đối soát nguồn hàng!";
                        }
                    }
                    item.put("isSuspicious", isSuspicious);
                    item.put("fraudReason", fraudReason);

                    // Visual Ticket Styling & Formatting
                    if ("PERCENTAGE".equalsIgnoreCase(type)) {
                        item.put("discountType", "discount");
                        item.put("stubVal", String.format("%.0f%%", val));
                        item.put("stubTag", isShopVoucher ? "SHOP VOUCHER" : "OCOP VIỆT");
                        item.put("stubBg", isShopVoucher ? "#fef3c7" : "#dcfce7");
                        item.put("stubColor", isShopVoucher ? "#b45309" : "#15803d");
                        item.put("stubIcon", isShopVoucher ? "bi-shop" : "bi-flower1");
                        String maxDesc = maxDiscount != null && maxDiscount > 0 ? " (Tối đa " + CURRENCY_FORMAT.format(maxDiscount) + ")" : "";
                        item.put("discountFormatted", String.format("Giảm %.0f%%%s", val, maxDesc));
                    } else if ("FREESHIP".equalsIgnoreCase(type)) {
                        item.put("discountType", "freeship");
                        item.put("stubVal", "SHIP");
                        item.put("stubTag", "CHUỖI LẠNH");
                        item.put("stubBg", "#e0f2fe");
                        item.put("stubColor", "#0369a1");
                        item.put("stubIcon", "bi-snow2");
                        String maxDesc = maxDiscount != null && maxDiscount > 0 ? " (Tối đa " + CURRENCY_FORMAT.format(maxDiscount) + ")" : "";
                        item.put("discountFormatted", "100% Phí Vận Chuyển Chuỗi Lạnh" + maxDesc);
                    } else {
                        item.put("discountType", cid % 2 == 0 ? "flash" : "welcome");
                        item.put("stubVal", String.format("%.0fK", val / 1000));
                        item.put("stubTag", isShopVoucher ? "GIAN HÀNG" : (cid % 2 == 0 ? "GIỜ VÀNG" : "BẠN MỚI"));
                        item.put("stubBg", isShopVoucher ? "#f1f5f9" : (cid % 2 == 0 ? "#ffedd5" : "#ede9fe"));
                        item.put("stubColor", isShopVoucher ? "#334155" : (cid % 2 == 0 ? "#ea580c" : "#7c3aed"));
                        item.put("stubIcon", isShopVoucher ? "bi-tags-fill" : (cid % 2 == 0 ? "bi-lightning-charge-fill" : "bi-person-check-fill"));
                        item.put("discountFormatted", "Giảm trực tiếp " + CURRENCY_FORMAT.format(val));
                    }

                    item.put("minSpendFormatted", CURRENCY_FORMAT.format(minOrder));
                    item.put("maxDiscountFormatted", maxDiscount != null ? CURRENCY_FORMAT.format(maxDiscount) : "Không giới hạn");

                    if ("PLATFORM".equalsIgnoreCase(sponsor)) {
                        item.put("sponsorType", "platform");
                        item.put("sponsorTag", "100% SÀN TÀI TRỢ");
                        item.put("sponsorBadgeClass", "bg-success-subtle text-success border border-success-subtle");
                    } else if ("COFUNDING".equalsIgnoreCase(sponsor)) {
                        item.put("sponsorType", "cofunding");
                        item.put("sponsorTag", "ĐỒNG TÀI TRỢ 65/35");
                        item.put("sponsorBadgeClass", "bg-primary-subtle text-primary border border-primary-subtle");
                    } else {
                        item.put("sponsorType", "vendor");
                        item.put("sponsorTag", "GIAN HÀNG TỰ TÀI TRỢ");
                        item.put("sponsorBadgeClass", "bg-warning-subtle text-warning-emphasis border border-warning-subtle");
                    }

                    int pct = limit > 0 ? (int) Math.round((double) used * 100.0 / limit) : 0;
                    item.put("percentUsed", pct);

                    double estGmv = used * Math.max(minOrder, 150000.0);
                    double estBudgetUsed = used * (val > 100 ? val : (val * 2000));
                    item.put("gmvFormatted", CURRENCY_FORMAT.format(estGmv));
                    item.put("budgetUsedFormatted", CURRENCY_FORMAT.format(estBudgetUsed));

                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getVouchersList: " + ex.getMessage());
        }
        return list;
    }

    /**
     * Get details of a single coupon.
     */
    public Map<String, Object> getCouponDetail(int couponId) {
        String sql = "SELECT c.coupon_id, c.shop_id, c.code, c.title, c.discount_type, c.discount_value, "
                   + "       c.min_order_value, c.max_discount_amount, c.usage_limit, c.used_count, "
                   + "       c.sponsor_type, c.start_date, c.end_date, c.is_active, c.created_at, "
                   + "       s.shop_name, s.phone as shop_phone "
                   + "FROM coupons c "
                   + "LEFT JOIN shops s ON c.shop_id = s.shop_id "
                   + "WHERE c.coupon_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("couponId", rs.getInt("coupon_id"));
                    item.put("shopId", rs.getObject("shop_id"));
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("code", rs.getString("code"));
                    item.put("title", rs.getString("title"));
                    item.put("discountType", rs.getString("discount_type"));
                    item.put("discountValue", rs.getDouble("discount_value"));
                    item.put("minOrderValue", rs.getDouble("min_order_value"));
                    item.put("maxDiscountAmount", rs.getObject("max_discount_amount") != null ? rs.getDouble("max_discount_amount") : null);
                    item.put("usageLimit", rs.getInt("usage_limit"));
                    item.put("usedCount", rs.getInt("used_count"));
                    item.put("sponsorType", rs.getString("sponsor_type"));
                    item.put("isActive", rs.getBoolean("is_active"));

                    Timestamp sDate = rs.getTimestamp("start_date");
                    Timestamp eDate = rs.getTimestamp("end_date");
                    item.put("startDateInput", sDate != null ? new SimpleDateFormat("yyyy-MM-dd").format(sDate) : "");
                    item.put("endDateInput", eDate != null ? new SimpleDateFormat("yyyy-MM-dd").format(eDate) : "");
                    item.put("startDateFormatted", sDate != null ? DATE_FORMAT.format(sDate) : "");
                    item.put("endDateFormatted", eDate != null ? DATE_FORMAT.format(eDate) : "");
                    return item;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getCouponDetail: " + ex.getMessage());
        }
        return null;
    }

    /**
     * Create a new platform coupon (funded by Platform or Co-funded).
     */
    public boolean createPlatformCoupon(String code, String title, String discountType, double discountValue,
                                        double minOrderValue, Double maxDiscountAmount, int usageLimit,
                                        String sponsorType, Timestamp startDate, Timestamp endDate) {
        String cleanCode = code != null ? code.trim().toUpperCase() : "";
        if (cleanCode.isEmpty()) return false;

        String checkSql = "SELECT COUNT(*) FROM coupons WHERE code = ?";
        String insertSql = "INSERT INTO coupons (shop_id, code, title, discount_type, discount_value, min_order_value, "
                         + "                     max_discount_amount, usage_limit, used_count, sponsor_type, "
                         + "                     start_date, end_date, is_active, created_at) "
                         + "VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, 1, CURRENT_TIMESTAMP)";

        try (Connection conn = getConnection()) {
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setString(1, cleanCode);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new IllegalArgumentException("Mã voucher '" + cleanCode + "' đã tồn tại trong hệ thống! Vui lòng chọn mã khác.");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, cleanCode);
                ps.setString(2, title != null ? title.trim() : cleanCode);
                ps.setString(3, discountType != null ? discountType.trim().toUpperCase() : "PERCENTAGE");
                ps.setDouble(4, discountValue);
                ps.setDouble(5, minOrderValue);
                if (maxDiscountAmount != null && maxDiscountAmount > 0) {
                    ps.setDouble(6, maxDiscountAmount);
                } else {
                    ps.setNull(6, java.sql.Types.DECIMAL);
                }
                ps.setInt(7, usageLimit > 0 ? usageLimit : 1000);
                ps.setString(8, sponsorType != null ? sponsorType.trim().toUpperCase() : "PLATFORM");
                ps.setTimestamp(9, startDate != null ? startDate : new Timestamp(System.currentTimeMillis()));
                ps.setTimestamp(10, endDate != null ? endDate : new Timestamp(System.currentTimeMillis() + 30L * 86400000L));
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in createPlatformCoupon: " + ex.getMessage(), ex);
            return false;
        }
    }

    /**
     * Update existing coupon rules and settings.
     */
    public boolean updateCoupon(int couponId, String title, String discountType, double discountValue,
                                double minOrderValue, Double maxDiscountAmount, int usageLimit,
                                String sponsorType, Timestamp startDate, Timestamp endDate, boolean isActive) {
        String sql = "UPDATE coupons SET title = ?, discount_type = ?, discount_value = ?, min_order_value = ?, "
                   + "       max_discount_amount = ?, usage_limit = ?, sponsor_type = ?, start_date = ?, end_date = ?, is_active = ? "
                   + "WHERE coupon_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title != null ? title.trim() : "");
            ps.setString(2, discountType != null ? discountType.trim().toUpperCase() : "PERCENTAGE");
            ps.setDouble(3, discountValue);
            ps.setDouble(4, minOrderValue);
            if (maxDiscountAmount != null && maxDiscountAmount > 0) {
                ps.setDouble(5, maxDiscountAmount);
            } else {
                ps.setNull(5, java.sql.Types.DECIMAL);
            }
            ps.setInt(6, usageLimit > 0 ? usageLimit : 1000);
            ps.setString(7, sponsorType != null ? sponsorType.trim().toUpperCase() : "PLATFORM");
            ps.setTimestamp(8, startDate != null ? startDate : new Timestamp(System.currentTimeMillis()));
            ps.setTimestamp(9, endDate != null ? endDate : new Timestamp(System.currentTimeMillis() + 30L * 86400000L));
            ps.setBoolean(10, isActive);
            ps.setInt(11, couponId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in updateCoupon: " + ex.getMessage(), ex);
            return false;
        }
    }

    /**
     * Pause / Activate / Block coupon (soft delete / status toggle).
     */
    public boolean toggleCouponStatus(int couponId, boolean isActive) {
        String sql = "UPDATE coupons SET is_active = ? WHERE coupon_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, couponId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in toggleCouponStatus: " + ex.getMessage());
            return false;
        }
    }

    /**
     * Delete coupon if not referenced in any past orders.
     */
    public boolean deleteCoupon(int couponId) throws IllegalStateException, SQLException {
        try (Connection conn = getConnection()) {
            String checkSql = "SELECT COUNT(*) FROM orders WHERE coupon_id = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, couponId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        int ordersCount = rs.getInt(1);
                        throw new IllegalStateException("Không thể xóa mã giảm giá này vì đã có " + ordersCount + " đơn hàng áp dụng! Vui lòng chỉ bấm 'Tạm dừng / Khóa mã' để bảo toàn dữ liệu đối soát.");
                    }
                }
            }

            String deleteSql = "DELETE FROM coupons WHERE coupon_id = ?";
            try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                psDel.setInt(1, couponId);
                return psDel.executeUpdate() > 0;
            }
        }
    }

    // -------------------------------------------------------------------------
    // 5. DISPUTES & ARBITRATION
    // -------------------------------------------------------------------------
    public Map<String, Object> getDisputeStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                   + "    COUNT(*) as total_count, "
                   + "    SUM(CASE WHEN status = 'OPEN' THEN 1 ELSE 0 END) as open_count, "
                   + "    SUM(CASE WHEN status = 'MEDIATING' THEN 1 ELSE 0 END) as mediating_count, "
                   + "    SUM(CASE WHEN status = 'REFUNDED_BUYER' THEN 1 ELSE 0 END) as refunded_count, "
                   + "    SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) as rejected_count, "
                   + "    SUM(CASE WHEN status IN ('OPEN', 'MEDIATING') THEN claim_amount ELSE 0 END) as frozen_amount "
                   + "FROM disputes";
        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                stats.put("totalCount", rs.getInt("total_count"));
                stats.put("openCount", rs.getInt("open_count"));
                stats.put("mediatingCount", rs.getInt("mediating_count"));
                stats.put("refundedCount", rs.getInt("refunded_count"));
                stats.put("rejectedCount", rs.getInt("rejected_count"));
                stats.put("frozenAmountFormatted", CURRENCY_FORMAT.format(rs.getDouble("frozen_amount")));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getDisputeStats: " + ex.getMessage());
        }
        return stats;
    }

    public List<Map<String, Object>> getDisputesList() {
        return getDisputesList(null, null, null);
    }

    public List<Map<String, Object>> getDisputesList(String statusFilter, String searchKeyword, String reasonFilter) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT d.dispute_id, d.dispute_code, d.reason_category, d.complaint_text, ")
           .append("       d.claim_amount, d.evidence_image_url, d.resolution_decision, d.resolution_note, d.status, d.created_at, ")
           .append("       u.full_name as customer_name, s.shop_name, s.rating as shop_rating, ")
           .append("       so.sub_order_code, o.order_code, ")
           .append("       del.tracking_number, del.proof_image_url as driver_proof_image, ")
           .append("       drv.full_name as driver_name ")
           .append("FROM disputes d ")
           .append("JOIN users u ON d.customer_id = u.user_id ")
           .append("JOIN shops s ON d.shop_id = s.shop_id ")
           .append("LEFT JOIN sub_orders so ON d.sub_order_id = so.sub_order_id ")
           .append("LEFT JOIN orders o ON so.order_id = o.order_id ")
           .append("LEFT JOIN deliveries del ON so.sub_order_id = del.sub_order_id ")
           .append("LEFT JOIN users drv ON del.driver_id = drv.user_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            String sf = statusFilter.trim();
            if ("OPEN".equalsIgnoreCase(sf) || "admin_decision".equalsIgnoreCase(sf)) {
                conditions.add("d.status = 'OPEN'");
            } else if ("MEDIATING".equalsIgnoreCase(sf) || "negotiating".equalsIgnoreCase(sf)) {
                conditions.add("d.status = 'MEDIATING'");
            } else if ("REFUNDED_BUYER".equalsIgnoreCase(sf) || "refunded".equalsIgnoreCase(sf)) {
                conditions.add("d.status = 'REFUNDED_BUYER'");
            } else if ("REJECTED".equalsIgnoreCase(sf) || "rejected".equalsIgnoreCase(sf)) {
                conditions.add("d.status = 'REJECTED'");
            } else {
                conditions.add("d.status = ?");
                params.add(sf);
            }
        }

        if (reasonFilter != null && !reasonFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(reasonFilter.trim())) {
            conditions.add("LOWER(d.reason_category) LIKE ?");
            params.add("%" + reasonFilter.trim().toLowerCase() + "%");
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(d.dispute_code) LIKE ? OR LOWER(o.order_code) LIKE ? OR LOWER(so.sub_order_code) LIKE ? OR LOWER(u.full_name) LIKE ? OR LOWER(s.shop_name) LIKE ? OR LOWER(d.complaint_text) LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }
        sql.append("ORDER BY (CASE WHEN d.status = 'OPEN' THEN 0 WHEN d.status = 'MEDIATING' THEN 1 ELSE 2 END) ASC, d.dispute_id DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("disputeId", rs.getLong("dispute_id"));
                    String code = rs.getString("dispute_code");
                    item.put("disputeCode", code);
                    item.put("orderCode", rs.getString("order_code") != null ? "#" + rs.getString("order_code") : "#ORD-" + rs.getLong("dispute_id"));
                    item.put("subOrderCode", rs.getString("sub_order_code"));
                    String reason = rs.getString("reason_category");
                    item.put("reasonCategory", reason != null ? reason : "Hư hỏng hoa quả");
                    item.put("complaintText", rs.getString("complaint_text"));
                    double claimAmount = rs.getDouble("claim_amount");
                    item.put("claimAmount", claimAmount);
                    item.put("claimAmountFormatted", CURRENCY_FORMAT.format(claimAmount));
                    item.put("shopOfferFormatted", CURRENCY_FORMAT.format(claimAmount * 0.5));
                    String stt = rs.getString("status");
                    item.put("status", stt);
                    item.put("resolutionDecision", rs.getString("resolution_decision"));

                    String statusPill = "CẦN ADMIN PHÁN QUYẾT";
                    String statusGroup = "admin_decision";
                    if ("REFUNDED_BUYER".equalsIgnoreCase(stt)) {
                        statusPill = "ĐÃ HOÀN TIỀN (REFUNDED)";
                        statusGroup = "refunded";
                    } else if ("REJECTED".equalsIgnoreCase(stt)) {
                        statusPill = "ĐÃ BÁC BỎ KHIẾU NẠI";
                        statusGroup = "rejected";
                    } else if ("MEDIATING".equalsIgnoreCase(stt)) {
                        statusPill = "ĐANG ĐỐI SOÁT";
                        statusGroup = "negotiating";
                    } else if ("RESOLVED".equalsIgnoreCase(stt)) {
                        statusPill = "ĐÃ GIẢI QUYẾT";
                        statusGroup = "admin_decision";
                    }
                    item.put("statusPill", statusPill);
                    item.put("statusGroup", statusGroup);

                    String cName = rs.getString("customer_name");
                    item.put("customerName", cName != null ? cName : "Khách hàng");

                    // Customer initials
                    String initials = "KH";
                    if (cName != null && !cName.trim().isEmpty()) {
                        String[] parts = cName.trim().split("\\s+");
                        if (parts.length >= 2) {
                            initials = ("" + parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
                        } else {
                            initials = ("" + parts[0].charAt(0)).toUpperCase();
                        }
                    }
                    item.put("initials", initials);

                    item.put("shopName", rs.getString("shop_name"));
                    item.put("shopRating", rs.getDouble("shop_rating") > 0 ? String.format("%.1f ★", rs.getDouble("shop_rating")) : "4.8 ★");

                    String evImg = rs.getString("evidence_image_url");
                    if (evImg == null || evImg.trim().isEmpty()) {
                        evImg = "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400";
                    }
                    item.put("evidenceImageUrl", evImg);

                    item.put("trackingNumber", rs.getString("tracking_number"));
                    item.put("driverProofImage", rs.getString("driver_proof_image"));
                    item.put("driverName", rs.getString("driver_name"));

                    String resNote = rs.getString("resolution_note");
                    if (resNote == null || resNote.trim().isEmpty()) {
                        resNote = "Hồ sơ khiếu nại đang được hội đồng trọng tài sàn FreshFruit kiểm duyệt đối soát dữ liệu đóng gói cùng camera giao nhận vận chuyển.";
                    }
                    item.put("resolutionNote", resNote);

                    Timestamp created = rs.getTimestamp("created_at");
                    String createdStr = created != null ? DATE_FORMAT.format(created) : "Hôm nay";
                    item.put("createdFormatted", createdStr);

                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getDisputesList: " + ex.getMessage());
        }
        return list;
    }

    public Map<String, Object> getDisputeDetail(long disputeId) {
        String sql = "SELECT d.dispute_id, d.dispute_code, d.reason_category, d.complaint_text, d.claim_amount, d.evidence_image_url, "
                   + "       d.status, d.resolution_decision, d.resolution_note, d.resolved_by, d.resolved_at, d.created_at, "
                   + "       u.user_id as customer_id, u.full_name as customer_name, u.phone as customer_phone, u.email as customer_email, "
                   + "       s.shop_id, s.shop_name, s.rating as shop_rating, s.phone as shop_phone, s.address as shop_address, "
                   + "       so.sub_order_id, so.sub_order_code, so.shop_total, so.status as sub_order_status, so.delivery_slot, "
                   + "       o.order_id, o.order_code, "
                   + "       del.tracking_number, del.delivery_status, del.proof_image_url as driver_proof_image, "
                   + "       drv.full_name as driver_name, drv.phone as driver_phone "
                   + "FROM disputes d "
                   + "JOIN users u ON d.customer_id = u.user_id "
                   + "JOIN shops s ON d.shop_id = s.shop_id "
                   + "LEFT JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
                   + "LEFT JOIN orders o ON so.order_id = o.order_id "
                   + "LEFT JOIN deliveries del ON so.sub_order_id = del.sub_order_id "
                   + "LEFT JOIN users drv ON del.driver_id = drv.user_id "
                   + "WHERE d.dispute_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, disputeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("disputeId", rs.getLong("dispute_id"));
                    item.put("disputeCode", rs.getString("dispute_code"));
                    item.put("orderCode", rs.getString("order_code") != null ? "#" + rs.getString("order_code") : "#ORD-" + rs.getLong("dispute_id"));
                    item.put("subOrderCode", rs.getString("sub_order_code"));
                    item.put("reasonCategory", rs.getString("reason_category"));
                    item.put("complaintText", rs.getString("complaint_text"));
                    double claimAmount = rs.getDouble("claim_amount");
                    item.put("claimAmount", claimAmount);
                    item.put("claimAmountFormatted", CURRENCY_FORMAT.format(claimAmount));
                    item.put("shopOfferFormatted", CURRENCY_FORMAT.format(claimAmount * 0.5));
                    item.put("status", rs.getString("status"));
                    item.put("resolutionDecision", rs.getString("resolution_decision"));
                    item.put("resolutionNote", rs.getString("resolution_note"));
                    item.put("customerName", rs.getString("customer_name"));
                    item.put("customerPhone", rs.getString("customer_phone"));
                    item.put("customerEmail", rs.getString("customer_email"));
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("shopRating", rs.getDouble("shop_rating") > 0 ? String.format("%.1f ★", rs.getDouble("shop_rating")) : "4.8 ★");
                    item.put("shopPhone", rs.getString("shop_phone"));
                    item.put("shopAddress", rs.getString("shop_address"));
                    item.put("evidenceImageUrl", rs.getString("evidence_image_url"));
                    item.put("driverName", rs.getString("driver_name"));
                    item.put("driverPhone", rs.getString("driver_phone"));
                    item.put("trackingNumber", rs.getString("tracking_number"));
                    item.put("driverProofImage", rs.getString("driver_proof_image"));
                    Timestamp cat = rs.getTimestamp("created_at");
                    item.put("createdFormatted", cat != null ? DATE_FORMAT.format(cat) : "Hôm nay");
                    return item;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getDisputeDetail: " + ex.getMessage());
        }
        return null;
    }

    public boolean resolveDispute(long disputeId, String decision, String resolutionNote, long adminId) {
        String status = "MEDIATING";
        String resolutionDecision = decision;
        if ("REFUND_BUYER".equalsIgnoreCase(decision)) {
            status = "REFUNDED_BUYER";
            resolutionDecision = "REFUND_BUYER";
        } else if ("REJECT_BUYER".equalsIgnoreCase(decision)) {
            status = "REJECTED";
            resolutionDecision = "REJECT_BUYER";
        } else if ("REQUEST_INFO".equalsIgnoreCase(decision)) {
            status = "MEDIATING";
            resolutionDecision = "REQUEST_INFO";
        }

        String sql = "UPDATE disputes SET status = ?, resolution_decision = ?, resolution_note = ?, resolved_by = ?, resolved_at = CURRENT_TIMESTAMP "
                   + "WHERE dispute_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, resolutionDecision);
            ps.setString(3, resolutionNote != null ? resolutionNote.trim() : "");
            ps.setLong(4, adminId);
            ps.setLong(5, disputeId);
            int rows = ps.executeUpdate();

            // Nếu hoàn tiền: cập nhật trạng thái đơn con sang REFUNDED
            if (rows > 0 && "REFUNDED_BUYER".equals(status)) {
                String subOrderSql = "UPDATE sub_orders SET status = 'REFUNDED', updated_at = CURRENT_TIMESTAMP "
                                   + "WHERE sub_order_id = (SELECT sub_order_id FROM disputes WHERE dispute_id = ?)";
                try (PreparedStatement subPs = conn.prepareStatement(subOrderSql)) {
                    subPs.setLong(1, disputeId);
                    subPs.executeUpdate();
                }
            }
            return rows > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in resolveDispute: " + ex.getMessage(), ex);
            return false;
        }
    }

    // -------------------------------------------------------------------------
    // 7. PRODUCTS & INVENTORY
    // -------------------------------------------------------------------------
    public Map<String, Object> getProductModerationStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                   + "    COUNT(p.product_id) as total_count, "
                   + "    SUM(CASE WHEN p.is_active = 1 THEN 1 ELSE 0 END) as active_count, "
                   + "    SUM(CASE WHEN p.is_active = 0 THEN 1 ELSE 0 END) as inactive_count, "
                   + "    SUM(CASE WHEN p.report_count > 0 OR p.violation_reason IS NOT NULL THEN 1 ELSE 0 END) as flagged_count, "
                   + "    SUM(CASE WHEN p.certification IS NOT NULL AND p.certification != '' THEN 1 ELSE 0 END) as certified_count, "
                   + "    SUM(CASE WHEN pv.stock_quantity <= pv.low_stock_threshold THEN 1 ELSE 0 END) as low_stock_count, "
                   + "    SUM(CASE WHEN p.is_featured = 1 THEN 1 ELSE 0 END) as featured_count "
                   + "FROM products p "
                   + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                int total = rs.getInt("total_count");
                int active = rs.getInt("active_count");
                int inactive = rs.getInt("inactive_count");
                int flagged = rs.getInt("flagged_count");
                int certified = rs.getInt("certified_count");
                int lowStock = rs.getInt("low_stock_count");
                int featured = rs.getInt("featured_count");

                stats.put("totalCount", total);
                stats.put("activeCount", active);
                stats.put("inactiveCount", inactive);
                stats.put("flaggedCount", flagged);
                stats.put("pendingCount", inactive);
                stats.put("certifiedCount", certified);
                stats.put("lowStockCount", lowStock);
                stats.put("featuredCount", featured);
                stats.put("safeCount", certified);

                double complianceRate = total > 0 ? (certified * 100.0 / total) : 100.0;
                stats.put("complianceRate", Math.round(complianceRate * 10.0) / 10.0);

                double activeRate = total > 0 ? (active * 100.0 / total) : 100.0;
                stats.put("activeRate", Math.round(activeRate * 10.0) / 10.0);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getProductModerationStats: " + ex.getMessage());
        }
        return stats;
    }

    public List<Map<String, Object>> getProductsList() {
        return getProductsList(null, null, null);
    }

    public List<Map<String, Object>> getProductsList(String statusFilter, String categoryFilter, String searchKeyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT p.product_id, p.name as product_name, p.origin, p.storage_temp, p.certification, ")
           .append("       p.is_featured, p.is_active, p.created_at, p.updated_at, p.report_count, p.violation_reason, p.moderated_at, ")
           .append("       c.category_id, c.category_name, s.shop_name, pv.sku, pv.price, pv.stock_quantity, pv.unit, ")
           .append("       pv.low_stock_threshold, ")
           .append("       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, image_id ASC) as thumbnail_url ")
           .append("FROM products p ")
           .append("LEFT JOIN categories c ON p.category_id = c.category_id ")
           .append("LEFT JOIN shops s ON p.shop_id = s.shop_id ")
           .append("LEFT JOIN product_variants pv ON p.product_id = pv.product_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            String sf = statusFilter.trim();
            if ("flagged".equalsIgnoreCase(sf) || "reported".equalsIgnoreCase(sf)) {
                conditions.add("(p.report_count > 0 OR p.violation_reason IS NOT NULL)");
            } else if ("approved".equalsIgnoreCase(sf) || "ACTIVE".equalsIgnoreCase(sf) || "active".equalsIgnoreCase(sf)) {
                conditions.add("p.is_active = 1");
            } else if ("pending".equalsIgnoreCase(sf) || "rejected".equalsIgnoreCase(sf) || "INACTIVE".equalsIgnoreCase(sf) || "inactive".equalsIgnoreCase(sf) || "hidden".equalsIgnoreCase(sf)) {
                conditions.add("p.is_active = 0");
            } else if ("safe".equalsIgnoreCase(sf) || "certified".equalsIgnoreCase(sf)) {
                conditions.add("(p.certification IS NOT NULL AND p.certification != '')");
            } else if ("featured".equalsIgnoreCase(sf)) {
                conditions.add("p.is_featured = 1");
            } else if ("low_stock".equalsIgnoreCase(sf)) {
                conditions.add("pv.stock_quantity <= pv.low_stock_threshold");
            }
        }

        if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !"all".equalsIgnoreCase(categoryFilter.trim())) {
            conditions.add("(c.category_name = ? OR CAST(c.category_id AS VARCHAR(20)) = ?)");
            params.add(categoryFilter.trim());
            params.add(categoryFilter.trim());
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(p.name) LIKE ? OR LOWER(pv.sku) LIKE ? OR LOWER(s.shop_name) LIKE ? OR LOWER(p.origin) LIKE ? OR LOWER(p.certification) LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }
        sql.append("ORDER BY (CASE WHEN p.report_count > 0 THEN 0 WHEN p.is_active = 0 THEN 1 ELSE 2 END) ASC, p.product_id ASC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    long pid = rs.getLong("product_id");
                    item.put("productId", pid);
                    String pName = rs.getString("product_name");
                    item.put("productName", pName);
                    String origin = rs.getString("origin") != null ? rs.getString("origin") : "Đang cập nhật";
                    item.put("origin", origin);
                    String storageTemp = rs.getString("storage_temp") != null ? rs.getString("storage_temp") : "2-5°C";
                    item.put("storageTemp", storageTemp);
                    String cert = rs.getString("certification") != null ? rs.getString("certification") : "Đang thẩm định";
                    item.put("certification", cert);
                    String catName = rs.getString("category_name") != null ? rs.getString("category_name") : "Trái cây mùa vụ";
                    item.put("categoryName", catName);
                    item.put("shopName", rs.getString("shop_name") != null ? rs.getString("shop_name") : "Nhà Vườn FreshFruit");
                    String sku = rs.getString("sku") != null ? rs.getString("sku") : "FRU-" + pid;
                    item.put("sku", sku);
                    double price = rs.getDouble("price");
                    item.put("price", price);
                    item.put("priceFormatted", price > 0 ? CURRENCY_FORMAT.format(price) : "120,000 ₫");
                    String unit = rs.getString("unit") != null ? rs.getString("unit") : "kg";
                    item.put("unit", unit);
                    int stock = rs.getInt("stock_quantity");
                    item.put("stock", stock);
                    item.put("stockFormatted", stock + " " + unit);

                    boolean isActive = rs.getBoolean("is_active");
                    boolean isFeatured = rs.getBoolean("is_featured");
                    item.put("isActive", isActive);
                    item.put("isFeatured", isFeatured);

                    int reportCount = rs.getInt("report_count");
                    String violationReason = rs.getString("violation_reason");
                    Timestamp moderatedAt = rs.getTimestamp("moderated_at");
                    item.put("reportCount", reportCount);
                    item.put("violationReason", violationReason);
                    item.put("moderatedAt", moderatedAt != null ? DATE_FORMAT.format(moderatedAt) : null);
                    boolean isFlagged = reportCount > 0 || (violationReason != null && !violationReason.trim().isEmpty());
                    item.put("isFlagged", isFlagged);

                    Timestamp createdAt = rs.getTimestamp("created_at");
                    if (createdAt != null) {
                        item.put("timeAgo", DATE_FORMAT.format(createdAt));
                    } else {
                        item.put("timeAgo", "Hôm nay");
                    }

                    // Image matching fruit name or DB thumbnail
                    String img = rs.getString("thumbnail_url");
                    if (img == null || img.trim().isEmpty()) {
                        String lower = pName.toLowerCase();
                        if (lower.contains("dâu")) {
                            img = "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200&h=200&fit=crop";
                        } else if (lower.contains("sầu")) {
                            img = "https://images.unsplash.com/photo-1587334274328-64186a80aeee?w=200&h=200&fit=crop";
                        } else if (lower.contains("xoài")) {
                            img = "https://images.unsplash.com/photo-1553279768-865429fa0078?w=200&h=200&fit=crop";
                        } else if (lower.contains("bưởi")) {
                            img = "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=200&h=200&fit=crop";
                        } else if (lower.contains("mận")) {
                            img = "https://images.unsplash.com/photo-1528825871115-3581a5387919?w=200&h=200&fit=crop";
                        } else if (lower.contains("lê") || lower.contains("táo")) {
                            img = "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop";
                        } else if (lower.contains("thanh long")) {
                            img = "https://images.unsplash.com/photo-1527325678964-54921661f888?w=200&h=200&fit=crop";
                        } else {
                            img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=200&h=200&fit=crop";
                        }
                    }
                    item.put("thumbnailUrl", img);

                    // Moderation & compliance tags based on real DB status
                    if (!isActive) {
                        item.put("modTag", (violationReason != null && !violationReason.trim().isEmpty()) ? "ĐÃ KHÓA VI PHẠM" : "TẠM ẨN / CHỜ DUYỆT");
                        item.put("modTagClass", "bg-danger-subtle text-danger border-danger-subtle");
                        item.put("modTagIcon", "bi-slash-circle-fill");
                        item.put("riskBadgeClass", "badge-ai-danger");
                        item.put("riskBadgeIcon", "bi-x-circle-fill");
                        item.put("riskBadgeText", "Đã khóa hiển thị");
                        item.put("riskLevel", "high");
                        item.put("statusGroup", "pending rejected inactive hidden" + (isFlagged ? " flagged reported" : ""));
                    } else if (isFlagged) {
                        item.put("modTag", "BỊ BÁO CÁO (" + reportCount + " lượt)");
                        item.put("modTagClass", "bg-warning-subtle text-warning-emphasis border-warning-subtle");
                        item.put("modTagIcon", "bi-flag-fill");
                        item.put("riskBadgeClass", "badge-ai-warning");
                        item.put("riskBadgeIcon", "bi-exclamation-triangle-fill");
                        item.put("riskBadgeText", "Cần xử lý vi phạm");
                        item.put("riskLevel", "warning");
                        item.put("statusGroup", "approved active flagged reported");
                    } else if (isFeatured) {
                        item.put("modTag", "SẢN PHẨM NỔI BẬT");
                        item.put("modTagClass", "bg-primary-subtle text-primary border-primary-subtle");
                        item.put("modTagIcon", "bi-star-fill");
                        item.put("riskBadgeClass", "badge-ai-success");
                        item.put("riskBadgeIcon", "bi-patch-check-fill");
                        item.put("riskBadgeText", "Đạt chuẩn: " + cert);
                        item.put("riskLevel", "safe");
                        item.put("statusGroup", "approved active safe");
                    } else {
                        item.put("modTag", "ĐANG MỞ BÁN");
                        item.put("modTagClass", "bg-success-subtle text-success border-success-subtle");
                        item.put("modTagIcon", "bi-check-circle-fill");
                        item.put("riskBadgeClass", "badge-ai-success");
                        item.put("riskBadgeIcon", "bi-shield-check");
                        item.put("riskBadgeText", "Đạt chuẩn: " + cert);
                        item.put("riskLevel", "safe");
                        item.put("statusGroup", "approved active safe");
                    }

                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getProductsList: " + ex.getMessage());
        }
        return list;
    }

    public boolean moderateProduct(long productId, boolean isActive, String violationReason) {
        String sql = "UPDATE products SET is_active = ?, violation_reason = ?, moderated_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE product_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setString(2, violationReason != null && !violationReason.trim().isEmpty() ? violationReason.trim() : null);
            ps.setLong(3, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in moderateProduct: " + ex.getMessage(), ex);
            return false;
        }
    }

    public Map<String, Object> getProductDetail(long productId) {
        String sql = "SELECT p.product_id, p.name as product_name, p.origin, p.storage_temp, p.certification, "
                   + "       p.is_featured, p.is_active, p.created_at, p.updated_at, p.report_count, p.violation_reason, p.moderated_at, "
                   + "       c.category_id, c.category_name, s.shop_name, pv.sku, pv.price, pv.stock_quantity, pv.unit, "
                   + "       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, image_id ASC) as thumbnail_url "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN shops s ON p.shop_id = s.shop_id "
                   + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id "
                   + "WHERE p.product_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("productId", rs.getLong("product_id"));
                    item.put("productName", rs.getString("product_name"));
                    item.put("origin", rs.getString("origin"));
                    item.put("storageTemp", rs.getString("storage_temp"));
                    item.put("certification", rs.getString("certification"));
                    item.put("isFeatured", rs.getBoolean("is_featured"));
                    item.put("isActive", rs.getBoolean("is_active"));
                    item.put("reportCount", rs.getInt("report_count"));
                    item.put("violationReason", rs.getString("violation_reason"));
                    item.put("moderatedAt", rs.getTimestamp("moderated_at") != null ? DATE_FORMAT.format(rs.getTimestamp("moderated_at")) : null);
                    item.put("categoryId", rs.getInt("category_id"));
                    item.put("categoryName", rs.getString("category_name"));
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("sku", rs.getString("sku"));
                    item.put("price", rs.getDouble("price"));
                    item.put("priceFormatted", CURRENCY_FORMAT.format(rs.getDouble("price")));
                    item.put("stock", rs.getInt("stock_quantity"));
                    item.put("unit", rs.getString("unit"));
                    item.put("thumbnailUrl", rs.getString("thumbnail_url"));
                    return item;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getProductDetail: " + ex.getMessage());
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // 8. ORDERS & FULFILLMENT STREAM
    // -------------------------------------------------------------------------

    /**
     * Get aggregate statistics for orders and fulfillment.
     */
    public Map<String, Object> getOrderStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                   + "    COUNT(o.order_id) as total_orders, "
                   + "    COALESCE(SUM(o.final_amount), 0) as total_gmv, "
                   + "    SUM(CASE WHEN o.order_status = 'COMPLETED' THEN 1 ELSE 0 END) as completed_orders, "
                   + "    SUM(CASE WHEN o.order_status = 'PROCESSING' THEN 1 ELSE 0 END) as processing_orders, "
                   + "    SUM(CASE WHEN o.order_status = 'SHIPPING' THEN 1 ELSE 0 END) as shipping_orders, "
                   + "    SUM(CASE WHEN o.order_status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled_orders, "
                   + "    (SELECT COUNT(*) FROM sub_orders) as total_sub_orders, "
                   + "    (SELECT COUNT(*) FROM deliveries WHERE delivery_status = 'IN_TRANSIT') as active_deliveries "
                   + "FROM orders o";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                stats.put("totalOrders", rs.getInt("total_orders"));
                stats.put("totalGmv", rs.getDouble("total_gmv"));
                stats.put("totalGmvFormatted", CURRENCY_FORMAT.format(rs.getDouble("total_gmv")));
                stats.put("completedOrders", rs.getInt("completed_orders"));
                stats.put("processingOrders", rs.getInt("processing_orders"));
                stats.put("shippingOrders", rs.getInt("shipping_orders"));
                stats.put("cancelledOrders", rs.getInt("cancelled_orders"));
                stats.put("totalSubOrders", rs.getInt("total_sub_orders"));
                stats.put("activeDeliveries", rs.getInt("active_deliveries"));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getOrderStats: " + ex.getMessage());
        }
        return stats;
    }

    public List<Map<String, Object>> getOrdersList() {
        return getOrdersList(null, null);
    }

    /**
     * Get orders list with search and status filtering.
     */
    public List<Map<String, Object>> getOrdersList(String statusFilter, String searchKeyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.order_id, o.order_code, o.final_amount, o.total_goods_amount, o.total_shipping_fee, ")
           .append("       o.platform_discount, o.order_status, o.payment_status, o.payment_method, o.created_at, ")
           .append("       u.user_id as customer_id, u.full_name as customer_name, u.phone as customer_phone, u.email as customer_email, ")
           .append("       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city, ")
           .append("       COUNT(DISTINCT so.sub_order_id) as sub_orders_count, ")
           .append("       COUNT(DISTINCT so.shop_id) as shops_count, ")
           .append("       STRING_AGG(s.shop_name, ', ') as shop_names, ")
           .append("       (SELECT COUNT(*) FROM order_items oi JOIN sub_orders so2 ON oi.sub_order_id = so2.sub_order_id WHERE so2.order_id = o.order_id) as total_items ")
           .append("FROM orders o ")
           .append("JOIN users u ON o.customer_id = u.user_id ")
           .append("LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id ")
           .append("LEFT JOIN sub_orders so ON o.order_id = so.order_id ")
           .append("LEFT JOIN shops s ON so.shop_id = s.shop_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            conditions.add("o.order_status = ?");
            params.add(statusFilter.trim());
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(o.order_code) LIKE ? OR LOWER(u.full_name) LIKE ? OR LOWER(COALESCE(u.phone, '')) LIKE ? OR LOWER(COALESCE(osa.recipient_name, '')) LIKE ? OR LOWER(COALESCE(osa.city, '')) LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }

        sql.append("GROUP BY o.order_id, o.order_code, o.final_amount, o.total_goods_amount, o.total_shipping_fee, ")
           .append("         o.platform_discount, o.order_status, o.payment_status, o.payment_method, o.created_at, ")
           .append("         u.user_id, u.full_name, u.phone, u.email, ")
           .append("         osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city ")
           .append("ORDER BY o.order_id DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("orderId", rs.getLong("order_id"));
                    item.put("orderCode", rs.getString("order_code"));
                    item.put("customerId", rs.getLong("customer_id"));
                    item.put("customerName", rs.getString("customer_name"));
                    item.put("customerPhone", rs.getString("customer_phone") != null ? rs.getString("customer_phone") : "Chưa cập nhật");
                    item.put("customerEmail", rs.getString("customer_email"));
                    
                    String recipient = rs.getString("recipient_name");
                    item.put("recipientName", recipient != null ? recipient : rs.getString("customer_name"));
                    item.put("recipientPhone", rs.getString("recipient_phone") != null ? rs.getString("recipient_phone") : rs.getString("customer_phone"));
                    String city = rs.getString("city") != null ? rs.getString("city") : "Toàn quốc";
                    item.put("city", city);
                    
                    String street = rs.getString("street_address");
                    String ward = rs.getString("ward");
                    String district = rs.getString("district");
                    StringBuilder fullAddr = new StringBuilder();
                    if (street != null && !street.isEmpty()) fullAddr.append(street);
                    if (ward != null && !ward.isEmpty()) fullAddr.append(", ").append(ward);
                    if (district != null && !district.isEmpty()) fullAddr.append(", ").append(district);
                    if (city != null && !city.isEmpty()) fullAddr.append(", ").append(city);
                    item.put("fullAddress", fullAddr.length() > 0 ? fullAddr.toString() : "Địa chỉ giao hàng chuẩn");

                    double finalAmt = rs.getDouble("final_amount");
                    item.put("finalAmount", finalAmt);
                    item.put("finalAmountFormatted", CURRENCY_FORMAT.format(finalAmt));
                    item.put("goodsAmountFormatted", CURRENCY_FORMAT.format(rs.getDouble("total_goods_amount")));
                    item.put("shippingFeeFormatted", CURRENCY_FORMAT.format(rs.getDouble("total_shipping_fee")));
                    item.put("platformDiscountFormatted", CURRENCY_FORMAT.format(rs.getDouble("platform_discount")));

                    String ordStatus = rs.getString("order_status");
                    item.put("orderStatus", ordStatus);
                    if ("COMPLETED".equalsIgnoreCase(ordStatus)) {
                        item.put("orderStatusText", "Hoàn thành");
                        item.put("orderStatusBadge", "bg-success-subtle text-success border border-success-subtle");
                    } else if ("PROCESSING".equalsIgnoreCase(ordStatus)) {
                        item.put("orderStatusText", "Đang xử lý");
                        item.put("orderStatusBadge", "bg-warning-subtle text-warning-emphasis border border-warning-subtle");
                    } else if ("SHIPPING".equalsIgnoreCase(ordStatus)) {
                        item.put("orderStatusText", "Đang giao vận");
                        item.put("orderStatusBadge", "bg-primary-subtle text-primary border border-primary-subtle");
                    } else if ("CANCELLED".equalsIgnoreCase(ordStatus)) {
                        item.put("orderStatusText", "Đã hủy đơn");
                        item.put("orderStatusBadge", "bg-danger-subtle text-danger border border-danger-subtle");
                    } else {
                        item.put("orderStatusText", ordStatus);
                        item.put("orderStatusBadge", "bg-secondary-subtle text-secondary border border-secondary-subtle");
                    }

                    String payStatus = rs.getString("payment_status");
                    item.put("paymentStatus", payStatus);
                    if ("PAID".equalsIgnoreCase(payStatus)) {
                        item.put("paymentStatusText", "Đã thanh toán");
                        item.put("paymentStatusBadge", "bg-success-subtle text-success border border-success-subtle");
                    } else if ("UNPAID".equalsIgnoreCase(payStatus)) {
                        item.put("paymentStatusText", "Chờ thanh toán");
                        item.put("paymentStatusBadge", "bg-warning-subtle text-warning-emphasis border border-warning-subtle");
                    } else if ("REFUNDED".equalsIgnoreCase(payStatus)) {
                        item.put("paymentStatusText", "Đã hoàn tiền");
                        item.put("paymentStatusBadge", "bg-info-subtle text-info-emphasis border border-info-subtle");
                    } else {
                        item.put("paymentStatusText", payStatus);
                        item.put("paymentStatusBadge", "bg-secondary-subtle text-secondary border border-secondary-subtle");
                    }

                    item.put("paymentMethod", rs.getString("payment_method"));
                    item.put("subOrdersCount", rs.getInt("sub_orders_count"));
                    item.put("shopsCount", rs.getInt("shops_count"));
                    item.put("shopNames", rs.getString("shop_names") != null ? rs.getString("shop_names") : "Chưa xác định");
                    item.put("totalItems", rs.getInt("total_items"));

                    Timestamp createdAt = rs.getTimestamp("created_at");
                    item.put("createdAtFormatted", createdAt != null ? DATETIME_FORMAT.format(createdAt) : "-");
                    item.put("dateFormatted", createdAt != null ? DATE_FORMAT.format(createdAt) : "-");

                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getOrdersList: " + ex.getMessage());
        }
        return list;
    }
    
    public List<ShopRequest> getShopRequestsByStatus(String status) {
        List<ShopRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM [dbo].[shop_requests]";
        if (status != null && !status.equals("ALL")) {
            sql += " WHERE status = ?";
        }
        sql += " ORDER BY created_at DESC";

        try (Connection conn = this.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (status != null && !status.equals("ALL")) {
                ps.setString(1, status);
            }
            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    ShopRequest r = new ShopRequest();
                    r.setRequestId(rs.getInt("request_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setShopName(rs.getString("shop_name"));
                    r.setBusinessType(rs.getString("business_type"));
                    r.setProvince(rs.getString("province"));
                    r.setDistrict(rs.getString("district"));
                    r.setWard(rs.getString("ward"));
                    r.setStreetAddress(rs.getString("street_address"));
                    r.setPickupAddress(rs.getString("pickup_address"));
                    r.setReturnAddress(rs.getString("return_address"));
                    r.setIdCardNumber(rs.getString("id_card_number"));
                    r.setTaxCode(rs.getString("tax_code"));
                    r.setIdCardFrontUrl(rs.getString("id_card_front_url"));
                    r.setIdCardBackUrl(rs.getString("id_card_back_url"));
                    r.setShopDescription(rs.getString("shop_description"));
                    r.setShopLogoUrl(rs.getString("shop_logo_url"));
                    r.setShopBannerUrl(rs.getString("shop_banner_url"));
                    r.setBankName(rs.getString("bank_name"));
                    r.setBankAccountNumber(rs.getString("bank_account_number"));
                    r.setBankAccountHolder(rs.getString("bank_account_holder"));
                    r.setStatus(rs.getString("status"));
                    r.setReason(rs.getString("reason"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get detailed order structure: master order + child sub_orders + items + deliveries + driver.
     */
    public Map<String, Object> getOrderDetail(long orderId) {
        Map<String, Object> detail = new HashMap<>();

        // 1. Master Order & Shipping Address
        String orderSql = "SELECT o.order_id, o.order_code, o.customer_id, o.coupon_id, o.total_goods_amount, "
                        + "       o.total_shipping_fee, o.platform_discount, o.final_amount, o.payment_status, "
                        + "       o.payment_method, o.order_status, o.created_at, o.updated_at, "
                        + "       u.full_name as customer_name, u.email as customer_email, u.phone as customer_phone, "
                        + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city, "
                        + "       c.code as coupon_code, c.title as coupon_title "
                        + "FROM orders o "
                        + "JOIN users u ON o.customer_id = u.user_id "
                        + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                        + "LEFT JOIN coupons c ON o.coupon_id = c.coupon_id "
                        + "WHERE o.order_id = ?";

        try (Connection conn = getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setLong(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        detail.put("orderId", rs.getLong("order_id"));
                        detail.put("orderCode", rs.getString("order_code"));
                        detail.put("customerName", rs.getString("customer_name"));
                        detail.put("customerEmail", rs.getString("customer_email"));
                        detail.put("customerPhone", rs.getString("customer_phone") != null ? rs.getString("customer_phone") : "Chưa cập nhật");
                        
                        detail.put("recipientName", rs.getString("recipient_name") != null ? rs.getString("recipient_name") : rs.getString("customer_name"));
                        detail.put("recipientPhone", rs.getString("recipient_phone") != null ? rs.getString("recipient_phone") : rs.getString("customer_phone"));
                        
                        String street = rs.getString("street_address");
                        String ward = rs.getString("ward");
                        String district = rs.getString("district");
                        String city = rs.getString("city");
                        StringBuilder fullAddr = new StringBuilder();
                        if (street != null && !street.isEmpty()) fullAddr.append(street);
                        if (ward != null && !ward.isEmpty()) fullAddr.append(", ").append(ward);
                        if (district != null && !district.isEmpty()) fullAddr.append(", ").append(district);
                        if (city != null && !city.isEmpty()) fullAddr.append(", ").append(city != null ? city : "Việt Nam");
                        detail.put("shippingAddressFull", fullAddr.toString());
                        detail.put("city", city != null ? city : "Toàn quốc");

                        detail.put("goodsAmountFormatted", CURRENCY_FORMAT.format(rs.getDouble("total_goods_amount")));
                        detail.put("shippingFeeFormatted", CURRENCY_FORMAT.format(rs.getDouble("total_shipping_fee")));
                        detail.put("platformDiscountFormatted", CURRENCY_FORMAT.format(rs.getDouble("platform_discount")));
                        detail.put("finalAmountFormatted", CURRENCY_FORMAT.format(rs.getDouble("final_amount")));
                        detail.put("paymentMethod", rs.getString("payment_method"));
                        detail.put("paymentStatus", rs.getString("payment_status"));
                        detail.put("orderStatus", rs.getString("order_status"));
                        detail.put("couponCode", rs.getString("coupon_code"));
                        detail.put("couponTitle", rs.getString("coupon_title"));

                        Timestamp cat = rs.getTimestamp("created_at");
                        detail.put("createdAtFormatted", cat != null ? DATETIME_FORMAT.format(cat) : "-");
                    } else {
                        return null;
                    }
                }
            }

            // 2. Fetch Sub-Orders for this Master Order
            String subSql = "SELECT so.sub_order_id, so.sub_order_code, so.shop_id, so.delivery_slot, "
                          + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                          + "       so.commission_rate, so.commission_amount, so.status, so.created_at, "
                          + "       s.shop_name, s.phone as shop_phone, s.address as shop_address, s.province as shop_province "
                          + "FROM sub_orders so "
                          + "JOIN shops s ON so.shop_id = s.shop_id "
                          + "WHERE so.order_id = ? "
                          + "ORDER BY so.sub_order_id ASC";

            List<Map<String, Object>> subOrders = new ArrayList<>();
            try (PreparedStatement psSub = conn.prepareStatement(subSql)) {
                psSub.setLong(1, orderId);
                try (ResultSet rsSub = psSub.executeQuery()) {
                    while (rsSub.next()) {
                        Map<String, Object> sub = new HashMap<>();
                        long subOrderId = rsSub.getLong("sub_order_id");
                        sub.put("subOrderId", subOrderId);
                        sub.put("subOrderCode", rsSub.getString("sub_order_code"));
                        sub.put("shopId", rsSub.getLong("shop_id"));
                        sub.put("shopName", rsSub.getString("shop_name"));
                        sub.put("shopPhone", rsSub.getString("shop_phone"));
                        sub.put("shopAddress", rsSub.getString("shop_address"));
                        sub.put("shopProvince", rsSub.getString("shop_province"));
                        sub.put("deliverySlot", rsSub.getString("delivery_slot") != null ? rsSub.getString("delivery_slot") : "Tiêu chuẩn");

                        sub.put("subtotalFormatted", CURRENCY_FORMAT.format(rsSub.getDouble("shop_subtotal")));
                        sub.put("shippingFeeFormatted", CURRENCY_FORMAT.format(rsSub.getDouble("shop_shipping_fee")));
                        sub.put("discountFormatted", CURRENCY_FORMAT.format(rsSub.getDouble("shop_discount")));
                        sub.put("totalFormatted", CURRENCY_FORMAT.format(rsSub.getDouble("shop_total")));
                        sub.put("commissionRate", rsSub.getDouble("commission_rate"));
                        sub.put("commissionAmountFormatted", CURRENCY_FORMAT.format(rsSub.getDouble("commission_amount")));

                        String stt = rsSub.getString("status");
                        sub.put("status", stt);
                        if ("DELIVERED".equalsIgnoreCase(stt)) {
                            sub.put("statusText", "Đã giao hàng");
                            sub.put("statusBadge", "bg-success-subtle text-success border border-success-subtle");
                        } else if ("SHIPPING".equalsIgnoreCase(stt)) {
                            sub.put("statusText", "Đang giao hàng");
                            sub.put("statusBadge", "bg-primary-subtle text-primary border border-primary-subtle");
                        } else if ("REFUNDED".equalsIgnoreCase(stt)) {
                            sub.put("statusText", "Đã hoàn tiền");
                            sub.put("statusBadge", "bg-warning-subtle text-warning-emphasis border border-warning-subtle");
                        } else {
                            sub.put("statusText", stt);
                            sub.put("statusBadge", "bg-secondary-subtle text-secondary border border-secondary-subtle");
                        }

                        // 3. Items inside this Sub-Order
                        String itemSql = "SELECT oi.order_item_id, oi.variant_id, oi.product_name_snapshot, oi.variant_name_snapshot, "
                                       + "       oi.sku_snapshot, oi.unit, oi.unit_price, oi.quantity, oi.total_price "
                                       + "FROM order_items oi "
                                       + "WHERE oi.sub_order_id = ? "
                                       + "ORDER BY oi.order_item_id ASC";

                        List<Map<String, Object>> items = new ArrayList<>();
                        try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                            psItem.setLong(1, subOrderId);
                            try (ResultSet rsItem = psItem.executeQuery()) {
                                while (rsItem.next()) {
                                    Map<String, Object> itemMap = new HashMap<>();
                                    itemMap.put("orderItemId", rsItem.getLong("order_item_id"));
                                    String pName = rsItem.getString("product_name_snapshot");
                                    itemMap.put("productName", pName);
                                    itemMap.put("variantName", rsItem.getString("variant_name_snapshot"));
                                    itemMap.put("sku", rsItem.getString("sku_snapshot"));
                                    itemMap.put("unit", rsItem.getString("unit"));
                                    itemMap.put("unitPriceFormatted", CURRENCY_FORMAT.format(rsItem.getDouble("unit_price")));
                                    itemMap.put("quantity", rsItem.getInt("quantity"));
                                    itemMap.put("totalPriceFormatted", CURRENCY_FORMAT.format(rsItem.getDouble("total_price")));

                                    // Thumbnail fallback
                                    String img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=100&h=100&fit=crop";
                                    if (pName != null) {
                                        String lower = pName.toLowerCase();
                                        if (lower.contains("dâu")) img = "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=100&h=100&fit=crop";
                                        else if (lower.contains("sầu")) img = "https://images.unsplash.com/photo-1587334274328-64186a80aeee?w=100&h=100&fit=crop";
                                        else if (lower.contains("xoài")) img = "https://images.unsplash.com/photo-1553279768-865429fa0078?w=100&h=100&fit=crop";
                                        else if (lower.contains("quà")) img = "https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=100&h=100&fit=crop";
                                    }
                                    itemMap.put("thumbnailUrl", img);

                                    items.add(itemMap);
                                }
                            }
                        }
                        sub.put("items", items);

                        // 4. Delivery info for this sub_order
                        String delSql = "SELECT del.delivery_id, del.driver_id, del.tracking_number, del.delivery_status, "
                                      + "       del.proof_image_url, del.failure_reason, del.assigned_at, del.delivered_at, "
                                      + "       drv.full_name as driver_name, drv.phone as driver_phone "
                                      + "FROM deliveries del "
                                      + "LEFT JOIN users drv ON del.driver_id = drv.user_id "
                                      + "WHERE del.sub_order_id = ?";

                        Map<String, Object> deliveryMap = new HashMap<>();
                        try (PreparedStatement psDel = conn.prepareStatement(delSql)) {
                            psDel.setLong(1, subOrderId);
                            try (ResultSet rsDel = psDel.executeQuery()) {
                                if (rsDel.next()) {
                                    deliveryMap.put("deliveryId", rsDel.getLong("delivery_id"));
                                    deliveryMap.put("trackingNumber", rsDel.getString("tracking_number"));
                                    String delStatus = rsDel.getString("delivery_status");
                                    deliveryMap.put("deliveryStatus", delStatus);
                                    if ("DELIVERED".equalsIgnoreCase(delStatus)) {
                                        deliveryMap.put("statusText", "Đã giao thành công");
                                        deliveryMap.put("statusBadge", "bg-success text-white");
                                    } else if ("IN_TRANSIT".equalsIgnoreCase(delStatus)) {
                                        deliveryMap.put("statusText", "Đang vận chuyển");
                                        deliveryMap.put("statusBadge", "bg-primary text-white");
                                    } else if ("ASSIGNED".equalsIgnoreCase(delStatus)) {
                                        deliveryMap.put("statusText", "Đã điều phối tài xế");
                                        deliveryMap.put("statusBadge", "bg-info text-dark");
                                    } else {
                                        deliveryMap.put("statusText", delStatus);
                                        deliveryMap.put("statusBadge", "bg-secondary text-white");
                                    }
                                    deliveryMap.put("driverId", rsDel.getLong("driver_id"));
                                    deliveryMap.put("driverName", rsDel.getString("driver_name") != null ? rsDel.getString("driver_name") : "Chưa gán tài xế");
                                    deliveryMap.put("driverPhone", rsDel.getString("driver_phone") != null ? rsDel.getString("driver_phone") : "-");
                                    deliveryMap.put("proofImageUrl", rsDel.getString("proof_image_url"));
                                    deliveryMap.put("failureReason", rsDel.getString("failure_reason"));

                                    Timestamp assAt = rsDel.getTimestamp("assigned_at");
                                    deliveryMap.put("assignedAtFormatted", assAt != null ? DATETIME_FORMAT.format(assAt) : "-");
                                    Timestamp devAt = rsDel.getTimestamp("delivered_at");
                                    deliveryMap.put("deliveredAtFormatted", devAt != null ? DATETIME_FORMAT.format(devAt) : "-");
                                }
                            }
                        }
                        sub.put("delivery", deliveryMap);

                        subOrders.add(sub);
                    }
                }
            }
            detail.put("subOrders", subOrders);
            detail.put("subOrdersCount", subOrders.size());

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getOrderDetail for orderId=" + orderId, ex);
        }

        return detail;
    }

    // -------------------------------------------------------------------------
    // 8.5 DELIVERIES (GIAO VẬN NỘI BỘ & ĐIỀU PHỐI TÀI XẾ)
    // -------------------------------------------------------------------------

    /**
     * Get statistics of deliveries.
     */
    public Map<String, Object> getDeliveryStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                   + "    COUNT(*) as total_deliveries, "
                   + "    SUM(CASE WHEN delivery_status = 'DELIVERED' THEN 1 ELSE 0 END) as delivered_count, "
                   + "    SUM(CASE WHEN delivery_status = 'IN_TRANSIT' THEN 1 ELSE 0 END) as in_transit_count, "
                   + "    SUM(CASE WHEN delivery_status = 'ASSIGNED' THEN 1 ELSE 0 END) as assigned_count, "
                   + "    SUM(CASE WHEN delivery_status = 'FAILED' THEN 1 ELSE 0 END) as failed_count, "
                   + "    SUM(CASE WHEN proof_image_url IS NOT NULL AND proof_image_url != '' THEN 1 ELSE 0 END) as proof_count "
                   + "FROM deliveries";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                stats.put("totalDeliveries", rs.getInt("total_deliveries"));
                stats.put("deliveredCount", rs.getInt("delivered_count"));
                stats.put("inTransitCount", rs.getInt("in_transit_count"));
                stats.put("assignedCount", rs.getInt("assigned_count"));
                stats.put("failedCount", rs.getInt("failed_count"));
                stats.put("proofCount", rs.getInt("proof_count"));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getDeliveryStats: " + ex.getMessage());
        }
        return stats;
    }

    public List<Map<String, Object>> getDeliveriesList() {
        return getDeliveriesList(null, null);
    }

    /**
     * Get list of deliveries with filters.
     */
    public List<Map<String, Object>> getDeliveriesList(String statusFilter, String searchKeyword) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT del.delivery_id, del.sub_order_id, del.driver_id, del.tracking_number, ")
           .append("       del.delivery_status, del.proof_image_url, del.failure_reason, del.assigned_at, del.delivered_at, ")
           .append("       so.sub_order_code, so.shop_total, so.delivery_slot, ")
           .append("       o.order_id, o.order_code, ")
           .append("       s.shop_id, s.shop_name, s.phone as shop_phone, s.province as shop_province, ")
           .append("       uCust.full_name as customer_name, uCust.phone as customer_phone, ")
           .append("       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city, ")
           .append("       uDrv.full_name as driver_name, uDrv.phone as driver_phone ")
           .append("FROM deliveries del ")
           .append("JOIN sub_orders so ON del.sub_order_id = so.sub_order_id ")
           .append("JOIN orders o ON so.order_id = o.order_id ")
           .append("JOIN shops s ON so.shop_id = s.shop_id ")
           .append("JOIN users uCust ON o.customer_id = uCust.user_id ")
           .append("LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id ")
           .append("LEFT JOIN users uDrv ON del.driver_id = uDrv.user_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            conditions.add("del.delivery_status = ?");
            params.add(statusFilter.trim());
        }

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = "%" + searchKeyword.trim().toLowerCase() + "%";
            conditions.add("(LOWER(del.tracking_number) LIKE ? OR LOWER(o.order_code) LIKE ? OR LOWER(so.sub_order_code) LIKE ? OR LOWER(s.shop_name) LIKE ? OR LOWER(uCust.full_name) LIKE ? OR LOWER(COALESCE(uDrv.full_name, '')) LIKE ?)");
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }

        sql.append("ORDER BY del.delivery_id DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("deliveryId", rs.getLong("delivery_id"));
                    item.put("subOrderId", rs.getLong("sub_order_id"));
                    item.put("subOrderCode", rs.getString("sub_order_code"));
                    item.put("orderId", rs.getLong("order_id"));
                    item.put("orderCode", rs.getString("order_code"));
                    item.put("trackingNumber", rs.getString("tracking_number"));
                    item.put("shopTotalFormatted", CURRENCY_FORMAT.format(rs.getDouble("shop_total")));
                    item.put("deliverySlot", rs.getString("delivery_slot") != null ? rs.getString("delivery_slot") : "Tiêu chuẩn");

                    String dStatus = rs.getString("delivery_status");
                    item.put("deliveryStatus", dStatus);
                    if ("DELIVERED".equalsIgnoreCase(dStatus)) {
                        item.put("statusText", "Đã giao thành công");
                        item.put("statusBadge", "bg-success-subtle text-success border border-success-subtle");
                        item.put("statusIcon", "bi-check-circle-fill");
                    } else if ("IN_TRANSIT".equalsIgnoreCase(dStatus)) {
                        item.put("statusText", "Đang vận chuyển");
                        item.put("statusBadge", "bg-primary-subtle text-primary border border-primary-subtle");
                        item.put("statusIcon", "bi-truck");
                    } else if ("ASSIGNED".equalsIgnoreCase(dStatus)) {
                        item.put("statusText", "Đã phân công");
                        item.put("statusBadge", "bg-info-subtle text-info-emphasis border border-info-subtle");
                        item.put("statusIcon", "bi-person-check");
                    } else if ("FAILED".equalsIgnoreCase(dStatus)) {
                        item.put("statusText", "Giao thất bại");
                        item.put("statusBadge", "bg-danger-subtle text-danger border border-danger-subtle");
                        item.put("statusIcon", "bi-x-circle-fill");
                    } else {
                        item.put("statusText", dStatus);
                        item.put("statusBadge", "bg-secondary-subtle text-secondary border border-secondary-subtle");
                        item.put("statusIcon", "bi-clock");
                    }

                    item.put("shopId", rs.getLong("shop_id"));
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("shopPhone", rs.getString("shop_phone"));
                    item.put("shopProvince", rs.getString("shop_province"));

                    item.put("customerName", rs.getString("customer_name"));
                    item.put("customerPhone", rs.getString("customer_phone"));
                    item.put("recipientName", rs.getString("recipient_name") != null ? rs.getString("recipient_name") : rs.getString("customer_name"));
                    item.put("recipientPhone", rs.getString("recipient_phone") != null ? rs.getString("recipient_phone") : rs.getString("customer_phone"));

                    String street = rs.getString("street_address");
                    String ward = rs.getString("ward");
                    String district = rs.getString("district");
                    String city = rs.getString("city");
                    StringBuilder fullAddr = new StringBuilder();
                    if (street != null && !street.isEmpty()) fullAddr.append(street);
                    if (ward != null && !ward.isEmpty()) fullAddr.append(", ").append(ward);
                    if (district != null && !district.isEmpty()) fullAddr.append(", ").append(district);
                    if (city != null && !city.isEmpty()) fullAddr.append(", ").append(city);
                    item.put("fullAddress", fullAddr.toString());
                    item.put("city", city != null ? city : "Toàn quốc");

                    item.put("driverId", rs.getObject("driver_id"));
                    item.put("driverName", rs.getString("driver_name") != null ? rs.getString("driver_name") : "Chưa chỉ định");
                    item.put("driverPhone", rs.getString("driver_phone") != null ? rs.getString("driver_phone") : "-");

                    item.put("proofImageUrl", rs.getString("proof_image_url"));
                    item.put("failureReason", rs.getString("failure_reason"));

                    Timestamp assAt = rs.getTimestamp("assigned_at");
                    item.put("assignedAtFormatted", assAt != null ? DATETIME_FORMAT.format(assAt) : "-");
                    Timestamp devAt = rs.getTimestamp("delivered_at");
                    item.put("deliveredAtFormatted", devAt != null ? DATETIME_FORMAT.format(devAt) : "-");

                    list.add(item);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getDeliveriesList: " + ex.getMessage());
        }
        return list;
    }

 public boolean updateRequestStatus(int requestId, String status, String reason, int adminId) {
    // 1. Cập nhật trạng thái đơn đăng ký (chỉ xử lý đơn đang chờ duyệt)
    String sqlUpdateReq = "UPDATE [dbo].[shop_requests] "
            + "SET status = ?, reason = ?, reviewed_by = ?, reviewed_at = GETDATE() "
            + "WHERE request_id = ? AND status IN ('PENDING', 'PENDING_KYC')";

    // 2a. Đổi role CUSTOMER -> SHOP_OWNER (nếu user đã có dòng trong user_roles)
    String sqlUpdateRole = "UPDATE [dbo].[user_roles] "
            + "SET role_id = (SELECT role_id FROM [dbo].[roles] WHERE role_name = 'SHOP_OWNER') "
            + "WHERE user_id = (SELECT user_id FROM [dbo].[shop_requests] WHERE request_id = ?)";

    // 2b. Nếu user chưa có dòng nào trong user_roles thì thêm mới
    String sqlInsertRole = "INSERT INTO [dbo].[user_roles] (user_id, role_id) "
            + "SELECT sr.user_id, r.role_id FROM [dbo].[shop_requests] sr, [dbo].[roles] r "
            + "WHERE sr.request_id = ? AND r.role_name = 'SHOP_OWNER'";

    // 3. Tạo shop thật trong bảng shops (bỏ qua nếu user đã có shop)
    String sqlInsertShop = "INSERT INTO [dbo].[shops] "
            + "(owner_id, shop_name, slug, description, business_type, logo_url, banner_url, phone, address, province, "
            + " commission_rate, rating, total_sales_amount, total_orders_count, status, created_at, updated_at) "
            + "SELECT sr.user_id, sr.shop_name, 'shop-' + CAST(sr.request_id AS VARCHAR(20)), sr.shop_description, "
            + "       sr.business_type, sr.shop_logo_url, sr.shop_banner_url, u.phone, "
            + "       CONCAT_WS(', ', sr.street_address, sr.ward, sr.district, sr.province), sr.province, "
            + "       8.0, 0, 0, 0, 'ACTIVE', GETDATE(), GETDATE() "
            + "FROM [dbo].[shop_requests] sr "
            + "JOIN [dbo].[users] u ON u.user_id = sr.user_id "
            + "WHERE sr.request_id = ? "
            + "AND NOT EXISTS (SELECT 1 FROM [dbo].[shops] s WHERE s.owner_id = sr.user_id)";

    try (Connection conn = this.getConnection()) {
        if (conn == null) {
            System.err.println(">>> Không thể kết nối tới Database!");
            return false;
        }
        conn.setAutoCommit(false);

        try {
            // Bước 1: cập nhật shop_requests
            try (PreparedStatement psReq = conn.prepareStatement(sqlUpdateReq)) {
                psReq.setString(1, status);
                psReq.setString(2, reason);
                if (adminId > 0) {
                    psReq.setInt(3, adminId);
                } else {
                    psReq.setNull(3, java.sql.Types.INTEGER);
                }
                psReq.setInt(4, requestId);

                int affected = psReq.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    System.err.println(">>> Không tìm thấy đơn hoặc đơn đã được xử lý: " + requestId);
                    return false;
                }
            }

            // Gửi thông báo kết quả cho chủ shop
            notifyRequestResult(conn, requestId, status, reason);

            // Bước 2 + 3: chỉ khi APPROVED
            if ("APPROVED".equalsIgnoreCase(status)) {
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateRole)) {
                    ps.setInt(1, requestId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) { // user chưa có dòng nào trong user_roles
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsertRole)) {
                        ps.setInt(1, requestId);
                        ps.executeUpdate();
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(sqlInsertShop)) {
                    ps.setInt(1, requestId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            conn.rollback(); // lỗi ở bất kỳ bước nào thì hủy toàn bộ
            throw e;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}
                    
     /**
     * Fetch list of all active drivers for dispatch assignment.
     */
    public List<Map<String, Object>> getAllDrivers() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, u.phone, u.email, u.status "
                   + "FROM users u "
                   + "JOIN user_roles ur ON u.user_id = ur.user_id "
                   + "JOIN roles r ON ur.role_id = r.role_id "
                   + "WHERE r.role_name = 'DRIVER' AND u.status = 'ACTIVE' "
                   + "ORDER BY u.full_name ASC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> drv = new HashMap<>();
                drv.put("userId", rs.getLong("user_id"));
                drv.put("fullName", rs.getString("full_name"));
                drv.put("phone", rs.getString("phone") != null ? rs.getString("phone") : "Chưa có SĐT");
                drv.put("email", rs.getString("email"));
                list.add(drv);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getAllDrivers: " + ex.getMessage());
        }
        return list;
    }

    /**
     * Dispatch / re-assign driver and update delivery status.
     */
    public boolean assignDriver(long deliveryId, long driverId, String trackingNumber, String deliveryStatus) {
        String updateDelSql = "UPDATE deliveries SET driver_id = ?, tracking_number = ?, delivery_status = ?, "
                            + "       assigned_at = COALESCE(assigned_at, CURRENT_TIMESTAMP), "
                            + "       delivered_at = CASE WHEN ? = 'DELIVERED' AND delivered_at IS NULL THEN CURRENT_TIMESTAMP ELSE delivered_at END "
                            + "WHERE delivery_id = ?";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(updateDelSql)) {
                ps.setLong(1, driverId);
                ps.setString(2, trackingNumber != null ? trackingNumber.trim() : null);
                ps.setString(3, deliveryStatus != null ? deliveryStatus.trim() : "ASSIGNED");
                ps.setString(4, deliveryStatus != null ? deliveryStatus.trim() : "ASSIGNED");
                ps.setLong(5, deliveryId);
                ps.executeUpdate();
            }

            // Sync with sub_orders status if delivered or shipping
            if ("DELIVERED".equalsIgnoreCase(deliveryStatus)) {
                String subSql = "UPDATE sub_orders SET status = 'DELIVERED', updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = (SELECT sub_order_id FROM deliveries WHERE delivery_id = ?)";
                try (PreparedStatement psSub = conn.prepareStatement(subSql)) {
                    psSub.setLong(1, deliveryId);
                    psSub.executeUpdate();
                }
            } else if ("IN_TRANSIT".equalsIgnoreCase(deliveryStatus)) {
                String subSql = "UPDATE sub_orders SET status = 'SHIPPING', updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = (SELECT sub_order_id FROM deliveries WHERE delivery_id = ?)";
                try (PreparedStatement psSub = conn.prepareStatement(subSql)) {
                    psSub.setLong(1, deliveryId);
                    psSub.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in assignDriver: " + ex.getMessage(), ex);
            return false;
        }
    }
}
