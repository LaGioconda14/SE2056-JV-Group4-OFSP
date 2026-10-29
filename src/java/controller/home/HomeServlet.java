/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.home;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Product;
import service.IProductService;
import service.IWishlistService;
import service.impl.ProductServiceImpl;
import service.impl.WishlistServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="HomeServlet", urlPatterns={"/home", ""})
public class HomeServlet extends HttpServlet {

    private final IProductService productService = new ProductServiceImpl();
    private final IWishlistService wishlistService = new WishlistServiceImpl();
   
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
            out.println("<title>Servlet HomeServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet HomeServlet at " + request.getContextPath () + "</h1>");
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
        
        try {
            // Gọi Service lấy dữ liệu an toàn
            request.setAttribute("listProduct", productService.getHomeProducts());
            request.setAttribute("categories", productService.getAllCategories());
            request.setAttribute("homeTabs", productService.getHomeFeaturedTabs());
            request.setAttribute("hierarchyCategories", productService.getHierarchyCategories());
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Danh sách sản phẩm yêu thích của người dùng đang đăng nhập (để tô sáng trái tim trên từng sản phẩm)
        Set<Long> wishlistIds = Collections.emptySet();
        HttpSession session = request.getSession(false);
        Object sessionUser = (session != null) ? session.getAttribute("user") : null;
        if (sessionUser instanceof User) {
            try {
                wishlistIds = wishlistService.getProductIds((long) ((User) sessionUser).getId());
            } catch (RuntimeException e) {
                // Chưa tạo bảng wishlists hoặc lỗi DB: trang chủ vẫn hiển thị bình thường
                e.printStackTrace();
            }
        }
        request.setAttribute("wishlistIds", wishlistIds);
        request.setAttribute("wishlistCount", wishlistIds.size());

        // KIỂM TRA LẠI: Nếu file home.jsp nằm ở gốc web, hãy dùng "/home.jsp" 
        // Nếu nằm trong thư mục views/customer/home.jsp thì chỉnh lại cho khớp.
        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
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