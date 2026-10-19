package controller.shop;

import com.google.gson.Gson;
import dao.ShopDashboardDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

/**
 * Trang "Tổng quan Shop": doanh thu, số đơn, sản phẩm bán chạy, đánh giá, thống kê theo kỳ.
 * URL: /shop/dashboard?range=7|30|90|365|all
 */
@WebServlet(name = "ShopDashboardServlet", urlPatterns = {"/shop/dashboard"})
public class ShopDashboardServlet extends HttpServlet {

    private final ShopDashboardDAO dashboardDAO = new ShopDashboardDAO();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1. shopId
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            }
        }
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/register-shop");
            return;
        }

        // 2. Khoảng thời gian lọc: [from, to) với to = ngày mai
        String range = request.getParameter("range");
        if (!"7".equals(range) && !"90".equals(range) && !"365".equals(range) && !"all".equals(range)) {
            range = "30";
        }
        LocalDate today = LocalDate.now();
        LocalDate to = today.plusDays(1);
        LocalDate from;
        boolean hasCompare = true;
        String rangeLabel;
        switch (range) {
            case "7":   from = today.minusDays(6);   rangeLabel = "7 ngày qua";   break;
            case "90":  from = today.minusDays(89);  rangeLabel = "90 ngày qua";  break;
            case "365": from = today.minusDays(364); rangeLabel = "12 tháng qua"; break;
            case "all": {
                LocalDate first = dashboardDAO.getFirstOrderDate(shopId);
                from = (first != null) ? first : today.minusDays(29);
                hasCompare = false;
                rangeLabel = "Toàn thời gian";
                break;
            }
            default:    from = today.minusDays(29);  rangeLabel = "30 ngày qua";  break;
        }

        try {
            // 3. KPI kỳ hiện tại + kỳ trước (để tính % tăng giảm)
            Map<String, Object> cur = dashboardDAO.getSummary(shopId, from, to);
            double revenue = (Double) cur.get("revenue");
            double commission = (Double) cur.get("commission");
            int orders = (Integer) cur.get("orders");
            int delivered = (Integer) cur.get("delivered");

            if (hasCompare) {
                long days = java.time.temporal.ChronoUnit.DAYS.between(from, to);
                Map<String, Object> prev = dashboardDAO.getSummary(shopId, from.minusDays(days), from);
                request.setAttribute("revenueChange", pct(revenue, (Double) prev.get("revenue")));
                request.setAttribute("ordersChange", pct(orders, (Integer) prev.get("orders")));
                int curItems = (Integer) cur.get("itemsSold");
                request.setAttribute("itemsChange", pct(curItems, (Integer) prev.get("itemsSold")));
                double aovPrev = ((Integer) prev.get("delivered")) > 0
                        ? (Double) prev.get("revenue") / (Integer) prev.get("delivered") : 0;
                double aovCur = delivered > 0 ? revenue / delivered : 0;
                request.setAttribute("aovChange", pct(aovCur, aovPrev));
            }
            request.setAttribute("hasCompare", hasCompare);
            request.setAttribute("revenue", revenue);
            request.setAttribute("netRevenue", revenue - commission);
            request.setAttribute("commission", commission);
            request.setAttribute("orders", orders);
            request.setAttribute("delivered", delivered);
            request.setAttribute("cancelled", cur.get("cancelled"));
            request.setAttribute("itemsSold", cur.get("itemsSold"));
            request.setAttribute("avgOrderValue", delivered > 0 ? revenue / delivered : 0.0);
            int allOrders = orders + (Integer) cur.get("cancelled");
            request.setAttribute("cancelRate", allOrders > 0 ? (Integer) cur.get("cancelled") * 100.0 / allOrders : 0.0);

            // 4. Biểu đồ doanh thu / đơn hàng
            boolean monthly = "365".equals(range) || "all".equals(range);
            Map<String, List<?>> trend = dashboardDAO.getTrend(shopId, from, to, monthly);
            request.setAttribute("trendLabelsJson", gson.toJson(trend.get("labels")));
            request.setAttribute("trendRevenueJson", gson.toJson(trend.get("revenue")));
            request.setAttribute("trendOrdersJson", gson.toJson(trend.get("orders")));

            // 5. Cơ cấu trạng thái đơn
            Map<String, Integer> statusMap = dashboardDAO.getStatusBreakdown(shopId, from, to);
            Map<String, Integer> statusView = new LinkedHashMap<>();
            String[][] statusDefs = {
                {"NEW", "Mới"}, {"CONFIRMED", "Đã xác nhận"}, {"PACKING", "Đang đóng gói"},
                {"SHIPPING", "Đang giao"}, {"DELIVERED", "Đã giao"}, {"CANCELLED", "Đã hủy"}, {"REFUNDED", "Hoàn tiền"}
            };
            List<String> sLabels = new java.util.ArrayList<>();
            List<Integer> sValues = new java.util.ArrayList<>();
            for (String[] d : statusDefs) {
                Integer c = statusMap.get(d[0]);
                if (c != null && c > 0) {
                    sLabels.add(d[1]);
                    sValues.add(c);
                    statusView.put(d[1], c);
                }
            }
            request.setAttribute("statusLabelsJson", gson.toJson(sLabels));
            request.setAttribute("statusValuesJson", gson.toJson(sValues));
            request.setAttribute("hasStatusData", !sValues.isEmpty());

            // 6. Danh sách / thống kê khác
            request.setAttribute("bestSellers", dashboardDAO.getBestSellers(shopId, from, to, 5));
            request.setAttribute("recentOrders", dashboardDAO.getRecentOrders(shopId, 6));
            request.setAttribute("ratingStats", dashboardDAO.getRatingStats(shopId, from, to));
            request.setAttribute("latestReviews", dashboardDAO.getLatestReviews(shopId, 3));
            request.setAttribute("lowStockItems", dashboardDAO.getLowStockItems(shopId, 5));
            request.setAttribute("latestPayout", dashboardDAO.getLatestPayout(shopId));

            request.setAttribute("pendingOrders", dashboardDAO.countPendingOrders(shopId));
            request.setAttribute("shippingOrders", dashboardDAO.countShippingOrders(shopId));
            request.setAttribute("openDisputes", dashboardDAO.countOpenDisputes(shopId));
            request.setAttribute("lowStockCount", dashboardDAO.countLowStock(shopId));
            request.setAttribute("unrepliedReviews", dashboardDAO.countUnrepliedReviews(shopId));
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Không tải được số liệu tổng quan: " + e.getMessage());
        }

        request.setAttribute("range", range);
        request.setAttribute("rangeLabel", rangeLabel);
        request.setAttribute("fromDate", java.sql.Date.valueOf(from));
        request.setAttribute("toDate", java.sql.Date.valueOf(today));
        request.getRequestDispatcher("/views/shop/shop-dashboard.jsp").forward(request, response);
    }

    /** % thay đổi so với kỳ trước; null nếu kỳ trước = 0 (không so sánh được). */
    private Double pct(double current, double previous) {
        if (previous <= 0) {
            return current > 0 ? null : 0.0;
        }
        return (current - previous) * 100.0 / previous;
    }
}
