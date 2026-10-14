package controller.shop;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Shop;
import model.User;
import dao.ShopDAO;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopDashboardServlet", urlPatterns = {"/shop/dashboard", "/shop"})
public class ShopDashboardServlet extends HttpServlet {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập và phân quyền chủ shop
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Lấy shopId từ session hoặc database
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            }
        }

        // Lấy thông tin chi tiết Shop nếu chưa có trong session
        if (session.getAttribute("shopName") == null && shopId != null && shopId > 0) {
            Shop shop = shopDAO.getShopByOwnerId(user.getId());
            if (shop != null) {
                session.setAttribute("shopName", shop.getShopName());
                session.setAttribute("shopLogo", shop.getLogoUrl());
                session.setAttribute("shopStatus", shop.getStatus());
            }
        }

        // 3. Chuẩn bị các chỉ số thống kê cho Dashboard
        // Doanh thu hôm nay
        BigDecimal todayRevenue = new BigDecimal("14850000");
        int successfulOrders = 38;
        int newOrdersCount = 18;
        int pendingPack = 8;
        int pendingPickup = 4;
        int delivering = 6;
        
        // Thống kê sản phẩm
        int totalProducts = 42;
        int totalSkus = 115;
        int lowStockCount = 3;
        
        // Đánh giá
        double ratingAvg = 4.8;
        int totalReviews = 320;
        double satisfactionRate = 98.4;

        // Quyết toán ví
        BigDecimal payoutAmount = new BigDecimal("28450000");
        BigDecimal subOrderTotal = new BigDecimal("29947000");
        BigDecimal feeAmount = new BigDecimal("1497000");

        request.setAttribute("todayRevenue", todayRevenue);
        request.setAttribute("successfulOrders", successfulOrders);
        request.setAttribute("newOrdersCount", newOrdersCount);
        request.setAttribute("pendingPack", pendingPack);
        request.setAttribute("pendingPickup", pendingPickup);
        request.setAttribute("delivering", delivering);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalSkus", totalSkus);
        request.setAttribute("lowStockCount", lowStockCount);
        request.setAttribute("ratingAvg", ratingAvg);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("satisfactionRate", satisfactionRate);
        request.setAttribute("payoutAmount", payoutAmount);
        request.setAttribute("subOrderTotal", subOrderTotal);
        request.setAttribute("feeAmount", feeAmount);

        // Chuyển tiếp tới giao diện dashboard
        request.getRequestDispatcher("/views/shop/shop-dashboard.jsp").forward(request, response);
    }
}

