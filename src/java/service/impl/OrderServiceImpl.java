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

        List<CartItem> selected = orderDAO.getSelectedCartItems(customerId, new ArrayList<>(uniqueIds));
        if (selected == null || selected.isEmpty()) {
            throw new IllegalStateException("Không tìm thấy sản phẩm hợp lệ nào trong giỏ hàng để đặt hàng!");
        }

        for (CartItem item : selected) {
            if (item.getVariant() == null) {
                throw new IllegalStateException("Một số sản phẩm không tồn tại hoặc đã ngừng kinh doanh!");
            }
            if (item.getVariant().getStockQuantity() < item.getQuantity()) {
                throw new IllegalStateException("Sản phẩm '" + item.getVariant().getProductName() + " - "
                        + item.getVariant().getVariantName() + "' chỉ còn "
                        + item.getVariant().getStockQuantity() + " sản phẩm trong kho!");
            }
        }

        return selected;
    }

    @Override
    public Order buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode) {
        Order order = new Order();
        order.setCustomerId(customerId);
        order.setPaymentStatus("PENDING");

        Map<Long, List<CartItem>> itemsByShop = new HashMap<>();
        BigDecimal totalGoods = BigDecimal.ZERO;

        for (CartItem item : selectedItems) {
            long shopId = item.getVariant().getProduct() != null ? item.getVariant().getProduct().getShopId() : 1L;
            itemsByShop.computeIfAbsent(shopId, k -> new ArrayList<>()).add(item);
            BigDecimal itemTotal = item.getVariant().getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            totalGoods = totalGoods.add(itemTotal);
        }

        order.setTotalGoodsAmount(totalGoods);

        BigDecimal shippingPerShop = new BigDecimal("15000");
        BigDecimal totalShipping = shippingPerShop.multiply(BigDecimal.valueOf(itemsByShop.size()));
        order.setTotalShippingFee(totalShipping);

        BigDecimal discount = BigDecimal.ZERO;
        if (couponCode != null && !couponCode.trim().isEmpty()) {
            Coupon coupon = couponDAO.findByCode(couponCode.trim());
            if (coupon != null && coupon.isValid() && totalGoods.compareTo(coupon.getMinOrderAmount()) >= 0) {
                order.setCouponId(coupon.getCouponId());
                if ("PERCENT".equalsIgnoreCase(coupon.getDiscountType())) {
                    discount = totalGoods.multiply(coupon.getDiscountValue())
                            .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
                    if (coupon.getMaxDiscountAmount() != null && discount.compareTo(coupon.getMaxDiscountAmount()) > 0) {
                        discount = coupon.getMaxDiscountAmount();
                    }
                } else {
                    discount = coupon.getDiscountValue();
                }
                if (discount.compareTo(totalGoods) > 0) {
                    discount = totalGoods;
                }
            }
        }
        order.setPlatformDiscount(discount);

        BigDecimal finalAmount = totalGoods.add(totalShipping).subtract(discount);
        if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
            finalAmount = BigDecimal.ZERO;
        }
        order.setFinalAmount(finalAmount);

        List<SubOrder> subOrders = new ArrayList<>();
        BigDecimal remainingDiscount = discount;
        int remainingShops = itemsByShop.size();

        for (Map.Entry<Long, List<CartItem>> entry : itemsByShop.entrySet()) {
            long shopId = entry.getKey();
            List<CartItem> shopItems = entry.getValue();

            SubOrder sub = new SubOrder();
            sub.setShopId(shopId);
            sub.setStatus("PENDING");

            BigDecimal shopGoods = BigDecimal.ZERO;
            List<OrderItem> orderItems = new ArrayList<>();

            for (CartItem ci : shopItems) {
                OrderItem oi = new OrderItem();
                oi.setVariantId(ci.getVariant().getVariantId());
                oi.setProductNameSnapshot(ci.getVariant().getProductName());
                oi.setVariantNameSnapshot(ci.getVariant().getVariantName());
                oi.setSkuSnapshot(ci.getVariant().getSku());
                oi.setUnit(ci.getVariant().getUnit());
                oi.setUnitPrice(ci.getVariant().getPrice());
                oi.setQuantity(ci.getQuantity());

                BigDecimal lineTotal = ci.getVariant().getPrice().multiply(BigDecimal.valueOf(ci.getQuantity()));
                oi.setTotalPrice(lineTotal);

                orderItems.add(oi);
                shopGoods = shopGoods.add(lineTotal);
            }

            sub.setItems(orderItems);
            sub.setGoodsAmount(shopGoods);
            sub.setShippingFee(shippingPerShop);

            BigDecimal shopDiscount = BigDecimal.ZERO;
            if (discount.compareTo(BigDecimal.ZERO) > 0 && totalGoods.compareTo(BigDecimal.ZERO) > 0) {
                if (remainingShops == 1) {
                    shopDiscount = remainingDiscount;
                } else {
                    shopDiscount = discount.multiply(shopGoods)
                            .divide(totalGoods, 2, RoundingMode.HALF_UP);
                    if (shopDiscount.compareTo(remainingDiscount) > 0) {
                        shopDiscount = remainingDiscount;
                    }
                    remainingDiscount = remainingDiscount.subtract(shopDiscount);
                }
            }
            remainingShops--;

            sub.setPlatformDiscountShare(shopDiscount);
            sub.setShopVoucherDiscount(BigDecimal.ZERO);

            BigDecimal subFinal = shopGoods.add(shippingPerShop).subtract(shopDiscount);
            if (subFinal.compareTo(BigDecimal.ZERO) < 0) {
                subFinal = BigDecimal.ZERO;
            }
            sub.setFinalAmount(subFinal);

            subOrders.add(sub);
        }

        order.setSubOrders(subOrders);
        return order;
    }

    @Override
    public long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            boolean saveAddress) throws Exception {

        if (address == null) {
            throw new IllegalArgumentException("Vui lòng cung cấp địa chỉ giao hàng hợp lệ!");
        }

        List<CartItem> selectedItems = getSelectedItemsForCheckout(customerId, cartItemIds);
        Order draft = buildDraftOrder(customerId, selectedItems, couponCode);

        draft.setShippingAddress(address);
        draft.setPaymentStatus("PENDING");

        String slot = (deliverySlot == null || deliverySlot.trim().isEmpty())
                ? "Hỏa tốc trong ngày (2h - 4h)" : deliverySlot.trim();
        for (SubOrder sub : draft.getSubOrders()) {
            sub.setDeliverySlot(slot);
        }

        long orderId = orderDAO.createOrderWithSubOrders(draft, cartItemIds);

        if (saveAddress && address != null) {
            CustomerAddress ca = new CustomerAddress();
            ca.setUserId(customerId);
            ca.setRecipientName(address.getRecipientName());
            ca.setRecipientPhone(address.getRecipientPhone());
            ca.setStreetAddress(address.getStreetAddress());
            ca.setWard(address.getWard());
            ca.setDistrict(address.getDistrict());
            ca.setCity(address.getCity());
            ca.setDefaultAddress(true);
            try {
                orderDAO.saveCustomerAddress(ca);
            } catch (Exception e) {
                // Ignore address save error
            }
        }

        return orderId;
    }

    @Override
    public Order getOrderDetails(long orderId) {
        return orderDAO.getOrderById(orderId);
    }

    @Override
    public CustomerAddress getDefaultCustomerAddress(long customerId) {
        return orderDAO.getDefaultCustomerAddress(customerId);
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
    public List<Order> getOrdersByCustomerId(long customerId) {
        return orderDAO.getOrdersByCustomerId(customerId);
    }
}
