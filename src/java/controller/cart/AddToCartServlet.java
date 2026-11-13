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
import model.dto.cart.CartMutationResult;
import model.entity.user.User;
import service.ICartService;
import service.impl.CartServiceImpl;

/**
 * Servlet xử lý thêm biến thể sản phẩm vào giỏ hàng của người dùng.
 * Endpoint: /cart/add
 */
@WebServlet(name = "AddToCartServlet", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AddToCartServlet.class.getName());
    private transient ICartService cartService;

    /**
     * Khởi tạo mặc định với CartServiceImpl.
     */
    public AddToCartServlet() {
        this(new CartServiceImpl());
    }

    /**
     * Khởi tạo với ICartService tùy chỉnh (hỗ trợ Dependency Injection / Unit Test).
     *
     * @param cartService service xử lý nghiệp vụ giỏ hàng
     */
    AddToCartServlet(ICartService cartService) {
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
     * Chặn truy cập trực tiếp bằng phương thức GET vào endpoint thêm giỏ hàng,
     * tự động chuyển hướng người dùng về trang giỏ hàng.
     *
     * @param request  yêu cầu HTTP từ client
     * @param response phản hồi HTTP về client
     * @throws IOException nếu xảy ra lỗi vào/ra dữ liệu
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    /**
     * Xử lý yêu cầu HTTP POST để thêm biến thể sản phẩm vào giỏ hàng:
     * - Kiểm tra người dùng đã đăng nhập và tài khoản còn hoạt động hay không.
     * - Kiểm tra tính an toàn của URL chuyển hướng (returnUrl).
     * - Đọc variantId và quantity từ request, gọi cartService để thêm vào giỏ.
     * - Cập nhật lại số lượng sản phẩm trong giỏ (cartSize) trên session.
     * - Lưu thông báo flash (thành công hoặc lỗi) vào session.
     * - Chuyển hướng người dùng về returnUrl an toàn hoặc trang /cart.
     *
     * @param request  yêu cầu HTTP chứa variantId, quantity và returnUrl (nếu có)
     * @param response phản hồi HTTP về client
     * @throws ServletException nếu xảy ra lỗi servlet
     * @throws IOException      nếu xảy ra lỗi vào/ra dữ liệu
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Object sessionUser = session != null ? session.getAttribute("user") : null;
        User user = sessionUser instanceof User ? (User) sessionUser : null;
        String returnUrl = safeReturnUrl(request.getParameter("returnUrl"));

        // Người dùng chưa đăng nhập hoặc tài khoản bị vô hiệu hóa
        if (user == null || user.getId() <= 0 || !user.isActive()) {
            handleUnauthenticated(request, response);
            return;
        }

        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            // Gọi service thêm sản phẩm vào giỏ hàng và nhận kết quả cập nhật
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

    /**
     * Xử lý trường hợp người dùng chưa đăng nhập: đặt thông báo lỗi vào session
     * và chuyển hướng về trang đăng nhập.
     *
     * @param request  yêu cầu HTTP từ client
     * @param response phản hồi HTTP về client
     * @throws IOException nếu xảy ra lỗi vào/ra dữ liệu
     */
    private void handleUnauthenticated(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String message = "Vui lòng đăng nhập để thêm sản phẩm vào giỏ!";
        request.getSession(true).setAttribute("errorMessage", message);
        response.sendRedirect(request.getContextPath() + "/login");
    }

    /**
     * Chuẩn hóa và kiểm tra đường dẫn chuyển hướng sau khi thêm giỏ hàng (phòng tránh Open Redirect).
     * Chỉ chấp nhận đường dẫn nội bộ bắt đầu bằng '/' và không chứa protocol hay ký tự CRLF injection.
     *
     * @param returnUrl chuỗi URL do client gửi lên
     * @return chuỗi đường dẫn tương đối an toàn hoặc null nếu không hợp lệ
     */
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
