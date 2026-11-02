package service;

import java.sql.SQLException;
import java.util.List;
import model.Review;
import model.ReviewReport;
import model.ReviewSummary;

public interface IReviewService {
    boolean canReview(String type,long customerId,long purchaseRef) throws SQLException;
    long create(String type,long customerId,long purchaseRef,int rating,String comment) throws SQLException;
    void update(String type,long customerId,long reviewId,int rating,String comment) throws SQLException;
    void delete(String type,long customerId,long reviewId) throws SQLException;
    List<Review> listPublic(String type,long targetId,int page) throws SQLException;
    List<Review> listMine(String type,long customerId,int page) throws SQLException;
    ReviewSummary summary(String type,long targetId) throws SQLException;
    long report(String type,long reviewId,long reporterId,String reason) throws SQLException;
    List<ReviewReport> pendingReports(int page) throws SQLException;
    void moderate(long reportId,long adminId,String action) throws SQLException;
}
