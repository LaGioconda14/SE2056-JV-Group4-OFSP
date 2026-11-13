package controller.loyalty;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import model.entity.user.User;
import service.ILoyaltyService;
import service.impl.LoyaltyServiceImpl;

/** Lịch sử điểm thưởng (FE-14): lọc theo loại giao dịch và khoảng ngày, có phân trang. */
@WebServlet(name = "LoyaltyHistoryServlet", urlPatterns = {"/loyalty/history"})
public class LoyaltyHistoryServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private static final List<String> TYPES = Arrays.asList("ALL", "EARN", "REDEEM", "RESTORE", "REVERSE", "ADJUST");

    private final ILoyaltyService loyaltyService = new LoyaltyServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để xem lịch sử điểm!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        long customerId = user.getId();
        loyaltyService.syncOrders(customerId);

        String type = request.getParameter("type") == null ? "ALL" : request.getParameter("type").trim().toUpperCase();
        if (!TYPES.contains(type)) {
            type = "ALL";
        }
        String fromRaw = trim(request.getParameter("from"));
        String toRaw = trim(request.getParameter("to"));
        java.sql.Date from = parseDate(fromRaw);
        java.sql.Date to = parseDate(toRaw);
        if (from != null && to != null && from.after(to)) {
            request.setAttribute("filterError", "Ngày bắt đầu không được sau ngày kết thúc!");
            from = null;
            to = null;
            fromRaw = "";
            toRaw = "";
        }

        int totalItems = loyaltyService.countHistory(customerId, type, from, to);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        int page = Math.min(Math.max(1, parseInt(request.getParameter("page"))), totalPages);

        request.setAttribute("transactions", loyaltyService.history(customerId, type, from, to, page, PAGE_SIZE));
        request.setAttribute("totals", loyaltyService.historyTotals(customerId));
        request.setAttribute("account", loyaltyService.getAccount(customerId));
        request.setAttribute("type", type);
        request.setAttribute("from", fromRaw);
        request.setAttribute("to", toRaw);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.getRequestDispatcher("/views/loyalty/loyalty-history.jsp").forward(request, response);
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private java.sql.Date parseDate(String s) {
        try {
            return s.isEmpty() ? null : java.sql.Date.valueOf(s);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private int parseInt(String s) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ex) {
            return 1;
        }
    }
}
