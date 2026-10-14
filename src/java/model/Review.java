package model;

import java.sql.Timestamp;

public class Review {
    private long reviewId;
    private long orderItemId;
    private long customerId;
    private String customerName;
    private String customerAvatar;
    private long shopId;
    private int rating;
    private String comment;
    private String replyComment;
    private String productName;
    private String timeAgo;
    private Timestamp createdAt;
    private boolean verifiedBuyer;

    public Review() {
        this.verifiedBuyer = true;
    }

    public Review(long reviewId, long customerId, String customerName, String customerAvatar, 
                  long shopId, int rating, String comment, String productName, String timeAgo) {
        this.reviewId = reviewId;
        this.customerId = customerId;
        this.customerName = customerName;
        this.customerAvatar = customerAvatar;
        this.shopId = shopId;
        this.rating = rating;
        this.comment = comment;
        this.productName = productName;
        this.timeAgo = timeAgo;
        this.verifiedBuyer = true;
    }

    public long getReviewId() { return reviewId; }
    public void setReviewId(long reviewId) { this.reviewId = reviewId; }

    public long getOrderItemId() { return orderItemId; }
    public void setOrderItemId(long orderItemId) { this.orderItemId = orderItemId; }

    public long getCustomerId() { return customerId; }
    public void setCustomerId(long customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerAvatar() { return customerAvatar; }
    public void setCustomerAvatar(String customerAvatar) { this.customerAvatar = customerAvatar; }

    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public String getReplyComment() { return replyComment; }
    public void setReplyComment(String replyComment) { this.replyComment = replyComment; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getTimeAgo() { return timeAgo; }
    public void setTimeAgo(String timeAgo) { this.timeAgo = timeAgo; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isVerifiedBuyer() { return verifiedBuyer; }
    public void setVerifiedBuyer(boolean verifiedBuyer) { this.verifiedBuyer = verifiedBuyer; }
}

