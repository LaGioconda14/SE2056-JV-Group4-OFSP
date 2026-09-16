package filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

/**
 * Authentication Filter to protect secure resources (e.g. /change-password).
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/change-password"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Prevent browser caching of sensitive pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Not logged in -> redirect to login with error message
            httpRequest.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để truy cập tính năng này!");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        if (!user.isActive()) {
            // Account has been locked -> invalidate session and redirect
            if (session != null) {
                session.invalidate();
            }
            httpRequest.getSession(true).setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên!");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // Authenticated -> continue request
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}

