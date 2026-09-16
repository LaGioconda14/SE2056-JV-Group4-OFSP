package controller;

import dal.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller handling OTP verification and Password Reset.
 */
@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

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

        request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
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

        // Validation
        if (email == null || email.trim().isEmpty() ||
            otp == null || otp.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ tất cả các trường thông tin!");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        email = email.trim();
        otp = otp.trim();

        if (newPassword.length() < 6) {
            request.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp với mật khẩu mới!");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        // Verify OTP from database
        boolean isOtpValid = userDAO.verifyOTP(email, otp);
        if (!isOtpValid) {
            request.setAttribute("errorMessage", "Mã OTP không chính xác hoặc đã hết hiệu lực (quá 5 phút). Vui lòng kiểm tra lại hoặc yêu cầu mã mới!");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        // Reset password
        boolean isReset = userDAO.resetPassword(email, newPassword);
        if (isReset) {
            HttpSession session = request.getSession(true);
            session.removeAttribute("resetEmail");
            session.setAttribute("successMessage", "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới ngay bây giờ.");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình cập nhật mật khẩu. Vui lòng thử lại!");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
        }
    }
}

