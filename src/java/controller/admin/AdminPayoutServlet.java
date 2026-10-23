package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.List;
import model.PayoutGenerationResult;
import model.User;
import model.VendorPayout;
import service.IPayoutService;
import service.impl.PayoutServiceImpl;
import util.AdminGuard;

/**
 * Quyết toán & chi trả doanh thu gian hàng (System / Admin).
 *
 * POST action=generate : tính kỳ quyết toán (Net = Gross - Hoa hồng - Khấu trừ khiếu nại)
 * POST action=complete : xác nhận đã chuyển tiền cho chủ shop (PROCESSING -> COMPLETED)
 * POST action=hold / release : tạm giữ / gỡ tạm giữ
 * POST action=delete   : hủy kỳ chưa chi trả để tính lại
 */
@WebServlet(name = "AdminPayoutServlet", urlPatterns = {"/admin/payouts"})
public class AdminPayoutServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;
    private static final List<String> STATUSES = Arrays.asList("ALL", "PROCESSING", "ON_HOLD", "COMPLETED");

    private final IPayoutService payoutService = new PayoutServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (AdminGuard.requireAdmin(request, response) == null) {
            return;
        }
        String q = request.getParameter("q") == null ? "" : request.getParameter("q").trim();
        String status = request.getParameter("status") == null ? "ALL" : request.getParameter("status").trim().toUpperCase();
        if (!STATUSES.contains(status)) {
            status = "ALL";
        }

        int totalItems = payoutService.count(null, status, q);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        int page = Math.min(Math.max(1, parse(request.getParameter("page"))), totalPages);

        request.setAttribute("payouts", payoutService.search(null, status, q, page, PAGE_SIZE));
        request.setAttribute("summary", payoutService.getSummary(null));
        request.setAttribute("shops", payoutService.listActiveShops());
        request.setAttribute("countAll", payoutService.count(null, "ALL", q));
        request.setAttribute("countProcessing", payoutService.count(null, "PROCESSING", q));
        request.setAttribute("countHold", payoutService.count(null, "ON_HOLD", q));
        request.setAttribute("countCompleted", payoutService.count(null, "COMPLETED", q));
        request.setAttribute("q", q);
        request.setAttribute("status", status);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("today", LocalDate.now().toString());
        request.setAttribute("weekAgo", LocalDate.now().minusDays(6).toString());
        request.getRequestDispatcher("/views/admin/payouts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User admin = AdminGuard.requireAdmin(request, response);
        if (admin == null) {
            return;
        }
        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        try {
            switch (action) {
                case "generate":
                    generate(request);
                    break;
                case "complete": {
                    VendorPayout p = payoutService.markCompleted(id(request), admin.getId());
                    AdminGuard.flash(request, "Đã xác nhận chuyển tiền kỳ " + p.getPayoutCode() + " cho "
                            + p.getShopName() + " (" + p.getBankName() + " " + p.getMaskedAccount() + ").");
                    break;
                }
                case "hold":
                    payoutService.hold(id(request));
                    AdminGuard.flash(request, "Đã tạm giữ kỳ quyết toán.");
                    break;
                case "release":
                    payoutService.release(id(request));
                    AdminGuard.flash(request, "Đã gỡ tạm giữ, kỳ quyết toán chuyển về trạng thái chờ chi trả.");
                    break;
                case "delete":
                    payoutService.delete(id(request));
                    AdminGuard.flash(request, "Đã hủy kỳ quyết toán chưa chi trả. Bạn có thể tạo lại kỳ mới.");
                    break;
                default:
                    AdminGuard.flashError(request, "Thao tác không hợp lệ!");
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            AdminGuard.flashError(request, ex.getMessage());
        } catch (Exception ex) {
            AdminGuard.flashError(request, "Không thể xử lý do lỗi hệ thống. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/payouts");
    }

    private void generate(HttpServletRequest request) throws Exception {
        LocalDate start;
        LocalDate end;
        try {
            start = LocalDate.parse(request.getParameter("startDate"));
            end = LocalDate.parse(request.getParameter("endDate"));
        } catch (DateTimeParseException | NullPointerException ex) {
            throw new IllegalArgumentException("Vui lòng chọn ngày bắt đầu và ngày kết thúc hợp lệ!");
        }
        String shop = request.getParameter("shopId");
        Long shopId = (shop == null || shop.isEmpty() || "ALL".equals(shop)) ? null : Long.valueOf(shop);

        PayoutGenerationResult result = payoutService.generateSettlement(start, end, shopId);
        StringBuilder msg = new StringBuilder("Đã tạo " + result.getCreated() + " kỳ quyết toán.");
        if (!result.getSkipped().isEmpty()) {
            msg.append(" Bỏ qua: ").append(String.join("; ", result.getSkipped())).append('.');
        }
        if (result.getCreated() > 0) {
            AdminGuard.flash(request, msg.toString());
        } else {
            AdminGuard.flashError(request, msg.toString());
        }
    }

    private long id(HttpServletRequest request) {
        try {
            return Long.parseLong(request.getParameter("payoutId"));
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Mã kỳ quyết toán không hợp lệ!");
        }
    }

    private int parse(String s) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ex) {
            return 1;
        }
    }
}
