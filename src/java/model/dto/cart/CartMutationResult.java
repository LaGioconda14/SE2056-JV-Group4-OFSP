package model.dto.cart;

import model.entity.cart.CartItem;

/** Kết quả sau thao tác giỏ: dòng vừa cập nhật và số dòng biến thể để đồng bộ huy hiệu giỏ. */
public record CartMutationResult(CartItem item, int cartItemCount) {
}
