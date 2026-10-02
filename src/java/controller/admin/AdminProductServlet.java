package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products", "/admin/product-moderation"})
public class AdminProductServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uri = request.getRequestURI();
        boolean isModeration = uri.contains("product-moderation");
        request.setAttribute("isModeration", isModeration);
        request.setAttribute("activePage", isModeration ? "moderation" : "products");
        request.setAttribute("productsList", dao.getProductsList());
        request.getRequestDispatcher("/views/admin/products.jsp").forward(request, response);
    }
}

