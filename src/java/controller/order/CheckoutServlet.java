package controller.order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.CartItem;
import model.Coupon;
import model.CustomerAddress;
import model.Order;
import model.User;
import service.IOrderService;
import service.impl.OrderServiceImpl;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CheckoutServlet.class.getName());
    private static final int MAX_CHECKOUT_ITEMS = 100;
    private transient IOrderService orderService;

    public CheckoutServlet() {
        this(new OrderServiceImpl());
    }

    CheckoutServlet(IOrderService orderService) {
        this.orderService = orderService;
    }

    @Override
    public void init() {
        if (orderService == null) {
            orderService = new OrderServiceImpl();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processCheckout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processCheckout(request, response);
    }

    private void processCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isActive()) {
            request.getSession(true).setAttribute("errorMessage",
                    "Vui lòng đăng nhập để tiến hành thanh toán!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            CheckoutSelection selection = parseSelection(request, session);
            List<CartItem> selectedItems = orderService.getSelectedItemsForCheckout(
                    user.getId(), selection.itemIds());
            Map<Long, List<CartItem>> itemsByShop = groupItemsByShop(selectedItems);
            DraftResult draft = buildDraftWithVoucherFallback(user.getId(), selectedItems,
                    selection.couponCode(), selection.shopCouponCodes(), request, session);
            setViewAttributes(request, user.getId(), selection.itemIds(), selectedItems,
                    itemsByShop, draft);
            request.getRequestDispatcher("/views/order/checkout.jsp").forward(request, response);
        } catch (IllegalArgumentException ex) {
            session.setAttribute("cartError", ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/cart");
        } catch (RuntimeException ex) {
            LOGGER.log(Level.SEVERE, "Checkout preparation failed", ex);
            session.setAttribute("cartError",
                    "Không thể chuẩn bị thanh toán. Vui lòng thử lại sau!");
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private CheckoutSelection parseSelection(HttpServletRequest request, HttpSession session) {
        List<Long> itemIds = parseOrRestoreItemIds(request, session);
        String couponCode = parsePlatformCoupon(request, session);
        Map<Long, String> shopCoupons = parseShopCoupons(request, session);
        return new CheckoutSelection(itemIds, couponCode, shopCoupons);
    }

    private List<Long> parseOrRestoreItemIds(HttpServletRequest request, HttpSession session) {
        String[] values = request.getParameterValues("cartItemIds");
        List<Long> ids;
        if (values != null && values.length > 0) {
            if (values.length > MAX_CHECKOUT_ITEMS) {
                throw new IllegalArgumentException(
                        "Bạn chỉ có thể thanh toán tối đa 100 dòng sản phẩm mỗi lần!");
            }
            Set<Long> uniqueIds = new LinkedHashSet<>();
            for (String value : values) {
                long id = parsePositiveId(value, "Danh sách sản phẩm thanh toán không hợp lệ!");
                if (!uniqueIds.add(id)) {
                    throw new IllegalArgumentException(
                            "Danh sách sản phẩm thanh toán chứa sản phẩm trùng lặp!");
                }
            }
            ids = new ArrayList<>(uniqueIds);
            session.setAttribute("checkoutItemIds", ids);
        } else {
            ids = restoreItemIds(session);
        }
        if (ids.isEmpty()) {
            throw new IllegalArgumentException(
                    "Vui lòng chọn ít nhất một sản phẩm từ giỏ hàng để mua!");
        }
        if (ids.size() > MAX_CHECKOUT_ITEMS) {
            throw new IllegalArgumentException(
                    "Bạn chỉ có thể thanh toán tối đa 100 dòng sản phẩm mỗi lần!");
        }
        return ids;
    }

    private List<Long> restoreItemIds(HttpSession session) {
        Object saved = session.getAttribute("checkoutItemIds");
        if (!(saved instanceof List<?> savedIds)) {
            return new ArrayList<>();
        }
        Set<Long> uniqueIds = new LinkedHashSet<>();
        for (Object value : savedIds) {
            if (!(value instanceof Long id) || id <= 0 || !uniqueIds.add(id)) {
                throw new IllegalArgumentException(
                        "Danh sách sản phẩm thanh toán đã lưu không hợp lệ!");
            }
        }
        return new ArrayList<>(uniqueIds);
    }

    private String parsePlatformCoupon(HttpServletRequest request, HttpSession session) {
        String couponCode = request.getParameter("couponCode");
        String removeCoupon = request.getParameter("removeCoupon");
        if ("true".equalsIgnoreCase(removeCoupon) || "1".equals(removeCoupon)
                || (couponCode != null && couponCode.trim().isEmpty())) {
            session.removeAttribute("checkoutCouponCode");
            return null;
        }
        if (couponCode == null) {
            return (String) session.getAttribute("checkoutCouponCode");
        }
        String normalized = couponCode.trim().toUpperCase(Locale.ROOT);
        session.setAttribute("checkoutCouponCode", normalized);
        return normalized;
    }

    private Map<Long, String> parseShopCoupons(HttpServletRequest request, HttpSession session) {
        Map<Long, String> coupons = restoredShopCoupons(session);
        if ("true".equalsIgnoreCase(request.getParameter("replaceShopCoupons"))) {
            coupons.clear();
        }

        String removeShopId = request.getParameter("removeShopCoupon");
        if (removeShopId != null && !removeShopId.isBlank()) {
            coupons.remove(parsePositiveId(removeShopId, "Cửa hàng cần gỡ mã không hợp lệ!"));
        }

        String shopId = request.getParameter("shopId");
        String shopCouponCode = request.getParameter("shopCouponCode");
        if (shopId != null || shopCouponCode != null) {
            if (shopId == null || shopCouponCode == null) {
                throw new IllegalArgumentException("Thông tin mã giảm giá cửa hàng không hợp lệ!");
            }
            putOrRemoveCoupon(coupons,
                    parsePositiveId(shopId, "Cửa hàng áp dụng mã không hợp lệ!"), shopCouponCode);
        }

        Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            if (name.startsWith("shopCoupon_")) {
                long id = parsePositiveId(name.substring("shopCoupon_".length()),
                        "Cửa hàng áp dụng mã không hợp lệ!");
                putOrRemoveCoupon(coupons, id, request.getParameter(name));
            }
        }
        session.setAttribute("checkoutShopCoupons", coupons);
        return coupons;
    }

    private Map<Long, String> restoredShopCoupons(HttpSession session) {
        Object saved = session.getAttribute("checkoutShopCoupons");
        Map<Long, String> result = new LinkedHashMap<>();
        if (saved == null) {
            return result;
        }
        if (!(saved instanceof Map<?, ?> savedCoupons)) {
            throw new IllegalArgumentException("Danh sách mã giảm giá đã lưu không hợp lệ!");
        }
        for (Map.Entry<?, ?> entry : savedCoupons.entrySet()) {
            if (!(entry.getKey() instanceof Long shopId) || shopId <= 0
                    || !(entry.getValue() instanceof String code) || code.isBlank()) {
                throw new IllegalArgumentException("Danh sách mã giảm giá đã lưu không hợp lệ!");
            }
            result.put(shopId, code);
        }
        return result;
    }

    private void putOrRemoveCoupon(Map<Long, String> coupons, long shopId, String code) {
        if (code == null || code.trim().isEmpty()) {
            coupons.remove(shopId);
        } else {
            coupons.put(shopId, code.trim().toUpperCase(Locale.ROOT));
        }
    }

    private Map<Long, List<CartItem>> groupItemsByShop(List<CartItem> items) {
        Map<Long, List<CartItem>> grouped = new LinkedHashMap<>();
        for (CartItem item : items) {
            if (item.getVariant() == null || item.getVariant().getProduct() == null
                    || item.getVariant().getProduct().getShopId() <= 0) {
                throw new IllegalStateException("Sản phẩm thanh toán thiếu thông tin cửa hàng.");
            }
            long shopId = item.getVariant().getProduct().getShopId();
            grouped.computeIfAbsent(shopId, key -> new ArrayList<>()).add(item);
        }
        return grouped;
    }

    private DraftResult buildDraftWithVoucherFallback(long customerId, List<CartItem> items,
            String couponCode, Map<Long, String> shopCoupons, HttpServletRequest request,
            HttpSession session) {
        try {
            return new DraftResult(orderService.buildDraftOrder(customerId, items,
                    couponCode, shopCoupons), couponCode, shopCoupons);
        } catch (IllegalArgumentException initialError) {
            request.setAttribute("checkoutError", initialError.getMessage());
        }

        String validPlatformCoupon = couponCode;
        if (validPlatformCoupon != null) {
            try {
                orderService.buildDraftOrder(customerId, items, validPlatformCoupon,
                        Collections.emptyMap());
            } catch (IllegalArgumentException platformCouponError) {
                // Chỉ gỡ mã sàn khi chính mã này không tạo được bản nháp độc lập.
                validPlatformCoupon = null;
                session.removeAttribute("checkoutCouponCode");
            }
        }

        Map<Long, String> validShopCoupons = new LinkedHashMap<>();
        for (Map.Entry<Long, String> entry : shopCoupons.entrySet()) {
            Map<Long, String> candidate = new LinkedHashMap<>(validShopCoupons);
            candidate.put(entry.getKey(), entry.getValue());
            try {
                orderService.buildDraftOrder(customerId, items, validPlatformCoupon, candidate);
                validShopCoupons.put(entry.getKey(), entry.getValue());
            } catch (IllegalArgumentException invalidShopCoupon) {
                // Mỗi mã shop được thử riêng để mã hợp lệ của các shop khác không bị xóa theo.
            }
        }

        Order draft = orderService.buildDraftOrder(customerId, items,
                validPlatformCoupon, validShopCoupons);
        if (validShopCoupons.isEmpty()) {
            session.removeAttribute("checkoutShopCoupons");
        } else {
            session.setAttribute("checkoutShopCoupons", validShopCoupons);
        }
        return new DraftResult(draft, validPlatformCoupon, validShopCoupons);
    }

    private void setViewAttributes(HttpServletRequest request, long customerId, List<Long> itemIds,
            List<CartItem> selectedItems, Map<Long, List<CartItem>> itemsByShop, DraftResult draft) {
        CustomerAddress defaultAddress = orderService.getDefaultCustomerAddress(customerId);
        List<CustomerAddress> customerAddresses = orderService.getCustomerAddresses(customerId);
        Map<Long, List<Coupon>> availableShopCoupons = new HashMap<>();
        for (Long shopId : itemsByShop.keySet()) {
            availableShopCoupons.put(shopId, orderService.getAvailableShopCoupons(shopId));
        }

        request.setAttribute("availableCoupons",
                orderService.getAvailableCoupons(draft.order().getTotalGoodsAmount()));
        request.setAttribute("availableShopCoupons", availableShopCoupons);
        request.setAttribute("selectedItems", selectedItems);
        request.setAttribute("itemsByShop", itemsByShop);
        request.setAttribute("draftOrder", draft.order());
        request.setAttribute("defaultAddress", defaultAddress);
        request.setAttribute("customerAddresses", customerAddresses);
        request.setAttribute("cartItemIds", itemIds);
        request.setAttribute("couponCode", draft.couponCode());
        request.setAttribute("shopCouponCodes", draft.shopCouponCodes());
    }

    private long parsePositiveId(String value, String message) {
        try {
            long id = Long.parseLong(value == null ? "" : value.trim());
            if (id <= 0) {
                throw new IllegalArgumentException(message);
            }
            return id;
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(message);
        }
    }

    private record CheckoutSelection(List<Long> itemIds, String couponCode,
            Map<Long, String> shopCouponCodes) {
    }

    private record DraftResult(Order order, String couponCode,
            Map<Long, String> shopCouponCodes) {
    }
}
