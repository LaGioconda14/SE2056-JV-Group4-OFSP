package filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;

/**
 * RBAC Filter protecting all Admin routes (/admin/*).
 * Strictly requires an active authenticated session with role 'ADMIN'.
 */
@WebFilter(filterName = "AdminAuthFilter", urlPatterns = {"/admin", "/admin/*"})
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Prevent client/proxy caching of protected admin views
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 1. Unauthenticated: Redirect to login
        if (user == null) {
            httpRequest.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập với tài khoản Quản trị viên!");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // 2. Inactive account: Invalidate session and redirect to login
        if (!user.isActive()) {
            if (session != null) {
                session.invalidate();
            }
            httpRequest.getSession(true).setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên!");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // 3. Unauthorized role (not ADMIN): Reject with HTTP 403 Forbidden
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Quản trị viên!");
            return;
        }

        // Authorized ADMIN user
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
