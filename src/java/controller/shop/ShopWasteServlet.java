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
import model.WasteStatisticDTO;
import service.IInventoryWasteService;
import service.IProductService;
import service.IShopProductService;
import service.impl.InventoryWasteServiceImpl;
import service.impl.ProductServiceImpl;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopWasteServlet", urlPatterns = {"/shop/waste", "/shop/inventory/waste"})
public class ShopWasteServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ShopWasteServlet.class.getName());
    private static final int DEFAULT_PAGE_SIZE = 15;

    private final IInventoryWasteService wasteService = new InventoryWasteServiceImpl();
    private final IProductService productService = new ProductServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();

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
        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0 && session != null) {
                session.setAttribute("shopId", shopId);
            }
        }
        if (shopId == null || shopId <= 0) {
            shopId = 1L;
            if (session != null) {
                session.setAttribute("shopId", shopId);
            }
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
            request.setAttribute("activeMenu", "waste");

            request.getRequestDispatcher("/views/shop/shop-waste.jsp").forward(request, response);

        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error in ShopWasteServlet doGet", ex);
            request.setAttribute("errorMessage", "Lỗi tải nhật ký hàng hỏng: " + ex.getMessage());
            request.getRequestDispatcher("/views/shop/shop-waste.jsp").forward(request, response);
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
        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
        }
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/shop/waste");
            return;
        }

        String action = request.getParameter("action");
        if ("manual_waste".equals(action)) {
            try {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String reason = request.getParameter("reasonNote");

                if (quantity <= 0 || reason == null || reason.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/shop/waste?error=invalid_input");
                    return;
                }

                Long loggedBy = (long) user.getId();
                boolean ok = wasteService.recordManualWaste(shopId, variantId, quantity, reason.trim(), loggedBy);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/shop/waste?success=1");
                } else {
                    response.sendRedirect(request.getContextPath() + "/shop/waste?error=stock_exceeded");
                }
                return;
            } catch (Exception ex) {
                LOGGER.log(Level.SEVERE, "Error recording manual waste in ShopWasteServlet doPost", ex);
                response.sendRedirect(request.getContextPath() + "/shop/waste?error=system");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/shop/waste");
    }
}

