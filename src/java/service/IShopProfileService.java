package service;

import model.entity.shop.Shop;
import model.entity.shop.ShopRequest;
import model.entity.user.User;

/** Service boundary for viewing and updating a shop owner's profile. */
public interface IShopProfileService {
    ShopRequest getShopRequestByUserId(int userId);
    Shop getShopByOwnerId(long ownerId);
    User getOwnerById(int userId);
    boolean updateShopProfile(ShopRequest shopRequest);
    boolean updateBirthDate(int userId, java.sql.Date birthDate);
    boolean updateShopMedia(long ownerId, String logoUrl, String bannerUrl);
    boolean updateShopStatus(long ownerId, String newStatus);
}
