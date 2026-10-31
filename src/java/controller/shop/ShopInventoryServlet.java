package controller.shop;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.ShopDAO;
import model.InventoryBatchItem;
import model.InventoryWasteLog;
import model.ProductVariant;
import model.User;
import model.WasteStatisticDTO;
import service.IInventoryService;
import service.IInventoryWasteService;
import service.IProductService;
import service.IShopProductService;
import service.impl.InventoryServiceImpl;
import service.impl.InventoryWasteServiceImpl;
import service.impl.ProductServiceImpl;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopInventoryServlet", urlPatterns = {"/shop/inventory", "/shop/inventory/waste"})
public class ShopInventoryServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ShopInventoryServlet.class.getName());
    private static final int DEFAULT_PAGE_SIZE = 15;

    private final IInventoryService inventoryService = new InventoryServiceImpl();
    private final IInventoryWasteService wasteService = new InventoryWasteServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();
    private final IProductService productService = new ProductServiceImpl();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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
            String servletPath = request.getServletPath();
            String viewTab = request.getParameter("viewTab");
            if ("/shop/inventory/waste".equalsIgnoreCase(servletPath)) {
                viewTab = "waste";
            } else if (viewTab == null || viewTab.trim().isEmpty()) {
                viewTab = "alert";
            } else {
                viewTab = viewTab.trim().toLowerCase();
            }

            request.setAttribute("viewTab", viewTab);
            request.setAttribute("activeMenu", "inventory");

            if ("waste".equals(viewTab)) {
                String stage = request.getParameter("stage");
                if (stage == null || stage.trim().isEmpty()) {
                    stage = "ALL";
                } else {
                    stage = stage.trim().toUpperCase();
                }

                String keyword = request.getParameter("keyword");
                if (keyword != null) {
                    keyword = keyword.trim();
                }

                int page = 1;
                try {
                    String p = request.getParameter("page");
                    if (p != null && !p.trim().isEmpty()) {
                        page = Math.max(1, Integer.parseInt(p.trim()));
                    }
                } catch (NumberFormatException ignored) {
                    page = 1;
                }

                List<InventoryWasteLog> logs = wasteService.getWasteLogsByShop(shopId, stage, keyword, page, DEFAULT_PAGE_SIZE);
                int totalItems = wasteService.countWasteLogsByShop(shopId, stage, keyword);
                int totalPages = (int) Math.ceil((double) totalItems / DEFAULT_PAGE_SIZE);

                int lowStockCount = shopDAO.getLowStockCountByShopId(shopId);
                session.setAttribute("lowStockCount", lowStockCount);
                request.setAttribute("lowStockCount", lowStockCount);

                WasteStatisticDTO stats = wasteService.getWasteStatisticsByShop(shopId);
                List<ProductVariant> variants = productService.getVariantsByShopId(shopId);

                request.setAttribute("wasteLogs", logs);
                request.setAttribute("stats", stats);
                request.setAttribute("variants", variants);
                request.setAttribute("currentStage", stage);
                request.setAttribute("keyword", keyword != null ? keyword : "");
                request.setAttribute("currentPage", page);
                request.setAttribute("totalPages", Math.max(1, totalPages));
                request.setAttribute("totalItems", totalItems);
            } else {
                String keyword = request.getParameter("keyword");
                if (keyword != null) {
                    keyword = keyword.trim();
                }

                String riskLevel = request.getParameter("riskLevel");
                String sortBy = request.getParameter("sortBy");
                if (sortBy == null || sortBy.trim().isEmpty()) {
                    sortBy = "stock_asc";
                }

                int page = 1;
                int pageSize = 10;
                try {
                    String p = request.getParameter("page");
                    if (p != null && !p.trim().isEmpty()) {
                        page = Math.max(1, Integer.parseInt(p.trim()));
                    }
                } catch (NumberFormatException ignored) {
                    page = 1;
                }

                List<InventoryBatchItem> inventoryList = inventoryService.getInventoryAlertItems(shopId, keyword, riskLevel, sortBy, viewTab, page, pageSize);

                int totalCount = inventoryService.countInventoryAlertItems(shopId, keyword, riskLevel, viewTab);
                int totalPages = (int) Math.ceil((double) totalCount / pageSize);
                if (totalPages < 1) totalPages = 1;

                int criticalStockCount = inventoryService.getCriticalStockCount(shopId);
                String criticalNames = inventoryService.getCriticalItemNames(shopId);
                int expiringFreshnessCount = inventoryService.getExpiringFreshnessCount(shopId);
                BigDecimal totalInventoryValue = inventoryService.getTotalInventoryValue(shopId);
                int totalSkus = 115;

                request.setAttribute("inventoryList", inventoryList);
                request.setAttribute("keyword", keyword != null ? keyword : "");
                request.setAttribute("riskLevel", riskLevel);
                request.setAttribute("sortBy", sortBy);
                request.setAttribute("page", page);
                request.setAttribute("pageSize", pageSize);
                request.setAttribute("totalCount", totalCount);
                request.setAttribute("totalPages", totalPages);

                request.setAttribute("criticalStockCount", criticalStockCount > 0 ? criticalStockCount : 3);
                request.setAttribute("criticalNames", criticalNames);
                request.setAttribute("expiringFreshnessCount", expiringFreshnessCount);
                request.setAttribute("totalInventoryValue", totalInventoryValue);
                request.setAttribute("totalSkus", totalSkus > 0 ? totalSkus : 115);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tải quản lý tồn kho", e);
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

        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null || shopId <= 0) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            } else {
                shopId = 1L;
            }
        }

        String action = request.getParameter("action");
        String redirectTab = "alert";

        try {
            if ("restock".equalsIgnoreCase(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int addedQuantity = Integer.parseInt(request.getParameter("quantity"));
                inventoryService.restockVariant(variantId, addedQuantity);
                session.setAttribute("successMessage", "Nhập kho thành công thêm " + addedQuantity + " đơn vị!");
                redirectTab = "alert";
            } else if ("discount".equalsIgnoreCase(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int discountPercent = Integer.parseInt(request.getParameter("discountPercent"));
                inventoryService.applyFreshSaleDiscount(variantId, discountPercent);
                session.setAttribute("successMessage", "Đã áp dụng giảm giá xả tươi -" + discountPercent + "% thành công!");
                redirectTab = "alert";
            } else if ("toggle".equalsIgnoreCase(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                shopProductService.toggleVariantStatus(variantId, shopId);
                session.setAttribute("successMessage", "Đã thay đổi trạng thái ẩn/hiện sản phẩm thành công!");
                redirectTab = "all";
            } else if ("manual_waste".equalsIgnoreCase(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String reason = request.getParameter("reasonNote");

                if (quantity <= 0 || reason == null || reason.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Thông tin tiêu hủy không hợp lệ!");
                    redirectTab = "waste";
                    response.sendRedirect(request.getContextPath() + "/shop/inventory?viewTab=" + redirectTab);
                    return;
                }

                Long loggedBy = (long) user.getId();
                boolean ok = wasteService.recordManualWaste(shopId, variantId, quantity, reason.trim(), loggedBy);
                if (ok) {
                    session.setAttribute("successMessage", "Ghi nhận tiêu hủy " + quantity + " đơn vị thành công!");
                } else {
                    session.setAttribute("errorMessage", "Số lượng tiêu hủy vượt quá tồn kho hiện tại!");
                }
                redirectTab = "waste";
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi thao tác tồn kho trong doPost", e);
            session.setAttribute("errorMessage", "Thao tác thất bại: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/shop/inventory?viewTab=" + redirectTab);
    }
}
