package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        String parent = request.getParameter("parent");
        if (parent == null || parent.trim().isEmpty()) {
            parent = "ALL";
        }

        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        java.util.List<java.util.Map<String, Object>> allCategories = dao.getCategoriesList();
        int totalActiveSkus = 0;
        int activeCount = 0;
        for (java.util.Map<String, Object> c : allCategories) {
            totalActiveSkus += (Integer) c.getOrDefault("activeSkus", 0);
            if (Boolean.TRUE.equals(c.get("isActive"))) {
                activeCount++;
            }
        }

        java.util.List<java.util.Map<String, Object>> filteredList = dao.getCategoriesList(status, search, parent);

        request.setAttribute("selectedStatus", status.toUpperCase());
        request.setAttribute("selectedParent", parent);
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("totalCategories", allCategories.size());
        request.setAttribute("activeCategoriesCount", activeCount);
        request.setAttribute("totalActiveSkus", totalActiveSkus);
        request.setAttribute("allCategories", allCategories);
        request.setAttribute("categoriesList", filteredList);
        request.setAttribute("fruitMegaMenu", dao.getFruitMegaMenuCategories());
        request.getRequestDispatcher("/views/admin/categories.jsp").forward(request, response);
    }
}

