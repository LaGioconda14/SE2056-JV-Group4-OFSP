package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.IUserService;
import service.impl.UserServiceImpl;

/**
 * Controller handling OTP verification and Password Reset.
 */
@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            String resetEmail = (String) session.getAttribute("resetEmail");
            if (resetEmail != null) {
                request.setAttribute("email", resetEmail);
            }
            String successMsg = (String) session.getAttribute("successMessage");
            if (successMsg != null) {
                request.setAttribute("successMessage", successMsg);
                session.removeAttribute("successMessage");
            }
            String errorMsg = (String) session.getAttribute("errorMessage");
            if (errorMsg != null) {
                request.setAttribute("errorMessage", errorMsg);
                session.removeAttribute("errorMessage");
            }
        }

        request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String otp = request.getParameter("otp");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        request.setAttribute("email", email);
        request.setAttribute("otp", otp);

        // Basic check for empty OTP
        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập mã OTP!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Verify OTP from Web Session
        HttpSession session = request.getSession(false);
        if (session == null) {
            request.setAttribute("errorMessage", "Phiên xác thực đã hết hạn. Vui lòng quay lại gửi yêu cầu mã OTP mới!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        String sessionEmail = (String) session.getAttribute("resetEmail");
        String sessionOtp = (String) session.getAttribute("resetOtp");
        Long sessionExpiry = (Long) session.getAttribute("otpExpiryTime");

        if (sessionOtp == null || sessionExpiry == null || sessionEmail == null) {
            request.setAttribute("errorMessage", "Không tìm thấy phiên xác thực OTP hoặc phiên đã bị hủy. Vui lòng thực hiện lại từ đầu!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Kiểm tra thời hạn hiệu lực của OTP (5 phút)
        if (System.currentTimeMillis() > sessionExpiry) {
            session.removeAttribute("resetOtp");
            session.removeAttribute("otpExpiryTime");
            request.setAttribute("errorMessage", "Mã OTP đã hết hiệu lực (quá 5 phút). Vui lòng yêu cầu mã mới!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Kiểm tra email khớp với email đã nhận mã OTP
        if (email == null || !email.trim().equalsIgnoreCase(sessionEmail.trim())) {
            request.setAttribute("errorMessage", "Email không khớp với địa chỉ đã nhận mã xác thực OTP!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Kiểm tra mã OTP khớp
        if (!otp.trim().equals(sessionOtp.trim())) {
            request.setAttribute("errorMessage", "Mã OTP không chính xác. Vui lòng kiểm tra lại email của bạn!");
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Reset password via Service
        try {
            userService.resetPassword(email, newPassword, confirmPassword);

            session.removeAttribute("resetEmail");
            session.removeAttribute("resetOtp");
            session.removeAttribute("otpExpiryTime");

            session.setAttribute("successMessage", "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới ngay bây giờ.");
            response.sendRedirect(request.getContextPath() + "/login");
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
        }
    }
}


