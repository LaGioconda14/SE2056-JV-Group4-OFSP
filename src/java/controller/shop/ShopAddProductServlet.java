/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.shop;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import model.entity.product.Category;
import model.entity.user.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name = "ShopAddProductServlet", urlPatterns = {"/shop/product/add"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB tối đa cho 1 file ảnh
    maxRequestSize = 1024 * 1024 * 50     // 50MB tổng request
)
public class ShopAddProductServlet extends HttpServlet {

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

        request.getRequestDispatcher("/views/shop/products/add.jsp").forward(request, response);
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
            // Lấy thông tin từ form
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

            // AN TOÀN TUYỆT ĐỐI: Kiểm tra null/trống trước khi khởi tạo BigDecimal để tránh lỗi toCharArray()
            String priceStr = request.getParameter("price");
            BigDecimal price = (priceStr != null && !priceStr.trim().isEmpty()) 
                    ? new BigDecimal(priceStr.trim()) : BigDecimal.ZERO;

            String origPriceStr = request.getParameter("originalPrice");
            BigDecimal originalPrice = (origPriceStr != null && !origPriceStr.trim().isEmpty()) 
                    ? new BigDecimal(origPriceStr.trim()) : null;
            
            int stockQuantity = request.getParameter("stockQuantity") != null && !request.getParameter("stockQuantity").isEmpty() 
                    ? Integer.parseInt(request.getParameter("stockQuantity")) : 0;
            
            boolean isActive = request.getParameter("isActive") != null;

            // --- XỬ LÝ ẢNH CHÍNH (Ô 0): Kiểm tra file upload trước, nếu không có lấy URL text ---
            String coverImageUrl = "";
            Part filePart0 = request.getPart("imageFile0");
            if (filePart0 != null && filePart0.getSize() > 0) {
                coverImageUrl = saveUploadedFile(filePart0, request);
            } else {
                String urlInput0 = request.getParameter("coverImageUrl");
                if (urlInput0 != null && !urlInput0.trim().isEmpty() && !urlInput0.startsWith("Đã chọn:")) {
                    coverImageUrl = urlInput0.trim();
                }
            }

            // --- XỬ LÝ 4 ẢNH PHỤ (Ô 1 đến 4): Kiểm tra file upload hoặc URL tương ứng ---
            List<String> detailImages = new ArrayList<>();
            for (int i = 1; i <= 4; i++) {
                String imgPath = "";
                Part filePart = request.getPart("imageFile" + i);
                if (filePart != null && filePart.getSize() > 0) {
                    imgPath = saveUploadedFile(filePart, request);
                } else {
                    String urlInput = request.getParameter("detailImage" + i);
                    if (urlInput != null && !urlInput.trim().isEmpty() && !urlInput.startsWith("Đã chọn:")) {
                        imgPath = urlInput.trim();
                    }
                }
                
                if (!imgPath.isEmpty()) {
                    detailImages.add(imgPath);
                }
            }

            // Gọi Service thực thi
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
                request.getRequestDispatcher("/views/shop/products/add.jsp").forward(request, response);
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            reloadFormData(request);
            request.getRequestDispatcher("/views/shop/products/add.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            reloadFormData(request);
            request.getRequestDispatcher("/views/shop/products/add.jsp").forward(request, response);
        }
    }

    // Hàm phụ trợ lưu file ảnh vào thư mục assets/images/products của server
    private String saveUploadedFile(Part filePart, HttpServletRequest request) throws IOException {
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String ext = ".jpg";
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex > 0) {
            ext = fileName.substring(dotIndex).toLowerCase();
        }
        String uniqueFileName = "prod_" + System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + ext;

        String uploadDirRealPath = request.getServletContext().getRealPath("/assets/images/products");
        File uploadDir = new File(uploadDirRealPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String savedFilePath = uploadDirRealPath + File.separator + uniqueFileName;
        filePart.write(savedFilePath);

        // Đồng bộ sang thư mục source (web/assets/images/products) để khi Clean & Build không bị mất ảnh
        try {
            String devDirRealPath = uploadDirRealPath.replace(File.separator + "build" + File.separator + "web", File.separator + "web");
            File devDir = new File(devDirRealPath);
            if (devDir.exists() || devDir.mkdirs()) {
                java.nio.file.Files.copy(
                    Paths.get(savedFilePath),
                    Paths.get(devDirRealPath, uniqueFileName),
                    java.nio.file.StandardCopyOption.REPLACE_EXISTING
                );
            }
        } catch (Exception ignored) {
        }

        return request.getContextPath() + "/assets/images/products/" + uniqueFileName;
    }

    private void reloadFormData(HttpServletRequest request) {
        try {
            request.setAttribute("categories", productService.getAllCategories());
            request.setAttribute("certifications", productService.getAllCertifications());
            request.setAttribute("storageTemps", productService.getAllStorageTemps());
            request.setAttribute("units", productService.getAllUnits());
        } catch (Exception ignored) {}
    }
}