package controller.admin;

import dao.AdminDashboardDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.AdminDashboardStats;

/**
 * Controller handling Multi-Vendor Platform Admin Dashboard.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "dashboard");

        // Fetch real-time statistics from database
        AdminDashboardStats stats = dashboardDAO.getDashboardStats();
        request.setAttribute("stats", stats);

        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
}
