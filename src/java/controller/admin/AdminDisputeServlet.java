package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminDisputeServlet", urlPatterns = {"/admin/disputes"})
public class AdminDisputeServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("disputesList", dao.getDisputesList());
        request.getRequestDispatcher("/views/admin/disputes.jsp").forward(request, response);
    }
}

