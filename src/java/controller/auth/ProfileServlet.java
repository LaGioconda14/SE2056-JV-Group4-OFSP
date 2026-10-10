package controller.auth;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.util.List;
import model.CustomerAddress;
import model.User;
import service.ICustomerAddressService;
import service.IUserService;
import service.impl.CustomerAddressServiceImpl;
import service.impl.UserServiceImpl;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)
public class ProfileServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();
    private final ICustomerAddressService addressService = new CustomerAddressServiceImpl();

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

        User currentUser = userService.getUserById(sessionUser.getId());
        if (currentUser != null) {
            session.setAttribute("user", currentUser);
            request.setAttribute("user", currentUser);
        } else {
            request.setAttribute("user", sessionUser);
        }
        long targetUserId = (currentUser != null) ? currentUser.getId() : sessionUser.getId();
        List<CustomerAddress> addresses = addressService.getAddressesByUserId(targetUserId);
        request.setAttribute("addresses", addresses);

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
            String warningMsg = (String) session.getAttribute("warningMessage");
            if (warningMsg != null) {
                request.setAttribute("warningMessage", warningMsg);
                session.removeAttribute("warningMessage");
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

                String avatarUrl = "assets/images/avatars/" + newFileName;
                userService.updateAvatar(sessionUser.getId(), avatarUrl);

                User refreshed = userService.getUserById(sessionUser.getId());
                if (refreshed != null) {
                    session.setAttribute("user", refreshed);
                }
                session.setAttribute("successMessage", "Cập nhật ảnh đại diện thành công!");

            } catch (Exception e) {
                session.setAttribute("errorMessage", "Lỗi trong quá trình tải ảnh lên: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile");
            return;

        } else if ("deleteAvatar".equals(action)) {
            try {
                userService.updateAvatar(sessionUser.getId(), null);
                User refreshed = userService.getUserById(sessionUser.getId());
                if (refreshed != null) {
                    session.setAttribute("user", refreshed);
                }
                session.setAttribute("successMessage", "Đã xóa ảnh đại diện thành công!");
            } catch (Exception e) {
                session.setAttribute("errorMessage", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile");
            return;

        } else if ("changePassword".equals(action)) {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            try {
                userService.changePassword(sessionUser.getId(), oldPassword, newPassword, confirmPassword);
                session.setAttribute("successMessage", "Cập nhật mật khẩu bảo vệ tài khoản thành công!");
            } catch (Exception e) {
                session.setAttribute("errorMessage", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile#security");
            return;

        } else if ("addAddress".equals(action)) {
            String recipientName = request.getParameter("recipientName");
            String recipientPhone = request.getParameter("recipientPhone");
            String streetAddress = request.getParameter("streetAddress");
            String ward = request.getParameter("ward");
            String district = request.getParameter("district");
            String city = request.getParameter("city");
            String isDefaultParam = request.getParameter("isDefault");
            boolean isDefault = "true".equalsIgnoreCase(isDefaultParam) 
                             || "on".equalsIgnoreCase(isDefaultParam) 
                             || "1".equals(isDefaultParam);

            try {
                CustomerAddress newAddr = new CustomerAddress();
                newAddr.setUserId(sessionUser.getId());
                newAddr.setRecipientName(recipientName);
                newAddr.setRecipientPhone(recipientPhone);
                newAddr.setStreetAddress(streetAddress);
                newAddr.setWard(ward);
                newAddr.setDistrict(district);
                newAddr.setCity(city);
                newAddr.setDefault(isDefault);

                boolean success = addressService.addAddress(newAddr);
                if (success) {
                    session.setAttribute("successMessage", "Thêm địa chỉ nhận hàng thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể lưu địa chỉ. Vui lòng kiểm tra lại thông tin!");
                }
            } catch (IllegalArgumentException ex) {
                session.setAttribute("errorMessage", ex.getMessage());
            } catch (Exception ex) {
                session.setAttribute("errorMessage", "Lỗi xử lý thêm địa chỉ: " + ex.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile#address");
            return;

        } else if ("setDefaultAddress".equals(action)) {
            try {
                long addressId = Long.parseLong(request.getParameter("addressId"));
                boolean success = addressService.setDefaultAddress(addressId, sessionUser.getId());
                if (success) {
                    session.setAttribute("successMessage", "Đã thiết lập địa chỉ mặc định thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật địa chỉ mặc định!");
                }
            } catch (Exception ex) {
                session.setAttribute("errorMessage", "Lỗi: " + ex.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile#address");
            return;

        } else if ("deleteAddress".equals(action)) {
            try {
                long addressId = Long.parseLong(request.getParameter("addressId"));
                boolean success = addressService.deleteAddress(addressId, sessionUser.getId());
                if (success) {
                    session.setAttribute("successMessage", "Đã xóa địa chỉ nhận hàng thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể xóa địa chỉ này!");
                }
            } catch (Exception ex) {
                session.setAttribute("errorMessage", "Lỗi khi xóa địa chỉ: " + ex.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile#address");
            return;

        } else {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String gender = request.getParameter("gender");
            String birthDateStr = request.getParameter("birthDate");

            User currentUser = userService.getUserById(sessionUser.getId());
            if (currentUser == null) {
                currentUser = sessionUser;
            }

            String phoneToUpdate = (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null;
            if (phoneToUpdate != null && (phoneToUpdate.contains("*") || phoneToUpdate.equalsIgnoreCase("Chưa cập nhật"))) {
                phoneToUpdate = currentUser.getPhone();
            }

            java.sql.Date birthDateToUpdate = currentUser.getBirthDate();
            if (birthDateStr != null && !birthDateStr.trim().isEmpty() && !birthDateStr.contains("*")) {
                try {
                    birthDateToUpdate = java.sql.Date.valueOf(birthDateStr.trim());
                } catch (IllegalArgumentException e) {
                }
            } else if (birthDateStr != null && birthDateStr.trim().isEmpty()) {
                birthDateToUpdate = null;
            }

            try {
                userService.updateProfile(sessionUser.getId(), fullName, phoneToUpdate, gender, birthDateToUpdate);
                User refreshedUser = userService.getUserById(sessionUser.getId());
                if (refreshedUser != null) {
                    session.setAttribute("user", refreshedUser);
                }
                if (phoneToUpdate != null && !phoneToUpdate.trim().isEmpty()) {
                    session.removeAttribute("phoneMissingWarning");
                    session.removeAttribute("warningMessage");
                }
                session.setAttribute("successMessage", "Lưu thay đổi hồ sơ cá nhân thành công!");
            } catch (Exception e) {
                session.setAttribute("errorMessage", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/profile");
        }
    }
}
