package controller.payment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;
import model.PaymentOutcome;
import model.User;
import service.IPaymentService;
import service.impl.PaymentServiceImpl;
import util.PaymentGatewayUtil;

/**
 * Điểm nhận kết quả từ cổng thanh toán (vnp_ReturnUrl).
 * Xác thực chữ ký -> cập nhật payments/orders -> chuyển khách tới trang thành công
 * hoặc trang thất bại (có lựa chọn thanh toán lại / hủy đơn).
 */
@WebServlet(name = "PaymentReturnServlet", urlPatterns = {"/payment/return"})
public class PaymentReturnServlet extends HttpServlet {

    private final IPaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để xem kết quả thanh toán!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Map<String, String> params = PaymentGatewayUtil.readGatewayParams(request);
        PaymentOutcome outcome = paymentService.processGatewayReturn(params, user.getId());

        String ctx = request.getContextPath();
        if (outcome.getOrderId() <= 0) {
            session.setAttribute("paymentError", outcome.getMessage());
            response.sendRedirect(ctx + "/payment/history");
            return;
        }

        // Post/Redirect/Get: F5 trên trang kết quả không xử lý lại giao dịch.
        if (outcome.isSuccess()) {
            response.sendRedirect(ctx + "/payment/success?orderId=" + outcome.getOrderId());
        } else {
            response.sendRedirect(ctx + "/payment/failed?orderId=" + outcome.getOrderId());
        }
    }
}
