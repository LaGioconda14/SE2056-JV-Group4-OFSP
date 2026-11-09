package controller.shop;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.entity.promotion.Promotion;
import service.IShopPromotionService;
import service.impl.ShopPromotionServiceImpl;

/**
 * Quản lý Promotion (khuyến mãi tự động theo sản phẩm) của shop (FE-08).
 * Các loại: FIXED_PRICE (đồng giá), VOLUME (mua nhiều giảm sâu),
 * TIME_WINDOW (giảm tiền theo khung giờ / ngày cố định) + suất ưu đãi (quota) và lịch áp dụng tuỳ chọn.
 * (PERCENTAGE / FIXED_AMOUNT là loại cũ trùng voucher nên không cho tạo mới.)
 *   GET  /shop/promotions                    danh sách + lọc tab + tìm kiếm
 *   GET  /shop/promotions?action=new         form tạo mới
 *   GET  /shop/promotions?action=edit&id=    form sửa
 *   POST /shop/promotions  action=save|toggle|terminate
 */
@WebServlet(name = "ShopPromotionServlet", urlPatterns = {"/shop/promotions"})
public class ShopPromotionServlet extends BaseShopServlet {

    private final IShopPromotionService promotionService = new ShopPromotionServiceImpl();

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
            Promotion p = id == null ? null : promotionService.findByIdAndShop(id, shopId);
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

        // ---- Danh sách ----
        String tab = request.getParameter("tab");
        if (tab == null || !tab.matches("ALL|ONGOING|UPCOMING|PAUSED|FINISHED")) {
            tab = "ALL";
        }
        String q = trimToNull(request.getParameter("q"));

        request.setAttribute("promotions", paginate(request, promotionService.listByShop(shopId, tab, q), LIST_PAGE_SIZE));
        request.setAttribute("tabCounts", promotionService.countByTab(shopId));
        request.setAttribute("summary", promotionService.getShopSummary(shopId));
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
        String back = listUrl(request, "/shop/promotions");

        if ("toggle".equals(action) || "terminate".equals(action)) {
            Integer id = parseInt(request.getParameter("id"));
            boolean ok = false;
            String msg;
            if (id == null) {
                msg = "Chương trình không hợp lệ.";
            } else if ("toggle".equals(action)) {
                boolean active = "1".equals(request.getParameter("active"));
                ok = promotionService.setActive(id, shopId, active);
                msg = ok ? (active ? "Đã kích hoạt chương trình khuyến mãi." : "Đã tạm dừng chương trình khuyến mãi.")
                         : "Không thay đổi được trạng thái (chương trình đã kết thúc hoặc không tồn tại).";
            } else {
                ok = promotionService.terminate(id, shopId);
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

        // ---- Lưu (tạo mới / cập nhật) ----
        Integer id = parseInt(request.getParameter("promotionId"));
        boolean editing = id != null && id > 0;
        if (editing) {
            Promotion existing = promotionService.findByIdAndShop(id, shopId);
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

        boolean ok = editing ? promotionService.update(p) : promotionService.create(p) > 0;
        if (!ok) {
            request.setAttribute("formError", "Không lưu được chương trình khuyến mãi, vui lòng thử lại.");
            showForm(request, response, shopId, p, editing ? "edit" : "create");
            return;
        }
        flash(request, true, editing ? "Đã cập nhật chương trình \"" + p.getName() + "\"." : "Đã tạo chương trình \"" + p.getName() + "\".");
        response.sendRedirect(request.getContextPath() + "/shop/promotions");
    }

    // ------------------------------------------------------------------

    private void showForm(HttpServletRequest request, HttpServletResponse response, long shopId, Promotion p, String mode)
            throws ServletException, IOException {
        request.setAttribute("promotion", p);
        request.setAttribute("mode", mode);
        request.setAttribute("pickerProducts", promotionService.getShopProductsForPicker(shopId));
        request.getRequestDispatcher("/views/shop/shop-promotion-form.jsp").forward(request, response);
    }

    private Promotion readForm(HttpServletRequest req, long shopId, long id) {
        Promotion p = new Promotion();
        p.setPromotionId(id);
        p.setShopId(shopId);
        p.setName(trimToNull(req.getParameter("name")));
        p.setDescription(trimToNull(req.getParameter("description")));
        String type = req.getParameter("promotionType");
        if (type == null || !type.matches("FIXED_PRICE|VOLUME|TIME_WINDOW")) {
            type = Promotion.FIXED_PRICE;
        }
        p.setPromotionType(type);
        // Chỉ đọc các trường thuộc đúng loại đã chọn, các trường còn lại để null
        if (p.isVolume()) {
            p.setDiscountValue(parsePercent(req.getParameter("discountValue")));
            p.setMaxDiscountAmount(parseMoney(req.getParameter("maxDiscountAmount")));
        } else if (p.isTimeWindow() || p.isFixedPrice()) {
            p.setDiscountValue(parseMoney(req.getParameter("discountValue")));
        }
        if (p.isVolume()) {
            p.setMinQuantity(parseInt(req.getParameter("minQuantity")));
        }
        p.setQuota(parseInt(req.getParameter("quota")));
        // Lịch áp dụng: thứ trong tuần (1 = Thứ 2 ... 7 = Chủ nhật) + khung giờ trong ngày
        java.util.TreeSet<Integer> days = new java.util.TreeSet<>();
        String[] dayParams = req.getParameterValues("activeDays");
        if (dayParams != null) {
            for (String d : dayParams) {
                try {
                    days.add(Integer.parseInt(d.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        if (days.size() < 7) { // chọn đủ 7 ngày = mọi ngày = không giới hạn
            StringBuilder sb = new StringBuilder();
            for (int d : days) {
                if (d >= 1 && d <= 7) sb.append(sb.length() > 0 ? "," : "").append(d);
            }
            p.setActiveDays(sb.toString());
        }
        p.setDailyStartTime(trimToNull(req.getParameter("dailyStartTime")));
        p.setDailyEndTime(trimToNull(req.getParameter("dailyEndTime")));
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
        String typeError = validateType(p);
        if (typeError != null) {
            return typeError;
        }
        if (p.getQuota() != null) {
            if (p.getQuota() < 1 || p.getQuota() > 1_000_000) {
                return "Suất ưu đãi phải từ 1 đến 1.000.000 (để trống nếu không giới hạn).";
            }
            if (editing) {
                Promotion old = promotionService.findByIdAndShop(p.getPromotionId(), shopId);
                if (old != null && p.getQuota() < old.getSoldQuantity()) {
                    return "Suất ưu đãi không được nhỏ hơn số đã dùng (" + old.getSoldQuantity() + ").";
                }
            }
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
        if (p.isFixedPrice() || p.isTimeWindow()) {
            List<String> tooLow = new java.util.ArrayList<>();
            for (java.util.Map<String, Object> row : promotionService.getShopProductsForPicker(shopId)) {
                Long pid = (Long) row.get("productId");
                BigDecimal minPrice = (BigDecimal) row.get("minPrice");
                if (p.getProductIds().contains(pid) && minPrice != null && p.getDiscountValue().compareTo(minPrice) >= 0) {
                    tooLow.add((String) row.get("name"));
                }
            }
            if (!tooLow.isEmpty()) {
                return (p.isTimeWindow() ? "Số tiền giảm phải nhỏ hơn giá bán hiện tại của: "
                        : "Giá đồng giá phải thấp hơn giá bán hiện tại của: ")
                        + String.join(", ", tooLow.size() > 3 ? tooLow.subList(0, 3) : tooLow)
                        + (tooLow.size() > 3 ? " và " + (tooLow.size() - 3) + " sản phẩm khác" : "") + ".";
            }
        }
        List<String> conflicts = promotionService.findConflictingProducts(shopId, p.getProductIds(), p.getStartDate(), p.getEndDate(), editing ? p.getPromotionId() : 0);
        if (!conflicts.isEmpty()) {
            String shown = String.join(", ", conflicts.size() > 3 ? conflicts.subList(0, 3) : conflicts);
            return "Sản phẩm đã tham gia chương trình khuyến mãi khác trong cùng thời gian: " + shown
                    + (conflicts.size() > 3 ? " và " + (conflicts.size() - 3) + " sản phẩm khác" : "")
                    + ". Hãy đổi thời gian hoặc bỏ chọn các sản phẩm này.";
        }
        return null;
    }

    /** Kiểm tra các trường riêng của từng loại khuyến mãi. */
    private String validateType(Promotion p) {
        String scheduleError = validateSchedule(p);
        if (scheduleError != null) {
            return scheduleError;
        }
        if (p.getDiscountValue() == null || p.getDiscountValue().signum() <= 0) {
            return p.isFixedPrice() ? "Vui lòng nhập giá đồng giá hợp lệ (lớn hơn 0)."
                    : "Vui lòng nhập mức giảm hợp lệ (lớn hơn 0).";
        }
        if (p.isPercentage() || p.isVolume()) {
            if (p.getDiscountValue().compareTo(BigDecimal.valueOf(90)) > 0) {
                return "Mức giảm theo phần trăm tối đa là 90%.";
            }
            if (p.getMaxDiscountAmount() != null && p.getMaxDiscountAmount().signum() < 0) {
                return "Mức giảm tối đa không hợp lệ.";
            }
            if (p.isVolume()) {
                Integer min = p.getMinQuantity();
                if (min == null || min < 2 || min > 1000) {
                    return "Số lượng tối thiểu để được giảm phải từ 2 đến 1.000.";
                }
            }
        } else if (p.isTimeWindow()) {
            if (p.getDiscountValue().compareTo(BigDecimal.valueOf(1000)) < 0) {
                return "Số tiền giảm tối thiểu là 1.000đ cho mỗi sản phẩm.";
            }
        } else if (p.isFixedPrice()) {
            if (p.getDiscountValue().compareTo(BigDecimal.valueOf(1000)) < 0) {
                return "Giá đồng giá tối thiểu là 1.000đ.";
            }
        }
        return null;
    }

    /** Kiểm tra lịch áp dụng (thứ + khung giờ). Loại TIME_WINDOW bắt buộc phải có lịch. */
    private String validateSchedule(Promotion p) {
        for (int d : p.getActiveDayNumbers()) {
            if (d < 1 || d > 7) {
                return "Ngày trong tuần không hợp lệ.";
            }
        }
        String start = p.getDailyStartTime(), end = p.getDailyEndTime();
        if ((start == null) != (end == null)) {
            return "Vui lòng nhập đủ cả giờ bắt đầu và giờ kết thúc (hoặc để trống cả hai nếu áp dụng cả ngày).";
        }
        if (start != null) {
            java.time.LocalTime s, e;
            try {
                s = java.time.LocalTime.parse(start);
                e = java.time.LocalTime.parse(end);
            } catch (java.time.format.DateTimeParseException ex) {
                return "Khung giờ không hợp lệ (định dạng HH:mm).";
            }
            if (!s.isBefore(e)) {
                return "Giờ kết thúc phải sau giờ bắt đầu (không áp dụng khung giờ qua đêm). Muốn qua đêm hãy tạo 2 chương trình.";
            }
        }
        if (p.isTimeWindow() && !p.hasDaySchedule() && !p.hasTimeSchedule()) {
            return "Loại \"Giảm tiền theo khung giờ / ngày\" cần chọn ít nhất một thứ trong tuần hoặc một khung giờ cố định.";
        }
        return null;
    }
}
