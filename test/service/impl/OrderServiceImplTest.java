package service.impl;

import dao.CouponDAO;
import dao.OrderDAO;
import dao.ShopDAO;
import model.dto.order.OrderDetailDTO;
import model.dto.order.SubOrderDTO;
import model.dto.product.ProductVariantDetailDTO;
import model.entity.cart.CartItem;
import model.entity.order.ShippingAddress;
import model.entity.promotion.Coupon;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Unit Tests for OrderServiceImpl (Checkout & Order Placement)")
class OrderServiceImplTest {

    @Mock
    private OrderDAO orderDAO;

    @Mock
    private CouponDAO couponDAO;

    @Mock
    private ShopDAO shopDAO;

    private OrderServiceImpl orderService;

    @BeforeEach
    void setUp() {
        orderService = new OrderServiceImpl(orderDAO, couponDAO, shopDAO);
    }

    private CartItem createMockCartItem(long cartItemId, long shopId, String shopName,
                                        String shopStatus, boolean productActive,
                                        boolean variantActive, int stock, int qty,
                                        BigDecimal unitPrice) {
        ProductVariantDetailDTO variant = new ProductVariantDetailDTO();
        variant.setVariantId(1000L + cartItemId);
        variant.setProductId(500L);
        variant.setProductName("Product " + cartItemId);
        variant.setVariantName("Variant " + cartItemId);
        variant.setSku("SKU-" + cartItemId);
        variant.setShopId(shopId);
        variant.setShopName(shopName);
        variant.setShopStatus(shopStatus);
        variant.setProductActive(productActive);
        variant.setActive(variantActive);
        variant.setStockQuantity(stock);
        variant.setPrice(unitPrice);
        CartItem item = new CartItem();
        item.setCartItemId(cartItemId);
        item.setVariant(variant);
        item.setQuantity(qty);
        return item;
    }

    private ShippingAddress createValidShippingAddress() {
        ShippingAddress address = new ShippingAddress();
        address.setRecipientName("Nguyen Van A");
        address.setRecipientPhone("0987654321");
        address.setStreetAddress("123 Nguyen Trai");
        address.setWard("Phuong 1");
        address.setDistrict("Quan 1");
        address.setCity("TP Ho Chi Minh");
        return address;
    }

    private Coupon createValidPlatformCoupon(String code, String discountType, BigDecimal discountValue,
                                             BigDecimal maxCap, BigDecimal minOrderValue) {
        Coupon c = new Coupon();
        c.setCouponId(99);
        c.setCode(code);
        c.setShopId(null); // Platform coupon
        c.setActive(true);
        c.setDiscountType(discountType);
        c.setDiscountValue(discountValue);
        c.setMaxDiscountAmount(maxCap);
        c.setMinOrderValue(minOrderValue);
        c.setUsageLimit(100);
        c.setUsedCount(5);
        long now = System.currentTimeMillis();
        c.setStartDate(new Timestamp(now - 100_000));
        c.setEndDate(new Timestamp(now + 100_000));
        return c;
    }

    @Nested
    @DisplayName("getSelectedItemsForCheckout Tests")
    class GetSelectedItemsTests {

        @Test
        @DisplayName("Null or empty cartItemIds should throw IllegalArgumentException")
        void testGetSelectedItems_NullOrEmpty() {
            assertThrows(IllegalArgumentException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, null));
            assertThrows(IllegalArgumentException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, Collections.emptyList()));
        }

        @Test
        @DisplayName("cartItemIds containing null should throw IllegalArgumentException")
        void testGetSelectedItems_ContainsNull() {
            List<Long> ids = new ArrayList<>();
            ids.add(null);
            assertThrows(IllegalArgumentException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, ids));
        }

        @Test
        @DisplayName("DAO returning empty list should throw IllegalArgumentException")
        void testGetSelectedItems_EmptyFromDAO() {
            when(orderDAO.getSelectedCartItems(1L, List.of(10L)))
                .thenReturn(Collections.emptyList());

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, List.of(10L)));
            assertTrue(ex.getMessage().contains("Không tìm thấy"));
        }

        @Test
        @DisplayName("DAO returning fewer items than uniqueIds should throw IllegalArgumentException")
        void testGetSelectedItems_SizeMismatch() {
            CartItem item1 = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(100));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L, 2L)))
                .thenReturn(List.of(item1));

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, List.of(1L, 2L)));
            assertTrue(ex.getMessage().contains("không thuộc giỏ hàng"));
        }

        @Test
        @DisplayName("Inactive variant should throw IllegalStateException")
        void testGetSelectedItems_InactiveVariant() {
            CartItem item = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, false, 10, 1, BigDecimal.valueOf(100));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L)))
                .thenReturn(List.of(item));

            IllegalStateException ex = assertThrows(IllegalStateException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, List.of(1L)));
            assertTrue(ex.getMessage().contains("không còn khả dụng"));
        }

        @Test
        @DisplayName("Inactive shop should throw IllegalStateException")
        void testGetSelectedItems_InactiveShop() {
            CartItem item = createMockCartItem(1L, 10L, "Shop A", "SUSPENDED", true, true, 10, 1, BigDecimal.valueOf(100));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L)))
                .thenReturn(List.of(item));

            IllegalStateException ex = assertThrows(IllegalStateException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, List.of(1L)));
            assertTrue(ex.getMessage().contains("hiện không hoạt động"));
        }

        @Test
        @DisplayName("Stock less than item quantity should throw IllegalStateException")
        void testGetSelectedItems_InsufficientStock() {
            CartItem item = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, true, 3, 5, BigDecimal.valueOf(100));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L)))
                .thenReturn(List.of(item));

            IllegalStateException ex = assertThrows(IllegalStateException.class,
                () -> orderService.getSelectedItemsForCheckout(1L, List.of(1L)));
            assertTrue(ex.getMessage().contains("chỉ còn 3 sản phẩm trong kho"));
        }

        @Test
        @DisplayName("Valid items should pass validation and return items")
        void testGetSelectedItems_Success() {
            CartItem item = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, true, 10, 2, BigDecimal.valueOf(50000));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L)))
                .thenReturn(List.of(item));

            List<CartItem> result = orderService.getSelectedItemsForCheckout(1L, List.of(1L));

            assertNotNull(result);
            assertEquals(1, result.size());
            assertEquals(1L, result.get(0).getCartItemId());
        }
    }

    @Nested
    @DisplayName("getBuyNowItemForCheckout Tests")
    class BuyNowItemTests {

        @ParameterizedTest
        @CsvSource({
            "0, 1",
            "-1, 1",
            "1, 0",
            "1, -5"
        })
        @DisplayName("Invalid variantId or quantity should throw IllegalArgumentException")
        void testGetBuyNowItem_InvalidParams(long variantId, int qty) {
            assertThrows(IllegalArgumentException.class,
                () -> orderService.getBuyNowItemForCheckout(variantId, qty));
        }

        @Test
        @DisplayName("Item not found by DAO should throw IllegalArgumentException")
        void testGetBuyNowItem_NotFound() {
            when(orderDAO.getBuyNowItem(10L, 2)).thenReturn(null);

            assertThrows(IllegalArgumentException.class,
                () -> orderService.getBuyNowItemForCheckout(10L, 2));
        }

        @Test
        @DisplayName("Valid buy now item should return item")
        void testGetBuyNowItem_Success() {
            CartItem item = createMockCartItem(0L, 10L, "Shop A", "ACTIVE", true, true, 10, 2, BigDecimal.valueOf(50000));
            when(orderDAO.getBuyNowItem(10L, 2)).thenReturn(item);

            CartItem result = orderService.getBuyNowItemForCheckout(10L, 2);

            assertNotNull(result);
            assertEquals(2, result.getQuantity());
        }
    }

    @Nested
    @DisplayName("buildDraftOrder & Coupon Calculation Tests")
    class BuildDraftOrderTests {

        @Test
        @DisplayName("Shipping fee should be 14k for same province and 30k otherwise")
        void testBuildDraftOrder_ShippingFeeByProvince() {
            CartItem sameProvince = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(100000));
            CartItem otherProvince = createMockCartItem(2L, 20L, "Shop Beta", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(200000));
            when(shopDAO.getShopProvinces(anyCollection())).thenReturn(Map.of(
                    10L, "Thành phố Hồ Chí Minh",
                    20L, "Lâm Đồng"));

            OrderDetailDTO order = orderService.buildDraftOrder(1L,
                    List.of(sameProvince, otherProvince), null, Collections.emptyMap(), "TP. Ho Chi Minh");

            Map<Long, BigDecimal> fees = new HashMap<>();
            for (SubOrderDTO subOrder : order.getSubOrders()) {
                fees.put(subOrder.getShopId(), subOrder.getShopShippingFee());
            }
            assertEquals(0, new BigDecimal("14000").compareTo(fees.get(10L)));
            assertEquals(0, new BigDecimal("30000").compareTo(fees.get(20L)));
            assertEquals(0, new BigDecimal("44000").compareTo(order.getTotalShippingFee()));
            assertEquals(0, new BigDecimal("344000").compareTo(order.getFinalAmount()));
        }

        @Test
        @DisplayName("Missing shop province should use the 30k inter-province fee")
        void testBuildDraftOrder_MissingShopProvinceUsesFallbackFee() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(100000));
            when(shopDAO.getShopProvinces(anyCollection())).thenReturn(Collections.emptyMap());

            OrderDetailDTO order = orderService.buildDraftOrder(1L, List.of(item), null,
                    Collections.emptyMap(), "Hà Nội");

            assertEquals(0, new BigDecimal("30000").compareTo(order.getTotalShippingFee()));
            assertEquals(0, new BigDecimal("130000").compareTo(order.getFinalAmount()));
        }

        @Test
        @DisplayName("Multi-shop items should be grouped into separate SubOrders")
        void testBuildDraftOrder_MultiShopGrouping() {
            CartItem item1 = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 2, BigDecimal.valueOf(100000));
            CartItem item2 = createMockCartItem(2L, 20L, "Shop Beta", "ACTIVE", true, true, 5, 1, BigDecimal.valueOf(150000));

            OrderDetailDTO order = orderService.buildDraftOrder(1L, List.of(item1, item2), null);

            assertNotNull(order);
            assertEquals(1L, order.getCustomerId());
            assertEquals(2, order.getSubOrders().size());
            assertEquals(0, new BigDecimal("350000").compareTo(order.getTotalGoodsAmount()));
            assertEquals(0, new BigDecimal("350000").compareTo(order.getFinalAmount()));
        }

        @Test
        @DisplayName("Platform coupon with PERCENTAGE and MaxDiscount cap")
        void testBuildDraftOrder_PlatformCouponPercentageWithMax() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(500000));
            // 20% of 500k = 100k, but maxCap = 50k
            Coupon coupon = createValidPlatformCoupon("GIAM20", "PERCENTAGE", BigDecimal.valueOf(20),
                    BigDecimal.valueOf(50000), BigDecimal.valueOf(100000));
            when(couponDAO.findByCode("GIAM20")).thenReturn(coupon);

            OrderDetailDTO order = orderService.buildDraftOrder(1L, List.of(item), "GIAM20");

            assertEquals(0, new BigDecimal("50000.00").compareTo(order.getPlatformDiscount()));
            assertEquals(0, new BigDecimal("450000.00").compareTo(order.getFinalAmount()));
        }

        @Test
        @DisplayName("Platform coupon with FIXED_AMOUNT")
        void testBuildDraftOrder_PlatformCouponFixedAmount() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(200000));
            Coupon coupon = createValidPlatformCoupon("GIAM30K", "FIXED_AMOUNT", BigDecimal.valueOf(30000),
                    null, BigDecimal.valueOf(100000));
            when(couponDAO.findByCode("GIAM30K")).thenReturn(coupon);

            OrderDetailDTO order = orderService.buildDraftOrder(1L, List.of(item), "GIAM30K");

            assertEquals(0, new BigDecimal("30000.00").compareTo(order.getPlatformDiscount()));
            assertEquals(0, new BigDecimal("170000.00").compareTo(order.getFinalAmount()));
        }

        @Test
        @DisplayName("Platform coupon validation throws when coupon is tied to specific shop")
        void testBuildDraftOrder_PlatformCouponHasShopId_Throws() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(200000));
            Coupon coupon = createValidPlatformCoupon("SHOPVOUCHER", "FIXED_AMOUNT", BigDecimal.valueOf(30000), null, BigDecimal.ZERO);
            coupon.setShopId(10L); // Not a platform coupon
            when(couponDAO.findByCode("SHOPVOUCHER")).thenReturn(coupon);

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> orderService.buildDraftOrder(1L, List.of(item), "SHOPVOUCHER"));
            assertTrue(ex.getMessage().contains("không thể áp dụng cho toàn sàn"));
        }

        @Test
        @DisplayName("Platform coupon validation throws when expired")
        void testBuildDraftOrder_CouponExpired_Throws() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(200000));
            Coupon coupon = createValidPlatformCoupon("EXPIRED", "FIXED_AMOUNT", BigDecimal.valueOf(10000), null, BigDecimal.ZERO);
            coupon.setEndDate(new Timestamp(System.currentTimeMillis() - 100_000)); // Past
            when(couponDAO.findByCode("EXPIRED")).thenReturn(coupon);

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> orderService.buildDraftOrder(1L, List.of(item), "EXPIRED"));
            assertTrue(ex.getMessage().contains("đã hết hạn"));
        }

        @Test
        @DisplayName("Platform coupon validation throws when usage limit reached")
        void testBuildDraftOrder_CouponLimitReached_Throws() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(200000));
            Coupon coupon = createValidPlatformCoupon("MAXUSED", "FIXED_AMOUNT", BigDecimal.valueOf(10000), null, BigDecimal.ZERO);
            coupon.setUsageLimit(50);
            coupon.setUsedCount(50);
            when(couponDAO.findByCode("MAXUSED")).thenReturn(coupon);

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> orderService.buildDraftOrder(1L, List.of(item), "MAXUSED"));
            assertTrue(ex.getMessage().contains("hết lượt sử dụng"));
        }

        @Test
        @DisplayName("Platform coupon validation throws when order amount below minimum")
        void testBuildDraftOrder_BelowMinOrderValue_Throws() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(80000));
            Coupon coupon = createValidPlatformCoupon("MIN100", "FIXED_AMOUNT", BigDecimal.valueOf(20000), null, BigDecimal.valueOf(100000));
            when(couponDAO.findByCode("MIN100")).thenReturn(coupon);

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> orderService.buildDraftOrder(1L, List.of(item), "MIN100"));
            assertTrue(ex.getMessage().contains("Đơn hàng cần đạt tối thiểu"));
        }

        @Test
        @DisplayName("Shop coupon applied to specific shop suborder correctly")
        void testBuildDraftOrder_WithShopCoupon() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(200000));
            Coupon shopCoupon = createValidPlatformCoupon("SHOP10K", "FIXED_AMOUNT", BigDecimal.valueOf(10000), null, BigDecimal.valueOf(100000));
            shopCoupon.setShopId(10L); // Belongs to Shop 10
            when(couponDAO.findByCode("SHOP10K")).thenReturn(shopCoupon);

            Map<Long, String> shopCoupons = Map.of(10L, "SHOP10K");
            OrderDetailDTO order = orderService.buildDraftOrder(1L, List.of(item), null, shopCoupons);

            SubOrderDTO subOrder = order.getSubOrders().get(0);
            assertEquals(0, new BigDecimal("10000.00").compareTo(subOrder.getShopDiscount()));
            assertEquals(0, new BigDecimal("190000.00").compareTo(subOrder.getShopTotal()));
            assertEquals(0, new BigDecimal("190000.00").compareTo(order.getFinalAmount()));
        }

        @Test
        @DisplayName("Shop coupon validation throws if coupon belongs to a different shop")
        void testBuildDraftOrder_ShopCouponWrongShop_Throws() {
            CartItem item = createMockCartItem(1L, 10L, "Shop Alpha", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(200000));
            Coupon shopCoupon = createValidPlatformCoupon("SHOP20V", "FIXED_AMOUNT", BigDecimal.valueOf(10000), null, BigDecimal.ZERO);
            shopCoupon.setShopId(20L); // Belongs to Shop 20, but item is from Shop 10
            when(couponDAO.findByCode("SHOP20V")).thenReturn(shopCoupon);

            Map<Long, String> shopCoupons = Map.of(10L, "SHOP20V");
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> orderService.buildDraftOrder(1L, List.of(item), null, shopCoupons));
            assertTrue(ex.getMessage().contains("không thuộc cửa hàng này"));
        }
    }

    @Nested
    @DisplayName("placeOrder Tests")
    class PlaceOrderTests {

        @Test
        @DisplayName("Invalid recipient name in ShippingAddress throws IllegalArgumentException")
        void testPlaceOrder_EmptyName_Throws() {
            ShippingAddress address = createValidShippingAddress();
            address.setRecipientName("   ");

            CartItem item = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(100000));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L))).thenReturn(List.of(item));

            assertThrows(IllegalArgumentException.class,
                () -> orderService.placeOrder(1L, List.of(1L), address, "MORNING", "COD", null, false));
        }

        @ParameterizedTest(name = "Invalid phone number: \"{0}\"")
        @ValueSource(strings = {"12345", "098765432", "abcdefg", "09876543219999", ""})
        @DisplayName("Invalid recipient phone format throws IllegalArgumentException")
        void testPlaceOrder_InvalidPhone_Throws(String phone) {
            ShippingAddress address = createValidShippingAddress();
            address.setRecipientPhone(phone);

            CartItem item = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(100000));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L))).thenReturn(List.of(item));

            assertThrows(IllegalArgumentException.class,
                () -> orderService.placeOrder(1L, List.of(1L), address, "MORNING", "COD", null, false));
        }

        @Test
        @DisplayName("Invalid payment method throws IllegalArgumentException")
        void testPlaceOrder_InvalidPaymentMethod_Throws() {
            ShippingAddress address = createValidShippingAddress();
            CartItem item = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, true, 10, 1, BigDecimal.valueOf(100000));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L))).thenReturn(List.of(item));

            assertThrows(IllegalArgumentException.class,
                () -> orderService.placeOrder(1L, List.of(1L), address, "MORNING", "BITCOIN", null, false));
        }

        @Test
        @DisplayName("Valid inputs should successfully invoke orderDAO.createOrder")
        void testPlaceOrder_Success() throws Exception {
            ShippingAddress address = createValidShippingAddress();
            CartItem item = createMockCartItem(1L, 10L, "Shop A", "ACTIVE", true, true, 10, 2, BigDecimal.valueOf(100000));
            when(orderDAO.getSelectedCartItems(1L, List.of(1L))).thenReturn(List.of(item));
            when(orderDAO.createOrder(any(OrderDetailDTO.class), eq(address), eq(List.of(1L)), eq("COD"), eq(false)))
                .thenReturn(9999L);

            long orderId = orderService.placeOrder(1L, List.of(1L), address, "MORNING", "COD", null, false);

            assertEquals(9999L, orderId);
            verify(orderDAO).createOrder(any(OrderDetailDTO.class), eq(address), eq(List.of(1L)), eq("COD"), eq(false));
        }
    }

    @Nested
    @DisplayName("DAO Delegation Tests")
    class DaoDelegationTests {

        @Test
        @DisplayName("getOrderDetails should delegate to orderDAO.getOrderById")
        void testGetOrderDetails() {
            OrderDetailDTO mockOrder = new OrderDetailDTO();
            mockOrder.setOrderId(123L);
            when(orderDAO.getOrderById(123L)).thenReturn(mockOrder);

            OrderDetailDTO result = orderService.getOrderDetails(123L);

            assertEquals(mockOrder, result);
            verify(orderDAO).getOrderById(123L);
        }

        @Test
        @DisplayName("cancelOrderByCustomer should delegate to orderDAO.cancelOrderByCustomer")
        void testCancelOrderByCustomer() throws Exception {
            when(orderDAO.cancelOrderByCustomer(1L, "ORD-123", "Changed mind")).thenReturn(true);

            boolean success = orderService.cancelOrderByCustomer(1L, "ORD-123", "Changed mind");

            assertTrue(success);
            verify(orderDAO).cancelOrderByCustomer(1L, "ORD-123", "Changed mind");
        }
    }
}
