package controller.shop;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
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

    /** Số dòng mỗi trang cho các bảng danh sách của Kênh Người Bán (Voucher, Khuyến mãi...). */
    protected static final int LIST_PAGE_SIZE = 5;

    /**
     * Phân trang danh sách trong bộ nhớ theo tham số ?page=. Trang vượt quá giới hạn sẽ được
     * đưa về trang cuối (ví dụ vừa kết thúc/xóa dòng cuối của trang). Đặt các attribute:
     * currentPage, totalPages, totalItems, pageSize để views/common/pagination.jsp dùng.
     *
     * @return các phần tử của trang hiện tại
     */
    protected <T> List<T> paginate(HttpServletRequest req, List<T> all, int pageSize) {
        int total = (all == null) ? 0 : all.size();
        int totalPages = Math.max(1, (int) Math.ceil(total / (double) pageSize));
        Integer p = parseInt(req.getParameter("page"));
        int current = (p == null) ? 1 : Math.min(Math.max(p, 1), totalPages);
        req.setAttribute("currentPage", current);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalItems", total);
        req.setAttribute("pageSize", pageSize);
        if (total == 0) {
            return Collections.emptyList();
        }
        int from = (current - 1) * pageSize;
        int to = Math.min(from + pageSize, total);
        return new ArrayList<>(all.subList(from, to));
    }

    /**
     * URL quay lại trang danh sách sau khi POST (tạm dừng / kích hoạt / kết thúc),
     * giữ nguyên tab, từ khóa tìm kiếm và số trang mà form đã gửi kèm.
     */
    protected String listUrl(HttpServletRequest req, String basePath) {
        StringBuilder sb = new StringBuilder(req.getContextPath()).append(basePath);
        String sep = "?";
        String tab = req.getParameter("tab");
        if (tab != null && tab.matches("ALL|ONGOING|UPCOMING|PAUSED|FINISHED")) {
            sb.append(sep).append("tab=").append(tab);
            sep = "&";
        }
        String q = trimToNull(req.getParameter("q"));
        if (q != null) {
            try {
                sb.append(sep).append("q=").append(URLEncoder.encode(q, "UTF-8"));
                sep = "&";
            } catch (UnsupportedEncodingException ignored) {
                // UTF-8 luôn được hỗ trợ
            }
        }
        Integer page = parseInt(req.getParameter("page"));
        if (page != null && page > 1) {
            sb.append(sep).append("page=").append(page);
        }
        return sb.toString();
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
