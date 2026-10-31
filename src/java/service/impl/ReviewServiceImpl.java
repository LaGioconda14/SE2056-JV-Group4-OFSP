package service.impl;

import dao.ReviewDAO;
import dao.ShopDAO;
import java.util.List;
import java.util.Map;
import model.Review;
import model.Shop;
import service.INotificationService;
import service.IReviewService;

public class ReviewServiceImpl implements IReviewService {

    private final ReviewDAO reviewDAO;
    private final ShopDAO shopDAO;
    private final INotificationService notificationService;

    public ReviewServiceImpl() {
        this.reviewDAO = new ReviewDAO();
        this.shopDAO = new ShopDAO();
        this.notificationService = new NotificationServiceImpl();
    }

    public ReviewServiceImpl(ReviewDAO reviewDAO, ShopDAO shopDAO, INotificationService notificationService) {
        this.reviewDAO = reviewDAO;
        this.shopDAO = shopDAO;
        this.notificationService = notificationService;
    }

    @Override
    public List<Review> getReviewsByProductId(long productId, Integer starFilter, int page, int pageSize) {
        if (productId <= 0) return List.of();
        return reviewDAO.getReviewsByProductId(productId, starFilter, page, pageSize);
    }

    @Override
    public Map<String, Object> getRatingSummary(long productId) {
        if (productId <= 0) return Map.of();
        return reviewDAO.getRatingSummary(productId);
    }

    @Override
    public boolean canCustomerReview(long customerId, long orderItemId) {
        if (customerId <= 0 || orderItemId <= 0) return false;
        return reviewDAO.canCustomerReview(customerId, orderItemId);
    }

    @Override
    public long submitReview(long customerId, long orderItemId, long shopId, int rating, String comment, List<String> imageUrls) {
        if (customerId <= 0 || orderItemId <= 0 || rating < 1 || rating > 5) {
            return -1;
        }

        if (!reviewDAO.canCustomerReview(customerId, orderItemId)) {
            return -2;
        }

        Review r = new Review();
        r.setCustomerId(customerId);
        r.setOrderItemId(orderItemId);
        r.setShopId(shopId);
        r.setRating(rating);
        r.setComment(comment != null ? comment.trim() : "");

        long reviewId = reviewDAO.insertReview(r, imageUrls);
        if (reviewId > 0) {
            try {
                Shop shop = shopDAO.getShopById(shopId);
                if (shop != null && shop.getOwnerId() > 0) {
                    Map<String, Object> item = reviewDAO.getOrderItemForReview(customerId, orderItemId);
                    String prodName = item != null ? (String) item.get("productName") : "sản phẩm";
                    notificationService.notifyNewReview(shop.getOwnerId(), prodName, rating, reviewId);
                }
            } catch (Exception ignored) {
            }
        }
        return reviewId;
    }

    @Override
    public List<Review> getReviewsByShop(long shopId, String tab, int page, int pageSize) {
        if (shopId <= 0) return List.of();
        return reviewDAO.getReviewsByShop(shopId, tab, page, pageSize);
    }

    @Override
    public int countReviewsByShop(long shopId, String tab) {
        if (shopId <= 0) return 0;
        return reviewDAO.countReviewsByShop(shopId, tab);
    }

    @Override
    public boolean replyReview(long shopId, long reviewId, String replyComment) {
        if (shopId <= 0 || reviewId <= 0 || replyComment == null || replyComment.trim().isEmpty()) {
            return false;
        }

        boolean updated = reviewDAO.replyReview(shopId, reviewId, replyComment.trim());
        if (updated) {
            try {
                Review rev = reviewDAO.getReviewById(reviewId);
                if (rev != null && rev.getCustomerId() > 0) {
                    Shop shop = shopDAO.getShopById(shopId);
                    String shopName = shop != null ? shop.getShopName() : "Gian hàng";
                    String prodName = rev.getProductName() != null ? rev.getProductName() : "nông sản";
                    notificationService.notifyReviewReply(rev.getCustomerId(), shopName, prodName, rev.getProductId());
                }
            } catch (Exception ignored) {
            }
        }
        return updated;
    }

    @Override
    public Map<String, Object> getOrderItemForReview(long customerId, long orderItemId) {
        if (customerId <= 0 || orderItemId <= 0) return null;
        return reviewDAO.getOrderItemForReview(customerId, orderItemId);
    }

    @Override
    public Review getReviewById(long reviewId) {
        if (reviewId <= 0) return null;
        return reviewDAO.getReviewById(reviewId);
    }
}

