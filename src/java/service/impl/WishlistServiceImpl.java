package service.impl;

import dao.WishlistDAO;
import java.util.List;
import java.util.Set;
import model.Product;
import service.IWishlistService;

public class WishlistServiceImpl implements IWishlistService {

    private final WishlistDAO wishlistDAO = new WishlistDAO();

    @Override
    public boolean toggle(long userId, long productId) {
        if (productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ!");
        }
        if (wishlistDAO.exists(userId, productId)) {
            wishlistDAO.remove(userId, productId);
            return false;
        }
        if (!wishlistDAO.add(userId, productId)) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại hoặc đã ngừng bán!");
        }
        return true;
    }

    @Override
    public void remove(long userId, long productId) {
        if (productId <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ!");
        }
        wishlistDAO.remove(userId, productId);
    }

    @Override
    public Set<Long> getProductIds(long userId) {
        return wishlistDAO.getProductIds(userId);
    }

    @Override
    public List<Product> getProducts(long userId) {
        return wishlistDAO.getProducts(userId);
    }

    @Override
    public int count(long userId) {
        return wishlistDAO.count(userId);
    }
}
