package dao;

import com.google.gson.Gson;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.YearMonth;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.dto.admin.AdminDashboardStats;
import util.DBContext;

/**
 * Data Access Object for Admin Dashboard aggregated telemetry.
 */
public class AdminDashboardDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(AdminDashboardDAO.class.getName());
    private static final Gson GSON = new Gson();

    private static Timestamp atStart(LocalDate date) {
        return Timestamp.valueOf(date.atStartOfDay());
    }

    public LocalDate getFirstOrderDate() {
        String sql = "SELECT MIN(created_at) FROM orders";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getTimestamp(1) != null) return rs.getTimestamp(1).toLocalDateTime().toLocalDate();
        } catch (SQLException ex) { LOGGER.log(Level.WARNING, "Failed to load first order date", ex); }
        return null;
    }

    public List<Map<String, Object>> getAvailableShops() {
        List<Map<String, Object>> shops = new ArrayList<>();
        String sql = "SELECT shop_id,shop_name,status FROM shops ORDER BY CASE WHEN status='ACTIVE' THEN 0 ELSE 1 END,shop_name";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> shop = new HashMap<>();
                shop.put("shopId", rs.getLong("shop_id")); shop.put("shopName", rs.getString("shop_name"));
                shop.put("status", rs.getString("status")); shops.add(shop);
            }
        } catch (SQLException ex) { LOGGER.log(Level.WARNING, "Failed to load shops", ex); }
        return shops;
    }

    public Map<String,Object> getShop(long shopId) {
        String sql = "SELECT shop_id,shop_name,status,logo_url FROM shops WHERE shop_id=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String,Object> shop = new HashMap<>();
                    shop.put("shopId", rs.getLong("shop_id")); shop.put("shopName", rs.getString("shop_name"));
                    shop.put("status", rs.getString("status")); shop.put("logoUrl", rs.getString("logo_url")); return shop;
                }
            }
        } catch (SQLException ex) { LOGGER.log(Level.WARNING, "Failed to load shop", ex); }
        return null;
    }

    public AdminDashboardStats getDashboardStats(LocalDate from, LocalDate to, boolean compare) {
        AdminDashboardStats stats = new AdminDashboardStats();
        Connection conn = getConnection();
        if (conn == null) {
            initFallbackStats(stats); stats.setDataAvailable(false); stats.setErrorMessage("Không thể kết nối cơ sở dữ liệu."); return stats;
        }
        try (conn) {
            loadPeriodKpis(conn, stats, from, to);
            loadCurrentOperations(conn, stats);
            if (compare) {
                long days = java.time.temporal.ChronoUnit.DAYS.between(from, to);
                AdminDashboardStats previous = new AdminDashboardStats();
                loadPeriodKpis(conn, previous, from.minusDays(days), from);
                stats.setGmvGrowth(percent(stats.getTotalGmv(), previous.getTotalGmv()));
                stats.setCommissionGrowth(percent(stats.getNetCommission(), previous.getNetCommission()));
                stats.setOrderGrowth(percent(stats.getTotalOrdersCount(), previous.getTotalOrdersCount()));
                stats.setUserGrowth(percent(stats.getTotalUsersCount(), countBefore(conn, "users", from, null)));
                stats.setShopGrowth(percent(stats.getActiveShopsCount(), countBefore(conn, "shops", from, "status='ACTIVE'")));
            }
            loadPlatformTrend(conn, stats, from, to, java.time.temporal.ChronoUnit.DAYS.between(from, to) > 120);
            loadPlatformStatuses(conn, stats, from, to);
            loadTopProductsByPeriod(conn, stats, from, to);
            loadPendingShops(conn, stats);
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Failed period dashboard", ex); stats.setDataAvailable(false);
            stats.setErrorMessage("Không thể tải đầy đủ số liệu dashboard.");
        }
        return stats;
    }

    private void loadPeriodKpis(Connection conn, AdminDashboardStats stats, LocalDate from, LocalDate to) throws SQLException {
        String sql = "SELECT "
                + "(SELECT COALESCE(SUM(shop_total),0) FROM sub_orders WHERE status='DELIVERED' AND created_at>=? AND created_at<?) gmv,"
                + "(SELECT COALESCE(SUM(commission_amount),0) FROM sub_orders WHERE status='DELIVERED' AND created_at>=? AND created_at<?) commission,"
                + "(SELECT COUNT(*) FROM orders WHERE created_at>=? AND created_at<?) orders_count,"
                + "(SELECT COUNT(*) FROM users WHERE created_at<?) users_count,"
                + "(SELECT COUNT(*) FROM shops WHERE status='ACTIVE' AND created_at<?) shops_count";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int i=1; ps.setTimestamp(i++,atStart(from)); ps.setTimestamp(i++,atStart(to));
            ps.setTimestamp(i++,atStart(from)); ps.setTimestamp(i++,atStart(to));
            ps.setTimestamp(i++,atStart(from)); ps.setTimestamp(i++,atStart(to));
            ps.setTimestamp(i++,atStart(to)); ps.setTimestamp(i,atStart(to));
            try (ResultSet rs=ps.executeQuery()) { if(rs.next()) {
                stats.setTotalGmv(rs.getDouble("gmv")); stats.setNetCommission(rs.getDouble("commission"));
                stats.setTotalOrdersCount(rs.getInt("orders_count")); stats.setTotalUsersCount(rs.getInt("users_count"));
                stats.setActiveUsersCount(rs.getInt("users_count")); stats.setActiveShopsCount(rs.getInt("shops_count"));
            }}
        }
    }

    private void loadCurrentOperations(Connection conn, AdminDashboardStats stats) throws SQLException {
        String sql="SELECT (SELECT COUNT(*) FROM shop_requests WHERE status='PENDING') pending_shops,"
                + "(SELECT COUNT(*) FROM products WHERE is_active=0) pending_products,"
                + "(SELECT COUNT(*) FROM disputes WHERE status IN ('OPEN','MEDIATING')) disputes,"
                + "(SELECT COUNT(*) FROM orders WHERE order_status IN ('PENDING','CONFIRMED','PROCESSING','SHIPPING')) processing_orders";
        try(PreparedStatement ps=conn.prepareStatement(sql);ResultSet rs=ps.executeQuery()){if(rs.next()){
            stats.setPendingKycCount(rs.getInt("pending_shops"));stats.setFlaggedProductsCount(rs.getInt("pending_products"));
            stats.setOpenDisputesCount(rs.getInt("disputes"));stats.setProcessingOrdersCount(rs.getInt("processing_orders"));}}
    }

    private int countBefore(Connection conn,String table,LocalDate date,String extra)throws SQLException{
        String sql="SELECT COUNT(*) FROM "+table+" WHERE created_at<?"+(extra==null?"":" AND "+extra);
        try(PreparedStatement ps=conn.prepareStatement(sql)){ps.setTimestamp(1,atStart(date));try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getInt(1):0;}}
    }
    private double percent(double current,double previous){return previous<=0?(current>0?100:0):Math.round((current-previous)*1000/previous)/10.0;}

    private void loadPlatformTrend(Connection conn,AdminDashboardStats stats,LocalDate from,LocalDate to,boolean monthly)throws SQLException{
        String key=monthly?"CONVERT(VARCHAR(7),created_at,120)":"CONVERT(VARCHAR(10),created_at,120)";
        String sql="SELECT "+key+" k,COALESCE(SUM(shop_total),0) gmv,COALESCE(SUM(commission_amount),0) commission FROM sub_orders WHERE status='DELIVERED' AND created_at>=? AND created_at<? GROUP BY "+key;
        Map<String,double[]> rows=new HashMap<>();try(PreparedStatement ps=conn.prepareStatement(sql)){ps.setTimestamp(1,atStart(from));ps.setTimestamp(2,atStart(to));try(ResultSet rs=ps.executeQuery()){while(rs.next())rows.put(rs.getString("k"),new double[]{rs.getDouble("gmv"),rs.getDouble("commission")});}}
        List<String> labels=new ArrayList<>();List<Double> gmv=new ArrayList<>();List<Double> comm=new ArrayList<>();LocalDate last=to.minusDays(1);
        if(monthly){for(YearMonth m=YearMonth.from(from),end=YearMonth.from(last);!m.isAfter(end);m=m.plusMonths(1)){String k=String.format("%04d-%02d",m.getYear(),m.getMonthValue());double[]v=rows.getOrDefault(k,new double[]{0,0});labels.add(String.format("%02d/%04d",m.getMonthValue(),m.getYear()));gmv.add(v[0]);comm.add(v[1]);}}
        else{for(LocalDate d=from;!d.isAfter(last);d=d.plusDays(1)){double[]v=rows.getOrDefault(d.toString(),new double[]{0,0});labels.add(String.format("%02d/%02d",d.getDayOfMonth(),d.getMonthValue()));gmv.add(v[0]);comm.add(v[1]);}}
        stats.setChartLabelsJson(GSON.toJson(labels));stats.setChartGmvJson(GSON.toJson(gmv));stats.setChartCommissionJson(GSON.toJson(comm));
    }

    private void loadPlatformStatuses(Connection conn,AdminDashboardStats stats,LocalDate from,LocalDate to)throws SQLException{
        Map<String,Integer> counts=new HashMap<>();String sql="SELECT order_status,COUNT(*) c FROM orders WHERE created_at>=? AND created_at<? GROUP BY order_status";
        try(PreparedStatement ps=conn.prepareStatement(sql)){ps.setTimestamp(1,atStart(from));ps.setTimestamp(2,atStart(to));try(ResultSet rs=ps.executeQuery()){while(rs.next())counts.put(rs.getString(1),rs.getInt(2));}}
        String[][]defs={{"PENDING","Chờ xác nhận"},{"CONFIRMED","Đã xác nhận"},{"PROCESSING","Đang xử lý"},{"SHIPPING","Đang giao"},{"COMPLETED","Hoàn thành"},{"CANCELLED","Đã hủy"}};List<String>labels=new ArrayList<>();List<Integer>values=new ArrayList<>();
        for(String[]d:defs){int c=counts.getOrDefault(d[0],0);if(c>0){labels.add(d[1]);values.add(c);}}stats.setStatusLabelsJson(GSON.toJson(labels));stats.setStatusDataJson(GSON.toJson(values));
    }

    private void loadTopProductsByPeriod(Connection conn,AdminDashboardStats stats,LocalDate from,LocalDate to)throws SQLException{
        String sql="SELECT TOP 5 oi.product_name_snapshot product_name,s.shop_name,SUM(oi.quantity) total_sold,SUM(oi.total_price) revenue,MAX(oi.unit) unit FROM order_items oi JOIN sub_orders so ON so.sub_order_id=oi.sub_order_id JOIN shops s ON s.shop_id=so.shop_id WHERE so.status='DELIVERED' AND so.created_at>=? AND so.created_at<? GROUP BY oi.product_name_snapshot,s.shop_name ORDER BY revenue DESC,total_sold DESC";
        List<Map<String,Object>>list=new ArrayList<>();DecimalFormat money=new DecimalFormat("#,### ₫");try(PreparedStatement ps=conn.prepareStatement(sql)){ps.setTimestamp(1,atStart(from));ps.setTimestamp(2,atStart(to));try(ResultSet rs=ps.executeQuery()){while(rs.next()){Map<String,Object>r=new HashMap<>();r.put("productName",rs.getString("product_name"));r.put("shopName",rs.getString("shop_name"));r.put("soldFormatted",rs.getInt("total_sold")+" "+rs.getString("unit"));r.put("revenueFormatted",money.format(rs.getDouble("revenue")));list.add(r);}}}stats.setTopProducts(list);
    }

    /**
     * Fetch complete real-time dashboard statistics from SQL Server.
     */
    public AdminDashboardStats getDashboardStats() {
        AdminDashboardStats stats = new AdminDashboardStats();

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.warning("Database connection failed in AdminDashboardDAO, returning default fallback stats");
            initFallbackStats(stats);
            return stats;
        }

        try (conn) {
            // 1. Core KPIs
            loadCoreKpis(conn, stats);

            // 2. Next Payout Settlements
            loadPayoutSummary(conn, stats);

            // 3. Pending KYC Shops
            loadPendingShops(conn, stats);

            // 4. Escalated Disputes
            loadActiveDisputes(conn, stats);

            // 5. Category Distribution & Chart
            loadCategoryShare(conn, stats);

            // 7. Top Vendors
            loadTopShops(conn, stats);

            // 8. Top Selling Products
            loadTopProducts(conn, stats);

        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error querying admin dashboard statistics: " + ex.getMessage(), ex);
            initFallbackStats(stats);
        }

        return stats;
    }

    private void loadCoreKpis(Connection conn, AdminDashboardStats stats) {
        String sql = "SELECT "
                   + "    (SELECT COALESCE(SUM(total_sales_amount), 0) FROM shops) AS TotalGmv, "
                   + "    (SELECT COALESCE(SUM(total_sales_amount * commission_rate / 100.0), 0) FROM shops) AS NetCommission, "
                   + "    (SELECT COALESCE(SUM(total_orders_count), 0) FROM shops) AS TotalOrdersCount, "
                   + "    (SELECT COUNT(*) FROM shops WHERE status = 'ACTIVE') AS ActiveShops, "
                   + "    (SELECT COUNT(*) FROM shop_requests WHERE status = 'PENDING') AS PendingKyc, "
                   + "    (SELECT COUNT(DISTINCT u.user_id) FROM users u "
                   + "     JOIN user_roles ur ON u.user_id = ur.user_id "
                   + "     JOIN roles r ON ur.role_id = r.role_id WHERE r.role_name = 'CUSTOMER') AS TotalBuyers, "
                   + "    (SELECT COUNT(*) FROM users) AS TotalUsers, "
                   + "    (SELECT COUNT(*) FROM users WHERE status = 'ACTIVE') AS ActiveUsers, "
                   + "    (SELECT COUNT(*) FROM disputes WHERE status IN ('OPEN', 'MEDIATING')) AS OpenDisputes, "
                   + "    (SELECT COALESCE(SUM(claim_amount), 0) FROM disputes WHERE status IN ('OPEN', 'MEDIATING')) AS TotalEscrow, "
                   + "    (SELECT COUNT(*) FROM products WHERE is_active = 0) AS FlaggedProducts, "
                   + "    (SELECT COUNT(*) FROM orders) AS TotalOrdersInDb, "
                   + "    (SELECT COUNT(*) FROM orders WHERE order_status = 'COMPLETED') AS CompletedOrders, "
                   + "    (SELECT COUNT(*) FROM orders WHERE order_status = 'PROCESSING') AS ProcessingOrders, "
                   + "    (SELECT COUNT(*) FROM products) AS TotalProducts, "
                   + "    (SELECT COUNT(*) FROM products WHERE certification IS NOT NULL AND certification != '') AS CertifiedProducts";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                stats.setTotalGmv(rs.getDouble("TotalGmv"));
                stats.setNetCommission(rs.getDouble("NetCommission"));
                stats.setTotalOrdersCount(rs.getInt("TotalOrdersCount"));
                stats.setActiveShopsCount(rs.getInt("ActiveShops"));
                stats.setPendingKycCount(rs.getInt("PendingKyc"));
                stats.setTotalBuyersCount(rs.getInt("TotalBuyers"));

                int totalUsers = rs.getInt("TotalUsers");
                int activeUsers = rs.getInt("ActiveUsers");
                stats.setTotalUsersCount(totalUsers);
                stats.setActiveUsersCount(activeUsers);
                double userRate = totalUsers > 0 ? (activeUsers * 100.0 / totalUsers) : 100.0;
                stats.setActiveUserRate(Math.round(userRate * 10.0) / 10.0);

                stats.setOpenDisputesCount(rs.getInt("OpenDisputes"));
                stats.setTotalEscrowAmount(rs.getDouble("TotalEscrow"));
                stats.setFlaggedProductsCount(rs.getInt("FlaggedProducts"));

                int totalOrdersInDb = rs.getInt("TotalOrdersInDb");
                int completedOrders = rs.getInt("CompletedOrders");
                int processingOrders = rs.getInt("ProcessingOrders");
                stats.setCompletedOrdersCount(completedOrders);
                stats.setProcessingOrdersCount(processingOrders);
                double compRate = totalOrdersInDb > 0 ? (completedOrders * 100.0 / totalOrdersInDb) : 100.0;
                stats.setOrderCompletionRate(Math.round(compRate * 10.0) / 10.0);

                int totalProds = rs.getInt("TotalProducts");
                int certifiedProds = rs.getInt("CertifiedProducts");
                double certRate = totalProds > 0 ? (certifiedProds * 100.0 / totalProds) : 100.0;
                stats.setCertifiedProductRate(Math.round(certRate * 10.0) / 10.0);
                stats.setTotalProductsCount(totalProds);
                stats.setCertifiedProductsCount(certifiedProds);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load core KPIs: " + ex.getMessage());
        }

        // Query growth rates between payout settlement cycles
        String growthSql = "WITH PayoutCycles AS ("
                         + "    SELECT cycle_name, MIN(period_start) as start_date, "
                         + "           SUM(gross_sales) as total_gross, "
                         + "           SUM(commission_withheld) as total_comm, "
                         + "           SUM(total_orders_count) as total_orders, "
                         + "           ROW_NUMBER() OVER (ORDER BY MIN(period_start) DESC) as rn "
                         + "    FROM vendor_payouts "
                         + "    GROUP BY cycle_name"
                         + ") "
                         + "SELECT curr.total_gross as curr_gmv, prev.total_gross as prev_gmv, "
                         + "       curr.total_comm as curr_comm, prev.total_comm as prev_comm, "
                         + "       curr.total_orders as curr_orders, prev.total_orders as prev_orders "
                         + "FROM PayoutCycles curr "
                         + "LEFT JOIN PayoutCycles prev ON prev.rn = curr.rn + 1 "
                         + "WHERE curr.rn = 1";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(growthSql)) {
            if (rs.next()) {
                double currGmv = rs.getDouble("curr_gmv");
                double prevGmv = rs.getDouble("prev_gmv");
                double currComm = rs.getDouble("curr_comm");
                double prevComm = rs.getDouble("prev_comm");
                int currOrders = rs.getInt("curr_orders");
                int prevOrders = rs.getInt("prev_orders");

                double gmvGrowth = prevGmv > 0 ? ((currGmv - prevGmv) / prevGmv * 100.0) : 0.0;
                double commGrowth = prevComm > 0 ? ((currComm - prevComm) / prevComm * 100.0) : 0.0;
                double ordGrowth = prevOrders > 0 ? ((currOrders - prevOrders) / (double) prevOrders * 100.0) : 0.0;

                stats.setGmvGrowth(Math.round(gmvGrowth * 10.0) / 10.0);
                stats.setCommissionGrowth(Math.round(commGrowth * 10.0) / 10.0);
                stats.setOrderGrowth(Math.round(ordGrowth * 10.0) / 10.0);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load growth metrics: " + ex.getMessage());
        }
    }

    private void loadPayoutSummary(Connection conn, AdminDashboardStats stats) {
        String sql = "SELECT COUNT(*) as vendor_count, COALESCE(SUM(net_payout), 0) as total_payout, "
                   + "       MAX(period_end) as next_period_end "
                   + "FROM vendor_payouts WHERE status = 'PROCESSING'";

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                int vendors = rs.getInt("vendor_count");
                double payout = rs.getDouble("total_payout");
                stats.setNextPayoutVendorsCount(vendors);
                stats.setNextPayoutVolume(payout);
                Timestamp periodEnd = rs.getTimestamp("next_period_end");
                if (periodEnd != null) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                    stats.setNextPayoutDate("Hạn: " + sdf.format(periodEnd));
                } else {
                    stats.setNextPayoutDate("Chưa có kỳ mới");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load payout summary: " + ex.getMessage());
            stats.setNextPayoutVendorsCount(0);
            stats.setNextPayoutVolume(0.0);
            stats.setNextPayoutDate("Chưa có kỳ mới");
        }
    }

   private void loadPendingShops(Connection conn, AdminDashboardStats stats) {
    // Chỉ chọn các cột thực tế có trong cơ sở dữ liệu của bạn
    String sql = "SELECT TOP 5 request_id, shop_name, business_type, province, created_at "
               + "FROM shop_requests WHERE status = 'PENDING' ORDER BY created_at DESC";

    List<Map<String, Object>> list = new ArrayList<>();
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    try (Statement st = conn.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
        while (rs.next()) {
            Map<String, Object> map = new HashMap<>();
            long id = rs.getLong("request_id");
            String name = rs.getString("shop_name");
            String type = rs.getString("business_type");
            String province = rs.getString("province");
            Timestamp createdAt = rs.getTimestamp("created_at");

            map.put("requestId", id);
            map.put("shopName", name);
            map.put("businessType", type != null ? type : "Nhà vườn");
            map.put("province", province != null ? province : "Toàn quốc");
            map.put("createdAtFormatted", createdAt != null ? sdf.format(createdAt) : "Hôm nay");
            map.put("avatarAbbr", getAbbr(name));
            
            list.add(map);
        }
    } catch (SQLException ex) {
        LOGGER.log(Level.WARNING, "Failed to load pending shop requests: " + ex.getMessage());
    }

    stats.setPendingShops(list);
}
    private void loadActiveDisputes(Connection conn, AdminDashboardStats stats) {
        String sql = "SELECT TOP 5 d.dispute_id, d.dispute_code, d.reason_category, d.complaint_text, "
                   + "       d.claim_amount, d.status, u.full_name AS customer_name, s.shop_name, d.created_at "
                   + "FROM disputes d "
                   + "JOIN users u ON d.customer_id = u.user_id "
                   + "JOIN shops s ON d.shop_id = s.shop_id "
                   + "WHERE d.status IN ('OPEN', 'MEDIATING') "
                   + "ORDER BY d.created_at DESC";

        List<Map<String, Object>> list = new ArrayList<>();
        DecimalFormat df = new DecimalFormat("#,### ₫");

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("disputeId", rs.getLong("dispute_id"));
                map.put("disputeCode", rs.getString("dispute_code"));
                map.put("reasonCategory", rs.getString("reason_category"));
                map.put("complaintText", rs.getString("complaint_text"));
                map.put("claimAmountFormatted", df.format(rs.getDouble("claim_amount")));
                map.put("status", rs.getString("status"));
                map.put("customerName", rs.getString("customer_name"));
                map.put("shopName", rs.getString("shop_name"));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load active disputes: " + ex.getMessage());
        }

        stats.setActiveDisputes(list);
    }

    private void loadCategoryShare(Connection conn, AdminDashboardStats stats) {
        String sql = "SELECT COALESCE(pcat.category_name, c.category_name) as group_name, "
                   + "       COUNT(p.product_id) as product_count, "
                   + "       COALESCE(SUM(pv.price * pv.stock_quantity), 0) as inventory_volume "
                   + "FROM products p "
                   + "JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN categories pcat ON c.parent_id = pcat.category_id "
                   + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id "
                   + "GROUP BY COALESCE(pcat.category_name, c.category_name) "
                   + "ORDER BY inventory_volume DESC, product_count DESC";

        List<String> labels = new ArrayList<>();
        List<Double> volumes = new ArrayList<>();
        List<Integer> counts = new ArrayList<>();
        List<Map<String, Object>> catList = new ArrayList<>();
        double grandTotalVolume = 0;
        int grandTotalCount = 0;

        String[] colors = {"#15803d", "#22c55e", "#ea580c", "#fb923c", "#3b82f6", "#06b6d4"};

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                String catName = rs.getString("group_name");
                double vol = rs.getDouble("inventory_volume");
                int cnt = rs.getInt("product_count");
                if (vol > 0 || cnt > 0) {
                    labels.add(catName);
                    volumes.add(vol);
                    counts.add(cnt);
                    grandTotalVolume += vol;
                    grandTotalCount += cnt;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load category share: " + ex.getMessage());
        }

        List<Integer> percentages = new ArrayList<>();
        boolean useVolume = grandTotalVolume > 0;
        double baseTotal = useVolume ? grandTotalVolume : (grandTotalCount > 0 ? grandTotalCount : 1.0);

        for (int i = 0; i < labels.size(); i++) {
            double metric = useVolume ? volumes.get(i) : counts.get(i);
            int pct = (int) Math.round((metric / baseTotal) * 100.0);
            percentages.add(pct);

            Map<String, Object> cMap = new HashMap<>();
            cMap.put("name", labels.get(i));
            cMap.put("percent", pct);
            cMap.put("volumeFormatted", useVolume ? AdminDashboardStats.formatCurrency(volumes.get(i)) : (counts.get(i) + " sản phẩm"));
            cMap.put("color", colors[i % colors.length]);
            catList.add(cMap);
        }

        stats.setCategoryLabelsJson(GSON.toJson(labels));
        stats.setCategoryDataJson(GSON.toJson(percentages));
        stats.setCategoryStats(catList);
    }

    private void loadRevenueTrajectory(Connection conn, AdminDashboardStats stats) {
        String sql = "SELECT FORMAT(created_at, 'dd/MM') as day_label, "
                   + "       COALESCE(SUM(shop_total), 0) / 1000000.0 as gmv_m, "
                   + "       COALESCE(SUM(commission_amount), 0) / 1000000.0 as comm_m "
                   + "FROM sub_orders "
                   + "GROUP BY FORMAT(created_at, 'dd/MM'), CAST(created_at AS DATE) "
                   + "ORDER BY CAST(created_at AS DATE) ASC";

        List<String> days = new ArrayList<>();
        List<Double> gmv = new ArrayList<>();
        List<Double> comm = new ArrayList<>();

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                days.add(rs.getString("day_label"));
                gmv.add(Math.round(rs.getDouble("gmv_m") * 100.0) / 100.0);
                comm.add(Math.round(rs.getDouble("comm_m") * 100.0) / 100.0);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load revenue trajectory: " + ex.getMessage());
        }

        if (days.isEmpty()) {
            days.add("Hôm nay");
            gmv.add(0.0);
            comm.add(0.0);
        }

        stats.setChartLabelsJson(GSON.toJson(days));
        stats.setChartGmvJson(GSON.toJson(gmv));
        stats.setChartCommissionJson(GSON.toJson(comm));
    }

    private void initFallbackStats(AdminDashboardStats stats) {
        stats.setTotalGmv(0.0);
        stats.setNetCommission(0.0);
        stats.setTotalOrdersCount(0);
        stats.setActiveShopsCount(0);
        stats.setPendingKycCount(0);
        stats.setTotalBuyersCount(0);
        stats.setActiveUsersCount(0);
        stats.setOpenDisputesCount(0);
        stats.setTotalEscrowAmount(0.0);
        stats.setFlaggedProductsCount(0);
        stats.setNextPayoutVolume(0.0);
        stats.setNextPayoutVendorsCount(0);
        stats.setNextPayoutDate("Chưa có kỳ mới");
        stats.setGmvGrowth(0.0);
        stats.setCommissionGrowth(0.0);
        stats.setOrderGrowth(0.0);
        stats.setOrderCompletionRate(100.0);
        stats.setTotalUsersCount(0);
        stats.setActiveUserRate(100.0);
        stats.setCertifiedProductRate(100.0);
        stats.setPendingShops(Collections.emptyList());
        stats.setActiveDisputes(Collections.emptyList());
        stats.setTopShops(Collections.emptyList());
        stats.setTopProducts(Collections.emptyList());
        stats.setChartLabelsJson("[]");
        stats.setChartGmvJson("[]");
        stats.setChartCommissionJson("[]");
        stats.setCategoryLabelsJson("[]");
        stats.setCategoryDataJson("[]");
        stats.setCategoryStats(Collections.emptyList());
    }

    private void loadTopShops(Connection conn, AdminDashboardStats stats) {
        String sql = "SELECT TOP 5 s.shop_id, s.shop_name, s.business_type, u.full_name as owner_name, "
                   + "       s.total_orders_count, s.total_sales_amount, s.rating, s.status "
                   + "FROM shops s "
                   + "JOIN users u ON s.owner_id = u.user_id "
                   + "WHERE s.status = 'ACTIVE' "
                   + "ORDER BY s.total_sales_amount DESC";

        List<Map<String, Object>> list = new ArrayList<>();
        DecimalFormat df = new DecimalFormat("#,### ₫");

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                String name = rs.getString("shop_name");
                map.put("shopName", name);
                map.put("ownerName", rs.getString("owner_name"));
                map.put("ordersCount", rs.getInt("total_orders_count"));
                map.put("salesFormatted", df.format(rs.getDouble("total_sales_amount")));
                map.put("rating", String.format("%.2f ★", rs.getDouble("rating")));
                map.put("avatarTag", getAbbr(name));
                String status = rs.getString("status");
                map.put("status", status);
                map.put("statusLabel", "ACTIVE".equalsIgnoreCase(status) ? "Hoạt động" : ("SUSPENDED".equalsIgnoreCase(status) ? "Tạm khóa" : status));
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load top shops: " + ex.getMessage());
        }
        stats.setTopShops(list);
    }

    private void loadTopProducts(Connection conn, AdminDashboardStats stats) {
        String sql = "SELECT TOP 5 p.product_id, p.name AS product_name, s.shop_name, c.category_name, "
                   + "       COALESCE(SUM(oi.quantity), 0) AS total_sold, "
                   + "       COALESCE(MAX(oi.unit), MAX(pv.unit), 'kg') AS unit "
                   + "FROM products p "
                   + "JOIN shops s ON p.shop_id = s.shop_id "
                   + "JOIN categories c ON p.category_id = c.category_id "
                   + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id "
                   + "LEFT JOIN order_items oi ON pv.variant_id = oi.variant_id "
                   + "GROUP BY p.product_id, p.name, s.shop_name, c.category_name "
                   + "ORDER BY total_sold DESC, p.product_id ASC";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("productName", rs.getString("product_name"));
                map.put("shopName", rs.getString("shop_name"));
                map.put("categoryName", rs.getString("category_name"));
                int sold = rs.getInt("total_sold");
                String unit = rs.getString("unit") != null ? rs.getString("unit") : "kg";
                map.put("soldFormatted", sold + " " + unit);
                map.put("statusLabel", sold > 0 ? "Bán chạy" : "Đang mở bán");
                list.add(map);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.WARNING, "Failed to load top products: " + ex.getMessage());
        }
        stats.setTopProducts(list);
    }

    private String getAbbr(String name) {
        if (name == null || name.trim().isEmpty()) return "FF";
        String[] words = name.trim().split("\\s+");
        if (words.length == 1) return words[0].substring(0, Math.min(2, words[0].length())).toUpperCase();
        return ("" + words[0].charAt(0) + words[1].charAt(0)).toUpperCase();
    }
}
