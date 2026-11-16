package controller.auth;

import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
import service.IUserService;
import service.impl.UserServiceImpl;
import util.SellerSessionUtil;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectByUserRole((User) session.getAttribute("user"), request, response);
            return;
        }

        transferFlashMessages(session, request);
        populateRememberMeCookies(request);
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        try {
            User user = userService.login(email, password);

            if (request.getSession(false) != null) {
                request.changeSessionId();
            }
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());

            handleRememberMeCookies(request, response, email, remember);

            if ("SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
                SellerSessionUtil.initShopSession(session, user.getId());
            }

            redirectByUserRole(user, request, response);
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        }
    }

    private void transferFlashMessages(HttpSession session, HttpServletRequest request) {
        if (session == null) return;
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

    private void populateRememberMeCookies(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return;
        for (Cookie c : cookies) {
            if ("c_email".equals(c.getName())) {
                request.setAttribute("rememberEmail", URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8));
            } else if ("c_rem".equals(c.getName())) {
                request.setAttribute("rememberChecked", "checked");
            }
        }
    }

    private void handleRememberMeCookies(HttpServletRequest request, HttpServletResponse response, String email, String remember) {
        int maxAge = (remember != null) ? (7 * 24 * 60 * 60) : 0;
        String path = request.getContextPath().isEmpty() ? "/" : request.getContextPath();
        String safeEmail = (remember != null && email != null) ? URLEncoder.encode(email, StandardCharsets.UTF_8) : "";

        Cookie emailCookie = new Cookie("c_email", safeEmail);
        emailCookie.setMaxAge(maxAge);
        emailCookie.setPath(path);
        emailCookie.setHttpOnly(true);
        response.addCookie(emailCookie);

        Cookie remCookie = new Cookie("c_rem", (remember != null) ? "checked" : "");
        remCookie.setMaxAge(maxAge);
        remCookie.setPath(path);
        remCookie.setHttpOnly(true);
        response.addCookie(remCookie);
    }

    private void redirectByUserRole(User user, HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (user == null || user.getRole() == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (user.getRole().toUpperCase()) {
            case "ADMIN" -> response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            case "SHOP_OWNER" -> response.sendRedirect(request.getContextPath() + "/shop/dashboard");
            case "DRIVER" -> response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
            default -> response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
