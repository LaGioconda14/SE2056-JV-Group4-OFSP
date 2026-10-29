package controller.seller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ShopRequest;
import model.User;
import service.IShopRequestService;
import service.IUserService;
import service.impl.ShopRequestServiceImpl;
import service.impl.UserServiceImpl;
import util.SellerSessionUtil;

/**
 * Cổng vào kênh người bán cho tài khoản đang là khách hàng:
 *   GET /seller/status : theo dõi hồ sơ đăng ký bán hàng (chờ duyệt / bị từ chối / đã duyệt)
 *   GET /seller/enter  : vào trang người bán (dashboard) ngay khi hồ sơ đã được duyệt,
 *                        không cần đăng xuất rồi đăng nhập lại
 *
 * Vai trò của user được đọc lại từ database mỗi lần vào, vì admin có thể vừa duyệt hồ sơ
 * (đổi CUSTOMER -> SHOP_OWNER) trong khi session của người dùng vẫn giữ vai trò cũ.
 */
@WebServlet(name = "SellerPortalServlet", urlPatterns = {"/seller/status", "/seller/enter"})
public class SellerPortalServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();
    private final IShopRequestService shopRequestService = new ShopRequestServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;
        if (sessionUser == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        // Làm mới vai trò từ DB
        User user = userService.getUserById(sessionUser.getId());
        if (user != null) {
            session.setAttribute("user", user);
        } else {
            user = sessionUser;
        }

        boolean isOwner = "SHOP_OWNER".equalsIgnoreCase(user.getRole());
        if (isOwner) {
            SellerSessionUtil.initShopSession(session, user.getId());
        }

        // /seller/enter: đã là chủ shop thì vào dashboard, chưa thì về trang theo dõi hồ sơ
        if ("/seller/enter".equals(request.getServletPath())) {
            response.sendRedirect(ctx + (isOwner ? "/shop/dashboard" : "/seller/status"));
            return;
        }

        ShopRequest latest = shopRequestService.getLatestRequestByUserId(user.getId());
        if (!isOwner && latest == null) {
            // Chưa từng đăng ký bán hàng -> sang form đăng ký
            response.sendRedirect(ctx + "/register-shop");
            return;
        }

        String state;
        if (isOwner || (latest != null && SellerSessionUtil.isApproved(latest.getStatus()))) {
            state = "APPROVED";
        } else if (SellerSessionUtil.isPending(latest.getStatus())) {
            state = "PENDING";
        } else {
            state = "REJECTED";
        }

        request.setAttribute("sellerState", state);
        request.setAttribute("shopRequest", latest);
        request.getRequestDispatcher("/views/shop/seller-status.jsp").forward(request, response);
    }
}
