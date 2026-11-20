package controller.auth;

import java.io.IOException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.user.UserDAO;
import model.dto.auth.GoogleAccount;
import model.entity.user.User;
import service.IUserService;
import service.impl.UserServiceImpl;
import util.GoogleOAuthUtil;
import util.SellerSessionUtil;

@WebServlet(name = "LoginGoogleServlet", urlPatterns = {"/login-google"})
public class LoginGoogleServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginGoogleServlet.class.getName());
    private static final String OAUTH_STATE = "googleOAuthState";
    private static final String OAUTH_REDIRECT_URI = "googleOAuthRedirectUri";
    private final IUserService userService = new UserServiceImpl();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        if (session.getAttribute("user") != null) {
            User loggedUser = (User) session.getAttribute("user");
            redirectAfterLogin(loggedUser, false, session, request, response);
            return;
        }

        String code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            String error = request.getParameter("error");
            if (error != null) {
                clearOAuthSession(session);
                session.setAttribute("errorMessage", "Đăng nhập Google đã bị hủy hoặc không được cấp quyền.");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            if (!GoogleOAuthUtil.isConfigured()) {
                session.setAttribute("errorMessage", "Đăng nhập Google chưa được cấu hình. Hãy tạo src/java/oauth.properties từ file oauth.properties.example.");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String redirectUri = resolveRedirectUri(request);
            String state = UUID.randomUUID().toString();
            session.setAttribute(OAUTH_STATE, state);
            session.setAttribute(OAUTH_REDIRECT_URI, redirectUri);
            response.sendRedirect(GoogleOAuthUtil.getGoogleLoginUrl(redirectUri, state));
            return;
        }

        try {
            String expectedState = (String) session.getAttribute(OAUTH_STATE);
            String returnedState = request.getParameter("state");
            if (expectedState == null || !expectedState.equals(returnedState)) {
                throw new SecurityException("Phiên xác thực Google không hợp lệ hoặc đã hết hạn.");
            }
            String redirectUri = (String) session.getAttribute(OAUTH_REDIRECT_URI);
            if (redirectUri == null || redirectUri.isBlank()) {
                throw new SecurityException("Không tìm thấy URL callback của phiên đăng nhập Google.");
            }

            String accessToken = GoogleOAuthUtil.getToken(code, redirectUri);
            GoogleAccount googleUser = GoogleOAuthUtil.getUserInfo(accessToken);

            // Tài khoản Google chưa có trong hệ thống sẽ được tự tạo -> sau đó cho chọn vai trò
            String googleEmail = (googleUser.getEmail() == null) ? "" : googleUser.getEmail().trim().toLowerCase();
            boolean isNewAccount = !googleEmail.isEmpty() && !userDAO.isEmailExists(googleEmail);

            User user = userService.processGoogleLogin(googleUser);

            request.changeSessionId();
            clearOAuthSession(session);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userfullname", user.getFullName());
            session.setAttribute("email", user.getEmail());
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

            redirectAfterLogin(user, isNewAccount, session, request, response);
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Google Authentication Error", ex);
            clearOAuthSession(session);
            session.setAttribute("errorMessage", "Không thể xác thực tài khoản Google. Vui lòng thử lại.");
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    private String resolveRedirectUri(HttpServletRequest request) {
        String configuredRedirectUri = GoogleOAuthUtil.getConfiguredRedirectUri();
        if (configuredRedirectUri != null) {
            return configuredRedirectUri;
        }
        return request.getRequestURL().toString();
    }

    private void clearOAuthSession(HttpSession session) {
        session.removeAttribute(OAUTH_STATE);
        session.removeAttribute(OAUTH_REDIRECT_URI);
    }

    private void redirectAfterLogin(User user, boolean isNewAccount, HttpSession session,
            HttpServletRequest request, HttpServletResponse response) throws IOException {
        String ctx = request.getContextPath();
        String role = (user == null || user.getRole() == null) ? "CUSTOMER" : user.getRole().toUpperCase();
        switch (role) {
            case "ADMIN":
                response.sendRedirect(ctx + "/admin/dashboard");
                break;
            case "SHOP_OWNER":
                SellerSessionUtil.initShopSession(session, user.getId());
                response.sendRedirect(ctx + "/shop/dashboard");
                break;
            default:
                response.sendRedirect(ctx + (isNewAccount ? "/choose-role" : "/home"));
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
