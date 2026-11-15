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

@WebServlet(name="SearchServlet", urlPatterns={"/search"})
public class SearchServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    /**
     * HÀM IN THÔNG TIN RA GIAO DIỆN (VIEW RENDERING)
     * Nhận dữ liệu đã chuẩn bị từ doGet và chuyển tiếp sang trang JSP để in ra màn hình.
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/views/product/product-search.jsp").forward(request, response);
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

        // 1. Keyword tìm kiếm
        String query = request.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            query = request.getParameter("keyword");
        }
        if (query != null) {
            query = query.trim();
        }

        // 2. Danh mục đã chọn (hỗ trợ cả multi-checkbox 'category' và đơn 'categoryId')
        String[] catArr = request.getParameterValues("category");
        List<String> selectedCategories = new ArrayList<>();
        if (catArr != null) {
            for (String c : catArr) {
                if (c != null && !c.trim().isEmpty() && !"all".equalsIgnoreCase(c.trim()) && !"0".equals(c.trim())) {
                    selectedCategories.add(c.trim());
                }
            }
        }
        String singleCatId = request.getParameter("categoryId");
        if (singleCatId != null && !singleCatId.trim().isEmpty() && !"all".equalsIgnoreCase(singleCatId.trim()) && !"0".equals(singleCatId.trim())) {
            if (!selectedCategories.contains(singleCatId.trim())) {
                selectedCategories.add(singleCatId.trim());
            }
        }

        // 3. Khoảng giá (minPrice, maxPrice)
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

        // 4. Tình trạng hàng (availability)
        String availability = request.getParameter("availability");
        Boolean inStockOnly = false;
        if ("in_stock".equalsIgnoreCase(availability) || "true".equalsIgnoreCase(availability) || "1".equals(availability)) {
            inStockOnly = true;
        }

        // 5. Thống kê danh mục phẳng có số lượng sản phẩm
        List<Category> listCategories = productService.getAllCategoriesWithCount();
        int inStockCount = productService.countInStockProducts();

        // 6. Lấy danh sách toàn bộ sản phẩm theo từ khóa và các tiêu chí lọc (không phân trang)
        List<ProductCardDTO> listProduct = productService.getFilteredCatalogProducts(
                query, selectedCategories, minPrice, maxPrice, null, null, inStockOnly, "featured", 0, 0
        );

        // Lưu toàn bộ dữ liệu đã xử lý vào Request Attributes
        request.setAttribute("txtSearch", query != null ? query : "");
        request.setAttribute("paramKeyword", query != null ? query : "");
        request.setAttribute("selectedCategoriesList", selectedCategories);
        request.setAttribute("minPrice", minPriceStr);
        request.setAttribute("maxPrice", maxPriceStr);
        request.setAttribute("paramMinPrice", minPrice);
        request.setAttribute("paramMaxPrice", maxPrice);
        request.setAttribute("selectedAvailability", availability);
        request.setAttribute("paramAvailability", availability);
        request.setAttribute("inStockCount", inStockCount);

        request.setAttribute("listCategories", listCategories);
        request.setAttribute("listProduct", listProduct);
        request.setAttribute("listProducts", listProduct);
        request.setAttribute("totalProducts", listProduct != null ? listProduct.size() : 0);

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
        return "Search and Filter Servlet";
    }
}
