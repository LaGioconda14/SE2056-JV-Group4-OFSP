package controller.shop;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
import model.dto.order.SubOrderDTO;
import enums.SubOrderStatus;
import service.IOrderFulfillmentService;
import service.impl.OrderFulfillmentServiceImpl;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopOrdersServlet", urlPatterns = {"/shop/orders"})
public class ShopOrdersServlet extends HttpServlet {

    private final IOrderFulfillmentService fulfillmentService = new OrderFulfillmentServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession();
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (session.getAttribute("shopId") != null)
                ? ((Number) session.getAttribute("shopId")).longValue() : null;
        if (shopId == null || shopId <= 0) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            } else {
                shopId = 1L;
                session.setAttribute("shopId", shopId);
            }
        }

        String statusTab = request.getParameter("status");
        if (statusTab == null || statusTab.trim().isEmpty()) {
            statusTab = "ALL";
        }

        String keyword = request.getParameter("keyword");

        SubOrderStatus tabStatus = SubOrderStatus.from(statusTab);
        List<SubOrderDTO> list = fulfillmentService.getSubOrdersByShop(shopId, tabStatus, keyword);

        int countAll = fulfillmentService.countSubOrdersByShop(shopId, null);
        int countNew = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.NEW);
        int countPacking = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.PACKING);
        int countShipping = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.SHIPPING);
        int countDelivered = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.DELIVERED);
        int countFailed = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.FAILED);
        int countCancelled = fulfillmentService.countSubOrdersByShop(shopId, SubOrderStatus.CANCELLED);

        session.setAttribute("shopSubOrdersCount", countAll);
        session.setAttribute("sidebarPendingOrdersCount", countNew);
        request.setAttribute("sidebarPendingOrdersCount", countNew);

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