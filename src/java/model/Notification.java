package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    private long notificationId;
    private long userId;
    private String title;
    private String message;
    private String type = "ORDER";
    private String referenceType;
    private Long referenceId;
    private boolean isRead = false;
    private Timestamp createdAt;

    public Notification() {
    }

    public Notification(long notificationId, long userId, String title, String message, String type,
                        String referenceType, Long referenceId, boolean isRead, Timestamp createdAt) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.isRead = isRead;
        this.createdAt = createdAt;
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

    public void setRead(boolean read) {
        isRead = read;
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
        long minutes = diff / (60 * 1000L);
        if (minutes < 1) return "Vừa xong";
        if (minutes < 60) return minutes + " phút trước";
        long hours = minutes / 60;
        if (hours < 24) return hours + " giờ trước";
        long days = hours / 24;
        return days + " ngày trước";
    }

    public String getIconClass() {
        if (type == null) return "bi-bell";
        return switch (type.toUpperCase()) {
            case "ORDER" -> "bi-box-seam text-emerald-600";
            case "KYC" -> "bi-shield-check text-blue-600";
            case "DISPUTE" -> "bi-exclamation-triangle text-rose-600";
            case "PROMOTION" -> "bi-tag text-amber-600";
            default -> "bi-bell text-emerald-600";
        };
    }
}
