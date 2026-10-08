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

@WebFilter(filterName = "CartCsrfFilter", urlPatterns = {"/cart", "/cart/*"})
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
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }
        chain.doFilter(request, response);
    }
}
