package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.CustomerAddress;
import util.DBContext;

public class CustomerAddressDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(CustomerAddressDAO.class.getName());

    public List<CustomerAddress> getAddressesByUserId(long userId) {
        List<CustomerAddress> list = new ArrayList<>();
        String sql = "SELECT address_id, user_id, recipient_name, recipient_phone, "
                   + "       street_address, ward, district, city, is_default, created_at, updated_at "
                   + "FROM customer_addresses "
                   + "WHERE user_id = ? "
                   + "ORDER BY is_default DESC, created_at DESC";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in getAddressesByUserId");
            return list;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToAddress(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getAddressesByUserId for userId: " + userId, ex);
        }
        return list;
    }

    public CustomerAddress getAddressById(long addressId, long userId) {
        String sql = "SELECT address_id, user_id, recipient_name, recipient_phone, "
                   + "       street_address, ward, district, city, is_default, created_at, updated_at "
                   + "FROM customer_addresses "
                   + "WHERE address_id = ? AND user_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return null;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAddress(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getAddressById for addressId: " + addressId, ex);
        }
        return null;
    }

    public int countAddresses(long userId) {
        String sql = "SELECT COUNT(*) FROM customer_addresses WHERE user_id = ?";
        Connection conn = getConnection();
        if (conn == null) {
            return 0;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting addresses for userId: " + userId, ex);
        }
        return 0;
    }

    public boolean addAddress(CustomerAddress address) {
        int existingCount = countAddresses(address.getUserId());
        boolean shouldBeDefault = address.isDefault() || (existingCount == 0);

        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try {
            conn.setAutoCommit(false);

            if (shouldBeDefault && existingCount > 0) {
                String resetSql = "UPDATE customer_addresses SET is_default = 0, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
                try (PreparedStatement resetPs = conn.prepareStatement(resetSql)) {
                    resetPs.setLong(1, address.getUserId());
                    resetPs.executeUpdate();
                }
            }

            String insertSql = "INSERT INTO customer_addresses (user_id, recipient_name, recipient_phone, "
                             + "       street_address, ward, district, city, is_default, created_at, updated_at) "
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setLong(1, address.getUserId());
                insertPs.setString(2, address.getRecipientName().trim());
                insertPs.setString(3, address.getRecipientPhone().trim());
                insertPs.setString(4, address.getStreetAddress().trim());
                insertPs.setString(5, address.getWard() != null ? address.getWard().trim() : "");
                insertPs.setString(6, address.getDistrict() != null ? address.getDistrict().trim() : "");
                insertPs.setString(7, address.getCity().trim());
                insertPs.setBoolean(8, shouldBeDefault);

                int rows = insertPs.executeUpdate();
                conn.commit();
                return rows > 0;
            }
        } catch (SQLException ex) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", e);
            }
            LOGGER.log(Level.SEVERE, "Error adding address for userId: " + address.getUserId(), ex);
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing connection", e);
            }
        }
    }

    public boolean setDefaultAddress(long addressId, long userId) {
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try {
            conn.setAutoCommit(false);

            String resetSql = "UPDATE customer_addresses SET is_default = 0, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
            try (PreparedStatement resetPs = conn.prepareStatement(resetSql)) {
                resetPs.setLong(1, userId);
                resetPs.executeUpdate();
            }

            String setSql = "UPDATE customer_addresses SET is_default = 1, updated_at = CURRENT_TIMESTAMP WHERE address_id = ? AND user_id = ?";
            try (PreparedStatement setPs = conn.prepareStatement(setSql)) {
                setPs.setLong(1, addressId);
                setPs.setLong(2, userId);
                int rows = setPs.executeUpdate();
                conn.commit();
                return rows > 0;
            }
        } catch (SQLException ex) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", e);
            }
            LOGGER.log(Level.SEVERE, "Error setting default address for addressId: " + addressId, ex);
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing connection", e);
            }
        }
    }

    public boolean deleteAddress(long addressId, long userId) {
        CustomerAddress current = getAddressById(addressId, userId);
        if (current == null) {
            return false;
        }

        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try {
            conn.setAutoCommit(false);

            String deleteSql = "DELETE FROM customer_addresses WHERE address_id = ? AND user_id = ?";
            try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                deletePs.setLong(1, addressId);
                deletePs.setLong(2, userId);
                deletePs.executeUpdate();
            }

            if (current.isDefault()) {
                String promoteSql = "UPDATE customer_addresses SET is_default = 1, updated_at = CURRENT_TIMESTAMP "
                                  + "WHERE address_id = (SELECT TOP 1 address_id FROM customer_addresses WHERE user_id = ? ORDER BY created_at DESC)";
                try (PreparedStatement promotePs = conn.prepareStatement(promoteSql)) {
                    promotePs.setLong(1, userId);
                    promotePs.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", e);
            }
            LOGGER.log(Level.SEVERE, "Error deleting address for addressId: " + addressId, ex);
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing connection", e);
            }
        }
    }

    private CustomerAddress mapResultSetToAddress(ResultSet rs) throws SQLException {
        return new CustomerAddress(
            rs.getLong("address_id"),
            rs.getLong("user_id"),
            rs.getString("recipient_name"),
            rs.getString("recipient_phone"),
            rs.getString("street_address"),
            rs.getString("ward"),
            rs.getString("district"),
            rs.getString("city"),
            rs.getBoolean("is_default"),
            rs.getTimestamp("created_at"),
            rs.getTimestamp("updated_at")
        );
    }
}
