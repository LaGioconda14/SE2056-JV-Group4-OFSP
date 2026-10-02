package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminShopServlet", urlPatterns = {"/admin/shops"})
public class AdminShopServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("shopStats", dao.getShopStats());
        request.setAttribute("shopsList", dao.getShopsList());
        request.getRequestDispatcher("/views/admin/shops.jsp").forward(request, response);
    }
}

