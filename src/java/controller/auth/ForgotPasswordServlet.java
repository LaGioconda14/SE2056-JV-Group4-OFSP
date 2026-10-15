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
 * Controller handling Forgot Password request and OTP generation.
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();

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

        if (email != null) {
            email = email.trim();
        }

        try {
            String otp = userService.sendForgotPasswordOtp(email);

            // Lưu thông tin OTP và thời gian hết hạn (5 phút) vào Web Session
            long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000L);
            HttpSession session = request.getSession(true);
            session.setAttribute("resetEmail", email);
            session.setAttribute("resetOtp", otp);
            session.setAttribute("otpExpiryTime", expiryTime);
            session.setAttribute("successMessage", "Mã xác thực OTP đã được gửi đến email: " + email + ". Mã có hiệu lực trong 5 phút!");

            response.sendRedirect(request.getContextPath() + "/reset-password");
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
        }
    }
}


