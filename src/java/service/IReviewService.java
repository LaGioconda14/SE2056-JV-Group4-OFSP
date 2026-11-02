package service;

import java.util.List;
import model.Review;
import model.ReviewSummary;

public interface IReviewService {

    boolean canReviewOrderItem(long customerId, long orderItemId);

    long createReview(long customerId, long orderItemId, int rating, String comment) throws Exception;

    List<Review> getReviewsByProduct(long productId, int page, int pageSize);

    ReviewSummary getReviewSummary(long productId);

    List<Review> getReviewsByCustomer(long customerId);

    List<Review> getReviewsByShop(long shopId, int page, int pageSize);

    boolean replyReview(long reviewId, long shopId, String replyComment);

    boolean updateReviewStatus(long reviewId, String status);
}
