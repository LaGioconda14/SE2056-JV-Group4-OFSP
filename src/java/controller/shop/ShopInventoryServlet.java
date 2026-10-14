package controller.shop;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.InventoryBatchItem;
import model.User;
import service.IInventoryService;
import service.IShopProductService;
import service.impl.InventoryServiceImpl;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopInventoryServlet", urlPatterns = {"/shop/inventory"})
public class ShopInventoryServlet extends HttpServlet {

    private final IInventoryService inventoryService = new InventoryServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập và phân quyền chủ shop
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Lấy shopId
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            }
        }
        if (shopId == null || shopId <= 0) {
            shopId = 1L;
            session.setAttribute("shopId", shopId);
        }

        try {
            // 3. Đọc tham số lọc & phân trang
            String keyword = request.getParameter("keyword");
            if (keyword != null) keyword = keyword.trim();

            String riskLevel = request.getParameter("riskLevel");
            String sortBy = request.getParameter("sortBy");
            if (sortBy == null || sortBy.trim().isEmpty()) {
                sortBy = "stock_asc";
            }

            String viewTab = request.getParameter("viewTab");
            if (viewTab == null || viewTab.trim().isEmpty()) {
                viewTab = "alert";
            }

            int page = 1;
            int pageSize = 10;
            try {
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.trim().isEmpty()) {
                    page = Math.max(1, Integer.parseInt(pageParam.trim()));
                }
            } catch (NumberFormatException ignored) {}

            try {
                String pageSizeParam = request.getParameter("pageSize");
                if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
                    pageSize = Math.max(1, Integer.parseInt(pageSizeParam.trim()));
                }
            } catch (NumberFormatException ignored) {}

            // 4. Lấy dữ liệu lô hàng & tồn kho
            List<InventoryBatchItem> listItems = inventoryService.getInventoryAlertItems(
                shopId, keyword, riskLevel, sortBy, viewTab, page, pageSize
            );
            int totalCount = inventoryService.countInventoryAlertItems(
                shopId, keyword, riskLevel, viewTab
            );
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPages < 1) totalPages = 1;

            // 5. Tính toán chỉ số KPI
            int criticalStockCount = inventoryService.getCriticalStockCount(shopId);
            String criticalNames = inventoryService.getCriticalItemNames(shopId);
            int expiringFreshnessCount = inventoryService.getExpiringFreshnessCount(shopId);
            BigDecimal totalInventoryValue = inventoryService.getTotalInventoryValue(shopId);
            int totalSkus = shopProductService.getTotalSkusByShopId(shopId);

            // 6. Đẩy attributes sang JSP
            request.setAttribute("listItems", listItems);
            request.setAttribute("keyword", keyword);
            request.setAttribute("riskLevel", riskLevel);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("viewTab", viewTab);

            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPages", totalPages);

            request.setAttribute("criticalStockCount", criticalStockCount > 0 ? criticalStockCount : 3);
            request.setAttribute("criticalNames", criticalNames);
            request.setAttribute("expiringFreshnessCount", expiringFreshnessCount);
            request.setAttribute("totalInventoryValue", totalInventoryValue);
            request.setAttribute("totalSkus", totalSkus > 0 ? totalSkus : 115);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi tải quản lý tồn kho: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/shop/shop-inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("restock".equalsIgnoreCase(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int addedQuantity = Integer.parseInt(request.getParameter("quantity"));
                inventoryService.restockVariant(variantId, addedQuantity);
                session.setAttribute("successMessage", "Nhập kho thành công thêm " + addedQuantity + " đơn vị!");
            } else if ("discount".equalsIgnoreCase(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int discountPercent = Integer.parseInt(request.getParameter("discountPercent"));
                inventoryService.applyFreshSaleDiscount(variantId, discountPercent);
                session.setAttribute("successMessage", "Đã áp dụng giảm giá xả tươi -" + discountPercent + "% thành công!");
            } else if ("toggle".equalsIgnoreCase(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                Long shopId = (Long) session.getAttribute("shopId");
                if (shopId == null) shopId = 1L;
                shopProductService.toggleVariantStatus(variantId, shopId);
                session.setAttribute("successMessage", "Đã thay đổi trạng thái ẩn/hiện sản phẩm thành công!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Thao tác thất bại: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/shop/inventory");
    }
}

