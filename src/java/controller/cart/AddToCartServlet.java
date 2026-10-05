/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.cart;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

/**
 *
 * @author Bac
 */
@WebServlet(name = "AddToCartServlet", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    private final ICartService cartService = new CartServiceImpl();

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
