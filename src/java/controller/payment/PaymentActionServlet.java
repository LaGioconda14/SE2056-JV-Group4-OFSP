package controller.payment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Payment;
import model.User;
import service.IPaymentService;
import service.impl.PaymentServiceImpl;
import util.PaymentGatewayUtil;

/**
 * Hai lựa chọn của khách sau khi thanh toán thất bại (business flow):
 * POST /payment/retry  : thanh toán lại -> tạo giao dịch mới, quay lại cổng.
 * POST /payment/cancel : hủy đơn (hoàn kho, hoàn voucher).
 * Cả hai đều được CartCsrfFilter kiểm tra csrfToken.
 */
@WebServlet(name = "PaymentActionServlet", urlPatterns = {"/payment/retry", "/payment/cancel"})
public class PaymentActionServlet extends HttpServlet {

    private final IPaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để tiếp tục thanh toán!");
            response.sendRedirect(ctx + "/login");
            return;
        }

        long orderId;
        try {
            orderId = Long.parseLong(request.getParameter("orderId"));
        } catch (NumberFormatException ex) {
            response.sendRedirect(ctx + "/payment/history");
            return;
        }

        if (request.getServletPath().endsWith("/cancel")) {
            cancel(request, response, session, user, orderId);
        } else {
            retry(request, response, session, user, orderId);
        }
    }

    private void retry(HttpServletRequest request, HttpServletResponse response, HttpSession session,
            User user, long orderId) throws IOException {
        String ctx = request.getContextPath();
        try {
            String provider = request.getParameter("provider");
            if (provider == null || provider.trim().isEmpty()) {
                // Mặc định dùng lại phương thức của lần thanh toán trước.
                Payment last = paymentService.getLatestPaymentByOrder(orderId);
                provider = (last != null) ? last.getPaymentProvider() : null;
            }
            // Thanh toán lại bằng phương thức khác: đổi sang COD, giữ nguyên đơn và giỏ hàng.
            if (Payment.PROVIDER_COD.equalsIgnoreCase(provider)) {
                paymentService.switchToCod(user.getId(), orderId);
                session.setAttribute("orderSuccess",
                        "Đã chuyển sang thanh toán khi nhận hàng (COD). Đơn hàng của bạn đã được xác nhận!");
                response.sendRedirect(ctx + "/order/confirmation?orderId=" + orderId);
                return;
            }
            String gatewayUrl = paymentService.startOnlinePayment(
                    user.getId(), orderId, provider, PaymentGatewayUtil.baseUrl(request));
            response.sendRedirect(gatewayUrl);
        } catch (Exception ex) {
            session.setAttribute("paymentError", ex.getMessage());
            response.sendRedirect(ctx + "/payment/failed?orderId=" + orderId);
        }
    }

    private void cancel(HttpServletRequest request, HttpServletResponse response, HttpSession session,
            User user, long orderId) throws IOException {
        String ctx = request.getContextPath();
        try {
            paymentService.cancelUnpaidOrder(user.getId(), orderId);
            session.setAttribute("paymentNotice", "Đã hủy đơn hàng chưa thanh toán. Sản phẩm đã được hoàn lại kho.");
            response.sendRedirect(ctx + "/payment/history");
        } catch (Exception ex) {
            session.setAttribute("paymentError", ex.getMessage());
            response.sendRedirect(ctx + "/payment/history");
        }
    }
}
