package controller.auth;

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
import service.impl.ShopRequestServiceImpl;
import util.SellerSessionUtil;

/**
 * Màn hình "Bạn muốn dùng Gốc Vườn với vai trò nào?" hiện ngay sau khi đăng ký tài khoản
 * (hoặc lần đầu đăng nhập bằng Google):
 *   - Khách hàng (người mua)  -> vào trang chủ, tài khoản vẫn là CUSTOMER
 *   - Người bán (seller)      -> sang form đăng ký gian hàng, chờ admin duyệt
 */
@WebServlet(name = "ChooseRoleServlet", urlPatterns = {"/choose-role"})
public class ChooseRoleServlet extends HttpServlet {

    private final IShopRequestService shopRequestService = new ShopRequestServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ctx = request.getContextPath();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        // Tài khoản đã có vai trò riêng thì không cần chọn nữa
        String role = (user.getRole() == null) ? "CUSTOMER" : user.getRole().toUpperCase();
        switch (role) {
            case "ADMIN":
                response.sendRedirect(ctx + "/admin/dashboard");
                return;
            case "SHOP_OWNER":
                SellerSessionUtil.initShopSession(session, user.getId());
                response.sendRedirect(ctx + "/shop/dashboard");
                return;
            case "DRIVER":
                response.sendRedirect(ctx + "/shipper/deliveries");
                return;
            default:
                break;
        }

        // Đã nộp hồ sơ bán hàng (đang chờ hoặc đã duyệt) thì sang trang theo dõi hồ sơ
        ShopRequest latest = shopRequestService.getLatestRequestByUserId(user.getId());
        if (latest != null && (SellerSessionUtil.isPending(latest.getStatus())
                || SellerSessionUtil.isApproved(latest.getStatus()))) {
            response.sendRedirect(ctx + "/seller/status");
            return;
        }

        request.getRequestDispatcher("/views/auth/choose-role.jsp").forward(request, response);
    }
}
