package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import service.ILoyaltyService;
import service.impl.LoyaltyServiceImpl;

/**
 * Admin quản lý luật điểm thưởng và điều chỉnh điểm của khách (FE-14). Truy cập được bảo vệ bởi bộ lọc /admin/*.
 *
 * GET  /admin/loyalty                 : luật hiện tại + tìm khách (?q=) + khách đang chọn (?customerId=)
 * POST /admin/loyalty action=saveRules : lưu tỉ lệ tích điểm, giá trị 1 điểm, trần dùng điểm
 * POST /admin/loyalty action=adjust    : cộng / trừ điểm cho khách kèm lý do
 */
@WebServlet(name = "AdminLoyaltyServlet", urlPatterns = {"/admin/loyalty"})
public class AdminLoyaltyServlet extends HttpServlet {

    private final ILoyaltyService loyaltyService = new LoyaltyServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String q = request.getParameter("q") == null ? "" : request.getParameter("q").trim();
        request.setAttribute("settings", loyaltyService.getSettings());
        request.setAttribute("q", q);
        request.setAttribute("results", loyaltyService.searchCustomers(q));

        long customerId = parseLong(request.getParameter("customerId"));
        if (customerId > 0) {
            request.setAttribute("customer", loyaltyService.getCustomerBrief(customerId));
            request.setAttribute("customerAccount", loyaltyService.getAccount(customerId));
        }
        request.getRequestDispatcher("/views/admin/loyalty.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        String redirect = request.getContextPath() + "/admin/loyalty";
        try {
            if ("saveRules".equals(action)) {
                loyaltyService.updateSettings(parseInt(request.getParameter("earnVndPerPoint")),
                        parseInt(request.getParameter("redeemVndPerPoint")),
                        parseInt(request.getParameter("maxRedeemPercent")));
                session.setAttribute("adminFlash", "Đã lưu luật chương trình điểm thưởng.");
            } else if ("adjust".equals(action)) {
                long customerId = parseLong(request.getParameter("customerId"));
                if (customerId <= 0) {
                    throw new IllegalArgumentException("Vui lòng chọn khách hàng cần điều chỉnh điểm!");
                }
                redirect += "?customerId=" + customerId;
                int balance = loyaltyService.adjustPoints(customerId, parseInt(request.getParameter("delta")),
                        request.getParameter("reason"));
                session.setAttribute("adminFlash", "Đã điều chỉnh điểm. Số dư mới của khách: " + balance + " điểm.");
            } else {
                session.setAttribute("adminError", "Thao tác không hợp lệ!");
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            session.setAttribute("adminError", ex.getMessage());
        } catch (Exception ex) {
            session.setAttribute("adminError", "Không thể xử lý do lỗi hệ thống. Vui lòng thử lại!");
        }
        response.sendRedirect(redirect);
    }

    /** Chấp nhận "+50" hoặc "-30"; ký tự không phải số bị coi là không hợp lệ. */
    private int parseInt(String s) {
        try {
            return Integer.parseInt(s == null ? "" : s.trim().replace("+", ""));
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị nhập vào phải là số nguyên!");
        }
    }

    private long parseLong(String s) {
        try {
            return Long.parseLong(s.trim());
        } catch (Exception ex) {
            return 0;
        }
    }
}
