/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.product;

import dao.ProductDAO;
import dao.ShopDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Shop;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.Shop;
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

                    // Lấy thông tin Shop bán sản phẩm này
                    ShopDAO shopDAO = new ShopDAO();
                    Shop shop = null;
                    int shopTotalProducts = 0;
                    try {
                        if (product.getShopId() > 0) {
                            shop = shopDAO.getShopById(product.getShopId());
                            shopTotalProducts = shopDAO.getTotalProductsCountByShopId(product.getShopId());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    if (shop == null) {
                        shop = new Shop();
                        shop.setShopId(product.getShopId() > 0 ? product.getShopId() : 1L);
                        String defaultShopName = "GỐC VƯỜN OFFICIAL STORE";
                        if (product.getOrigin() != null && !product.getOrigin().trim().isEmpty()) {
                            defaultShopName = "NÔNG TRẠI " + product.getOrigin().trim().toUpperCase() + " OFFICIAL";
                        }
                        shop.setShopName(defaultShopName);
                        shop.setStatus("ACTIVE");
                        shop.setRating(new BigDecimal("4.9"));
                        shop.setProvince(product.getOrigin() != null && !product.getOrigin().trim().isEmpty() ? product.getOrigin() : "Thành phố Hồ Chí Minh");
                        shop.setDescription("Hệ thống phân phối nông sản tươi sạch, chuẩn hữu cơ VietGAP & GlobalGAP hàng đầu Việt Nam.");
                        shop.setLogoUrl("https://images.unsplash.com/photo-1542838132-92c53300491e?w=150");
                        shopTotalProducts = 283;
                    }
                    request.setAttribute("shop", shop);
                    request.setAttribute("shopTotalProducts", shopTotalProducts);

                    // Tính thời gian tham gia thực tế từ createdAt của shop
                    String shopJoinedTime = "Đã xác minh";
                    if (shop.getCreatedAt() != null) {
                        long diffMillis = System.currentTimeMillis() - shop.getCreatedAt().getTime();
                        long days = diffMillis / (1000L * 60 * 60 * 24);
                        long months = days / 30;
                        if (months >= 12) {
                            long years = months / 12;
                            shopJoinedTime = years + " năm trước";
                        } else if (months > 0) {
                            shopJoinedTime = months + " tháng trước";
                        } else if (days > 0) {
                            shopJoinedTime = days + " ngày trước";
                        } else {
                            shopJoinedTime = "Gần đây";
                        }
                    }
                    request.setAttribute("shopJoinedTime", shopJoinedTime);

                    // Lấy danh sách sản phẩm liên quan
                    try {
                        List<Product> relatedProducts = null;
                        if (product.getCategorySlug() != null && !product.getCategorySlug().trim().isEmpty()) {
                            relatedProducts = productDAO.getProductsByCategorySlug(product.getCategorySlug());
                        }
                        if (relatedProducts == null || relatedProducts.isEmpty()) {
                            relatedProducts = productDAO.getAllProducts();
                        }
                        if (relatedProducts != null) {
                            List<Product> filteredRelated = new ArrayList<>();
                            for (Product rp : relatedProducts) {
                                if (rp.getId() != product.getId()) {
                                    filteredRelated.add(rp);
                                }
                                if (filteredRelated.size() >= 4) break;
                            }
                            request.setAttribute("relatedProducts", filteredRelated);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        request.setAttribute("currentUser", session.getAttribute("user"));
                        transferFlashMessage(session, request, "cartSuccess", "successMessage");
                        transferFlashMessage(session, request, "cartError", "errorMessage");
                    }

                    request.setAttribute("variants", product.getVariants());

                    List<Map<String, String>> imageList = new ArrayList<>();
                    if (product.getImages() != null) {
                        for (String imageUrl : product.getImages()) {
                            if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                                Map<String, String> image = new LinkedHashMap<>();
                                image.put("imageUrl", imageUrl);
                                imageList.add(image);
                            }
                        }
                    }
                    if (imageList.isEmpty() && product.getImage() != null) {
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

    private void transferFlashMessage(HttpSession session, HttpServletRequest request,
            String sessionKey, String requestKey) {
        Object message = session.getAttribute(sessionKey);
        if (message != null) {
            request.setAttribute(requestKey, message);
            session.removeAttribute(sessionKey);
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
