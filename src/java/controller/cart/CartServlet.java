package controller.cart;

import java.io.IOException;
import exception.CartException;
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

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private transient ICartService cartService;

    public CartServlet() {
        this(new CartServiceImpl());
    }

    CartServlet(ICartService cartService) {
        this.cartService = cartService;
    }

    @Override
    public void init() {
        if (cartService == null) {
            cartService = new CartServiceImpl();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            session = request.getSession(true);
            session.setAttribute("errorMessage", "Vui lòng đăng nhập để xem giỏ hàng!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Cart cart;
        try {
            cart = cartService.loadCartAndReconcile((long) user.getId());
        } catch (CartException ex) {
            response.setStatus(CartControllerSupport.status(ex));
            request.setAttribute("errorMessage", ex.getMessage());
            cart = new Cart();
        } catch (RuntimeException ex) {
            CartException safeError = CartControllerSupport.unexpected(ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("errorMessage", safeError.getMessage());
            cart = new Cart();
        }
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
