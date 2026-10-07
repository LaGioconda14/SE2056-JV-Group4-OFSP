/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.cart;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Product;
import model.ProductVariant;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;
import util.DBContext;

/**
 *
 * @author Bac
 */
@WebServlet(name = "AddToCartServlet", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    private final ICartService cartService = new CartServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.sku, pv.variant_name, pv.unit, pv.price, pv.stock_quantity, p.name AS product_name "
                + "FROM product_variants pv "
                + "INNER JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.is_active = 1 AND p.is_active = 1 "
                + "ORDER BY pv.variant_id ASC";

        try {
            Connection conn = new DBContext().getConnection();
            if (conn != null) {
                try (conn;
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Product p = new Product();
                        p.setName(rs.getString("product_name"));

                        ProductVariant v = new ProductVariant();
                        v.setVariantId(rs.getLong("variant_id"));
                        v.setSku(rs.getString("sku"));
                        v.setVariantName(rs.getString("variant_name"));
                        v.setUnit(rs.getString("unit"));
                        v.setPrice(rs.getBigDecimal("price"));
                        v.setStockQuantity(rs.getInt("stock_quantity"));
                        v.setProduct(p);

                        variants.add(v);
                    }
                }
            }
        } catch (Exception ex) {
            // Không chặn, JSP có sẵn danh sách mẫu dự phòng
        }

        request.setAttribute("variantList", variants);
        request.getRequestDispatcher("/views/product/product-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để thêm sản phẩm vào giỏ!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            cartService.addItem((long) user.getId(), variantId, quantity);
            session.setAttribute("cartSuccess", "Đã thêm sản phẩm vào giỏ hàng!");
        } catch (NumberFormatException e) {
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            session.setAttribute("cartError", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
