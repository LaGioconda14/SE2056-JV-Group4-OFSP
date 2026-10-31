package controller.shop;

import dao.PromotionDAO;
import dao.VoucherDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Voucher;

@WebServlet(name = "ShopVoucherServlet", urlPatterns = {"/shop/vouchers"})
public class ShopVoucherServlet extends BaseShopServlet {
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final PromotionDAO promotionDAO = new PromotionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long shopId = requireShop(request, response);
        if (shopId == null) return;

        String action = request.getParameter("action");
        if ("new".equals(action)) {
            Voucher v = new Voucher();
            long now = System.currentTimeMillis();
            v.setDiscountType("PERCENTAGE");
            v.setStartDate(new Timestamp(now));
            v.setEndDate(new Timestamp(now + 30L * 24 * 3600 * 1000));
            showForm(request, response, shopId, v, "create");
            return;
        }
        if ("edit".equals(action) || "usage".equals(action)) {
            Integer id = parseInt(request.getParameter("id"));
            Voucher v = id == null ? null : voucherDAO.findByIdAndShop(id, shopId);
            if (v == null) {
                flash(request, false, "Không tìm thấy voucher.");
                response.sendRedirect(request.getContextPath() + "/shop/vouchers");
                return;
            }
            if ("usage".equals(action)) {
                request.setAttribute("voucher", v);
                request.setAttribute("usageStats", voucherDAO.getUsageStats(id));
                request.setAttribute("usageList", voucherDAO.getUsageHistory(id, 200));
                request.getRequestDispatcher("/views/shop/shop-voucher-usage.jsp").forward(request, response);
                return;
            }
            if (v.getTerminatedAt() != null) {
                flash(request, false, "Voucher đã kết thúc sớm nên không thể chỉnh sửa. Bạn có thể xem lịch sử sử dụng.");
                response.sendRedirect(request.getContextPath() + "/shop/vouchers");
                return;
            }
            showForm(request, response, shopId, v, "edit");
            return;
        }

        String tab = request.getParameter("tab");
        if (tab == null || !tab.matches("ALL|ONGOING|UPCOMING|PAUSED|FINISHED")) {
            tab = "ALL";
        }
        String q = trimToNull(request.getParameter("q"));

        request.setAttribute("vouchers", voucherDAO.listByShop(shopId, tab, q));
        request.setAttribute("tabCounts", voucherDAO.countByTab(shopId));
        request.setAttribute("summary", voucherDAO.getShopSummary(shopId));
        request.setAttribute("tab", tab);
        request.setAttribute("q", q == null ? "" : q);
        request.getRequestDispatcher("/views/shop/shop-vouchers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long shopId = requireShop(request, response);
        if (shopId == null) return;

        String action = request.getParameter("action");
        String back = request.getContextPath() + "/shop/vouchers";
        String tab = request.getParameter("tab");
        if (tab != null && tab.matches("ALL|ONGOING|UPCOMING|PAUSED|FINISHED")) {
            back += "?tab=" + tab;
        }

        if ("toggle".equals(action) || "terminate".equals(action)) {
            Integer id = parseInt(request.getParameter("id"));
            boolean ok = false;
            String msg;
            if (id == null) {
                msg = "Voucher không hợp lệ.";
            } else if ("toggle".equals(action)) {
                boolean active = "1".equals(request.getParameter("active"));
                ok = voucherDAO.setActive(id, shopId, active);
                msg = ok ? (active ? "Đã kích hoạt voucher." : "Đã tạm dừng voucher.")
                         : "Không thay đổi được trạng thái (voucher đã kết thúc hoặc không tồn tại).";
            } else {
                ok = voucherDAO.terminate(id, shopId);
                msg = ok ? "Đã kết thúc voucher. Lịch sử sử dụng vẫn được lưu lại."
                         : "Không kết thúc được voucher (đã kết thúc hoặc không tồn tại).";
            }
            flash(request, ok, msg);
            response.sendRedirect(back);
            return;
        }

        if (!"save".equals(action)) {
            response.sendRedirect(back);
            return;
        }

        Integer id = parseInt(request.getParameter("couponId"));
        boolean editing = id != null && id > 0;

        Voucher existing = null;
        if (editing) {
            existing = voucherDAO.findByIdAndShop(id, shopId);
            if (existing == null || existing.getTerminatedAt() != null) {
                flash(request, false, "Voucher không tồn tại hoặc đã kết thúc, không thể chỉnh sửa.");
                response.sendRedirect(request.getContextPath() + "/shop/vouchers");
                return;
            }
        }

        Voucher v = readForm(request, existing);
        String error = validate(v, editing, existing);
        if (error != null) {
            request.setAttribute("formError", error);
            showForm(request, response, shopId, v, editing ? "edit" : "create");
            return;
        }

        boolean ok;
        if (editing) {
            v.setCouponId(id);
            ok = voucherDAO.update(v, shopId);
        } else {
            ok = voucherDAO.create(v, shopId) > 0;
        }
        if (!ok) {
            request.setAttribute("formError", "Không lưu được voucher, vui lòng thử lại.");
            showForm(request, response, shopId, v, editing ? "edit" : "create");
            return;
        }
        flash(request, true, editing ? "Đã cập nhật voucher " + v.getCode() + "." : "Đã tạo voucher " + v.getCode() + ".");
        response.sendRedirect(request.getContextPath() + "/shop/vouchers");
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, long shopId, Voucher v, String mode)
            throws ServletException, IOException {
        request.setAttribute("voucher", v);
        request.setAttribute("mode", mode);
        request.setAttribute("pickerProducts", promotionDAO.getShopProductsForPicker(shopId));
        request.getRequestDispatcher("/views/shop/shop-voucher-form.jsp").forward(request, response);
    }

    private Voucher readForm(HttpServletRequest req, Voucher existing) {
        Voucher v = new Voucher();
        if (existing != null) {
            v.setCouponId(existing.getCouponId());
            v.setCode(existing.getCode());
            v.setUsedCount(existing.getUsedCount());
        } else {
            String code = req.getParameter("code");
            v.setCode(code == null ? "" : code.trim().toUpperCase());
        }
        v.setTitle(trimToNull(req.getParameter("title")));
        v.setDescription(trimToNull(req.getParameter("description")));
        v.setDiscountType("FIXED_AMOUNT".equals(req.getParameter("discountType")) ? "FIXED_AMOUNT" : "PERCENTAGE");
        v.setDiscountValue(v.isPercentage() ? parsePercent(req.getParameter("discountValue")) : parseMoney(req.getParameter("discountValue")));
        BigDecimal minOrder = parseMoney(req.getParameter("minOrderValue"));
        v.setMinOrderValue(minOrder == null ? BigDecimal.ZERO : minOrder);
        v.setMaxDiscountAmount(v.isPercentage() ? parseMoney(req.getParameter("maxDiscountAmount")) : null);
        Integer limit = parseInt(req.getParameter("usageLimit"));
        v.setUsageLimit(limit == null ? 0 : limit);
        Integer perUser = parseInt(req.getParameter("perUserLimit"));
        v.setPerUserLimit(perUser == null ? 0 : perUser);
        v.setStartDate(parseDateTime(req.getParameter("startDate")));
        v.setEndDate(parseDateTime(req.getParameter("endDate")));
        v.setAppliesTo("PRODUCTS".equals(req.getParameter("appliesTo")) ? "PRODUCTS" : "ALL");
        v.setProductIds(parseIdList(req.getParameterValues("productIds")));
        v.setActive(req.getParameter("active") != null);
        return v;
    }

    private String validate(Voucher v, boolean editing, Voucher existing) {
        if (!editing) {
            if (!v.getCode().matches("^[A-Z0-9_-]{4,20}$")) {
                return "Mã voucher gồm 4–20 ký tự: chữ cái không dấu, số, dấu gạch ngang hoặc gạch dưới.";
            }
            if (voucherDAO.codeExists(v.getCode(), null)) {
                return "Mã voucher \"" + v.getCode() + "\" đã tồn tại trên sàn, vui lòng chọn mã khác.";
            }
        }
        if (v.getTitle() == null || v.getTitle().length() < 3 || v.getTitle().length() > 150) {
            return "Tên chương trình voucher cần từ 3 đến 150 ký tự.";
        }
        if (v.getDescription() != null && v.getDescription().length() > 500) {
            return "Mô tả tối đa 500 ký tự.";
        }
        if (v.getDiscountValue() == null || v.getDiscountValue().signum() <= 0) {
            return "Vui lòng nhập mức giảm hợp lệ (lớn hơn 0).";
        }
        if (v.isPercentage()) {
            if (v.getDiscountValue().compareTo(BigDecimal.valueOf(100)) > 0) {
                return "Mức giảm theo phần trăm không được vượt quá 100%.";
            }
            if (v.getMaxDiscountAmount() != null && v.getMaxDiscountAmount().signum() < 0) {
                return "Mức giảm tối đa không hợp lệ.";
            }
        } else {
            if (v.getDiscountValue().compareTo(BigDecimal.valueOf(1000)) < 0) {
                return "Mức giảm cố định tối thiểu là 1.000đ.";
            }
            if (v.getMinOrderValue().signum() > 0 && v.getDiscountValue().compareTo(v.getMinOrderValue()) > 0) {
                return "Mức giảm cố định không được lớn hơn giá trị đơn hàng tối thiểu.";
            }
        }
        if (v.getMinOrderValue().signum() < 0) {
            return "Giá trị đơn hàng tối thiểu không hợp lệ.";
        }
        if (v.getUsageLimit() < 1 || v.getUsageLimit() > 1000000) {
            return "Tổng số lượt sử dụng phải từ 1 đến 1.000.000.";
        }
        if (editing && existing != null && v.getUsageLimit() < existing.getUsedCount()) {
            return "Tổng số lượt không được nhỏ hơn số lượt đã dùng (" + existing.getUsedCount() + ").";
        }
        if (v.getPerUserLimit() < 1 || v.getPerUserLimit() > v.getUsageLimit()) {
            return "Số lượt tối đa mỗi khách phải từ 1 và không vượt quá tổng số lượt.";
        }
        if (v.getStartDate() == null || v.getEndDate() == null) {
            return "Vui lòng chọn thời gian bắt đầu và kết thúc.";
        }
        if (!v.getEndDate().after(v.getStartDate())) {
            return "Thời gian kết thúc phải sau thời gian bắt đầu.";
        }
        if (!editing && !v.getEndDate().after(new Timestamp(System.currentTimeMillis()))) {
            return "Thời gian kết thúc phải ở tương lai.";
        }
        if ("PRODUCTS".equals(v.getAppliesTo()) && v.getProductIds().isEmpty()) {
            return "Vui lòng chọn ít nhất một sản phẩm được áp dụng voucher.";
        }
        return null;
    }
}
