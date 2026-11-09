package service;

import model.entity.shop.ShopRequest;

public interface IShopRequestService {
    boolean submitShopRequest(ShopRequest request);

    /** Hồ sơ đăng ký bán hàng mới nhất của user (null nếu chưa từng đăng ký). */
    ShopRequest getLatestRequestByUserId(int userId);
}
