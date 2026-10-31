package controller.shop;

import dao.ProductDAO;
import dao.ShopDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.Product;
import model.Review;
import model.Shop;
import model.User;

@WebServlet(name = "ShopStorefrontServlet", urlPatterns = {"/store", "/shop/storefront", "/shop/detail", "/shop-detail"})
public class ShopStorefrontServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ShopDAO shopDAO = new ShopDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        String slug = request.getParameter("slug");

        Long shopId = null;
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                shopId = Long.parseLong(idStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        Shop shop = null;
        if (slug != null && !slug.trim().isEmpty()) {
            shop = shopDAO.getShopBySlug(slug.trim());
        }
        if (shop == null && shopId != null) {
            shop = shopDAO.getShopById(shopId);
        }

        if (shop == null && (idStr == null || idStr.trim().isEmpty()) && (slug == null || slug.trim().isEmpty())) {
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                shop = shopDAO.getShopByOwnerId(user.getId());
            }
            if (shop == null) {
                shop = shopDAO.getFirstActiveShop();
            }
        }

        if (shop == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String catIdStr = request.getParameter("catId");
        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort");

        Integer selectedCatId = null;
        if (catIdStr != null && !catIdStr.trim().isEmpty()) {
            try {
                selectedCatId = Integer.parseInt(catIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        List<Product> products = productDAO.getProductsByShop(shop.getShopId(), selectedCatId, keyword, sort);
        List<Category> categories = productDAO.getCategoriesByShopId(shop.getShopId());
        List<Review> reviews = shopDAO.getReviewsByShopId(shop.getShopId());
        int totalProductsCount = shopDAO.getTotalProductsCountByShopId(shop.getShopId());

        String shopJoinedTime = "Từ khi thành lập";
        if (shop.getCreatedAt() != null) {
            long diffMillis = System.currentTimeMillis() - shop.getCreatedAt().getTime();
            long days = diffMillis / (1000 * 60 * 60 * 24);
            if (days < 30) {
                shopJoinedTime = Math.max(1, days) + " ngày trước";
            } else if (days < 365) {
                shopJoinedTime = (days / 30) + " tháng trước";
            } else {
                shopJoinedTime = (days / 365) + " năm trước";
            }
        }

        boolean isOwner = false;
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if (user != null && user.getId() == shop.getOwnerId()) {
                isOwner = true;
            }
        }

        request.setAttribute("shop", shop);
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("reviews", reviews);
        request.setAttribute("totalProductsCount", totalProductsCount);
        request.setAttribute("shopJoinedTime", shopJoinedTime);
        request.setAttribute("selectedCatId", selectedCatId);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("isOwner", isOwner);

        request.getRequestDispatcher("/views/shop/shop-storefront.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
