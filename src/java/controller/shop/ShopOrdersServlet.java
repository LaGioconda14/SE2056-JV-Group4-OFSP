package controller.shop;

import dao.OrderFulfillmentDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.SubOrder;

@WebServlet(name = "ShopOrdersServlet", urlPatterns = {"/shop/orders"})
public class ShopOrdersServlet extends HttpServlet {

    private final OrderFulfillmentDAO fulfillmentDAO = new OrderFulfillmentDAO();

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

        // Query real database records
        List<SubOrder> list = fulfillmentDAO.getSubOrdersByShop(shopId, statusTab, keyword);

        // Counts for tab badges
        int countAll = fulfillmentDAO.countSubOrdersByShop(shopId, "ALL");
        int countNew = fulfillmentDAO.countSubOrdersByShop(shopId, "NEW");
        int countPacking = fulfillmentDAO.countSubOrdersByShop(shopId, "PACKING");
        int countShipping = fulfillmentDAO.countSubOrdersByShop(shopId, "SHIPPING");
        int countDelivered = fulfillmentDAO.countSubOrdersByShop(shopId, "DELIVERED");
        int countCancelled = fulfillmentDAO.countSubOrdersByShop(shopId, "CANCELLED");

        request.setAttribute("orderList", list);
        request.setAttribute("currentTab", statusTab.toUpperCase());
        request.setAttribute("keyword", keyword != null ? keyword : "");
        request.setAttribute("countAll", countAll);
        request.setAttribute("countNew", countNew);
        request.setAttribute("countPacking", countPacking);
        request.setAttribute("countShipping", countShipping);
        request.setAttribute("countDelivered", countDelivered);
        request.setAttribute("countCancelled", countCancelled);
        request.setAttribute("activeMenu", "orders");

        request.getRequestDispatcher("/views/shop/shop-orders.jsp").forward(request, response);
    }
}
