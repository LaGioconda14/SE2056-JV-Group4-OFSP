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
import util.PasswordUtil;

/**
 * Controller handling Customer Account Registration.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // If user already logged in, redirect to home
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Retain form inputs for re-rendering if error occurs
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        // 1. Validation - Required fields
        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ các thông tin bắt buộc!");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        fullName = fullName.trim();
        email = email.trim();
        phone = (phone != null) ? phone.trim() : "";

        // 2. Validation - Full Name length
        if (fullName.length() < 2 || fullName.length() > 100) {
            request.setAttribute("errorMessage", "Họ và tên phải từ 2 đến 100 ký tự!");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 3. Validation - Email format
        String emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
        if (!email.matches(emailRegex)) {
            request.setAttribute("errorMessage", "Định dạng Email không hợp lệ (Ví dụ: user@example.com)!");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 4. Validation - Phone format (VN phone number format if provided)
        if (!phone.isEmpty()) {
            String phoneRegex = "^(0[3|5|7|8|9])[0-9]{8}$";
            if (!phone.matches(phoneRegex)) {
                request.setAttribute("errorMessage", "Số điện thoại không hợp lệ (cần 10 chữ số, bắt đầu bằng 03, 05, 07, 08, 09)!");
                request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
                return;
            }
        }

        // 5. Validation - Password length
        if (password.length() < 6) {
            request.setAttribute("errorMessage", "Mật khẩu phải chứa ít nhất 6 ký tự!");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 6. Validation - Password confirmation
        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu xác nhận không trùng khớp!");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 7. Check if Email already exists
        if (userDAO.isEmailExists(email)) {
            request.setAttribute("errorMessage", "Địa chỉ Email này đã được đăng ký. Vui lòng chọn Email khác hoặc Đăng nhập!");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 8. Create new User entity with SHA-256 hashed password
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email.toLowerCase());
        newUser.setPhone(phone.isEmpty() ? null : phone);
        newUser.setPassword(PasswordUtil.hashPassword(password));
        newUser.setStatus(1); // ACTIVE

        boolean registered = userDAO.register(newUser);

        if (registered) {
            // Success -> Redirect to login page with success notification
            HttpSession session = request.getSession(true);
            session.setAttribute("successMessage", "Đăng ký tài khoản thành công! Bạn có thể đăng nhập ngay bây giờ.");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("errorMessage", "Đăng ký không thành công do lỗi hệ thống. Vui lòng thử lại sau!");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }
}


