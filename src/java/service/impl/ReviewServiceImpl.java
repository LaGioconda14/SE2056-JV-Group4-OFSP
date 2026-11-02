package service.impl;

import dao.ReviewDAO;
import java.sql.SQLException;
import java.util.List;
import model.Review;
import model.ReviewReport;
import model.ReviewSummary;
import service.IReviewService;

public class ReviewServiceImpl implements IReviewService {
    private final ReviewDAO dao;
    private static final int PAGE_SIZE=15;

    public ReviewServiceImpl() { this(new ReviewDAO()); }
    public ReviewServiceImpl(ReviewDAO dao) { this.dao=dao; }

    private static String type(String type) {
        if(type==null)throw new IllegalArgumentException("Review type is required (PRODUCT or SHOP)");
        String value=type.trim().toUpperCase(java.util.Locale.ROOT);
        if(!"PRODUCT".equals(value)&&!"SHOP".equals(value))
            throw new IllegalArgumentException("Review type must be PRODUCT or SHOP");
        return value;
    }
    private static void positive(long id) {
        if(id<=0)throw new IllegalArgumentException("ID must be positive");
    }
    private static String checkedComment(String comment) {
        String value=comment==null?"":comment.trim();
        if(value.length()>2000)throw new IllegalArgumentException("Review text must be at most 2000 characters");
        return value;
    }
    private static void rating(int rating) {
        if(rating<1||rating>5)throw new IllegalArgumentException("Rating must be between 1 and 5");
    }
    private static int offset(int page) {
        if(page<1||page>100000)throw new IllegalArgumentException("Page must be between 1 and 100000");
        return (page-1)*PAGE_SIZE;
    }

    @Override public boolean canReview(String type,long customerId,long purchaseRef)throws SQLException {
        positive(customerId);positive(purchaseRef);
        return "PRODUCT".equals(type(type))
            ?dao.canReviewProduct(customerId,purchaseRef):dao.canReviewShop(customerId,purchaseRef);
    }
    @Override public long create(String type,long customerId,long purchaseRef,int stars,String comment)throws SQLException {
        String t=type(type);positive(customerId);positive(purchaseRef);rating(stars);
        String c=checkedComment(comment);
        return "PRODUCT".equals(t)
                ?dao.createProductReview(customerId,purchaseRef,stars,c)
                :dao.createShopReview(customerId,purchaseRef,stars,c);
    }
    @Override public void update(String type,long customerId,long reviewId,int stars,String comment)throws SQLException {
        String t=type(type);positive(customerId);positive(reviewId);rating(stars);
        if(!dao.updateReview(t,customerId,reviewId,stars,checkedComment(comment)))
            throw new SecurityException("Review not found or you are not its author");
    }
    @Override public void delete(String type,long customerId,long reviewId)throws SQLException {
        String t=type(type);positive(customerId);positive(reviewId);
        if(!dao.deleteReview(t,customerId,reviewId))
            throw new SecurityException("Review not found or you are not its author");
    }
    @Override public List<Review> listPublic(String type,long targetId,int page)throws SQLException {
        String t=type(type);positive(targetId);
        return dao.listPublic(t,targetId,PAGE_SIZE,offset(page));
    }
    @Override public List<Review> listMine(String type,long customerId,int page)throws SQLException {
        String t=type(type);positive(customerId);
        return dao.listMine(t,customerId,PAGE_SIZE,offset(page));
    }
    @Override public ReviewSummary summary(String type,long targetId)throws SQLException {
        String t=type(type);positive(targetId);
        return dao.summary(t,targetId);
    }
    @Override public long report(String type,long reviewId,long reporterId,String reason)throws SQLException {
        String t=type(type);positive(reviewId);positive(reporterId);
        String r=reason==null?"":reason.trim();
        if(r.length()<10||r.length()>500)
            throw new IllegalArgumentException("Report reason must contain 10 to 500 characters");
        return dao.reportReview(t,reviewId,reporterId,r);
    }
    @Override public List<ReviewReport> pendingReports(int page)throws SQLException {
        return dao.listReports(PAGE_SIZE,offset(page));
    }
    @Override public void moderate(long reportId,long adminId,String action)throws SQLException {
        positive(reportId);positive(adminId);
        String normalized=action==null?"":action.trim().toUpperCase(java.util.Locale.ROOT);
        if(!("APPROVE".equals(normalized)||"REJECT".equals(normalized)
                ||"HIDE".equals(normalized)||"REMOVE".equals(normalized)))
            throw new IllegalArgumentException("Action must be APPROVE, REJECT, HIDE or REMOVE");
        if(!dao.moderate(reportId,adminId,normalized))
            throw new IllegalArgumentException("Report does not exist or was already moderated");
    }
}
