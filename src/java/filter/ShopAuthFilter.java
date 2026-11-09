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
 * RBAC Filter protecting all Seller/Shop routes (/shop/*).
 * Strictly requires role 'SHOP_OWNER', while whitelisting public customer-facing
 * storefront paths (/shop/storefront, /shop/detail).
 */
@WebFilter(filterName = "ShopAuthFilter", urlPatterns = {"/shop/*"})
public class ShopAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String servletPath = httpRequest.getServletPath();
        String pathInfo = httpRequest.getPathInfo();
        String path = (servletPath != null ? servletPath : "") + (pathInfo != null ? pathInfo : "");
        String lowerPath = path.toLowerCase();

        // 1. Whitelist public customer-facing storefront product/shop viewing routes
        if (isStorefrontPath(lowerPath)) {
            chain.doFilter(request, response);
            return;
        }

        // Prevent client/proxy caching of seller management back-office pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 2. Unauthenticated: Redirect to login
        if (user == null) {
            httpRequest.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập với tài khoản Chủ gian hàng!");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // 3. Inactive account: Invalidate session and redirect to login
        if (!user.isActive()) {
            if (session != null) {
                session.invalidate();
            }
            httpRequest.getSession(true).setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên!");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // 4. Unauthorized role (not SHOP_OWNER): Reject with HTTP 403 Forbidden
        if (!"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập Kênh Người Bán!");
            return;
        }

        // Authorized SHOP_OWNER user
        chain.doFilter(request, response);
    }

    /**
     * Check if the requested path is a public storefront route.
     * Public routes include:
     * - /shop/storefront, /shop/storefront/*
     * - /shop/detail, /shop/detail/*
     */
    private boolean isStorefrontPath(String lowerPath) {
        if (lowerPath == null || lowerPath.isEmpty()) {
            return false;
        }
        return lowerPath.equals("/shop/storefront")
                || lowerPath.startsWith("/shop/storefront/")
                || lowerPath.equals("/shop/detail")
                || lowerPath.startsWith("/shop/detail/");
    }

    @Override
    public void destroy() {
    }
}
