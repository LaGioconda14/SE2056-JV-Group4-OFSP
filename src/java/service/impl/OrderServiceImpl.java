package service.impl;

import dao.CouponDAO;
import dao.OrderDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import model.CartItem;
import model.Coupon;
import model.CustomerAddress;
import model.Order;
import model.OrderItem;
import model.ShippingAddress;
import model.SubOrder;
import service.IOrderService;

public class OrderServiceImpl implements IOrderService {

    private final OrderDAO orderDAO;
    private final CouponDAO couponDAO;

    public OrderServiceImpl() {
        this.orderDAO = new OrderDAO();
        this.couponDAO = new CouponDAO();
    }

    public OrderServiceImpl(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
        this.couponDAO = new CouponDAO();
    }

    public OrderServiceImpl(OrderDAO orderDAO, CouponDAO couponDAO) {
        this.orderDAO = orderDAO;
        this.couponDAO = couponDAO;
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

        for (CartItem item : selected) {
            if (item.getVariant() == null || !item.getVariant().isActive()
                    || item.getVariant().getProduct() == null
                    || !item.getVariant().getProduct().isActive()) {
                throw new IllegalStateException("Sản phẩm '"
                        + (item.getVariant() != null ? item.getVariant().getVariantName() : "")
                        + "' hiện không còn khả dụng!");
            }
            if (!"ACTIVE".equalsIgnoreCase(item.getVariant().getProduct().getShopStatus())) {
                throw new IllegalStateException("Cửa hàng của sản phẩm '"
                        + item.getVariant().getProduct().getName() + "' hiện không hoạt động!");
            }
            if (item.getQuantity() <= 0) {
                throw new IllegalStateException("Số lượng sản phẩm thanh toán phải lớn hơn 0!");
            }
            if (item.getVariant().getStockQuantity() < item.getQuantity()) {
                throw new IllegalStateException("Sản phẩm '" + item.getVariant().getProduct().getName() + " - "
                        + item.getVariant().getVariantName() + "' chỉ còn "
                        + item.getVariant().getStockQuantity() + " sản phẩm trong kho!");
            }
        }

        return selected;
    }

    @Override
    public Order buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode) {
        return buildDraftOrder(customerId, selectedItems, couponCode, Collections.emptyMap());
    }

    @Override
    public Order buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode,
            Map<Long, String> shopCouponCodes) {
        Order order = new Order();
        order.setCustomerId(customerId);

        Map<Long, List<CartItem>> itemsByShop = new HashMap<>();
        Map<Long, String> shopNames = new HashMap<>();

        for (CartItem cartItem : selectedItems) {
            long shopId = cartItem.getVariant().getProduct().getShopId();
            itemsByShop.computeIfAbsent(shopId, key -> new ArrayList<>()).add(cartItem);
            if (cartItem.getVariant().getProduct().getShopName() != null) {
                shopNames.put(shopId, cartItem.getVariant().getProduct().getShopName());
            }
        }

        BigDecimal totalGoods = BigDecimal.ZERO;
        BigDecimal totalShipping = BigDecimal.ZERO;
        BigDecimal totalShopDiscount = BigDecimal.ZERO;
        List<SubOrder> subOrders = new ArrayList<>();

        for (Map.Entry<Long, List<CartItem>> entry : itemsByShop.entrySet()) {
            long shopId = entry.getKey();
            List<CartItem> shopItems = entry.getValue();

            SubOrder sub = new SubOrder();
            sub.setShopId(shopId);
            sub.setShopName(shopNames.getOrDefault(shopId, "Cửa hàng"));
            sub.setStatus("NEW");

            BigDecimal shopSubtotal = BigDecimal.ZERO;
            List<OrderItem> orderItems = new ArrayList<>();

            for (CartItem cartItem : shopItems) {
                OrderItem orderItem = new OrderItem();
                orderItem.setVariantId(cartItem.getVariant().getVariantId());
                orderItem.setProductNameSnapshot(cartItem.getVariant().getProduct().getName());
                orderItem.setVariantNameSnapshot(cartItem.getVariant().getVariantName());
                orderItem.setSkuSnapshot(cartItem.getVariant().getSku());
                orderItem.setUnit(cartItem.getVariant().getUnit() != null
                        ? cartItem.getVariant().getUnit() : "phần");
                orderItem.setUnitPrice(cartItem.getVariant().getPrice());
                orderItem.setQuantity(cartItem.getQuantity());
                orderItem.setTotalPrice(cartItem.getSubtotal());

                orderItems.add(orderItem);
                shopSubtotal = shopSubtotal.add(cartItem.getSubtotal());
            }

            sub.setItems(orderItems);
            sub.setShopSubtotal(shopSubtotal);

            BigDecimal shopShippingFee = BigDecimal.ZERO;
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
                || address.getDistrict() == null || address.getDistrict().trim().isEmpty()
                || address.getCity() == null || address.getCity().trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Vui lòng nhập đầy đủ phường/xã, quận/huyện và tỉnh/thành phố!");
        }

        String normalizedSlot = deliverySlot == null ? ""
                : deliverySlot.trim().toUpperCase(Locale.ROOT);
        if (!("MORNING".equals(normalizedSlot)
                || "AFTERNOON".equals(normalizedSlot)
                || "EVENING".equals(normalizedSlot))) {
            throw new IllegalArgumentException("Khung giờ giao hàng không hợp lệ!");
        }

        String normalizedPayment = paymentMethod == null ? ""
                : paymentMethod.trim().toUpperCase(Locale.ROOT);
        if (!"COD".equals(normalizedPayment)) {
            throw new IllegalArgumentException(
                    "Hiện tại hệ thống chỉ hỗ trợ thanh toán khi nhận hàng (COD)!");
        }

        address.setRecipientName(address.getRecipientName().trim());
        address.setRecipientPhone(normalizedPhone);
        address.setStreetAddress(address.getStreetAddress().trim());
        address.setWard(address.getWard().trim());
        address.setDistrict(address.getDistrict().trim());
        address.setCity(address.getCity().trim());

        List<CartItem> selectedItems = getSelectedItemsForCheckout(customerId, cartItemIds);
        Order order = buildDraftOrder(customerId, selectedItems, couponCode, shopCouponCodes);
        for (SubOrder sub : order.getSubOrders()) {
            sub.setDeliverySlot(normalizedSlot);
        }
        order.setPaymentStatus("PENDING");

        return orderDAO.createOrder(order, address, cartItemIds,
                normalizedPayment, saveAddress);
    }

    @Override
    public Order getOrderDetails(long orderId) {
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
    public List<Order> getOrdersByCustomerId(long customerId) {
        return orderDAO.getOrdersByCustomerId(customerId);
    }

    @Override
    public List<SubOrder> getSubOrdersByCustomerId(long customerId) {
        return orderDAO.getSubOrdersByCustomerId(customerId);
    }

    @Override
    public boolean cancelOrderByCustomer(long customerId, String orderIdentifier, String cancelReason) throws Exception {
        return orderDAO.cancelOrderByCustomer(customerId, orderIdentifier, cancelReason);
    }
}
