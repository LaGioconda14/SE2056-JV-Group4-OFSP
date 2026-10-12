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
        request.setAttribute("vouchersList", dao.getVouchersList());
        request.getRequestDispatcher("/views/admin/vouchers.jsp").forward(request, response);
    }
}

