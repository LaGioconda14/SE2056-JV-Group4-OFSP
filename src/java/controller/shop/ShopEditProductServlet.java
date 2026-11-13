package controller.shop;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import model.entity.product.Category;
import model.dto.product.ProductDetailDTO;
import model.entity.user.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name="ShopEditProductServlet", urlPatterns={"/shop/product/edit"})
public class ShopEditProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

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

        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }

        try {
            // Bắt linh hoạt cả productId và id trên URL
            String idStr = request.getParameter("productId");
            if (idStr == null || idStr.trim().isEmpty()) {
                idStr = request.getParameter("id");
            }

            if (idStr != null && !idStr.trim().isEmpty()) {
                long productId = Long.parseLong(idStr.trim());
                ProductDetailDTO product = productService.getShopProductForEdit(productId, shopId);
                if (product == null) {
                    session.setAttribute("errorMessage", "Không tìm thấy sản phẩm hoặc bạn không có quyền chỉnh sửa!");
                    response.sendRedirect(request.getContextPath() + "/shop/products");
                    return;
                }
                request.setAttribute("product", product);

                // Nạp danh sách ảnh phụ nếu DTO có lưu danh sách images
                if (product.getImages() != null) {
                    List<String> subImages = new ArrayList<>();
                    for (String img : product.getImages()) {
                        if (img != null && !img.equals(product.getImage())) {
                            subImages.add(img);
                        }
                    }
                    if (subImages.size() > 0) request.setAttribute("detailImage1", subImages.get(0));
                    if (subImages.size() > 1) request.setAttribute("detailImage2", subImages.get(1));
                    if (subImages.size() > 2) request.setAttribute("detailImage3", subImages.get(2));
                    if (subImages.size() > 3) request.setAttribute("detailImage4", subImages.get(3));
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/shop/products");
                return;
            }

            loadDropdownData(request);

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi tải thông tin sản phẩm: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }

        request.getRequestDispatcher("/views/shop/shop-edit-product.jsp").forward(request, response);
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
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }

        long productId = 0;
        try {
            String productIdStr = request.getParameter("productId");
            productId = Long.parseLong(productIdStr.trim());

            String name = request.getParameter("name");
            String categoryIdStr = request.getParameter("categoryId");
            String origin = request.getParameter("origin");
            String storageTemp = request.getParameter("storageTemp");
            String certification = request.getParameter("certification");
            String description = request.getParameter("description");
            String isActiveStr = request.getParameter("isActive");
            String coverImageUrl = request.getParameter("coverImageUrl");

            // Lấy thêm 4 ảnh phụ từ form
            String detailImage1 = request.getParameter("detailImage1");
            String detailImage2 = request.getParameter("detailImage2");
            String detailImage3 = request.getParameter("detailImage3");
            String detailImage4 = request.getParameter("detailImage4");

            int categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) ? Integer.parseInt(categoryIdStr.trim()) : 0;
            boolean isActive = "true".equalsIgnoreCase(isActiveStr) || "on".equalsIgnoreCase(isActiveStr);

            // Gọi Service cập nhật thông tin chính
            boolean success = productService.updateFullProduct(
                shopId, productId, name, categoryId, origin, storageTemp,
                certification, description, isActive, coverImageUrl
            );

            if (success) {
                // Sử dụng session successMessage để flash-message.jsp hiển thị đồng bộ
                session.setAttribute("successMessage", "Cập nhật thông tin nông sản thành công!");
                response.sendRedirect(request.getContextPath() + "/shop/products");
            } else {
                session.setAttribute("errorMessage", "Cập nhật thông tin nông sản thất bại. Vui lòng kiểm tra lại dữ liệu!");
                reloadFormOnFailure(request, response, productId, shopId, detailImage1, detailImage2, detailImage3, detailImage4);
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            reloadFormOnFailure(request, response, productId, shopId,
                request.getParameter("detailImage1"),
                request.getParameter("detailImage2"),
                request.getParameter("detailImage3"),
                request.getParameter("detailImage4")
            );
        }
    }

    private void loadDropdownData(HttpServletRequest request) {
        List<Category> categories = productService.getAllCategories();
        request.setAttribute("categories", categories);
        request.setAttribute("certifications", productService.getAllCertifications());
        request.setAttribute("storageTemps", productService.getAllStorageTemps());
        request.setAttribute("units", productService.getAllUnits());
    }

    private void reloadFormOnFailure(HttpServletRequest request, HttpServletResponse response,
                                     long productId, Long shopId,
                                     String img1, String img2, String img3, String img4)
            throws ServletException, IOException {
        if (productId > 0) {
            ProductDetailDTO product = productService.getShopProductForEdit(productId, shopId);
            request.setAttribute("product", product);
        }
        request.setAttribute("detailImage1", img1);
        request.setAttribute("detailImage2", img2);
        request.setAttribute("detailImage3", img3);
        request.setAttribute("detailImage4", img4);
        loadDropdownData(request);
        request.getRequestDispatcher("/views/shop/shop-edit-product.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "ShopEditProductServlet";
    }
}