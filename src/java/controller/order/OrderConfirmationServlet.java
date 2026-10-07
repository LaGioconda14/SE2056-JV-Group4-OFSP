package controller.order;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Order;
import model.User;
import service.IOrderService;
import service.impl.OrderServiceImpl;

@WebServlet(name = "OrderConfirmationServlet", urlPatterns = {"/order/confirmation"})
public class OrderConfirmationServlet extends HttpServlet {

    private final IOrderService orderService = new OrderServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderIdParam = request.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        try {
            long orderId = Long.parseLong(orderIdParam.trim());
            Order order = orderService.getOrderDetails(orderId);

            if (order == null || order.getCustomerId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }

            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/order/order-confirmation.jsp").forward(request, response);

        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
}
