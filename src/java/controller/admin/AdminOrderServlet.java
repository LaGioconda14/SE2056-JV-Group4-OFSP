package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders"})
public class AdminOrderServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        String search = request.getParameter("search");

        request.setAttribute("orderStats", dao.getOrderStats());
        request.setAttribute("ordersList", dao.getOrdersList(status, search));
        request.setAttribute("selectedStatus", status != null && !status.trim().isEmpty() ? status.trim() : "ALL");
        request.setAttribute("searchKeyword", search != null ? search.trim() : "");
        request.getRequestDispatcher("/views/admin/orders.jsp").forward(request, response);
    }
}

