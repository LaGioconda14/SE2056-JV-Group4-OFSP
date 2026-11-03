/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.shop;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ProductVariant;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="ShopDeleteVariantServlet", urlPatterns={"/shop/product/variant/delete"})
public class ShopDeleteVariantServlet extends HttpServlet {
   
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
            out.println("<title>Servlet ShopDeleteVariantServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ShopDeleteVariantServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    private final IProductService productService = new ProductServiceImpl();
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

        ProductVariant variant = productService.getShopVariantById(variantId, shopId);
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

        ProductVariant variant = productService.getShopVariantById(variantId, shopId);
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

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
