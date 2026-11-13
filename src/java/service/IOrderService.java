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

/**
 * Interface định nghĩa các nghiệp vụ đặt hàng và quản lý đơn hàng của khách hàng:
 * - Lấy và thẩm định sản phẩm thanh toán (từ giỏ hàng hoặc Mua ngay).
 * - Tính toán đơn hàng tạm tính (draft order): tiền hàng, phí ship, voucher sàn và voucher shop.
 * - Đặt đơn hàng (thường từ giỏ hoặc Mua ngay).
 * - Xem chi tiết đơn hàng, danh sách đơn hàng con (sub-orders), hủy đơn hàng.
 * - Quản lý địa chỉ giao hàng và danh sách mã giảm giá khả dụng.
 */
public interface IOrderService {

    /**
     * Lấy danh sách sản phẩm được chọn từ giỏ hàng để chuẩn bị checkout.
     * Áp dụng khuyến mãi hiện hành và xác thực tính khả dụng của từng sản phẩm.
     *
     * @param customerId  ID của khách hàng
     * @param cartItemIds danh sách ID các mục giỏ hàng được chọn
     * @return danh sách CartItem hợp lệ để checkout
     */
    List<CartItem> getSelectedItemsForCheckout(long customerId, List<Long> cartItemIds);

    /**
     * Lấy thông tin biến thể sản phẩm cho luồng "Mua ngay" (không thông qua giỏ hàng).
     *
     * @param variantId ID biến thể sản phẩm
     * @param quantity  số lượng mua
     * @return CartItem đại diện cho sản phẩm mua ngay
     */
    CartItem getBuyNowItemForCheckout(long variantId, int quantity);

    /**
     * Tạo đơn hàng tạm tính (Draft Order) để hiển thị chi phí tại trang Checkout.
     *
     * @param customerId    ID khách hàng
     * @param selectedItems danh sách sản phẩm được chọn
     * @param couponCode    mã giảm giá toàn sàn (nếu có)
     * @return OrderDetailDTO chứa thông tin chia theo từng shop và tổng thanh toán
     */
    OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode);

    /**
     * Tạo đơn hàng tạm tính kèm theo mã giảm giá riêng của từng shop.
     *
     * @param customerId       ID khách hàng
     * @param selectedItems    danh sách sản phẩm
     * @param couponCode       mã giảm giá toàn sàn
     * @param shopCouponCodes  map chứa [shopId -> mã voucher của shop]
     * @return OrderDetailDTO chứa thông tin chi tiết tiền hàng và giảm giá
     */
    OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode,
            Map<Long, String> shopCouponCodes);

    /**
     * Tạo đơn hàng tạm tính đầy đủ có tính toán phí vận chuyển dựa trên tỉnh/thành của khách và shop.
     *
     * @param customerId       ID khách hàng
     * @param selectedItems    danh sách sản phẩm
     * @param couponCode       mã giảm giá toàn sàn
     * @param shopCouponCodes  map [shopId -> mã voucher shop]
     * @param customerProvince tỉnh/thành phố nhận hàng của khách
     * @return OrderDetailDTO đầy đủ phí ship, voucher và tổng tiền cuối cùng
     */
    OrderDetailDTO buildDraftOrder(long customerId, List<CartItem> selectedItems, String couponCode,
            Map<Long, String> shopCouponCodes, String customerProvince);

    /**
     * Đặt hàng từ giỏ hàng (phiên bản cơ bản).
     */
    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            boolean saveAddress) throws Exception;

    /**
     * Đặt hàng từ giỏ hàng kèm voucher riêng của từng shop.
     */
    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, boolean saveAddress) throws Exception;

    /**
     * Đặt hàng từ giỏ hàng kèm voucher riêng và ghi chú lời nhắn riêng cho từng shop.
     */
    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    /**
     * Đặt hàng từ giỏ hàng đầy đủ: ngày giao hàng, khung giờ, ghi chú từng shop và phương thức thanh toán.
     *
     * @param customerId       ID khách hàng
     * @param cartItemIds      danh sách mục giỏ hàng được đặt
     * @param address          địa chỉ giao hàng
     * @param deliveryDate     ngày giao hàng mong muốn
     * @param deliverySlot     khung giờ giao hàng
     * @param paymentMethod    phương thức thanh toán (COD, CARD, VNPAY)
     * @param couponCode       mã giảm giá toàn sàn
     * @param shopCouponCodes  map [shopId -> mã voucher shop]
     * @param shopNotes        map [shopId -> lời nhắn cho shop]
     * @param saveAddress      cờ lưu địa chỉ này vào sổ địa chỉ khách hàng
     * @return orderId của đơn hàng cha vừa tạo
     * @throws Exception nếu xảy ra lỗi trong quá trình đặt hàng hoặc kiểm tra dữ liệu
     */
    long placeOrder(long customerId, List<Long> cartItemIds, ShippingAddress address,
            String deliveryDate, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    /**
     * Đặt đơn "Mua ngay" cho một sản phẩm duy nhất (không qua giỏ hàng).
     */
    long placeBuyNowOrder(long customerId, long variantId, int quantity, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, boolean saveAddress) throws Exception;

    /**
     * Đặt đơn "Mua ngay" kèm ghi chú lời nhắn cho shop.
     */
    long placeBuyNowOrder(long customerId, long variantId, int quantity, ShippingAddress address,
            String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    /**
     * Đặt đơn "Mua ngay" đầy đủ ngày giao, khung giờ, ghi chú và phương thức thanh toán.
     *
     * @param customerId       ID khách hàng
     * @param variantId        ID biến thể sản phẩm
     * @param quantity         số lượng mua
     * @param address          địa chỉ giao hàng
     * @param deliveryDate     ngày giao mong muốn
     * @param deliverySlot     khung giờ giao
     * @param paymentMethod    phương thức thanh toán
     * @param couponCode       mã voucher sàn
     * @param shopCouponCodes  map voucher shop
     * @param shopNotes        map lời nhắn shop
     * @param saveAddress      cờ lưu địa chỉ
     * @return orderId của đơn hàng vừa tạo
     * @throws Exception nếu xảy ra lỗi
     */
    long placeBuyNowOrder(long customerId, long variantId, int quantity, ShippingAddress address,
            String deliveryDate, String deliverySlot, String paymentMethod, String couponCode,
            Map<Long, String> shopCouponCodes, Map<Long, String> shopNotes, boolean saveAddress) throws Exception;

    /**
     * Lấy thông tin chi tiết một đơn hàng theo orderId (kèm các đơn con và sản phẩm).
     *
     * @param orderId ID đơn hàng cha
     * @return OrderDetailDTO chi tiết
     */
    OrderDetailDTO getOrderDetails(long orderId);

    /**
     * Lấy địa chỉ giao hàng mặc định của khách hàng.
     *
     * @param customerId ID khách hàng
     * @return CustomerAddress mặc định hoặc null nếu chưa có
     */
    CustomerAddress getDefaultCustomerAddress(long customerId);

    /**
     * Lấy danh sách tất cả địa chỉ đã lưu trong sổ địa chỉ của khách hàng.
     *
     * @param customerId ID khách hàng
     * @return danh sách địa chỉ đã lưu
     */
    List<CustomerAddress> getCustomerAddresses(long customerId);

    /**
     * Lấy thông tin một địa chỉ cụ thể của khách hàng theo addressId.
     *
     * @param customerId ID khách hàng
     * @param addressId  ID địa chỉ
     * @return CustomerAddress tương ứng
     */
    CustomerAddress getCustomerAddress(long customerId, long addressId);

    /**
     * Lấy danh sách các mã voucher toàn sàn đang khả dụng cho mức giá trị đơn hàng chỉ định.
     *
     * @param orderAmount tổng tiền hàng của đơn
     * @return danh sách Coupon sàn hợp lệ
     */
    List<Coupon> getAvailableCoupons(BigDecimal orderAmount);

    /**
     * Lấy danh sách các mã voucher đang phát hành và còn hiệu lực của một shop cụ thể.
     *
     * @param shopId ID của cửa hàng
     * @return danh sách Coupon của shop
     */
    List<Coupon> getAvailableShopCoupons(long shopId);

    /**
     * Lấy danh sách toàn bộ các đơn hàng con (sub-orders) của khách hàng để hiển thị trang lịch sử đơn.
     *
     * @param customerId ID khách hàng
     * @return danh sách SubOrderDTO
     */
    List<SubOrderDTO> getSubOrdersByCustomerId(long customerId);

    /**
     * Xử lý yêu cầu khách hàng hủy đơn hàng (hoàn lại tồn kho, hủy đơn con tương ứng).
     *
     * @param customerId      ID khách hàng thực hiện hủy
     * @param orderIdentifier mã đơn hàng (orderCode hoặc subOrderCode)
     * @param cancelReason    lý do hủy đơn
     * @return true nếu hủy thành công
     * @throws Exception nếu không thể hủy (ví dụ đơn đã chuyển sang trạng thái đang giao)
     */
    boolean cancelOrderByCustomer(long customerId, String orderIdentifier, String cancelReason) throws Exception;
}
