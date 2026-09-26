package controller.auth;

import dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;
import util.EmailUtil;

/**
 * Controller handling Forgot Password request and OTP generation.
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập địa chỉ Email!");
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        email = email.trim();
        User user = userDAO.findByEmail(email);

        if (user == null) {
            request.setAttribute("errorMessage", "Email không tồn tại trong hệ thống Online Fruit Shop!");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!user.isActive()) {
            request.setAttribute("errorMessage", "Tài khoản này đang bị khóa. Vui lòng liên hệ quản trị viên!");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Generate 6-digit OTP
        String otp = EmailUtil.generateOTP();

        // Send OTP via Email (JavaMail API)
        boolean isSent = EmailUtil.sendOtpEmail(email, user.getFullName(), otp);
        if (!isSent) {
            request.setAttribute("errorMessage", "Không thể gửi email OTP lúc này. Vui lòng kiểm tra lại hòm thư hoặc thử lại sau!");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Lưu thông tin OTP và thời gian hết hạn (5 phút) vào Web Session
        long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000L);
        HttpSession session = request.getSession(true);
        session.setAttribute("resetEmail", email);
        session.setAttribute("resetOtp", otp);
        session.setAttribute("otpExpiryTime", expiryTime);
        session.setAttribute("successMessage", "Mã xác thực OTP đã được gửi đến email: " + email + ". Mã có hiệu lực trong 5 phút!");

        response.sendRedirect(request.getContextPath() + "/reset-password");
    }
}


