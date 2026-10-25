package controller.cart;

import exception.CartErrorCode;
import exception.CartException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

final class CartControllerSupport {

    private CartControllerSupport() {
    }

    static User activeUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object value = session != null ? session.getAttribute("user") : null;
        if (value instanceof User user && user.getId() > 0 && user.isActive()) {
            return user;
        }
        return null;
    }

    static long positiveLong(HttpServletRequest request, String name) {
        try {
            long value = Long.parseLong(request.getParameter(name));
            if (value <= 0) {
                throw invalidInput();
            }
            return value;
        } catch (NumberFormatException | NullPointerException ex) {
            throw invalidInput();
        }
    }

    static int positiveInt(HttpServletRequest request, String name) {
        try {
            int value = Integer.parseInt(request.getParameter(name));
            if (value <= 0) {
                throw invalidInput();
            }
            return value;
        } catch (NumberFormatException | NullPointerException ex) {
            throw invalidInput();
        }
    }

    static void success(HttpSession session, String message) {
        session.setAttribute("cartSuccess", message);
        session.removeAttribute("cartError");
    }

    static void error(HttpSession session, CartException ex) {
        session.setAttribute("cartError", ex.getMessage());
        session.removeAttribute("cartSuccess");
    }

    static CartException unexpected(RuntimeException cause) {
        Logger.getLogger(CartControllerSupport.class.getName())
                .log(Level.SEVERE, "Unexpected cart controller failure", cause);
        return new CartException(CartErrorCode.DATABASE_FAILURE,
                "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!", cause);
    }

    static int status(CartException ex) {
        return switch (ex.getCode()) {
            case INVALID_INPUT -> HttpServletResponse.SC_BAD_REQUEST;
            case CART_NOT_FOUND, ITEM_NOT_FOUND -> HttpServletResponse.SC_NOT_FOUND;
            case VARIANT_UNAVAILABLE, INSUFFICIENT_STOCK -> HttpServletResponse.SC_CONFLICT;
            case DATABASE_FAILURE -> HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        };
    }

    static String safeReturnUrl(String returnUrl) {
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

    private static CartException invalidInput() {
        return new CartException(CartErrorCode.INVALID_INPUT, "Dữ liệu không hợp lệ!");
    }
}
