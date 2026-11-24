package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.user.User;
import service.ICartService;
import service.IProductService;
import service.IWishlistService;
import service.impl.CartServiceImpl;
import service.impl.ProductServiceImpl;
import service.impl.WishlistServiceImpl;

/**
 * Filter dùng chung cho toàn bộ giao diện khách hàng:
 * 1. Tự động nạp sẵn danh mục (categories & hierarchyCategories) vào request nếu chưa có,
 *    giúp các trang JSP / header / footer hiển thị menu mà không cần scriptlet gọi Service trực tiếp.
 * 2. Tự động nạp số lượng giỏ hàng (cartSize) và danh sách yêu thích (wishlistCount).
 */
@WebFilter(filterName = "CartBadgeFilter", urlPatterns = {"/*"})
public class CartBadgeFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CartBadgeFilter.class.getName());
    private final ICartService cartService = new CartServiceImpl();
    private final IProductService productService = new ProductServiceImpl();
    private final IWishlistService wishlistService = new WishlistServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String path = httpRequest.getServletPath();

        // Bỏ qua tài nguyên tĩnh để tối ưu hóa hiệu năng
        if (path != null && (path.startsWith("/assets/") || path.endsWith(".css") || path.endsWith(".js")
                || path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".jpeg")
                || path.endsWith(".svg") || path.endsWith(".woff2") || path.endsWith(".ico"))) {
            chain.doFilter(request, response);
            return;
        }

        // Bỏ qua các trang quản trị, gian hàng, shipper, api và xác thực (không cần nạp catalog badge)
        if (path != null && (path.startsWith("/admin") || path.startsWith("/shop")
                || path.startsWith("/shipper") || path.startsWith("/api")
                || path.equals("/login") || path.equals("/register")
                || path.equals("/forgot-password") || path.equals("/reset-password")
                || path.equals("/change-password"))) {
            chain.doFilter(request, response);
            return;
        }

        // 1. Tự động nạp categories vào request
        if (httpRequest.getAttribute("categories") == null) {
            Object cachedCategories = httpRequest.getServletContext().getAttribute("appCategories");
            if (cachedCategories == null) {
                try {
                    cachedCategories = productService.getAllCategories();
                    httpRequest.getServletContext().setAttribute("appCategories", cachedCategories);
                } catch (Exception ex) {
                    LOGGER.log(Level.WARNING, "Cannot load categories in CartBadgeFilter", ex);
                }
            }
            if (cachedCategories != null) {
                httpRequest.setAttribute("categories", cachedCategories);
            }
        }

        // 2. Tự động nạp hierarchyCategories vào request (cho mega-menu Header)
        if (httpRequest.getAttribute("hierarchyCategories") == null) {
            Object cachedHierarchy = httpRequest.getServletContext().getAttribute("appHierarchyCategories");
            if (cachedHierarchy == null) {
                try {
                    cachedHierarchy = productService.getHierarchyCategories();
                    httpRequest.getServletContext().setAttribute("appHierarchyCategories", cachedHierarchy);
                } catch (Exception ex) {
                    LOGGER.log(Level.WARNING, "Cannot load hierarchyCategories in CartBadgeFilter", ex);
                }
            }
            if (cachedHierarchy != null) {
                httpRequest.setAttribute("hierarchyCategories", cachedHierarchy);
            }
        }

        // 3. Nạp cartSize và wishlistCount cho người dùng đăng nhập (ưu tiên đọc từ Session cache)
        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user != null && user.isActive()) {
            // Badge là cache của số dòng giỏ hàng, không phải dữ liệu quyết định số lượng khi checkout.
            Object cachedCartSize = (session != null) ? session.getAttribute("cartSize") : null;
            if (cachedCartSize == null) {
                try {
                    int cartSize = cartService.getCartItemCount((long) user.getId());
                    session.setAttribute("cartSize", cartSize);
                    httpRequest.setAttribute("cartSize", cartSize);
                } catch (RuntimeException ex) {
                    LOGGER.log(Level.WARNING, "Cannot load cart badge in CartBadgeFilter", ex);
                    if (session != null) {
                        session.setAttribute("cartSize", 0);
                    }
                    httpRequest.setAttribute("cartSize", 0);
                }
            } else {
                httpRequest.setAttribute("cartSize", cachedCartSize);
            }

            Object cachedWishlistCount = (session != null) ? session.getAttribute("wishlistCount") : null;
            if (cachedWishlistCount == null) {
                try {
                    int wlCount = wishlistService.count((long) user.getId());
                    session.setAttribute("wishlistCount", wlCount);
                    httpRequest.setAttribute("wishlistCount", wlCount);
                } catch (Exception ex) {
                    if (session != null) {
                        session.setAttribute("wishlistCount", 0);
                    }
                    httpRequest.setAttribute("wishlistCount", 0);
                }
            } else {
                httpRequest.setAttribute("wishlistCount", cachedWishlistCount);
            }
        } else {
            if (session != null) {
                session.removeAttribute("cartSize");
                session.removeAttribute("wishlistCount");
            }
            httpRequest.setAttribute("cartSize", 0);
            httpRequest.setAttribute("wishlistCount", 0);
        }

        chain.doFilter(request, response);
    }
}
