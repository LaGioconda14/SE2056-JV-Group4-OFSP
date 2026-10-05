package service.impl;

import dao.CartDAO;
import java.util.List;
import java.util.logging.Logger;
import model.Cart;
import model.CartItem;
import model.ProductVariant;
import service.ICartService;

/**
 *
 * @author Bac
 */
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
        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null) {
            return new Cart();
        }
        List<CartItem> items = cartDAO.getCartItems(cart.getCartId());
        cart.setItems(items);
        return cart;
    }

    @Override
    public void addItem(long customerId, long variantId, int quantity) throws Exception {
        if (quantity <= 0) {
            throw new Exception("Số lượng phải lớn hơn 0!");
        }

        Cart cart = cartDAO.getCartByCustomerId(customerId);
        if (cart == null) {
            throw new Exception("Không thể tạo giỏ hàng. Vui lòng thử lại!");
        }

        // kiem tra variant da co trong gio chua
        CartItem existingItem = cartDAO.findCartItem(cart.getCartId(), variantId);

        if (existingItem != null) {
            // da co -> cong so luong
            int newQuantity = existingItem.getQuantity() + quantity;
            boolean updated = cartDAO.updateCartItemQuantity(existingItem.getCartItemID(), newQuantity);
            if (!updated) {
                throw new Exception("Cập nhật số lượng thất bại. Vui lòng thử lại!");
            }
        } else {
            // chua co -> them moi
            boolean inserted = cartDAO.insertCartItem(cart.getCartId(), variantId, quantity);
            if (!inserted) {
                throw new Exception("Thêm sản phẩm vào giỏ hàng thất bại. Vui lòng thử lại!");
            }
        }
    }

    @Override
    public void updateQuantity(long customerId, long cartItemId, int quantity) throws Exception {
        if (quantity <= 0) {
            throw new Exception("Số lượng phải lớn hơn 0!");
        }

        boolean updated = cartDAO.updateCartItemQuantity(cartItemId, quantity);
        if (!updated) {
            throw new Exception("Cập nhật số lượng thất bại. Vui lòng thử lại!");
        }
    }

    @Override
    public void removeItem(long customerId, long cartItemId) throws Exception {
        boolean deleted = cartDAO.deleteCartItem(cartItemId);
        if (!deleted) {
            throw new Exception("Xóa sản phẩm khỏi giỏ hàng thất bại. Vui lòng thử lại!");
        }
    }
}
