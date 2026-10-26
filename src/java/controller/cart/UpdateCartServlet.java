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

@WebServlet(name = "UpdateCartServlet", urlPatterns = {"/cart/update"})
public class UpdateCartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UpdateCartServlet.class.getName());
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
        HttpSession session = request.getSession(false);
        Object sessionUser = session != null ? session.getAttribute("user") : null;
        User user = sessionUser instanceof User ? (User) sessionUser : null;
        if (user == null || user.getId() <= 0 || !user.isActive()) {
            redirectToLogin(request, response);
            return;
        }
        try {
            cartService.updateQuantity(user.getId(),
                    Long.parseLong(request.getParameter("cartItemId")),
                    Integer.parseInt(request.getParameter("quantity")));
            session.setAttribute("cartSize", cartService.getCartItemCount(user.getId()));
            session.setAttribute("cartSuccess", "Đã cập nhật số lượng!");
            session.removeAttribute("cartError");
        } catch (NumberFormatException ex) {
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
            session.removeAttribute("cartSuccess");
        } catch (IllegalArgumentException ex) {
            session.setAttribute("cartError", ex.getMessage());
            session.removeAttribute("cartSuccess");
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Cannot update cart quantity", ex);
            session.setAttribute("cartError", "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!");
            session.removeAttribute("cartSuccess");
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
