package controller.shop;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.IProductService;
import service.impl.ProductServiceImpl;

@WebServlet(name = "ShopDeleteProductServlet", urlPatterns = {"/shop/product/delete"})
public class ShopDeleteProductServlet extends HttpServlet {
    private final IProductService productService = new ProductServiceImpl();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ShopDeleteProductServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ShopDeleteProductServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

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

        try {
            String productIdStr = request.getParameter("productId");
            String idStr = request.getParameter("id");
            boolean success = false;
            if (productIdStr != null && !productIdStr.trim().isEmpty()) {
                long productId = Long.parseLong(productIdStr);
                success = productService.softDeleteProduct(productId, shopId);
            } else if (idStr != null && !idStr.trim().isEmpty()) {
                long variantId = Long.parseLong(idStr);
                success = productService.softDeleteVariant(variantId, shopId);
            }

            if (success) {
                session.setAttribute("successMessage", "Đã ẩn/xóa sản phẩm thành công!");
            } else {
                session.setAttribute("errorMessage", "Thao tác thất bại hoặc bạn không có quyền!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/shop/products");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
