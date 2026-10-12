package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

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
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }
        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        request.setAttribute("selectedRole", role.toUpperCase());
        request.setAttribute("selectedStatus", status.toUpperCase());
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("roleCounts", dao.getUserRoleCounts());
        request.setAttribute("usersList", dao.getUsersList(role, status, search));
        request.getRequestDispatcher("/views/admin/users.jsp").forward(request, response);
    }
}

