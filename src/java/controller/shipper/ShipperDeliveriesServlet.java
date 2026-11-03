package controller.shipper;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Delivery;
import model.DriverProfile;
import model.User;
import service.IDeliveryService;
import service.IDriverService;
import service.impl.DeliveryServiceImpl;
import service.impl.DriverServiceImpl;
import service.INotificationService;
import service.impl.NotificationServiceImpl;
import java.io.File;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import util.CloudinaryUtil;

@WebServlet(name = "ShipperDeliveriesServlet", urlPatterns = {"/shipper/deliveries"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 30     // 30MB
)
public class ShipperDeliveriesServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ShipperDeliveriesServlet.class.getName());

    private final IDeliveryService deliveryService = new DeliveryServiceImpl();
    private final IDriverService driverService = new DriverServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!"DRIVER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        long driverId = user.getId();
        DriverProfile driverProfile = driverService.getDriverProfileByUserId(driverId);
        if (driverProfile == null) {
            driverProfile = new DriverProfile();
            driverProfile.setUserId(driverId);
            driverProfile.setFullName(user.getFullName());
            driverProfile.setPhone(user.getPhone());
            driverProfile.setApprovalStatus("PENDING");
            driverProfile.setAvailabilityStatus("UNAVAILABLE");
        }


        List<Delivery> deliveries = deliveryService.getDeliveriesByDriver(driverId, "all", null);

        int activeOrderCount = 0;
        if (deliveries != null) {
            for (Delivery d : deliveries) {
                if (d.getDeliveryStatus() != null) {
                    String st = d.getDeliveryStatus().toUpperCase();
                    if ("ASSIGNING".equals(st) || "ASSIGNED".equals(st) || "DELIVERING".equals(st) || "IN_TRANSIT".equals(st) || "PICKED_UP".equals(st)) {
                        activeOrderCount++;
                    }
                }
            }
        }

        BigDecimal totalCod = deliveryService.getTotalCodCollected(driverId);

        request.setAttribute("deliveries", deliveries);
        request.setAttribute("driverProfile", driverProfile);
        request.setAttribute("activeOrderCount", activeOrderCount);
        request.setAttribute("totalCod", totalCod);

        request.getRequestDispatcher("/views/shipper/deliveries.jsp").forward(request, response);
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

        if (!"DRIVER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        long driverId = user.getId();

        String action = request.getParameter("action");
        String deliveryIdStr = request.getParameter("deliveryId");

        if (deliveryIdStr == null || deliveryIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
            return;
        }
        long deliveryId;
        try {
            deliveryId = Long.parseLong(deliveryIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
            return;
        }
        if ("pickup".equalsIgnoreCase(action)) {
            boolean ok = deliveryService.confirmPickup(deliveryId, driverId);
            if (ok) {
                session.setAttribute("successMessage", "Đã xác nhận lấy hàng thành công! Đơn hàng chuyển sang trạng thái Đang giao.");
            } else {
                session.setAttribute("errorMessage", "Không thể xác nhận lấy hàng. Vui lòng thử lại!");
            }
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
            return;
        }

        if ("complete".equalsIgnoreCase(action)) {
            String proofImageUrl = null;
            try {
                Part filePart = request.getPart("proofImageFile");
                if (filePart != null && filePart.getSize() > 0) {
                    try {
                        proofImageUrl = CloudinaryUtil.uploadImage(filePart, "deliveries/pod");
                    } catch (Exception ex) {
                        LOGGER.log(Level.WARNING, "Cloudinary upload failed for PoD, falling back to local file", ex);
                        String appPath = request.getServletContext().getRealPath("");
                        String uploadPath = appPath + File.separator + "assets" + File.separator + "uploads" + File.separator + "pod";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        String fileName = "pod_" + deliveryId + "_" + System.currentTimeMillis() + ".jpg";
                        filePart.write(uploadPath + File.separator + fileName);
                        proofImageUrl = request.getContextPath() + "/assets/uploads/pod/" + fileName;
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error processing PoD file part", e);
            }

            if (proofImageUrl == null || proofImageUrl.isBlank()) {
                proofImageUrl = request.getParameter("proofImageUrl");
            }
            if (proofImageUrl == null || proofImageUrl.isBlank()) {
                proofImageUrl = "https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=600";
            }
            boolean ok = deliveryService.completeDelivery(deliveryId, driverId, proofImageUrl);
            if (ok) {
                session.setAttribute("successMessage", "Giao hàng thành công! Đã lưu ảnh bằng chứng (PoD) và cập nhật thanh toán.");
                try {
                    Delivery del = deliveryService.getDeliveryById(deliveryId, driverId);
                    if (del != null && del.getSubOrderId() > 0) {
                        INotificationService notiService = new NotificationServiceImpl();
                        notiService.notifyOrderDeliveredBySubOrder(del.getSubOrderId(), del.getSubOrderCode());
                    }
                } catch (Exception ignored) {}
            } else {
                session.setAttribute("errorMessage", "Không thể hoàn tất giao hàng. Vui lòng thử lại!");
            }
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
            return;
        }

        if ("failed".equalsIgnoreCase(action)) {
            String failureReason = request.getParameter("failureReason");
            boolean ok = deliveryService.recordFailedDelivery(deliveryId, driverId, failureReason);
            if (ok) {
                session.setAttribute("successMessage", "Đã ghi nhận giao hàng thất bại! Hệ thống đã tự động kích hoạt quy trình Trả hàng/Hoàn tiền.");
            } else {
                session.setAttribute("errorMessage", "Không thể ghi nhận sự cố. Vui lòng thử lại!");
            }
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
    }
}
