package service;

import java.util.List;
import model.entity.delivery.DriverProfile;

public interface IDriverService {

    DriverProfile getDriverProfileByUserId(long userId);


    // Shop Delivery Staff (Shippers) Management
    List<DriverProfile> getDriversByShopId(long shopId, String statusFilter, String keyword);

    boolean createShopShipper(long shopId, String fullName, String email, String phone, String password,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts);

    boolean updateShopShipper(long driverId, long shopId, String fullName, String phone,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts, String availabilityStatus);

    boolean toggleShipperStatus(long driverId, long shopId, String newStatus);

    boolean deleteShopShipper(long driverId, long shopId);

    boolean assignDriverToSubOrder(long subOrderId, long driverUserId);
}
