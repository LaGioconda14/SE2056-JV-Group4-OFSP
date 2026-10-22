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

@WebServlet(name = "RemoveCartServlet", urlPatterns = {"/cart/remove"})
public class RemoveCartServlet extends HttpServlet {

    private transient ICartService cartService;

    public RemoveCartServlet() {
        this(new CartServiceImpl());
    }

    RemoveCartServlet(ICartService cartService) {
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
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        HttpSession session = request.getSession(false);
        try {
            cartService.removeItem(user.getId(),
                    CartControllerSupport.positiveLong(request, "cartItemId"));
            session.setAttribute("cartSize", cartService.getCartItemCount(user.getId()));
            CartControllerSupport.success(session, "Đã xóa sản phẩm khỏi giỏ hàng!");
        } catch (CartException ex) {
            CartControllerSupport.error(session, ex);
        } catch (RuntimeException ex) {
            CartControllerSupport.error(session, CartControllerSupport.unexpected(ex));
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
