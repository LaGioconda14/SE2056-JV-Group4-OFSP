package controller.shop_product;

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
import dao.ShopDAO;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopProductServlet", urlPatterns = {"/shop/products"})
public class ShopProductServlet extends HttpServlet {

    private final ShopDAO shopDAO = new ShopDAO();
    private final IProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập và phân quyền Chủ shop
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Lưu thông tin cơ bản của User vào Session để hiển thị ở Header
        session.setAttribute("userfullname", user.getFullName());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("userAvatar", user.getAvatarUrl());

        // 3. Lấy thông tin Shop và nạp vào Session
        Long shopId = (Long) session.getAttribute("shopId");
        Shop shop = (Shop) session.getAttribute("shopObj");

        if (shopId == null || shop == null) {
            try {
                shop = shopDAO.getShopByOwnerId(user.getId()); // Hoặc user.getId() tùy model của ông
                if (shop != null) {
                    shopId = (long) shop.getShopId();
                    session.setAttribute("shopId", shopId);
                    session.setAttribute("shopName", shop.getShopName());
                    session.setAttribute("shopLogo", shop.getLogoUrl()); // Hoặc getLogoUrl()
                    session.setAttribute("shopObj", shop);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 4. Lấy danh sách sản phẩm của shop
        if (shopId != null) {
            List<Product> products = productService.getProductSummariesByShopId(shopId);
            request.setAttribute("products", products);
            request.setAttribute("totalProductsCount", productService.countProductsByShopId(shopId));

            request.setAttribute("tabAllProductCount", productService.countProductsByStatusTab(shopId, "all"));
            request.setAttribute("tabActiveProductCount", productService.countProductsByStatusTab(shopId, "active"));
            request.setAttribute("tabVietgapProductCount", productService.countProductsByStatusTab(shopId, "vietgap"));
            request.setAttribute("tabHiddenProductCount", productService.countProductsByStatusTab(shopId, "hidden"));
            request.setAttribute("tabWarningProductCount", productService.countProductsByStatusTab(shopId, "warning"));
        }

        // 5. Forward sang trang JSP
        request.getRequestDispatcher("/views/shop_product/shop-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
