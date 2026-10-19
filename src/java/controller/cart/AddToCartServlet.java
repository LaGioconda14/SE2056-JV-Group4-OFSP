package controller.cart;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.CartItem;
import model.User;
import service.ICartService;
import service.impl.CartServiceImpl;

@WebServlet(name = "AddToCartServlet", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    private final ICartService cartService = new CartServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String returnUrl = safeReturnUrl(request.getParameter("returnUrl"));
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "true".equals(request.getParameter("ajax"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

        if (user == null) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"redirect\":\"" + request.getContextPath()
                        + "/login\",\"message\":\"Vui lòng đăng nhập để thêm sản phẩm vào giỏ!\"}");
                return;
            }
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để thêm sản phẩm vào giỏ!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            cartService.addItem((long) user.getId(), variantId, quantity);
            if ("buyNow".equals(request.getParameter("action"))) {
                Cart cart = cartService.getCart((long) user.getId());
                CartItem checkoutItem = cart.getItems().stream()
                        .filter(item -> item.getVariant() != null
                        && item.getVariant().getVariantId() == variantId)
                        .findFirst()
                        .orElseThrow(() -> new IllegalStateException(
                        "Không thể chuẩn bị sản phẩm để thanh toán!"));
                session.removeAttribute("checkoutCouponCode");
                response.sendRedirect(request.getContextPath() + "/checkout?cartItemIds="
                        + checkoutItem.getCartItemID());
                return;
            }
            session.setAttribute("cartSuccess", "Đã thêm sản phẩm vào giỏ hàng!");
            int newCartSize = cartService.getCart((long) user.getId()).getVariantCount();
            session.setAttribute("cartSize", newCartSize);
            if (isAjax) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":true,\"message\":\"Đã thêm sản phẩm vào giỏ hàng thành công!\",\"cartSize\":"
                        + newCartSize + "}");
                return;
            }
        } catch (NumberFormatException e) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu không hợp lệ!\"}");
                return;
            }
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            if (isAjax) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\""
                        + (e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Không thể thêm vào giỏ!") + "\"}");
                return;
            }
            session.setAttribute("cartError", e.getMessage());
        }

        response.sendRedirect(request.getContextPath()
                + (returnUrl != null ? returnUrl : "/cart"));
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
