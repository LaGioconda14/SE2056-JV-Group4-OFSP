package controller.admin;

import dao.AdminManagementDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AdminManagementDAO dao = new AdminManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        

        // Handle flash session messages
        HttpSession session = request.getSession();
        if (session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }
        if (session.getAttribute("errorMessage") != null) {
            request.setAttribute("errorMessage", session.getAttribute("errorMessage"));
            session.removeAttribute("errorMessage");
        }

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

        List<Map<String, Object>> allCategories = dao.getCategoriesList();
        int totalActiveSkus = 0;
        int activeCount = 0;
        for (Map<String, Object> c : allCategories) {
            totalActiveSkus += (Integer) c.getOrDefault("activeSkus", 0);
            if (Boolean.TRUE.equals(c.get("isActive"))) {
                activeCount++;
            }
        }

        List<Map<String, Object>> filteredList = dao.getCategoriesList(status, search, parent);

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("addCategory".equalsIgnoreCase(action)) {
            String name = request.getParameter("categoryName");
            String slug = request.getParameter("slug");
            String description = request.getParameter("description");
            String parentIdStr = request.getParameter("parentId");
            String iconClass = request.getParameter("iconClass");
            String imageUrl = request.getParameter("imageUrl");
            String displayOrderStr = request.getParameter("displayOrder");
            boolean isActive = "1".equals(request.getParameter("isActive")) || "true".equalsIgnoreCase(request.getParameter("isActive")) || "on".equalsIgnoreCase(request.getParameter("isActive"));

            if (name == null || name.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Tên danh mục không được để trống!");
                response.sendRedirect(request.getContextPath() + "/admin/categories");
                return;
            }

            Integer parentId = null;
            if (parentIdStr != null && !parentIdStr.trim().isEmpty() && !"0".equals(parentIdStr.trim())) {
                try {
                    parentId = Integer.parseInt(parentIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            int displayOrder = 0;
            if (displayOrderStr != null && !displayOrderStr.trim().isEmpty()) {
                try {
                    displayOrder = Integer.parseInt(displayOrderStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            boolean ok = dao.addCategory(name, slug, description, parentId, iconClass, imageUrl, displayOrder, isActive);
            if (ok) {
                session.setAttribute("successMessage", "Thêm mới danh mục '" + name.trim() + "' thành công!");
            } else {
                session.setAttribute("errorMessage", "Thêm danh mục thất bại. Vui lòng kiểm tra lại slug hoặc thông tin nhập!");
            }
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        if ("updateCategory".equalsIgnoreCase(action)) {
            String catIdStr = request.getParameter("categoryId");
            String name = request.getParameter("categoryName");
            String slug = request.getParameter("slug");
            String description = request.getParameter("description");
            String parentIdStr = request.getParameter("parentId");
            String iconClass = request.getParameter("iconClass");
            String imageUrl = request.getParameter("imageUrl");
            String displayOrderStr = request.getParameter("displayOrder");
            boolean isActive = "1".equals(request.getParameter("isActive")) || "true".equalsIgnoreCase(request.getParameter("isActive")) || "on".equalsIgnoreCase(request.getParameter("isActive"));

            if (catIdStr == null || catIdStr.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Mã danh mục không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/admin/categories");
                return;
            }

            if (name == null || name.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Tên danh mục không được để trống!");
                response.sendRedirect(request.getContextPath() + "/admin/categories");
                return;
            }

            try {
                int categoryId = Integer.parseInt(catIdStr.trim());
                Integer parentId = null;
                if (parentIdStr != null && !parentIdStr.trim().isEmpty() && !"0".equals(parentIdStr.trim())) {
                    parentId = Integer.parseInt(parentIdStr.trim());
                }

                int displayOrder = 0;
                if (displayOrderStr != null && !displayOrderStr.trim().isEmpty()) {
                    displayOrder = Integer.parseInt(displayOrderStr.trim());
                }

                boolean ok = dao.updateCategory(categoryId, name, slug, description, parentId, iconClass, imageUrl, displayOrder, isActive);
                if (ok) {
                    session.setAttribute("successMessage", "Cập nhật danh mục '" + name.trim() + "' thành công!");
                } else {
                    session.setAttribute("errorMessage", "Cập nhật danh mục thất bại!");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Mã danh mục hoặc dữ liệu số không hợp lệ!");
            }
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        if ("toggleCategoryStatus".equalsIgnoreCase(action)) {
            String catIdStr = request.getParameter("categoryId");
            String isActiveStr = request.getParameter("isActive");

            if (catIdStr != null && !catIdStr.trim().isEmpty()) {
                try {
                    int catId = Integer.parseInt(catIdStr.trim());
                    boolean targetActive = "1".equals(isActiveStr) || "true".equalsIgnoreCase(isActiveStr);
                    boolean ok = dao.toggleCategoryStatus(catId, targetActive);

                    if (ok) {
                        session.setAttribute("successMessage", "Đã " + (targetActive ? "bật hiển thị" : "tắt hiển thị") + " danh mục #" + catId + "!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể cập nhật trạng thái danh mục!");
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        if ("deleteCategory".equalsIgnoreCase(action)) {
            String catIdStr = request.getParameter("categoryId");
            if (catIdStr != null && !catIdStr.trim().isEmpty()) {
                try {
                    int catId = Integer.parseInt(catIdStr.trim());
                    boolean ok = dao.deleteCategory(catId);
                    if (ok) {
                        session.setAttribute("successMessage", "Xóa danh mục #" + catId + " thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể xóa danh mục. Danh mục không tồn tại!");
                    }
                } catch (IllegalStateException e) {
                    // Chặn xóa cứng khi có sản phẩm hoặc danh mục con
                    session.setAttribute("errorMessage", e.getMessage());
                } catch (Exception e) {
                    session.setAttribute("errorMessage", "Lỗi khi xóa danh mục: " + e.getMessage());
                }
            } else {
                session.setAttribute("errorMessage", "Mã danh mục cần xóa không hợp lệ!");
            }
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }
}
