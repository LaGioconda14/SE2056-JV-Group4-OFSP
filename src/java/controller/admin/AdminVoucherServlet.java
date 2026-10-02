package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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

