package controller.cart;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

@WebServlet(name = "RemoveCartServlet", urlPatterns = {"/cart/remove"})
public class RemoveCartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(RemoveCartServlet.class.getName());
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
        HttpSession session = request.getSession(false);
        Object sessionUser = session != null ? session.getAttribute("user") : null;
        User user = sessionUser instanceof User ? (User) sessionUser : null;
        if (user == null || user.getId() <= 0 || !user.isActive()) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        try {
            cartService.removeItem(user.getId(),
                    Long.parseLong(request.getParameter("cartItemId")));
            session.setAttribute("cartSize", cartService.getCartItemCount(user.getId()));
            session.setAttribute("cartSuccess", "Đã xóa sản phẩm khỏi giỏ hàng!");
            session.removeAttribute("cartError");
        } catch (NumberFormatException ex) {
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
            session.removeAttribute("cartSuccess");
        } catch (IllegalArgumentException ex) {
            session.setAttribute("cartError", ex.getMessage());
            session.removeAttribute("cartSuccess");
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Cannot remove cart item", ex);
            session.setAttribute("cartError", "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!");
            session.removeAttribute("cartSuccess");
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
