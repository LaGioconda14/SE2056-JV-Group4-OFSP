package controller.wishlist;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.IWishlistService;
import service.impl.WishlistServiceImpl;

/**
 * Các thao tác ghi lên wishlist (chỉ POST, có CSRF token qua CartCsrfFilter):
 *   POST /wishlist/toggle  - bấm trái tim: thêm / bỏ yêu thích (trả JSON)
 *   POST /wishlist/remove  - xóa khỏi danh sách ở trang wishlist (trả JSON, hoặc redirect nếu không dùng AJAX)
 */
@WebServlet(name = "WishlistActionServlet", urlPatterns = {"/wishlist/toggle", "/wishlist/remove"})
public class WishlistActionServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(WishlistActionServlet.class.getName());

    private final IWishlistService wishlistService = new WishlistServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/wishlist");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "true".equals(request.getParameter("ajax"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

        if (user == null) {
            if (isAjax) {
                writeJson(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "{\"success\":false,\"redirect\":\"" + request.getContextPath()
                        + "/login\",\"message\":\"Vui lòng đăng nhập để dùng danh sách yêu thích!\"}");
                return;
            }
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để dùng danh sách yêu thích!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long productId;
        try {
            productId = Long.parseLong(request.getParameter("productId"));
        } catch (NumberFormatException e) {
            fail(request, response, session, isAjax, HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu không hợp lệ!");
            return;
        }

        long userId = user.getId();
        boolean isRemove = "/wishlist/remove".equals(request.getServletPath());
        try {
            boolean wished;
            String message;
            if (isRemove) {
                wishlistService.remove(userId, productId);
                wished = false;
                message = "Đã xóa sản phẩm khỏi danh sách yêu thích";
            } else {
                wished = wishlistService.toggle(userId, productId);
                message = wished ? "Đã thêm vào danh sách yêu thích" : "Đã bỏ khỏi danh sách yêu thích";
            }
            int count = wishlistService.count(userId);

            if (isAjax) {
                writeJson(response, HttpServletResponse.SC_OK,
                        "{\"success\":true,\"wished\":" + wished + ",\"count\":" + count
                        + ",\"message\":\"" + escape(message) + "\"}");
                return;
            }
            response.sendRedirect(request.getContextPath()
                    + safeReturnUrl(request.getParameter("returnUrl"), "/wishlist"));
        } catch (IllegalArgumentException e) {
            fail(request, response, session, isAjax, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        } catch (RuntimeException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật wishlist", e);
            fail(request, response, session, isAjax, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể cập nhật danh sách yêu thích. Vui lòng thử lại!");
        }
    }

    private void fail(HttpServletRequest request, HttpServletResponse response, HttpSession session,
            boolean isAjax, int status, String message) throws IOException {
        if (isAjax) {
            writeJson(response, status, "{\"success\":false,\"message\":\"" + escape(message) + "\"}");
            return;
        }
        session.setAttribute("wishlistError", message);
        response.sendRedirect(request.getContextPath() + "/wishlist");
    }

    private void writeJson(HttpServletResponse response, int status, String json) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json);
    }

    private String escape(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", " ").replace("\n", " ");
    }

    /** Chỉ cho redirect về đường dẫn nội bộ của ứng dụng. */
    private String safeReturnUrl(String returnUrl, String fallback) {
        if (returnUrl == null) {
            return fallback;
        }
        String normalized = returnUrl.trim();
        if (!normalized.startsWith("/") || normalized.startsWith("//")
                || normalized.contains("://") || normalized.contains("\r")
                || normalized.contains("\n")) {
            return fallback;
        }
        return normalized;
    }
}
