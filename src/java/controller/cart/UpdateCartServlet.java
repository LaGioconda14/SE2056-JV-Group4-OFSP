/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.cart;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

/**
 *
 * @author Bac
 */
@WebServlet(name = "UpdateCartServlet", urlPatterns = {"/cart/update"})
public class UpdateCartServlet extends HttpServlet {

    private final ICartService cartService = new CartServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            cartService.updateQuantity((long) user.getId(), cartItemId, quantity);
            session.setAttribute("cartSuccess", "Đã cập nhật số lượng!");
        } catch (NumberFormatException e) {
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            session.setAttribute("cartError", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
