package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Shop;
import dao.ShopDAO;
import service.IUserService;
import service.impl.UserServiceImpl;

/**
 * Controller handling User Login and Remember Me Cookies.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        clearRememberPasswordCookie(request, response);
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User loggedUser = (User) session.getAttribute("user");
            redirectByRole(loggedUser, request, response);
            return;
        }

        if (session != null) {
            String errorMsg = (String) session.getAttribute("errorMessage");
            if (errorMsg != null) {
                request.setAttribute("errorMessage", errorMsg);
                session.removeAttribute("errorMessage");
            }
            String successMsg = (String) session.getAttribute("successMessage");
            if (successMsg != null) {
                request.setAttribute("successMessage", successMsg);
                session.removeAttribute("successMessage");
            }
        }

        // Remember the email only; never store a password in a cookie.
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("c_email".equals(c.getName())) {
                    request.setAttribute("rememberEmail", c.getValue());
                }
                if ("c_rem".equals(c.getName()) && "1".equals(c.getValue())) {
                    request.setAttribute("rememberChecked", "checked");
                }
            }
        }

        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        clearRememberPasswordCookie(request, response);
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        User user;
        try {
            user = userService.login(email, password);
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Rotate an existing session ID after authentication to prevent session fixation.
        if (request.getSession(false) != null) {
            request.changeSessionId();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userfullname", user.getFullName());
        session.setAttribute("email", user.getEmail());

        // Remember the email for seven days; do not persist the password.
        int cookieMaxAge = (remember != null) ? (7 * 24 * 60 * 60) : 0;
        addCookie(request, response, "c_email", user.getEmail(), cookieMaxAge);
        addCookie(request, response, "c_rem", remember != null ? "1" : "", cookieMaxAge);
        // CUSTOMER (and any default role) is redirected once through the shared role handler.
        redirectByRole(user, request, response);
    }

    private void redirectByRole(User user, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String role = user == null ? null : user.getRole();
        String destination;
        if ("SHOP_OWNER".equalsIgnoreCase(role)) {
            destination = "/shop/products";
        } else if ("ADMIN".equalsIgnoreCase(role)) {
            destination = "/admin/dashboard";
        } else {
            destination = "/home";
        }
        response.sendRedirect(request.getContextPath() + destination);
    }

    private void clearRememberPasswordCookie(HttpServletRequest request, HttpServletResponse response) {
        Cookie passwordCookie = new Cookie("c_pass", "");
        passwordCookie.setMaxAge(0);
        passwordCookie.setPath(cookiePath(request));
        passwordCookie.setHttpOnly(true);
        passwordCookie.setSecure(request.isSecure());
        response.addCookie(passwordCookie);
    }

    private void addCookie(HttpServletRequest request, HttpServletResponse response,
            String name, String value, int maxAge) {
        Cookie cookie = new Cookie(name, value == null ? "" : value);
        cookie.setMaxAge(maxAge);
        cookie.setPath(cookiePath(request));
        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        response.addCookie(cookie);
    }

    private String cookiePath(HttpServletRequest request) {
        String contextPath = request.getContextPath();
        return contextPath == null || contextPath.isEmpty() ? "/" : contextPath;
    }
}
