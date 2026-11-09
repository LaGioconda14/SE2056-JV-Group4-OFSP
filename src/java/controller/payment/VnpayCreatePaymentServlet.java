package controller.payment;

import enums.PaymentMethod;
import enums.PaymentStatus;
import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.order.Order;
import model.entity.user.User;
import service.VnpayPaymentService;
import util.VnpayUtil;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.VnpayConfig;

@WebServlet(name = "VnpayCreatePaymentServlet", urlPatterns = {"/payment/vnpay/create"})
public class VnpayCreatePaymentServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(VnpayCreatePaymentServlet.class.getName());
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
            if (!VnpayConfig.isConfigured()) {
                if (session != null) {
                    session.setAttribute("errorMessage",
                            "Cổng thanh toán VNPAY chưa được cấu hình thông tin kết nối (thiếu vnpay.tmn_code hoặc vnpay.hash_secret trong file vnpay.properties). Đơn hàng #"
                            + orderId + " đã được ghi nhận ở trạng thái Chờ thanh toán.");
                }
                response.sendRedirect(request.getContextPath() + "/profile#orders");
                return;
            }
            String returnUrl = request.getScheme() + "://" + request.getServerName()
                    + (("http".equals(request.getScheme()) && request.getServerPort() == 80)
                    || ("https".equals(request.getScheme()) && request.getServerPort() == 443)
                    ? "" : ":" + request.getServerPort())
                    + request.getContextPath() + "/payment/vnpay/return";
            response.sendRedirect(paymentService.createPaymentUrl(
                    order, VnpayUtil.getClientIp(request), returnUrl));
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Không thể khởi tạo thanh toán VNPAY cho đơn hàng", ex);
            if (session != null) {
                session.setAttribute("errorMessage", "Không thể khởi tạo thanh toán VNPAY: " + ex.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile#orders");
        }
    }
}
