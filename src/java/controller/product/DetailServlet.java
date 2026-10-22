/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.product;

import dao.ProductDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import service.IProductService;
import service.impl.ProductServiceImpl;

/**
 *
 * @author ADMIN
 */
@WebServlet(name="DetailServlet", urlPatterns={"/detail"})
public class DetailServlet extends HttpServlet {
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
        
        // 1. Lấy tham số id từ URL gửi lên
        String idStr = request.getParameter("id");
        System.out.println(">>> [DEBUG DETAIL] ID nhận được từ URL: " + idStr);

        try {
            if (idStr != null && !idStr.trim().isEmpty()) {
                int productId = Integer.parseInt(idStr);
                
                // 2. Gọi DAO lấy thông tin sản phẩm chi tiết
                ProductDAO productDAO = new ProductDAO();
                Product product = productDAO.getProductById(productId); // (Hoặc qua Service nếu nhóm ông dùng Service)

                if (product != null) {
                    System.out.println(">>> [DEBUG DETAIL] Đã tìm thấy sản phẩm: " + product.getName());
                    request.setAttribute("product", product);
                    request.setAttribute("variants", product.getVariants());

                    List<Map<String, String>> imageList = new ArrayList<>();
                    for (String imageUrl : product.getImages()) {
                        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                            Map<String, String> image = new LinkedHashMap<>();
                            image.put("imageUrl", imageUrl);
                            imageList.add(image);
                        }
                    }
                    if (imageList.isEmpty()) {
                        Map<String, String> image = new LinkedHashMap<>();
                        image.put("imageUrl", product.getImage());
                        imageList.add(image);
                    }
                    request.setAttribute("imageList", imageList);
                    
                    // 3. Forward dữ liệu sang trang detail.jsp đã tạo
                    request.getRequestDispatcher("/views/product/product-detail.jsp").forward(request, response);
                    return;
                } else {
                    System.out.println(">>> [DEBUG DETAIL] Không tìm thấy sản phẩm với ID = " + productId);
                }
            }
        } catch (Exception e) {
            System.out.println(">>> [DEBUG DETAIL] Lỗi ngoại lệ trong DetailServlet:");
            e.printStackTrace();
        }

        // Nếu ID không hợp lệ hoặc không tìm thấy sản phẩm thì mới chuyển hướng về trang danh sách
        response.sendRedirect(request.getContextPath() + "/products");
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
