package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String viewUserIdStr = request.getParameter("viewUserId");
        if (viewUserIdStr != null && !viewUserIdStr.trim().isEmpty()) {
            try {
                long viewUserId = Long.parseLong(viewUserIdStr.trim());
                Map<String, Object> detail = dao.getUserDetail(viewUserId);
                if (detail != null) {
                    request.setAttribute("userDetail", detail);
                }
            } catch (NumberFormatException ignored) {}
        }

        // Handle flash messages from session
        HttpSession session = request.getSession();
        if (session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }
        if (session.getAttribute("errorMessage") != null) {
            request.setAttribute("errorMessage", session.getAttribute("errorMessage"));
            session.removeAttribute("errorMessage");
        }

        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            role = "ALL";
        }
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }
        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        request.setAttribute("selectedRole", role.toUpperCase());
        request.setAttribute("selectedStatus", status.toUpperCase());
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("roleCounts", dao.getUserRoleCounts());
        request.setAttribute("usersList", dao.getUsersList(role, status, search));
        request.getRequestDispatcher("/views/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        String redirectRole = request.getParameter("currentRole");
        String redirectStatus = request.getParameter("currentStatus");
        String redirectSearch = request.getParameter("currentSearch");

        if ("changeStatus".equalsIgnoreCase(action) || "toggleStatus".equalsIgnoreCase(action)) {
            String userIdStr = request.getParameter("userId");
            String newStatus = request.getParameter("newStatus");
            String decisionReason = request.getParameter("decisionReason");

            if (userIdStr == null || userIdStr.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Mã người dùng không hợp lệ!");
            } else if (newStatus == null || (!"ACTIVE".equalsIgnoreCase(newStatus) && !"BLOCKED".equalsIgnoreCase(newStatus) && !"INACTIVE".equalsIgnoreCase(newStatus))) {
                session.setAttribute("errorMessage", "Trạng thái tài khoản không hợp lệ!");
            } else if (decisionReason == null || decisionReason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập đầy đủ lý do quản trị (Decision Reason) để lưu vết lịch sử hệ thống!");
            } else {
                try {
                    long userId = Long.parseLong(userIdStr.trim());
                    User currentUser = (User) session.getAttribute("user");
                    String adminIdentifier = currentUser != null 
                            ? (currentUser.getFullName() + " (" + currentUser.getEmail() + ")") 
                            : "Ban Quản Trị (admin@freshfruit.com)";

                    boolean updated = dao.updateUserStatus(userId, newStatus.toUpperCase(), decisionReason.trim(), adminIdentifier);
                    if (updated) {
                        String statusVn = "BLOCKED".equalsIgnoreCase(newStatus) ? "Khóa tài khoản" : ("ACTIVE".equalsIgnoreCase(newStatus) ? "Mở khóa thành công" : newStatus);
                        session.setAttribute("successMessage", "Đã " + statusVn + " cho tài khoản ID #" + userId + " (Lý do: " + decisionReason.trim() + ")");
                    } else {
                        session.setAttribute("errorMessage", "Không thể cập nhật trạng thái tài khoản. Vui lòng kiểm tra lại!");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Định dạng mã người dùng không đúng!");
                }
            }
        }

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/users?");
        if (redirectRole != null && !redirectRole.trim().isEmpty()) {
            redirectUrl.append("role=").append(URLEncoder.encode(redirectRole.trim(), StandardCharsets.UTF_8)).append("&");
        }
        if (redirectStatus != null && !redirectStatus.trim().isEmpty()) {
            redirectUrl.append("status=").append(URLEncoder.encode(redirectStatus.trim(), StandardCharsets.UTF_8)).append("&");
        }
        if (redirectSearch != null && !redirectSearch.trim().isEmpty()) {
            redirectUrl.append("search=").append(URLEncoder.encode(redirectSearch.trim(), StandardCharsets.UTF_8));
        }

        response.sendRedirect(redirectUrl.toString());
    }
}
