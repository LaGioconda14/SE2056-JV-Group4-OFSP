package service;

import model.GoogleAccount;
import model.User;

/**
 * Service interface for User operations and Authentication business logic.
 */
public interface IUserService {

    /**
     * Authenticates a user with email or phone number and raw password.
     *
     * @param emailOrPhone User's email or phone number
     * @param rawPassword  User's raw password
     * @return Authenticated User object
     * @throws Exception with user-facing message if credentials are invalid or account is locked
     */
    User login(String emailOrPhone, String rawPassword) throws Exception;

    /**
     * Registers a new customer account after validating all inputs.
     *
     * @param fullName        Customer's full name
     * @param email           Customer's email
     * @param phone           Customer's phone (optional)
     * @param password        Password
     * @param confirmPassword Password confirmation
     * @throws Exception with user-facing message if validation or registration fails
     */
    void register(String fullName, String email, String phone, String password, String confirmPassword) throws Exception;

    /**
     * Sends an OTP for resetting a forgotten password.
     *
     * @param email User's email
     * @return Generated 6-digit OTP code
     * @throws Exception if email is not found, locked, or email sending fails
     */
    String sendForgotPasswordOtp(String email) throws Exception;

    /**
     * Resets a user's password using email and new password.
     *
     * @param email           User's email
     * @param newPassword     New password
     * @param confirmPassword Confirmation of new password
     * @throws Exception if passwords do not match or update fails
     */
    void resetPassword(String email, String newPassword, String confirmPassword) throws Exception;

    /**
     * Changes password for an existing user after verifying the current password.
     *
     * @param userId          User ID
     * @param oldPassword     Current password
     * @param newPassword     New password
     * @param confirmPassword Confirmation of new password
     * @throws Exception if old password is incorrect or validation fails
     */
    void changePassword(int userId, String oldPassword, String newPassword, String confirmPassword) throws Exception;

    /**
     * Finds a user by ID.
     *
     * @param userId User ID
     * @return User object or null
     */
    User getUserById(int userId);

    /**
     * Updates personal profile information.
     *
     * @param userId    User ID
     * @param fullName  Full name
     * @param phone     Phone number
     * @param gender    Gender
     * @param birthDate Date of birth
     * @throws Exception if full name is empty or update fails
     */
    void updateProfile(int userId, String fullName, String phone, String gender, java.sql.Date birthDate) throws Exception;

    /**
     * Updates avatar image URL for a user.
     *
     * @param userId    User ID
     * @param avatarUrl Avatar URL or relative path (null to remove)
     * @throws Exception if DB update fails
     */
    void updateAvatar(int userId, String avatarUrl) throws Exception;

    /**
     * Processes Google OAuth login, automatically registering user if first time.
     *
     * @param googleAccount Google account information
     * @return Authenticated User object
     * @throws Exception if account is locked or registration fails
     */
    User processGoogleLogin(GoogleAccount googleAccount) throws Exception;
}
