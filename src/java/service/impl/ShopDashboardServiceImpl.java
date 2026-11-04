package service.impl;

import dao.ShopDashboardDAO;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import service.IShopDashboardService;

/** DAO access for shop dashboard aggregates. */
public class ShopDashboardServiceImpl implements IShopDashboardService {
    private final ShopDashboardDAO dashboardDAO = new ShopDashboardDAO();

    @Override
    public LocalDate getFirstOrderDate(long shopId) { return dashboardDAO.getFirstOrderDate(shopId); }
    @Override
    public Map<String, Object> getSummary(long shopId, LocalDate from, LocalDate to) { return dashboardDAO.getSummary(shopId, from, to); }
    @Override
    public Map<String, List<?>> getTrend(long shopId, LocalDate from, LocalDate to, boolean monthly) { return dashboardDAO.getTrend(shopId, from, to, monthly); }
    @Override
    public Map<String, Integer> getStatusBreakdown(long shopId, LocalDate from, LocalDate to) { return dashboardDAO.getStatusBreakdown(shopId, from, to); }
    @Override
    public List<Map<String, Object>> getBestSellers(long shopId, LocalDate from, LocalDate to, int limit) { return dashboardDAO.getBestSellers(shopId, from, to, limit); }
    @Override
    public List<Map<String, Object>> getRecentOrders(long shopId, int limit) { return dashboardDAO.getRecentOrders(shopId, limit); }
    @Override
    public int countPendingOrders(long shopId) { return dashboardDAO.countPendingOrders(shopId); }
    @Override
    public int countShippingOrders(long shopId) { return dashboardDAO.countShippingOrders(shopId); }
    @Override
    public int countOpenDisputes(long shopId) { return dashboardDAO.countOpenDisputes(shopId); }
    @Override
    public int countLowStock(long shopId) { return dashboardDAO.countLowStock(shopId); }
    @Override
    public int countUnrepliedReviews(long shopId) { return dashboardDAO.countUnrepliedReviews(shopId); }
    @Override
    public List<Map<String, Object>> getLowStockItems(long shopId, int limit) { return dashboardDAO.getLowStockItems(shopId, limit); }
    @Override
    public Map<String, Object> getRatingStats(long shopId, LocalDate from, LocalDate to) { return dashboardDAO.getRatingStats(shopId, from, to); }
    @Override
    public List<Map<String, Object>> getLatestReviews(long shopId, int limit) { return dashboardDAO.getLatestReviews(shopId, limit); }
    @Override
    public Map<String, Object> getLatestPayout(long shopId) { return dashboardDAO.getLatestPayout(shopId); }
}
