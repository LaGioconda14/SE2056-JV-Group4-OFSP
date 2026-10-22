package service.impl;

import dao.CartDAO;
import exception.CartErrorCode;
import exception.CartException;
import model.Cart;
import model.CartItem;
import model.CartMutationResult;
import service.ICartService;

public class CartServiceImpl implements ICartService {

    private final CartDAO cartDAO;

    public CartServiceImpl() {
        this(new CartDAO());
    }

    public CartServiceImpl(CartDAO cartDAO) {
        this.cartDAO = cartDAO;
    }

    @Override
    public Cart loadCartAndReconcile(long customerId) {
        validateId(customerId);
        Cart cart = cartDAO.findOrCreateCartByCustomerId(customerId);
        cart.setItems(cartDAO.loadAndReconcileItems(cart.getCartId()));
        return cart;
    }

    @Override
    public int getCartItemCount(long customerId) {
        validateId(customerId);
        return cartDAO.countItemsByCustomerId(customerId);
    }

    @Override
    public CartMutationResult addItem(long customerId, long variantId, int quantity) {
        validateId(customerId);
        validateId(variantId);
        validateQuantity(quantity);
        return cartDAO.addCartItem(customerId, variantId, quantity);
    }

    @Override
    public void updateQuantity(long customerId, long cartItemId, int quantity) {
        validateId(customerId);
        validateId(cartItemId);
        validateQuantity(quantity);
        cartDAO.updateCartItemQuantity(customerId, cartItemId, quantity);
    }

    @Override
    public void removeItem(long customerId, long cartItemId) {
        validateId(customerId);
        validateId(cartItemId);
        cartDAO.deleteCartItem(customerId, cartItemId);
    }

    @Override
    public void changeVariant(long customerId, long cartItemId, long variantId) {
        validateId(customerId);
        validateId(cartItemId);
        validateId(variantId);
        cartDAO.changeCartItemVariant(customerId, cartItemId, variantId);
    }

    private void validateId(long id) {
        if (id <= 0) {
            throw new CartException(CartErrorCode.INVALID_INPUT,
                    "Thông tin giỏ hàng không hợp lệ!");
        }
    }

    private void validateQuantity(int quantity) {
        if (quantity <= 0) {
            throw new CartException(CartErrorCode.INVALID_INPUT,
                    "Số lượng phải lớn hơn 0!");
        }
    }
}
