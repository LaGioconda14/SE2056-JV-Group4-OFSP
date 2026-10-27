package controller.order;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
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
import enums.PaymentMethod;
import model.CartItem;
import model.Coupon;
import model.CustomerAddress;
import model.Order;
import model.User;
import service.IAddressLookupService;
import service.ICustomerAddressService;
import service.IOrderService;
import service.impl.AddressLookupServiceImpl;
import service.impl.CustomerAddressServiceImpl;
import service.impl.OrderServiceImpl;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CheckoutServlet.class.getName());
    private static final int MAX_CHECKOUT_ITEMS = 100;
    private transient IOrderService orderService;
    private final IAddressLookupService addressLookupService = new AddressLookupServiceImpl();
    private final ICustomerAddressService customerAddressService = new CustomerAddressServiceImpl();

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
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isActive()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = request.getParameter("checkoutAction");
        if (action == null || action.isBlank()) {
            processCheckout(request, response);
            return;
        }
        if (!List.of("selectProvince", "selectDistrict", "selectAddress", "createAddress", "applyCoupon", "removeCoupon",
                "applyShopCoupon", "removeShopCoupon").contains(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        Map<String, String> draft = draft(session, user.getId());
        saveDraft(request, draft);
        if ("selectProvince".equals(action) || "selectDistrict".equals(action)
                || "createAddress".equals(action)) {
            draft.put("openAddressModal", "true");
        } else {
            draft.remove("openAddressModal");
        }
        if ("selectProvince".equals(action)) {
            draft.put("addressSelection", "new");
            draft.remove("districtCode");
            draft.remove("wardCode");
        } else if ("selectDistrict".equals(action)) {
            draft.put("addressSelection", "new");
            draft.remove("wardCode");
        } else if ("selectAddress".equals(action)) {
            String selected = draft.get("addressSelection");
            if (selected == null || !selected.startsWith("saved:")) {
                request.setAttribute("addressError", "Vui lòng chọn địa chỉ đã lưu!");
                draft.put("openAddressModal", "true");
            } else {
                try {
                    long addressId = parsePositiveId(selected.substring(6), "Địa chỉ không hợp lệ!");
                    if (orderService.getCustomerAddress(user.getId(), addressId) == null) {
                        throw new IllegalArgumentException("Địa chỉ không thuộc tài khoản của bạn!");
                    }
                } catch (IllegalArgumentException ex) {
                    draft.remove("addressSelection");
                    draft.put("openAddressModal", "true");
                    request.setAttribute("addressError", ex.getMessage());
                }
            }
        } else if ("createAddress".equals(action)) {
            try {
                if (!"new".equals(draft.get("addressSelection"))) {
                    throw new IllegalArgumentException("Vui lòng chọn thêm địa chỉ mới!");
                }
                String provinceCode = draft.get("provinceCode");
                String districtCode = draft.get("districtCode");
                String city = lookupName(provinces(), provinceCode);
                String district = lookupName(districts(provinceCode), districtCode);
                CustomerAddress address = new CustomerAddress();
                address.setUserId((long) user.getId());
                address.setRecipientName(draft.get("recipientName"));
                address.setRecipientPhone(draft.get("recipientPhone"));
                address.setStreetAddress(draft.get("streetAddress"));
                address.setCity(city);
                address.setDistrict(district);
                String wardCode = draft.get("wardCode");
                address.setWard(lookupName(wards(districtCode), wardCode));
                address.setDefault("true".equals(draft.get("isDefault")));
                if (!customerAddressService.addAddress(address)) {
                    throw new IllegalArgumentException("Không thể lưu địa chỉ. Vui lòng thử lại!");
                }
                if (address.getAddressId() <= 0) {
                    throw new IllegalStateException("Địa chỉ đã lưu nhưng chưa có mã. Vui lòng tải lại trang checkout!");
                }
                draft.put("addressSelection", "saved:" + address.getAddressId());
                draft.remove("openAddressModal");
                session.setAttribute("checkoutAddressSuccess", "Địa chỉ mới đã được lưu và chọn cho đơn hàng này.");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            } catch (IllegalArgumentException ex) {
                request.setAttribute("addressError", ex.getMessage());
            }
        } else if ("applyCoupon".equals(action)) {
            String code = request.getParameter("newCouponCode");
            if (code != null && !code.isBlank() && code.length() <= 100) {
                session.setAttribute("checkoutCouponCode", code.trim().toUpperCase(Locale.ROOT));
            } else {
                request.setAttribute("checkoutError", "Mã giảm giá không hợp lệ!");
            }
        } else if ("removeCoupon".equals(action)) {
            session.removeAttribute("checkoutCouponCode");
        } else if ("applyShopCoupon".equals(action) || "removeShopCoupon".equals(action)) {
            try {
                long shopId = parsePositiveId(request.getParameter("targetShopId"), "Cửa hàng không hợp lệ!");
                if (loadSelectedItems(user.getId(), restoreSelection(session))
                        .stream().noneMatch(item -> item.getVariant().getProduct().getShopId() == shopId)) {
                    throw new IllegalArgumentException("Cửa hàng không thuộc đơn hàng thanh toán!");
                }
                Map<Long, String> codes = restoredShopCoupons(session);
                if ("removeShopCoupon".equals(action)) {
                    codes.remove(shopId);
                } else {
                    String code = request.getParameter("newShopCouponCode");
                    if (code == null || code.isBlank() || code.length() > 100) {
                        throw new IllegalArgumentException("Mã giảm giá cửa hàng không hợp lệ!");
                    }
                    putOrRemoveCoupon(codes, shopId, code);
                }
                session.setAttribute("checkoutShopCoupons", codes);
            } catch (IllegalArgumentException ex) {
                request.setAttribute("checkoutError", ex.getMessage());
            }
        }
        request.setAttribute("checkoutActionHandled", true);
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
            List<CartItem> selectedItems = loadSelectedItems(user.getId(), selection);
            if (!Boolean.TRUE.equals(request.getAttribute("checkoutActionHandled"))) {
                draft(session, user.getId()).remove("openAddressModal");
            }
            Map<Long, List<CartItem>> itemsByShop = groupItemsByShop(selectedItems);
            DraftResult draft = buildDraftWithVoucherFallback(user.getId(), selectedItems,
                    selection.couponCode(), selection.shopCouponCodes(), request, session);
            setViewAttributes(request, user.getId(), selection, selectedItems,
                    itemsByShop, draft);
            Map<String, String> formDraft = draft(session, user.getId());
            request.setAttribute("formDraft", formDraft);
            String selected = formDraft.get("addressSelection");
            if (selected != null && selected.startsWith("saved:")) {
                try {
                    long addressId = Long.parseLong(selected.substring(6));
                    if (orderService.getCustomerAddress(user.getId(), addressId) == null) {
                        selected = null;
                        formDraft.remove("addressSelection");
                    }
                } catch (NumberFormatException ex) {
                    selected = null;
                    formDraft.remove("addressSelection");
                }
            }
            request.setAttribute("selectedAddressId", selected != null && selected.startsWith("saved:")
                    ? selected.substring("saved:".length()) : "");
            List<AddressOption> provinces = provinces();
            request.setAttribute("provinces", provinces);
            String provinceCode = formDraft.get("provinceCode");
            String districtCode = formDraft.get("districtCode");
            List<AddressOption> districts = lookupOptional(provinces, provinceCode)
                    ? districts(provinceCode) : Collections.emptyList();
            List<AddressOption> wards = lookupOptional(districts, districtCode)
                    ? wards(districtCode) : Collections.emptyList();
            request.setAttribute("districts", districts);
            request.setAttribute("wards", wards);
            if (provinces.isEmpty() && request.getAttribute("addressError") == null) {
                request.setAttribute("addressError", "Không thể tải danh sách tỉnh/thành. Vui lòng thử lại sau!");
            } else if (lookupOptional(provinces, provinceCode) && districts.isEmpty()
                    && request.getAttribute("addressError") == null) {
                request.setAttribute("addressError", "Không thể tải danh sách quận/huyện. Vui lòng thử lại sau!");
            } else if (lookupOptional(districts, districtCode) && wards.isEmpty()
                    && request.getAttribute("addressError") == null) {
                request.setAttribute("addressError", "Không thể tải danh sách phường/xã. Vui lòng thử lại sau!");
            }
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
        CheckoutSelection source = parseOrRestoreSource(request, session);
        String couponCode = parsePlatformCoupon(request, session);
        Map<Long, String> shopCoupons = parseShopCoupons(request, session);
        return new CheckoutSelection(source.itemIds(), source.buyNowVariantId(),
                source.buyNowQuantity(), couponCode, shopCoupons);
    }

    private CheckoutSelection parseOrRestoreSource(HttpServletRequest request, HttpSession session) {
        String[] values = request.getParameterValues("cartItemIds");
        if (values != null && values.length > 0) {
            List<Long> itemIds = parseItemIds(values);
            session.setAttribute("checkoutItemIds", itemIds);
            clearBuyNowSelection(session);
            return new CheckoutSelection(itemIds, null, null, null, Collections.emptyMap());
        }

        if ("buyNow".equals(request.getParameter("checkoutMode"))) {
            long variantId = parsePositiveId(request.getParameter("variantId"),
                    "Sản phẩm mua ngay không hợp lệ!");
            int quantity = parsePositiveQuantity(request.getParameter("quantity"));
            saveBuyNowSelection(session, variantId, quantity);
            return new CheckoutSelection(Collections.emptyList(), variantId, quantity,
                    null, Collections.emptyMap());
        }
        return restoreSelection(session);
    }

    private List<Long> parseItemIds(String[] values) {
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
        return new ArrayList<>(uniqueIds);
    }

    private CheckoutSelection restoreSelection(HttpSession session) {
        if ("buyNow".equals(session.getAttribute("checkoutMode"))) {
            Object variant = session.getAttribute("checkoutBuyNowVariantId");
            Object quantity = session.getAttribute("checkoutBuyNowQuantity");
            if (variant instanceof Long variantId && variantId > 0
                    && quantity instanceof Integer buyNowQuantity && buyNowQuantity > 0) {
                return new CheckoutSelection(Collections.emptyList(), variantId, buyNowQuantity,
                        null, Collections.emptyMap());
            }
            clearBuyNowSelection(session);
            throw new IllegalArgumentException("Thông tin mua ngay đã hết hạn hoặc không hợp lệ!");
        }

        List<Long> itemIds = restoreItemIds(session);
        if (itemIds.isEmpty()) {
            throw new IllegalArgumentException(
                    "Vui lòng chọn ít nhất một sản phẩm từ giỏ hàng để mua!");
        }
        return new CheckoutSelection(itemIds, null, null, null, Collections.emptyMap());
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

    private List<CartItem> loadSelectedItems(long customerId, CheckoutSelection selection) {
        if (selection.isBuyNow()) {
            return List.of(orderService.getBuyNowItemForCheckout(
                    selection.buyNowVariantId(), selection.buyNowQuantity()));
        }
        return orderService.getSelectedItemsForCheckout(customerId, selection.itemIds());
    }

    private void saveBuyNowSelection(HttpSession session, long variantId, int quantity) {
        session.setAttribute("checkoutMode", "buyNow");
        session.setAttribute("checkoutBuyNowVariantId", variantId);
        session.setAttribute("checkoutBuyNowQuantity", quantity);
        session.removeAttribute("checkoutItemIds");
    }

    private void clearBuyNowSelection(HttpSession session) {
        session.removeAttribute("checkoutMode");
        session.removeAttribute("checkoutBuyNowVariantId");
        session.removeAttribute("checkoutBuyNowQuantity");
    }

    private String parsePlatformCoupon(HttpServletRequest request, HttpSession session) {
        if (request.getParameter("checkoutAction") != null) {
            return (String) session.getAttribute("checkoutCouponCode");
        }
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
        if (normalized.length() > 100) {
            throw new IllegalArgumentException("Mã giảm giá không hợp lệ!");
        }
        session.setAttribute("checkoutCouponCode", normalized);
        return normalized;
    }

    private Map<Long, String> parseShopCoupons(HttpServletRequest request, HttpSession session) {
        Map<Long, String> coupons = restoredShopCoupons(session);
        if (request.getParameter("checkoutAction") != null) {
            return coupons;
        }
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
            if (code.length() > 100) {
                throw new IllegalArgumentException("Mã giảm giá cửa hàng không hợp lệ!");
            }
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

    private void setViewAttributes(HttpServletRequest request, long customerId, CheckoutSelection selection,
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
        request.setAttribute("cartItemIds", selection.itemIds());
        request.setAttribute("buyNow", selection.isBuyNow());
        request.setAttribute("buyNowVariantId", selection.buyNowVariantId());
        request.setAttribute("buyNowQuantity", selection.buyNowQuantity());
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

    private int parsePositiveQuantity(String value) {
        try {
            int quantity = Integer.parseInt(value == null ? "" : value.trim());
            if (quantity <= 0) {
                throw new IllegalArgumentException("Số lượng mua ngay không hợp lệ!");
            }
            return quantity;
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Số lượng mua ngay không hợp lệ!");
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, String> draft(HttpSession session, long userId) {
        Map<String, String> draft = (Map<String, String>) session.getAttribute("checkoutFormDraft");
        if (draft == null || !Long.toString(userId).equals(draft.get("customerId"))) {
            draft = new HashMap<>();
            draft.put("customerId", Long.toString(userId));
            session.setAttribute("checkoutFormDraft", draft);
        }
        return draft;
    }

    private void saveDraft(HttpServletRequest request, Map<String, String> draft) {
        for (String key : List.of("addressSelection", "recipientName", "recipientPhone", "streetAddress",
                "provinceCode", "districtCode", "wardCode", "paymentMethod", "deliverySlot")) {
            String value = request.getParameter(key);
            if (value != null) {
                int maxLength = "addressSelection".equals(key) ? 32 : 255;
                draft.put(key, value.substring(0, Math.min(value.length(), maxLength)));
            }
        }
        PaymentMethod paymentMethod = PaymentMethod.from(draft.get("paymentMethod"));
        if (paymentMethod != PaymentMethod.COD && paymentMethod != PaymentMethod.CARD) {
            draft.put("paymentMethod", PaymentMethod.COD.name());
        }
        draft.put("isDefault", request.getParameter("isDefault") == null ? "false" : "true");
        Enumeration<String> keys = request.getParameterNames();
        while (keys.hasMoreElements()) {
            String key = keys.nextElement();
            if (key.startsWith("shopNote_") && key.length() < 40) {
                String value = request.getParameter(key);
                draft.put(key, value == null ? "" : value.substring(0, Math.min(value.length(), 500)));
            }
        }
    }

    private List<AddressOption> provinces() {
        return parseOptions(addressLookupService.getProvincesJson(), null);
    }

    private List<AddressOption> districts(String provinceCode) {
        return parseOptions(addressLookupService.getDistrictsJson(provinceCode), "districts");
    }

    private List<AddressOption> wards(String districtCode) {
        return parseOptions(addressLookupService.getWardsJson(districtCode), "wards");
    }

    private List<AddressOption> parseOptions(String json, String property) {
        try {
            JsonElement root = JsonParser.parseString(json);
            JsonArray array = property == null ? root.getAsJsonArray() : root.getAsJsonObject().getAsJsonArray(property);
            List<AddressOption> options = new ArrayList<>();
            for (JsonElement element : array) {
                JsonObject object = element.getAsJsonObject();
                options.add(new AddressOption(object.get("code").getAsString(), object.get("name").getAsString()));
            }
            return options;
        } catch (RuntimeException ex) {
            LOGGER.log(Level.WARNING, "Address list unavailable", ex);
            return Collections.emptyList();
        }
    }

    private boolean lookupOptional(List<AddressOption> options, String code) {
        return code != null && options.stream().anyMatch(option -> option.getCode().equals(code));
    }

    private String lookupName(List<AddressOption> options, String code) {
        return options.stream().filter(option -> option.getCode().equals(code))
                .map(AddressOption::getName).findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Địa chỉ tỉnh/quận/phường không hợp lệ hoặc chưa được tải!"));
    }

    public static class AddressOption {
        private final String code;
        private final String name;

        public AddressOption(String code, String name) {
            this.code = code;
            this.name = name;
        }

        public String getCode() {
            return code;
        }

        public String getName() {
            return name;
        }

    }

    private record CheckoutSelection(List<Long> itemIds, Long buyNowVariantId,
            Integer buyNowQuantity, String couponCode, Map<Long, String> shopCouponCodes) {

        private boolean isBuyNow() {
            return buyNowVariantId != null && buyNowQuantity != null;
        }
    }

    private record DraftResult(Order order, String couponCode,
            Map<Long, String> shopCouponCodes) {
    }
}
