package service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/** Reads the shop dashboard aggregates. */
public interface IShopDashboardService {
    LocalDate getFirstOrderDate(long shopId);
    Map<String, Object> getSummary(long shopId, LocalDate from, LocalDate to);
    Map<String, List<?>> getTrend(long shopId, LocalDate from, LocalDate to, boolean monthly);
    Map<String, Integer> getStatusBreakdown(long shopId, LocalDate from, LocalDate to);
    List<Map<String, Object>> getBestSellers(long shopId, LocalDate from, LocalDate to, int limit);
    List<Map<String, Object>> getRecentOrders(long shopId, int limit);
    int countPendingOrders(long shopId);
    int countShippingOrders(long shopId);
    int countOpenDisputes(long shopId);
    int countLowStock(long shopId);
    int countUnrepliedReviews(long shopId);
    List<Map<String, Object>> getLowStockItems(long shopId, int limit);
    Map<String, Object> getRatingStats(long shopId, LocalDate from, LocalDate to);
    List<Map<String, Object>> getLatestReviews(long shopId, int limit);
    Map<String, Object> getLatestPayout(long shopId);
}
