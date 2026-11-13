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
 * Servlet xử lý đổi phân loại (variant) cho một mục sản phẩm đã có trong giỏ hàng.
 * Endpoint: /cart/change-variant
 */
@WebServlet(name = "ChangeCartVariantServlet", urlPatterns = {"/cart/change-variant"})
public class ChangeCartVariantServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ChangeCartVariantServlet.class.getName());
    private transient ICartService cartService;

    /**
     * Khởi tạo mặc định với CartServiceImpl.
     */
    public ChangeCartVariantServlet() {
        this(new CartServiceImpl());
    }

    /**
     * Khởi tạo với ICartService tùy chỉnh (hỗ trợ Dependency Injection / Unit Test).
     *
     * @param cartService service xử lý nghiệp vụ giỏ hàng
     */
    ChangeCartVariantServlet(ICartService cartService) {
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
     * Xử lý yêu cầu HTTP POST để thay đổi phân loại sản phẩm trong giỏ:
     * - Kiểm tra trạng thái đăng nhập và tài khoản hoạt động của người dùng.
     * - Lấy cartItemId và variantId mới từ request parameter.
     * - Gọi cartService để đổi sang biến thể mới (hỗ trợ gộp nếu phân loại đích đã tồn tại).
     * - Cập nhật lại số lượng sản phẩm (cartSize) trên session.
     * - Lưu thông báo flash (thành công hoặc lỗi) vào session.
     * - Chuyển hướng người dùng về lại trang /cart.
     *
     * @param request  yêu cầu HTTP chứa cartItemId và variantId mới
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
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Thực hiện đổi sang biến thể mới cho mục giỏ hàng
            cartService.changeVariant(user.getId(),
                    Long.parseLong(request.getParameter("cartItemId")),
                    Long.parseLong(request.getParameter("variantId")));

            // Cập nhật lại số lượng mục trong giỏ trên session
            session.setAttribute("cartSize", cartService.getCartItemCount(user.getId()));
            session.setAttribute("cartSuccess", "Đã đổi phân loại sản phẩm trong giỏ hàng!");
            session.removeAttribute("cartError");
        } catch (NumberFormatException ex) {
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
            session.removeAttribute("cartSuccess");
        } catch (IllegalArgumentException ex) {
            session.setAttribute("cartError", ex.getMessage());
            session.removeAttribute("cartSuccess");
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Cannot change cart item variant", ex);
            session.setAttribute("cartError", "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!");
            session.removeAttribute("cartSuccess");
        }

        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
