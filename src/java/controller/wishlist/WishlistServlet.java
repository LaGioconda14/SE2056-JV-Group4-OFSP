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

    /** Mỗi trang đúng 1 hàng ngang (4 thẻ sản phẩm ở màn hình rộng); nhiều hơn thì chuyển sang trang kế. */
    private static final int WISHLIST_PAGE_SIZE = 4;

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

        int total = items.size();
        int totalPages = Math.max(1, (int) Math.ceil(total / (double) WISHLIST_PAGE_SIZE));
        int current = 1;
        try {
            current = Integer.parseInt(request.getParameter("page").trim());
        } catch (RuntimeException ignored) {
            // không có / sai tham số page -> trang 1
        }
        current = Math.min(Math.max(current, 1), totalPages);
        int from = (current - 1) * WISHLIST_PAGE_SIZE;
        List<Product> pageItems = total == 0
                ? new ArrayList<Product>()
                : new ArrayList<>(items.subList(from, Math.min(from + WISHLIST_PAGE_SIZE, total)));

        request.setAttribute("wishlistItems", pageItems);
        request.setAttribute("wishlistCount", total);
        request.setAttribute("currentPage", current);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", total);
        request.setAttribute("pageSize", WISHLIST_PAGE_SIZE);
        request.getRequestDispatcher("/views/wishlist/wishlist.jsp").forward(request, response);
    }
}
