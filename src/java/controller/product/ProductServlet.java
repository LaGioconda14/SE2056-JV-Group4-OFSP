package controller.product;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name="ProductsServlet", urlPatterns={"/products"})
public class ProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Keyword search
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            keyword = request.getParameter("query"); // fallback từ header search
        }
        if (keyword != null) {
            keyword = keyword.trim();
        }

        // 2. Categories filter (hỗ trợ cả multi-checkbox và single param)
        String[] catArr = request.getParameterValues("category");
        List<String> selectedCategories = new ArrayList<>();
        if (catArr != null) {
            for (String c : catArr) {
                if (c != null && !c.trim().isEmpty() && !"all".equalsIgnoreCase(c.trim())) {
                    selectedCategories.add(c.trim());
                }
            }
        }
        // Fallback parameter "categoryId" nếu có
        String singleCatId = request.getParameter("categoryId");
        if (singleCatId != null && !singleCatId.trim().isEmpty() && !selectedCategories.contains(singleCatId.trim())) {
            selectedCategories.add(singleCatId.trim());
        }

        // 3. Price range filter
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        BigDecimal minPrice = null;
        BigDecimal maxPrice = null;
        try {
            if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
                minPrice = new BigDecimal(minPriceStr.trim().replaceAll("[^0-9.]", ""));
            }
        } catch (Exception ignored) {}
        try {
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                maxPrice = new BigDecimal(maxPriceStr.trim().replaceAll("[^0-9.]", ""));
            }
        } catch (Exception ignored) {}

        // 4. Rating filter
        String ratingStr = request.getParameter("rating");
        Double minRating = null;
        if (ratingStr != null && !ratingStr.trim().isEmpty()) {
            try {
                minRating = Double.parseDouble(ratingStr.trim());
            } catch (Exception ignored) {}
        }

        // 5. Origin filter (hỗ trợ nhiều checkbox)
        String[] originArr = request.getParameterValues("origin");
        List<String> selectedOrigins = new ArrayList<>();
        if (originArr != null) {
            for (String o : originArr) {
                if (o != null && !o.trim().isEmpty()) {
                    selectedOrigins.add(o.trim());
                }
            }
        }

        // 6. Availability filter
        String availability = request.getParameter("availability");
        Boolean inStockOnly = false;
        if ("in_stock".equalsIgnoreCase(availability) || "true".equalsIgnoreCase(availability) || "1".equals(availability)) {
            inStockOnly = true;
        }

        // 7. Sort by
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "featured";
        } else {
            sortBy = sortBy.trim();
        }

        // 8. Pagination
        int page = 1;
        int pageSize = 12; // 3 hàng x 4 cột theo đúng layout ảnh mẫu
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr.trim());
                if (page < 1) page = 1;
            } catch (Exception ignored) {
                page = 1;
            }
        }

        // 9. Lấy dữ liệu danh mục kèm số lượng & thống kê
        List<Category> listCategories = productService.getAllCategoriesWithCount();
        Map<String, Integer> listOrigins = productService.getOriginsWithCount();
        int inStockCount = productService.countInStockProducts();
        BigDecimal[] dbMinMax = productService.getMinMaxProductPrices();

        // 10. Query sản phẩm theo bộ lọc
        List<Product> listProducts = productService.getFilteredCatalogProducts(
                keyword, selectedCategories, minPrice, maxPrice, minRating, selectedOrigins, inStockOnly, sortBy, page, pageSize
        );
        int totalProducts = productService.countFilteredCatalogProducts(
                keyword, selectedCategories, minPrice, maxPrice, minRating, selectedOrigins, inStockOnly
        );
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        // 11. Đẩy dữ liệu sang JSP
        request.setAttribute("listProducts", listProducts);
        request.setAttribute("listProduct", listProducts); // Tương thích ngược
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("listCategories", listCategories);
        request.setAttribute("categories", listCategories); // Tương thích ngược
        request.setAttribute("listOrigins", listOrigins);
        request.setAttribute("inStockCount", inStockCount);
        request.setAttribute("dbMinPrice", dbMinMax[0]);
        request.setAttribute("dbMaxPrice", dbMinMax[1]);

        request.setAttribute("selectedCategoriesList", selectedCategories);
        request.setAttribute("selectedCategory", selectedCategories.isEmpty() ? null : selectedCategories.get(0));
        request.setAttribute("selectedOriginsList", selectedOrigins);
        request.setAttribute("paramKeyword", keyword);
        request.setAttribute("paramMinPrice", minPrice);
        request.setAttribute("paramMaxPrice", maxPrice);
        request.setAttribute("paramRating", minRating != null ? minRating.intValue() : null);
        request.setAttribute("paramAvailability", availability);
        request.setAttribute("paramSortBy", sortBy);

        // 12. Forward sang giao diện sản phẩm catalog
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
