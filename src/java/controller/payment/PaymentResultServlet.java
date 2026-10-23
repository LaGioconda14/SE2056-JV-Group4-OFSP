package controller.payment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Order;
import model.Payment;
import model.User;
import service.IOrderService;
import service.IPaymentService;
import service.impl.OrderServiceImpl;
import service.impl.PaymentServiceImpl;

/**
 * GET /payment/success?orderId= : biên lai thanh toán điện tử.
 * GET /payment/failed?orderId=  : thông báo thất bại + lựa chọn thanh toán lại / hủy đơn.
 */
@WebServlet(name = "PaymentResultServlet", urlPatterns = {"/payment/success", "/payment/failed"})
public class PaymentResultServlet extends HttpServlet {

    private final IPaymentService paymentService = new PaymentServiceImpl();
    private final IOrderService orderService = new OrderServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để xem kết quả thanh toán!");
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

        Payment payment = paymentService.getLatestPaymentByOrder(orderId);
        if (payment == null || payment.getCustomerId() != user.getId()) {
            response.sendRedirect(ctx + "/payment/history");
            return;
        }

        boolean successPage = request.getServletPath().endsWith("/success");

        // Điều hướng đúng trang theo kết quả thực tế trong DB (không tin vào URL).
        if (successPage && !payment.isSuccess()) {
            response.sendRedirect(ctx + "/payment/history");
            return;
        }
        if (!successPage && payment.isSuccess()) {
            response.sendRedirect(ctx + "/payment/success?orderId=" + orderId);
            return;
        }

        Order order = orderService.getOrderDetails(orderId);
        request.setAttribute("payment", payment);
        request.setAttribute("order", order);

        String view = successPage ? "/views/payment/payment_success.jsp" : "/views/payment/payment_failed.jsp";
        request.getRequestDispatcher(view).forward(request, response);
    }
}
