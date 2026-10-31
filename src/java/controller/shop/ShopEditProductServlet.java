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
import java.util.List;
import model.Category;
import model.ProductVariant;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name="ShopEditProductServlet", urlPatterns={"/shop/product/edit"})
public class ShopEditProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ShopEditProductServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ShopEditProductServlet at " + request.getContextPath () + "</h1>");
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
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                long variantId = Long.parseLong(idStr.trim());
                ProductVariant product = productService.getVariantById(variantId);
                request.setAttribute("product", product);
            }

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

        request.getRequestDispatcher("/views/shop/shop-edit-product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            shopId = 1L;
        }

        try {
            String variantIdStr = request.getParameter("variantId");
            String name = request.getParameter("name");
            String categoryIdStr = request.getParameter("categoryId");
            String origin = request.getParameter("origin");
            String storageTemp = request.getParameter("storageTemp");
            String certification = request.getParameter("certification");
            String description = request.getParameter("description");
            String sku = request.getParameter("sku");
            String variantName = request.getParameter("variantName");
            String unit = request.getParameter("unit");
            String priceStr = request.getParameter("price");
            String originalPriceStr = request.getParameter("originalPrice");
            String stockQuantityStr = request.getParameter("stockQuantity");
            String isActiveStr = request.getParameter("isActive");
            String coverImageUrl = request.getParameter("coverImageUrl");

            long variantId = Long.parseLong(variantIdStr);
            int categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) ? Integer.parseInt(categoryIdStr) : 0;
            BigDecimal price = (priceStr != null && !priceStr.trim().isEmpty()) ? new BigDecimal(priceStr) : BigDecimal.ZERO;
            BigDecimal originalPrice = (originalPriceStr != null && !originalPriceStr.trim().isEmpty()) ? new BigDecimal(originalPriceStr) : price;
            int stockQuantity = (stockQuantityStr != null && !stockQuantityStr.trim().isEmpty()) ? Integer.parseInt(stockQuantityStr) : 0;
            boolean isActive = "true".equalsIgnoreCase(isActiveStr) || "on".equalsIgnoreCase(isActiveStr);

            boolean success = productService.updateFullProduct(
                shopId, variantId, name, categoryId, origin, storageTemp, certification,
                description, sku, variantName, unit, price, originalPrice,
                stockQuantity, isActive, coverImageUrl
            );

            if (success) {
                response.sendRedirect(request.getContextPath() + "/shop/products?message=updated_success");
            } else {
                request.setAttribute("errorMessage", "Cập nhật thông tin nông sản thất bại. Vui lòng kiểm tra lại dữ liệu!");

                ProductVariant product = productService.getVariantById(variantId);
                request.setAttribute("product", product);
                request.setAttribute("categories", productService.getAllCategories());
                request.setAttribute("certifications", productService.getAllCertifications());
                request.setAttribute("storageTemps", productService.getAllStorageTemps());
                request.setAttribute("units", productService.getAllUnits());

                request.getRequestDispatcher("/views/shop/shop-edit-product.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("/views/shop/shop-edit-product.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
