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

@WebServlet(name="ShopDeleteVariantServlet", urlPatterns={"/shop/product/variant/delete"})
public class ShopDeleteVariantServlet extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
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

        boolean success = productService.softDeleteVariant(variantId, shopId);

        if (success) {
            session.setAttribute("successMessage", "Đã ẩn / xóa biến thể thành công!");
        } else {
            session.setAttribute("errorMessage", "Xóa biến thể thất bại!");
        }

        response.sendRedirect(request.getContextPath() + "/shop/product/variants?productId=" + productId);
    }

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

        boolean success = productService.softDeleteVariant(variantId, shopId);

        if (success) {
            session.setAttribute("successMessage", "Đã ẩn / xóa biến thể thành công!");
        } else {
            session.setAttribute("errorMessage", "Xóa biến thể thất bại!");
        }

        response.sendRedirect(request.getContextPath() + "/shop/product/variants?productId=" + productId);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
