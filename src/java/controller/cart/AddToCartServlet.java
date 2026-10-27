package controller.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.CartMutationResult;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

@WebServlet(name = "AddToCartServlet", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AddToCartServlet.class.getName());
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
        HttpSession session = request.getSession(false);
        Object sessionUser = session != null ? session.getAttribute("user") : null;
        User user = sessionUser instanceof User ? (User) sessionUser : null;
        String returnUrl = safeReturnUrl(request.getParameter("returnUrl"));
        if (user == null || user.getId() <= 0 || !user.isActive()) {
            handleUnauthenticated(request, response);
            return;
        }

        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            if ("buyNow".equals(request.getParameter("action"))) {
                if (variantId <= 0 || quantity <= 0) {
                    throw new IllegalArgumentException("Dữ liệu sản phẩm không hợp lệ!");
                }
                session.setAttribute("checkoutMode", "buyNow");
                session.setAttribute("checkoutBuyNowVariantId", variantId);
                session.setAttribute("checkoutBuyNowQuantity", quantity);
                session.removeAttribute("checkoutItemIds");
                session.removeAttribute("checkoutCouponCode");
                session.removeAttribute("checkoutShopCoupons");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }

            CartMutationResult result = cartService.addItem(user.getId(), variantId, quantity);
            int cartSize = result.cartItemCount();
            session.setAttribute("cartSize", cartSize);

            session.setAttribute("cartSuccess", "Đã thêm sản phẩm vào giỏ hàng!");
            session.removeAttribute("cartError");
        } catch (NumberFormatException ex) {
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
            session.removeAttribute("cartSuccess");
        } catch (IllegalArgumentException ex) {
            session.setAttribute("cartError", ex.getMessage());
            session.removeAttribute("cartSuccess");
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Cannot add item to cart", ex);
            session.setAttribute("cartError", "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!");
            session.removeAttribute("cartSuccess");
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

    private String safeReturnUrl(String returnUrl) {
        if (returnUrl == null) {
            return null;
        }
        String normalized = returnUrl.trim();
        if (!normalized.startsWith("/") || normalized.startsWith("//")
                || normalized.contains("://") || normalized.contains("\r")
                || normalized.contains("\n")) {
            return null;
        }
        return normalized;
    }
}
