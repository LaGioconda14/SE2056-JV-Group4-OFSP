package controller.shop;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.SubOrder;
import enums.SubOrderStatus;
import service.IOrderFulfillmentService;
import service.impl.OrderFulfillmentServiceImpl;

@WebServlet(name = "ShopOrdersServlet", urlPatterns = {"/shop/orders"})
public class ShopOrdersServlet extends HttpServlet {

    private final IOrderFulfillmentService fulfillmentService = new OrderFulfillmentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String statusTab = request.getParameter("status");
        if (statusTab == null || statusTab.trim().isEmpty()) {
            statusTab = "ALL";
        }

        String keyword = request.getParameter("keyword");

        long shopId = 1L; // Default current shop
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("shopId") != null) {
            try {
                shopId = ((Number) session.getAttribute("shopId")).longValue();
            } catch (Exception ignored) {
            }
        }

        SubOrderStatus tabStatus = SubOrderStatus.from(statusTab);
        List<SubOrder> list = fulfillmentService.getSubOrdersByShop(shopId, tabStatus, keyword);

        int countAll = fulfillmentService.countSubOrdersByShop(shopId, null);
        int countNew = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.NEW);
        int countPacking = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.PACKING);
        int countShipping = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.SHIPPING);
        int countDelivered = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.DELIVERED);
        int countFailed = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.FAILED);
        int countCancelled = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.CANCELLED);

        if (session != null) {
            session.setAttribute("shopSubOrdersCount", countAll);
        }

        request.setAttribute("orderList", list);
        request.setAttribute("currentTab", statusTab.toUpperCase());
        request.setAttribute("keyword", keyword != null ? keyword : "");
        request.setAttribute("countAll", countAll);
        request.setAttribute("shopSubOrdersCount", countAll);
        request.setAttribute("countNew", countNew);
        request.setAttribute("countPacking", countPacking);
        request.setAttribute("countShipping", countShipping);
        request.setAttribute("countDelivered", countDelivered);
        request.setAttribute("countFailed", countFailed);
        request.setAttribute("countCancelled", countCancelled);
        request.setAttribute("activeMenu", "orders");

        request.getRequestDispatcher("/views/shop/shop-orders.jsp").forward(request, response);
    }
}
