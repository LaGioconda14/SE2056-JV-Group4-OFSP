package controller.payment;

import enums.PaymentMethod;
import enums.PaymentStatus;
import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.User;
import service.VnpayPaymentService;
import util.VnpayUtil;

@WebServlet(name = "VnpayCreatePaymentServlet", urlPatterns = {"/payment/vnpay/create"})
public class VnpayCreatePaymentServlet extends HttpServlet {

    private final VnpayPaymentService paymentService = new VnpayPaymentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long orderId = Long.parseLong(request.getParameter("orderId"));
            Order order = paymentService.getOrder(orderId);
            if (order == null || order.getCustomerId() != user.getId()
                    || !PaymentMethod.VNPAY.name().equalsIgnoreCase(order.getPaymentMethod())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if (PaymentStatus.PAID.name().equalsIgnoreCase(order.getPaymentStatus())) {
                response.sendRedirect(request.getContextPath()
                        + "/order/confirmation?orderId=" + orderId + "&payment=success");
                return;
            }
            String returnUrl = request.getScheme() + "://" + request.getServerName()
                    + (("http".equals(request.getScheme()) && request.getServerPort() == 80)
                    || ("https".equals(request.getScheme()) && request.getServerPort() == 443)
                    ? "" : ":" + request.getServerPort())
                    + request.getContextPath() + "/payment/vnpay/return";
            response.sendRedirect(paymentService.createPaymentUrl(
                    order, VnpayUtil.getClientIp(request), returnUrl));
        } catch (IllegalArgumentException | IllegalStateException ex) {
            if (session != null) {
                session.setAttribute("errorMessage", "Không thể khởi tạo thanh toán VNPAY: " + ex.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile#orders");
        }
    }
}
