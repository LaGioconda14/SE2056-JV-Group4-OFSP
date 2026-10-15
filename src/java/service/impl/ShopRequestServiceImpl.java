package service.impl;

import dao.ShopRequestDAO;
import model.ShopRequest;
import service.IShopRequestService;

public class ShopRequestServiceImpl implements IShopRequestService {

    private ShopRequestDAO shopRequestDAO = new ShopRequestDAO();

    @Override
    public boolean submitShopRequest(ShopRequest request) {
        // Có thể bổ sung validate dữ liệu ở đây nếu cần
        return shopRequestDAO.insertShopRequest(request);
    }
}