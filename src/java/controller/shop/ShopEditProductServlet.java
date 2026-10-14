package controller.shop;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.ProductVariant;
import model.User;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopEditProductServlet", urlPatterns = {
    "/shop/product/edit", 
    "/shop/products/edit",
    "/shop/product/toggle",
    "/shop/product/delete"
})
public class ShopEditProductServlet extends HttpServlet {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Lấy shopId
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            } else {
                shopId = 1L;
                session.setAttribute("shopId", shopId);
            }
        }

        String path = request.getServletPath();

        // 3. Xử lý Toggle Ẩn / Hiện nếu gọi route /toggle
        if ("/shop/product/toggle".equals(path)) {
            try {
                String idParam = request.getParameter("id");
                if (idParam != null && !idParam.trim().isEmpty()) {
                    long variantId = Long.parseLong(idParam.trim());
                    shopProductService.toggleVariantStatus(variantId, shopId);
                    session.setAttribute("successMessage", "Thay đổi trạng thái kinh doanh của sản phẩm thành công!");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Lỗi đổi trạng thái: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }

        // 4. Xử lý Xóa nếu gọi route /delete
        if ("/shop/product/delete".equals(path)) {
            try {
                String idParam = request.getParameter("id");
                if (idParam != null && !idParam.trim().isEmpty()) {
                    long variantId = Long.parseLong(idParam.trim());
                    shopProductService.deleteVariant(variantId, shopId);
                    session.setAttribute("successMessage", "Xóa sản phẩm thành công!");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Lỗi xóa sản phẩm: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }

        // 5. Hiển thị màn hình chỉnh sửa
        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }

            long variantId = Long.parseLong(idParam.trim());
            ProductVariant product = shopProductService.getVariantDetailForEdit(variantId, shopId);

            if (product == null) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin sản phẩm cần sửa!");
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }

            List<Category> categories = shopProductService.getAllCategories();
            request.setAttribute("product", product);
            request.setAttribute("categories", categories);

            request.getRequestDispatcher("/views/shop/shop-product-edit.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi tải thông tin sản phẩm: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/shop/products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null || shopId <= 0) {
            shopId = 1L;
            session.setAttribute("shopId", shopId);
        }

        try {
            String variantIdStr = request.getParameter("variantId");
            String productIdStr = request.getParameter("productId");

            if (variantIdStr == null || productIdStr == null) {
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }

            long variantId = Long.parseLong(variantIdStr.trim());
            long productId = Long.parseLong(productIdStr.trim());

            String name = request.getParameter("name");
            String categoryIdStr = request.getParameter("categoryId");
            String origin = request.getParameter("origin");
            String storageTemp = request.getParameter("storageTemp");
            String[] certsArray = request.getParameterValues("certifications");
            String description = request.getParameter("description");

            String unit = request.getParameter("unit");
            String sku = request.getParameter("sku");
            String originalPriceStr = request.getParameter("originalPrice");
            String priceStr = request.getParameter("price");
            String stockQuantityStr = request.getParameter("stockQuantity");
            String lowStockThresholdStr = request.getParameter("lowStockThreshold");
            String status = request.getParameter("status"); // active / hidden
            boolean isActive = "active".equalsIgnoreCase(status) || "true".equalsIgnoreCase(status) || "1".equals(status);

            String coverImage = request.getParameter("coverImage");
            String imgDetail1 = request.getParameter("imgDetail1");
            String imgDetail2 = request.getParameter("imgDetail2");
            String imgDetail3 = request.getParameter("imgDetail3");
            String imgDetail4 = request.getParameter("imgDetail4");

            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Tên sản phẩm nông sản không được để trống!");
                doGet(request, response);
                return;
            }

            int categoryId = 1;
            try {
                if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                    categoryId = Integer.parseInt(categoryIdStr.trim());
                }
            } catch (NumberFormatException ignored) {}

            if (origin == null || origin.trim().isEmpty()) {
                origin = "Đà Lạt, Lâm Đồng";
            }
            if (storageTemp == null || storageTemp.trim().isEmpty()) {
                storageTemp = "Kho lạnh 2°C - 8°C";
            }

            StringBuilder certSb = new StringBuilder();
            if (certsArray != null && certsArray.length > 0) {
                for (String cert : certsArray) {
                    if (cert != null && !cert.trim().isEmpty()) {
                        if (certSb.length() > 0) certSb.append(", ");
                        certSb.append(cert.trim());
                    }
                }
            }
            String certification = certSb.length() > 0 ? certSb.toString() : "VietGAP";

            BigDecimal originalPrice = new BigDecimal("125000");
            try {
                if (originalPriceStr != null && !originalPriceStr.trim().isEmpty()) {
                    String clean = originalPriceStr.replaceAll("[^0-9.]", "");
                    if (!clean.isEmpty()) originalPrice = new BigDecimal(clean);
                }
            } catch (Exception ignored) {}

            BigDecimal price = new BigDecimal("98000");
            try {
                if (priceStr != null && !priceStr.trim().isEmpty()) {
                    String clean = priceStr.replaceAll("[^0-9.]", "");
                    if (!clean.isEmpty()) price = new BigDecimal(clean);
                } else {
                    price = originalPrice;
                }
            } catch (Exception ignored) {}

            int stockQuantity = 100;
            try {
                if (stockQuantityStr != null && !stockQuantityStr.trim().isEmpty()) {
                    stockQuantity = Integer.parseInt(stockQuantityStr.replaceAll("[^0-9]", ""));
                }
            } catch (Exception ignored) {}

            int lowStockThreshold = 15;
            try {
                if (lowStockThresholdStr != null && !lowStockThresholdStr.trim().isEmpty()) {
                    lowStockThreshold = Integer.parseInt(lowStockThresholdStr.replaceAll("[^0-9]", ""));
                }
            } catch (Exception ignored) {}

            List<String> detailImageUrls = new ArrayList<>();
            if (imgDetail1 != null && !imgDetail1.trim().isEmpty()) detailImageUrls.add(imgDetail1.trim());
            if (imgDetail2 != null && !imgDetail2.trim().isEmpty()) detailImageUrls.add(imgDetail2.trim());
            if (imgDetail3 != null && !imgDetail3.trim().isEmpty()) detailImageUrls.add(imgDetail3.trim());
            if (imgDetail4 != null && !imgDetail4.trim().isEmpty()) detailImageUrls.add(imgDetail4.trim());

            shopProductService.updateFullProduct(
                shopId, productId, variantId, name.trim(), categoryId, origin, storageTemp,
                certification, description, sku, unit, unit, price, originalPrice,
                stockQuantity, lowStockThreshold, isActive, coverImage, detailImageUrls
            );

            session.setAttribute("successMessage", "Cập nhật sản phẩm nông sản '" + name.trim() + "' thành công!");
            response.sendRedirect(request.getContextPath() + "/shop/products");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi cập nhật sản phẩm: " + e.getMessage());
            doGet(request, response);
        }
    }
}

