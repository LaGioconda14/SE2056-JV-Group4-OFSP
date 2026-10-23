/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.shop_product;

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
import model.Shop;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="ShopEditProductServlet", urlPatterns={"/shop/product/edit"})
public class ShopEditProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
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
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // 1. Bắt linh hoạt mọi loại tên tham số truyền lên từ URL
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.trim().isEmpty()) {
                long variantId = Long.parseLong(idStr.trim());
                ProductVariant product = productService.getVariantById(variantId);
                request.setAttribute("product", product);
            }

            // 2. Lấy dữ liệu hỗ trợ cho dropdown / datalist
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

        // 3. Forward đúng sang trang chỉnh sửa JSP
        request.getRequestDispatcher("/views/shop_product/shop-edit-product.jsp").forward(request, response);
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
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Kiểm tra quyền hạn (Phải là chủ shop)
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Long shopId = (Long) session.getAttribute("shopId");

        try {
            // 2. Lấy tất cả các tham số từ form gửi lên
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

            // 3. Ép kiểu dữ liệu an toàn
            long variantId = Long.parseLong(variantIdStr);
            int categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) ? Integer.parseInt(categoryIdStr) : 0;
            BigDecimal price = (priceStr != null && !priceStr.trim().isEmpty()) ? new BigDecimal(priceStr) : BigDecimal.ZERO;
            BigDecimal originalPrice = (originalPriceStr != null && !originalPriceStr.trim().isEmpty()) ? new BigDecimal(originalPriceStr) : price;
            int stockQuantity = (stockQuantityStr != null && !stockQuantityStr.trim().isEmpty()) ? Integer.parseInt(stockQuantityStr) : 0;
            boolean isActive = "true".equalsIgnoreCase(isActiveStr) || "on".equalsIgnoreCase(isActiveStr);

            // 4. Gọi Service thực hiện cập nhật
            boolean success = productService.updateFullProduct(shopId,
                variantId, name, categoryId, origin, storageTemp, certification, 
                description, sku, variantName, unit, price, originalPrice, 
                stockQuantity, isActive, coverImageUrl
            );

            if (success) {
                // Cập nhật thành công -> Chuyển hướng về danh sách sản phẩm kèm thông báo
                response.sendRedirect(request.getContextPath() + "/shop/products?message=updated_success");
            } else {
                // Cập nhật thất bại -> Đẩy lại lỗi và giữ nguyên form
                request.setAttribute("errorMessage", "Cập nhật thông tin nông sản thất bại. Vui lòng kiểm tra lại dữ liệu!");
                
                // Load lại dữ liệu để form không bị rỗng khi render lại
                ProductVariant product = productService.getVariantById(variantId);
                request.setAttribute("product", product);
                request.setAttribute("categories", productService.getAllCategories());
                request.setAttribute("certifications", productService.getAllCertifications());
                request.setAttribute("storageTemps", productService.getAllStorageTemps());
                request.setAttribute("units", productService.getAllUnits());
                
                request.getRequestDispatcher("/views/shop_product/shop-edit-product.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("/views/shop_product/shop-edit-product.jsp").forward(request, response);
        }
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
