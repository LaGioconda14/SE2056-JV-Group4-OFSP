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
import java.util.ArrayList;
import java.util.List;
import model.Category;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name = "ShopAddProductServlet", urlPatterns = {"/shop/product/add"})
public class ShopAddProductServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    private final IProductService productService = new ProductServiceImpl();
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
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

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
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
            // Lấy danh mục quả đổ ra dropdown
            List<Category> categories = productService.getAllCategories();
            request.setAttribute("categories", categories);
            // Lấy danh sách chứng nhận động từ database
            List<String> certifications = productService.getAllCertifications();
            request.setAttribute("certifications", certifications);
            // 3. Lấy danh sách nhiệt độ bảo quản gợi ý từ DB
            List<String> storageTemps = productService.getAllStorageTemps();
            request.setAttribute("storageTemps", storageTemps);
            //Lấy unit
            List<String> units = productService.getAllUnits();
            request.setAttribute("units", units);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/views/shop_product/shop-add-product.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
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

            BigDecimal price = new BigDecimal(request.getParameter("price"));
            BigDecimal originalPrice = request.getParameter("originalPrice") != null && !request.getParameter("originalPrice").trim().isEmpty() 
                    ? new BigDecimal(request.getParameter("originalPrice")) : null;
            
            int stockQuantity = request.getParameter("stockQuantity") != null && !request.getParameter("stockQuantity").isEmpty() 
                    ? Integer.parseInt(request.getParameter("stockQuantity")) : 0;
            
            boolean isActive = request.getParameter("isActive") != null;

            // Lấy danh sách 5 hình ảnh
            String coverImageUrl = request.getParameter("coverImageUrl");
            List<String> detailImages = new ArrayList<>();
            for (int i = 1; i <= 4; i++) {
                String imgUrl = request.getParameter("detailImage" + i);
                if (imgUrl != null && !imgUrl.trim().isEmpty()) {
                    detailImages.add(imgUrl.trim());
                }
            }

            // Gọi Service thực thi (Service đã đảm nhận toàn bộ việc Validate)
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
                request.getRequestDispatcher("/views/shop_product/shop-add-product.jsp").forward(request, response);
            }

        } catch (IllegalArgumentException e) {
            // Bắt lỗi do Service validate ném ra (VD: trùng SKU, giá <= 0, trống tên...)
            request.setAttribute("errorMessage", e.getMessage());
            reloadFormData(request);
            request.getRequestDispatcher("/views/shop_product/shop-add-product.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            reloadFormData(request);
            request.getRequestDispatcher("/views/shop_product/shop-add-product.jsp").forward(request, response);
        }
    }
    // Hàm phụ trợ nạp lại dữ liệu cho form khi forward báo lỗi
    private void reloadFormData(HttpServletRequest request) {
        try {
            request.setAttribute("categories", productService.getAllCategories());
            request.setAttribute("certifications", productService.getAllCertifications());
            request.setAttribute("storageTemps", productService.getAllStorageTemps());
            request.setAttribute("units", productService.getAllUnits());
        } catch (Exception ignored) {}
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
