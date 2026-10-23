package controller.shop;

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
import service.IPayoutService;
import service.impl.PayoutServiceImpl;

/**
 * Doanh thu & Rút tiền của chủ shop (mục "Doanh thu & Rút tiền" trong menu Seller Center).
 * Shop xem các kỳ quyết toán của MÌNH và cập nhật tài khoản ngân hàng nhận tiền;
 * việc chuyển tiền do Admin xác nhận ở /admin/payouts.
 */
@WebServlet(name = "ShopFinanceServlet", urlPatterns = {"/shop/finance"})
public class ShopFinanceServlet extends HttpServlet {

    private static final int PAGE_SIZE = 6;
    private static final List<String> STATUSES = Arrays.asList("ALL", "PROCESSING", "ON_HOLD", "COMPLETED");

    private final IPayoutService payoutService = new PayoutServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        long[] ctx = resolveShop(request, response);
        if (ctx == null) {
            return;
        }
        long shopId = ctx[0];

        String status = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
        if (!STATUSES.contains(status)) {
            status = "ALL";
        }
        int totalItems = payoutService.count(shopId, status, null);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        int page = Math.min(Math.max(1, parse(request.getParameter("page"))), totalPages);

        request.setAttribute("payouts", payoutService.search(shopId, status, null, page, PAGE_SIZE));
        request.setAttribute("summary", payoutService.getSummary(shopId));
        request.setAttribute("info", payoutService.getShopFinanceInfo(shopId));
        request.setAttribute("status", status);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("activeMenu", "finance");
        request.getRequestDispatcher("/views/shop/shop-finance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        long[] ctx = resolveShop(request, response);
        if (ctx == null) {
            return;
        }
        HttpSession session = request.getSession();
        try {
            payoutService.updateBankInfo(ctx[0], ctx[1], request.getParameter("bankName"),
                    request.getParameter("bankAccount"), request.getParameter("bankHolder"));
            session.setAttribute("shopFlash",
                    "Đã cập nhật tài khoản nhận tiền. Các kỳ quyết toán tiếp theo sẽ chuyển vào tài khoản này.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            session.setAttribute("shopError", ex.getMessage());
        } catch (Exception ex) {
            session.setAttribute("shopError", "Không thể cập nhật do lỗi hệ thống. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/shop/finance");
    }

    /** @return {shopId, ownerUserId} của chủ shop đang đăng nhập, hoặc null nếu đã chuyển hướng. */
    private long[] resolveShop(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản chủ gian hàng!");
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        long shopId = payoutService.findShopIdByOwner(user.getId());
        if (shopId < 0) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản của bạn chưa sở hữu gian hàng nào");
            return null;
        }
        return new long[]{shopId, user.getId()};
    }

    private int parse(String s) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ex) {
            return 1;
        }
    }
}
