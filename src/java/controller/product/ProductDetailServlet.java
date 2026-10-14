package controller.product;

import dao.ProductDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/detail", "/product/detail"})
public class ProductDetailServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

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

        // 1. Lấy thông tin sản phẩm chi tiết
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            // Nếu không tìm thấy, lấy sản phẩm ID 1 làm fallback để giao diện luôn hiển thị đầy đủ
            product = productDAO.getProductById(1);
        }

        // 2. Lấy danh sách sản phẩm liên quan gợi ý (You May Also Savor - 4 sản phẩm)
        List<Product> relatedProducts = productDAO.getRelatedProducts(productId, 4);

        // 3. Đưa ra request scope
        request.setAttribute("product", product);
        request.setAttribute("relatedProducts", relatedProducts);

        // 4. Forward sang trang JSP chi tiết
        request.getRequestDispatcher("/views/product/product-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}

