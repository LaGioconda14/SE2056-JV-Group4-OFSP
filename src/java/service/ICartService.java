package service;

import model.entity.cart.Cart;
import model.entity.cart.CartItem;
import model.dto.cart.CartMutationResult;

public interface ICartService {

    Cart loadCartAndReconcile(long customerId);

    int getCartItemCount(long customerId);

    CartMutationResult addItem(long customerId, long variantId, int quantity);

    void updateQuantity(long customerId, long cartItemId, int quantity);

    void removeItem(long customerId, long cartItemId);

    void changeVariant(long customerId, long cartItemId, long variantId);
}
