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

@WebServlet(name = "LoginGoogleServlet", urlPatterns = {"/login-google"})
public class LoginGoogleServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginGoogleServlet.class.getName());
    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        String error = request.getParameter("error");
        if (error != null) {
            session.setAttribute("errorMessage", "Đăng nhập Google bị hủy hoặc gặp lỗi: " + error);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (session.getAttribute("user") != null) {
            User loggedUser = (User) session.getAttribute("user");
            if ("ADMIN".equalsIgnoreCase(loggedUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
            }
            return;
        }

        String code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            if (!GoogleOAuthUtil.isConfigured()) {
                session.setAttribute("errorMessage", "Tính năng đăng nhập Google chưa được cấu hình Client ID & Secret từ Google Cloud!");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            response.sendRedirect(GoogleOAuthUtil.getGoogleLoginUrl());
            return;
        }

        try {
            String accessToken = GoogleOAuthUtil.getToken(code);
            GoogleAccount googleUser = GoogleOAuthUtil.getUserInfo(accessToken);

            User user = userService.processGoogleLogin(googleUser);

            session.setAttribute("user", user);
            if (googleUser.getPicture() != null && !googleUser.getPicture().trim().isEmpty()) {
                session.setAttribute("avatarUrl", googleUser.getPicture());
            } else if (user.getAvatarUrl() != null && !user.getAvatarUrl().trim().isEmpty()) {
                session.setAttribute("avatarUrl", user.getAvatarUrl());
            }

            session.setAttribute("successMessage", "Đăng nhập Google thành công! Xin chào " + user.getFullName() + ".");
            if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
                session.setAttribute("warningMessage", 
                    "Tài khoản của bạn đăng ký qua Google hiện chưa có Số điện thoại! "
                    + "Vui lòng cập nhật số điện thoại để thuận tiện nhận cuộc gọi giao hàng từ shipper.");
                session.setAttribute("phoneMissingWarning", true);
            }

            if (user != null && "ADMIN".equalsIgnoreCase(user.getRole())) {
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
