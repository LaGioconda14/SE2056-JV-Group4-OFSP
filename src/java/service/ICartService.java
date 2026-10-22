package service;

import model.Cart;
import model.CartItem;
import model.CartMutationResult;

public interface ICartService {

    Cart loadCartAndReconcile(long customerId);

    int getCartItemCount(long customerId);

    CartMutationResult addItem(long customerId, long variantId, int quantity);

    void updateQuantity(long customerId, long cartItemId, int quantity);

    void removeItem(long customerId, long cartItemId);

    void changeVariant(long customerId, long cartItemId, long variantId);
}
