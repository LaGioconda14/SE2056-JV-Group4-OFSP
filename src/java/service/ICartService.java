package service;

import model.entity.cart.Cart;
import model.entity.cart.CartItem;
import model.dto.cart.CartMutationResult;

/**
 * Interface định nghĩa các nghiệp vụ quản lý giỏ hàng của khách hàng.
 */
public interface ICartService {

    /**
     * Nạp toàn bộ giỏ hàng của khách hàng và đối soát lại số lượng theo tồn kho thực tế.
     * Tự động điều chỉnh giảm số lượng nếu vượt quá tồn kho hiện tại hoặc hết hàng.
     *
     * @param customerId ID của khách hàng
     * @return đối tượng Cart chứa danh sách sản phẩm và thông tin giỏ hàng
     */
    Cart loadCartAndReconcile(long customerId);

    /**
     * Đếm tổng số lượng dòng sản phẩm trong giỏ hàng của khách hàng.
     *
     * @param customerId ID của khách hàng
     * @return số lượng mục sản phẩm trong giỏ
     */
    int getCartItemCount(long customerId);

    /**
     * Thêm một biến thể sản phẩm vào giỏ hàng với số lượng chỉ định.
     * Nếu biến thể đã tồn tại trong giỏ thì tăng số lượng.
     *
     * @param customerId ID của khách hàng
     * @param variantId  ID của biến thể sản phẩm (variant)
     * @param quantity   số lượng cần thêm
     * @return kết quả biến đổi giỏ hàng (CartMutationResult) chứa tổng số mục mới
     */
    CartMutationResult addItem(long customerId, long variantId, int quantity);

    /**
     * Cập nhật số lượng của một mục sản phẩm trong giỏ hàng.
     *
     * @param customerId ID của khách hàng
     * @param cartItemId ID của mục giỏ hàng (cart_item_id)
     * @param quantity   số lượng mới (phải lớn hơn 0)
     */
    void updateQuantity(long customerId, long cartItemId, int quantity);

    /**
     * Xóa một mục sản phẩm khỏi giỏ hàng.
     *
     * @param customerId ID của khách hàng
     * @param cartItemId ID của mục giỏ hàng cần xóa
     */
    void removeItem(long customerId, long cartItemId);

    /**
     * Đổi biến thể (variant) của một mục đã có trong giỏ hàng.
     * Nếu biến thể mới đã có trong giỏ thì gộp số lượng và xóa mục cũ.
     *
     * @param customerId ID của khách hàng
     * @param cartItemId ID của mục giỏ hàng hiện tại
     * @param variantId  ID của biến thể mới muốn chuyển sang
     */
    void changeVariant(long customerId, long cartItemId, long variantId);
}

