package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import model.Refund;
import model.User;
import service.IRefundService;
import service.impl.RefundServiceImpl;
import util.AdminGuard;

/**
 * Hoàn tiền & hoàn tiền một phần (Admin / System).
 *
 * GET  /admin/refunds          : sổ hoàn tiền + khiếu nại chờ phán quyết
 * POST /admin/refunds          : Admin tạo khoản hoàn tiền thủ công (toàn phần hoặc một phần)
 * POST /admin/disputes/resolve : phán quyết khiếu nại (hoàn 100% / hoàn một phần / bác bỏ / yêu cầu giải trình).
 *                                Khiếu nại gồm cả loại tự sinh khi shipper ghi nhận khách từ chối nhận hàng.
 * Hoàn tiền tự động khi hủy đơn nằm ở RefundServiceImpl.autoRefundOnCancel (gọi từ luồng hủy đơn).
 */
@WebServlet(name = "AdminRefundServlet", urlPatterns = {"/admin/refunds", "/admin/disputes/resolve"})
public class AdminRefundServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;
    private static final List<String> SOURCES = Arrays.asList("ALL", "CANCEL", "DISPUTE", "MANUAL");

    private final IRefundService refundService = new RefundServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (AdminGuard.requireAdmin(request, response) == null) {
            return;
        }
        String q = request.getParameter("q") == null ? "" : request.getParameter("q").trim();
        String source = request.getParameter("source") == null ? "ALL" : request.getParameter("source").trim().toUpperCase();
        if (!SOURCES.contains(source)) {
            source = "ALL";
        }

        int totalItems = refundService.count(q, source);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        int page = Math.min(Math.max(1, parse(request.getParameter("page"))), totalPages);

        request.setAttribute("refunds", refundService.search(q, source, page, PAGE_SIZE));
        request.setAttribute("summary", refundService.getSummary());
        request.setAttribute("pendingDisputes", refundService.listPendingDisputes());
        request.setAttribute("q", q);
        request.setAttribute("source", source);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.getRequestDispatcher("/views/admin/refunds.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User admin = AdminGuard.requireAdmin(request, response);
        if (admin == null) {
            return;
        }
        if (request.getServletPath().endsWith("/disputes/resolve")) {
            resolve(request, response, admin);
        } else {
            manualRefund(request, response, admin);
        }
    }

    private void manualRefund(HttpServletRequest request, HttpServletResponse response, User admin)
            throws IOException {
        String ctx = request.getContextPath();
        try {
            BigDecimal amount = AdminGuard.parseMoney(request.getParameter("amount"));
            Refund r = refundService.issueManualRefund(request.getParameter("subOrderCode"), amount,
                    request.getParameter("reason"), admin.getId());
            AdminGuard.flash(request, "Đã hoàn " + money(r.getAmount()) + "đ cho đơn " + r.getSubOrderCode()
                    + " (" + r.getTypeLabel().toLowerCase() + "). Mã hoàn tiền: " + r.getRefundCode());
        } catch (IllegalArgumentException | IllegalStateException ex) {
            AdminGuard.flashError(request, ex.getMessage());
        } catch (Exception ex) {
            AdminGuard.flashError(request, "Không thể hoàn tiền do lỗi hệ thống. Vui lòng thử lại!");
        }
        response.sendRedirect(ctx + "/admin/refunds");
    }

    private void resolve(HttpServletRequest request, HttpServletResponse response, User admin)
            throws IOException {
        String ctx = request.getContextPath();
        String back = ctx + "/admin/refunds";
        String code = request.getParameter("disputeCode");
        String decision = request.getParameter("decision");
        String note = request.getParameter("note");
        try {
            if ("REQUEST_INFO".equalsIgnoreCase(decision)) {
                refundService.requestMoreInfo(code, note, admin.getId());
                AdminGuard.flash(request, "Đã gửi yêu cầu giải trình tới gian hàng cho khiếu nại " + code + ".");
            } else {
                Refund r = refundService.resolveDispute(code, decision,
                        AdminGuard.parseMoney(request.getParameter("amount")), note, admin.getId());
                if (r == null) {
                    AdminGuard.flash(request, "Đã bác bỏ khiếu nại " + code + ". Gian hàng không bị trừ tiền.");
                } else {
                    AdminGuard.flash(request, "Đã phán quyết khiếu nại " + code + ": hoàn " + money(r.getAmount())
                            + "đ cho khách (" + r.getTypeLabel().toLowerCase() + "). Mã hoàn tiền: " + r.getRefundCode());
                }
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            AdminGuard.flashError(request, ex.getMessage());
        } catch (Exception ex) {
            AdminGuard.flashError(request, "Không thể xử lý khiếu nại do lỗi hệ thống. Vui lòng thử lại!");
        }
        response.sendRedirect(back);
    }

    private int parse(String s) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ex) {
            return 1;
        }
    }

    private String money(BigDecimal v) {
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(v);
    }
}
