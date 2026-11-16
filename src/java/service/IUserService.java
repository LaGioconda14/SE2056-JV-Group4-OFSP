package service;

import model.dto.auth.GoogleAccount;
import model.entity.user.User;

public interface IUserService {

    User login(String emailOrPhone, String rawPassword) throws Exception;

    void register(String fullName, String email, String phone, String password, String confirmPassword) throws Exception;

    String sendForgotPasswordOtp(String email) throws Exception;

    void resetPassword(String email, String newPassword, String confirmPassword) throws Exception;

    void changePassword(int userId, String oldPassword, String newPassword, String confirmPassword) throws Exception;

    User getUserById(int userId);

    void updateProfile(int userId, String fullName, String phone, String gender, java.sql.Date birthDate) throws Exception;

    void updateAvatar(int userId, String avatarUrl) throws Exception;

    User processGoogleLogin(GoogleAccount googleAccount) throws Exception;
}
