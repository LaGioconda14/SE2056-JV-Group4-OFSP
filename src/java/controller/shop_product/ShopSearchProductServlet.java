/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.shop_product;

import dao.ShopDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Category;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="ShopSearchProductServlet", urlPatterns={"/shop/product/search"})
public class ShopSearchProductServlet extends HttpServlet {
   
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
            out.println("<title>Servlet ShopSearchProductServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ShopSearchProductServlet at " + request.getContextPath () + "</h1>");
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
    
    private final ShopDAO shopDAO = new ShopDAO();
    private final IProductService productService = new ProductServiceImpl();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Object shopIdObj = session.getAttribute("shopId");
        long shopId = (Long)shopIdObj;

        // 2. Lấy các tham số lọc từ URL request gửi lên
        String keyword = request.getParameter("keyword");

        String categoryIdStr = request.getParameter("categoryId");
        Long categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) ? Long.parseLong(categoryIdStr) : null;

        String certification = request.getParameter("certification");
        String stockLevel = request.getParameter("stockLevel");

        // 3. Gọi qua Service để lấy danh sách sản phẩm đã lọc
        List<model.Product> products = productService.getShopFilteredProducts(shopId, keyword, categoryId, certification, stockLevel);

        // 4. Đẩy dữ liệu sang trang JSP để hiển thị
        request.setAttribute("products", products);
        List<Category> categoryList = productService.getAllCategories();
        request.setAttribute("categories", categoryList);
        List<String> certificationList = productService.getAllCertifications();
        request.setAttribute("certifications", certificationList);
        request.getRequestDispatcher("/views/shop_product/shop-products.jsp").forward(request, response);
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
