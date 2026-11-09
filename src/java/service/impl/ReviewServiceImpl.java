package service.impl;

import dao.ReviewDAO;
import java.util.List;
import model.entity.review.Review;
import model.dto.review.ReviewSummary;
import service.IReviewService;

public class ReviewServiceImpl implements IReviewService {

    private final ReviewDAO reviewDAO;

    public ReviewServiceImpl() {
        this.reviewDAO = new ReviewDAO();
    }

    public ReviewServiceImpl(ReviewDAO reviewDAO) {
        this.reviewDAO = reviewDAO;
    }

    @Override
    public boolean canReviewOrderItem(long customerId, long orderItemId) {
        return reviewDAO.canReviewOrderItem(customerId, orderItemId);
    }

    @Override
    public long createReview(long customerId, long orderItemId, int rating, String comment) throws Exception {
        return reviewDAO.createReview(customerId, orderItemId, rating, comment);
    }

    @Override
    public List<Review> getReviewsByProduct(long productId, int page, int pageSize) {
        return reviewDAO.getReviewsByProduct(productId, page, pageSize);
    }

    @Override
    public ReviewSummary getReviewSummary(long productId) {
        return reviewDAO.getReviewSummary(productId);
    }

    @Override
    public List<Review> getReviewsByCustomer(long customerId) {
        return reviewDAO.getReviewsByCustomer(customerId);
    }

    @Override
    public List<Review> getReviewsByShop(long shopId, int page, int pageSize) {
        return reviewDAO.getReviewsByShop(shopId, page, pageSize);
    }

    @Override
    public boolean replyReview(long reviewId, long shopId, String replyComment) {
        return reviewDAO.replyReview(reviewId, shopId, replyComment);
    }

    @Override
    public boolean updateReviewStatus(long reviewId, String status) {
        return reviewDAO.updateReviewStatus(reviewId, status);
    }
}
