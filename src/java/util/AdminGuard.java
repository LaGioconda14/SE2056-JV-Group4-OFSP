package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

/** Kiểm tra quyền cho các trang quản trị mới (ADMIN hoặc STAFF). */
public final class AdminGuard {

    private AdminGuard() {
    }

    /** @return user đã đăng nhập với quyền ADMIN/STAFF, hoặc null nếu đã chuyển hướng/từ chối. */
    public static User requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản quản trị!");
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        String role = user.getRole() == null ? "" : user.getRole().toUpperCase();
        if (!"ADMIN".equals(role) && !"STAFF".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này");
            return null;
        }
        return user;
    }

    public static void flash(HttpServletRequest request, String message) {
        request.getSession(true).setAttribute("adminFlash", message);
    }

    public static void flashError(HttpServletRequest request, String message) {
        request.getSession(true).setAttribute("adminError", message);
    }

    /** Chỉ giữ lại chữ số để đọc số tiền VND người dùng nhập (150.000 / 150,000 / 150000). */
    public static java.math.BigDecimal parseMoney(String raw) {
        if (raw == null) {
            return null;
        }
        String digits = raw.replaceAll("[^0-9]", "");
        return digits.isEmpty() ? null : new java.math.BigDecimal(digits);
    }
}
