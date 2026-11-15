package service;

import java.util.List;
import java.util.Map;
import model.entity.review.Review;
import model.dto.review.ReviewSummary;

public interface IReviewService {

    boolean canReviewOrderItem(long customerId, long orderItemId);

    long createReview(long customerId, long orderItemId, int rating, String comment) throws Exception;

    List<Review> getReviewsByProduct(long productId, int page, int pageSize);

    ReviewSummary getReviewSummary(long productId);

    List<Review> getReviewsByCustomer(long customerId);

    List<Review> getReviewsByShop(long shopId, int page, int pageSize);

    List<Review> getReviewsByShop(long shopId, Integer rating, String replyStatus, String keyword, int page, int pageSize);

    int countReviewsByShop(long shopId, Integer rating, String replyStatus, String keyword);

    Map<String, Object> getShopReviewStats(long shopId);

    boolean replyReview(long reviewId, long shopId, String replyComment);

    boolean updateReviewStatus(long reviewId, String status);
}
