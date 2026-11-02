package filter;

import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(filterName = "CartCsrfFilter", urlPatterns = {
    "", "/home", "/products", "/search", "/detail", "/cart", "/cart/*", "/checkout", "/order/place"
})
public class CartCsrfFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        String token;
        synchronized (session) {
            token = (String) session.getAttribute("cartCsrfToken");
            if (token == null) {
                token = UUID.randomUUID().toString();
                session.setAttribute("cartCsrfToken", token);
            }
        }
        if ("POST".equals(req.getMethod()) && !token.equals(req.getParameter("csrfToken"))) {
            session.setAttribute("checkoutError",
                    "Phiên làm việc đã thay đổi. Vui lòng kiểm tra lại thông tin và thực hiện thao tác lần nữa!");
            String servletPath = req.getServletPath();
            String safePath = "/order/place".equals(servletPath) || "/checkout".equals(servletPath)
                    ? "/checkout" : "/cart";
            res.sendRedirect(req.getContextPath() + safePath);
            return;
        }
        chain.doFilter(request, response);
    }
}
