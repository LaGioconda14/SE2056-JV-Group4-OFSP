package util;

import dao.ShopDAO;
import jakarta.servlet.http.HttpSession;
import model.Shop;

/**
 * Tiện ích dùng chung cho luồng đăng ký / đăng nhập của người bán (seller).
 */
public final class SellerSessionUtil {

    private SellerSessionUtil() {
    }

    /** Nạp thông tin gian hàng của chủ shop vào session (shopId, shopName, shopLogo...). */
    public static void initShopSession(HttpSession session, long ownerId) {
        try {
            Shop shop = new ShopDAO().getShopByOwnerId(ownerId);
            if (shop != null) {
                session.setAttribute("shopId", shop.getShopId());
                session.setAttribute("shopName", shop.getShopName());
                session.setAttribute("shopLogo", shop.getLogoUrl());
                session.setAttribute("shopObj", shop);
                session.setAttribute("shopStatus", shop.getStatus());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Hồ sơ đang chờ admin duyệt (PENDING hoặc PENDING_KYC theo cách admin đang xử lý). */
    public static boolean isPending(String status) {
        return "PENDING".equalsIgnoreCase(status) || "PENDING_KYC".equalsIgnoreCase(status);
    }

    public static boolean isApproved(String status) {
        return "APPROVED".equalsIgnoreCase(status);
    }

    public static boolean isRejected(String status) {
        return "REJECTED".equalsIgnoreCase(status);
    }
}
