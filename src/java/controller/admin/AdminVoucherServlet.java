package controller.admin;

import controller.shop.ShopVoucherServlet;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.dto.promotion.Voucher;

@WebServlet(name = "AdminVoucherServlet", urlPatterns = {"/admin/vouchers"})
public class AdminVoucherServlet extends ShopVoucherServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if ("new".equals(action)) {
            Voucher voucher = new Voucher();
            long now = System.currentTimeMillis();
            voucher.setDiscountType("PERCENTAGE");
            voucher.setStartDate(new Timestamp(now));
            voucher.setEndDate(new Timestamp(now + 30L * 24 * 3600 * 1000));
            showForm(request, response, voucher, false);
            return;
        }
        if ("edit".equals(action) || "usage".equals(action)) {
            Integer id = parseInt(request.getParameter("id"));
            Voucher voucher = id == null ? null : voucherService.findPlatformById(id);
            if (voucher == null) {
                flash(request, false, "Không tìm thấy voucher toàn sàn.");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
                return;
            }
            if ("usage".equals(action)) {
                request.setAttribute("voucher", voucher);
                request.setAttribute("usageStats", voucherService.getUsageStats(id));
                request.setAttribute("usageList", voucherService.getUsageHistory(id, 200));
                request.setAttribute("adminMode", Boolean.TRUE);
                request.getRequestDispatcher("/views/shop/marketing/voucher-usage.jsp").forward(request, response);
                return;
            }
            if (voucher.getTerminatedAt() != null) {
                flash(request, false, "Voucher đã kết thúc sớm nên không thể chỉnh sửa.");
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
                return;
            }
            showForm(request, response, voucher, true);
            return;
        }
        String tab = request.getParameter("tab");
        if (tab == null || !tab.matches("ALL|ONGOING|UPCOMING|PAUSED|FINISHED")) tab = "ALL";
        String q = trimToNull(request.getParameter("q"));
        ensureCsrf(request);
        request.setAttribute("vouchers", paginate(request, voucherService.listPlatform(tab, q), LIST_PAGE_SIZE));
        request.setAttribute("tabCounts", voucherService.countPlatformByTab());
        request.setAttribute("summary", voucherService.getPlatformSummary());
        request.setAttribute("tab", tab);
        request.setAttribute("q", q == null ? "" : q);
        request.setAttribute("adminMode", Boolean.TRUE);
        request.getRequestDispatcher("/views/shop/marketing/vouchers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        String token = session == null ? null : (String) session.getAttribute("adminVoucherCsrf");
        if (token == null || !token.equals(request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String action = request.getParameter("action");
        if ("toggle".equals(action) || "terminate".equals(action)) {
            Integer id = parseInt(request.getParameter("id"));
            boolean ok = id != null && ("toggle".equals(action)
                    ? voucherService.setPlatformActive(id, "1".equals(request.getParameter("active")))
                    : voucherService.terminatePlatform(id));
            flash(request, ok, ok ? "Đã cập nhật trạng thái voucher toàn sàn." : "Không thay đổi được voucher toàn sàn.");
            response.sendRedirect(listUrl(request, "/admin/vouchers"));
            return;
        }
        if (!"save".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        Integer id = parseInt(request.getParameter("couponId"));
        if (request.getParameter("couponId") != null && (id == null || id <= 0)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        boolean editing = id != null && id > 0;
        Voucher existing = editing ? voucherService.findPlatformById(id) : null;
        if (editing && (existing == null || existing.getTerminatedAt() != null)) {
            flash(request, false, "Voucher không tồn tại hoặc đã kết thúc, không thể chỉnh sửa.");
            response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            return;
        }
        Voucher voucher = readForm(request, existing);
        voucher.setShopId(null);
        voucher.setSponsorType("PLATFORM");
        voucher.setAppliesTo("ALL");
        voucher.setProductIds(Collections.emptyList());
        String error = validate(voucher, editing, existing);
        if (error != null) {
            request.setAttribute("formError", error);
            showForm(request, response, voucher, editing);
            return;
        }
        boolean saved = editing ? voucherService.updatePlatform(voucher) : voucherService.createPlatform(voucher) > 0;
        if (!saved) {
            request.setAttribute("formError", "Không thể lưu voucher. Vui lòng kiểm tra dữ liệu và cấu trúc bảng coupons.");
            showForm(request, response, voucher, editing);
            return;
        }
        session.setAttribute("successMessage", (editing ? "Đã cập nhật voucher toàn sàn " : "Đã tạo voucher toàn sàn ") + voucher.getCode() + ".");
        response.sendRedirect(request.getContextPath() + "/admin/vouchers");
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, Voucher voucher, boolean editing)
            throws ServletException, IOException {
        ensureCsrf(request);
        request.setAttribute("voucher", voucher);
        request.setAttribute("mode", editing ? "edit" : "create");
        request.setAttribute("adminMode", Boolean.TRUE);
        request.getRequestDispatcher("/views/shop/marketing/voucher-form.jsp").forward(request, response);
    }

    private void ensureCsrf(HttpServletRequest request) {
        HttpSession session = request.getSession();
        if (session.getAttribute("adminVoucherCsrf") == null) {
            session.setAttribute("adminVoucherCsrf", UUID.randomUUID().toString());
        }
    }
}

