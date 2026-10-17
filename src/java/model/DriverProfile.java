package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Model representing Driver Partner Profile, KYC & Vehicle Equipment,
 * Working State, Approval Lifecycle, and real-time GPS location.
 */
public class DriverProfile implements Serializable {

    private static final long serialVersionUID = 1L;

    // Primary keys & User linkage
    private long driverId;
    private long userId;
    private String fullName;
    private String email;
    private String phone;
    private String avatarUrl;

    // Vehicle & Cold Chain KYC
    private String licenseNumber;
    private String vehicleType;
    private String vehiclePlate;
    private String coldStorageType;
    private String operatingCity;
    private String operatingDistricts;
    private String hubName;

    // Approval & Availability State
    private String approvalStatus;      // PENDING, APPROVED, REJECTED, NEEDS_REVISION
    private String availabilityStatus;  // OFFLINE, AVAILABLE, BUSY
    private Long reviewedBy;
    private String reviewerName;
    private Timestamp reviewedAt;
    private String rejectionReason;

    // Performance & Capacity
    private BigDecimal rating;
    private int totalTrips;
    private int maxCapacityOrders;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // GPS & Live Location
    private Double latitude;
    private Double longitude;
    private Timestamp lastUpdatedAt;

    // Dynamic metrics
    private int activeOrderCount;

    public DriverProfile() {
        this.approvalStatus = "PENDING";
        this.availabilityStatus = "OFFLINE";
        this.rating = BigDecimal.valueOf(5.0);
        this.maxCapacityOrders = 5;
    }

    // Helper status checks
    public boolean isApproved() {
        return "APPROVED".equalsIgnoreCase(approvalStatus);
    }

    public boolean isPending() {
        return "PENDING".equalsIgnoreCase(approvalStatus);
    }

    public boolean isNeedsRevision() {
        return "NEEDS_REVISION".equalsIgnoreCase(approvalStatus) || "REJECTED".equalsIgnoreCase(approvalStatus);
    }

    public boolean isAvailable() {
        return "AVAILABLE".equalsIgnoreCase(availabilityStatus);
    }

    public boolean isOnline() {
        return "AVAILABLE".equalsIgnoreCase(availabilityStatus) || "BUSY".equalsIgnoreCase(availabilityStatus);
    }

    public void setOnline(boolean online) {
        this.availabilityStatus = online ? "AVAILABLE" : "OFFLINE";
    }

    public boolean isGpsFresh() {
        if (lastUpdatedAt == null) {
            return false;
        }
        long now = System.currentTimeMillis();
        long diff = now - lastUpdatedAt.getTime();
        return diff <= (15 * 60 * 1000); // 15 minutes
    }

    public boolean canAcceptMoreOrders() {
        return isApproved() && isAvailable() && (activeOrderCount < maxCapacityOrders);
    }

    public String getApprovalBadgeClass() {
        if ("APPROVED".equalsIgnoreCase(approvalStatus)) {
            return "bg-success-subtle text-success border border-success-subtle";
        } else if ("PENDING".equalsIgnoreCase(approvalStatus)) {
            return "bg-warning-subtle text-warning border border-warning-subtle";
        } else {
            return "bg-danger-subtle text-danger border border-danger-subtle";
        }
    }

    public String getApprovalStatusLabel() {
        if ("APPROVED".equalsIgnoreCase(approvalStatus)) {
            return "Đã duyệt & Sẵn sàng hoạt động";
        } else if ("PENDING".equalsIgnoreCase(approvalStatus)) {
            return "Đang chờ Admin duyệt";
        } else if ("NEEDS_REVISION".equalsIgnoreCase(approvalStatus)) {
            return "Cần bổ sung hồ sơ";
        } else if ("REJECTED".equalsIgnoreCase(approvalStatus)) {
            return "Hồ sơ bị từ chối";
        }
        return approvalStatus;
    }

    // Backwards compatibility getters
    public String getLicensePlate() {
        return vehiclePlate;
    }

    public void setLicensePlate(String licensePlate) {
        this.vehiclePlate = licensePlate;
    }

    public String getColdBoxType() {
        return coldStorageType;
    }

    public void setColdBoxType(String coldBoxType) {
        this.coldStorageType = coldBoxType;
    }

    public String getOperatingDistrict() {
        return operatingDistricts;
    }

    public void setOperatingDistrict(String operatingDistrict) {
        this.operatingDistricts = operatingDistrict;
    }

    public Timestamp getLocationUpdatedAt() {
        return lastUpdatedAt;
    }

    public void setLocationUpdatedAt(Timestamp locationUpdatedAt) {
        this.lastUpdatedAt = locationUpdatedAt;
    }

    // Standard Getters and Setters
    public long getDriverId() {
        return driverId;
    }

    public void setDriverId(long driverId) {
        this.driverId = driverId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getLicenseNumber() {
        return licenseNumber;
    }

    public void setLicenseNumber(String licenseNumber) {
        this.licenseNumber = licenseNumber;
    }

    public String getVehicleType() {
        return vehicleType;
    }

    public void setVehicleType(String vehicleType) {
        this.vehicleType = vehicleType;
    }

    public String getVehiclePlate() {
        return vehiclePlate;
    }

    public void setVehiclePlate(String vehiclePlate) {
        this.vehiclePlate = vehiclePlate;
    }

    public String getColdStorageType() {
        return coldStorageType;
    }

    public void setColdStorageType(String coldStorageType) {
        this.coldStorageType = coldStorageType;
    }

    public String getOperatingCity() {
        return operatingCity;
    }

    public void setOperatingCity(String operatingCity) {
        this.operatingCity = operatingCity;
    }

    public String getOperatingDistricts() {
        return operatingDistricts;
    }

    public void setOperatingDistricts(String operatingDistricts) {
        this.operatingDistricts = operatingDistricts;
    }

    public String getHubName() {
        return hubName;
    }

    public void setHubName(String hubName) {
        this.hubName = hubName;
    }

    public String getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    public String getAvailabilityStatus() {
        return availabilityStatus;
    }

    public void setAvailabilityStatus(String availabilityStatus) {
        this.availabilityStatus = availabilityStatus;
    }

    public Long getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Long reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }

    public Timestamp getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(Timestamp reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public BigDecimal getRating() {
        return rating;
    }

    public void setRating(BigDecimal rating) {
        this.rating = rating;
    }

    public int getTotalTrips() {
        return totalTrips;
    }

    public void setTotalTrips(int totalTrips) {
        this.totalTrips = totalTrips;
    }

    public int getMaxCapacityOrders() {
        return maxCapacityOrders;
    }

    public void setMaxCapacityOrders(int maxCapacityOrders) {
        this.maxCapacityOrders = maxCapacityOrders;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Timestamp getLastUpdatedAt() {
        return lastUpdatedAt;
    }

    public void setLastUpdatedAt(Timestamp lastUpdatedAt) {
        this.lastUpdatedAt = lastUpdatedAt;
    }

    public int getActiveOrderCount() {
        return activeOrderCount;
    }

    public void setActiveOrderCount(int activeOrderCount) {
        this.activeOrderCount = activeOrderCount;
    }
}
