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
import service.IUserService;
import service.impl.UserServiceImpl;

/**
 * Controller handling User Login and Remember Me Cookies.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        // If already logged in, redirect to home page
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        // Check for any flash message from session (e.g. from Filter or Reset Pass)
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

        // Check Remember Me cookies to auto-fill login form
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("c_email".equals(c.getName())) {
                    request.setAttribute("rememberEmail", c.getValue());
                }
                if ("c_pass".equals(c.getName())) {
                    request.setAttribute("rememberPassword", c.getValue());
                }
                if ("c_rem".equals(c.getName())) {
                    request.setAttribute("rememberChecked", "checked");
                }
            }
        }

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
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Authentication Successful -> Store session
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);

        // Process Remember Me Cookies (Expires in 7 days)
        int cookieMaxAge = (remember != null) ? (7 * 24 * 60 * 60) : 0;

        Cookie cookieEmail = new Cookie("c_email", (remember != null) ? email : "");
        cookieEmail.setMaxAge(cookieMaxAge);
        cookieEmail.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
        response.addCookie(cookieEmail);

        Cookie cookiePassword = new Cookie("c_pass", (remember != null) ? password : "");
        cookiePassword.setMaxAge(cookieMaxAge);
        cookiePassword.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
        response.addCookie(cookiePassword);

        Cookie cookieRem = new Cookie("c_rem", (remember != null) ? "checked" : "");
        cookieRem.setMaxAge(cookieMaxAge);
        cookieRem.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
        response.addCookie(cookieRem);

        // Redirect based on role
        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
}


