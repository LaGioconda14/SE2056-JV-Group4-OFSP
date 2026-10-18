package service.impl;

import dao.DriverDAO;
import java.util.List;
import model.DriverProfile;
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
    public DriverProfile getDriverProfile(long driverId) {
        return driverDAO.getDriverProfile(driverId);
    }

    @Override
    public List<DriverProfile> getAllDriverProfiles(String approvalStatus, String keyword) {
        return driverDAO.getAllDriverProfiles(approvalStatus, keyword);
    }

    @Override
    public boolean autoDispatchSubOrder(long subOrderId) {
        return driverDAO.autoAssignDelivery(subOrderId);
    }
}
