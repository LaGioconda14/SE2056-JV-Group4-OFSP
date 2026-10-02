package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            role = "ALL";
        }

        request.setAttribute("selectedRole", role.toUpperCase());
        request.setAttribute("roleCounts", dao.getUserRoleCounts());
        request.setAttribute("usersList", dao.getUsersList(role));
        request.getRequestDispatcher("/views/admin/users.jsp").forward(request, response);
    }
}

