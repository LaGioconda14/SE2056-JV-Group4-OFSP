package controller.seller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ShopRequest;
import model.User;
import service.IShopRequestService;
import service.impl.ShopRequestServiceImpl;
import util.CloudinaryUtil;

import java.io.IOException;

@WebServlet(name = "RegisterShopServlet", urlPatterns = {"/register-shop"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class RegisterShopServlet extends HttpServlet {

    private IShopRequestService shopRequestService = new ShopRequestServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("account");
        if (currentUser == null) {
            currentUser = (User) session.getAttribute("user"); // Thử check cả key "user" dự phòng
        }

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/views/shop/register-shop.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            // 1. Lấy thông tin user hiện tại từ Session (Kiểm tra cả "account" và "user")
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("account");
            if (currentUser == null) {
                currentUser = (User) session.getAttribute("user");
            }

            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // 2. Lấy dữ liệu Text từ Form
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

            // 3. Xử lý Upload các file Ảnh lên Cloudinary trực tiếp
            String idFrontUrl = CloudinaryUtil.uploadImage(request.getPart("idCardFront"), "shop_requests/cccd");
            String idBackUrl  = CloudinaryUtil.uploadImage(request.getPart("idCardBack"), "shop_requests/cccd");
            String logoUrl    = CloudinaryUtil.uploadImage(request.getPart("shopLogo"), "shop_requests/logos");
            String bannerUrl  = CloudinaryUtil.uploadImage(request.getPart("shopBanner"), "shop_requests/banners");

            // 4. Tạo đối tượng ShopRequest và gán URL ảnh nhận được từ Cloudinary
            ShopRequest shopReq = new ShopRequest();
            shopReq.setUserId(currentUser.getId());
            shopReq.setShopName(shopName);
            shopReq.setBusinessType(businessType);
            shopReq.setShopDescription(shopDescription);
            shopReq.setIdCardNumber(idCardNumber);
            shopReq.setTaxCode(taxCode);
            shopReq.setProvince(province);
            shopReq.setDistrict(district);
            shopReq.setWard(ward);
            shopReq.setStreetAddress(streetAddress);
            shopReq.setPickupAddress(pickupAddress);
            shopReq.setReturnAddress(returnAddress);
            shopReq.setBankName(bankName);
            shopReq.setBankAccountNumber(bankAccountNumber);
            shopReq.setBankAccountHolder(bankAccountHolder);

            shopReq.setIdCardFrontUrl(idFrontUrl);
            shopReq.setIdCardBackUrl(idBackUrl);
            shopReq.setShopLogoUrl(logoUrl);
            shopReq.setShopBannerUrl(bannerUrl);

            // 5. Lưu vào Database thông qua Service
            boolean isSuccess = shopRequestService.submitShopRequest(shopReq);

            if (isSuccess) {
                request.setAttribute("message", "Gửi yêu cầu đăng ký gian hàng thành công! Vui lòng chờ Admin phê duyệt.");
                request.getRequestDispatcher("/views/shop/register-success.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Đã xảy ra lỗi khi lưu vào cơ sở dữ liệu. Vui lòng thử lại!");
                request.getRequestDispatcher("/views/shop/register-shop.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace(); // In lỗi chi tiết ra console Tomcat nếu có sự cố
            request.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("/views/shop/register-shop.jsp").forward(request, response);
        }
    }
}