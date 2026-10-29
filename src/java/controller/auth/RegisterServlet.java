package controller.auth;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.IUserService;
import service.impl.UserServiceImpl;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
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

        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        try {
            userService.register(fullName, email, phone, password, confirmPassword);

            HttpSession session = request.getSession(true);

            // Đăng nhập luôn cho người vừa đăng ký, rồi chuyển sang màn hình chọn vai trò
            // (Khách hàng / Người bán). Tài khoản mới luôn có vai trò CUSTOMER.
            User newUser = null;
            try {
                newUser = userService.login(email.trim(), password);
            } catch (Exception loginEx) {
                // Không tự đăng nhập được thì quay về cách cũ: yêu cầu đăng nhập thủ công
            }
            if (newUser != null) {
                session.setAttribute("user", newUser);
                session.setAttribute("userfullname", newUser.getFullName());
                session.setAttribute("email", newUser.getEmail());
                response.sendRedirect(request.getContextPath() + "/choose-role");
                return;
            }

            session.setAttribute("successMessage", "Đăng ký tài khoản thành công! Bạn có thể đăng nhập ngay bây giờ.");
            response.sendRedirect(request.getContextPath() + "/login");
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }
}
