package service;

import java.util.List;
import model.CartItem;
import model.CustomerAddress;
import model.Coupon;
import model.Order;
import model.ShippingAddress;

public interface IOrderService {

    List<CartItem> getSelectedItemsForCheckout(long customerId, List<Long> cartItemIds) throws Exception;

    Order buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode);

    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            boolean saveAddress) throws Exception;

    Order getOrderDetails(long orderId);

    CustomerAddress getDefaultCustomerAddress(long customerId);

    List<CustomerAddress> getCustomerAddresses(long customerId);

    CustomerAddress getCustomerAddress(long customerId, long addressId);

    List<Coupon> getAvailableCoupons(java.math.BigDecimal orderAmount);
}
