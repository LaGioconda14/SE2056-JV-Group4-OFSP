package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import model.User;
import service.IPaymentService;
import service.impl.PaymentServiceImpl;

/**
 * Admin theo dõi giao dịch thanh toán toàn sàn (Track Payment Status / View Payment History - Admin).
 * Chỉ ADMIN và STAFF được truy cập.
 */
@WebServlet(name = "AdminPaymentServlet", urlPatterns = {"/admin/payments"})
public class AdminPaymentServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private static final List<String> METHODS = Arrays.asList("ALL", "COD", "ONLINE", "VNPAY", "BANK_TRANSFER");
    private static final List<String> STATUSES = Arrays.asList("ALL", "SUCCESS", "PENDING", "FAILED");
    private static final List<Integer> RANGES = Arrays.asList(7, 30, 90, 365, 0);

    private final IPaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản quản trị!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String role = user.getRole() == null ? "" : user.getRole().toUpperCase();
        if (!"ADMIN".equals(role) && !"STAFF".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này");
            return;
        }

        String q = request.getParameter("q") == null ? "" : request.getParameter("q").trim();
        String method = pick(request.getParameter("method"), METHODS);
        String status = pick(request.getParameter("status"), STATUSES);
        int days = parseInt(request.getParameter("days"), 30);
        if (!RANGES.contains(days)) {
            days = 30;
        }

        int totalItems = paymentService.countPayments(null, q, method, status, days);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        int page = Math.min(Math.max(1, parseInt(request.getParameter("page"), 1)), totalPages);

        request.setAttribute("payments", paymentService.searchPayments(null, q, method, status, days, page, PAGE_SIZE));
        request.setAttribute("stats", paymentService.getStats(null));
        request.setAttribute("countAll", paymentService.countPayments(null, q, method, "ALL", days));
        request.setAttribute("countSuccess", paymentService.countPayments(null, q, method, "SUCCESS", days));
        request.setAttribute("countPending", paymentService.countPayments(null, q, method, "PENDING", days));
        request.setAttribute("countFailed", paymentService.countPayments(null, q, method, "FAILED", days));
        request.setAttribute("q", q);
        request.setAttribute("method", method);
        request.setAttribute("status", status);
        request.setAttribute("days", days);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.getRequestDispatcher("/views/admin/payments.jsp").forward(request, response);
    }

    private String pick(String value, List<String> allowed) {
        if (value == null) {
            return "ALL";
        }
        String v = value.trim().toUpperCase();
        return allowed.contains(v) ? v : "ALL";
    }

    private int parseInt(String s, int fallback) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ex) {
            return fallback;
        }
    }
}
