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
import model.User;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopAddProductServlet", urlPatterns = {"/shop/product/add", "/shop/products/add"})
public class ShopAddProductServlet extends HttpServlet {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập và phân quyền chủ shop
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

        try {
            // 3. Tải danh sách danh mục để đổ vào Dropdown
            List<Category> categories = shopProductService.getAllCategories();
            request.setAttribute("categories", categories);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải danh mục sản phẩm: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/shop/shop-product-add.jsp").forward(request, response);
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
        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId == null || shopId <= 0) {
                shopId = 1L;
            }
            session.setAttribute("shopId", shopId);
        }

        String action = request.getParameter("action");
        boolean isPublish = "publish".equalsIgnoreCase(action);

        String name = request.getParameter("name");
        String categoryIdStr = request.getParameter("categoryId");
        String origin = request.getParameter("origin");
        String storageTemp = request.getParameter("storageTemp");
        String[] certsArray = request.getParameterValues("certifications");
        String description = request.getParameter("description");

        String unit = request.getParameter("unit");
        String originalPriceStr = request.getParameter("originalPrice");
        String priceStr = request.getParameter("price");
        String stockQuantityStr = request.getParameter("stockQuantity");
        String lowStockThresholdStr = request.getParameter("lowStockThreshold");

        String coverImage = request.getParameter("coverImage");
        String imgDetail1 = request.getParameter("imgDetail1");
        String imgDetail2 = request.getParameter("imgDetail2");
        String imgDetail3 = request.getParameter("imgDetail3");
        String imgDetail4 = request.getParameter("imgDetail4");

        String[] shippingArray = request.getParameterValues("shippingStandard");

        // Parse and sanitize
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập tên sản phẩm nông sản!");
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
            for (int i = 0; i < certsArray.length; i++) {
                if (certsArray[i] != null && !certsArray[i].trim().isEmpty()) {
                    if (certSb.length() > 0) certSb.append(", ");
                    certSb.append(certsArray[i].trim());
                }
            }
        }
        String certification = certSb.length() > 0 ? certSb.toString() : "VietGAP";

        if (unit == null || unit.trim().isEmpty()) {
            unit = "Hộp (500g - 1kg)";
        }

        BigDecimal originalPrice = new BigDecimal("125000");
        try {
            if (originalPriceStr != null && !originalPriceStr.trim().isEmpty()) {
                String cleanNum = originalPriceStr.replaceAll("[^0-9.]", "");
                if (!cleanNum.isEmpty()) {
                    originalPrice = new BigDecimal(cleanNum);
                }
            }
        } catch (Exception ignored) {}

        BigDecimal price = new BigDecimal("98000");
        try {
            if (priceStr != null && !priceStr.trim().isEmpty()) {
                String cleanNum = priceStr.replaceAll("[^0-9.]", "");
                if (!cleanNum.isEmpty()) {
                    price = new BigDecimal(cleanNum);
                }
            } else {
                price = originalPrice;
            }
        } catch (Exception ignored) {}

        int stockQuantity = 150;
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

        // Cover image fallback
        if (coverImage == null || coverImage.trim().isEmpty()) {
            coverImage = "https://images.unsplash.com/photo-1543528176-61b239494933?w=800&auto=format&fit=crop&q=80";
        }

        List<String> detailImageUrls = new ArrayList<>();
        if (imgDetail1 != null && !imgDetail1.trim().isEmpty()) detailImageUrls.add(imgDetail1.trim());
        if (imgDetail2 != null && !imgDetail2.trim().isEmpty()) detailImageUrls.add(imgDetail2.trim());
        if (imgDetail3 != null && !imgDetail3.trim().isEmpty()) detailImageUrls.add(imgDetail3.trim());
        if (imgDetail4 != null && !imgDetail4.trim().isEmpty()) detailImageUrls.add(imgDetail4.trim());

        // Default 4 detail images matching mockup if none entered
        if (detailImageUrls.isEmpty()) {
            detailImageUrls.add("https://images.unsplash.com/photo-1588615419957-6627063d81b4?w=400&auto=format&fit=crop&q=80"); // Cuống
            detailImageUrls.add("https://images.unsplash.com/photo-1518635017498-87f514b751ba?w=400&auto=format&fit=crop&q=80"); // Cắt lát
            detailImageUrls.add("https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&auto=format&fit=crop&q=80"); // Tem QR
            detailImageUrls.add("https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=400&auto=format&fit=crop&q=80"); // 1 Hộp
        }

        StringBuilder shippingSb = new StringBuilder();
        if (shippingArray != null && shippingArray.length > 0) {
            for (String ship : shippingArray) {
                if (ship != null && !ship.trim().isEmpty()) {
                    if (shippingSb.length() > 0) shippingSb.append(", ");
                    shippingSb.append(ship.trim());
                }
            }
        }
        String shippingStandard = shippingSb.length() > 0 ? shippingSb.toString() : "Chuỗi Lạnh FreshCold 2H, Hái tươi trong ngày";

        String sku = request.getParameter("sku");

        try {
            long productId = shopProductService.addFullProduct(
                shopId, name.trim(), categoryId, origin, storageTemp, certification, description,
                sku, unit, unit, price, originalPrice, stockQuantity, lowStockThreshold,
                isPublish, coverImage, detailImageUrls, shippingStandard
            );

            session.setAttribute("successMessage", "Thêm mới và " + (isPublish ? "phát hành" : "lưu nháp") + " sản phẩm nông sản '" + name.trim() + "' thành công!");
            response.sendRedirect(request.getContextPath() + "/shop/products");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi lưu sản phẩm: " + e.getMessage());
            doGet(request, response);
        }
    }
}

