package service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.entity.cart.CartItem;
import model.entity.promotion.Coupon;
import model.entity.user.CustomerAddress;
import model.dto.order.OrderDetailDTO;
import model.dto.order.SubOrderDTO;
import model.entity.order.ShippingAddress;

public interface IOrderService {

    List<CartItem> getSelectedItemsForCheckout(long customerId, List<Long> cartItemIds);

    CartItem getBuyNowItemForCheckout(long variantId, int quantity);

    OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode);

    OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode,
            Map<Long, String> shopCouponCodes);

    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            boolean saveAddress) throws Exception;

    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, boolean saveAddress) throws Exception;

    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliveryDate, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    long placeBuyNowOrder(long customerId, long variantId, int quantity, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, boolean saveAddress) throws Exception;

    long placeBuyNowOrder(long customerId, long variantId, int quantity, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    long placeBuyNowOrder(long customerId, long variantId, int quantity, ShippingAddress address,
            String deliveryDate, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    OrderDetailDTO getOrderDetails(long orderId);

    CustomerAddress getDefaultCustomerAddress(long customerId);

    List<CustomerAddress> getCustomerAddresses(long customerId);

    CustomerAddress getCustomerAddress(long customerId, long addressId);

    List<Coupon> getAvailableCoupons(BigDecimal orderAmount);

    List<Coupon> getAvailableShopCoupons(long shopId);

    List<SubOrderDTO> getSubOrdersByCustomerId(long customerId);

    boolean cancelOrderByCustomer(long customerId, String orderIdentifier, String cancelReason) throws Exception;
}