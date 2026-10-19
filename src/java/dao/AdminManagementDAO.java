package dao;

import model.ShopRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.DecimalFormat;
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
        sql.append("SELECT u.user_id, u.full_name, u.email, u.phone, u.status, u.created_at, ")
           .append("       COALESCE(r.role_name, 'CUSTOMER') as role_name, ")
           .append("       s.shop_name, s.status as shop_status, ")
           .append("       COALESCE(o.order_count, 0) as order_count, ")
           .append("       COALESCE(o.total_spent, 0) as total_spent ")
           .append("FROM users u ")
           .append("LEFT JOIN user_roles ur ON u.user_id = ur.user_id ")
           .append("LEFT JOIN roles r ON ur.role_id = r.role_id ")
           .append("LEFT JOIN shops s ON u.user_id = s.owner_id ")
           .append("LEFT JOIN (")
           .append("    SELECT customer_id, COUNT(order_id) as order_count, SUM(final_amount) as total_spent ")
           .append("    FROM orders GROUP BY customer_id")
           .append(") o ON u.user_id = o.customer_id ");

        List<String> conditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter.trim())) {
            String rf = roleFilter.trim();
            if ("ADMIN_STAFF".equalsIgnoreCase(rf)) {
                conditions.add("r.role_name IN ('ADMIN', 'STAFF')");
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
            conditions.add("(LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(u.phone) LIKE ? OR LOWER(s.shop_name) LIKE ? OR CAST(u.user_id AS VARCHAR(20)) LIKE ?)");
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
                    item.put("phone", rs.getString("phone"));
                    item.put("roleName", rs.getString("role_name"));
                    item.put("status", rs.getString("status"));
                    item.put("shopName", rs.getString("shop_name"));
                    item.put("shopStatus", rs.getString("shop_status"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    item.put("createdAtFormatted", createdAt != null ? DATE_FORMAT.format(createdAt) : "-");

                    int orderCount = rs.getInt("order_count");
                    double spent = rs.getDouble("total_spent");
                    item.put("orderCount", orderCount);
                    item.put("totalSpentFormatted", spent > 0 ? CURRENCY_FORMAT.format(spent) : "-");

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
        sql.append("SELECT c.category_id, c.parent_id, c.category_name, c.slug, c.description, c.image_url, c.icon_class, c.is_active, ")
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
        // Select Level 2 categories under "Trái Cây" (parent_id = 1)
        String sql = "SELECT c.category_id, c.category_name, c.slug, c.description, c.image_url, c.icon_class, c.is_active "
                   + "FROM categories c WHERE c.parent_id = 1 ORDER BY c.display_order ASC";

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

    // -------------------------------------------------------------------------
    // 4. VOUCHERS / COUPONS
    // -------------------------------------------------------------------------
    // -------------------------------------------------------------------------
    // 4. VOUCHERS / COUPONS
    // -------------------------------------------------------------------------
    public List<Map<String, Object>> getVouchersList() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT coupon_id, code, title, discount_type, discount_value, min_order_value, "
                   + "       max_discount_amount, usage_limit, used_count, sponsor_type, is_active "
                   + "FROM coupons ORDER BY coupon_id ASC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                int cid = rs.getInt("coupon_id");
                item.put("couponId", cid);
                String code = rs.getString("code");
                item.put("code", code);
                item.put("couponCode", code);
                item.put("title", rs.getString("title"));
                String type = rs.getString("discount_type");
                double val = rs.getDouble("discount_value");
                double minOrder = rs.getDouble("min_order_value");
                int used = rs.getInt("used_count");
                int limit = rs.getInt("usage_limit");
                String sponsor = rs.getString("sponsor_type");

                if ("PERCENTAGE".equalsIgnoreCase(type)) {
                    item.put("discountType", "discount");
                    item.put("stubVal", String.format("%.0f%%", val));
                    item.put("stubTag", "OCOP VIỆT");
                    item.put("stubBg", "#dcfce7");
                    item.put("stubColor", "#15803d");
                    item.put("stubIcon", "bi-flower1");
                    item.put("discountFormatted", String.format("Giảm %.0f%% (Tối đa %s)", val, CURRENCY_FORMAT.format(rs.getDouble("max_discount_amount"))));
                } else if ("FREESHIP".equalsIgnoreCase(type)) {
                    item.put("discountType", "freeship");
                    item.put("stubVal", "30K");
                    item.put("stubTag", "SHIP LẠNH");
                    item.put("stubBg", "#e0f2fe");
                    item.put("stubColor", "#0369a1");
                    item.put("stubIcon", "bi-snow2");
                    item.put("discountFormatted", "100% Phí Ship (Tối đa 30,000 ₫)");
                } else {
                    item.put("discountType", cid % 2 == 0 ? "flash" : "welcome");
                    item.put("stubVal", String.format("%.0fK", val / 1000));
                    item.put("stubTag", cid % 2 == 0 ? "GIỜ VÀNG" : "BẠN MỚI");
                    item.put("stubBg", cid % 2 == 0 ? "#ffedd5" : "#ede9fe");
                    item.put("stubColor", cid % 2 == 0 ? "#ea580c" : "#7c3aed");
                    item.put("stubIcon", cid % 2 == 0 ? "bi-lightning-charge-fill" : "bi-person-check-fill");
                    item.put("discountFormatted", "Giảm " + CURRENCY_FORMAT.format(val));
                }

                item.put("minSpendFormatted", CURRENCY_FORMAT.format(minOrder));
                item.put("usedCount", used);
                item.put("usageLimit", limit);
                item.put("remainingCount", Math.max(0, limit - used));
                item.put("usageFormatted", used + " / " + limit + " mã");
                item.put("sponsorType", "PLATFORM".equalsIgnoreCase(sponsor) ? "platform" : "cofunding");
                item.put("sponsorTag", "PLATFORM".equalsIgnoreCase(sponsor) ? "100% SÀN TÀI TRỢ" : "ĐỒNG TÀI TRỢ 65/35");
                item.put("isActive", rs.getBoolean("is_active"));
                
                int pct = limit > 0 ? (int) Math.round((double) used * 100.0 / limit) : 0;
                item.put("percentUsed", pct);
                
                // GMV & budget estimates
                double estGmv = used * Math.max(minOrder, 150000.0);
                double estBudgetUsed = used * (val > 100 ? val : (val * 2000));
                item.put("gmvFormatted", CURRENCY_FORMAT.format(estGmv));
                item.put("budgetUsedFormatted", CURRENCY_FORMAT.format(estBudgetUsed));
                list.add(item);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getVouchersList: " + ex.getMessage());
        }
        return list;
    }

    // -------------------------------------------------------------------------
    // 5. DISPUTES
    // -------------------------------------------------------------------------
    public List<Map<String, Object>> getDisputesList() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT d.dispute_id, d.dispute_code, d.reason_category, d.complaint_text, "
                   + "       d.claim_amount, d.evidence_image_url, d.resolution_note, d.status, d.created_at, "
                   + "       u.full_name as customer_name, s.shop_name, s.rating as shop_rating, "
                   + "       so.sub_order_code, o.order_code "
                   + "FROM disputes d "
                   + "JOIN users u ON d.customer_id = u.user_id "
                   + "JOIN shops s ON d.shop_id = s.shop_id "
                   + "LEFT JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
                   + "LEFT JOIN orders o ON so.order_id = o.order_id "
                   + "ORDER BY d.dispute_id DESC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("disputeId", rs.getLong("dispute_id"));
                String code = rs.getString("dispute_code");
                item.put("disputeCode", code);
                item.put("orderCode", rs.getString("order_code") != null ? "#" + rs.getString("order_code") : "#ORD-" + rs.getLong("dispute_id"));
                String reason = rs.getString("reason_category");
                item.put("reasonCategory", reason != null ? reason : "Hư hỏng hoa quả");
                item.put("complaintText", rs.getString("complaint_text"));
                double claimAmount = rs.getDouble("claim_amount");
                item.put("claimAmount", claimAmount);
                item.put("claimAmountFormatted", CURRENCY_FORMAT.format(claimAmount));
                item.put("shopOfferFormatted", CURRENCY_FORMAT.format(claimAmount * 0.5));
                String stt = rs.getString("status");
                item.put("status", stt);
                
                String statusPill = "CẦN ADMIN PHÁN QUYẾT";
                String statusGroup = "admin_decision";
                if ("REFUNDED_BUYER".equalsIgnoreCase(stt)) {
                    statusPill = "ĐÃ HOÀN TIỀN";
                    statusGroup = "refunded";
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

                String resNote = rs.getString("resolution_note");
                if (resNote == null || resNote.trim().isEmpty()) {
                    resNote = "Hồ sơ khiếu nại đang được hội đồng trọng tài sàn FreshFruit kiểm duyệt đối soát dữ liệu đóng gói cùng camera giao nhận vận chuyển.";
                }
                item.put("resolutionNote", resNote);
                
                java.sql.Timestamp created = rs.getTimestamp("created_at");
                String createdStr = created != null ? DATE_FORMAT.format(created) : "Hôm nay";
                item.put("createdFormatted", createdStr);

                list.add(item);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getDisputesList: " + ex.getMessage());
        }
        return list;
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
                int certified = rs.getInt("certified_count");
                int lowStock = rs.getInt("low_stock_count");
                int featured = rs.getInt("featured_count");

                stats.put("totalCount", total);
                stats.put("activeCount", active);
                stats.put("inactiveCount", inactive);
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
           .append("       p.is_featured, p.is_active, p.created_at, p.updated_at, ")
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
            if ("approved".equalsIgnoreCase(sf) || "ACTIVE".equalsIgnoreCase(sf)) {
                conditions.add("p.is_active = 1");
            } else if ("pending".equalsIgnoreCase(sf) || "rejected".equalsIgnoreCase(sf) || "INACTIVE".equalsIgnoreCase(sf)) {
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
        sql.append("ORDER BY p.product_id ASC");

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
                        item.put("modTag", "CHỜ DUYỆT / TẠM ẨN");
                        item.put("modTagClass", "bg-warning-subtle text-warning-emphasis border-warning-subtle");
                        item.put("modTagIcon", "bi-clock-history");
                        item.put("riskBadgeClass", "badge-ai-warning");
                        item.put("riskBadgeIcon", "bi-exclamation-circle-fill");
                        item.put("riskBadgeText", "Chờ thẩm định");
                        item.put("riskLevel", "warning");
                        item.put("statusGroup", "pending rejected");
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

    // -------------------------------------------------------------------------
    // 8. ORDERS & FULFILLMENT STREAM
    // -------------------------------------------------------------------------
    public List<Map<String, Object>> getOrdersList() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT o.order_id, o.order_code, o.final_amount, o.order_status, o.payment_status, "
                   + "       o.payment_method, u.full_name as customer_name, osa.city "
                   + "FROM orders o "
                   + "JOIN users u ON o.customer_id = u.user_id "
                   + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                   + "ORDER BY o.order_id DESC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("orderId", rs.getLong("order_id"));
                item.put("orderCode", rs.getString("order_code"));
                item.put("customerName", rs.getString("customer_name"));
                item.put("city", rs.getString("city") != null ? rs.getString("city") : "Toàn quốc");
                item.put("finalAmountFormatted", CURRENCY_FORMAT.format(rs.getDouble("final_amount")));
                item.put("orderStatus", rs.getString("order_status"));
                item.put("paymentStatus", rs.getString("payment_status"));
                item.put("paymentMethod", rs.getString("payment_method"));
                list.add(item);
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
}
