package model.dto.order;

import enums.DeliveryStatus;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Data Transfer Object chứa thông tin giao vận và tài xế được JOIN từ bảng deliveries, users và driver_profiles.
 */
public class DeliveryDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long deliveryId;
    private String trackingNumber;
    private String deliveryStatus;
    private String failureReason;
    private String proofImageUrl;
    private Timestamp assignedAt;
    private Timestamp deliveredAt;

    private Long driverId;
    private String driverName;
    private String driverPhone;
    private String driverVehiclePlate;
    private String driverVehicleType;
    private String driverAvatarUrl;

    public DeliveryDTO() {
    }

    public Long getDeliveryId() {
        return deliveryId;
    }

    public void setDeliveryId(Long deliveryId) {
        this.deliveryId = deliveryId;
    }

    public String getTrackingNumber() {
        return trackingNumber;
    }

    public void setTrackingNumber(String trackingNumber) {
        this.trackingNumber = trackingNumber;
    }

    public String getDeliveryStatus() {
        return deliveryStatus;
    }

    public void setDeliveryStatus(String deliveryStatus) {
        this.deliveryStatus = deliveryStatus;
    }

    public DeliveryStatus getDeliveryStatusEnum() {
        return DeliveryStatus.from(deliveryStatus);
    }

    public void setDeliveryStatus(DeliveryStatus deliveryStatus) {
        this.deliveryStatus = deliveryStatus != null ? deliveryStatus.name() : null;
    }

    public String getFailureReason() {
        return failureReason;
    }

    public void setFailureReason(String failureReason) {
        this.failureReason = failureReason;
    }

    public String getProofImageUrl() {
        return proofImageUrl;
    }

    public void setProofImageUrl(String proofImageUrl) {
        this.proofImageUrl = proofImageUrl;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }

    public Timestamp getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(Timestamp deliveredAt) {
        this.deliveredAt = deliveredAt;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getDriverPhone() {
        return driverPhone;
    }

    public void setDriverPhone(String driverPhone) {
        this.driverPhone = driverPhone;
    }

    public String getDriverVehiclePlate() {
        return driverVehiclePlate;
    }

    public void setDriverVehiclePlate(String driverVehiclePlate) {
        this.driverVehiclePlate = driverVehiclePlate;
    }

    public String getDriverVehicleType() {
        return driverVehicleType;
    }

    public void setDriverVehicleType(String driverVehicleType) {
        this.driverVehicleType = driverVehicleType;
    }

    public String getDriverAvatarUrl() {
        return driverAvatarUrl;
    }

    public void setDriverAvatarUrl(String driverAvatarUrl) {
        this.driverAvatarUrl = driverAvatarUrl;
    }
}
