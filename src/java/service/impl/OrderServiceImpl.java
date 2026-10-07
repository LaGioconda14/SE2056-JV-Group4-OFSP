package service.impl;

import dao.CouponDAO;
import dao.OrderDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.util.ArrayList;
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
    private static final BigDecimal DEFAULT_SHIPPING_FEE_PER_SHOP = new BigDecimal("25000");
    private static final BigDecimal FREE_SHIPPING_THRESHOLD = new BigDecimal("200000");

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
    public List<CartItem> getSelectedItemsForCheckout(long customerId, List<Long> cartItemIds) throws Exception {
        if (cartItemIds == null || cartItemIds.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất một sản phẩm để thanh toán!");
        }

        Set<Long> uniqueIds = new LinkedHashSet<>(cartItemIds);
        if (uniqueIds.contains(null)) {
            throw new IllegalArgumentException("Danh sách sản phẩm thanh toán không hợp lệ!");
        }

        List<CartItem> items = orderDAO.getSelectedCartItems(customerId, new ArrayList<>(uniqueIds));
        if (items.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy sản phẩm hợp lệ nào trong giỏ hàng!");
        }
        if (items.size() != uniqueIds.size()) {
            throw new IllegalArgumentException("Có sản phẩm không thuộc giỏ hàng của bạn hoặc đã bị xóa!");
        }

        // Kiểm tra tồn kho & trạng thái hoạt động của từng sản phẩm
        for (CartItem item : items) {
            if (item.getVariant() == null || !item.getVariant().isActive()
                    || item.getVariant().getProduct() == null
                    || !item.getVariant().getProduct().isActive()) {
                throw new IllegalStateException("Sản phẩm '" + (item.getVariant() != null ? item.getVariant().getVariantName() : "")
                        + "' hiện không còn khả dụng!");
            }
            if (!"ACTIVE".equalsIgnoreCase(item.getVariant().getProduct().getShopStatus())) {
                throw new IllegalStateException("Cửa hàng của sản phẩm '"
                        + item.getVariant().getProduct().getName() + "' hiện không hoạt động!");
            }
            if (item.getQuantity() <= 0) {
                throw new IllegalStateException("Số lượng sản phẩm thanh toán phải lớn hơn 0!");
            }
            if (item.getQuantity() > item.getVariant().getStockQuantity()) {
                throw new IllegalStateException("Sản phẩm '" + item.getVariant().getProduct().getName()
                        + " - " + item.getVariant().getVariantName()
                        + "' chỉ còn " + item.getVariant().getStockQuantity() + " sản phẩm trong kho!");
            }
        }

        return items;
    }

    @Override
    public Order buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode) {
        Order order = new Order();
        order.setCustomerId(customerId);

        // Nhóm các món hàng theo từng Shop (Mỗi Shop tạo thành 1 SubOrder)
        Map<Long, List<CartItem>> itemsByShop = new HashMap<>();
        Map<Long, String> shopNames = new HashMap<>();

        for (CartItem ci : selectedItems) {
            long shopId = ci.getVariant().getProduct().getShopId();
            itemsByShop.computeIfAbsent(shopId, k -> new ArrayList<>()).add(ci);
            if (ci.getVariant().getProduct().getShopName() != null) {
                shopNames.put(shopId, ci.getVariant().getProduct().getShopName());
            }
        }

        BigDecimal totalGoods = BigDecimal.ZERO;
        BigDecimal totalShipping = BigDecimal.ZERO;
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

            for (CartItem ci : shopItems) {
                OrderItem oi = new OrderItem();
                oi.setVariantId(ci.getVariant().getVariantId());
                oi.setProductNameSnapshot(ci.getVariant().getProduct().getName());
                oi.setVariantNameSnapshot(ci.getVariant().getVariantName());
                oi.setSkuSnapshot(ci.getVariant().getSku());
                oi.setUnit(ci.getVariant().getUnit() != null ? ci.getVariant().getUnit() : "phần");
                oi.setUnitPrice(ci.getVariant().getPrice());
                oi.setQuantity(ci.getQuantity());
                oi.setTotalPrice(ci.getSubtotal());

                orderItems.add(oi);
                shopSubtotal = shopSubtotal.add(ci.getSubtotal());
            }

            sub.setItems(orderItems);
            sub.setShopSubtotal(shopSubtotal);

            // Phí ship từng shop: Miễn phí nếu đơn hàng của shop >= 200.000đ
            BigDecimal shopShip = (shopSubtotal.compareTo(FREE_SHIPPING_THRESHOLD) >= 0)
                    ? BigDecimal.ZERO : DEFAULT_SHIPPING_FEE_PER_SHOP;
            sub.setShopShippingFee(shopShip);
            sub.setShopDiscount(BigDecimal.ZERO);
            sub.setShopTotal(shopSubtotal.add(shopShip));

            subOrders.add(sub);
            totalGoods = totalGoods.add(shopSubtotal);
            totalShipping = totalShipping.add(shopShip);
        }

        order.setSubOrders(subOrders);
        order.setTotalGoodsAmount(totalGoods);
        order.setTotalShippingFee(totalShipping);

        // Áp dụng voucher toàn sàn từ database
        BigDecimal discount = BigDecimal.ZERO;
        Integer couponId = null;
        if (couponCode != null && !couponCode.trim().isEmpty()) {
            Coupon coupon = couponDAO.findByCode(couponCode);
            validateCoupon(coupon, totalGoods);
            couponId = coupon.getCouponId();
            discount = calculateCouponDiscount(coupon, totalGoods);
        }

        order.setCouponId(couponId);
        order.setPlatformDiscount(discount);
        BigDecimal finalAmount = totalGoods.add(totalShipping).subtract(discount).max(BigDecimal.ZERO);
        order.setFinalAmount(finalAmount);

        return order;
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

        if (address.getRecipientName() == null || address.getRecipientName().trim().isEmpty()) {
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
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ phường/xã, quận/huyện và tỉnh/thành phố!");
        }

        String normalizedSlot = deliverySlot == null ? "" : deliverySlot.trim().toUpperCase(Locale.ROOT);
        if (!("MORNING".equals(normalizedSlot)
                || "AFTERNOON".equals(normalizedSlot)
                || "EVENING".equals(normalizedSlot))) {
            throw new IllegalArgumentException("Khung giờ giao hàng không hợp lệ!");
        }

        String normalizedPayment = paymentMethod == null
                ? "" : paymentMethod.trim().toUpperCase(Locale.ROOT);
        if (!"COD".equals(normalizedPayment)) {
            throw new IllegalArgumentException("Hiện tại hệ thống chỉ hỗ trợ thanh toán khi nhận hàng (COD)!");
        }

        address.setRecipientName(address.getRecipientName().trim());
        address.setRecipientPhone(normalizedPhone);
        address.setStreetAddress(address.getStreetAddress().trim());
        address.setWard(address.getWard().trim());
        address.setDistrict(address.getDistrict().trim());
        address.setCity(address.getCity().trim());

        // Lấy lại các item và xác minh tồn kho
        List<CartItem> selectedItems = getSelectedItemsForCheckout(customerId, cartItemIds);
        Order order = buildDraftOrder(customerId, selectedItems, couponCode);

        // Gán deliverySlot cho các sub_orders
        for (SubOrder sub : order.getSubOrders()) {
            sub.setDeliverySlot(normalizedSlot);
        }

        // Thiết lập trạng thái thanh toán
        order.setPaymentStatus("PENDING");

        // Gọi DAO lưu vào DB trong 1 Transaction nguyên tử
        return orderDAO.createOrder(order, address, cartItemIds, normalizedPayment, saveAddress);
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
}
