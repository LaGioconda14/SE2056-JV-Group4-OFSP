package service;

import model.Cart;

/**
 *
 * @author Bac
 */
public interface ICartService {

    Cart getCart(long customerId);

    void addItem(long customerId, long variantId, int quantity) throws Exception;

    void updateQuantity(long customerId, long cartItemId, int quantity) throws Exception;

    void removeItem(long customerId, long cartItemId) throws Exception;
}
