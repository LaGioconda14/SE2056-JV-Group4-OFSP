package model;

/** One delivered order item/sub-order eligible for a customer review. */
public class ReviewPurchase {
    public String type;
    public long purchaseRef;
    public long targetId;
    public long shopId;
    public String productName;
    public String shopName;
    public String thumbnailUrl;
    public String orderCode;
    public boolean canReview;
    public Long existingReviewId;
}
