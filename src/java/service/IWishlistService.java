package service;

import java.util.List;
import java.util.Set;
import model.Product;

public interface IWishlistService {

    /**
     * Bấm trái tim: chưa thích thì thêm, đã thích thì bỏ.
     *
     * @return true nếu sau thao tác sản phẩm đang được yêu thích
     * @throws IllegalArgumentException nếu sản phẩm không tồn tại / ngừng bán
     */
    boolean toggle(long userId, long productId);

    /** Xóa sản phẩm khỏi danh sách yêu thích. */
    void remove(long userId, long productId);

    /** Id các sản phẩm user đã thích (để tô sáng trái tim). */
    Set<Long> getProductIds(long userId);

    /** Sản phẩm yêu thích, mới thêm lên đầu. */
    List<Product> getProducts(long userId);

    int count(long userId);
}
