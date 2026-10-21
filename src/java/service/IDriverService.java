package service;

import java.util.List;
import model.DriverProfile;

public interface IDriverService {

    DriverProfile getDriverProfileByUserId(long userId);

    DriverProfile getDriverProfile(long driverId);

    List<DriverProfile> getAllDriverProfiles(String approvalStatus, String keyword);

    boolean autoDispatchSubOrder(long subOrderId);

    // Shop Delivery Staff (Shippers) Management
    List<DriverProfile> getDriversByShopId(long shopId, String statusFilter, String keyword);

    List<DriverProfile> getAvailableDriversByShopId(long shopId);

    boolean createShopShipper(long shopId, String fullName, String email, String phone, String password,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts);

    boolean updateShopShipper(long driverId, long shopId, String fullName, String phone,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts, String availabilityStatus);

    boolean toggleShipperStatus(long driverId, long shopId, String newStatus);

    boolean deleteShopShipper(long driverId, long shopId);

    boolean assignDriverToSubOrder(long subOrderId, long driverUserId);
}
