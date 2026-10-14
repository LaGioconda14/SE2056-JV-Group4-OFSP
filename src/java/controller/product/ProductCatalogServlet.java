package controller.product;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ProductCatalogServlet", urlPatterns = {"/products", "/shop"})
public class ProductCatalogServlet extends HttpServlet {

    private final IProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. Lấy parameters bộ lọc
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            keyword = request.getParameter("query"); // Hỗ trợ cả 2 tên param
        }
        
        String[] selectedCategories = request.getParameterValues("category");
        if (selectedCategories == null && request.getParameter("categoryId") != null) {
            selectedCategories = new String[]{request.getParameter("categoryId")};
        }

        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        Double minPrice = null;
        Double maxPrice = null;
        try {
            if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
                minPrice = Double.parseDouble(minPriceStr.trim());
            }
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                maxPrice = Double.parseDouble(maxPriceStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        String ratingStr = request.getParameter("rating");
        Integer rating = null;
        try {
            if (ratingStr != null && !ratingStr.trim().isEmpty()) {
                rating = Integer.parseInt(ratingStr.trim());
            }
        } catch (NumberFormatException ignored) {}

        String availability = request.getParameter("availability"); // in_stock
        String origin = request.getParameter("origin");
        String tag = request.getParameter("tag"); // organic, sale, under5, citrus, berries
        String sortBy = request.getParameter("sortBy"); // featured, price_asc, price_desc, rating
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "featured";
        }

        // 2. Phân trang
        int page = 1;
        int pageSize = 12; // 12 sản phẩm trên 1 trang giống ảnh mockup
        String pageStr = request.getParameter("page");
        try {
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                page = Integer.parseInt(pageStr.trim());
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException ignored) {}

        // 3. Truy vấn dữ liệu qua Service
        int totalProducts = productService.countCatalogProducts(keyword, selectedCategories, minPrice, maxPrice, rating, availability, origin, tag);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        if (totalPages < 1) totalPages = 1;

        List<Product> listProducts = productService.getCatalogProducts(keyword, selectedCategories, minPrice, maxPrice, rating, availability, origin, tag, sortBy, page, pageSize);
        List<Category> listCategories = productService.getAllCategories();

        // 4. Đẩy attributes ra request scope
        request.setAttribute("listProducts", listProducts);
        request.setAttribute("listCategories", listCategories);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", pageSize);

        // Giữ lại trạng thái lọc trên giao diện
        request.setAttribute("paramKeyword", keyword);
        request.setAttribute("selectedCategoriesList", selectedCategories != null ? Arrays.asList(selectedCategories) : null);
        request.setAttribute("paramMinPrice", minPrice);
        request.setAttribute("paramMaxPrice", maxPrice);
        request.setAttribute("paramRating", rating);
        request.setAttribute("paramAvailability", availability);
        request.setAttribute("paramOrigin", origin);
        request.setAttribute("paramTag", tag);
        request.setAttribute("paramSortBy", sortBy);

        String selectedCategoryName = null;
        if (selectedCategories != null && selectedCategories.length == 1) {
            String targetCat = selectedCategories[0];
            for (Category c : listCategories) {
                if (String.valueOf(c.getCategoryId()).equals(targetCat) || (c.getSlug() != null && c.getSlug().equalsIgnoreCase(targetCat))) {
                    selectedCategoryName = c.getCategoryName();
                    break;
                }
            }
        }
        request.setAttribute("selectedCategoryName", selectedCategoryName);

        // 5. Forward ra JSP giao diện
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

