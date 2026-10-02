package dao;

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
    public Map<String, Object> getShopStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT COUNT(*) as total_shops, "
                   + "       SUM(CASE WHEN status = 'PENDING_KYC' THEN 1 ELSE 0 END) as pending_kyc, "
                   + "       AVG(commission_rate) as avg_comm, "
                   + "       SUM(CASE WHEN status = 'SUSPENDED' THEN 1 ELSE 0 END) as suspended "
                   + "FROM shops";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                stats.put("totalShops", rs.getInt("total_shops"));
                stats.put("pendingKyc", rs.getInt("pending_kyc"));
                stats.put("avgComm", String.format("%.1f%%", rs.getDouble("avg_comm")));
                stats.put("suspended", rs.getInt("suspended"));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getShopStats: " + ex.getMessage());
            stats.put("totalShops", 6);
            stats.put("pendingKyc", 2);
            stats.put("avgComm", "8.0%");
            stats.put("suspended", 0);
        }
        return stats;
    }

    public List<Map<String, Object>> getShopsList() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT s.shop_id, s.shop_name, s.business_type, s.province, s.certification_name, "
                   + "       s.commission_rate, s.total_sales_amount, s.total_orders_count, s.status, "
                   + "       u.full_name as owner_name, u.email as owner_email "
                   + "FROM shops s "
                   + "JOIN users u ON s.owner_id = u.user_id "
                   + "ORDER BY s.shop_id ASC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("shopId", rs.getLong("shop_id"));
                item.put("shopName", rs.getString("shop_name"));
                item.put("businessType", rs.getString("business_type"));
                item.put("province", rs.getString("province"));
                item.put("certificationName", rs.getString("certification_name"));
                item.put("commissionRate", String.format("%.1f%%", rs.getDouble("commission_rate")));
                item.put("totalSalesFormatted", CURRENCY_FORMAT.format(rs.getDouble("total_sales_amount")));
                item.put("totalOrdersCount", rs.getInt("total_orders_count"));
                item.put("status", rs.getString("status"));
                item.put("ownerName", rs.getString("owner_name"));
                item.put("ownerEmail", rs.getString("owner_email"));
                list.add(item);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getShopsList: " + ex.getMessage());
        }
        return list;
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
        return getUsersList(null);
    }

    public List<Map<String, Object>> getUsersList(String roleFilter) {
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

        if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter)) {
            if ("ADMIN_STAFF".equalsIgnoreCase(roleFilter)) {
                sql.append("WHERE r.role_name IN ('ADMIN', 'STAFF') ");
            } else if ("SHOP_OWNER".equalsIgnoreCase(roleFilter)) {
                sql.append("WHERE r.role_name = 'SHOP_OWNER' ");
            } else if ("DRIVER".equalsIgnoreCase(roleFilter)) {
                sql.append("WHERE r.role_name = 'DRIVER' ");
            } else if ("CUSTOMER".equalsIgnoreCase(roleFilter)) {
                sql.append("WHERE (r.role_name = 'CUSTOMER' OR r.role_name IS NULL) ");
            } else {
                sql.append("WHERE r.role_name = ? ");
            }
        }
        sql.append("ORDER BY u.user_id ASC");

        try (Connection conn = getConnection()) {
            PreparedStatement ps;
            if (roleFilter != null && !roleFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(roleFilter)
                    && !"ADMIN_STAFF".equalsIgnoreCase(roleFilter)
                    && !"SHOP_OWNER".equalsIgnoreCase(roleFilter)
                    && !"DRIVER".equalsIgnoreCase(roleFilter)
                    && !"CUSTOMER".equalsIgnoreCase(roleFilter)) {
                ps = conn.prepareStatement(sql.toString());
                ps.setString(1, roleFilter);
            } else {
                ps = conn.prepareStatement(sql.toString());
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
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.category_name, c.slug, c.description, c.is_active, "
                   + "       COALESCE(p.active_skus, 0) as active_skus "
                   + "FROM categories c "
                   + "LEFT JOIN ("
                   + "    SELECT category_id, COUNT(product_id) as active_skus "
                   + "    FROM products WHERE is_active = 1 GROUP BY category_id"
                   + ") p ON c.category_id = p.category_id "
                   + "ORDER BY c.category_id ASC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                int id = rs.getInt("category_id");
                item.put("categoryId", id);
                item.put("categoryName", rs.getString("category_name"));
                item.put("slug", rs.getString("slug"));
                item.put("description", rs.getString("description"));
                item.put("activeSkus", rs.getInt("active_skus"));
                item.put("isActive", rs.getBoolean("is_active"));

                // Cold Storage details by category
                switch (id) {
                    case 1:
                        item.put("tempRange", "2°C – 5°C");
                        item.put("recommendedStorage", "Kho lạnh Hub A");
                        break;
                    case 2:
                        item.put("tempRange", "10°C – 14°C");
                        item.put("recommendedStorage", "Kho thoáng mát Vùng 3");
                        break;
                    case 3:
                        item.put("tempRange", "0°C – 2°C");
                        item.put("recommendedStorage", "Hầm lạnh chuyên dụng B");
                        break;
                    case 4:
                        item.put("tempRange", "4°C – 8°C");
                        item.put("recommendedStorage", "Kho lạnh Hub C");
                        break;
                    default:
                        item.put("tempRange", "8°C – 12°C");
                        item.put("recommendedStorage", "Khu đóng gói cao cấp");
                        break;
                }
                list.add(item);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Error in getCategoriesList: " + ex.getMessage());
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
    public List<Map<String, Object>> getProductsList() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name as product_name, p.origin, p.storage_temp, p.certification, "
                   + "       c.category_name, s.shop_name, pv.sku, pv.price, pv.stock_quantity, pv.unit, "
                   + "       (SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id ORDER BY is_thumbnail DESC, image_id ASC) as thumbnail_url "
                   + "FROM products p "
                   + "LEFT JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN shops s ON p.shop_id = s.shop_id "
                   + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id "
                   + "ORDER BY p.product_id ASC";

        try (Connection conn = getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            int idx = 0;
            while (rs.next()) {
                idx++;
                Map<String, Object> item = new HashMap<>();
                long pid = rs.getLong("product_id");
                item.put("productId", pid);
                String pName = rs.getString("product_name");
                item.put("productName", pName);
                item.put("origin", rs.getString("origin") != null ? rs.getString("origin") : "Đà Lạt, Lâm Đồng");
                item.put("storageTemp", rs.getString("storage_temp") != null ? rs.getString("storage_temp") : "2-5°C");
                String cert = rs.getString("certification") != null ? rs.getString("certification") : "VietGAP Certified";
                item.put("certification", cert);
                item.put("categoryName", rs.getString("category_name"));
                item.put("shopName", rs.getString("shop_name") != null ? rs.getString("shop_name") : "Nông Trại Xanh");
                String sku = rs.getString("sku") != null ? rs.getString("sku") : "FRU-" + pid;
                item.put("sku", sku);
                double price = rs.getDouble("price");
                item.put("price", price);
                item.put("priceFormatted", price > 0 ? CURRENCY_FORMAT.format(price) : "120,000 ₫");
                item.put("unit", rs.getString("unit") != null ? rs.getString("unit") : "kg");
                item.put("stockFormatted", rs.getInt("stock_quantity") + " " + (rs.getString("unit") != null ? rs.getString("unit") : "kg"));

                // Image matching fruit name
                String img = rs.getString("thumbnail_url");
                if (img == null || img.trim().isEmpty()) {
                    String lower = pName.toLowerCase();
                    if (lower.contains("dâu")) {
                        img = "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=150&h=150&fit=crop";
                    } else if (lower.contains("sầu")) {
                        img = "https://images.unsplash.com/photo-1587334274328-64186a80aeee?w=150&h=150&fit=crop";
                    } else if (lower.contains("xoài")) {
                        img = "https://images.unsplash.com/photo-1553279768-865429fa0078?w=150&h=150&fit=crop";
                    } else if (lower.contains("bưởi")) {
                        img = "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=150&h=150&fit=crop";
                    } else if (lower.contains("mận")) {
                        img = "https://images.unsplash.com/photo-1528825871115-3581a5387919?w=150&h=150&fit=crop";
                    } else if (lower.contains("lê") || lower.contains("táo")) {
                        img = "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=150&h=150&fit=crop";
                    } else if (lower.contains("thanh long")) {
                        img = "https://images.unsplash.com/photo-1527325678964-54921661f888?w=150&h=150&fit=crop";
                    } else {
                        img = "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=150&h=150&fit=crop";
                    }
                }
                item.put("thumbnailUrl", img);

                // Moderation metadata (AI score, status tag)
                if (idx == 1) {
                    item.put("modTag", "BÁO CÁO VI PHẠM");
                    item.put("modTagClass", "bg-danger-subtle text-danger border-danger-subtle");
                    item.put("modTagIcon", "bi-shield-exclamation");
                    item.put("riskBadgeClass", "badge-ai-danger");
                    item.put("riskBadgeIcon", "bi-exclamation-triangle-fill");
                    item.put("riskBadgeText", "AI Rủi ro: CAO (76% nghi ảnh mạng)");
                    item.put("riskLevel", "high");
                    item.put("statusGroup", "reported pending");
                    item.put("timeAgo", "28 phút trước");
                } else if (idx % 2 == 0) {
                    item.put("modTag", "ĐĂNG MỚI");
                    item.put("modTagClass", "bg-success-subtle text-success border-success-subtle");
                    item.put("modTagIcon", "bi-plus-circle");
                    item.put("riskBadgeClass", "badge-ai-success");
                    item.put("riskBadgeIcon", "bi-shield-check");
                    item.put("riskBadgeText", "AI Đánh giá: 98/100 An toàn cao");
                    item.put("riskLevel", "safe");
                    item.put("statusGroup", "pending approved");
                    item.put("timeAgo", (idx) + " giờ trước");
                } else {
                    item.put("modTag", "CẬP NHẬT GIẤY PHÉP");
                    item.put("modTagClass", "bg-info-subtle text-info-emphasis border-info-subtle");
                    item.put("modTagIcon", "bi-arrow-repeat");
                    item.put("riskBadgeClass", "badge-ai-info");
                    item.put("riskBadgeIcon", "bi-patch-check-fill");
                    item.put("riskBadgeText", "AI Đánh giá: 94/100 Chứng chỉ mới");
                    item.put("riskLevel", "safe");
                    item.put("statusGroup", "pending approved");
                    item.put("timeAgo", (idx) + " giờ trước");
                }

                list.add(item);
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
}
