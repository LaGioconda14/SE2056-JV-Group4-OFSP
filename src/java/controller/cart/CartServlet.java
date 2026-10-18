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
import model.Cart;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

/**
 *
 * @author Bac
 */
@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private final ICartService cartService = new CartServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            session = request.getSession(true);
            session.setAttribute("errorMessage", "Vui lòng đăng nhập để xem giỏ hàng!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Cart cart = cartService.getCart((long) user.getId());
        request.setAttribute("cart", cart);
        if (cart.getItems().stream().anyMatch(model.CartItem::isQuantityAdjusted)) {
            request.setAttribute("stockNotice",
                    "Một số sản phẩm đã được tự động giảm số lượng theo tồn kho hiện tại.");
        }

        String successMsg = (String) session.getAttribute("cartSuccess");
        String errorMsg = (String) session.getAttribute("cartError");
        if (successMsg != null) {
            request.setAttribute("successMessage", successMsg);
            session.removeAttribute("cartSuccess");
        }
        if (errorMsg != null) {
            request.setAttribute("errorMessage", errorMsg);
            session.removeAttribute("cartError");
        }

        request.getRequestDispatcher("/views/cart/cart.jsp").forward(request, response);
    }
}
