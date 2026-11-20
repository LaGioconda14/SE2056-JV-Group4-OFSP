package controller.shop;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
import model.entity.shop.Shop;
import model.dto.product.ProductCardDTO;
import model.dto.product.ProductVariantStockDTO;
import dao.shop.ShopDAO;
import service.IOrderFulfillmentService;
import service.IProductService;
import service.impl.OrderFulfillmentServiceImpl;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopProductServlet", urlPatterns = {"/shop/products"})
public class ShopProductServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAO();
    private final IProductService productService = new ProductServiceImpl();
    private final IOrderFulfillmentService fulfillmentService = new OrderFulfillmentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra session đăng nhập
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Lấy thông tin shopId của user hiện tại
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            Shop shop = shopDAO.getShopByOwnerId(user.getId());
            if (shop != null) {
                shopId = shop.getShopId();
                session.setAttribute("shopId", shopId);
                session.setAttribute("shop", shop);
            }
        }
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/register-shop");
            return;
        }

        // 3. Xử lý thông báo chuyển tiếp (Flash message) nếu có
        String message = request.getParameter("message");
        if (message != null) {
            switch (message) {
                case "add_success":
                    request.setAttribute("successMessage", "Thêm nông sản mới thành công!");
                    break;
                case "updated_success":
                    request.setAttribute("successMessage", "Cập nhật thông tin nông sản thành công!");
                    break;
                case "delete_success":
                    request.setAttribute("successMessage", "Đã xóa sản phẩm thành công!");
                    break;
                default:
                    break;
            }
        }

        // 4. Lấy danh sách sản phẩm và biến thể của shop
        String statusTab = request.getParameter("statusTab");
        if (statusTab == null || statusTab.trim().isEmpty()) {
            statusTab = "all";
        }
        statusTab = statusTab.trim().toLowerCase();
        request.setAttribute("statusTab", statusTab);

        // Lấy danh sách tóm tắt Product đã lọc theo Tab (kèm biến thể count, giá min-max, tổng tồn kho)
        List<ProductCardDTO> products = productService.getProductSummariesByShopId(shopId, statusTab);
        request.setAttribute("products", products);
        int totalProducts = productService.countProductsByShopId(shopId);
        request.setAttribute("totalProductsCount", totalProducts);
        request.setAttribute("totalProducts", totalProducts);

        int tabAllCount = productService.countProductsByStatusTab(shopId, "all");
        int tabActiveCount = productService.countProductsByStatusTab(shopId, "active");
        int tabLowStockCount = productService.countProductsByStatusTab(shopId, "low_stock");
        int tabOutOfStockCount = productService.countProductsByStatusTab(shopId, "out_of_stock");
        int tabHiddenCount = productService.countProductsByStatusTab(shopId, "hidden");

        request.setAttribute("tabAllProductCount", tabAllCount);
        request.setAttribute("tabActiveProductCount", tabActiveCount);
        request.setAttribute("tabLowStockProductCount", tabLowStockCount);
        request.setAttribute("tabOutOfStockProductCount", tabOutOfStockCount);
        request.setAttribute("tabHiddenProductCount", tabHiddenCount);

        // Tương thích ngược cho các biến cũ
        request.setAttribute("tabWarningProductCount", tabLowStockCount);
        request.setAttribute("tabVietgapProductCount", productService.countProductsByStatusTab(shopId, "vietgap"));

        // Hỗ trợ tương thích ngược cho các tab variant
        List<ProductVariantStockDTO> listVariants = productService.getVariantsByShopId(shopId);
        request.setAttribute("listVariants", listVariants);
        request.setAttribute("totalVariantsCount", listVariants != null ? listVariants.size() : 0);
        int totalSkus = productService.countVariantsByShopId(shopId);
        request.setAttribute("totalSkus", totalSkus);

        request.setAttribute("tabAllCount", tabAllCount);
        request.setAttribute("tabActiveCount", tabActiveCount);
        request.setAttribute("tabLowStockCount", tabLowStockCount);
        request.setAttribute("tabOutOfStockCount", tabOutOfStockCount);
        request.setAttribute("tabHiddenCount", tabHiddenCount);
        request.setAttribute("tabWarningCount", tabLowStockCount);
        request.setAttribute("tabVietgapCount", productService.countProductsByStatusTab(shopId, "vietgap"));

        int shopSubOrdersCount = fulfillmentService.countSubOrdersByShop(shopId, null);
        session.setAttribute("shopSubOrdersCount", shopSubOrdersCount);
        request.setAttribute("shopSubOrdersCount", shopSubOrdersCount);

        int lowStockCount = shopDAO.getLowStockCountByShopId(shopId);
        session.setAttribute("lowStockCount", lowStockCount);
        request.setAttribute("lowStockCount", lowStockCount);

        // 5. Forward sang trang JSP
        request.getRequestDispatcher("/views/shop/products/list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
