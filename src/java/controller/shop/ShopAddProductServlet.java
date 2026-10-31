package controller.shop;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopAddProductServlet", urlPatterns = {"/shop/product/add"})
public class ShopAddProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ShopAddProductServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ShopAddProductServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        try {
            List<Category> categories = productService.getAllCategories();
            request.setAttribute("categories", categories);

            List<String> certifications = productService.getAllCertifications();
            request.setAttribute("certifications", certifications);

            List<String> storageTemps = productService.getAllStorageTemps();
            request.setAttribute("storageTemps", storageTemps);

            List<String> units = productService.getAllUnits();
            request.setAttribute("units", units);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/views/shop/shop-add-product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Long shopId = (Long) session.getAttribute("shopId");

        if (shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String name = request.getParameter("name");
            int categoryId = request.getParameter("categoryId") != null && !request.getParameter("categoryId").isEmpty()
                    ? Integer.parseInt(request.getParameter("categoryId")) : 0;
            String origin = request.getParameter("origin");
            String storageTemp = request.getParameter("storageTemp");
            String certification = request.getParameter("certification");
            String description = request.getParameter("description");

            String sku = request.getParameter("sku");
            String variantName = request.getParameter("variantName");
            String unit = request.getParameter("unit");

            BigDecimal price = new BigDecimal(request.getParameter("price"));
            BigDecimal originalPrice = request.getParameter("originalPrice") != null && !request.getParameter("originalPrice").trim().isEmpty()
                    ? new BigDecimal(request.getParameter("originalPrice")) : null;

            int stockQuantity = request.getParameter("stockQuantity") != null && !request.getParameter("stockQuantity").isEmpty()
                    ? Integer.parseInt(request.getParameter("stockQuantity")) : 0;

            boolean isActive = request.getParameter("isActive") != null;

            String coverImageUrl = request.getParameter("coverImageUrl");
            List<String> detailImages = new ArrayList<>();
            for (int i = 1; i <= 4; i++) {
                String imgUrl = request.getParameter("detailImage" + i);
                if (imgUrl != null && !imgUrl.trim().isEmpty()) {
                    detailImages.add(imgUrl.trim());
                }
            }

            long newProductId = productService.insertFullProduct(
                    shopId, name, categoryId, origin, storageTemp, certification, description,
                    sku, variantName, unit, price, originalPrice, stockQuantity, 10,
                    isActive, coverImageUrl, detailImages, "Chuẩn Vườn"
            );

            if (newProductId > 0) {
                session.setAttribute("successMessage", "Thêm mới nông sản thành công!");
                response.sendRedirect(request.getContextPath() + "/shop/products");
            } else {
                request.setAttribute("errorMessage", "Thêm sản phẩm thất bại, vui lòng kiểm tra lại thông tin!");
                reloadFormData(request);
                request.getRequestDispatcher("/views/shop/shop-add-product.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            reloadFormData(request);
            request.getRequestDispatcher("/views/shop/shop-add-product.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            reloadFormData(request);
            request.getRequestDispatcher("/views/shop/shop-add-product.jsp").forward(request, response);
        }
    }

    private void reloadFormData(HttpServletRequest request) {
        try {
            request.setAttribute("categories", productService.getAllCategories());
            request.setAttribute("certifications", productService.getAllCertifications());
            request.setAttribute("storageTemps", productService.getAllStorageTemps());
            request.setAttribute("units", productService.getAllUnits());
        } catch (Exception ignored) {}
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
