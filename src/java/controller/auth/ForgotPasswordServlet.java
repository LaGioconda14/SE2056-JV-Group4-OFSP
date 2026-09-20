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

        // Save OTP with 5 minutes expiry time
        boolean saved = userDAO.saveOTP(email, otp, 5);

        if (!saved) {
            request.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình tạo mã OTP. Vui lòng thử lại!");
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Send OTP via Email (JavaMail API)
        EmailUtil.sendOtpEmail(email, user.getFullName(), otp);

        // Store resetEmail in session to facilitate next step
        HttpSession session = request.getSession(true);
        session.setAttribute("resetEmail", email);
        session.setAttribute("successMessage", "Mã xác thực OTP đã được gửi đến email: " + email + ". Mã có hiệu lực trong 5 phút!");

        response.sendRedirect(request.getContextPath() + "/reset-password");
    }
}


