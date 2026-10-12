package controller.shop;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import model.ProductVariant;
import model.User;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

@WebServlet(name = "ShopProductServlet", urlPatterns = {"/shop/products"})
public class ShopProductServlet extends HttpServlet {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập và phân quyền chủ shop
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        // 2. Lấy shopId: Ưu tiên lấy trong session, nếu chưa có thì nhờ Service đi tìm
        Long shopId = (Long) session.getAttribute("shopId");

        if (shopId == null) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            // Tìm thấy thì lưu vào session luôn để lần sau khỏi phải tìm lại
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            }
        }

// 3. Chốt chặn cuối: Nếu vẫn không có shopId thì đá về login
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // 3. Lấy tham số tìm kiếm và lọc
            String keyword = request.getParameter("keyword");
            if (keyword == null || keyword.trim().isEmpty()) {
                keyword = request.getParameter("txtSearch");
            }
            String categoryId = request.getParameter("categoryId");
            String stockLevel = request.getParameter("stockLevel");

            List<ProductVariant> listVariants;

            // Nếu có từ khóa hoặc bộ lọc thì gọi hàm filter, ngược lại lấy tất cả theo shopId
            if ((keyword != null && !keyword.trim().isEmpty()) || 
                (categoryId != null && !categoryId.trim().isEmpty()) || 
                (stockLevel != null && !stockLevel.trim().isEmpty())) {
                
                listVariants = shopProductService.getVariantsByShop(shopId, keyword, categoryId, stockLevel);
            } else {
                listVariants = shopProductService.getVariantsByShopId(shopId);
            }

            // 4. Đẩy dữ liệu sang JSP
            request.setAttribute("listVariants", listVariants);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi tải danh sách sản phẩm: " + e.getMessage());
        }

        // 5. Forward giao diện
        int totalSKU = shopProductService.getTotalSkusByShopId(shopId);
        BigDecimal totalInventory = shopProductService.getTotalInventoryValueByShopId(shopId);
        int lowStock = shopProductService.getLowStockCountByShopId(shopId);
        request.setAttribute("totalSKU", totalSKU);
        request.setAttribute("totalValue", totalInventory);
        request.setAttribute("lowStockCount", lowStock);
        request.getRequestDispatcher("/views/shop/shop-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}