package controller.shopinventory;

import dao.shop.ShopDAO;
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

@WebServlet(name = "InventoryDashboardServlet", urlPatterns = {"/shop/inventory/batches", "/shop/batches", "/shop/inventory"})
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

        // 1. Lấy danh sách toàn bộ lô hàng của shop
        List<ProductBatch> allBatches = inventoryService.getBatchesByShopId(shopId);

        long totalStock = 0;
        int lowStockCount = 0;
        int totalBatches = 0;
        int nearExpiryCount = 0;

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
            }
        }

        // 2. Lọc tìm kiếm Server-Side (No-JS Search)
        String keyword = request.getParameter("keyword");
        List<ProductBatch> displayBatches = allBatches != null ? new ArrayList<>(allBatches) : new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.trim().toLowerCase();
            displayBatches.removeIf(b -> {
                String pName = b.getProductName() != null ? b.getProductName().toLowerCase() : "";
                String vName = b.getVariantName() != null ? b.getVariantName().toLowerCase() : "";
                String sku = b.getSku() != null ? b.getSku().toLowerCase() : "";
                String bCode = b.getBatchCode() != null ? b.getBatchCode().toLowerCase() : "";
                return !pName.contains(kw) && !vName.contains(kw) && !sku.contains(kw) && !bCode.contains(kw);
            });
        }

        // 3. Gom nhóm theo variantId để hiển thị danh sách accordion
        Map<Long, List<ProductBatch>> variantBatchMap = new LinkedHashMap<>();
        for (ProductBatch batch : displayBatches) {
            variantBatchMap.computeIfAbsent(batch.getVariantId(), k -> new ArrayList<>()).add(batch);
        }

        // 4. Xử lý nạp dữ liệu Modal qua URL (100% No-JS Server-Rendered Modals)
        String action = request.getParameter("action");
        String batchIdParam = request.getParameter("batchId");
        String variantIdParam = request.getParameter("variantId");

        if (batchIdParam != null && !batchIdParam.trim().isEmpty()) {
            try {
                int targetBatchId = Integer.parseInt(batchIdParam.trim());
                if (allBatches != null) {
                    for (ProductBatch b : allBatches) {
                        if (b.getBatchId() == targetBatchId) {
                            if ("adjust".equalsIgnoreCase(action)) {
                                request.setAttribute("selectedAdjustBatch", b);
                            } else if ("dispose".equalsIgnoreCase(action)) {
                                request.setAttribute("selectedDisposeBatch", b);
                            }
                            break;
                        }
                    }
                }
            } catch (NumberFormatException ignored) {
            }
        }

        if (variantIdParam != null && !variantIdParam.trim().isEmpty()) {
            try {
                long targetVariantId = Long.parseLong(variantIdParam.trim());
                if (allBatches != null) {
                    for (ProductBatch b : allBatches) {
                        if (b.getVariantId() == targetVariantId) {
                            request.setAttribute("selectedRestockVariant", b);
                            break;
                        }
                    }
                }
            } catch (NumberFormatException ignored) {
            }
        }

        request.setAttribute("variantBatchMap", variantBatchMap);
        request.setAttribute("totalStock", totalStock);
        request.setAttribute("totalBatches", totalBatches);
        request.setAttribute("lowStockCount", lowStockCount);
        request.setAttribute("nearExpiryCount", nearExpiryCount);

        request.getRequestDispatcher("/views/shop/inventory/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
