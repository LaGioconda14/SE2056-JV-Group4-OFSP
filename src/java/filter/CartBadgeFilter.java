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
import service.impl.CartServiceImpl;

@WebFilter(filterName = "CartBadgeFilter", urlPatterns = {
    "", "/home", "/products", "/search", "/detail", "/cart", "/cart/*", "/checkout", "/order/*", "/profile", "/profile/*", "/wishlist"
})
public class CartBadgeFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CartBadgeFilter.class.getName());
    private final ICartService cartService = new CartServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user != null && user.isActive()) {
            try {
                // Badge chỉ đếm dòng hiện có, không được tạo cart hoặc reconcile dữ liệu ngoài trang /cart.
                session.setAttribute("cartSize", cartService.getCartItemCount((long) user.getId()));
            } catch (RuntimeException ex) {
                LOGGER.log(Level.WARNING, "Cannot load cart badge", ex);
                if (session.getAttribute("cartSize") == null) {
                    session.setAttribute("cartSize", 0);
                }
            }
        } else if (session != null) {
            session.removeAttribute("cartSize");
        }

        chain.doFilter(request, response);
    }
}
