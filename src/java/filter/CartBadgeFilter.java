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
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

@WebFilter(filterName = "CartBadgeFilter", urlPatterns = {
    "", "/home", "/products", "/search", "/detail", "/cart", "/cart/*"
})
public class CartBadgeFilter implements Filter {

    private final ICartService cartService = new CartServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user != null) {
            try {
                session.setAttribute("cartSize",
                        cartService.getCart((long) user.getId()).getTotalQuantity());
            } catch (RuntimeException ex) {
                session.setAttribute("cartSize", 0);
            }
        } else if (session != null) {
            session.removeAttribute("cartSize");
        }

        chain.doFilter(request, response);
    }
}
