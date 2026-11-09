package model.dto.cart;

import model.entity.cart.CartItem;

public record CartMutationResult(CartItem item, int cartItemCount) {
}
