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
import model.dto.product.ProductVariantDetailDTO;
import model.entity.user.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="ShopDeleteVariantServlet", urlPatterns={"/shop/product/variant/delete"})
public class ShopDeleteVariantServlet extends HttpServlet {

    private final IProductService productService = new ProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/shop/products");
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
        Long shopId = (Long) session.getAttribute("shopId");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long variantId = null;
        try {
            variantId = Long.parseLong(request.getParameter("variantId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }

        ProductVariantDetailDTO variant = productService.getShopVariantById(variantId, shopId);
        if (variant == null) {
            response.sendRedirect(request.getContextPath() + "/shop/products");
            return;
        }
        long productId = variant.getProductId();

        // Thực hiện xóa mềm
        boolean success = productService.softDeleteVariant(variantId, shopId);

        if (success) {
            session.setAttribute("successMessage", "Đã ẩn / xóa biến thể thành công!");
        } else {
            session.setAttribute("errorMessage", "Xóa biến thể thất bại!");
        }

        response.sendRedirect(request.getContextPath() + "/shop/product/variants?productId=" + productId);
    }
}
