package service.impl;

import dao.CartDAO;
import java.util.List;
import java.util.logging.Logger;
import model.Cart;
import model.CartItem;
import model.ProductVariant;
import service.ICartService;

public class CartServiceImpl implements ICartService {

    private static final Logger LOGGER = Logger.getLogger(CartServiceImpl.class.getName());
    private final CartDAO cartDAO;

    public CartServiceImpl() {
        this.cartDAO = new CartDAO();
    }

    public CartServiceImpl(CartDAO cartDAO) {
        this.cartDAO = cartDAO;
    }

    @Override
    public Cart getCart(long customerId) {
        Cart cart = requireCart(customerId);
        List<CartItem> items = cartDAO.getCartItems(cart.getCartId());
        if (items == null) {
            LOGGER.severe("Cart item lookup returned no result");
            throw new IllegalStateException("Không thể tải giỏ hàng. Vui lòng thử lại sau!");
        }
        cart.setItems(items);
        return cart;
    }

    @Override
    public void addItem(long customerId, long variantId, int quantity) throws Exception {
        validateId(customerId);
        validateId(variantId);
        validateQuantity(quantity);
        validateVariant(cartDAO.findAvailableVariant(variantId), quantity);
        Cart cart = requireCart(customerId);
        if (!cartDAO.addCartItem(customerId, cart.getCartId(), variantId, quantity)) {
            throw new IllegalArgumentException("Giỏ hàng không khả dụng!");
        }
    }

    @Override
    public void updateQuantity(long customerId, long cartItemId, int quantity) throws Exception {
        validateId(customerId);
        validateId(cartItemId);
        validateQuantity(quantity);
        Cart cart = requireCart(customerId);
        CartItem item = requireItem(cart.getCartId(), cartItemId);
        validateVariant(cartDAO.findAvailableVariant(item.getVariant().getVariantId()), quantity);
        if (!cartDAO.updateCartItemQuantity(customerId, cart.getCartId(), cartItemId, quantity)) {
            throw new IllegalArgumentException("Sản phẩm không có trong giỏ hàng!");
        }
    }

    @Override
    public void removeItem(long customerId, long cartItemId) throws Exception {
        validateId(customerId);
        validateId(cartItemId);
        Cart cart = requireCart(customerId);
        requireItem(cart.getCartId(), cartItemId);
        if (!cartDAO.deleteCartItem(customerId, cart.getCartId(), cartItemId)) {
            throw new IllegalArgumentException("Sản phẩm không có trong giỏ hàng!");
        }
    }

    @Override
    public void changeVariant(long customerId, long cartItemId, long variantId) throws Exception {
        validateId(customerId);
        validateId(cartItemId);
        validateId(variantId);
        Cart cart = requireCart(customerId);
        if (!cartDAO.changeCartItemVariant(customerId, cart.getCartId(), cartItemId, variantId)) {
            throw new IllegalArgumentException("Không thể đổi biến thể trong giỏ hàng!");
        }
    }

    private Cart requireCart(long customerId) {
        validateId(customerId);
        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null || cart.getCartId() <= 0 || cart.getCustomerId() != customerId) {
            LOGGER.severe("Cart lookup returned an invalid cart");
            throw new IllegalStateException("Không thể tải giỏ hàng. Vui lòng thử lại sau!");
        }
        return cart;
    }

    private CartItem requireItem(long cartId, long cartItemId) {
        CartItem item = cartDAO.findCartItemById(cartId, cartItemId);
        if (item == null) {
            throw new IllegalArgumentException("Sản phẩm không có trong giỏ hàng!");
        }
        return item;
    }

    private void validateId(long id) {
        if (id <= 0) {
            throw new IllegalArgumentException("Thông tin giỏ hàng không hợp lệ!");
        }
    }

    private void validateQuantity(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0!");
        }
    }

    private void validateVariant(ProductVariant variant, long quantity) {
        if (variant == null || !variant.isActive() || variant.getProduct() == null
                || !variant.getProduct().isActive()) {
            throw new IllegalArgumentException("Sản phẩm hiện không khả dụng!");
        }
        if (quantity > variant.getStockQuantity()) {
            throw new IllegalArgumentException("Số lượng vượt quá tồn kho!");
        }
    }
}
