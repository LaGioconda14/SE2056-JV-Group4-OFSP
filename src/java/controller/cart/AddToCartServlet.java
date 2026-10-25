package controller.cart;

import exception.CartException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.CartMutationResult;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

@WebServlet(name = "AddToCartServlet", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    private transient ICartService cartService;

    public AddToCartServlet() {
        this(new CartServiceImpl());
    }

    AddToCartServlet(ICartService cartService) {
        this.cartService = cartService;
    }

    @Override
    public void init() {
        if (cartService == null) {
            cartService = new CartServiceImpl();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = CartControllerSupport.activeUser(request);
        String returnUrl = CartControllerSupport.safeReturnUrl(request.getParameter("returnUrl"));
        if (user == null) {
            handleUnauthenticated(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        try {
            long variantId = CartControllerSupport.positiveLong(request, "variantId");
            int quantity = CartControllerSupport.positiveInt(request, "quantity");
            CartMutationResult result = cartService.addItem(user.getId(), variantId, quantity);
            int cartSize = result.cartItemCount();
            session.setAttribute("cartSize", cartSize);

            if ("buyNow".equals(request.getParameter("action"))) {
                session.removeAttribute("checkoutCouponCode");
                session.removeAttribute("checkoutShopCoupons");
                response.sendRedirect(request.getContextPath() + "/checkout?cartItemIds="
                        + result.item().getCartItemId());
                return;
            }

            CartControllerSupport.success(session, "Đã thêm sản phẩm vào giỏ hàng!");
        } catch (CartException ex) {
            CartControllerSupport.error(session, ex);
        } catch (RuntimeException ex) {
            CartException safeError = CartControllerSupport.unexpected(ex);
            CartControllerSupport.error(session, safeError);
        }

        response.sendRedirect(request.getContextPath()
                + (returnUrl != null ? returnUrl : "/cart"));
    }

    private void handleUnauthenticated(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String message = "Vui lòng đăng nhập để thêm sản phẩm vào giỏ!";
        request.getSession(true).setAttribute("errorMessage", message);
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
