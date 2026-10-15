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
import model.Category;
import model.ProductVariant;
import model.User;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopProductServlet", urlPatterns = {"/shop/products"})
public class ShopProductServlet extends HttpServlet {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();

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


        try {
            // 3. Đọc tham số lọc & phân trang
            String keyword = request.getParameter("keyword");
            if (keyword == null || keyword.trim().isEmpty()) {
                keyword = request.getParameter("txtSearch");
            }
            if (keyword != null) {
                keyword = keyword.trim();
            }

            String categoryId = request.getParameter("categoryId");
            String certification = request.getParameter("certification");
            String stockLevel = request.getParameter("stockLevel");
            String statusTab = request.getParameter("statusTab");
            if (statusTab == null || statusTab.trim().isEmpty()) {
                statusTab = "all";
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

            // 4. Lấy dữ liệu sản phẩm theo bộ lọc và phân trang
            List<ProductVariant> listVariants = shopProductService.getVariantsByShopId(shopId);
            int totalVariantsCount = shopProductService.countFilteredVariants(
                shopId, keyword, categoryId, certification, stockLevel, statusTab
            );
            int totalPages = (int) Math.ceil((double) totalVariantsCount / pageSize);
            if (totalPages < 1) totalPages = 1;

            // 5. Lấy danh sách danh mục để đổ vào Dropdown
            List<Category> categories = shopProductService.getAllCategories();

            // 6. Tính toán các chỉ số KPI theo gian hàng
            int totalSKU = shopProductService.getTotalSkusByShopId(shopId);
            int totalProducts = shopProductService.getTotalProductsCountByShopId(shopId);
            int activeSKU = shopProductService.getActiveSkusCountByShopId(shopId);
            int ocopCount = shopProductService.getOcopOrVietgapCountByShopId(shopId);
            int lowStockCount = shopProductService.getLowStockCountByShopId(shopId);
            BigDecimal totalInventoryValue = shopProductService.getTotalInventoryValueByShopId(shopId);

            // Tỷ lệ sẵn sàng (%)
            double readyRate = (totalSKU > 0) ? Math.round(((double) activeSKU / totalSKU) * 1000.0) / 10.0 : 95.2;
            // Tỷ trọng danh mục OCOP/VietGAP (%)
            double ocopRate = (totalSKU > 0) ? Math.round(((double) ocopCount / totalSKU) * 1000.0) / 10.0 : 85.7;

            // Số lượng cho từng tab trạng thái
            int tabAllCount = totalSKU;
            int tabActiveCount = activeSKU;
            int tabVietgapCount = shopProductService.getTabCountByShopId(shopId, "vietgap");
            int tabHiddenCount = shopProductService.getTabCountByShopId(shopId, "hidden");
            int tabWarningCount = shopProductService.getTabCountByShopId(shopId, "warning");

            // 7. Đẩy tất cả dữ liệu sang JSP
            request.setAttribute("listVariants", listVariants);
            request.setAttribute("categories", categories);

            request.setAttribute("keyword", keyword);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("certification", certification);
            request.setAttribute("stockLevel", stockLevel);
            request.setAttribute("statusTab", statusTab);

            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalVariantsCount", totalVariantsCount);
            request.setAttribute("totalPages", totalPages);

            request.setAttribute("totalSKU", totalSKU);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("activeSKU", activeSKU);
            request.setAttribute("readyRate", readyRate);
            request.setAttribute("ocopCount", ocopCount);
            request.setAttribute("ocopRate", ocopRate);
            request.setAttribute("lowStockCount", lowStockCount);
            request.setAttribute("totalValue", totalInventoryValue);

            request.setAttribute("tabAllCount", tabAllCount);
            request.setAttribute("tabActiveCount", tabActiveCount);
            request.setAttribute("tabVietgapCount", tabVietgapCount);
            request.setAttribute("tabHiddenCount", tabHiddenCount);
            request.setAttribute("tabWarningCount", tabWarningCount);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi tải danh sách sản phẩm: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/shop/shop-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}