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

@WebServlet(name = "ShopProfileServlet", urlPatterns = {"/shop/profile"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 30
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

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        ShopRequest shop = shopRequestDAO.getShopRequestByUserId(user.getId());
        request.setAttribute("shop", shop);

        Shop realShop = shopDAO.getShopByOwnerId(user.getId());
        request.setAttribute("shopStatus", realShop != null ? realShop.getStatus() : "ACTIVE");

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
            if (birthDateStr != null && !birthDateStr.trim().isEmpty()) {
                try {
                    java.sql.Date birthDate = java.sql.Date.valueOf(birthDateStr.trim());
                    if (userDAO.updateBirthDate(user.getId(), birthDate)) {
                        user.setBirthDate(birthDate);
                    }
                } catch (IllegalArgumentException ignored) {
                }
            }

            if (logoUrl != null || bannerUrl != null) {
                shopDAO.updateShopMedia(user.getId(), logoUrl, bannerUrl);
            }

            String newStatus = null;
            if ("open".equals(statusParam)) newStatus = "ACTIVE";
            else if ("paused".equals(statusParam)) newStatus = "PAUSED";
            else if ("closed".equals(statusParam)) newStatus = "CLOSED";
            if (newStatus != null) {
                shopDAO.updateShopStatusBySeller(user.getId(), newStatus);
            }

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

        response.sendRedirect(request.getContextPath() + "/shop/profile");
    }
}
