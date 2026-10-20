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
import service.IOrderFulfillmentService;
import service.IUserService;
import service.impl.OrderFulfillmentServiceImpl;
import service.impl.UserServiceImpl;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (isLoggedIn(session)) {
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

        User user;
        try {
            user = userService.login(email, password);
        } catch (Exception ex) {
            handleLoginError(request, response, email, ex.getMessage());
            return;
        }

        HttpSession session = request.getSession(true);
        initUserSession(session, user);
        handleRememberMeCookies(request, response, email, password, remember);

        if ("SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            initShopSession(session, user.getId());
        }

        redirectByUserRole(user, request, response);
    }

    private boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute("user") != null;
    }

    private void transferFlashMessages(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
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
        if (cookies == null) {
            return;
        }
        for (Cookie c : cookies) {
            if ("c_email".equals(c.getName())) {
                request.setAttribute("rememberEmail", c.getValue());
            } else if ("c_pass".equals(c.getName())) {
                request.setAttribute("rememberPassword", c.getValue());
            } else if ("c_rem".equals(c.getName())) {
                request.setAttribute("rememberChecked", "checked");
            }
        }
    }

    private void handleLoginError(HttpServletRequest request, HttpServletResponse response,
            String email, String errorMessage) throws ServletException, IOException {
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("email", email);
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    private void initUserSession(HttpSession session, User user) {
        session.setAttribute("user", user);
        session.setAttribute("userfullname", user.getFullName());
        session.setAttribute("email", user.getEmail());
    }

    private void handleRememberMeCookies(HttpServletRequest request, HttpServletResponse response,
            String email, String password, String remember) {
        int cookieMaxAge = (remember != null) ? (7 * 24 * 60 * 60) : 0;
        String contextPath = request.getContextPath().isEmpty() ? "/" : request.getContextPath();

        addCookie(response, "c_email", (remember != null) ? email : "", cookieMaxAge, contextPath);
        addCookie(response, "c_pass", (remember != null) ? password : "", cookieMaxAge, contextPath);
        addCookie(response, "c_rem", (remember != null) ? "checked" : "", cookieMaxAge, contextPath);
    }

    private void addCookie(HttpServletResponse response, String name, String value, int maxAge, String path) {
        Cookie cookie = new Cookie(name, value);
        cookie.setMaxAge(maxAge);
        cookie.setPath(path);
        response.addCookie(cookie);
    }

    private void initShopSession(HttpSession session, int userId) {
        try {
            Shop shop = shopDAO.getShopByOwnerId(userId);
            if (shop != null) {
                session.setAttribute("shopId", shop.getShopId());
                session.setAttribute("shopName", shop.getShopName());
                session.setAttribute("shopLogo", shop.getLogoUrl());
                session.setAttribute("shopObj", shop);
                session.setAttribute("shop", shop);
                session.setAttribute("shopStatus", shop.getStatus());

                IOrderFulfillmentService fulfillmentService = new OrderFulfillmentServiceImpl();
                int countAll = fulfillmentService.countSubOrdersByShop(shop.getShopId(), null);
                session.setAttribute("shopSubOrdersCount", countAll);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void redirectByUserRole(User user, HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (user == null || user.getRole() == null) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        switch (user.getRole().toUpperCase()) {
            case "ADMIN":
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                break;
            case "SHOP_OWNER":
                response.sendRedirect(request.getContextPath() + "/shop/products");
                break;
            case "DRIVER":
                response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                break;
        }
    }
}