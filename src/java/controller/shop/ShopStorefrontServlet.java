package controller.shop;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;
import model.Review;
import model.Shop;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopStorefrontServlet", urlPatterns = {"/shop/storefront", "/store", "/shop/view", "/shop/home", "/shop-detail"})
public class ShopStorefrontServlet extends HttpServlet {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. Lấy shopId hoặc slug từ parameter
        String idParam = request.getParameter("id");
        String slugParam = request.getParameter("slug");

        long shopId = 1L; // Mặc định shop 1 (Nông Trại Hữu Cơ Mộc Châu)
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                shopId = Long.parseLong(idParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        // 2. Lấy thông tin Shop qua Service
        Shop shop = null;
        if (slugParam != null && !slugParam.trim().isEmpty()) {
            shop = shopProductService.getShopBySlug(slugParam.trim());
        }
        if (shop == null) {
            shop = shopProductService.getShopById(shopId);
        }
        if (shop == null) {
            shop = shopProductService.getShopById(1L);
        }

        long activeShopId = shop != null ? shop.getShopId() : 1L;

        // 3. Lọc theo Danh mục
        String catParam = request.getParameter("cat");
        Integer categoryId = null;
        if (catParam != null && !catParam.trim().isEmpty()) {
            try {
                categoryId = Integer.parseInt(catParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        // 4. Sắp xếp sản phẩm
        String sortParam = request.getParameter("sort");
        if (sortParam == null || sortParam.trim().isEmpty()) {
            sortParam = "featured";
        }

        // 5. Query dữ liệu từ Database qua Service
        List<Product> products = shopProductService.getProductsByShopId(activeShopId, categoryId, sortParam);
        List<Category> categories = shopProductService.getCategoriesWithCountByShopId(activeShopId);
        List<Review> reviews = shopProductService.getReviewsByShopId(activeShopId);

        // Tính tổng số lượng sản phẩm của shop
        int totalProductsCount = 0;
        if (categories != null && !categories.isEmpty()) {
            for (Category c : categories) {
                totalProductsCount += c.getProductCount();
            }
        }
        if (totalProductsCount == 0 && products != null) {
            totalProductsCount = products.size();
        }

        // 6. Truyền attributes ra Request Scope
        request.setAttribute("shop", shop);
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("totalProductsCount", totalProductsCount);
        request.setAttribute("selectedCatId", categoryId);
        request.setAttribute("selectedSort", sortParam);
        request.setAttribute("reviews", reviews);

        // 7. Forward sang trang giao diện
        request.getRequestDispatcher("/views/shop/shop-storefront.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

