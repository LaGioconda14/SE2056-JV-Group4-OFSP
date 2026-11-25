package service.impl;

import dao.order.CartDAO;
import model.entity.cart.Cart;
import model.entity.cart.CartItem;
import model.dto.cart.CartMutationResult;
import service.ICartService;

/**
 * Cung cấp triển khai các nghiệp vụ giỏ hàng (ICartService):
 * - Nạp và đối soát số lượng tồn kho giỏ hàng.
 * - Thêm, sửa, xóa, đổi phân loại sản phẩm.
 * - Tự động áp dụng giá khuyến mãi tại thời điểm xem giỏ.
 */
public class CartServiceImpl implements ICartService {

    // Service chi kiem tra gia tri dau vao; customerId phai den tu nguon da xac thuc.
    private final CartDAO cartDAO;

    /**
     * Khởi tạo CartServiceImpl với CartDAO mặc định.
     */
    public CartServiceImpl() {
        this(new CartDAO());
    }

    /**
     * Khởi tạo CartServiceImpl với CartDAO tùy chỉnh (phục vụ Unit Test).
     *
     * @param cartDAO DAO tương tác bảng carts và cart_items
     */
    public CartServiceImpl(CartDAO cartDAO) {
        this.cartDAO = cartDAO;
    }

    /**
     * Nạp giỏ hàng của khách hàng, đối soát lại số lượng tồn kho và áp dụng khuyến mãi hiện hành.
     *
     * @param customerId ID của khách hàng
     * @return giỏ hàng hoàn chỉnh đã cập nhật tồn kho và khuyến mãi
     */
    @Override
    public Cart loadCartAndReconcile(long customerId) {
        validateId(customerId);
        // Tao/tim gio va doi soat la hai lan goi DAO voi transaction rieng, khong atomic chung.
        // Tìm giỏ hàng hiện tại hoặc tạo mới nếu khách hàng chưa có giỏ
        Cart cart = cartDAO.findOrCreateCartByCustomerId(customerId);
        // Tải các item và tự động đối soát tồn kho
        java.util.List<CartItem> loaded = cartDAO.loadAndReconcileItems(cart.getCartId());
        // Tinh gia sau khi DAO doi soat va commit; khong ghi gia nay vao cart_items tai day.
        // Giá ưu đãi ở đây chỉ là snapshot khi xem giỏ; đặt hàng còn phải giữ quota trong DB.
        util.PromotionPricing.applyToCartItems(loaded);
        cart.setItems(loaded);
        return cart;
    }

    /**
     * Lấy tổng số lượng dòng sản phẩm trong giỏ hàng của khách hàng.
     *
     * @param customerId ID của khách hàng
     * @return số lượng mục sản phẩm
     */
    @Override
    public int getCartItemCount(long customerId) {
        validateId(customerId);
        // Chi dem dong hien co, khong tao gio va khong cong so luong san pham.
        return cartDAO.countItemsByCustomerId(customerId);
    }

    /**
     * Thêm biến thể sản phẩm vào giỏ hàng sau khi xác thực dữ liệu đầu vào.
     *
     * @param customerId ID của khách hàng
     * @param variantId  ID biến thể sản phẩm
     * @param quantity   số lượng muốn thêm (phải > 0)
     * @return kết quả thao tác giỏ hàng kèm tổng số mục mới
     */
    @Override
    public CartMutationResult addItem(long customerId, long variantId, int quantity) {
        // Kiem tra can duoi truoc DAO; DAO kiem tra trang thai va tong quantity so voi stock.
        validateId(customerId);
        validateId(variantId);
        validateQuantity(quantity);
        return cartDAO.addCartItem(customerId, variantId, quantity);
    }

    /**
     * Cập nhật số lượng của mục sản phẩm trong giỏ hàng.
     *
     * @param customerId ID của khách hàng
     * @param cartItemId ID mục giỏ hàng
     * @param quantity   số lượng mới (phải > 0)
     */
    @Override
    public void updateQuantity(long customerId, long cartItemId, int quantity) {
        // quantity la gia tri moi; DAO kiem tra item thuoc gio va khong vuot stock.
        validateId(customerId);
        validateId(cartItemId);
        validateQuantity(quantity);
        cartDAO.updateCartItemQuantity(customerId, cartItemId, quantity);
    }

    /**
     * Xóa một mục sản phẩm khỏi giỏ hàng.
     *
     * @param customerId ID của khách hàng
     * @param cartItemId ID mục giỏ hàng cần xóa
     */
    @Override
    public void removeItem(long customerId, long cartItemId) {
        // DAO gioi han xoa theo gio cua customerId, khong chi dua vao cartItemId.
        validateId(customerId);
        validateId(cartItemId);
        cartDAO.deleteCartItem(customerId, cartItemId);
    }

    /**
     * Thay đổi phân loại (variant) cho một mục sản phẩm trong giỏ hàng.
     *
     * @param customerId ID của khách hàng
     * @param cartItemId ID mục giỏ hàng cần đổi
     * @param variantId  ID biến thể mới muốn đổi sang
     */
    @Override
    public void changeVariant(long customerId, long cartItemId, long variantId) {
        // DAO kiem tra cung product, trang thai variant dich va xu ly gop trong transaction.
        validateId(customerId);
        validateId(cartItemId);
        validateId(variantId);
        cartDAO.changeCartItemVariant(customerId, cartItemId, variantId);
    }

    /**
     * Kiểm tra tính hợp lệ của ID (phải là số nguyên dương).
     *
     * @param id ID cần kiểm tra
     * @throws IllegalArgumentException nếu ID <= 0
     */
    private void validateId(long id) {
        if (id <= 0) {
            throw new IllegalArgumentException("Thông tin giỏ hàng không hợp lệ!");
        }
    }

    /**
     * Kiểm tra tính hợp lệ của số lượng (phải > 0).
     *
     * @param quantity số lượng cần kiểm tra
     * @throws IllegalArgumentException nếu quantity <= 0
     */
    private void validateQuantity(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0!");
        }
    }
}
