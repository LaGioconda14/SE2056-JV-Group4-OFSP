package service.impl;

import dao.UserDAO;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.GoogleAccount;
import model.User;
import service.IUserService;
import util.EmailUtil;
import util.PasswordUtil;

/**
 * Implementation of IUserService for business logic and validation.
 */
public class UserServiceImpl implements IUserService {

    private static final Logger LOGGER = Logger.getLogger(UserServiceImpl.class.getName());
    private final UserDAO userDAO;

    public UserServiceImpl() {
        this.userDAO = new UserDAO();
    }

    public UserServiceImpl(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    @Override
    public User login(String email, String rawPassword) throws Exception {
        if (email == null || email.trim().isEmpty() || rawPassword == null || rawPassword.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập đầy đủ Email và Mật khẩu!");
        }

        email = email.trim();
        User user = userDAO.findByEmail(email);

        if (user == null || !PasswordUtil.verifyPassword(rawPassword, user.getPassword())) {
            throw new Exception("Email hoặc mật khẩu không chính xác!");
        }

        if (!user.isActive()) {
            throw new Exception("Tài khoản của bạn đang bị khóa. Vui lòng liên hệ hỗ trợ!");
        }

        return user;
    }

    @Override
    public void register(String fullName, String email, String phone, String password, String confirmPassword) throws Exception {
        // 1. Validation - Required fields
        if (fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            throw new Exception("Vui lòng điền đầy đủ các thông tin bắt buộc!");
        }

        fullName = fullName.trim();
        email = email.trim();
        phone = (phone != null) ? phone.trim() : "";

        // 2. Validation - Full Name length
        if (fullName.length() < 2 || fullName.length() > 100) {
            throw new Exception("Họ và tên phải từ 2 đến 100 ký tự!");
        }

        // 3. Validation - Email format
        String emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
        if (!email.matches(emailRegex)) {
            throw new Exception("Định dạng Email không hợp lệ (Ví dụ: user@example.com)!");
        }

        // 4. Validation - Phone format
        if (!phone.isEmpty()) {
            String phoneRegex = "^(0[3|5|7|8|9])[0-9]{8}$";
            if (!phone.matches(phoneRegex)) {
                throw new Exception("Số điện thoại không hợp lệ (cần 10 chữ số, bắt đầu bằng 03, 05, 07, 08, 09)!");
            }
        }

        // 5. Validation - Password length
        if (password.length() < 6) {
            throw new Exception("Mật khẩu phải chứa ít nhất 6 ký tự!");
        }

        // 6. Validation - Password confirmation
        if (!password.equals(confirmPassword)) {
            throw new Exception("Mật khẩu xác nhận không trùng khớp!");
        }

        // 7. Check if Email already exists
        if (userDAO.isEmailExists(email)) {
            throw new Exception("Địa chỉ Email này đã được đăng ký. Vui lòng chọn Email khác hoặc Đăng nhập!");
        }

        // 8. Create new User entity with SHA-256 hashed password
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email.toLowerCase());
        newUser.setPhone(phone.isEmpty() ? null : phone);
        newUser.setPassword(PasswordUtil.hashPassword(password));
        newUser.setStatus(1); // ACTIVE

        boolean registered = userDAO.register(newUser);
        if (!registered) {
            throw new Exception("Đăng ký không thành công do lỗi hệ thống. Vui lòng thử lại sau!");
        }
    }

    @Override
    public String sendForgotPasswordOtp(String email) throws Exception {
        if (email == null || email.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập địa chỉ Email!");
        }

        email = email.trim();
        User user = userDAO.findByEmail(email);

        if (user == null) {
            throw new Exception("Email không tồn tại trong hệ thống Online Fruit Shop!");
        }

        if (!user.isActive()) {
            throw new Exception("Tài khoản này đang bị khóa. Vui lòng liên hệ quản trị viên!");
        }

        String otp = EmailUtil.generateOTP();
        boolean isSent = EmailUtil.sendOtpEmail(email, user.getFullName(), otp);

        if (!isSent) {
            throw new Exception("Không thể gửi email OTP lúc này. Vui lòng kiểm tra lại hòm thư hoặc thử lại sau!");
        }

        return otp;
    }

    @Override
    public void resetPassword(String email, String newPassword, String confirmPassword) throws Exception {
        if (email == null || email.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            throw new Exception("Vui lòng điền đầy đủ các thông tin!");
        }

        if (newPassword.length() < 6) {
            throw new Exception("Mật khẩu mới phải có ít nhất 6 ký tự!");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new Exception("Mật khẩu xác nhận không khớp với mật khẩu mới!");
        }

        email = email.trim();
        boolean isUpdated = userDAO.resetPassword(email, newPassword);
        if (!isUpdated) {
            throw new Exception("Cập nhật lại mật khẩu thất bại. Vui lòng thử lại!");
        }
    }

    @Override
    public void changePassword(int userId, String oldPassword, String newPassword, String confirmPassword) throws Exception {
        if (oldPassword == null || oldPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập đầy đủ tất cả các trường mật khẩu!");
        }

        if (newPassword.length() < 6) {
            throw new Exception("Mật khẩu mới phải có ít nhất 6 ký tự!");
        }

        if (oldPassword.equals(newPassword)) {
            throw new Exception("Mật khẩu mới không được trùng với mật khẩu cũ!");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new Exception("Mật khẩu xác nhận không khớp với mật khẩu mới!");
        }

        User freshUser = userDAO.findById(userId);
        if (freshUser == null) {
            throw new Exception("Không tìm thấy thông tin tài khoản người dùng!");
        }

        if (!PasswordUtil.verifyPassword(oldPassword, freshUser.getPassword())) {
            throw new Exception("Mật khẩu hiện tại (mật khẩu cũ) không chính xác!");
        }

        boolean isUpdated = userDAO.updatePassword(userId, newPassword);
        if (!isUpdated) {
            throw new Exception("Có lỗi xảy ra khi đổi mật khẩu. Vui lòng thử lại!");
        }
    }

    @Override
    public User getUserById(int userId) {
        return userDAO.findById(userId);
    }

    @Override
    public void updateProfile(int userId, String fullName, String phone, String gender, java.sql.Date birthDate) throws Exception {
        if (fullName == null || fullName.trim().isEmpty()) {
            throw new Exception("Họ và tên không được để trống!");
        }

        fullName = fullName.trim();
        if (fullName.length() < 2 || fullName.length() > 100) {
            throw new Exception("Họ và tên phải từ 2 đến 100 ký tự!");
        }

        boolean updated = userDAO.updateProfile(userId, fullName, phone, gender, birthDate);
        if (!updated) {
            throw new Exception("Có lỗi xảy ra khi cập nhật hồ sơ cá nhân. Vui lòng thử lại!");
        }
    }

    @Override
    public void updateAvatar(int userId, String avatarUrl) throws Exception {
        boolean updated = userDAO.updateAvatar(userId, avatarUrl);
        if (!updated) {
            throw new Exception("Không thể cập nhật ảnh đại diện vào cơ sở dữ liệu!");
        }
    }

    @Override
    public User processGoogleLogin(GoogleAccount googleAccount) throws Exception {
        if (googleAccount == null || googleAccount.getEmail() == null || googleAccount.getEmail().trim().isEmpty()) {
            throw new Exception("Không thể lấy thông tin tài khoản Google. Vui lòng thử lại!");
        }

        String googleEmail = googleAccount.getEmail().trim().toLowerCase();
        User user = userDAO.findByEmail(googleEmail);

        if (user == null) {
            // Tự động đăng ký tài khoản khách hàng mới cho lần đầu đăng nhập Google
            User newUser = new User();
            newUser.setEmail(googleEmail);

            String name = googleAccount.getName();
            if (name == null || name.trim().isEmpty()) {
                name = googleEmail.split("@")[0];
            }
            newUser.setFullName(name);

            // Mật khẩu ngẫu nhiên cho tài khoản OAuth
            newUser.setPassword(PasswordUtil.hashPassword(UUID.randomUUID().toString()));
            newUser.setPhone(null);
            newUser.setRole("CUSTOMER");
            newUser.setStatus(1); // ACTIVE

            boolean registered = userDAO.register(newUser);
            if (!registered) {
                throw new Exception("Đăng ký tài khoản Google mới thất bại. Vui lòng thử lại!");
            }

            user = userDAO.findByEmail(googleEmail);
            if (user == null) {
                throw new Exception("Không thể tải thông tin tài khoản vừa tạo từ Google!");
            }
        }

        if (!user.isActive()) {
            throw new Exception("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ!");
        }

        return user;
    }
}
