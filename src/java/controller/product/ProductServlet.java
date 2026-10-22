/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.product;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.Category;
import model.Product;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="ProductsServlet", urlPatterns={"/products"})
public class ProductServlet extends HttpServlet {
    private IProductService productService = new ProductServiceImpl();
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
        request.setCharacterEncoding("UTF-8");
        
        // 1. Lấy tham số category slug từ URL khi người dùng bấm vào danh mục
        String categorySlug = request.getParameter("category");
        String keyword = request.getParameter("keyword");
        String minPrice = request.getParameter("minPrice");
        String maxPrice = request.getParameter("maxPrice");
        String rating = request.getParameter("rating");
        String availability = request.getParameter("availability");
        String origin = request.getParameter("origin");
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "default";
        }

        List<Product> listProduct = productService.searchAndFilterProducts(
                keyword, categorySlug, minPrice, maxPrice, rating, availability, origin, sortBy);
        
        // 3. Lấy toàn bộ danh mục từ CategoryDAO (thông qua Service) để đổ ra sidebar bên trái
        List<Category> categories = productService.getAllCategories();
        
        // 4. Đẩy dữ liệu sang trang JSP
        request.setAttribute("listProduct", listProduct);
        request.setAttribute("categories", categories);
        request.setAttribute("selectedCategory", categorySlug);
        request.setAttribute("keyword", keyword);
        request.setAttribute("minPrice", minPrice);
        request.setAttribute("maxPrice", maxPrice);
        request.setAttribute("selectedRating", rating);
        request.setAttribute("selectedAvailability", availability);
        request.setAttribute("origin", origin);
        request.setAttribute("sortBy", sortBy);
        
        // 5. Chuyển hướng tới giao diện productlist-by-category.jsp
        request.getRequestDispatcher("/views/product/productlist-by-category.jsp").forward(request, response);
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
        processRequest(request, response);
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
        processRequest(request, response);
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
