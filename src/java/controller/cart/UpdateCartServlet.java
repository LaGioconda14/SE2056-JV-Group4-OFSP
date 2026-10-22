package controller.cart;

import exception.CartException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

@WebServlet(name = "UpdateCartServlet", urlPatterns = {"/cart/update"})
public class UpdateCartServlet extends HttpServlet {

    private transient ICartService cartService;

    public UpdateCartServlet() {
        this(new CartServiceImpl());
    }

    UpdateCartServlet(ICartService cartService) {
        this.cartService = cartService;
    }

    @Override
    public void init() {
        if (cartService == null) {
            cartService = new CartServiceImpl();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = CartControllerSupport.activeUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        HttpSession session = request.getSession(false);
        try {
            cartService.updateQuantity(user.getId(),
                    CartControllerSupport.positiveLong(request, "cartItemId"),
                    CartControllerSupport.positiveInt(request, "quantity"));
            session.setAttribute("cartSize", cartService.getCartItemCount(user.getId()));
            CartControllerSupport.success(session, "Đã cập nhật số lượng!");
        } catch (CartException ex) {
            CartControllerSupport.error(session, ex);
        } catch (RuntimeException ex) {
            CartControllerSupport.error(session, CartControllerSupport.unexpected(ex));
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
