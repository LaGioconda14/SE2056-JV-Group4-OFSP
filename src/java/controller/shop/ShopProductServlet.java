package controller.shop;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Shop;
import model.Product;
import model.ProductVariant;
import dao.ShopDAO;
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
        if (shopId != null) {
            // Lấy danh sách tóm tắt Product (kèm biến thể count, giá min-max, tổng tồn kho)
            List<Product> products = productService.getProductSummariesByShopId(shopId);
            request.setAttribute("products", products);
            request.setAttribute("totalProductsCount", productService.countProductsByShopId(shopId));

            request.setAttribute("tabAllProductCount", productService.countProductsByStatusTab(shopId, "all"));
            request.setAttribute("tabActiveProductCount", productService.countProductsByStatusTab(shopId, "active"));
            request.setAttribute("tabVietgapProductCount", productService.countProductsByStatusTab(shopId, "vietgap"));
            request.setAttribute("tabHiddenProductCount", productService.countProductsByStatusTab(shopId, "hidden"));
            request.setAttribute("tabWarningProductCount", productService.countProductsByStatusTab(shopId, "warning"));

            // Hỗ trợ tương thích ngược cho các tab variant
            List<ProductVariant> listVariants = productService.getVariantsByShopId(shopId);
            request.setAttribute("listVariants", listVariants);
            request.setAttribute("totalVariantsCount", listVariants != null ? listVariants.size() : 0);
            int totalProducts = productService.countProductsByShopId(shopId);
            int totalSkus = productService.countVariantsByShopId(shopId);
            request.setAttribute("totalProducts", totalProducts);
            request.setAttribute("totalSkus", totalSkus);

            int tabAllCount = productService.countVariantsByStatusTab(shopId, "all");
            int tabActiveCount = productService.countVariantsByStatusTab(shopId, "active");
            int tabVietgapCount = productService.countVariantsByStatusTab(shopId, "vietgap");
            int tabHiddenCount = productService.countVariantsByStatusTab(shopId, "hidden");
            int tabWarningCount = productService.countVariantsByStatusTab(shopId, "warning");

            request.setAttribute("tabAllCount", tabAllCount);
            request.setAttribute("tabActiveCount", tabActiveCount);
            request.setAttribute("tabVietgapCount", tabVietgapCount);
            request.setAttribute("tabHiddenCount", tabHiddenCount);
            request.setAttribute("tabWarningCount", tabWarningCount);

            int shopSubOrdersCount = fulfillmentService.countSubOrdersByShop(shopId, null);
            session.setAttribute("shopSubOrdersCount", shopSubOrdersCount);
            request.setAttribute("shopSubOrdersCount", shopSubOrdersCount);

            int lowStockCount = shopDAO.getLowStockCountByShopId(shopId);
            session.setAttribute("lowStockCount", lowStockCount);
            request.setAttribute("lowStockCount", lowStockCount);
        }

        // 5. Forward sang trang JSP
        request.getRequestDispatcher("/views/shop/shop-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
