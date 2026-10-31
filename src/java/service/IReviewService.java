package service;

import java.util.List;
import java.util.Map;
import model.Review;

public interface IReviewService {

    List<Review> getReviewsByProductId(long productId, Integer starFilter, int page, int pageSize);

    Map<String, Object> getRatingSummary(long productId);

    boolean canCustomerReview(long customerId, long orderItemId);

    long submitReview(long customerId, long orderItemId, long shopId, int rating, String comment, List<String> imageUrls);

    List<Review> getReviewsByShop(long shopId, String tab, int page, int pageSize);

    int countReviewsByShop(long shopId, String tab);

    boolean replyReview(long shopId, long reviewId, String replyComment);

    Map<String, Object> getOrderItemForReview(long customerId, long orderItemId);

    Review getReviewById(long reviewId);
}

