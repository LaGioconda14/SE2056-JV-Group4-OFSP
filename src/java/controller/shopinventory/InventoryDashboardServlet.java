package controller.shopinventory;

import dao.CategoryDAO;
import dao.ShopDAO;
import java.io.IOException;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.ProductBatch;
import model.Shop;
import model.User;
import service.IInventoryService;
import service.impl.InventoryServiceImpl;

@WebServlet(name = "InventoryDashboardServlet", urlPatterns = {"/shop/inventory"})
public class InventoryDashboardServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final IInventoryService inventoryService = new InventoryServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (Long) session.getAttribute("shopId");
        Shop shop = (Shop) session.getAttribute("shopObj");

        if (shop == null || shopId == null || shopId <= 0) {
            shop = shopDAO.getShopByOwnerId(user.getId());
            if (shop == null) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }
            shopId = shop.getShopId();
            session.setAttribute("shopId", shopId);
            session.setAttribute("shopObj", shop);
        }

        String keyword = request.getParameter("keyword");
        String categoryId = request.getParameter("category");

// 2. Lấy danh sách lô nông sản theo đúng Shop ID kết hợp Search & Filter
        List<ProductBatch> allBatches = inventoryService.searchAndFilterBatches(shopId, keyword, categoryId);

// 3. Lấy toàn bộ danh mục để đổ vào Dropdown bộ lọc
        List<Category> categoryList = categoryDAO.getAllCategories();
        request.setAttribute("CATEGORY_LIST", categoryList);

        long totalStock = 0;
        int lowStockCount = 0;
        int totalBatches = 0;
        int nearExpiryCount = 0;

        // 4. Gom nhóm trực tiếp bằng Map: Key là variantId, Value là danh sách ProductBatch của variant đó
        Map<Long, List<ProductBatch>> variantBatchMap = new LinkedHashMap<>();

        if (allBatches != null) {
            totalBatches = allBatches.size();
            for (ProductBatch batch : allBatches) {
                totalStock += batch.getCurrentQuantity();

                if (batch.getCurrentQuantity() <= 10) {
                    lowStockCount++;
                }
                if (batch.getDaysRemaining() <= 7) {
                    nearExpiryCount++;
                }

                // Gom nhóm các lô chung 1 variant vào chung một danh sách
                variantBatchMap.computeIfAbsent(batch.getVariantId(), k -> new ArrayList<>()).add(batch);
            }
        }

        // 5. Đẩy dữ liệu sang JSP
        request.setAttribute("variantBatchMap", variantBatchMap);
        request.setAttribute("CATEGORY_LIST", categoryList);
        request.setAttribute("totalStock", totalStock);
        request.setAttribute("totalBatches", totalBatches);
        request.setAttribute("lowStockCount", lowStockCount);
        request.setAttribute("nearExpiryCount", nearExpiryCount);

        request.getRequestDispatcher("/views/inventory/inventory-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
