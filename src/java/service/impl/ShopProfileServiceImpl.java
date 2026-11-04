package service.impl;

import dao.ShopDAO;
import dao.ShopRequestDAO;
import dao.UserDAO;
import model.Shop;
import model.ShopRequest;
import model.User;
import service.IShopProfileService;

/** DAO access for shop profile operations. */
public class ShopProfileServiceImpl implements IShopProfileService {
    private final ShopRequestDAO shopRequestDAO = new ShopRequestDAO();
    private final ShopDAO shopDAO = new ShopDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    public ShopRequest getShopRequestByUserId(int userId) { return shopRequestDAO.getShopRequestByUserId(userId); }
    @Override
    public Shop getShopByOwnerId(long ownerId) { return shopDAO.getShopByOwnerId(ownerId); }
    @Override
    public User getOwnerById(int userId) { return userDAO.findById(userId); }
    @Override
    public boolean updateShopProfile(ShopRequest shopRequest) { return shopRequestDAO.updateShopProfile(shopRequest); }
    @Override
    public boolean updateBirthDate(int userId, java.sql.Date birthDate) { return userDAO.updateBirthDate(userId, birthDate); }
    @Override
    public boolean updateShopMedia(long ownerId, String logoUrl, String bannerUrl) { return shopDAO.updateShopMedia(ownerId, logoUrl, bannerUrl); }
    @Override
    public boolean updateShopStatus(long ownerId, String newStatus) { return shopDAO.updateShopStatusBySeller(ownerId, newStatus); }
}
