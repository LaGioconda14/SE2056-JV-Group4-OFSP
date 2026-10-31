package service.impl;

import dao.ShopRequestDAO;
import model.ShopRequest;
import service.IShopRequestService;

public class ShopRequestServiceImpl implements IShopRequestService {

    private final ShopRequestDAO shopRequestDAO = new ShopRequestDAO();

    @Override
    public boolean submitShopRequest(ShopRequest request) {
        return shopRequestDAO.insertShopRequest(request);
    }

    @Override
    public ShopRequest getLatestRequestByUserId(int userId) {
        return shopRequestDAO.getLatestRequestByUserId(userId);
    }
}
