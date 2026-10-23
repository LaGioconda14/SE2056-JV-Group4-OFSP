package controller.payment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;
import model.Payment;
import model.User;
import service.IPaymentService;
import service.impl.PaymentServiceImpl;

/**
 * Lịch sử thanh toán & giao dịch của khách hàng (Track Payment Status / View Payment History).
 * Hỗ trợ tìm kiếm, lọc theo phương thức / trạng thái / khoảng thời gian, phân trang
 * và xuất CSV (?export=csv).
 */
@WebServlet(name = "PaymentHistoryServlet", urlPatterns = {"/payment/history"})
public class PaymentHistoryServlet extends HttpServlet {

    private static final int PAGE_SIZE = 6;
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
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để xem lịch sử thanh toán!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        long customerId = user.getId();

        String q = trim(request.getParameter("q"));
        String method = pick(request.getParameter("method"), METHODS, "ALL");
        String status = pick(request.getParameter("status"), STATUSES, "ALL");
        int days = parseInt(request.getParameter("days"), 30);
        if (!RANGES.contains(days)) {
            days = 30;
        }

        if ("csv".equalsIgnoreCase(request.getParameter("export"))) {
            exportCsv(response, paymentService.searchPayments(customerId, q, method, status, days, 1, 5000));
            return;
        }

        int totalItems = paymentService.countPayments(customerId, q, method, status, days);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        int page = Math.min(Math.max(1, parseInt(request.getParameter("page"), 1)), totalPages);

        request.setAttribute("payments", paymentService.searchPayments(customerId, q, method, status, days, page, PAGE_SIZE));
        request.setAttribute("stats", paymentService.getStats(customerId));

        // Số lượng trên từng tab trạng thái (cùng bộ lọc tìm kiếm / phương thức / thời gian).
        request.setAttribute("countAll", paymentService.countPayments(customerId, q, method, "ALL", days));
        request.setAttribute("countSuccess", paymentService.countPayments(customerId, q, method, "SUCCESS", days));
        request.setAttribute("countPending", paymentService.countPayments(customerId, q, method, "PENDING", days));
        request.setAttribute("countFailed", paymentService.countPayments(customerId, q, method, "FAILED", days));

        request.setAttribute("q", q);
        request.setAttribute("method", method);
        request.setAttribute("status", status);
        request.setAttribute("days", days);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("fromItem", totalItems == 0 ? 0 : (page - 1) * PAGE_SIZE + 1);
        request.setAttribute("toItem", Math.min(page * PAGE_SIZE, totalItems));

        request.getRequestDispatcher("/views/payment/payment_history.jsp").forward(request, response);
    }

    private void exportCsv(HttpServletResponse response, List<Payment> rows) throws IOException {
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"lich-su-thanh-toan.csv\"");
        PrintWriter out = response.getWriter();
        out.write('\uFEFF'); // BOM để Excel đọc đúng tiếng Việt
        out.println("Ma giao dich,Ma don hang,Ngay tao,So tien (VND),Phuong thuc,Trang thai,Ghi chu");
        for (Payment p : rows) {
            out.println(csv(p.getTransactionCode()) + "," + csv(p.getOrderCode()) + ","
                    + csv(p.getCreatedAtFull()) + "," + p.getAmount().toBigInteger() + ","
                    + csv(p.getProviderLabel()) + "," + csv(p.getStatusLabel()) + "," + csv(p.getNote()));
        }
        out.flush();
    }

    /** Escape CSV và chặn CSV-injection (ô bắt đầu bằng = + - @ bị Excel hiểu là công thức). */
    private String csv(String value) {
        if (value == null) {
            return "";
        }
        String v = value;
        if (!v.isEmpty() && "=+-@".indexOf(v.charAt(0)) >= 0) {
            v = "'" + v;
        }
        return "\"" + v.replace("\"", "\"\"") + "\"";
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private String pick(String value, List<String> allowed, String fallback) {
        if (value == null) {
            return fallback;
        }
        String v = value.trim().toUpperCase();
        return allowed.contains(v) ? v : fallback;
    }

    private int parseInt(String s, int fallback) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ex) {
            return fallback;
        }
    }
}
