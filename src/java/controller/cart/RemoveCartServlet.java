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
 * Servlet xử lý xóa sản phẩm khỏi giỏ hàng của người dùng.
 * Endpoint: /cart/remove
 */
@WebServlet(name = "RemoveCartServlet", urlPatterns = {"/cart/remove"})
public class RemoveCartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(RemoveCartServlet.class.getName());
    private transient ICartService cartService;

    /**
     * Khởi tạo mặc định với CartServiceImpl.
     */
    public RemoveCartServlet() {
        this(new CartServiceImpl());
    }

    /**
     * Khởi tạo với ICartService tùy chỉnh (hỗ trợ Dependency Injection / Unit Test).
     *
     * @param cartService service xử lý nghiệp vụ giỏ hàng
     */
    RemoveCartServlet(ICartService cartService) {
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
     * Xử lý yêu cầu HTTP POST để xóa một mục sản phẩm khỏi giỏ hàng:
     * - Kiểm tra trạng thái đăng nhập của người dùng.
     * - Lấy cartItemId từ request parameter.
     * - Gọi cartService để xóa mục khỏi giỏ hàng trong cơ sở dữ liệu.
     * - Cập nhật lại số lượng sản phẩm trong giỏ (cartSize) trong session.
     * - Đặt thông báo flash (thành công hoặc lỗi) vào session.
     * - Chuyển hướng người dùng về lại trang /cart.
     *
     * @param request  yêu cầu HTTP chứa cartItemId
     * @param response phản hồi HTTP về client
     * @throws IOException nếu xảy ra lỗi vào/ra dữ liệu
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Khong tao session khi doc user; yeu cau User co ID duong va dang hoat dong.
        // Neu khong dat, luu errorMessage vao session va redirect /login.
        HttpSession session = request.getSession(false);
        Object sessionUser = session != null ? session.getAttribute("user") : null;
        User user = sessionUser instanceof User ? (User) sessionUser : null;

        // Bắt buộc đăng nhập trước khi thực hiện thao tác giỏ hàng
        if (user == null || user.getId() <= 0 || !user.isActive()) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // cartItemId duoc ep sang long; userId lay tu session, khong lay tu client.
            // Service/DAO giới hạn cartItemId theo user hiện tại, không xóa theo ID trần từ client.
            cartService.removeItem(user.getId(),
                    Long.parseLong(request.getParameter("cartItemId")));

            // Cập nhật lại tổng số mục trong giỏ trên session
            session.setAttribute("cartSize", cartService.getCartItemCount(user.getId()));
            session.setAttribute("cartSuccess", "Đã xóa sản phẩm khỏi giỏ hàng!");
            session.removeAttribute("cartError");
        // Sau khi xoa, getCartItemCount cap nhat badge; neu loi, luu flash loi thay cho thanh cong.
        // Loi so va runtime dung thong bao chung; IllegalArgumentException dung message cua service.
        } catch (NumberFormatException ex) {
            session.setAttribute("cartError", "Dữ liệu không hợp lệ!");
            session.removeAttribute("cartSuccess");
        } catch (IllegalArgumentException ex) {
            session.setAttribute("cartError", ex.getMessage());
            session.removeAttribute("cartSuccess");
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Cannot remove cart item", ex);
            session.setAttribute("cartError", "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!");
            session.removeAttribute("cartSuccess");
        }

        // Ca thanh cong va that bai deu redirect ve /cart; runtime duoc ghi log o tren.
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
