package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products", "/admin/product-moderation"})
public class AdminProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String uri = request.getRequestURI();
        boolean isModeration = uri.contains("product-moderation");
        
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }
        
        String category = request.getParameter("category");
        if (category == null || category.trim().isEmpty()) {
            category = "ALL";
        }
        
        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        request.setAttribute("isModeration", isModeration);
        request.setAttribute("activePage", isModeration ? "moderation" : "products");
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("productStats", dao.getProductModerationStats());
        request.setAttribute("categoriesList", dao.getCategoriesList());
        request.setAttribute("productsList", dao.getProductsList(status, category, search));

        request.getRequestDispatcher("/views/admin/products.jsp").forward(request, response);
    }
}

