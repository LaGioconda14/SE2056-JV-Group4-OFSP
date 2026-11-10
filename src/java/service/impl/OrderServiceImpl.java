package service.impl;

import dao.CouponDAO;
import dao.OrderDAO;
import dao.ShopDAO;
import enums.DeliverySlot;
import enums.PaymentMethod;
import enums.PaymentStatus;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.Normalizer;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import model.entity.cart.CartItem;
import model.entity.promotion.Coupon;
import model.entity.user.CustomerAddress;
import model.dto.order.OrderDetailDTO;
import model.dto.order.OrderItemDetailDTO;
import model.dto.order.SubOrderDTO;
import model.entity.order.ShippingAddress;
import service.IOrderService;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class OrderServiceImpl implements IOrderService {

    private final OrderDAO orderDAO;
    private final CouponDAO couponDAO;
    private final ShopDAO shopDAO;
    private static final BigDecimal SAME_PROVINCE_SHIPPING_FEE = new BigDecimal("14000");
    private static final BigDecimal DIFFERENT_PROVINCE_SHIPPING_FEE = new BigDecimal("30000");
    private static final Pattern DIACRITICS = Pattern.compile("\\p{M}+");

    public OrderServiceImpl() {
        this.orderDAO = new OrderDAO();
        this.couponDAO = new CouponDAO();
        this.shopDAO = new ShopDAO();
    }

    public OrderServiceImpl(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
        this.couponDAO = new CouponDAO();
        this.shopDAO = new ShopDAO();
    }

    public OrderServiceImpl(OrderDAO orderDAO, CouponDAO couponDAO) {
        this.orderDAO = orderDAO;
        this.couponDAO = couponDAO;
        this.shopDAO = new ShopDAO();
    }

    public OrderServiceImpl(OrderDAO orderDAO, CouponDAO couponDAO, ShopDAO shopDAO) {
        this.orderDAO = orderDAO;
        this.couponDAO = couponDAO;
        this.shopDAO = shopDAO;
    }

    @Override
    public List<CartItem> getSelectedItemsForCheckout(long customerId, List<Long> cartItemIds) {
        if (cartItemIds == null || cartItemIds.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất một sản phẩm để thanh toán!");
        }

        Set<Long> uniqueIds = new LinkedHashSet<>(cartItemIds);
        if (uniqueIds.contains(null)) {
            throw new IllegalArgumentException("Danh sách sản phẩm thanh toán không hợp lệ!");
        }

        List<CartItem> selected = orderDAO.getSelectedCartItems(customerId, new ArrayList<>(uniqueIds));
        if (selected.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy sản phẩm hợp lệ nào trong giỏ hàng!");
        }
        if (selected.size() != uniqueIds.size()) {
            throw new IllegalArgumentException("Có sản phẩm không thuộc giỏ hàng của bạn hoặc đã bị xóa!");
        }

        util.PromotionPricing.applyToCartItems(selected); // khuyến mãi tính lại từ DB tại thời điểm thanh toán
        validateCheckoutItems(selected);
        return selected;
    }

    @Override
    public CartItem getBuyNowItemForCheckout(long variantId, int quantity) {
        if (variantId <= 0 || quantity <= 0) {
            throw new IllegalArgumentException("Sản phẩm mua ngay không hợp lệ!");
        }
        CartItem item = orderDAO.getBuyNowItem(variantId, quantity);
        if (item == null) {
            throw new IllegalArgumentException("Không tìm thấy sản phẩm mua ngay!");
        }
        util.PromotionPricing.applyToCartItems(List.of(item));
        validateCheckoutItems(List.of(item));
        return item;
    }

    private void validateCheckoutItems(List<CartItem> items) {
        for (CartItem item : items) {
            if (item.getVariant() == null || !item.getVariant().isActive()
                    || !item.getVariant().isProductActive()) {
                throw new IllegalStateException("Sản phẩm '"
                        + (item.getVariant() != null ? item.getVariant().getVariantName() : "")
                        + "' hiện không còn khả dụng!");
            }
            if (!"ACTIVE".equalsIgnoreCase(item.getVariant().getShopStatus())) {
                throw new IllegalStateException("Cửa hàng của sản phẩm '"
                        + item.getVariant().getProductName() + "' hiện không hoạt động!");
            }
            if (item.getQuantity() <= 0) {
                throw new IllegalStateException("Số lượng sản phẩm thanh toán phải lớn hơn 0!");
            }
            if (item.getVariant().getStockQuantity() < item.getQuantity()) {
                throw new IllegalStateException("Sản phẩm '" + item.getVariant().getProductName() + " - "
                        + item.getVariant().getVariantName() + "' chỉ còn "
                        + item.getVariant().getStockQuantity() + " sản phẩm trong kho!");
            }
        }

    }

    @Override
    public OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode) {
        return buildDraftOrder(customerId, selectedItems, couponCode, Collections.emptyMap());
    }

    @Override
    public OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode,
            Map<Long, String> shopCouponCodes) {
        return buildDraftOrder(customerId, selectedItems, couponCode, shopCouponCodes, null);
    }

    @Override
    public OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode,
            Map<Long, String> shopCouponCodes, String customerProvince) {
        OrderDetailDTO order = new OrderDetailDTO();
        order.setCustomerId(customerId);

        Map<Long, List<CartItem>> itemsByShop = new HashMap<>();
        Map<Long, String> shopNames = new HashMap<>();

        for (CartItem cartItem : selectedItems) {
            long shopId = cartItem.getVariant().getShopId();
            itemsByShop.computeIfAbsent(shopId, key -> new ArrayList<>()).add(cartItem);
            if (cartItem.getVariant().getShopName() != null) {
                shopNames.put(shopId, cartItem.getVariant().getShopName());
            }
        }

        BigDecimal totalGoods = BigDecimal.ZERO;
        BigDecimal totalShipping = BigDecimal.ZERO;
        BigDecimal totalShopDiscount = BigDecimal.ZERO;
        List<SubOrderDTO> subOrders = new ArrayList<>();
        Map<Long, String> shopProvinces = customerProvince == null || customerProvince.isBlank()
                ? Collections.emptyMap() : shopDAO.getShopProvinces(itemsByShop.keySet());

        for (Map.Entry<Long, List<CartItem>> entry : itemsByShop.entrySet()) {
            long shopId = entry.getKey();
            List<CartItem> shopItems = entry.getValue();

            SubOrderDTO sub = new SubOrderDTO();
            sub.setShopId(shopId);
            sub.setShopName(shopNames.getOrDefault(shopId, "Cửa hàng"));
            sub.setStatus("NEW");

            BigDecimal shopSubtotal = BigDecimal.ZERO;
            List<OrderItemDetailDTO> orderItems = new ArrayList<>();

            for (CartItem cartItem : shopItems) {
                OrderItemDetailDTO orderItem = new OrderItemDetailDTO();
                orderItem.setVariantId(cartItem.getVariant().getVariantId());
                orderItem.setProductNameSnapshot(cartItem.getVariant().getProductName());
                orderItem.setVariantNameSnapshot(cartItem.getVariant().getVariantName());
                orderItem.setSkuSnapshot(cartItem.getVariant().getSku());
                orderItem.setUnit(cartItem.getVariant().getUnit() != null
                        ? cartItem.getVariant().getUnit() : "phần");
                orderItem.setUnitPrice(cartItem.getVariant().getPrice());
                orderItem.setQuantity(cartItem.getQuantity());
                orderItem.setTotalPrice(cartItem.getSubtotal()); // đã trừ khuyến mãi
                if (cartItem.isOnPromotion()) {
                    orderItem.setPromotionId(cartItem.getPromotion().getPromotionId());
                    orderItem.setPromotionDiscount(cartItem.getPromotionDiscount());
                    orderItem.setPromotionUnits(cartItem.getPromotionUnits());
                }

                orderItems.add(orderItem);
                shopSubtotal = shopSubtotal.add(cartItem.getSubtotal());
            }

            sub.setItems(orderItems);
            sub.setShopSubtotal(shopSubtotal);

            BigDecimal shopShippingFee = calculateShippingFee(
                    shopProvinces.get(shopId), customerProvince);
            sub.setShopShippingFee(shopShippingFee);

            BigDecimal shopDiscount = BigDecimal.ZERO;
            if (shopCouponCodes != null && shopCouponCodes.containsKey(shopId)) {
                String sCode = shopCouponCodes.get(shopId);
                if (sCode != null && !sCode.trim().isEmpty()) {
                    Coupon sc = couponDAO.findByCode(sCode.trim());
                    validateShopCoupon(sc, shopId, shopSubtotal);
                    shopDiscount = calculateCouponDiscount(sc, shopSubtotal);
                    sub.setShopCouponId(sc.getCouponId());
                    sub.setShopCouponCode(sc.getCode());
                }
            }

            sub.setShopDiscount(shopDiscount);
            sub.setShopTotal(shopSubtotal.add(shopShippingFee).subtract(shopDiscount).max(BigDecimal.ZERO));

            subOrders.add(sub);
            totalGoods = totalGoods.add(shopSubtotal);
            totalShipping = totalShipping.add(shopShippingFee);
            totalShopDiscount = totalShopDiscount.add(shopDiscount);
        }

        order.setSubOrders(subOrders);
        order.setTotalGoodsAmount(totalGoods);
        order.setTotalShippingFee(totalShipping);

        BigDecimal discount = BigDecimal.ZERO;
        Integer couponId = null;
        if (couponCode != null && !couponCode.trim().isEmpty()) {
            Coupon coupon = couponDAO.findByCode(couponCode.trim());
            validatePlatformCoupon(coupon, totalGoods);
            couponId = coupon.getCouponId();
            discount = calculateCouponDiscount(coupon, totalGoods);
        }

        order.setCouponId(couponId);
        order.setPlatformDiscount(discount);
        order.setFinalAmount(totalGoods.subtract(totalShopDiscount).add(totalShipping).subtract(discount).max(BigDecimal.ZERO));
        return order;
    }

    private BigDecimal calculateShippingFee(String shopProvince, String customerProvince) {
        if (customerProvince == null || customerProvince.isBlank()) {
            return BigDecimal.ZERO;
        }
        String normalizedShopProvince = normalizeProvince(shopProvince);
        String normalizedCustomerProvince = normalizeProvince(customerProvince);
        if (!normalizedShopProvince.isEmpty()
                && normalizedShopProvince.equals(normalizedCustomerProvince)) {
            return SAME_PROVINCE_SHIPPING_FEE;
        }
        return DIFFERENT_PROVINCE_SHIPPING_FEE;
    }

    private String normalizeProvince(String value) {
        if (value == null) {
            return "";
        }
        String normalized = DIACRITICS.matcher(
                Normalizer.normalize(value, Normalizer.Form.NFD)).replaceAll("")
                .toLowerCase(Locale.ROOT)
                .replace('đ', 'd')
                .replaceAll("\\b(thanh pho|tinh|tp)\\.?\\s*", "")
                .replaceAll("[^a-z0-9]", "");
        return normalized;
    }

    private void validateShopCoupon(Coupon coupon, long shopId, BigDecimal eligibleAmount) {
        if (coupon == null) {
            throw new IllegalArgumentException("Mã giảm giá của shop không tồn tại!");
        }
        if (coupon.getShopId() == null || coupon.getShopId() != shopId) {
            throw new IllegalArgumentException("Mã giảm giá '" + coupon.getCode() + "' không thuộc cửa hàng này!");
        }
        validateCoupon(coupon, eligibleAmount);
    }

    private void validatePlatformCoupon(Coupon coupon, BigDecimal eligibleAmount) {
        if (coupon == null) {
            throw new IllegalArgumentException("Mã giảm giá không tồn tại!");
        }
        if (coupon.getShopId() != null) {
            throw new IllegalArgumentException("Mã giảm giá '" + coupon.getCode() + "' là voucher của cửa hàng, không thể áp dụng cho toàn sàn!");
        }
        validateCoupon(coupon, eligibleAmount);
    }

    private void validateCoupon(Coupon coupon, BigDecimal eligibleAmount) {
        if (coupon == null) {
            throw new IllegalArgumentException("Mã giảm giá không tồn tại!");
        }
        if (!coupon.isActive()) {
            throw new IllegalArgumentException("Mã giảm giá hiện không hoạt động!");
        }

        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (coupon.getStartDate() == null || now.before(coupon.getStartDate())) {
            throw new IllegalArgumentException("Mã giảm giá chưa đến thời gian sử dụng!");
        }
        if (coupon.getEndDate() == null || now.after(coupon.getEndDate())) {
            throw new IllegalArgumentException("Mã giảm giá đã hết hạn!");
        }
        if (coupon.getUsedCount() >= coupon.getUsageLimit()) {
            throw new IllegalArgumentException("Mã giảm giá đã hết lượt sử dụng!");
        }

        BigDecimal minimum = coupon.getMinOrderValue() != null
                ? coupon.getMinOrderValue() : BigDecimal.ZERO;
        if (eligibleAmount.compareTo(minimum) < 0) {
            throw new IllegalArgumentException("Đơn hàng cần đạt tối thiểu "
                    + minimum.setScale(0, RoundingMode.HALF_UP).toPlainString()
                    + "đ để sử dụng mã " + coupon.getCode() + "!");
        }
    }

    private BigDecimal calculateCouponDiscount(Coupon coupon, BigDecimal eligibleAmount) {
        BigDecimal discount;
        String type = coupon.getDiscountType() == null
                ? "" : coupon.getDiscountType().trim().toUpperCase(Locale.ROOT);

        if ("PERCENTAGE".equals(type)) {
            discount = eligibleAmount.multiply(coupon.getDiscountValue())
                    .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        } else if ("FIXED_AMOUNT".equals(type)) {
            discount = coupon.getDiscountValue();
        } else {
            throw new IllegalArgumentException("Loại mã giảm giá không hợp lệ!");
        }

        if (coupon.getMaxDiscountAmount() != null
                && discount.compareTo(coupon.getMaxDiscountAmount()) > 0) {
            discount = coupon.getMaxDiscountAmount();
        }
        return discount.min(eligibleAmount).max(BigDecimal.ZERO)
                .setScale(2, RoundingMode.HALF_UP);
    }

    @Override
    public long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            boolean saveAddress) throws Exception {
        return placeOrder(customerId, cartItemIds, address, deliverySlot, paymentMethod, couponCode, Collections.emptyMap(), saveAddress);
    }

    @Override
    public long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes,
            boolean saveAddress) throws Exception {
        return placeOrder(customerId, cartItemIds, address, deliverySlot, paymentMethod, couponCode, shopCouponCodes, Collections.emptyMap(), saveAddress);
    }

    @Override
    public long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes,
            boolean saveAddress) throws Exception {
        return placeOrder(customerId, cartItemIds, address, null, deliverySlot, paymentMethod, couponCode, shopCouponCodes, shopNotes, saveAddress);
    }

    @Override
    public long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliveryDate, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes,
            boolean saveAddress) throws Exception {
        List<CartItem> selectedItems = getSelectedItemsForCheckout(customerId, cartItemIds);
        OrderDetailDTO order = prepareOrder(customerId, selectedItems, address, deliveryDate, deliverySlot,
                paymentMethod, couponCode, shopCouponCodes, shopNotes);
        return orderDAO.createOrder(order, address, cartItemIds,
                order.getPaymentMethod(), saveAddress);
    }

    @Override
    public long placeBuyNowOrder(long customerId, long variantId, int quantity,
            ShippingAddress address, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, boolean saveAddress) throws Exception {
        return placeBuyNowOrder(customerId, variantId, quantity, address, null, deliverySlot, paymentMethod, couponCode, shopCouponCodes, Collections.emptyMap(), saveAddress);
    }

    @Override
    public long placeBuyNowOrder(long customerId, long variantId, int quantity,
            ShippingAddress address, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes,
            boolean saveAddress) throws Exception {
        return placeBuyNowOrder(customerId, variantId, quantity, address, null, deliverySlot, paymentMethod, couponCode, shopCouponCodes, shopNotes, saveAddress);
    }

    @Override
    public long placeBuyNowOrder(long customerId, long variantId, int quantity,
            ShippingAddress address, String deliveryDate, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes,
            boolean saveAddress) throws Exception {
        CartItem item = getBuyNowItemForCheckout(variantId, quantity);
        OrderDetailDTO order = prepareOrder(customerId, List.of(item), address, deliveryDate, deliverySlot,
                paymentMethod, couponCode, shopCouponCodes, shopNotes);
        return orderDAO.createBuyNowOrder(order, address, order.getPaymentMethod(), saveAddress);
    }

    private OrderDetailDTO prepareOrder(long customerId, List<CartItem> selectedItems, ShippingAddress address,
            String deliveryDateStr, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes) {
        if (address == null || address.getRecipientName() == null
                || address.getRecipientName().trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập họ tên người nhận!");
        }
        if (address.getRecipientPhone() == null || address.getRecipientPhone().trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập số điện thoại người nhận!");
        }
        String normalizedPhone = address.getRecipientPhone().trim();
        if (!normalizedPhone.matches("^(0|\\+84)[0-9]{9,10}$")) {
            throw new IllegalArgumentException("Số điện thoại người nhận không hợp lệ!");
        }
        if (address.getStreetAddress() == null || address.getStreetAddress().trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập địa chỉ giao hàng cụ thể!");
        }
        if (address.getWard() == null || address.getWard().trim().isEmpty()
                || address.getCity() == null || address.getCity().trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Vui lòng nhập đầy đủ phường/xã và tỉnh/thành phố!");
        }

        PaymentMethod selectedPayment = PaymentMethod.from(paymentMethod);
        if (selectedPayment != PaymentMethod.COD && selectedPayment != PaymentMethod.CARD
                && selectedPayment != PaymentMethod.VNPAY) {
            throw new IllegalArgumentException(
                    "Phương thức thanh toán không hợp lệ!");
        }

        address.setRecipientName(address.getRecipientName().trim());
        address.setRecipientPhone(normalizedPhone);
        address.setStreetAddress(address.getStreetAddress().trim());
        address.setWard(address.getWard().trim());
        address.setDistrict(address.getDistrict() != null ? address.getDistrict().trim() : "");
        address.setCity(address.getCity().trim());

        OrderDetailDTO order = buildDraftOrder(customerId, selectedItems, couponCode,
                shopCouponCodes, address.getCity());

        // Chuẩn hóa ngày giao
        LocalDate selectedDate;
        try {
            if (deliveryDateStr != null && !deliveryDateStr.trim().isEmpty()) {
                selectedDate = LocalDate.parse(deliveryDateStr.trim());
            } else {
                selectedDate = LocalDate.now();
            }
        } catch (Exception ex) {
            selectedDate = LocalDate.now();
        }
        String formattedDate = selectedDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));

        // Chuẩn hóa khung giờ giao hàng
        String slotText = "08:00 - 10:00";
        if (deliverySlot != null && !deliverySlot.trim().isEmpty()) {
            String trimmed = deliverySlot.trim();
            if ("MORNING".equalsIgnoreCase(trimmed) || "M1".equalsIgnoreCase(trimmed)) {
                slotText = "08:00 - 10:00";
            } else if ("M2".equalsIgnoreCase(trimmed)) {
                slotText = "10:00 - 12:00";
            } else if ("AFTERNOON".equalsIgnoreCase(trimmed) || "A1".equalsIgnoreCase(trimmed)) {
                slotText = "13:00 - 15:00";
            } else if ("A2".equalsIgnoreCase(trimmed)) {
                slotText = "15:00 - 17:00";
            } else if ("EVENING".equalsIgnoreCase(trimmed) || "E1".equalsIgnoreCase(trimmed)) {
                slotText = "17:00 - 19:00";
            } else if ("E2".equalsIgnoreCase(trimmed)) {
                slotText = "19:00 - 21:00";
            } else {
                slotText = trimmed;
            }
        }

        String slotLabel = slotText + " (" + formattedDate + ")";

        for (SubOrderDTO sub : order.getSubOrders()) {
            String note = shopNotes != null ? shopNotes.get(sub.getShopId()) : null;
            if (note != null && !note.trim().isEmpty()) {
                sub.setDeliverySlot(slotLabel + " • Lời nhắn: " + note.trim());
            } else {
                sub.setDeliverySlot(slotLabel);
            }
        }
        order.setPaymentStatus(PaymentStatus.PENDING);
        order.setPaymentMethod(selectedPayment);

        return order;
    }

    @Override
    public OrderDetailDTO getOrderDetails(long orderId) {
        return orderDAO.getOrderById(orderId);
    }

    @Override
    public CustomerAddress getDefaultCustomerAddress(long customerId) {
        return orderDAO.getDefaultAddress(customerId);
    }

    @Override
    public List<CustomerAddress> getCustomerAddresses(long customerId) {
        return orderDAO.getCustomerAddresses(customerId);
    }

    @Override
    public CustomerAddress getCustomerAddress(long customerId, long addressId) {
        return orderDAO.getCustomerAddressById(customerId, addressId);
    }

    @Override
    public List<Coupon> getAvailableCoupons(BigDecimal orderAmount) {
        return couponDAO.findAvailableForAmount(orderAmount);
    }

    @Override
    public List<Coupon> getAvailableShopCoupons(long shopId) {
        return couponDAO.findAvailableForShop(shopId);
    }

    @Override
    public List<SubOrderDTO> getSubOrdersByCustomerId(long customerId) {
        return orderDAO.getSubOrdersByCustomerId(customerId);
    }

    @Override
    public boolean cancelOrderByCustomer(long customerId, String orderIdentifier, String cancelReason) throws Exception {
        return orderDAO.cancelOrderByCustomer(customerId, orderIdentifier, cancelReason);
    }
}
