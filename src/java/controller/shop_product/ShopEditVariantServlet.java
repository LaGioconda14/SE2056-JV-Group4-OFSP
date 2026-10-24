package controller.shop_product;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ProductVariant;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopEditVariantServlet", urlPatterns = {"/shop/product/variant/edit"})
public class ShopEditVariantServlet extends HttpServlet {

    private final IProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Long shopId = getAuthorizedShopId(request, response);
        Long variantId = parseVariantId(request);
        if (shopId == null || variantId == null) {
            if (shopId != null) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
            }
            return;
        }
        ProductVariant variant = productService.getShopVariantById(variantId, shopId);
        if (variant == null) {
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }
        request.setAttribute("variant", variant);
        request.getRequestDispatcher("/views/shop_product/shop-product-editvariant.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        Long shopId = getAuthorizedShopId(request, response);
        Long variantId = parseVariantId(request);
        if (shopId == null || variantId == null) {
            if (shopId != null) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
            }
            return;
        }

        try {
            productService.updateVariantDetails(shopId, variantId,
                    request.getParameter("sku"), request.getParameter("variantName"), request.getParameter("unit"),
                    request.getParameter("price"), request.getParameter("originalPrice"),
                    request.getParameter("stockQuantity"), request.getParameter("lowStockThreshold"),
                    request.getParameter("isActive") != null);
            ProductVariant updatedVariant = productService.getShopVariantById(variantId, shopId);
            if (updatedVariant == null) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/shop/product/variants?productId="
                    + updatedVariant.getProductId());
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            ProductVariant variant = productService.getShopVariantById(variantId, shopId);
            if (variant == null) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }
            request.setAttribute("variant", variant);
            request.getRequestDispatcher("/views/shop_product/shop-product-editvariant.jsp").forward(request, response);
        }
    }

    private Long getAuthorizedShopId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Long shopId = (Long) session.getAttribute("shopId");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return shopId;
    }

    private Long parseVariantId(HttpServletRequest request) {
        try {
            return Long.parseLong(request.getParameter("variantId"));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
