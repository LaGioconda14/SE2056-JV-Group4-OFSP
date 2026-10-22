package controller.cart;

import exception.CartException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;
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
        boolean ajax = isAjax(request);
        if (user == null) {
            handleUnauthenticated(request, response, ajax);
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
                response.sendRedirect(request.getContextPath() + "/checkout?cartItemIds="
                        + result.item().getCartItemId());
                return;
            }

            CartControllerSupport.success(session, "Đã thêm sản phẩm vào giỏ hàng!");
            if (ajax) {
                CartControllerSupport.writeJson(response, HttpServletResponse.SC_OK,
                        Map.of("success", true,
                                "message", "Đã thêm sản phẩm vào giỏ hàng thành công!",
                                "cartSize", cartSize));
                return;
            }
        } catch (CartException ex) {
            if (ajax) {
                CartControllerSupport.writeJson(response, CartControllerSupport.status(ex),
                        Map.of("success", false, "message", ex.getMessage()));
                return;
            }
            CartControllerSupport.error(session, ex);
        } catch (RuntimeException ex) {
            CartException safeError = CartControllerSupport.unexpected(ex);
            if (ajax) {
                CartControllerSupport.writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        Map.of("success", false, "message", safeError.getMessage()));
                return;
            }
            CartControllerSupport.error(session, safeError);
        }

        response.sendRedirect(request.getContextPath()
                + (returnUrl != null ? returnUrl : "/cart"));
    }

    private boolean isAjax(HttpServletRequest request) {
        String accept = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "true".equals(request.getParameter("ajax"))
                || (accept != null && accept.contains("application/json"));
    }

    private void handleUnauthenticated(HttpServletRequest request, HttpServletResponse response,
            boolean ajax) throws IOException {
        String message = "Vui lòng đăng nhập để thêm sản phẩm vào giỏ!";
        if (ajax) {
            CartControllerSupport.writeJson(response, HttpServletResponse.SC_UNAUTHORIZED,
                    Map.of("success", false, "redirect", request.getContextPath() + "/login",
                            "message", message));
            return;
        }
        request.getSession(true).setAttribute("errorMessage", message);
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
