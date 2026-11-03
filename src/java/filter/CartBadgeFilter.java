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
import model.User;
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

        // 3. Nạp cartSize và wishlistCount cho người dùng đăng nhập
        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user != null && user.isActive()) {
            try {
                int cartSize = cartService.getCartItemCount((long) user.getId());
                session.setAttribute("cartSize", cartSize);
                httpRequest.setAttribute("cartSize", cartSize);
            } catch (RuntimeException ex) {
                LOGGER.log(Level.WARNING, "Cannot load cart badge in CartBadgeFilter", ex);
                if (session.getAttribute("cartSize") == null) {
                    session.setAttribute("cartSize", 0);
                }
                httpRequest.setAttribute("cartSize", 0);
            }

            try {
                int wlCount = wishlistService.count((long) user.getId());
                session.setAttribute("wishlistCount", wlCount);
                httpRequest.setAttribute("wishlistCount", wlCount);
            } catch (Exception ex) {
                httpRequest.setAttribute("wishlistCount", 0);
            }
        } else {
            if (session != null) {
                session.removeAttribute("cartSize");
            }
            httpRequest.setAttribute("cartSize", 0);
            httpRequest.setAttribute("wishlistCount", 0);
        }

        chain.doFilter(request, response);
    }
}
