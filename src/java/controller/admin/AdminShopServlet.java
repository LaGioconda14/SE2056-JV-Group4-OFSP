package controller.admin;

import dao.AdminManagementDAO;
import model.User;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Quản lý gian hàng & hồ sơ đăng ký (Admin).
 * GET  /admin/shops?status=ALL|ACTIVE|PENDING_KYC|SUSPENDED|REJECTED  -> hiển thị
 * POST /admin/shops  action = approve | reject | suspend | unlock | approveAll
 */
@WebServlet(name = "AdminShopServlet", urlPatterns = {"/admin/shops"})
public class AdminShopServlet extends HttpServlet {

    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Handle flash session messages
        HttpSession session = request.getSession();
        if (session.getAttribute("successMessage") != null) {
            request.setAttribute("flashMessage", session.getAttribute("successMessage"));
            request.setAttribute("flashType", "success");
            session.removeAttribute("successMessage");
        }
        if (session.getAttribute("errorMessage") != null) {
            request.setAttribute("flashMessage", session.getAttribute("errorMessage"));
            request.setAttribute("flashType", "danger");
            session.removeAttribute("errorMessage");
        }

        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = request.getParameter("tab");
        }
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }
        status = status.trim().toUpperCase();
        if ("PENDING".equals(status)) {
            status = "PENDING_KYC";
        }

        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "ALL";
        }
        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        // Flash message sau thao tác
        HttpSession session = request.getSession();
        Object flash = session.getAttribute("shopAdminMsg");
        if (flash != null) {
            request.setAttribute("flashMessage", flash);
            request.setAttribute("flashType", session.getAttribute("shopAdminMsgType"));
            session.removeAttribute("shopAdminMsg");
            session.removeAttribute("shopAdminMsgType");
        }

        List<Map<String, Object>> shops = dao.getShopsList(status, type, null, search);

        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedType", type);
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("shopStats", dao.getShopStats());
        request.setAttribute("businessTypes", dao.getShopBusinessTypes());
        request.setAttribute("shopsList", shops);
        // JSON cho modal chi tiết (Gson tự escape ký tự HTML nên nhúng vào <script> an toàn)
        request.setAttribute("shopsJson", gson.toJson(shops));

        request.getRequestDispatcher("/views/admin/shops.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("account");
        if (admin == null) {
            admin = (User) session.getAttribute("user");
        }
        int adminId = (admin != null) ? admin.getId() : 1;

        String action = request.getParameter("action");
        String tab = request.getParameter("tab");
        if (tab == null || !tab.matches("ALL|ACTIVE|PENDING_KYC|SUSPENDED|REJECTED")) {
            tab = "ALL";
        }

        boolean ok = false;
        String message;
        try {
            if ("approveAll".equals(action)) {
                int n = dao.approveAllPending(adminId);
                ok = n > 0;
                message = ok ? "Đã duyệt " + n + " hồ sơ đang chờ." : "Không có hồ sơ nào đang chờ duyệt.";
            } else {
                int reqId = Integer.parseInt(request.getParameter("id"));
                String reason = request.getParameter("reason");
                reason = reason == null ? "" : reason.trim();

                switch (action == null ? "" : action) {
                    case "approve":
                        ok = dao.updateRequestStatus(reqId, "APPROVED", null, adminId);
                        message = ok ? "Đã duyệt gian hàng và gửi thông báo cho chủ shop."
                                     : "Không duyệt được (hồ sơ đã được xử lý hoặc không tồn tại).";
                        break;
                    case "reject":
                        if (reason.isEmpty()) {
                            message = "Vui lòng nhập lý do từ chối.";
                        } else {
                            ok = dao.updateRequestStatus(reqId, "REJECTED", reason, adminId);
                            message = ok ? "Đã từ chối hồ sơ và gửi lý do cho chủ shop."
                                         : "Không từ chối được (hồ sơ đã được xử lý hoặc không tồn tại).";
                        }
                        break;
                    case "suspend":
                        if (reason.isEmpty()) {
                            message = "Vui lòng nhập lý do tạm khóa.";
                        } else {
                            ok = dao.suspendShop(reqId, reason, adminId);
                            message = ok ? "Đã tạm khóa gian hàng và gửi thông báo cho chủ shop."
                                         : "Không tạm khóa được (shop chưa được duyệt hoặc đã bị khóa).";
                            if (ok) {
                                tab = "SUSPENDED";
                            }
                        }
                        break;
                    case "unlock":
                        ok = dao.unlockShop(reqId, adminId);
                        message = ok ? "Đã mở khóa gian hàng và gửi thông báo cho chủ shop."
                                     : "Không mở khóa được (shop không ở trạng thái tạm khóa).";
                        break;
                    default:
                        message = "Thao tác không hợp lệ.";
                }
            }
        } catch (NumberFormatException e) {
            message = "Mã hồ sơ không hợp lệ.";
        } catch (Exception e) {
            e.printStackTrace();
            message = "Có lỗi xảy ra: " + e.getMessage();
        }

        session.setAttribute("shopAdminMsg", message);
        session.setAttribute("shopAdminMsgType", ok ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/shops?status=" + tab);
    }
}