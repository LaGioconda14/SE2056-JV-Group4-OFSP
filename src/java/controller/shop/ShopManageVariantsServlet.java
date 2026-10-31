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
import model.ProductVariant;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopManageVariantsServlet", urlPatterns = {"/shop/product/variants"})
public class ShopManageVariantsServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Long shopId = (Long) session.getAttribute("shopId");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long productId = Long.parseLong(request.getParameter("productId"));
            Product productSummary = null;
            for (Product item : productService.getProductSummariesByShopId(shopId)) {
                if (item.getId() == productId) {
                    productSummary = item;
                    break;
                }
            }
            if (productSummary == null) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }

            List<ProductVariant> variants = productService.getShopVariantsByProductId(shopId, productId);
            request.setAttribute("productSummary", productSummary);
            request.setAttribute("variants", variants);
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
            request.getRequestDispatcher("/views/shop/shop-product-variants.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/shop/products");
        }
    }
}
