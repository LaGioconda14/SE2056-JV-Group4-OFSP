package controller.wishlist;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.User;
import service.IWishlistService;
import service.impl.WishlistServiceImpl;

/**
 * Trang danh sách sản phẩm yêu thích của khách hàng: GET /wishlist.
 * (AuthFilter đã chặn người chưa đăng nhập, ở đây kiểm tra lại cho chắc.)
 */
@WebServlet(name = "WishlistServlet", urlPatterns = {"/wishlist"})
public class WishlistServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(WishlistServlet.class.getName());

    private final IWishlistService wishlistService = new WishlistServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để xem danh sách yêu thích!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Thông báo lỗi lưu tạm từ lần thao tác không dùng AJAX trước đó (nếu có)
        Object flashError = session.getAttribute("wishlistError");
        if (flashError != null) {
            request.setAttribute("wishlistError", flashError);
            session.removeAttribute("wishlistError");
        }

        List<Product> items;
        try {
            items = wishlistService.getProducts((long) user.getId());
        } catch (RuntimeException e) {
            LOGGER.log(Level.SEVERE, "Không tải được danh sách yêu thích", e);
            items = new ArrayList<>();
            request.setAttribute("wishlistError",
                    "Không thể tải danh sách yêu thích lúc này. Vui lòng thử lại sau!");
        }

        request.setAttribute("wishlistItems", items);
        request.setAttribute("wishlistCount", items.size());
        request.getRequestDispatcher("/views/wishlist/wishlist.jsp").forward(request, response);
    }
}
