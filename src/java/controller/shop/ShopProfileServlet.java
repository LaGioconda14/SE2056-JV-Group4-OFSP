package controller.shop;

import dao.ShopDAO;
import dao.ShopRequestDAO;
import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Shop;
import model.ShopRequest;
import model.User;
import util.CloudinaryUtil;

/**
 * Servlet handling Shop Profile view and update.
 * Multipart để nhận ảnh logo / banner.
 */
@WebServlet(name = "ShopProfileServlet", urlPatterns = {"/shop/profile"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 30     // 30MB
)
public class ShopProfileServlet extends HttpServlet {

    private final ShopRequestDAO shopRequestDAO = new ShopRequestDAO();
    private final ShopDAO shopDAO = new ShopDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Kiểm tra quyền đăng nhập và role chủ shop
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Thông tin hồ sơ shop (shop_requests)
        ShopRequest shop = shopRequestDAO.getShopRequestByUserId(user.getId());
        request.setAttribute("shop", shop);

        // Trạng thái hiện tại của shop (shops.status): ACTIVE / PAUSED / CLOSED / ...
        Shop realShop = shopDAO.getShopByOwnerId(user.getId());
        request.setAttribute("shopStatus", realShop != null ? realShop.getStatus() : "ACTIVE");

        // Thông tin chủ shop mới nhất (email, ngày sinh)
        User owner = userDAO.findById(user.getId());
        request.setAttribute("owner", owner != null ? owner : user);

        request.getRequestDispatcher("/views/shop/shop-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Nhận dữ liệu cập nhật từ các tab form trên giao diện
        String shopName = request.getParameter("shopName");
        String businessType = request.getParameter("businessType");
        String shopDescription = request.getParameter("shopDescription");
        String idCardNumber = request.getParameter("idCardNumber");
        String taxCode = request.getParameter("taxCode");
        String province = request.getParameter("province");
        String district = request.getParameter("district");
        String ward = request.getParameter("ward");
        String streetAddress = request.getParameter("streetAddress");
        String pickupAddress = request.getParameter("pickupAddress");
        String returnAddress = request.getParameter("returnAddress");
        String bankName = request.getParameter("bankName");
        String bankAccountNumber = request.getParameter("bankAccountNumber");
        String bankAccountHolder = request.getParameter("bankAccountHolder");
        String birthDateStr = request.getParameter("birthDate");
        String statusParam = request.getParameter("shopStatus");

        // Upload ảnh mới (nếu có) lên Cloudinary; không chọn ảnh -> null -> giữ ảnh cũ
        String logoUrl = null;
        String bannerUrl = null;
        try {
            Part logoPart = request.getPart("shopLogo");
            Part bannerPart = request.getPart("shopBanner");
            logoUrl = CloudinaryUtil.uploadImage(logoPart, "shop_requests/logos");
            bannerUrl = CloudinaryUtil.uploadImage(bannerPart, "shop_requests/banners");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Không tải được ảnh lên, vui lòng thử lại (ảnh tối đa 10MB).");
            response.sendRedirect(request.getContextPath() + "/shop/profile");
            return;
        }

        // Đóng gói dữ liệu vào đối tượng ShopRequest để gọi DAO cập nhật
        ShopRequest shop = new ShopRequest();
        shop.setUserId(user.getId());
        shop.setShopName(shopName);
        shop.setBusinessType(businessType);
        shop.setShopDescription(shopDescription);
        shop.setIdCardNumber(idCardNumber);
        shop.setTaxCode(taxCode);
        shop.setProvince(province);
        shop.setDistrict(district);
        shop.setWard(ward);
        shop.setStreetAddress(streetAddress);
        shop.setPickupAddress(pickupAddress);
        shop.setReturnAddress(returnAddress);
        shop.setBankName(bankName);
        shop.setBankAccountNumber(bankAccountNumber);
        shop.setBankAccountHolder(bankAccountHolder);
        shop.setShopLogoUrl(logoUrl);
        shop.setShopBannerUrl(bannerUrl);

        boolean success = shopRequestDAO.updateShopProfile(shop);

        if (success) {
            // Ngày sinh chủ shop (users.birth_date)
            if (birthDateStr != null && !birthDateStr.trim().isEmpty()) {
                try {
                    java.sql.Date birthDate = java.sql.Date.valueOf(birthDateStr.trim());
                    if (userDAO.updateBirthDate(user.getId(), birthDate)) {
                        user.setBirthDate(birthDate);
                    }
                } catch (IllegalArgumentException ignored) {
                    // Định dạng ngày không hợp lệ -> bỏ qua
                }
            }

            // Logo/banner vào bảng shops để storefront hiển thị ảnh mới
            if (logoUrl != null || bannerUrl != null) {
                shopDAO.updateShopMedia(user.getId(), logoUrl, bannerUrl);
            }

            // Trạng thái shop: open / paused / closed
            String newStatus = null;
            if ("open".equals(statusParam)) newStatus = "ACTIVE";
            else if ("paused".equals(statusParam)) newStatus = "PAUSED";
            else if ("closed".equals(statusParam)) newStatus = "CLOSED";
            if (newStatus != null) {
                shopDAO.updateShopStatusBySeller(user.getId(), newStatus);
            }

            // Làm mới thông tin shop trong session để sidebar/header hiển thị đúng ngay
            Shop refreshed = shopDAO.getShopByOwnerId(user.getId());
            if (refreshed != null) {
                session.setAttribute("shopObj", refreshed);
                session.setAttribute("shopLogo", refreshed.getLogoUrl());
                session.setAttribute("shop", refreshed.getStatus());
            }
            if (shopName != null && !shopName.trim().isEmpty()) {
                session.setAttribute("shopName", shopName.trim());
            }
            session.setAttribute("successMessage", "Cập nhật thông tin shop thành công!");
        } else {
            session.setAttribute("errorMessage", "Cập nhật thất bại, vui lòng thử lại.");
        }

        // Chuyển hướng lại trang profile sau khi cập nhật xong
        response.sendRedirect(request.getContextPath() + "/shop/profile");
    }
}
