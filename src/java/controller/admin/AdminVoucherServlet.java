package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminVoucherServlet", urlPatterns = {"/admin/vouchers"})
public class AdminVoucherServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sponsor = request.getParameter("sponsor");
        String status = request.getParameter("status");
        String search = request.getParameter("search");

        request.setAttribute("voucherStats", dao.getVoucherStats());
        request.setAttribute("vouchersList", dao.getVouchersList(sponsor, status, search));
        request.setAttribute("selectedSponsor", sponsor != null && !sponsor.trim().isEmpty() ? sponsor.trim() : "ALL");
        request.setAttribute("selectedStatus", status != null && !status.trim().isEmpty() ? status.trim() : "ALL");
        request.setAttribute("searchKeyword", search != null ? search.trim() : "");
        request.getRequestDispatcher("/views/admin/vouchers.jsp").forward(request, response);
    }
}

