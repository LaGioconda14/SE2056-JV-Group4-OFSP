package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    private long notificationId;
    private long userId;
    private String title;
    private String message;
    private String type;
    private String referenceType;
    private Long referenceId;
    private boolean isRead;
    private Timestamp createdAt;

    public Notification() {
    }

    public Notification(long userId, String title, String message, String type, String referenceType, Long referenceId) {
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type != null ? type : "SYSTEM";
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.isRead = false;
    }

    public long getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(long notificationId) {
        this.notificationId = notificationId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReferenceType() {
        return referenceType;
    }

    public void setReferenceType(String referenceType) {
        this.referenceType = referenceType;
    }

    public Long getReferenceId() {
        return referenceId;
    }

    public void setReferenceId(Long referenceId) {
        this.referenceId = referenceId;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean isRead) {
        this.isRead = isRead;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getTimeAgo() {
        if (createdAt == null) return "Vừa xong";
        long diff = System.currentTimeMillis() - createdAt.getTime();
        long seconds = diff / 1000;
        if (seconds < 60) return "Vừa xong";
        long minutes = seconds / 60;
        if (minutes < 60) return minutes + " phút trước";
        long hours = minutes / 60;
        if (hours < 24) return hours + " giờ trước";
        long days = hours / 24;
        if (days < 30) return days + " ngày trước";
        long months = days / 30;
        if (months < 12) return months + " tháng trước";
        return (months / 12) + " năm trước";
    }

    public String getTargetUrl() {
        return getTargetUrl("");
    }

    public String getTargetUrl(String contextPath) {
        String base = (contextPath != null) ? contextPath : "";
        if ("SUB_ORDER".equalsIgnoreCase(referenceType) || "ORDER".equalsIgnoreCase(referenceType)) {
            return base + "/order-detail?id=" + referenceId;
        } else if ("PRODUCT".equalsIgnoreCase(referenceType)) {
            return base + "/detail?id=" + referenceId + "#reviews";
        } else if ("REVIEW".equalsIgnoreCase(referenceType)) {
            return base + "/shop/reviews";
        } else if ("SHOP_REQUEST".equalsIgnoreCase(referenceType)) {
            return base + "/seller/portal";
        } else if ("INVENTORY".equalsIgnoreCase(referenceType)) {
            return base + "/shop/inventory";
        }
        return base + "/profile?tab=notifications";
    }
}

