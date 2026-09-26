package controller.auth;

import dao.UserDAO;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import model.User;
import util.PasswordUtil;

/**
 * Controller handling User Profile, Account Settings, Avatar Upload, and Password Updates.
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1MB
    maxFileSize = 1024 * 1024 * 5,       // 5MB
    maxRequestSize = 1024 * 1024 * 10    // 10MB
)
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Tải thông tin mới nhất từ cơ sở dữ liệu
        User currentUser = userDAO.findById(sessionUser.getId());
        if (currentUser != null) {
            session.setAttribute("user", currentUser);
            request.setAttribute("user", currentUser);
        } else {
            request.setAttribute("user", sessionUser);
        }

        // Chuyển flash message từ session sang request (nếu có)
        if (session != null) {
            String successMsg = (String) session.getAttribute("successMessage");
            if (successMsg != null) {
                request.setAttribute("successMessage", successMsg);
                session.removeAttribute("successMessage");
            }
            String errorMsg = (String) session.getAttribute("errorMessage");
            if (errorMsg != null) {
                request.setAttribute("errorMessage", errorMsg);
                session.removeAttribute("errorMessage");
            }
        }

        request.getRequestDispatcher("/views/auth/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "updateProfile";
        }

        if ("uploadAvatar".equals(action)) {
            // Xử lý tải lên ảnh đại diện mới
            try {
                Part filePart = request.getPart("avatarFile");
                if (filePart == null || filePart.getSize() == 0) {
                    session.setAttribute("errorMessage", "Vui lòng chọn một file ảnh để tải lên!");
                    response.sendRedirect(request.getContextPath() + "/profile");
                    return;
                }

                String submittedFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String ext = "";
                int dotIndex = submittedFileName.lastIndexOf('.');
                if (dotIndex > 0) {
                    ext = submittedFileName.substring(dotIndex).toLowerCase();
                }

                if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".webp")) {
                    session.setAttribute("errorMessage", "Định dạng file không hỗ trợ! Vui lòng chọn ảnh JPG, PNG hoặc WEBP.");
                    response.sendRedirect(request.getContextPath() + "/profile");
                    return;
                }

                if (filePart.getSize() > 2 * 1024 * 1024) {
                    session.setAttribute("errorMessage", "Kích thước ảnh tối đa là 2MB!");
                    response.sendRedirect(request.getContextPath() + "/profile");
                    return;
                }

                String newFileName = "avatar_" + sessionUser.getId() + "_" + System.currentTimeMillis() + ext;
                String uploadDirRealPath = request.getServletContext().getRealPath("/assets/images/avatars");
                File uploadDir = new File(uploadDirRealPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String savedFilePath = uploadDirRealPath + File.separator + newFileName;
                filePart.write(savedFilePath);

                // Đường dẫn tương đối lưu vào DB
                String avatarUrl = "assets/images/avatars/" + newFileName;
                boolean updated = userDAO.updateAvatar(sessionUser.getId(), avatarUrl);

                if (updated) {
                    User refreshed = userDAO.findById(sessionUser.getId());
                    if (refreshed != null) {
                        session.setAttribute("user", refreshed);
                    }
                    session.setAttribute("successMessage", "Cập nhật ảnh đại diện thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật ảnh đại diện vào cơ sở dữ liệu!");
                }

            } catch (Exception e) {
                session.setAttribute("errorMessage", "Lỗi trong quá trình tải ảnh lên: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile");
            return;

        } else if ("deleteAvatar".equals(action)) {
            // Xóa ảnh đại diện hiện tại
            boolean updated = userDAO.updateAvatar(sessionUser.getId(), null);
            if (updated) {
                User refreshed = userDAO.findById(sessionUser.getId());
                if (refreshed != null) {
                    session.setAttribute("user", refreshed);
                }
                session.setAttribute("successMessage", "Đã xóa ảnh đại diện thành công!");
            } else {
                session.setAttribute("errorMessage", "Có lỗi xảy ra khi xóa ảnh đại diện!");
            }
            response.sendRedirect(request.getContextPath() + "/profile");
            return;

        } else if ("changePassword".equals(action)) {
            // Xử lý đổi mật khẩu từ trong trang profile
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (oldPassword == null || oldPassword.trim().isEmpty() ||
                newPassword == null || newPassword.trim().isEmpty() ||
                confirmPassword == null || confirmPassword.trim().isEmpty()) {
                
                session.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường mật khẩu!");
                response.sendRedirect(request.getContextPath() + "/profile#security");
                return;
            }

            if (newPassword.length() < 6) {
                session.setAttribute("errorMessage", "Mật khẩu mới phải có ít nhất 6 ký tự!");
                response.sendRedirect(request.getContextPath() + "/profile#security");
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                session.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp!");
                response.sendRedirect(request.getContextPath() + "/profile#security");
                return;
            }

            // Kiểm tra mật khẩu cũ
            User userDb = userDAO.findById(sessionUser.getId());
            if (userDb == null || !PasswordUtil.verifyPassword(oldPassword, userDb.getPassword())) {
                session.setAttribute("errorMessage", "Mật khẩu hiện tại không chính xác!");
                response.sendRedirect(request.getContextPath() + "/profile#security");
                return;
            }

            // Cập nhật mật khẩu mới
            boolean updated = userDAO.updatePassword(sessionUser.getId(), newPassword);
            if (updated) {
                session.setAttribute("successMessage", "Cập nhật mật khẩu bảo vệ tài khoản thành công!");
            } else {
                session.setAttribute("errorMessage", "Có lỗi xảy ra khi cập nhật mật khẩu. Vui lòng thử lại!");
            }
            response.sendRedirect(request.getContextPath() + "/profile#security");

        } else {
            // Mặc định: Cập nhật thông tin cá nhân (Họ tên, SĐT, Giới tính, Ngày sinh)
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String gender = request.getParameter("gender");
            String birthDateStr = request.getParameter("birthDate");

            if (fullName == null || fullName.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Họ và tên không được để trống!");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            // Lấy thông tin hiện tại từ DB để bảo vệ các trường che mặt nạ (masked)
            User currentUser = userDAO.findById(sessionUser.getId());
            if (currentUser == null) {
                currentUser = sessionUser;
            }

            // Nếu người dùng không sửa SĐT mà để nguyên dạng che sao (chứa '*'), giữ nguyên SĐT cũ
            String phoneToUpdate = (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null;
            if (phoneToUpdate != null && phoneToUpdate.contains("*")) {
                phoneToUpdate = currentUser.getPhone();
            }

            // Xử lý ngày sinh
            java.sql.Date birthDateToUpdate = currentUser.getBirthDate();
            if (birthDateStr != null && !birthDateStr.trim().isEmpty() && !birthDateStr.contains("*")) {
                try {
                    birthDateToUpdate = java.sql.Date.valueOf(birthDateStr.trim());
                } catch (IllegalArgumentException e) {
                    // Định dạng ngày không hợp lệ, giữ nguyên
                }
            }

            boolean updated = userDAO.updateProfile(sessionUser.getId(), fullName, phoneToUpdate, gender, birthDateToUpdate);
            if (updated) {
                User refreshedUser = userDAO.findById(sessionUser.getId());
                if (refreshedUser != null) {
                    session.setAttribute("user", refreshedUser);
                }
                session.setAttribute("successMessage", "Lưu thay đổi hồ sơ cá nhân thành công!");
            } else {
                session.setAttribute("errorMessage", "Có lỗi xảy ra khi lưu thông tin. Vui lòng thử lại!");
            }
            response.sendRedirect(request.getContextPath() + "/profile");
        }
    }
}
