/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.shop;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name = "ShopDeleteProductServlet", urlPatterns = {"/shop/product/delete"})
public class ShopDeleteProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Long shopId = (Long) session.getAttribute("shopId");

        // Kiểm tra quyền chủ shop
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null && !productIdStr.trim().isEmpty()) {
                long productId = Long.parseLong(productIdStr);
                
                // Gọi hàm xóa mềm đồng thời sản phẩm cha và toàn bộ biến thể con
                boolean success = productService.softDeleteProductAndVariants(productId, shopId);

                if (success) {
                    session.setAttribute("successMessage", "Đã ngừng bán sản phẩm và toàn bộ biến thể thành công!");
                } else {
                    session.setAttribute("errorMessage", "Thao tác thất bại hoặc bạn không có quyền chỉnh sửa sản phẩm này!");
                }
            } else {
                session.setAttribute("errorMessage", "Mã sản phẩm không hợp lệ!");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Định dạng mã sản phẩm không hợp lệ!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }

        // Điều hướng về lại trang danh sách sản phẩm của shop
        response.sendRedirect(request.getContextPath() + "/shop/products");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
