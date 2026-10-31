package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import enums.ApprovalStatus;
import enums.AvailabilityStatus;

/**
 * Model representing Driver Partner Profile, KYC & Vehicle Equipment,
 * Working State, Approval Lifecycle, Real-time GPS location, and Shop affiliation.
 */
public class DriverProfile implements Serializable {

    private static final long serialVersionUID = 1L;

    // Primary keys & User linkage
    private long driverId;
    private long userId;
    private Long shopId;
    private String shopName;
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
        this.approvalStatus = ApprovalStatus.APPROVED.name();
        this.availabilityStatus = AvailabilityStatus.AVAILABLE.name();
        this.rating = BigDecimal.valueOf(5.0);
        this.maxCapacityOrders = 5;
    }

    // Helper status checks
    public boolean isApproved() {
        return ApprovalStatus.APPROVED.name().equalsIgnoreCase(approvalStatus);
    }

    public boolean isPending() {
        return ApprovalStatus.PENDING.name().equalsIgnoreCase(approvalStatus);
    }

    public boolean isNeedsRevision() {
        return ApprovalStatus.NEEDS_REVISION.name().equalsIgnoreCase(approvalStatus)
                || ApprovalStatus.REJECTED.name().equalsIgnoreCase(approvalStatus);
    }

    public boolean isAvailable() {
        return AvailabilityStatus.AVAILABLE.name().equalsIgnoreCase(availabilityStatus);
    }

    public boolean isBusy() {
        return AvailabilityStatus.BUSY.name().equalsIgnoreCase(availabilityStatus);
    }

    public boolean isOffline() {
        return AvailabilityStatus.OFFLINE.name().equalsIgnoreCase(availabilityStatus);
    }

    public boolean isOnline() {
        return AvailabilityStatus.AVAILABLE.name().equalsIgnoreCase(availabilityStatus)
                || AvailabilityStatus.BUSY.name().equalsIgnoreCase(availabilityStatus);
    }

    public void setOnline(boolean online) {
        this.availabilityStatus = online ? AvailabilityStatus.AVAILABLE.name() : AvailabilityStatus.OFFLINE.name();
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
        if (ApprovalStatus.APPROVED.name().equalsIgnoreCase(approvalStatus)) {
            return "bg-success-subtle text-success border border-success-subtle";
        } else if (ApprovalStatus.PENDING.name().equalsIgnoreCase(approvalStatus)) {
            return "bg-warning-subtle text-warning border border-warning-subtle";
        } else {
            return "bg-danger-subtle text-danger border border-danger-subtle";
        }
    }

    public String getApprovalStatusLabel() {
        if (ApprovalStatus.APPROVED.name().equalsIgnoreCase(approvalStatus)) {
            return "Đã duyệt & Sẵn sàng hoạt động";
        } else if (ApprovalStatus.PENDING.name().equalsIgnoreCase(approvalStatus)) {
            return "Đang chờ Admin duyệt";
        } else if (ApprovalStatus.NEEDS_REVISION.name().equalsIgnoreCase(approvalStatus)) {
            return "Cần bổ sung hồ sơ";
        } else if (ApprovalStatus.REJECTED.name().equalsIgnoreCase(approvalStatus)) {
            return "Hồ sơ bị từ chối";
        }
        return approvalStatus;
    }

    public String getAvailabilityBadgeClass() {
        if (isAvailable()) {
            return "bg-emerald-100 text-emerald-800 border-emerald-200";
        } else if (isBusy()) {
            return "bg-blue-100 text-blue-800 border-blue-200";
        } else {
            return "bg-slate-100 text-slate-600 border-slate-200";
        }
    }

    public String getAvailabilityLabel() {
        if (isAvailable()) {
            return "Sẵn sàng nhận đơn";
        } else if (isBusy()) {
            return "Đang đi giao hàng";
        } else {
            return "Tạm nghỉ / Offline";
        }
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

    public Long getShopId() {
        return shopId;
    }

    public void setShopId(Long shopId) {
        this.shopId = shopId;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
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

    public ApprovalStatus getApprovalStatusEnum() {
        return ApprovalStatus.from(approvalStatus);
    }

    public void setApprovalStatus(ApprovalStatus status) {
        this.approvalStatus = status != null ? status.name() : ApprovalStatus.PENDING.name();
    }

    public String getAvailabilityStatus() {
        return availabilityStatus;
    }

    public void setAvailabilityStatus(String availabilityStatus) {
        this.availabilityStatus = availabilityStatus;
    }

    public AvailabilityStatus getAvailabilityStatusEnum() {
        return AvailabilityStatus.from(availabilityStatus);
    }

    public void setAvailabilityStatus(AvailabilityStatus status) {
        this.availabilityStatus = status != null ? status.name() : AvailabilityStatus.OFFLINE.name();
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
