package filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

/**
 * Nạp dữ liệu dùng chung cho sidebar của Kênh Người Bán (views/shop/layout/sidebar.jsp).
 * Chạy cho mọi trang /shop/* nên mọi trang seller đều hiển thị cùng một số liệu trên badge,
 * không phụ thuộc servlet của từng trang có tự set hay không.
 *
 * Request attribute được set:
 *   - sidebarLowStockCount : số SKU sắp hết hàng của shop (badge đỏ ở mục "Kho & Cảnh báo tồn")
 */
@WebFilter(filterName = "ShopLayoutFilter", urlPatterns = {"/shop/*"})
public class ShopLayoutFilter implements Filter {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;

        if ("GET".equalsIgnoreCase(req.getMethod())) {
            HttpSession session = req.getSession(false);
            Object u = (session != null) ? session.getAttribute("user") : null;

            if (u instanceof User && "SHOP_OWNER".equalsIgnoreCase(((User) u).getRole())) {
                try {
                    Long shopId = (Long) session.getAttribute("shopId");
                    if (shopId == null) {
                        shopId = shopProductService.getShopIDByOwnerID(((User) u).getId());
                    }
                    if (shopId != null && shopId > 0) {
                        req.setAttribute("sidebarLowStockCount", shopProductService.getLowStockCountByShopId(shopId));
                    }
                } catch (Exception e) {
                    // Không để lỗi đếm badge làm hỏng cả trang; sidebar sẽ hiện 0
                    e.printStackTrace();
                }
            }
        }

        chain.doFilter(request, response);
    }
}
