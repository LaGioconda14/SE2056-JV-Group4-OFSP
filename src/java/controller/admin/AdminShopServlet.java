package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminShopServlet", urlPatterns = {"/admin/shops"})
public class AdminShopServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = request.getParameter("tab");
        }
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "ALL";
        }

        String cert = request.getParameter("cert");
        if (cert == null || cert.trim().isEmpty()) {
            cert = "ALL";
        }

        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        request.setAttribute("selectedStatus", status.toUpperCase());
        request.setAttribute("selectedType", type);
        request.setAttribute("selectedCert", cert);
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("shopStats", dao.getShopStats());
        request.setAttribute("shopsList", dao.getShopsList(status, type, cert, search));
        request.getRequestDispatcher("/views/admin/shops.jsp").forward(request, response);
    }
}

