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
import enums.DeliveryStatus;
import enums.SubOrderStatus;
import util.DBContext;

public class DriverDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(DriverDAO.class.getName());

    /**
     * Retrieve Driver Profile by User ID (used when logged in driver accesses the system)
     */
    public DriverProfile getDriverProfileByUserId(long userId) {
        String sql = "SELECT dp.driver_id, dp.user_id, dp.shop_id, s.shop_name, u.full_name, u.email, u.phone, u.avatar_url, "
                + "       dp.license_number, dp.vehicle_type, dp.vehicle_plate, dp.cold_storage_type, "
                + "       dp.operating_city, dp.operating_districts, dp.hub_name, "
                + "       dp.approval_status, dp.availability_status, dp.reviewed_by, rev.full_name AS reviewer_name, "
                + "       dp.reviewed_at, dp.rejection_reason, dp.rating, dp.total_trips, dp.max_capacity_orders, "
                + "       dp.created_at, dp.updated_at, "
                + "       dl.latitude, dl.longitude, dl.last_updated_at, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders "
                + "FROM driver_profiles dp "
                + "JOIN users u ON dp.user_id = u.user_id "
                + "LEFT JOIN shops s ON dp.shop_id = s.shop_id "
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
        String sql = "SELECT dp.driver_id, dp.user_id, dp.shop_id, s.shop_name, u.full_name, u.email, u.phone, u.avatar_url, "
                + "       dp.license_number, dp.vehicle_type, dp.vehicle_plate, dp.cold_storage_type, "
                + "       dp.operating_city, dp.operating_districts, dp.hub_name, "
                + "       dp.approval_status, dp.availability_status, dp.reviewed_by, rev.full_name AS reviewer_name, "
                + "       dp.reviewed_at, dp.rejection_reason, dp.rating, dp.total_trips, dp.max_capacity_orders, "
                + "       dp.created_at, dp.updated_at, "
                + "       dl.latitude, dl.longitude, dl.last_updated_at, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders "
                + "FROM driver_profiles dp "
                + "JOIN users u ON dp.user_id = u.user_id "
                + "LEFT JOIN shops s ON dp.shop_id = s.shop_id "
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
     * List all Driver Profiles belonging to a specific Shop (with optional status filter and keyword search)
     */
    public List<DriverProfile> getDriversByShopId(long shopId, String statusFilter, String keyword) {
        List<DriverProfile> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT dp.driver_id, dp.user_id, dp.shop_id, s.shop_name, u.full_name, u.email, u.phone, u.avatar_url, "
                + "       dp.license_number, dp.vehicle_type, dp.vehicle_plate, dp.cold_storage_type, "
                + "       dp.operating_city, dp.operating_districts, dp.hub_name, "
                + "       dp.approval_status, dp.availability_status, dp.reviewed_by, rev.full_name AS reviewer_name, "
                + "       dp.reviewed_at, dp.rejection_reason, dp.rating, dp.total_trips, dp.max_capacity_orders, "
                + "       dp.created_at, dp.updated_at, "
                + "       dl.latitude, dl.longitude, dl.last_updated_at, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders "
                + "FROM driver_profiles dp "
                + "JOIN users u ON dp.user_id = u.user_id "
                + "LEFT JOIN shops s ON dp.shop_id = s.shop_id "
                + "LEFT JOIN users rev ON dp.reviewed_by = rev.user_id "
                + "LEFT JOIN driver_locations dl ON dp.driver_id = dl.driver_id "
                + "WHERE dp.shop_id = ? "
        );

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND dp.availability_status = ? ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ? OR dp.vehicle_plate LIKE ? OR dp.vehicle_type LIKE ?) ");
        }

        sql.append(" ORDER BY CASE WHEN dp.availability_status = 'AVAILABLE' THEN 1 WHEN dp.availability_status = 'BUSY' THEN 2 ELSE 3 END, dp.rating DESC, dp.driver_id DESC");

        Connection conn = getConnection();
        if (conn == null) return list;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setLong(idx++, shopId);

            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                ps.setString(idx++, statusFilter.trim().toUpperCase());
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
                    list.add(extractDriverProfile(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error listing drivers for shop " + shopId, ex);
        }
        return list;
    }

    /**
     * Get list of currently AVAILABLE drivers belonging to a specific Shop, ready for dispatch
     */
    public List<DriverProfile> getAvailableDriversByShopId(long shopId) {
        return getDriversByShopId(shopId, "AVAILABLE", null);
    }

    /**
     * Create a new Shipper / Delivery Staff belonging to a Shop
     */
    public boolean createShopShipper(long shopId, String fullName, String email, String phone, String password,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts) {
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn) {
            conn.setAutoCommit(false);
            long targetUserId = -1;

            // 1. Check if user already exists with email or phone
            String findUserSql = "SELECT user_id FROM users WHERE email = ? OR (phone = ? AND phone IS NOT NULL AND phone <> '')";
            try (PreparedStatement psFind = conn.prepareStatement(findUserSql)) {
                psFind.setString(1, email);
                psFind.setString(2, phone);
                try (ResultSet rs = psFind.executeQuery()) {
                    if (rs.next()) {
                        targetUserId = rs.getLong("user_id");
                    }
                }
            }

            if (targetUserId == -1) {
                // Insert new user
                String insertUserSql = "INSERT INTO users (email, phone, password_hash, full_name, avatar_url, gender, birth_date, status) "
                        + "VALUES (?, ?, ?, ?, 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&h=100&fit=crop', 'MALE', '1995-01-01', 'ACTIVE')";
                try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                    psUser.setString(1, email);
                    psUser.setString(2, phone);
                    psUser.setString(3, (password != null && !password.trim().isEmpty()) ? password.trim() : "123456");
                    psUser.setNString(4, fullName);
                    psUser.executeUpdate();
                    try (ResultSet rsKey = psUser.getGeneratedKeys()) {
                        if (rsKey.next()) {
                            targetUserId = rsKey.getLong(1);
                        }
                    }
                }
            }

            if (targetUserId <= 0) {
                conn.rollback();
                return false;
            }

            // 2. Ensure role DRIVER (4) in user_roles
            String checkRoleSql = "SELECT 1 FROM user_roles WHERE user_id = ? AND role_id = 4";
            boolean hasRole = false;
            try (PreparedStatement psRoleCheck = conn.prepareStatement(checkRoleSql)) {
                psRoleCheck.setLong(1, targetUserId);
                try (ResultSet rsR = psRoleCheck.executeQuery()) {
                    hasRole = rsR.next();
                }
            }
            if (!hasRole) {
                String addRoleSql = "INSERT INTO user_roles (user_id, role_id) VALUES (?, 4)";
                try (PreparedStatement psAddRole = conn.prepareStatement(addRoleSql)) {
                    psAddRole.setLong(1, targetUserId);
                    psAddRole.executeUpdate();
                }
            }

            // 3. Upsert driver_profiles with shop_id
            String checkDpSql = "SELECT driver_id FROM driver_profiles WHERE user_id = ?";
            long existingDriverId = -1;
            try (PreparedStatement psDpCheck = conn.prepareStatement(checkDpSql)) {
                psDpCheck.setLong(1, targetUserId);
                try (ResultSet rsDp = psDpCheck.executeQuery()) {
                    if (rsDp.next()) {
                        existingDriverId = rsDp.getLong("driver_id");
                    }
                }
            }

            if (existingDriverId != -1) {
                String updateDpSql = "UPDATE driver_profiles SET shop_id = ?, vehicle_type = ?, vehicle_plate = ?, "
                        + "cold_storage_type = ?, operating_districts = ?, availability_status = 'AVAILABLE', "
                        + "approval_status = 'APPROVED', updated_at = GETDATE() WHERE driver_id = ?";
                try (PreparedStatement psUp = conn.prepareStatement(updateDpSql)) {
                    psUp.setLong(1, shopId);
                    psUp.setNString(2, vehicleType);
                    psUp.setString(3, vehiclePlate);
                    psUp.setNString(4, coldStorageType);
                    psUp.setNString(5, operatingDistricts);
                    psUp.setLong(6, existingDriverId);
                    psUp.executeUpdate();
                }
            } else {
                String insertDpSql = "INSERT INTO driver_profiles (user_id, shop_id, license_number, vehicle_type, vehicle_plate, "
                        + "cold_storage_type, operating_city, operating_districts, approval_status, availability_status, rating, total_trips, max_capacity_orders) "
                        + "VALUES (?, ?, 'GPLX-' + CAST(? AS VARCHAR(20)), ?, ?, ?, N'Nội thành', ?, 'APPROVED', 'AVAILABLE', 5.00, 0, 5)";
                try (PreparedStatement psIns = conn.prepareStatement(insertDpSql)) {
                    psIns.setLong(1, targetUserId);
                    psIns.setLong(2, shopId);
                    psIns.setLong(3, targetUserId);
                    psIns.setNString(4, vehicleType);
                    psIns.setString(5, vehiclePlate);
                    psIns.setNString(6, coldStorageType);
                    psIns.setNString(7, operatingDistricts);
                    psIns.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating shop shipper for shopId " + shopId, ex);
        }
        return false;
    }

    /**
     * Update details of an existing Shop Shipper
     */
    public boolean updateShopShipper(long driverId, long shopId, String fullName, String phone,
            String vehicleType, String vehiclePlate, String coldStorageType, String operatingDistricts, String availabilityStatus) {
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn) {
            conn.setAutoCommit(false);

            String updateProfileSql = "UPDATE driver_profiles SET vehicle_type = ?, vehicle_plate = ?, cold_storage_type = ?, "
                    + "operating_districts = ?, availability_status = ?, updated_at = GETDATE() "
                    + "WHERE driver_id = ? AND shop_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateProfileSql)) {
                ps.setNString(1, vehicleType);
                ps.setString(2, vehiclePlate);
                ps.setNString(3, coldStorageType);
                ps.setNString(4, operatingDistricts);
                ps.setString(5, availabilityStatus != null ? availabilityStatus : "AVAILABLE");
                ps.setLong(6, driverId);
                ps.setLong(7, shopId);
                int r1 = ps.executeUpdate();
                if (r1 == 0) {
                    conn.rollback();
                    return false;
                }
            }

            String updateUserSql = "UPDATE u SET u.full_name = ?, u.phone = ? "
                    + "FROM users u JOIN driver_profiles dp ON u.user_id = dp.user_id "
                    + "WHERE dp.driver_id = ?";
            try (PreparedStatement psU = conn.prepareStatement(updateUserSql)) {
                psU.setNString(1, fullName);
                psU.setString(2, phone);
                psU.setLong(3, driverId);
                psU.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating shop shipper " + driverId, ex);
        }
        return false;
    }

    /**
     * Toggle availability status of a Shop Shipper (AVAILABLE <-> OFFLINE)
     */
    public boolean toggleShipperStatus(long driverId, long shopId, String newStatus) {
        String sql = "UPDATE driver_profiles SET availability_status = ?, updated_at = GETDATE() WHERE driver_id = ? AND shop_id = ?";
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setLong(2, driverId);
            ps.setLong(3, shopId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error toggling shipper status " + driverId, ex);
        }
        return false;
    }

    /**
     * Remove / Unlink Shipper from Shop (only if no active delivering orders)
     */
    public boolean deleteShopShipper(long driverId, long shopId) {
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn) {
            // Check active deliveries
            String checkActiveSql = "SELECT COUNT(*) FROM deliveries d "
                    + "JOIN driver_profiles dp ON d.driver_id = dp.user_id "
                    + "WHERE dp.driver_id = ? AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')";
            try (PreparedStatement psCheck = conn.prepareStatement(checkActiveSql)) {
                psCheck.setLong(1, driverId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        LOGGER.warning("Cannot remove shipper with active deliveries: " + driverId);
                        return false;
                    }
                }
            }

            String unlinkSql = "UPDATE driver_profiles SET shop_id = NULL, availability_status = 'OFFLINE', updated_at = GETDATE() "
                    + "WHERE driver_id = ? AND shop_id = ?";
            try (PreparedStatement psUnlink = conn.prepareStatement(unlinkSql)) {
                psUnlink.setLong(1, driverId);
                psUnlink.setLong(2, shopId);
                return psUnlink.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting shop shipper " + driverId, ex);
        }
        return false;
    }

    /**
     * Explicitly assign a Shop's Shipper (by driver user_id) to a Sub-Order
     */
    public boolean assignDriverToSubOrder(long subOrderId, long driverUserId) {
        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn) {
            conn.setAutoCommit(false);

            String trackingNumber = "FFX-COLD-" + (1000 + (subOrderId % 9000)) + "-VN";

            String checkSql = "SELECT delivery_id FROM deliveries WHERE sub_order_id = ?";
            boolean exists = false;
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setLong(1, subOrderId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                String updateDeliverySql = "UPDATE deliveries SET driver_id = ?, delivery_status = 'ASSIGNED', assigned_at = GETDATE() WHERE sub_order_id = ?";
                try (PreparedStatement psUp = conn.prepareStatement(updateDeliverySql)) {
                    psUp.setLong(1, driverUserId);
                    psUp.setLong(2, subOrderId);
                    psUp.executeUpdate();
                }
            } else {
                String insertDeliverySql = "INSERT INTO deliveries (sub_order_id, driver_id, tracking_number, delivery_status, assigned_at) "
                        + "VALUES (?, ?, ?, 'ASSIGNED', GETDATE())";
                try (PreparedStatement psIns = conn.prepareStatement(insertDeliverySql)) {
                    psIns.setLong(1, subOrderId);
                    psIns.setLong(2, driverUserId);
                    psIns.setString(3, trackingNumber);
                    psIns.executeUpdate();
                }
            }

            // Sync SubOrder status to SHIPPING
            String updateSubSql = "UPDATE sub_orders SET status = '" + SubOrderStatus.SHIPPING.name() + "', updated_at = GETDATE() WHERE sub_order_id = ?";
            try (PreparedStatement psSub = conn.prepareStatement(updateSubSql)) {
                psSub.setLong(1, subOrderId);
                psSub.executeUpdate();
            }

            // Sync Parent Order status to SHIPPING
            String updateOrdSql = "UPDATE o SET o.order_status = 'SHIPPING', o.updated_at = GETDATE() "
                    + "FROM orders o JOIN sub_orders so ON o.order_id = so.order_id WHERE so.sub_order_id = ?";
            try (PreparedStatement psOrd = conn.prepareStatement(updateOrdSql)) {
                psOrd.setLong(1, subOrderId);
                psOrd.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error assigning driver " + driverUserId + " to subOrderId " + subOrderId, ex);
        }
        return false;
    }

    /**
     * List all Driver Profiles for Admin Review (supports status filter and keyword search)
     */
    public List<DriverProfile> getAllDriverProfiles(String approvalStatus, String keyword) {
        List<DriverProfile> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT dp.driver_id, dp.user_id, dp.shop_id, s.shop_name, u.full_name, u.email, u.phone, u.avatar_url, "
                + "       dp.license_number, dp.vehicle_type, dp.vehicle_plate, dp.cold_storage_type, "
                + "       dp.operating_city, dp.operating_districts, dp.hub_name, "
                + "       dp.approval_status, dp.availability_status, dp.reviewed_by, rev.full_name AS reviewer_name, "
                + "       dp.reviewed_at, dp.rejection_reason, dp.rating, dp.total_trips, dp.max_capacity_orders, "
                + "       dp.created_at, dp.updated_at, "
                + "       dl.latitude, dl.longitude, dl.last_updated_at, "
                + "       (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) AS active_orders "
                + "FROM driver_profiles dp "
                + "JOIN users u ON dp.user_id = u.user_id "
                + "LEFT JOIN shops s ON dp.shop_id = s.shop_id "
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
                    list.add(extractDriverProfile(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error listing driver profiles", ex);
        }
        return list;
    }

    /**
     * Intelligent Auto-Assign Cold-Chain Dispatch Engine:
     * 1. Prioritizes available drivers belonging to the SubOrder's Shop!
     * 2. Fallback to platform drivers if shop has no available driver.
     */
    public Long findBestDriverForSubOrder(long subOrderId) {
        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn) {
            // STEP 1: Check if the sub_order's SHOP has an available driver
            String shopDriverSql = "SELECT dp.user_id "
                    + "FROM driver_profiles dp "
                    + "JOIN sub_orders so ON dp.shop_id = so.shop_id "
                    + "WHERE so.sub_order_id = ? "
                    + "  AND dp.approval_status = 'APPROVED' AND dp.availability_status = 'AVAILABLE' "
                    + "  AND (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) < dp.max_capacity_orders "
                    + "ORDER BY dp.rating DESC, dp.total_trips DESC";
            try (PreparedStatement psShop = conn.prepareStatement(shopDriverSql)) {
                psShop.setLong(1, subOrderId);
                try (ResultSet rsShop = psShop.executeQuery()) {
                    if (rsShop.next()) {
                        return rsShop.getLong("user_id");
                    }
                }
            }

            // STEP 2: Fallback to city-matched approved platform driver
            String infoSql = "SELECT s.province AS shop_province FROM sub_orders so JOIN shops s ON so.shop_id = s.shop_id WHERE so.sub_order_id = ?";
            String shopCity = null;
            try (PreparedStatement psCity = conn.prepareStatement(infoSql)) {
                psCity.setLong(1, subOrderId);
                try (ResultSet rsCity = psCity.executeQuery()) {
                    if (rsCity.next()) {
                        shopCity = rsCity.getString("shop_province");
                    }
                }
            }

            if (shopCity == null || shopCity.trim().isEmpty()) {
                shopCity = "TP. Hồ Chí Minh";
            }

            String cityPattern = (shopCity.toLowerCase().contains("hồ chí minh") || shopCity.toLowerCase().contains("hcm"))
                    ? "%Hồ Chí Minh%" : (shopCity.toLowerCase().contains("hà nội") ? "%Hà Nội%" : "%" + shopCity.trim() + "%");

            String driverSql = "SELECT dp.user_id "
                    + "FROM driver_profiles dp "
                    + "LEFT JOIN driver_locations dl ON dp.driver_id = dl.driver_id "
                    + "WHERE dp.approval_status = 'APPROVED' AND dp.availability_status = 'AVAILABLE' "
                    + "  AND dp.operating_city LIKE ? "
                    + "  AND (SELECT COUNT(*) FROM deliveries d WHERE d.driver_id = dp.user_id AND d.delivery_status IN ('ASSIGNED', 'DELIVERING', 'IN_TRANSIT', 'PICKED_UP')) < dp.max_capacity_orders "
                    + "ORDER BY CASE WHEN dp.user_id = 9 THEN 0 ELSE 1 END, dp.rating DESC";

            try (PreparedStatement psDriver = conn.prepareStatement(driverSql)) {
                psDriver.setString(1, cityPattern);
                try (ResultSet rsDriver = psDriver.executeQuery()) {
                    if (rsDriver.next()) {
                        return rsDriver.getLong("user_id");
                    }
                }
            }

            // Secondary Fallback: query active users with role DRIVER directly
            String userDriverSql = "SELECT TOP 1 u.user_id FROM users u "
                    + "JOIN user_roles ur ON u.user_id = ur.user_id "
                    + "WHERE ur.role_id = 4 AND u.status = 'ACTIVE' "
                    + "ORDER BY CASE WHEN u.user_id = 9 THEN 0 ELSE 1 END, u.user_id ASC";
            try (PreparedStatement psUd = conn.prepareStatement(userDriverSql)) {
                try (ResultSet rsUd = psUd.executeQuery()) {
                    if (rsUd.next()) {
                        return rsUd.getLong("user_id");
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error querying best driver for subOrderId " + subOrderId, ex);
        }

        return null;
    }

    /**
     * Atomically dispatches a delivery to a driver, or queues it as ASSIGNING if no driver available
     */
    public boolean autoAssignDelivery(long subOrderId) {
        Long bestDriverUserId = findBestDriverForSubOrder(subOrderId);
        if (bestDriverUserId != null) {
            return assignDriverToSubOrder(subOrderId, bestDriverUserId);
        }
        return false;
    }

    private DriverProfile extractDriverProfile(ResultSet rs) throws SQLException {
        DriverProfile dp = new DriverProfile();
        dp.setDriverId(rs.getLong("driver_id"));
        dp.setUserId(rs.getLong("user_id"));

        try {
            long sid = rs.getLong("shop_id");
            if (!rs.wasNull()) {
                dp.setShopId(sid);
            }
        } catch (SQLException ignored) {}

        try {
            dp.setShopName(rs.getNString("shop_name"));
        } catch (SQLException ignored) {}

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
