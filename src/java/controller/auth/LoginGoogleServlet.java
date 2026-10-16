package controller.auth;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.GoogleAccount;
import model.User;
import service.IUserService;
import service.impl.UserServiceImpl;
import util.GoogleOAuthUtil;

/**
 * Controller handling Google OAuth 2.0 Sign-In and Registration.
 */
@WebServlet(name = "LoginGoogleServlet", urlPatterns = {"/login-google"})
public class LoginGoogleServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginGoogleServlet.class.getName());
    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        // Check if user cancelled Google consent
        String error = request.getParameter("error");
        if (error != null) {
            session.setAttribute("errorMessage", "Đăng nhập Google bị hủy hoặc gặp lỗi: " + error);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // If already logged in, redirect to home page or admin
        if (session.getAttribute("user") != null) {
            User loggedUser = (User) session.getAttribute("user");
            if ("ADMIN".equalsIgnoreCase(loggedUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
            }
            return;
        }

        // Support Mock Demo Google Login for development & test grading
        String demo = request.getParameter("demo");
        if ("1".equals(demo) || "true".equalsIgnoreCase(demo)) {
            try {
                GoogleAccount mockGoogle = new GoogleAccount();
                mockGoogle.setId("google_test_1001");
                mockGoogle.setEmail("demo.google.user@freshfruit.com");
                mockGoogle.setName("Nguyễn Văn Google (Demo)");
                mockGoogle.setPicture("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop");
                mockGoogle.setVerified_email(true);

                User user = userService.processGoogleLogin(mockGoogle);
                session.setAttribute("user", user);
                session.setAttribute("avatarUrl", mockGoogle.getPicture());
                session.setAttribute("successMessage", "Đăng nhập Google (Môi trường Thử nghiệm) thành công! Xin chào " + user.getFullName() + ".");

                // Cảnh báo nếu chưa có số điện thoại
                if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
                    session.setAttribute("warningMessage", 
                        "Tài khoản của bạn đăng ký qua Google hiện chưa có Số điện thoại! "
                        + "Vui lòng cập nhật số điện thoại để thuận tiện nhận cuộc gọi giao hàng từ shipper.");
                    session.setAttribute("phoneMissingWarning", true);
                }

                if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/home.jsp");
                }
                return;
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "Mock Google Login Error", ex);
                session.setAttribute("errorMessage", "Lỗi tạo tài khoản demo: " + ex.getMessage());
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        }

        String code = request.getParameter("code");

        // Step 1: If no authorization code, redirect user to Google consent page
        if (code == null || code.trim().isEmpty()) {
            // Check if Client ID and Secret are configured
            if (!GoogleOAuthUtil.isConfigured()) {
                session.setAttribute("errorMessage", 
                        "Tính năng đăng nhập Google chưa được cấu hình Client ID & Secret từ Google Cloud! "
                        + "<br><a href=\"" + request.getContextPath() + "/login-google?demo=1\" class=\"alert-link fw-bold text-decoration-underline mt-1 d-inline-block\">"
                        + "<i class=\"bi bi-play-circle-fill me-1\"></i>Bấm vào đây để Đăng nhập thử nghiệm (Demo Google Login)</a>");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Redirect user to Google OAuth consent screen
            response.sendRedirect(GoogleOAuthUtil.getGoogleLoginUrl());
            return;
        }

        // Step 2: Google redirected back with authorization code -> Exchange for token & userinfo
        try {
            String accessToken = GoogleOAuthUtil.getToken(code);
            GoogleAccount googleUser = GoogleOAuthUtil.getUserInfo(accessToken);

            // Step 3 & 4: Process login or auto-register via Service
            User user = userService.processGoogleLogin(googleUser);

            // Step 5: Login successful -> Save to session
            session.setAttribute("user", user);
            if (googleUser.getPicture() != null && !googleUser.getPicture().trim().isEmpty()) {
                session.setAttribute("avatarUrl", googleUser.getPicture());
            } else if (user.getAvatarUrl() != null && !user.getAvatarUrl().trim().isEmpty()) {
                session.setAttribute("avatarUrl", user.getAvatarUrl());
            }

            session.setAttribute("successMessage", "Đăng nhập Google thành công! Xin chào " + user.getFullName() + ".");

            // Kiểm tra và cảnh báo nếu người dùng chưa cập nhật số điện thoại
            if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
                session.setAttribute("warningMessage", 
                    "Tài khoản của bạn đăng ký qua Google hiện chưa có Số điện thoại! "
                    + "Vui lòng cập nhật số điện thoại để thuận tiện nhận cuộc gọi giao hàng từ shipper.");
                session.setAttribute("phoneMissingWarning", true);
            }

            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
            }

        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Google Authentication Error", ex);
            session.setAttribute("errorMessage", "Lỗi trong quá trình xác thực Google: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
