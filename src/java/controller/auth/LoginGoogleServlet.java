package controller.auth;

import dao.UserDAO;
import java.io.IOException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.GoogleAccount;
import model.User;
import util.GoogleOAuthUtil;
import util.PasswordUtil;

/**
 * Controller handling Google OAuth 2.0 Sign-In and Registration.
 */
@WebServlet(name = "LoginGoogleServlet", urlPatterns = {"/login-google"})
public class LoginGoogleServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginGoogleServlet.class.getName());
    private final UserDAO userDAO = new UserDAO();

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

        String code = request.getParameter("code");

        // Step 1: If no authorization code, redirect user to Google consent page
        if (code == null || code.trim().isEmpty()) {
            // If already logged in, redirect to home page
            if (session.getAttribute("user") != null) {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }

            // Check if Client ID and Secret are configured
            if (!GoogleOAuthUtil.isConfigured()) {
                session.setAttribute("errorMessage", 
                        "Tính năng đăng nhập Google chưa được cấu hình Client ID & Secret! "
                        + "Vui lòng cập nhật GOOGLE_CLIENT_ID và GOOGLE_CLIENT_SECRET trong file GoogleOAuthUtil.java.");
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

            if (googleUser == null || googleUser.getEmail() == null || googleUser.getEmail().trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không thể lấy thông tin tài khoản Google. Vui lòng thử lại!");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String googleEmail = googleUser.getEmail().trim().toLowerCase();
            User user = userDAO.findByEmail(googleEmail);

            // Step 3: Handle Auto-Registration if user does not exist
            if (user == null) {
                User newUser = new User();
                newUser.setEmail(googleEmail);

                String name = googleUser.getName();
                if (name == null || name.trim().isEmpty()) {
                    name = googleEmail.split("@")[0];
                }
                newUser.setFullName(name);

                // Generate random secure password for OAuth account
                newUser.setPassword(PasswordUtil.hashPassword(UUID.randomUUID().toString()));
                newUser.setPhone(null);
                newUser.setRole("CUSTOMER");
                newUser.setStatus(1); // ACTIVE

                boolean registered = userDAO.register(newUser);
                if (!registered) {
                    session.setAttribute("errorMessage", "Đăng ký tài khoản Google mới thất bại. Vui lòng thử lại!");
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                user = userDAO.findByEmail(googleEmail);
            }

            // Step 4: Validate user active status
            if (user == null || !user.isActive()) {
                session.setAttribute("errorMessage", "Tài khoản của bạn đang bị khóa. Vui lòng liên hệ quản trị viên!");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Step 5: Login successful -> Save to session
            session.setAttribute("user", user);
            if (googleUser.getPicture() != null && !googleUser.getPicture().trim().isEmpty()) {
                session.setAttribute("avatarUrl", googleUser.getPicture());
            }

            session.setAttribute("successMessage", "Đăng nhập Google thành công! Xin chào " + user.getFullName() + ".");
            response.sendRedirect(request.getContextPath() + "/home.jsp");

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
