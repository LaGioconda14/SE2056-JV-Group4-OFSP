package service;

import model.entity.cart.Cart;
import model.entity.cart.CartItem;
import model.dto.cart.CartMutationResult;

/**
 * Interface định nghĩa các nghiệp vụ quản lý giỏ hàng của khách hàng.
 */
public interface ICartService {

    // Hop dong trien khai hien tai yeu cau moi ID va quantity duoc truyen vao deu duong.
    // customerId phai duoc lop goi lay tu danh tinh da xac thuc; interface khong xac thuc user.
    /**
     * Nạp toàn bộ giỏ hàng của khách hàng và đối soát lại số lượng theo tồn kho thực tế.
     * Chỉ giảm số lượng vượt kho đối với biến thể còn mua được; mục hết hàng giữ trạng thái để khách đổi biến thể.
     * Việc nạp có thể ghi lại số lượng bị giảm; giá khuyến mãi chỉ được tính để hiển thị,
     * không giữ tồn kho hoặc suất ưu đãi cho bước đặt hàng.
     *
     * @param customerId ID của khách hàng
     * @return đối tượng Cart chứa danh sách sản phẩm và thông tin giỏ hàng
     */
    Cart loadCartAndReconcile(long customerId);

    // Phep dem khong tao gio moi va dem so dong item, khong cong quantity cua cac dong.
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

    // Cap nhat dat quantity tuyet doi, khong phai cong them; vuot stock se bi tu choi.
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

    // Variant dich phai dang hoat dong, thuoc cung product; tong moi co the bi cat theo stock.
    /**
     * Đổi biến thể (variant) của một mục đã có trong giỏ hàng.
     * Nếu biến thể mới đã có trong giỏ thì gộp số lượng và xóa mục cũ.
     * Số lượng sau khi gộp bị giới hạn bởi tồn kho của biến thể đích.
     *
     * @param customerId ID của khách hàng
     * @param cartItemId ID của mục giỏ hàng hiện tại
     * @param variantId  ID của biến thể mới muốn chuyển sang
     */
    void changeVariant(long customerId, long cartItemId, long variantId);
}

