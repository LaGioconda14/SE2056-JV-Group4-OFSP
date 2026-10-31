package controller.shop;

import dao.PromotionDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Promotion;

@WebServlet(name = "ShopPromotionServlet", urlPatterns = {"/shop/promotions"})
public class ShopPromotionServlet extends BaseShopServlet {
    private final PromotionDAO promotionDAO = new PromotionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long shopId = requireShop(request, response);
        if (shopId == null) return;

        String action = request.getParameter("action");
        if ("new".equals(action)) {
            Promotion p = new Promotion();
            long now = System.currentTimeMillis();
            p.setPromotionType("PERCENTAGE");
            p.setStartDate(new Timestamp(now));
            p.setEndDate(new Timestamp(now + 7L * 24 * 3600 * 1000));
            showForm(request, response, shopId, p, "create");
            return;
        }
        if ("edit".equals(action)) {
            Integer id = parseInt(request.getParameter("id"));
            Promotion p = id == null ? null : promotionDAO.findByIdAndShop(id, shopId);
            if (p == null) {
                flash(request, false, "Không tìm thấy chương trình khuyến mãi.");
                response.sendRedirect(request.getContextPath() + "/shop/promotions");
                return;
            }
            if (p.getTerminatedAt() != null) {
                flash(request, false, "Chương trình đã kết thúc sớm nên không thể chỉnh sửa.");
                response.sendRedirect(request.getContextPath() + "/shop/promotions");
                return;
            }
            showForm(request, response, shopId, p, "edit");
            return;
        }

        String tab = request.getParameter("tab");
        if (tab == null || !tab.matches("ALL|ONGOING|UPCOMING|PAUSED|FINISHED")) {
            tab = "ALL";
        }
        String q = trimToNull(request.getParameter("q"));

        request.setAttribute("promotions", promotionDAO.listByShop(shopId, tab, q));
        request.setAttribute("tabCounts", promotionDAO.countByTab(shopId));
        request.setAttribute("summary", promotionDAO.getShopSummary(shopId));
        request.setAttribute("tab", tab);
        request.setAttribute("q", q == null ? "" : q);
        request.getRequestDispatcher("/views/shop/shop-promotions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long shopId = requireShop(request, response);
        if (shopId == null) return;

        String action = request.getParameter("action");
        String back = request.getContextPath() + "/shop/promotions";
        String tab = request.getParameter("tab");
        if (tab != null && tab.matches("ALL|ONGOING|UPCOMING|PAUSED|FINISHED")) {
            back += "?tab=" + tab;
        }

        if ("toggle".equals(action) || "terminate".equals(action)) {
            Integer id = parseInt(request.getParameter("id"));
            boolean ok = false;
            String msg;
            if (id == null) {
                msg = "Chương trình không hợp lệ.";
            } else if ("toggle".equals(action)) {
                boolean active = "1".equals(request.getParameter("active"));
                ok = promotionDAO.setActive(id, shopId, active);
                msg = ok ? (active ? "Đã kích hoạt chương trình khuyến mãi." : "Đã tạm dừng chương trình khuyến mãi.")
                         : "Không thay đổi được trạng thái (chương trình đã kết thúc hoặc không tồn tại).";
            } else {
                ok = promotionDAO.terminate(id, shopId);
                msg = ok ? "Đã kết thúc chương trình khuyến mãi."
                         : "Không kết thúc được chương trình (đã kết thúc hoặc không tồn tại).";
            }
            flash(request, ok, msg);
            response.sendRedirect(back);
            return;
        }

        if (!"save".equals(action)) {
            response.sendRedirect(back);
            return;
        }

        Integer id = parseInt(request.getParameter("promotionId"));
        boolean editing = id != null && id > 0;
        if (editing) {
            Promotion existing = promotionDAO.findByIdAndShop(id, shopId);
            if (existing == null || existing.getTerminatedAt() != null) {
                flash(request, false, "Chương trình không tồn tại hoặc đã kết thúc, không thể chỉnh sửa.");
                response.sendRedirect(request.getContextPath() + "/shop/promotions");
                return;
            }
        }

        Promotion p = readForm(request, shopId, editing ? id : 0);
        String error = validate(p, shopId, editing);
        if (error != null) {
            request.setAttribute("formError", error);
            showForm(request, response, shopId, p, editing ? "edit" : "create");
            return;
        }

        boolean ok = editing ? promotionDAO.update(p) : promotionDAO.create(p) > 0;
        if (!ok) {
            request.setAttribute("formError", "Không lưu được chương trình khuyến mãi, vui lòng thử lại.");
            showForm(request, response, shopId, p, editing ? "edit" : "create");
            return;
        }
        flash(request, true, editing ? "Đã cập nhật chương trình \"" + p.getName() + "\"." : "Đã tạo chương trình \"" + p.getName() + "\".");
        response.sendRedirect(request.getContextPath() + "/shop/promotions");
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, long shopId, Promotion p, String mode)
            throws ServletException, IOException {
        request.setAttribute("promotion", p);
        request.setAttribute("mode", mode);
        request.setAttribute("pickerProducts", promotionDAO.getShopProductsForPicker(shopId));
        request.getRequestDispatcher("/views/shop/shop-promotion-form.jsp").forward(request, response);
    }

    private Promotion readForm(HttpServletRequest req, long shopId, long id) {
        Promotion p = new Promotion();
        p.setPromotionId(id);
        p.setShopId(shopId);
        p.setName(trimToNull(req.getParameter("name")));
        p.setDescription(trimToNull(req.getParameter("description")));
        p.setPromotionType("FIXED_AMOUNT".equals(req.getParameter("promotionType")) ? "FIXED_AMOUNT" : "PERCENTAGE");
        p.setDiscountValue(p.isPercentage() ? parsePercent(req.getParameter("discountValue")) : parseMoney(req.getParameter("discountValue")));
        p.setMaxDiscountAmount(p.isPercentage() ? parseMoney(req.getParameter("maxDiscountAmount")) : null);
        p.setStartDate(parseDateTime(req.getParameter("startDate")));
        p.setEndDate(parseDateTime(req.getParameter("endDate")));
        p.setProductIds(parseIdList(req.getParameterValues("productIds")));
        p.setActive(req.getParameter("active") != null);
        return p;
    }

    private String validate(Promotion p, long shopId, boolean editing) {
        if (p.getName() == null || p.getName().length() < 3 || p.getName().length() > 150) {
            return "Tên chương trình cần từ 3 đến 150 ký tự.";
        }
        if (p.getDescription() != null && p.getDescription().length() > 500) {
            return "Mô tả tối đa 500 ký tự.";
        }
        if (p.getDiscountValue() == null || p.getDiscountValue().signum() <= 0) {
            return "Vui lòng nhập mức giảm hợp lệ (lớn hơn 0).";
        }
        if (p.isPercentage()) {
            if (p.getDiscountValue().compareTo(BigDecimal.valueOf(90)) > 0) {
                return "Mức giảm theo phần trăm tối đa là 90%.";
            }
            if (p.getMaxDiscountAmount() != null && p.getMaxDiscountAmount().signum() < 0) {
                return "Mức giảm tối đa không hợp lệ.";
            }
        } else if (p.getDiscountValue().compareTo(BigDecimal.valueOf(1000)) < 0) {
            return "Mức giảm cố định tối thiểu là 1.000đ cho mỗi sản phẩm.";
        }
        if (p.getStartDate() == null || p.getEndDate() == null) {
            return "Vui lòng chọn thời gian bắt đầu và kết thúc.";
        }
        if (!p.getEndDate().after(p.getStartDate())) {
            return "Thời gian kết thúc phải sau thời gian bắt đầu.";
        }
        if (!editing && !p.getEndDate().after(new Timestamp(System.currentTimeMillis()))) {
            return "Thời gian kết thúc phải ở tương lai.";
        }
        if (p.getProductIds().isEmpty()) {
            return "Vui lòng chọn ít nhất một sản phẩm tham gia khuyến mãi.";
        }
        List<String> conflicts = promotionDAO.findConflictingProducts(shopId, p.getProductIds(), p.getStartDate(), p.getEndDate(), editing ? p.getPromotionId() : 0);
        if (!conflicts.isEmpty()) {
            String shown = String.join(", ", conflicts.size() > 3 ? conflicts.subList(0, 3) : conflicts);
            return "Sản phẩm đã tham gia chương trình khuyến mãi khác trong cùng thời gian: " + shown
                    + (conflicts.size() > 3 ? " và " + (conflicts.size() - 3) + " sản phẩm khác" : "")
                    + ". Hãy đổi thời gian hoặc bỏ chọn các sản phẩm này.";
        }
        return null;
    }
}
