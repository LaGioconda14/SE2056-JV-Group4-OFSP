package model;

import java.io.Serializable;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Data Transfer Object containing all aggregated real-time statistics
 * for the Multi-Vendor Platform Admin Dashboard.
 */
public class AdminDashboardStats implements Serializable {
    private static final long serialVersionUID = 1L;

    private double totalGmv;
    private double netCommission;
    private int activeShopsCount;
    private int pendingKycCount;
    private int totalBuyersCount;
    private int openDisputesCount;
    private int totalOrdersCount;
    private int activeUsersCount;

    // Next Payout Cycle
    private double nextPayoutVolume;
    private int nextPayoutVendorsCount;
    private String nextPayoutDate;

    // Charts Json
    private String chartLabelsJson;
    private String chartGmvJson;
    private String chartCommissionJson;
    private String categoryLabelsJson;
    private String categoryDataJson;

    // Category detail breakdown
    private List<Map<String, Object>> categoryStats = new ArrayList<>();

    // Tables
    private List<Map<String, Object>> pendingShops = new ArrayList<>();
    private List<Map<String, Object>> activeDisputes = new ArrayList<>();
    private List<Map<String, Object>> topShops = new ArrayList<>();
    private List<Map<String, Object>> topProducts = new ArrayList<>();

    public List<Map<String, Object>> getTopShops() {
        return topShops;
    }

    public void setTopShops(List<Map<String, Object>> topShops) {
        this.topShops = topShops;
    }

    public List<Map<String, Object>> getTopProducts() {
        return topProducts;
    }

    public void setTopProducts(List<Map<String, Object>> topProducts) {
        this.topProducts = topProducts;
    }

    public AdminDashboardStats() {
    }

    public double getTotalGmv() {
        return totalGmv;
    }

    public void setTotalGmv(double totalGmv) {
        this.totalGmv = totalGmv;
    }

    public String getTotalGmvFormatted() {
        return formatCurrency(totalGmv);
    }

    public String getTotalGmvFullFormatted() {
        DecimalFormat df = new DecimalFormat("#,###");
        return "₫" + df.format(totalGmv);
    }

    public double getNetCommission() {
        return netCommission;
    }

    public void setNetCommission(double netCommission) {
        this.netCommission = netCommission;
    }

    public String getNetCommissionFormatted() {
        return formatCurrency(netCommission);
    }

    public String getNetCommissionFullFormatted() {
        DecimalFormat df = new DecimalFormat("#,###");
        return "₫" + df.format(netCommission);
    }

    public double getAvgTakeRate() {
        if (totalGmv <= 0) return 7.8;
        return Math.round((netCommission / totalGmv) * 1000.0) / 10.0;
    }

    public int getActiveShopsCount() {
        return activeShopsCount;
    }

    public void setActiveShopsCount(int activeShopsCount) {
        this.activeShopsCount = activeShopsCount;
    }

    public int getPendingKycCount() {
        return pendingKycCount;
    }

    public void setPendingKycCount(int pendingKycCount) {
        this.pendingKycCount = pendingKycCount;
    }

    public int getTotalBuyersCount() {
        return totalBuyersCount;
    }

    public void setTotalBuyersCount(int totalBuyersCount) {
        this.totalBuyersCount = totalBuyersCount;
    }

    public int getOpenDisputesCount() {
        return openDisputesCount;
    }

    public void setOpenDisputesCount(int openDisputesCount) {
        this.openDisputesCount = openDisputesCount;
    }

    public int getTotalOrdersCount() {
        return totalOrdersCount;
    }

    public void setTotalOrdersCount(int totalOrdersCount) {
        this.totalOrdersCount = totalOrdersCount;
    }

    public String getTotalOrdersFormatted() {
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(totalOrdersCount);
    }

    public int getActiveUsersCount() {
        return activeUsersCount;
    }

    public void setActiveUsersCount(int activeUsersCount) {
        this.activeUsersCount = activeUsersCount;
    }

    public String getActiveUsersFormatted() {
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(activeUsersCount);
    }

    public double getNextPayoutVolume() {
        return nextPayoutVolume;
    }

    public void setNextPayoutVolume(double nextPayoutVolume) {
        this.nextPayoutVolume = nextPayoutVolume;
    }

    public String getNextPayoutVolumeFormatted() {
        return formatCurrency(nextPayoutVolume);
    }

    public int getNextPayoutVendorsCount() {
        return nextPayoutVendorsCount;
    }

    public void setNextPayoutVendorsCount(int nextPayoutVendorsCount) {
        this.nextPayoutVendorsCount = nextPayoutVendorsCount;
    }

    public String getNextPayoutDate() {
        return nextPayoutDate != null ? nextPayoutDate : "Thứ Sáu, 04/10";
    }

    public void setNextPayoutDate(String nextPayoutDate) {
        this.nextPayoutDate = nextPayoutDate;
    }

    public String getChartLabelsJson() {
        return chartLabelsJson != null ? chartLabelsJson : "['01/10', '06/10', '11/10', '16/10', '21/10', '26/10', 'Hôm nay']";
    }

    public void setChartLabelsJson(String chartLabelsJson) {
        this.chartLabelsJson = chartLabelsJson;
    }

    public String getChartGmvJson() {
        return chartGmvJson != null ? chartGmvJson : "[42000, 68000, 54000, 78000, 98400, 89000, 114000]";
    }

    public void setChartGmvJson(String chartGmvJson) {
        this.chartGmvJson = chartGmvJson;
    }

    public String getChartCommissionJson() {
        return chartCommissionJson != null ? chartCommissionJson : "[3360, 5440, 4320, 6240, 7872, 7120, 9120]";
    }

    public void setChartCommissionJson(String chartCommissionJson) {
        this.chartCommissionJson = chartCommissionJson;
    }

    public String getCategoryLabelsJson() {
        return categoryLabelsJson != null ? categoryLabelsJson : "['Cam, Bưởi & Táo Lê', 'Nhiệt Đới & Đặc Sản', 'Dâu Tây & Quả Mọng', 'Dưa Lưới & Nho', 'Hộp Quà Biếu Tặng']";
    }

    public void setCategoryLabelsJson(String categoryLabelsJson) {
        this.categoryLabelsJson = categoryLabelsJson;
    }

    public String getCategoryDataJson() {
        return categoryDataJson != null ? categoryDataJson : "[34, 28, 18, 12, 8]";
    }

    public void setCategoryDataJson(String categoryDataJson) {
        this.categoryDataJson = categoryDataJson;
    }

    public List<Map<String, Object>> getCategoryStats() {
        return categoryStats;
    }

    public void setCategoryStats(List<Map<String, Object>> categoryStats) {
        this.categoryStats = categoryStats;
    }

    public List<Map<String, Object>> getPendingShops() {
        return pendingShops;
    }

    public void setPendingShops(List<Map<String, Object>> pendingShops) {
        this.pendingShops = pendingShops;
    }

    public List<Map<String, Object>> getActiveDisputes() {
        return activeDisputes;
    }

    public void setActiveDisputes(List<Map<String, Object>> activeDisputes) {
        this.activeDisputes = activeDisputes;
    }

    public static String formatCurrency(double amount) {
        if (amount >= 1_000_000_000.0) {
            return String.format("%.2f Tỷ ₫", amount / 1_000_000_000.0);
        } else if (amount >= 1_000_000.0) {
            return String.format("%.1f Tr ₫", amount / 1_000_000.0);
        } else {
            DecimalFormat df = new DecimalFormat("#,### ₫");
            return df.format(amount);
        }
    }
}
