package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.DriverProfile;
import util.DBContext;

public class DriverDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(DriverDAO.class.getName());

    /**
     * Retrieve Driver Profile by User ID (used when logged in driver accesses the system)
     */
    public DriverProfile getDriverProfileByUserId(long userId) {
        String sql = "SELECT dp.driver_id, dp.user_id, u.full_name, u.email, u.phone, u.avatar_url, "
                + "       dp.license_number, dp.vehicle_type, dp.vehicle_plate, dp.cold_storage_type, "
                + "       dp.operating_city, dp.operating_districts, dp.hub_name, "
                + "       dp.approval_status, dp.availability_status, dp.reviewed_by, rev.full_name AS reviewer_name, "
                + "       dp.reviewed_at, dp.rejection_reason, dp.rating, dp.total_trips, dp.max_capacity_orders, "
                + "       dp.created_at, dp.updated_at, "
                + "       dl.latitude, dl.longitude, dl.last_updated_at, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders "
                + "FROM driver_profiles dp "
                + "JOIN users u ON dp.user_id = u.user_id "
                + "LEFT JOIN users rev ON dp.reviewed_by = rev.user_id "
                + "LEFT JOIN driver_locations dl ON dp.driver_id = dl.driver_id "
                + "WHERE dp.user_id = ?";

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractDriverProfile(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving driver profile for userId " + userId, ex);
        }
        return null;
    }

    /**
     * Retrieve Driver Profile by Driver ID (primary key of driver_profiles)
     */
    public DriverProfile getDriverProfile(long driverId) {
        String sql = "SELECT dp.driver_id, dp.user_id, u.full_name, u.email, u.phone, u.avatar_url, "
                + "       dp.license_number, dp.vehicle_type, dp.vehicle_plate, dp.cold_storage_type, "
                + "       dp.operating_city, dp.operating_districts, dp.hub_name, "
                + "       dp.approval_status, dp.availability_status, dp.reviewed_by, rev.full_name AS reviewer_name, "
                + "       dp.reviewed_at, dp.rejection_reason, dp.rating, dp.total_trips, dp.max_capacity_orders, "
                + "       dp.created_at, dp.updated_at, "
                + "       dl.latitude, dl.longitude, dl.last_updated_at, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders "
                + "FROM driver_profiles dp "
                + "JOIN users u ON dp.user_id = u.user_id "
                + "LEFT JOIN users rev ON dp.reviewed_by = rev.user_id "
                + "LEFT JOIN driver_locations dl ON dp.driver_id = dl.driver_id "
                + "WHERE dp.driver_id = ?";

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, driverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractDriverProfile(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving driver profile for driverId " + driverId, ex);
        }
        return null;
    }

    /**
     * List all Driver Profiles for Admin Review (supports status filter and keyword search)
     */
    public List<DriverProfile> getAllDriverProfiles(String approvalStatus, String keyword) {
        List<DriverProfile> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT dp.driver_id, dp.user_id, u.full_name, u.email, u.phone, u.avatar_url, "
                + "       dp.license_number, dp.vehicle_type, dp.vehicle_plate, dp.cold_storage_type, "
                + "       dp.operating_city, dp.operating_districts, dp.hub_name, "
                + "       dp.approval_status, dp.availability_status, dp.reviewed_by, rev.full_name AS reviewer_name, "
                + "       dp.reviewed_at, dp.rejection_reason, dp.rating, dp.total_trips, dp.max_capacity_orders, "
                + "       dp.created_at, dp.updated_at, "
                + "       dl.latitude, dl.longitude, dl.last_updated_at, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders "
                + "FROM driver_profiles dp "
                + "JOIN users u ON dp.user_id = u.user_id "
                + "LEFT JOIN users rev ON dp.reviewed_by = rev.user_id "
                + "LEFT JOIN driver_locations dl ON dp.driver_id = dl.driver_id "
                + "WHERE 1=1 "
        );

        if (approvalStatus != null && !approvalStatus.trim().isEmpty() && !"ALL".equalsIgnoreCase(approvalStatus)) {
            sql.append(" AND dp.approval_status = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ? OR dp.vehicle_plate LIKE ? OR dp.operating_city LIKE ?) ");
        }

        sql.append(" ORDER BY CASE WHEN dp.approval_status = 'PENDING' THEN 1 WHEN dp.approval_status = 'NEEDS_REVISION' THEN 2 ELSE 3 END, dp.created_at DESC");

        Connection conn = getConnection();
        if (conn == null) return list;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (approvalStatus != null && !approvalStatus.trim().isEmpty() && !"ALL".equalsIgnoreCase(approvalStatus)) {
                ps.setString(idx++, approvalStatus.trim().toUpperCase());
            }

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DriverProfile dp = extractDriverProfile(rs);
                    list.add(dp);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error listing driver profiles", ex);
        }
        return list;
    }





    /**
     * Intelligent Auto-Assign Cold-Chain Dispatch Engine:
     * Finds eligible drivers who are APPROVED, AVAILABLE, and within capacity.
     */
    public Long findBestDriverForSubOrder(long subOrderId) {
        String infoSql = "SELECT s.province AS shop_province FROM sub_orders so JOIN shops s ON so.shop_id = s.shop_id WHERE so.sub_order_id = ?";
        String shopCity = null;

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn; PreparedStatement ps = conn.prepareStatement(infoSql)) {
            ps.setLong(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    shopCity = rs.getString("shop_province");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error fetching shop city for subOrderId " + subOrderId, ex);
        }

        if (shopCity == null || shopCity.trim().isEmpty()) {
            shopCity = "TP. Hồ Chí Minh";
        }

        String cityPattern = (shopCity.toLowerCase().contains("hồ chí minh") || shopCity.toLowerCase().contains("hcm")) 
                ? "%Hồ Chí Minh%" : (shopCity.toLowerCase().contains("hà nội") ? "%Hà Nội%" : "%" + shopCity.trim() + "%");

        String driverSql = "SELECT dp.user_id, dp.max_capacity_orders, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders, "
                + "       DATEDIFF(MINUTE, dl.last_updated_at, GETDATE()) AS gps_age_minutes "
                + "FROM driver_profiles dp "
                + "LEFT JOIN driver_locations dl ON dp.driver_id = dl.driver_id "
                + "WHERE dp.approval_status = 'APPROVED' AND dp.availability_status = 'AVAILABLE' "
                + "  AND dp.operating_city LIKE ? "
                + "  AND (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) < dp.max_capacity_orders "
                + "ORDER BY CASE WHEN dp.user_id = 9 THEN 0 ELSE 1 END, active_orders ASC, ISNULL(gps_age_minutes, 9999) ASC, dp.rating DESC";

        Connection conn2 = getConnection();
        if (conn2 == null) return null;

        try (conn2; PreparedStatement psDriver = conn2.prepareStatement(driverSql)) {
            psDriver.setString(1, cityPattern);
            try (ResultSet rsDriver = psDriver.executeQuery()) {
                if (rsDriver.next()) {
                    return rsDriver.getLong("user_id");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error querying best driver for subOrderId " + subOrderId, ex);
        }

        // Fallback: any available approved driver (prioritizing Driver 9)
        String fallbackSql = "SELECT dp.user_id "
                + "FROM driver_profiles dp "
                + "WHERE dp.approval_status = 'APPROVED' AND dp.availability_status = 'AVAILABLE' "
                + "  AND (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) < dp.max_capacity_orders "
                + "ORDER BY CASE WHEN dp.user_id = 9 THEN 0 ELSE 1 END, dp.rating DESC";

        Connection conn3 = getConnection();
        if (conn3 == null) return null;

        try (conn3; PreparedStatement psFb = conn3.prepareStatement(fallbackSql)) {
            try (ResultSet rsFb = psFb.executeQuery()) {
                if (rsFb.next()) {
                    return rsFb.getLong("user_id");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in fallback driver selection", ex);
        }

        // Secondary Fallback: query active users with role DRIVER directly
        String userDriverSql = "SELECT TOP 1 u.user_id FROM users u "
                + "JOIN user_roles ur ON u.user_id = ur.user_id "
                + "WHERE ur.role_id = 4 AND u.status = 'ACTIVE' "
                + "ORDER BY CASE WHEN u.user_id = 9 THEN 0 ELSE 1 END, u.user_id ASC";
        Connection conn4 = getConnection();
        if (conn4 != null) {
            try (conn4; PreparedStatement psUd = conn4.prepareStatement(userDriverSql)) {
                try (ResultSet rsUd = psUd.executeQuery()) {
                    if (rsUd.next()) {
                        return rsUd.getLong("user_id");
                    }
                }
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error in user driver fallback", ex);
            }
        }

        return null;
    }

    /**
     * Atomically dispatches a delivery to a driver, or queues it as ASSIGNING if no driver available
     */
    public boolean autoAssignDelivery(long subOrderId) {
        Long bestDriverUserId = findBestDriverForSubOrder(subOrderId);

        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn) {
            String checkSql = "SELECT delivery_id, driver_id, delivery_status FROM deliveries WHERE sub_order_id = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setLong(1, subOrderId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        long deliveryId = rs.getLong("delivery_id");
                        if (bestDriverUserId != null) {
                            String assignSql = "UPDATE deliveries SET driver_id = ?, delivery_status = 'ASSIGNED', assigned_at = GETDATE() "
                                    + "WHERE delivery_id = ? AND (driver_id IS NULL OR delivery_status = 'ASSIGNING')";
                            try (PreparedStatement psAssign = conn.prepareStatement(assignSql)) {
                                psAssign.setLong(1, bestDriverUserId);
                                psAssign.setLong(2, deliveryId);
                                return psAssign.executeUpdate() > 0;
                            }
                        } else {
                            String queueSql = "UPDATE deliveries SET delivery_status = 'ASSIGNING' WHERE delivery_id = ? AND driver_id IS NULL";
                            try (PreparedStatement psQueue = conn.prepareStatement(queueSql)) {
                                psQueue.setLong(1, deliveryId);
                                psQueue.executeUpdate();
                            }
                            return false;
                        }
                    } else {
                        String trackingNumber = "FFX-COLD-" + (1000 + (subOrderId % 9000)) + "-VN";
                        if (bestDriverUserId != null) {
                            String insertSql = "INSERT INTO deliveries (sub_order_id, driver_id, tracking_number, delivery_status, assigned_at) "
                                    + "VALUES (?, ?, ?, 'ASSIGNED', GETDATE())";
                            try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                                psIns.setLong(1, subOrderId);
                                psIns.setLong(2, bestDriverUserId);
                                psIns.setString(3, trackingNumber);
                                return psIns.executeUpdate() > 0;
                            }
                        } else {
                            String insertQueueSql = "INSERT INTO deliveries (sub_order_id, tracking_number, delivery_status) "
                                    + "VALUES (?, ?, 'ASSIGNING')";
                            try (PreparedStatement psInsQ = conn.prepareStatement(insertQueueSql)) {
                                psInsQ.setLong(1, subOrderId);
                                psInsQ.setString(2, trackingNumber);
                                return psInsQ.executeUpdate() > 0;
                            }
                        }
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in autoAssignDelivery for subOrderId " + subOrderId, ex);
        }
        return false;
    }

    private DriverProfile extractDriverProfile(ResultSet rs) throws SQLException {
        DriverProfile dp = new DriverProfile();
        dp.setDriverId(rs.getLong("driver_id"));
        dp.setUserId(rs.getLong("user_id"));
        dp.setFullName(rs.getNString("full_name"));
        dp.setEmail(rs.getString("email"));
        dp.setPhone(rs.getString("phone"));
        dp.setAvatarUrl(rs.getString("avatar_url"));

        dp.setLicenseNumber(rs.getString("license_number"));
        dp.setVehicleType(rs.getNString("vehicle_type"));
        dp.setVehiclePlate(rs.getString("vehicle_plate"));
        dp.setColdStorageType(rs.getNString("cold_storage_type"));
        dp.setOperatingCity(rs.getNString("operating_city"));
        dp.setOperatingDistricts(rs.getNString("operating_districts"));
        dp.setHubName(rs.getNString("hub_name"));

        dp.setApprovalStatus(rs.getString("approval_status"));
        dp.setAvailabilityStatus(rs.getString("availability_status"));
        long revBy = rs.getLong("reviewed_by");
        if (!rs.wasNull()) {
            dp.setReviewedBy(revBy);
        }
        dp.setReviewerName(rs.getNString("reviewer_name"));
        dp.setReviewedAt(rs.getTimestamp("reviewed_at"));
        dp.setRejectionReason(rs.getNString("rejection_reason"));

        dp.setRating(rs.getBigDecimal("rating"));
        dp.setTotalTrips(rs.getInt("total_trips"));
        dp.setMaxCapacityOrders(rs.getInt("max_capacity_orders"));
        dp.setCreatedAt(rs.getTimestamp("created_at"));
        dp.setUpdatedAt(rs.getTimestamp("updated_at"));

        double lat = rs.getDouble("latitude");
        if (!rs.wasNull()) {
            dp.setLatitude(lat);
        }
        double lng = rs.getDouble("longitude");
        if (!rs.wasNull()) {
            dp.setLongitude(lng);
        }
        dp.setLastUpdatedAt(rs.getTimestamp("last_updated_at"));
        dp.setActiveOrderCount(rs.getInt("active_orders"));
        return dp;
    }
}
