package dao;

import util.DBContext;
import util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;


/**
 * Data Access Object for User entity handling SQL Server operations.
 * Compatible with [dbo].[users] and [dbo].[roles] tables.
 */
public class UserDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    /**
     * Authenticate user with email and password.
     * Supports both plain text and SHA-256 hashed password.
     *
     * @param email    User's email
     * @param password Raw password entered by user
     * @return User object if authentication is successful, null otherwise
     */
    public User checkLogin(String email, String password) {
        String sql = "SELECT u.user_id, u.email, u.password_hash, u.full_name, u.phone, "
                   + "       COALESCE(r.role_name, 'CUSTOMER') AS role, u.status, u.created_at "
                   + "FROM users u "
                   + "LEFT JOIN user_roles ur ON u.user_id = ur.user_id "
                   + "LEFT JOIN roles r ON ur.role_id = r.role_id "
                   + "WHERE LOWER(u.email) = LOWER(?)";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in checkLogin");
            return null;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password_hash");
                    if (PasswordUtil.verifyPassword(password, storedPassword)) {
                        return mapResultSetToUser(rs);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error during checkLogin for email: " + email, ex);
        }
        return null;
    }

    /**
     * Find a user by their email address.
     *
     * @param email User's email
     * @return User object or null if not found
     */
    public User findByEmail(String email) {
        String sql = "SELECT u.user_id, u.email, u.password_hash, u.full_name, u.phone, "
                   + "       COALESCE(r.role_name, 'CUSTOMER') AS role, u.status, u.created_at "
                   + "FROM users u "
                   + "LEFT JOIN user_roles ur ON u.user_id = ur.user_id "
                   + "LEFT JOIN roles r ON ur.role_id = r.role_id "
                   + "WHERE LOWER(u.email) = LOWER(?)";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in findByEmail");
            return null;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error during findByEmail: " + email, ex);
        }
        return null;
    }

    /**
     * Find a user by their ID.
     *
     * @param id User ID
     * @return User object or null if not found
     */
    public User findById(int id) {
        String sql = "SELECT u.user_id, u.email, u.password_hash, u.full_name, u.phone, "
                   + "       COALESCE(r.role_name, 'CUSTOMER') AS role, u.status, u.created_at "
                   + "FROM users u "
                   + "LEFT JOIN user_roles ur ON u.user_id = ur.user_id "
                   + "LEFT JOIN roles r ON ur.role_id = r.role_id "
                   + "WHERE u.user_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in findById");
            return null;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error during findById: " + id, ex);
        }
        return null;
    }

    /**
     * Reset password for a user.
     *
     * @param email       User's email
     * @param newPassword Raw new password (will be hashed)
     * @return true if updated successfully
     */
    public boolean resetPassword(String email, String newPassword) {
        String sql = "UPDATE users "
                   + "SET password_hash = ?, "
                   + "    updated_at = GETDATE() "
                   + "WHERE LOWER(email) = LOWER(?)";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in resetPassword");
            return false;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String passwordToStore = PasswordUtil.hashPassword(newPassword);
            ps.setString(1, passwordToStore);
            ps.setString(2, email.trim());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error resetting password for email: " + email, ex);
        }
        return false;
    }

    /**
     * Update password for an authenticated user.
     *
     * @param userId      User ID
     * @param newPassword Raw new password
     * @return true if updated successfully
     */
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in updatePassword");
            return false;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String passwordToStore = PasswordUtil.hashPassword(newPassword);
            ps.setString(1, passwordToStore);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating password for user ID: " + userId, ex);
        }
        return false;
    }

    /**
     * Check if an email is already registered in the system.
     *
     * @param email User's email to check
     * @return true if email exists, false otherwise
     */
    public boolean isEmailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE LOWER(email) = LOWER(?)";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in isEmailExists");
            return false;
        }

        try (conn;
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking email existence: " + email, ex);
        }
        return false;
    }

    /**
     * Register a new user account with CUSTOMER role (role_id = 3).
     *
     * @param user User object containing fullName, email, phone, and hashed password
     * @return true if registration succeeded, false otherwise
     */
    public boolean register(User user) {
        String sqlUser = "INSERT INTO users (email, phone, password_hash, full_name, avatar_url, status, created_at, updated_at) "
                       + "VALUES (?, ?, ?, ?, NULL, 'ACTIVE', GETDATE(), GETDATE())";
        String sqlRole = "INSERT INTO user_roles (user_id, role_id) "
                       + "SELECT ?, role_id FROM roles WHERE role_name = 'CUSTOMER'";
        String sqlCart = "INSERT INTO carts (customer_id) VALUES (?)";

        Connection conn = getConnection();
        if (conn == null) {
            LOGGER.severe("Cannot establish DB connection in register");
            return false;
        }

        try (conn) {
            conn.setAutoCommit(false);
            long newUserId = -1;

            try (PreparedStatement ps = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, user.getEmail().trim().toLowerCase());
                ps.setString(2, user.getPhone() != null && !user.getPhone().trim().isEmpty() ? user.getPhone().trim() : null);
                ps.setString(3, user.getPassword());
                ps.setString(4, user.getFullName().trim());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet gk = ps.getGeneratedKeys()) {
                        if (gk.next()) {
                            newUserId = gk.getLong(1);
                        }
                    }
                }
            }

            if (newUserId > 0) {
                // Gán quyền CUSTOMER mặc định
                try (PreparedStatement psRole = conn.prepareStatement(sqlRole)) {
                    psRole.setLong(1, newUserId);
                    psRole.executeUpdate();
                }

                // Khởi tạo giỏ hàng trống mặc định cho khách
                try (PreparedStatement psCart = conn.prepareStatement(sqlCart)) {
                    psCart.setLong(1, newUserId);
                    psCart.executeUpdate();
                }

                conn.commit();
                return true;
            } else {
                conn.rollback();
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error registering new user with email: " + user.getEmail(), ex);
        }
        return false;
    }

    /**
     * Helper to map a ResultSet row to a User object.
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId((int) rs.getLong("user_id"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password_hash"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));

        // Status in DB is VARCHAR ('ACTIVE', 'LOCKED', etc.)
        String statusStr = rs.getString("status");
        user.setStatus("ACTIVE".equalsIgnoreCase(statusStr) ? 1 : 0);

        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}

