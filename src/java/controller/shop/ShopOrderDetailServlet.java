package controller.shop;

import java.io.IOException;
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

@WebServlet(name = "ShopOrderDetailServlet", urlPatterns = {"/shop/order-detail", "/shop/orders/detail"})
public class ShopOrderDetailServlet extends HttpServlet {

    private final IOrderFulfillmentService fulfillmentService = new OrderFulfillmentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        long shopId = 1L;
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("shopId") != null) {
            try {
                shopId = ((Number) session.getAttribute("shopId")).longValue();
            } catch (Exception ignored) {
            }
        }

        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            code = fulfillmentService.getFirstSubOrderCode(shopId);
        }

        if (code == null || code.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shop/orders");
            return;
        }

        SubOrder subOrder = fulfillmentService.getSubOrderDetails(code);
        if (subOrder == null) {
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=order_not_found");
            return;
        }

        int shopSubOrdersCount = fulfillmentService.countSubOrdersByShop(shopId, (SubOrderStatus) null);
        if (session != null) {
            session.setAttribute("shopSubOrdersCount", shopSubOrdersCount);
        }
        request.setAttribute("shopSubOrdersCount", shopSubOrdersCount);

        request.setAttribute("subOrder", subOrder);
        request.setAttribute("activeMenu", "orders");
        request.getRequestDispatcher("/views/shop/shop-order-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String action = request.getParameter("action");
        String code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=missing_code");
            return;
        }

        HttpSession session = request.getSession(false);
        Long currentUserId = null;
        if (session != null && session.getAttribute("userId") != null) {
            try {
                currentUserId = ((Number) session.getAttribute("userId")).longValue();
            } catch (Exception ignored) {
            }
        }

        if ("cancel_sub_order".equals(action)) {
            String category = request.getParameter("cancelReasonCategory");
            String note = request.getParameter("cancelReasonNote");
            StringBuilder sb = new StringBuilder();
            if (category != null && !category.trim().isEmpty()) {
                sb.append(category.trim());
            }
            if (note != null && !note.trim().isEmpty()) {
                if (sb.length() > 0) {
                    sb.append(" - ");
                }
                sb.append(note.trim());
            }
            String reason = sb.length() > 0 ? sb.toString() : "Shop hủy đơn do không đủ điều kiện cung cấp nông sản đạt chuẩn.";

            boolean ok = fulfillmentService.cancelSubOrder(code, reason, currentUserId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + SubOrderStatus.CANCELLED.name() + "&cancelled=1");
            } else {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&error=cancel_failed");
            }
            return;
        }

        if ("confirm".equals(action)) {
            fulfillmentService.updateSubOrderStatus(code, SubOrderStatus.PACKING);
            response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + SubOrderStatus.PACKING.name() + "&success=1");
            return;
        }

        if ("ready_to_ship".equals(action)) {
            fulfillmentService.updateSubOrderStatus(code, SubOrderStatus.SHIPPING);
            response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + SubOrderStatus.SHIPPING.name() + "&success=1");
            return;
        }

        String newStatus = request.getParameter("newStatus");
        if (newStatus != null && !newStatus.trim().isEmpty()) {
            SubOrderStatus statusEnum = SubOrderStatus.from(newStatus);
            if (statusEnum != null) {
                fulfillmentService.updateSubOrderStatus(code, statusEnum);
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + statusEnum.name() + "&success=1");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code);
    }
}
