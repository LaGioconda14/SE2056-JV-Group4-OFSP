package controller.product;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.entity.product.Category;
import model.dto.product.ProductCardDTO;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name="ProductsServlet", urlPatterns={"/products"})
public class ProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    /**
     * HÀM IN THÔNG TIN RA GIAO DIỆN (VIEW RENDERING)
     * Nhận dữ liệu đã xử lý từ doGet và chuyển tiếp sang trang JSP để in ra màn hình.
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/views/product/product-list.jsp").forward(request, response);
    }

    /**
     * HÀM XỬ LÝ DỮ LIỆU & BỘ LỌC TÌM KIẾM (LOGIC PROCESSING)
     * Phụ trách tiếp nhận các tham số tìm kiếm, khoảng giá, danh mục, truy vấn CSDL
     * rồi gọi processRequest để in dữ liệu ra JSP.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        // 1. Categories filter (hỗ trợ cả multi-checkbox và single param)
        String[] catArr = request.getParameterValues("category");
        List<String> selectedCategories = new ArrayList<>();
        if (catArr != null) {
            for (String c : catArr) {
                if (c != null && !c.trim().isEmpty() && !"all".equalsIgnoreCase(c.trim())) {
                    selectedCategories.add(c.trim());
                }
            }
        }
        // Nhận thêm categoryId hoặc categorySlug nếu người dùng đi từ menu
        String singleCatId = request.getParameter("categoryId");
        if (singleCatId != null && !singleCatId.trim().isEmpty() && !selectedCategories.contains(singleCatId.trim())) {
            selectedCategories.add(singleCatId.trim());
        }
        String singleCatSlug = request.getParameter("categorySlug");
        if (singleCatSlug != null && !singleCatSlug.trim().isEmpty() && !selectedCategories.contains(singleCatSlug.trim())) {
            selectedCategories.add(singleCatSlug.trim());
        }

        // 2. Price range filter
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

        // 3. Sort by
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "featured";
        } else {
            sortBy = sortBy.trim();
        }

        // 4. Lấy dữ liệu danh mục phẳng kèm số lượng sản phẩm
        List<Category> listCategories = productService.getAllCategoriesWithCount();

        // 5. Query toàn bộ sản phẩm theo bộ lọc (không phân trang)
        List<ProductCardDTO> listProducts = productService.getFilteredCatalogProducts(
                null, selectedCategories, minPrice, maxPrice, null, null, null, sortBy, 0, 0
        );
        int totalProducts = listProducts != null ? listProducts.size() : 0;

        // Lưu toàn bộ dữ liệu đã xử lý vào Request Attributes
        request.setAttribute("listProducts", listProducts);
        request.setAttribute("totalProducts", totalProducts);

        request.setAttribute("listCategories", listCategories);

        request.setAttribute("selectedCategoriesList", selectedCategories);
        request.setAttribute("paramMinPrice", minPrice);
        request.setAttribute("paramMaxPrice", maxPrice);
        request.setAttribute("paramSortBy", sortBy);

        // Sau khi xử lý xong dữ liệu, gọi processRequest để in thông tin ra JSP
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Products Catalog Servlet";
    }
}
