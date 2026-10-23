package controller.auth;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.CustomerAddress;
import model.SubOrder;
import model.User;
import service.ICustomerAddressService;
import service.IOrderService;
import service.IUserService;
import service.impl.CustomerAddressServiceImpl;
import service.impl.OrderServiceImpl;
import service.impl.UserServiceImpl;

@WebServlet(name = "ProfileServlet", urlPatterns = { "/profile" })
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 1, maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 10)
public class ProfileServlet extends HttpServlet {

    private final IUserService userService = new UserServiceImpl();
    private final ICustomerAddressService addressService = new CustomerAddressServiceImpl();
    private final IOrderService orderService = new OrderServiceImpl();

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
        try {
            List<CustomerAddress> addresses = addressService.getAddressesByUserId(targetUserId);
            request.setAttribute("addresses", addresses);
        } catch (Exception ex) {
            request.setAttribute("addresses", Collections.emptyList());
        }

        try {
            List<SubOrder> orders = orderService.getSubOrdersByCustomerId(targetUserId);
            request.setAttribute("orders", orders != null ? orders : Collections.emptyList());
            request.setAttribute("ordersCount", orders != null ? orders.size() : 0);
        } catch (Exception ex) {
            request.setAttribute("orders", Collections.emptyList());
            request.setAttribute("ordersCount", 0);
        }

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

        switch (action) {
            case "uploadAvatar":
                handleUploadAvatar(request, response, session, sessionUser);
                break;
            case "deleteAvatar":
                handleDeleteAvatar(request, response, session, sessionUser);
                break;
            case "changePassword":
                handleChangePassword(request, response, session, sessionUser);
                break;
            case "addAddress":
                handleAddAddress(request, response, session, sessionUser);
                break;
            case "setDefaultAddress":
                handleSetDefaultAddress(request, response, session, sessionUser);
                break;
            case "deleteAddress":
                handleDeleteAddress(request, response, session, sessionUser);
                break;
            case "cancelOrder":
                handleCancelOrder(request, response, session, sessionUser);
                break;
            case "updateProfile":
            default:
                handleUpdateProfile(request, response, session, sessionUser);
                break;
        }
    }

    private void handleUploadAvatar(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
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
                session.setAttribute("errorMessage",
                        "Định dạng file không hỗ trợ! Vui lòng chọn ảnh JPG, PNG hoặc WEBP.");
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
    }

    private void handleDeleteAvatar(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
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
    }

    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
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
    }

    private void handleAddAddress(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
        String recipientName = request.getParameter("recipientName");
        String recipientPhone = request.getParameter("recipientPhone");
        String city = request.getParameter("city");
        String district = request.getParameter("district");
        String ward = request.getParameter("ward");
        String streetAddress = request.getParameter("streetAddress");
        boolean isDefault = "true".equalsIgnoreCase(request.getParameter("isDefault"));

        CustomerAddress newAddress = new CustomerAddress();
        newAddress.setUserId((long) sessionUser.getId());
        newAddress.setRecipientName(recipientName);
        newAddress.setRecipientPhone(recipientPhone);
        newAddress.setCity(city);
        newAddress.setDistrict(district);
        newAddress.setWard(ward);
        newAddress.setStreetAddress(streetAddress);
        newAddress.setDefault(isDefault);

        try {
            addressService.addAddress(newAddress);
            session.setAttribute("successMessage", "Thêm địa chỉ nhận hàng mới thành công!");
        } catch (Exception e) {
            session.setAttribute("errorMessage", e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/profile#address");
    }

    private void handleSetDefaultAddress(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
        try {
            long addressId = Long.parseLong(request.getParameter("addressId"));
            addressService.setDefaultAddress(addressId, (long) sessionUser.getId());
            session.setAttribute("successMessage", "Đã đặt làm địa chỉ nhận hàng mặc định!");
        } catch (Exception e) {
            session.setAttribute("errorMessage", e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/profile#address");
    }

    private void handleDeleteAddress(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
        try {
            long addressId = Long.parseLong(request.getParameter("addressId"));
            addressService.deleteAddress(addressId, (long) sessionUser.getId());
            session.setAttribute("successMessage", "Đã xóa địa chỉ nhận hàng!");
        } catch (Exception e) {
            session.setAttribute("errorMessage", e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/profile#address");
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
        try {
            User currentUser = userService.getUserById(sessionUser.getId());
            if (currentUser == null) {
                currentUser = sessionUser;
            }

            processAvatar(request, sessionUser);

            String fullName = request.getParameter("fullName");
            String gender = request.getParameter("gender");
            String phone = resolvePhone(request.getParameter("phone"), currentUser.getPhone());
            java.sql.Date birthDate = parseBirthDate(request.getParameter("birthDate"), currentUser.getBirthDate());

            userService.updateProfile(sessionUser.getId(), fullName, phone, gender, birthDate);
            refreshUserSession(session, sessionUser.getId());

            session.setAttribute("successMessage", "Lưu thay đổi hồ sơ cá nhân thành công!");
        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("errorMessage", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private void processAvatar(HttpServletRequest request, User sessionUser) {
        String deleteAvatar = request.getParameter("deleteAvatar");

        if ("true".equalsIgnoreCase(deleteAvatar)) {
            try {
                userService.updateAvatar(sessionUser.getId(), null);
            } catch (Exception ignored) {
            }
            return;
        }

        try {
            Part filePart = request.getPart("avatarFile");
            if (filePart == null || filePart.getSize() == 0) {
                return;
            }

            if (filePart.getSize() > 2 * 1024 * 1024) {
                throw new IllegalArgumentException("Kích thước ảnh tối đa là 2MB!");
            }

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = fileName.contains(".") ? fileName.substring(fileName.lastIndexOf('.')).toLowerCase() : "";
            if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".webp")) {
                throw new IllegalArgumentException(
                        "Định dạng file không hỗ trợ! Vui lòng chọn ảnh JPG, PNG hoặc WEBP.");
            }

            String newFileName = "avatar_" + sessionUser.getId() + "_" + System.currentTimeMillis() + ext;
            String uploadDirRealPath = request.getServletContext().getRealPath("/assets/images/avatars");
            File uploadDir = new File(uploadDirRealPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            filePart.write(uploadDirRealPath + File.separator + newFileName);
            userService.updateAvatar(sessionUser.getId(), "assets/images/avatars/" + newFileName);
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception ignored) {
        }
    }

    private String resolvePhone(String inputPhone, String currentPhone) {
        if (inputPhone == null || inputPhone.trim().isEmpty()) {
            return null;
        }
        return inputPhone.contains("*") ? currentPhone : inputPhone.trim();
    }

    private java.sql.Date parseBirthDate(String dateStr, java.sql.Date currentBirthDate) {
        if (dateStr == null || dateStr.trim().isEmpty() || dateStr.contains("*")) {
            return currentBirthDate;
        }
        try {
            return java.sql.Date.valueOf(dateStr.trim());
        } catch (IllegalArgumentException e) {
            return currentBirthDate;
        }
    }

    private void refreshUserSession(HttpSession session, int userId) {
        if (session == null) {
            return;
        }
        User updatedUser = userService.getUserById(userId);
        if (updatedUser != null) {
            session.setAttribute("user", updatedUser);
        }
    }

    private void handleCancelOrder(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, User sessionUser) throws IOException {
        String orderId = request.getParameter("orderId");
        String reason = request.getParameter("reason");
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Người mua hủy đơn trực tiếp";
        }

        try {
            if (orderId == null || orderId.trim().isEmpty()) {
                throw new IllegalArgumentException("Mã đơn hàng không hợp lệ!");
            }

            boolean ok = orderService.cancelOrderByCustomer(sessionUser.getId(), orderId.trim(), reason.trim());
            if (ok) {
                setSessionFlash(session, "successMessage", "Đã hủy đơn hàng #" + orderId.trim() + " thành công!");
            } else {
                setSessionFlash(session, "errorMessage", "Không thể hủy đơn hàng. Vui lòng thử lại!");
            }
        } catch (Exception ex) {
            setSessionFlash(session, "errorMessage", ex.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/profile#orders");
    }

    private void setSessionFlash(HttpSession session, String key, String message) {
        if (session != null) {
            session.setAttribute(key, message);
        }
    }
}
