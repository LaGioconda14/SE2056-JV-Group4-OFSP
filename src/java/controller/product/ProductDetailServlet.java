package controller.product;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import model.Shop;
import service.IProductService;
import service.IShopProductService;
import service.impl.ProductServiceImpl;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/detail", "/product/detail"})
public class ProductDetailServlet extends HttpServlet {

    private final IProductService productService = new ProductServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        long productId = 1; // Mặc định ID 1 nếu chưa truyền
        try {
            if (idStr != null && !idStr.trim().isEmpty()) {
                productId = Long.parseLong(idStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        // 1. Lấy thông tin sản phẩm chi tiết qua Service
        Product product = productService.getProductById(productId);

        if (product == null) {
            // Nếu không tìm thấy, lấy sản phẩm ID 1 làm fallback để giao diện luôn hiển thị đầy đủ
            product = productService.getProductById(1);
        }

        // 2. Lấy thông tin Shop sở hữu sản phẩm này qua Service
        long shopId = (product != null && product.getShopId() > 0) ? product.getShopId() : 1L;
        Shop shop = shopProductService.getShopById(shopId);
        if (shop == null) {
            shop = shopProductService.getShopById(1L);
        }
        int shopTotalProducts = shopProductService.getTotalProductsCountByShopId(shopId);

        // 3. Lấy danh sách sản phẩm liên quan gợi ý (You May Also Savor - 4 sản phẩm) qua Service
        List<Product> relatedProducts = productService.getRelatedProducts(productId, 4);

        // 4. Đưa ra request scope
        request.setAttribute("product", product);
        request.setAttribute("shop", shop);
        request.setAttribute("shopTotalProducts", shopTotalProducts);
        request.setAttribute("relatedProducts", relatedProducts);

        // 5. Forward sang trang JSP chi tiết
        request.getRequestDispatcher("/views/product/product-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
