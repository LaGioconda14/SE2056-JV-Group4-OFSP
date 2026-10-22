package service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.CartItem;
import model.Coupon;
import model.CustomerAddress;
import model.Order;
import model.ShippingAddress;
import model.SubOrder;

public interface IOrderService {

    List<CartItem> getSelectedItemsForCheckout(long customerId, List<Long> cartItemIds);

    Order buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode);

    Order buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode,
            Map<Long, String> shopCouponCodes);

    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            boolean saveAddress) throws Exception;

    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, boolean saveAddress) throws Exception;

    Order getOrderDetails(long orderId);

    CustomerAddress getDefaultCustomerAddress(long customerId);

    List<CustomerAddress> getCustomerAddresses(long customerId);

    CustomerAddress getCustomerAddress(long customerId, long addressId);

    List<Coupon> getAvailableCoupons(BigDecimal orderAmount);

    List<Coupon> getAvailableShopCoupons(long shopId);

    List<Order> getOrdersByCustomerId(long customerId);

    List<SubOrder> getSubOrdersByCustomerId(long customerId);

    boolean cancelOrderByCustomer(long customerId, String orderIdentifier, String cancelReason) throws Exception;
}
