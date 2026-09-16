package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;
import service.PasswordUtil;

/**
 * Data Access Object for User entity handling SQL Server operations.
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
        String sql = "SELECT id, email, password, full_name, phone, role, status, reset_otp, otp_expiry_time, created_at "
                   + "FROM Users WHERE LOWER(email) = LOWER(?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) {
                LOGGER.severe("Cannot establish DB connection in checkLogin");
                return null;
            }

            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password");
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
        String sql = "SELECT id, email, password, full_name, phone, role, status, reset_otp, otp_expiry_time, created_at "
                   + "FROM Users WHERE LOWER(email) = LOWER(?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) {
                LOGGER.severe("Cannot establish DB connection in findByEmail");
                return null;
            }

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
        String sql = "SELECT id, email, password, full_name, phone, role, status, reset_otp, otp_expiry_time, created_at "
                   + "FROM Users WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) {
                LOGGER.severe("Cannot establish DB connection in findById");
                return null;
            }

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
     * Save generated OTP and its expiry time for password recovery.
     *
     * @param email         User's email
     * @param otp           6-digit OTP
     * @param expiryMinutes Validity duration in minutes (e.g., 5)
     * @return true if updated successfully
     */
    public boolean saveOTP(String email, String otp, int expiryMinutes) {
        String sql = "UPDATE Users "
                   + "SET reset_otp = ?, "
                   + "    otp_expiry_time = DATEADD(minute, ?, GETDATE()) "
                   + "WHERE LOWER(email) = LOWER(?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) return false;

            ps.setString(1, otp);
            ps.setInt(2, expiryMinutes);
            ps.setString(3, email.trim());

            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error saving OTP for email: " + email, ex);
        }
        return false;
    }

    /**
     * Verify if the provided OTP matches and has not expired.
     *
     * @param email User's email
     * @param otp   OTP code to verify
     * @return true if OTP is valid and within expiry time
     */
    public boolean verifyOTP(String email, String otp) {
        String sql = "SELECT id FROM Users "
                   + "WHERE LOWER(email) = LOWER(?) "
                   + "  AND reset_otp = ? "
                   + "  AND otp_expiry_time >= GETDATE()";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) return false;

            ps.setString(1, email.trim());
            ps.setString(2, otp.trim());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error verifying OTP for email: " + email, ex);
        }
        return false;
    }

    /**
     * Reset password after successful OTP verification, clear OTP fields.
     *
     * @param email       User's email
     * @param newPassword Raw or hashed new password
     * @return true if updated successfully
     */
    public boolean resetPassword(String email, String newPassword) {
        String sql = "UPDATE Users "
                   + "SET password = ?, "
                   + "    reset_otp = NULL, "
                   + "    otp_expiry_time = NULL "
                   + "WHERE LOWER(email) = LOWER(?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) return false;

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
        String sql = "UPDATE Users SET password = ? WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (conn == null) return false;

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
     * Helper to map a ResultSet row to a User object.
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getInt("status"));
        user.setResetOtp(rs.getString("reset_otp"));
        user.setOtpExpiryTime(rs.getTimestamp("otp_expiry_time"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}

