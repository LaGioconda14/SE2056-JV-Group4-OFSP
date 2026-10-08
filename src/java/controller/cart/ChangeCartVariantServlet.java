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

@WebServlet(name = "ChangeCartVariantServlet", urlPatterns = {"/cart/change-variant"})
public class ChangeCartVariantServlet extends HttpServlet {

    private final ICartService cartService = new CartServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
            long variantId = Long.parseLong(request.getParameter("variantId"));
            cartService.changeVariant((long) user.getId(), cartItemId, variantId);
            session.setAttribute("cartSuccess", "Đã đổi phân loại sản phẩm trong giỏ hàng!");
        } catch (NumberFormatException ex) {
            session.setAttribute("cartError", "Dữ liệu biến thể không hợp lệ!");
        } catch (Exception ex) {
            session.setAttribute("cartError", ex.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
