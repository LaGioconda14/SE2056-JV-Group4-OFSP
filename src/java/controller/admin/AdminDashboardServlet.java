package controller.admin;

import com.google.gson.Gson;
import dao.AdminDashboardDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.dto.admin.AdminDashboardStats;
import service.IShopDashboardService;
import service.impl.ShopDashboardServiceImpl;

@WebServlet(name="AdminDashboardServlet",urlPatterns={"/admin","/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID=1L;
    private final AdminDashboardDAO adminDAO=new AdminDashboardDAO();
    private final IShopDashboardService shopService=new ShopDashboardServiceImpl();
    private final Gson gson=new Gson();

    @Override protected void doGet(HttpServletRequest request,HttpServletResponse response)throws ServletException,IOException{
        String range=normalizeRange(request.getParameter("range"));Long shopId=parseLong(request.getParameter("shopId"));
        Map<String,Object>selectedShop=shopId==null?null:adminDAO.getShop(shopId);if(shopId!=null&&selectedShop==null)shopId=null;
        LocalDate today=LocalDate.now(),to=today.plusDays(1),from;boolean compare=true;String rangeLabel;
        switch(range){case"7":from=today.minusDays(6);rangeLabel="7 ngày qua";break;case"90":from=today.minusDays(89);rangeLabel="90 ngày qua";break;case"365":from=today.minusDays(364);rangeLabel="12 tháng qua";break;case"all":LocalDate first=shopId==null?adminDAO.getFirstOrderDate():shopService.getFirstOrderDate(shopId);from=first!=null?first:today.minusDays(29);compare=false;rangeLabel="Toàn thời gian";break;default:from=today.minusDays(29);rangeLabel="30 ngày qua";}
        request.setAttribute("activePage","dashboard");request.setAttribute("range",range);request.setAttribute("rangeLabel",rangeLabel);request.setAttribute("fromDate",java.sql.Date.valueOf(from));request.setAttribute("toDate",java.sql.Date.valueOf(today));request.setAttribute("hasCompare",compare);request.setAttribute("shops",adminDAO.getAvailableShops());request.setAttribute("selectedShop",selectedShop);request.setAttribute("selectedShopId",shopId);
        if(shopId==null)loadPlatform(request,from,to,compare);else loadShop(request,shopId,from,to,compare,range);
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request,response);
    }

    private void loadPlatform(HttpServletRequest request,LocalDate from,LocalDate to,boolean compare){
        AdminDashboardStats stats=adminDAO.getDashboardStats(from,to,compare);request.setAttribute("stats",stats);request.setAttribute("trendLabelsJson",stats.getChartLabelsJson());request.setAttribute("trendPrimaryJson",stats.getChartGmvJson());request.setAttribute("trendSecondaryJson",stats.getChartCommissionJson());request.setAttribute("statusLabelsJson",stats.getStatusLabelsJson());request.setAttribute("statusValuesJson",stats.getStatusDataJson());request.setAttribute("topProducts",stats.getTopProducts());request.setAttribute("pendingShopsList",stats.getPendingShops());request.setAttribute("pendingOrders",stats.getProcessingOrdersCount());request.setAttribute("pendingProducts",stats.getFlaggedProductsCount());request.setAttribute("pendingShops",stats.getPendingKycCount());request.setAttribute("openDisputes",stats.getOpenDisputesCount());
    }

    private void loadShop(HttpServletRequest request,long shopId,LocalDate from,LocalDate to,boolean compare,String range){
        Map<String,Object>current=shopService.getSummary(shopId,from,to);double revenue=number(current.get("revenue")),commission=number(current.get("commission"));int orders=integer(current.get("orders")),delivered=integer(current.get("delivered"));request.setAttribute("shopRevenue",revenue);request.setAttribute("shopNetRevenue",revenue-commission);request.setAttribute("shopCommission",commission);request.setAttribute("shopOrders",orders);request.setAttribute("shopDelivered",delivered);request.setAttribute("shopCancelled",current.get("cancelled"));request.setAttribute("shopItemsSold",current.get("itemsSold"));request.setAttribute("shopAverageOrder",delivered>0?revenue/delivered:0);
        if(compare){long days=ChronoUnit.DAYS.between(from,to);Map<String,Object>previous=shopService.getSummary(shopId,from.minusDays(days),from);request.setAttribute("revenueChange",percent(revenue,number(previous.get("revenue"))));}
        boolean monthly="365".equals(range)||"all".equals(range);Map<String,List<?>>trend=shopService.getTrend(shopId,from,to,monthly);request.setAttribute("trendLabelsJson",gson.toJson(trend.get("labels")));request.setAttribute("trendPrimaryJson",gson.toJson(trend.get("revenue")));request.setAttribute("trendSecondaryJson",gson.toJson(trend.get("orders")));
        Map<String,Integer>raw=shopService.getStatusBreakdown(shopId,from,to);String[][]defs={{"NEW","Mới"},{"CONFIRMED","Đã xác nhận"},{"PACKING","Đang đóng gói"},{"SHIPPING","Đang giao"},{"DELIVERED","Đã giao"},{"FAILED","Giao thất bại"},{"CANCELLED","Đã hủy"}};List<String>labels=new ArrayList<>();List<Integer>values=new ArrayList<>();for(String[]d:defs){int c=raw.getOrDefault(d[0],0);if(c>0){labels.add(d[1]);values.add(c);}}request.setAttribute("statusLabelsJson",gson.toJson(labels));request.setAttribute("statusValuesJson",gson.toJson(values));
        request.setAttribute("bestSellers",shopService.getBestSellers(shopId,from,to,5));request.setAttribute("recentOrders",shopService.getRecentOrders(shopId,6));request.setAttribute("ratingStats",shopService.getRatingStats(shopId,from,to));request.setAttribute("lowStockItems",shopService.getLowStockItems(shopId,5));request.setAttribute("latestPayout",shopService.getLatestPayout(shopId));request.setAttribute("pendingOrders",shopService.countPendingOrders(shopId));request.setAttribute("shippingOrders",shopService.countShippingOrders(shopId));request.setAttribute("openDisputes",shopService.countOpenDisputes(shopId));request.setAttribute("lowStockCount",shopService.countLowStock(shopId));
    }
    private String normalizeRange(String v){return"7".equals(v)||"90".equals(v)||"365".equals(v)||"all".equals(v)?v:"30";}
    private Long parseLong(String v){try{long n=Long.parseLong(v);return n>0?n:null;}catch(Exception e){return null;}}
    private double number(Object v){return v instanceof Number?((Number)v).doubleValue():0;}
    private int integer(Object v){return v instanceof Number?((Number)v).intValue():0;}
    private Double percent(double current,double previous){return previous<=0?(current>0?null:0):(current-previous)*100/previous;}
}
