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
import model.entity.user.User;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users", "/admin/users/assign-role", "/admin/users/invite"})
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

        String servletPath = request.getServletPath();
        if (action == null || action.trim().isEmpty()) {
            if ("/admin/users/assign-role".equalsIgnoreCase(servletPath)) {
                action = "assignRole";
            } else if ("/admin/users/invite".equalsIgnoreCase(servletPath)) {
                action = "invite";
            }
        }

        String redirectRole = request.getParameter("currentRole");
        String redirectStatus = request.getParameter("currentStatus");
        String redirectSearch = request.getParameter("currentSearch");

        if ("assignRole".equalsIgnoreCase(action)) {
            String userIdStr = request.getParameter("userId");
            String newRole = request.getParameter("newRole");

            if (userIdStr == null || userIdStr.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Mã người dùng không hợp lệ!");
            } else if (newRole == null || newRole.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng chọn vai trò hệ thống!");
            } else {
                try {
                    long userId = Long.parseLong(userIdStr.trim());
                    User currentUser = (User) session.getAttribute("user");
                    Long currentUserId = (currentUser != null) ? currentUser.getUserId() : null;

                    if (currentUserId != null && currentUserId == userId && !"ADMIN".equalsIgnoreCase(newRole)) {
                        session.setAttribute("errorMessage", "Bạn không thể tự hạ quyền vai trò của chính mình!");
                    } else {
                        boolean updated = dao.updateUserRole(userId, newRole);
                        if (updated) {
                            session.setAttribute("successMessage", "Cập nhật quyền thành công! Tài khoản ID #" + userId + " hiện có vai trò: " + newRole.toUpperCase());
                        } else {
                            session.setAttribute("errorMessage", "Không thể cập nhật quyền người dùng. Vui lòng thử lại!");
                        }
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Định dạng mã người dùng không đúng!");
                }
            }
        } else if ("invite".equalsIgnoreCase(action)) {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String roleCode = request.getParameter("roleCode");

            if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập đầy đủ họ tên và email hợp lệ!");
            } else {
                boolean created = dao.inviteUser(fullName, email, roleCode);
                if (created) {
                    session.setAttribute("successMessage", "Thêm nhân sự mới thành công (" + email.trim() + ") với vai trò: " + (roleCode != null ? roleCode.toUpperCase() : "STAFF") + ". Mật khẩu mặc định: Password@123");
                } else {
                    session.setAttribute("errorMessage", "Không thể tạo tài khoản (Email có thể đã tồn tại trong hệ thống)!");
                }
            }
        } else if ("changeStatus".equalsIgnoreCase(action) || "toggleStatus".equalsIgnoreCase(action)) {
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
                    if (currentUser == null) {
                        currentUser = (User) session.getAttribute("account");
                    }
                    Long currentUserId = null;
                    if (currentUser != null) {
                        currentUserId = currentUser.getUserId();
                    } else if (session.getAttribute("userId") != null) {
                        Object uidObj = session.getAttribute("userId");
                        if (uidObj instanceof Number) {
                            currentUserId = ((Number) uidObj).longValue();
                        } else {
                            try {
                                currentUserId = Long.parseLong(uidObj.toString());
                            } catch (NumberFormatException ignored) {}
                        }
                    }

                    boolean isSelf = (currentUserId != null && currentUserId == userId);
                    if (!isSelf && currentUser != null && currentUser.getEmail() != null) {
                        Map<String, Object> targetUserDetail = dao.getUserDetail(userId);
                        if (targetUserDetail != null && targetUserDetail.get("user") instanceof Map) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> targetUserMap = (Map<String, Object>) targetUserDetail.get("user");
                            String targetEmail = (String) targetUserMap.get("email");
                            if (targetEmail != null && currentUser.getEmail().equalsIgnoreCase(targetEmail)) {
                                isSelf = true;
                            }
                        }
                    }

                    if (isSelf && !"ACTIVE".equalsIgnoreCase(newStatus)) {
                        session.setAttribute("errorMessage", "Bạn không thể tự khóa tài khoản của chính mình!");
                    } else {
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
