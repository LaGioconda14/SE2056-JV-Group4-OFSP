package controller.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.AdminDashboardStats;
import service.IAdminDashboardService;
import service.impl.AdminDashboardServiceImpl;

/**
 * Controller handling Multi-Vendor Platform Admin Dashboard.
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final IAdminDashboardService dashboardService = new AdminDashboardServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("activePage", "dashboard");

        // Fetch real-time statistics from database
        AdminDashboardStats stats = dashboardService.getDashboardStats();
        request.setAttribute("stats", stats);

        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
}
