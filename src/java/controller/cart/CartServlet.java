package controller.cart;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.cart.Cart;
import model.entity.user.User;
import service.ICartService;
import service.impl.CartServiceImpl;

/**
 * Servlet điều hướng và hiển thị trang giỏ hàng người dùng.
 * Endpoint: /cart
 */
@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CartServlet.class.getName());
    private transient ICartService cartService;

    /**
     * Khởi tạo mặc định với CartServiceImpl.
     */
    public CartServlet() {
        this(new CartServiceImpl());
    }

    /**
     * Khởi tạo với ICartService tùy chỉnh (hỗ trợ Dependency Injection / Unit Test).
     *
     * @param cartService service xử lý nghiệp vụ giỏ hàng
     */
    CartServlet(ICartService cartService) {
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
     * Xử lý yêu cầu HTTP GET để xem giỏ hàng:
     * - Kiểm tra trạng thái đăng nhập của khách hàng.
     * - Tải giỏ hàng và đối soát tồn kho thực tế (reconcile).
     * - Cảnh báo nếu số lượng sản phẩm bị tự động điều chỉnh do thiếu hàng.
     * - Chuyển tiếp flash message (thông báo kết quả/lỗi) từ session sang request.
     * - Forward sang giao diện cart.jsp.
     *
     * @param request  yêu cầu HTTP từ client
     * @param response phản hồi HTTP về client
     * @throws ServletException nếu xảy ra lỗi servlet
     * @throws IOException      nếu xảy ra lỗi vào/ra dữ liệu
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        // GET khong doc tham so gio hang; lay user tu session hien co, khong tu request.
        // Khac cac action POST, nhanh nay chi kiem tra user != null, khong kiem tra ID hay active.
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Bắt buộc đăng nhập trước khi xem giỏ hàng
        if (user == null) {
            session = request.getSession(true);
            session.setAttribute("errorMessage", "Vui lòng đăng nhập để xem giỏ hàng!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Cart cart;
        try {
            // Đối soát lại với DB mỗi lần mở giỏ, thay vì dùng giá/tồn kho đã chụp trong session.
            cart = cartService.loadCartAndReconcile((long) user.getId());
        // Loi tham so tra HTTP 400; loi runtime duoc log va tra HTTP 500.
        // Ca hai van forward JSP voi gio rong va errorMessage trong request.
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("errorMessage", ex.getMessage());
            cart = new Cart();
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Cannot load cart", ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("errorMessage", "Không thể xử lý giỏ hàng. Vui lòng thử lại sau!");
            cart = new Cart();
        }
        request.setAttribute("cart", cart);

        // Thông báo nếu có bất kỳ sản phẩm nào bị hệ thống tự động hạ số lượng vì vượt quá tồn kho
        if (cart.getItems().stream().anyMatch(model.entity.cart.CartItem::isQuantityAdjusted)) {
            request.setAttribute("stockNotice",
                    "Một số sản phẩm đã được tự động giảm số lượng theo tồn kho hiện tại.");
        }

        // Lấy thông báo flash từ session (do các action thêm/sửa/xóa chuyển sang) và xóa sau khi hiển thị
        String successMsg = (String) session.getAttribute("cartSuccess");
        String errorMsg = (String) session.getAttribute("cartError");
        if (successMsg != null) {
            request.setAttribute("successMessage", successMsg);
            session.removeAttribute("cartSuccess");
        }
        if (errorMsg != null) {
            // Flash loi, neu co, ghi de errorMessage tu loi tai gio o tren.
            request.setAttribute("errorMessage", errorMsg);
            session.removeAttribute("cartError");
        }

        request.getRequestDispatcher("/views/cart/cart.jsp").forward(request, response);
    }
}
