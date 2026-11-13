package controller.cart;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.user.User;
import service.ICartService;
import service.impl.CartServiceImpl;

/**
 * Servlet xử lý cập nhật số lượng của một mục sản phẩm trong giỏ hàng.
 * Endpoint: /cart/update
 */
@WebServlet(name = "UpdateCartServlet", urlPatterns = {"/cart/update"})
public class UpdateCartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UpdateCartServlet.class.getName());
    private transient ICartService cartService;

    /**
     * Khởi tạo mặc định với CartServiceImpl.
     */
    public UpdateCartServlet() {
        this(new CartServiceImpl());
    }

    /**
     * Khởi tạo với ICartService tùy chỉnh (hỗ trợ Dependency Injection / Unit Test).
     *
     * @param cartService service xử lý nghiệp vụ giỏ hàng
     */
    UpdateCartServlet(ICartService cartService) {
        this.cartService = cartService;
    }

    /**
     * Khởi tạo servlet, đảm bảo cartService luôn sẵn sàng hoạt động.
     */
    @Override
    public void init() {
        if (cartService == null) {
            cartService = new CartServiceImpl();
        }
    }

    /**
     * Xử lý yêu cầu HTTP POST để cập nhật số lượng sản phẩm trong giỏ hàng:
     * - Kiểm tra trạng thái đăng nhập và hiệu lực của tài khoản người dùng.
     * - Đọc cartItemId và quantity từ request.
     * - Gọi cartService để cập nhật số lượng trong cơ sở dữ liệu.
     * - Cập nhật lại số lượng sản phẩm (cartSize) lưu trên session.
     * - Thiết lập thông báo flash thành công hoặc lỗi vào session.
     * - Chuyển hướng người dùng về trang /cart.
     *
     * @param request  yêu cầu HTTP chứa cartItemId và quantity mới
     * @param response phản hồi HTTP về client
     * @throws IOException nếu xảy ra lỗi vào/ra dữ liệu
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object sessionUser = session != null ? session.getAttribute("user") : null;
        User user = sessionUser instanceof User ? (User) sessionUser : null;

        // Bắt buộc người dùng phải đăng nhập
        if (user == null || user.getId() <= 0 || !user.isActive()) {
            redirectToLogin(request, response);
            return;
        }

        try {
            // Cập nhật số lượng sản phẩm tương ứng trong giỏ hàng
            cartService.updateQuantity(user.getId(),
                    Long.parseLong(request.getParameter("cartItemId")),
                    Integer.parseInt(request.getParameter("quantity")));

            // Cập nhật lại tổng số mục trong giỏ hiển thị trên badge header
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

    /**
     * Chuyển hướng người dùng tới trang đăng nhập kèm thông báo lỗi.
     *
     * @param request  yêu cầu HTTP từ client
     * @param response phản hồi HTTP về client
     * @throws IOException nếu xảy ra lỗi vào/ra dữ liệu
     */
    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
