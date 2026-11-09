package service.impl;

import dao.CartDAO;
import model.Cart;
import model.CartItem;
import model.CartMutationResult;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Unit Tests for CartServiceImpl")
class CartServiceImplTest {

    @Mock
    private CartDAO cartDAO;

    private CartServiceImpl cartService;

    @BeforeEach
    void setUp() {
        cartService = new CartServiceImpl(cartDAO);
    }

    @Nested
    @DisplayName("Validation Tests")
    class ValidationTests {

        @ParameterizedTest(name = "Invalid customerId: {0}")
        @ValueSource(longs = {0, -1, -50})
        @DisplayName("addItem with invalid customerId should throw IllegalArgumentException")
        void testAddItem_InvalidCustomerId(long invalidCustomerId) {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.addItem(invalidCustomerId, 10L, 1));
            assertEquals("Thông tin giỏ hàng không hợp lệ!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @ParameterizedTest(name = "Invalid variantId: {0}")
        @ValueSource(longs = {0, -1, -100})
        @DisplayName("addItem with invalid variantId should throw IllegalArgumentException")
        void testAddItem_InvalidVariantId(long invalidVariantId) {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.addItem(1L, invalidVariantId, 1));
            assertEquals("Thông tin giỏ hàng không hợp lệ!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @ParameterizedTest(name = "Invalid quantity: {0}")
        @ValueSource(ints = {0, -1, -10})
        @DisplayName("addItem with invalid quantity should throw IllegalArgumentException")
        void testAddItem_InvalidQuantity(int invalidQty) {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.addItem(1L, 10L, invalidQty));
            assertEquals("Số lượng phải lớn hơn 0!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @ParameterizedTest(name = "Invalid quantity for updateQuantity: {0}")
        @ValueSource(ints = {0, -1, -5})
        @DisplayName("updateQuantity with invalid quantity should throw IllegalArgumentException")
        void testUpdateQuantity_InvalidQuantity(int invalidQty) {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.updateQuantity(1L, 10L, invalidQty));
            assertEquals("Số lượng phải lớn hơn 0!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @Test
        @DisplayName("removeItem with invalid customerId should throw IllegalArgumentException")
        void testRemoveItem_InvalidCustomerId() {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.removeItem(0L, 5L));
            assertEquals("Thông tin giỏ hàng không hợp lệ!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @Test
        @DisplayName("removeItem with invalid cartItemId should throw IllegalArgumentException")
        void testRemoveItem_InvalidCartItemId() {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.removeItem(1L, 0L));
            assertEquals("Thông tin giỏ hàng không hợp lệ!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @Test
        @DisplayName("changeVariant with invalid variantId should throw IllegalArgumentException")
        void testChangeVariant_InvalidVariantId() {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.changeVariant(1L, 5L, -1L));
            assertEquals("Thông tin giỏ hàng không hợp lệ!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @Test
        @DisplayName("getCartItemCount with invalid customerId should throw IllegalArgumentException")
        void testGetCartItemCount_InvalidCustomerId() {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.getCartItemCount(-1L));
            assertEquals("Thông tin giỏ hàng không hợp lệ!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }

        @Test
        @DisplayName("loadCartAndReconcile with invalid customerId should throw IllegalArgumentException")
        void testLoadCartAndReconcile_InvalidCustomerId() {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> cartService.loadCartAndReconcile(0L));
            assertEquals("Thông tin giỏ hàng không hợp lệ!", ex.getMessage());
            verifyNoInteractions(cartDAO);
        }
    }

    @Nested
    @DisplayName("Cart Operations Tests")
    class OperationTests {

        @Test
        @DisplayName("addItem should delegate to cartDAO and return mutation result")
        void testAddItem_Success() {
            CartItem cartItem = new CartItem();
            cartItem.setCartItemId(101L);
            CartMutationResult expectedResult = new CartMutationResult(cartItem, 3);

            when(cartDAO.addCartItem(1L, 10L, 2)).thenReturn(expectedResult);

            CartMutationResult actualResult = cartService.addItem(1L, 10L, 2);

            assertNotNull(actualResult);
            assertEquals(expectedResult, actualResult);
            assertEquals(101L, actualResult.item().getCartItemId());
            assertEquals(3, actualResult.cartItemCount());
            verify(cartDAO, times(1)).addCartItem(1L, 10L, 2);
        }

        @Test
        @DisplayName("updateQuantity should call cartDAO.updateCartItemQuantity")
        void testUpdateQuantity_Success() {
            cartService.updateQuantity(1L, 10L, 5);

            verify(cartDAO, times(1)).updateCartItemQuantity(1L, 10L, 5);
        }

        @Test
        @DisplayName("removeItem should call cartDAO.deleteCartItem")
        void testRemoveItem_Success() {
            cartService.removeItem(1L, 10L);

            verify(cartDAO, times(1)).deleteCartItem(1L, 10L);
        }

        @Test
        @DisplayName("changeVariant should call cartDAO.changeCartItemVariant")
        void testChangeVariant_Success() {
            cartService.changeVariant(1L, 10L, 20L);

            verify(cartDAO, times(1)).changeCartItemVariant(1L, 10L, 20L);
        }

        @Test
        @DisplayName("getCartItemCount should return count from cartDAO")
        void testGetCartItemCount_Success() {
            when(cartDAO.countItemsByCustomerId(1L)).thenReturn(7);

            int count = cartService.getCartItemCount(1L);

            assertEquals(7, count);
            verify(cartDAO, times(1)).countItemsByCustomerId(1L);
        }

        @Test
        @DisplayName("loadCartAndReconcile should load cart, reconcile items and set to cart")
        void testLoadCartAndReconcile_Success() {
            Cart mockCart = new Cart();
            mockCart.setCartId(55L);
            mockCart.setCustomerId(1L);

            List<CartItem> items = new ArrayList<>();
            when(cartDAO.findOrCreateCartByCustomerId(1L)).thenReturn(mockCart);
            when(cartDAO.loadAndReconcileItems(55L)).thenReturn(items);

            Cart resultCart = cartService.loadCartAndReconcile(1L);

            assertNotNull(resultCart);
            assertEquals(55L, resultCart.getCartId());
            assertEquals(items, resultCart.getItems());
            verify(cartDAO, times(1)).findOrCreateCartByCustomerId(1L);
            verify(cartDAO, times(1)).loadAndReconcileItems(55L);
        }
    }
}
