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
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.CartItem;
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
        String returnUrl = safeReturnUrl(request.getParameter("returnUrl"));
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "true".equals(request.getParameter("ajax"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

        if (user == null) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"redirect\":\"" + request.getContextPath()
                        + "/login\",\"message\":\"Vui lòng đăng nhập để thêm sản phẩm vào giỏ!\"}");
                return;
            }
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để thêm sản phẩm vào giỏ!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            cartService.addItem((long) user.getId(), variantId, quantity);
            if ("buyNow".equals(request.getParameter("action"))) {
                Cart cart = cartService.getCart((long) user.getId());
                CartItem checkoutItem = cart.getItems().stream()
                        .filter(item -> item.getVariant() != null
                        && item.getVariant().getVariantId() == variantId)
                        .findFirst()
                        .orElseThrow(() -> new IllegalStateException(
                        "Không thể chuẩn bị sản phẩm để thanh toán!"));
                session.removeAttribute("checkoutCouponCode");
                response.sendRedirect(request.getContextPath() + "/checkout?cartItemIds="
                        + checkoutItem.getCartItemID());
                return;
            }
            session.setAttribute("cartSuccess", "Đã thêm sản phẩm vào giỏ hàng!");
            int newCartSize = cartService.getCart((long) user.getId()).getTotalQuantity();
            session.setAttribute("cartSize", newCartSize);
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":true,\"message\":\"Đã thêm sản phẩm vào giỏ hàng thành công!\",\"cartSize\":"
                        + newCartSize + "}");
                return;
            }
        } catch (NumberFormatException e) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu không hợp lệ!\"}");
                return;
            }
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\""
                        + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Không thể thêm vào giỏ!") + "\"}");
                return;
            }
            session.setAttribute("cartError", e.getMessage());
        }

        response.sendRedirect(request.getContextPath()
                + (returnUrl != null ? returnUrl : "/cart"));
    }

    private String safeReturnUrl(String returnUrl) {
        if (returnUrl == null) {
            return null;
        }
        String normalized = returnUrl.trim();
        if (!normalized.startsWith("/") || normalized.startsWith("//")
                || normalized.contains("://") || normalized.contains("\r")
                || normalized.contains("\n")) {
            return null;
        }
        return normalized;
    }
}
