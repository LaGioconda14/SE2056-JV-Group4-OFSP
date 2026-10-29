package controller.shop;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.InventoryWasteLog;
import model.ProductVariant;
import model.User;
import dao.ShopDAO;
import model.WasteStatisticDTO;
import service.IInventoryWasteService;
import service.IProductService;
import service.impl.InventoryWasteServiceImpl;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopInventoryServlet", urlPatterns = {"/shop/inventory", "/shop/inventory/waste"})
public class ShopInventoryServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ShopInventoryServlet.class.getName());
    private static final int DEFAULT_PAGE_SIZE = 15;

    private final IInventoryWasteService wasteService = new InventoryWasteServiceImpl();
    private final IProductService productService = new ProductServiceImpl();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (session != null && session.getAttribute("shopId") != null)
                ? ((Number) session.getAttribute("shopId")).longValue() : null;
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/shop/orders");
            return;
        }

        try {
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
            request.setAttribute("activeMenu", "inventory");

            request.getRequestDispatcher("/views/shop/shop-inventory.jsp").forward(request, response);

        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error in ShopInventoryServlet doGet", ex);
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=system");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (session != null && session.getAttribute("shopId") != null)
                ? ((Number) session.getAttribute("shopId")).longValue() : null;
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/shop/orders");
            return;
        }

        String action = request.getParameter("action");
        if ("manual_waste".equals(action)) {
            try {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String reason = request.getParameter("reasonNote");

                if (quantity <= 0 || reason == null || reason.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/shop/inventory?error=invalid_input");
                    return;
                }

                Long loggedBy = (long) user.getId();
                boolean ok = wasteService.recordManualWaste(shopId, variantId, quantity, reason.trim(), loggedBy);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/shop/inventory?success=1");
                } else {
                    response.sendRedirect(request.getContextPath() + "/shop/inventory?error=stock_exceeded");
                }
                return;
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "Error recording manual waste in doPost", ex);
                response.sendRedirect(request.getContextPath() + "/shop/inventory?error=system");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/shop/inventory");
    }
}
