package controller.shop;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.IShopProductService;
import service.impl.ShopProductServiceImpl;

/**
 * Lớp cha cho các servlet của Kênh Người Bán: kiểm tra đăng nhập/role SHOP_OWNER,
 * lấy shopId, và các hàm đọc dữ liệu form dùng chung.
 */
public abstract class BaseShopServlet extends HttpServlet {

    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    /** Trả về shopId của chủ shop đang đăng nhập; null nếu đã chuyển hướng (chưa đăng nhập / chưa có shop). */
    protected Long requireShop(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null) {
            long id = shopProductService.getShopIDByOwnerID(user.getId());
            if (id > 0) {
                shopId = id;
                session.setAttribute("shopId", shopId);
            }
        }
        if (shopId == null || shopId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/register-shop");
            return null;
        }
        return shopId;
    }

    protected void flash(HttpServletRequest req, boolean success, String message) {
        req.getSession().setAttribute(success ? "successMessage" : "errorMessage", message);
    }

    /** Đọc số tiền: chấp nhận "1.000", "1,000", "1000"; trả về null nếu rỗng hoặc sai định dạng. */
    protected static BigDecimal parseMoney(String s) {
        if (s == null) return null;
        String t = s.trim().replace(".", "").replace(",", "").replace(" ", "");
        if (t.isEmpty()) return null;
        try {
            return new BigDecimal(t);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Đọc phần trăm (cho phép số thập phân, dấu , hoặc .). */
    protected static BigDecimal parsePercent(String s) {
        if (s == null) return null;
        String t = s.trim().replace(',', '.');
        if (t.isEmpty()) return null;
        try {
            return new BigDecimal(t);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    protected static Integer parseInt(String s) {
        if (s == null) return null;
        try {
            return Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Đọc giá trị của thẻ datetime-local (yyyy-MM-ddTHH:mm). */
    protected static Timestamp parseDateTime(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return Timestamp.valueOf(LocalDateTime.parse(s.trim()));
        } catch (Exception e) {
            return null;
        }
    }

    protected static List<Long> parseIdList(String[] values) {
        List<Long> ids = new ArrayList<>();
        if (values != null) {
            for (String v : values) {
                try {
                    Long id = Long.valueOf(v.trim());
                    if (!ids.contains(id)) ids.add(id);
                } catch (NumberFormatException ignored) {
                    // bỏ qua giá trị không hợp lệ
                }
            }
        }
        return ids;
    }

    protected static String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
