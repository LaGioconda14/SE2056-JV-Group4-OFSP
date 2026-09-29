package controller.auth;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;
import service.IUserService;
import service.impl.UserServiceImpl;

/**
 * Controller handling Change Password for authenticated users.
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            userService.changePassword(sessionUser.getId(), oldPassword, newPassword, confirmPassword);

            // Cập nhật lại thông tin user trong session
            User freshUser = userService.getUserById(sessionUser.getId());
            if (freshUser != null) {
                session.setAttribute("user", freshUser);
            }

            request.setAttribute("successMessage", "Đổi mật khẩu thành công! Mật khẩu mới đã được áp dụng.");
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
        }

        request.getRequestDispatcher("/views/auth/change-password.jsp").forward(request, response);
    }
}


