package controller.shop;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopAddVariantServlet", urlPatterns = {"/shop/product/variant/add"})
public class ShopAddVariantServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Long productId = parseProductId(request);
        Product productSummary = loadOwnedProduct(request, response, productId);
        if (productSummary == null) {
            return;
        }
        request.setAttribute("productSummary", productSummary);
        request.getRequestDispatcher("/views/shop/shop-product-addvariant.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        Long productId = parseProductId(request);
        Product productSummary = loadOwnedProduct(request, response, productId);
        if (productSummary == null) {
            return;
        }

        try {
            Long shopId = (Long) request.getSession().getAttribute("shopId");

            productService.addVariantToProduct(shopId, productId,
                    request.getParameter("sku"), request.getParameter("variantName"), request.getParameter("unit"),
                    request.getParameter("price"), request.getParameter("originalPrice"),
                    request.getParameter("stockQuantity"), request.getParameter("lowStockThreshold"),
                    request.getParameter("isActive") != null);

            request.getSession().setAttribute("successMessage", "Đã thêm biến thể mới.");
            response.sendRedirect(request.getContextPath() + "/shop/product/variants?productId=" + productId);
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.setAttribute("productSummary", productSummary);
            request.getRequestDispatcher("/views/shop/shop-product-addvariant.jsp").forward(request, response);
        }
    }

    private Long parseProductId(HttpServletRequest request) {
        try {
            return Long.parseLong(request.getParameter("productId"));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Product loadOwnedProduct(HttpServletRequest request, HttpServletResponse response, Long productId)
            throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Long shopId = (Long) session.getAttribute("shopId");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        if (productId == null || productId <= 0) {
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return null;
        }
        List<Product> products = productService.getProductSummariesByShopId(shopId);
        for (Product product : products) {
            if (product.getId() == productId) {
                return product;
            }
        }
        response.sendRedirect(request.getContextPath() + "/shop/products");
        return null;
    }
}
