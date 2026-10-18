package service;

import java.util.List;
import model.DriverProfile;

public interface IDriverService {

    DriverProfile getDriverProfileByUserId(long userId);

    DriverProfile getDriverProfile(long driverId);

    List<DriverProfile> getAllDriverProfiles(String approvalStatus, String keyword);

    boolean autoDispatchSubOrder(long subOrderId);
}
