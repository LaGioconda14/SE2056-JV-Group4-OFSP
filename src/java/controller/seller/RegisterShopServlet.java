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
import util.SellerSessionUtil;

import java.io.IOException;

/**
 * Form đăng ký trở thành người bán (seller).
 *  - Chỉ tài khoản CUSTOMER mới đăng ký được; tài khoản vẫn là CUSTOMER trong lúc chờ admin duyệt.
 *  - Đã có hồ sơ đang chờ / đã duyệt thì chuyển sang /seller/status, không cho nộp trùng.
 *  - Hồ sơ bị từ chối thì được sửa và gửi lại.
 */
@WebServlet(name = "RegisterShopServlet", urlPatterns = {"/register-shop"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class RegisterShopServlet extends HttpServlet {

    private final IShopRequestService shopRequestService = new ShopRequestServiceImpl();

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("account");
        if (currentUser == null) {
            currentUser = (User) session.getAttribute("user"); // key dự phòng
        }
        return currentUser;
    }

    /**
     * Kiểm tra user có được đăng ký bán hàng không.
     *
     * @return true nếu đã chuyển hướng đi nơi khác (không cho hiện / nhận form)
     */
    private boolean redirectIfNotAllowed(User user, HttpServletRequest request,
            HttpServletResponse response, boolean exposeRejectedRequest) throws IOException {
        String ctx = request.getContextPath();
        String role = (user.getRole() == null) ? "CUSTOMER" : user.getRole().toUpperCase();

        if ("SHOP_OWNER".equals(role)) {
            response.sendRedirect(ctx + "/seller/enter");
            return true;
        }
        if (!"CUSTOMER".equals(role)) {
            response.sendRedirect(ctx + "/home");
            return true;
        }

        ShopRequest latest = shopRequestService.getLatestRequestByUserId(user.getId());
        if (latest != null) {
            if (SellerSessionUtil.isPending(latest.getStatus()) || SellerSessionUtil.isApproved(latest.getStatus())) {
                response.sendRedirect(ctx + "/seller/status");
                return true;
            }
            if (exposeRejectedRequest && SellerSessionUtil.isRejected(latest.getStatus())) {
                request.setAttribute("rejectedRequest", latest);
            }
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (redirectIfNotAllowed(currentUser, request, response, true)) {
            return;
        }

        request.getRequestDispatcher("/views/shop/register-shop.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            // 1. Lấy thông tin user hiện tại từ Session
            User currentUser = getCurrentUser(request);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            // Chặn nộp trùng khi đã có hồ sơ chờ duyệt / đã duyệt
            if (redirectIfNotAllowed(currentUser, request, response, false)) {
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

            // 3. Upload các file ảnh lên Cloudinary
            String idFrontUrl = CloudinaryUtil.uploadImage(request.getPart("idCardFront"), "shop_requests/cccd");
            String idBackUrl = CloudinaryUtil.uploadImage(request.getPart("idCardBack"), "shop_requests/cccd");
            String logoUrl = CloudinaryUtil.uploadImage(request.getPart("shopLogo"), "shop_requests/logos");
            String bannerUrl = CloudinaryUtil.uploadImage(request.getPart("shopBanner"), "shop_requests/banners");

            // 4. Tạo ShopRequest
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

            // 5. Lưu vào Database (status = PENDING). Tài khoản vẫn là CUSTOMER cho tới khi admin duyệt.
            boolean isSuccess = shopRequestService.submitShopRequest(shopReq);

            if (isSuccess) {
                // Redirect (PRG) để F5 không gửi lại hồ sơ
                response.sendRedirect(request.getContextPath() + "/seller/status?submitted=1");
            } else {
                request.setAttribute("errorMessage", "Đã xảy ra lỗi khi lưu vào cơ sở dữ liệu. Vui lòng thử lại!");
                request.getRequestDispatcher("/views/shop/register-shop.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            request.getRequestDispatcher("/views/shop/register-shop.jsp").forward(request, response);
        }
    }
}
