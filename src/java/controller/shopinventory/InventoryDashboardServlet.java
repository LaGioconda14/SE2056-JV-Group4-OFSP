package controller.shopinventory;

import dao.ShopDAO;
import java.io.IOException;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.inventory.ProductBatch;
import model.entity.shop.Shop;
import model.entity.user.User;
import service.IInventoryService;
import service.impl.InventoryServiceImpl;

@WebServlet(name = "InventoryDashboardServlet", urlPatterns = {"/shop/inventory/batches", "/shop/batches"})
public class InventoryDashboardServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAO();
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

        // 1. Lấy danh sách lô từ service có sẵn
        List<ProductBatch> allBatches = inventoryService.getBatchesByShopId(shopId);

        long totalStock = 0;
        int lowStockCount = 0;
        int totalBatches = 0;
        int nearExpiryCount = 0;

        // 2. Gom nhóm trực tiếp bằng Map: Key là variantId, Value là danh sách ProductBatch của variant đó
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

        // 3. Đẩy thẳng cái Map này sang JSP
        request.setAttribute("variantBatchMap", variantBatchMap);
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