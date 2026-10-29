package model;

import java.sql.Timestamp;

public class ReviewReport {
    public long reportId;
    public String reviewType;
    public long reviewId;
    public long reporterId;
    public String reason;
    public String reviewComment;
    public Integer reviewRating;
    public String reviewStatus;
    public String reviewerName;
    public String shopName;
    public String reporterName;
    public String status;
    public String moderationAction;
    public Long reviewedBy;
    public Timestamp createdAt;
    public Timestamp reviewedAt;
}
