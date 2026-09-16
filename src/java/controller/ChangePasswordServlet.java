package controller;

import dal.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;
import service.PasswordUtil;

/**
 * Controller handling Change Password for authenticated users.
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/change-password.jsp").forward(request, response);
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

        // Validate empty fields
        if (oldPassword == null || oldPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tất cả các trường mật khẩu!");
            request.getRequestDispatcher("/change-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("/change-password.jsp").forward(request, response);
            return;
        }

        if (oldPassword.equals(newPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu mới không được trùng với mật khẩu cũ!");
            request.getRequestDispatcher("/change-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp với mật khẩu mới!");
            request.getRequestDispatcher("/change-password.jsp").forward(request, response);
            return;
        }

        // Fetch fresh user data from DB to verify old password
        User freshUser = userDAO.findById(sessionUser.getId());
        if (freshUser == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean isOldPasswordCorrect = PasswordUtil.verifyPassword(oldPassword, freshUser.getPassword());
        if (!isOldPasswordCorrect) {
            request.setAttribute("errorMessage", "Mật khẩu hiện tại (mật khẩu cũ) không chính xác!");
            request.getRequestDispatcher("/change-password.jsp").forward(request, response);
            return;
        }

        // Update password in DB
        boolean isUpdated = userDAO.updatePassword(freshUser.getId(), newPassword);
        if (isUpdated) {
            // Update session user password
            freshUser.setPassword(PasswordUtil.hashPassword(newPassword));
            session.setAttribute("user", freshUser);

            request.setAttribute("successMessage", "Đổi mật khẩu thành công! Mật khẩu mới đã được áp dụng.");
            request.getRequestDispatcher("/change-password.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình cập nhật cơ sở dữ liệu. Vui lòng thử lại!");
            request.getRequestDispatcher("/change-password.jsp").forward(request, response);
        }
    }
}

