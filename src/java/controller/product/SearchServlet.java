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
@WebServlet(name="SearchServlet", urlPatterns={"/search"})
public class SearchServlet extends HttpServlet {
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
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet SearchServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SearchServlet at " + request.getContextPath () + "</h1>");
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
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        String query = request.getParameter("query");
        String categoryId = request.getParameter("categoryId");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String ratingStr = request.getParameter("rating");
        String availability = request.getParameter("availability");
        String origin = request.getParameter("origin");
        
        // Kết hợp từ khóa và các điều kiện bộ lọc
        List<Product> listProduct = productService.searchAndFilterProducts(query, categoryId, minPriceStr, maxPriceStr,
                ratingStr, availability, origin);
        
        // Lấy danh sách danh mục đổ ra sidebar bộ lọc
        List<Category> listCategories = productService.getHierarchyCategories(); 
        
        request.setAttribute("txtSearch", query);
        request.setAttribute("selectedCategory", categoryId);
        request.setAttribute("minPrice", minPriceStr);
        request.setAttribute("maxPrice", maxPriceStr);
        request.setAttribute("selectedRating", ratingStr);
        request.setAttribute("selectedAvailability", availability);
        request.setAttribute("selectedOrigin", origin);
        request.setAttribute("listProduct", listProduct);
        request.setAttribute("listCategories", listCategories);
        
        request.getRequestDispatcher("/views/product/product-search.jsp").forward(request, response);
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
