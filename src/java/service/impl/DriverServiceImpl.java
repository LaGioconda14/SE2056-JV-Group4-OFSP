package service.impl;

import dao.DriverDAO;
import java.util.List;
import model.entity.delivery.DriverProfile;
import service.IDriverService;

public class DriverServiceImpl implements IDriverService {

    private final DriverDAO driverDAO;

    public DriverServiceImpl() {
        this.driverDAO = new DriverDAO();
    }

    public DriverServiceImpl(DriverDAO driverDAO) {
        this.driverDAO = driverDAO;
    }

    @Override
    public DriverProfile getDriverProfileByUserId(long userId) {
        return driverDAO.getDriverProfileByUserId(userId);
    }

    @Override
    public List<DriverProfile> getDriversByShopId(long shopId, String statusFilter, String keyword) {
        return driverDAO.getDriversByShopId(shopId, statusFilter, keyword);
    }

    @Override
    public boolean createShopShipper(long shopId, String fullName, String email, String phone, String password,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts) {
        return driverDAO.createShopShipper(shopId, fullName, email, phone, password, vehicleType, vehiclePlate, coldStorageType, operatingDistricts);
    }

    @Override
    public boolean updateShopShipper(long driverId, long shopId, String fullName, String phone,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts, String availabilityStatus) {
        return driverDAO.updateShopShipper(driverId, shopId, fullName, phone, vehicleType, vehiclePlate, coldStorageType, operatingDistricts, availabilityStatus);
    }

    @Override
    public boolean toggleShipperStatus(long driverId, long shopId, String newStatus) {
        return driverDAO.toggleShipperStatus(driverId, shopId, newStatus);
    }

    @Override
    public boolean deleteShopShipper(long driverId, long shopId) {
        return driverDAO.deleteShopShipper(driverId, shopId);
    }

    @Override
    public boolean assignDriverToSubOrder(long subOrderId, long driverUserId) {
        return driverDAO.assignDriverToSubOrder(subOrderId, driverUserId);
    }
}
