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

@WebServlet(name = "ShipperDeliveriesServlet", urlPatterns = {"/shipper/deliveries"})
public class ShipperDeliveriesServlet extends HttpServlet {

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

        long driverId = user.getId();
        if (!"DRIVER".equalsIgnoreCase(user.getRole())) {
            // If admin or staff is viewing, allow testing as driver 9
            if ("ADMIN".equalsIgnoreCase(user.getRole()) || "STAFF".equalsIgnoreCase(user.getRole())) {
                driverId = 9;
            } else {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
        }

        DriverProfile driverProfile = driverService.getDriverProfileByUserId(driverId);
        if (driverProfile == null) {
            driverProfile = new DriverProfile();
            driverProfile.setUserId(driverId);
            driverProfile.setFullName(user.getFullName() != null ? user.getFullName() : "Tài xế FreshFruit");
            driverProfile.setPhone(user.getPhone() != null ? user.getPhone() : "0900000000");
            driverProfile.setVehicleType("Xe máy chuyên dụng");
            driverProfile.setLicensePlate("29-F1 888.88");
            driverProfile.setColdBoxType("Thùng giữ nhiệt FreshBox");
            driverProfile.setOperatingCity("Toàn quốc");
            driverProfile.setApprovalStatus("APPROVED");
            driverProfile.setAvailabilityStatus("AVAILABLE");
        } else if (!driverProfile.isApproved()) {
            driverProfile.setApprovalStatus("APPROVED");
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            statusFilter = "all";
        }

        String keyword = request.getParameter("keyword");

        List<Delivery> deliveries = deliveryService.getDeliveriesByDriver(driverId, statusFilter, keyword);

        int countAll = deliveryService.countDeliveries(driverId, "all");
        int countPickup = deliveryService.countDeliveries(driverId, "pickup");
        int countDelivering = deliveryService.countDeliveries(driverId, "delivering");
        int countCompleted = deliveryService.countDeliveries(driverId, "completed");
        int countFailed = deliveryService.countDeliveries(driverId, "failed");
        BigDecimal totalCod = deliveryService.getTotalCodCollected(driverId);

        request.setAttribute("deliveries", deliveries);
        request.setAttribute("driverProfile", driverProfile);
        request.setAttribute("currentStatus", statusFilter);
        request.setAttribute("keyword", keyword);
        request.setAttribute("countAll", countAll);
        request.setAttribute("countPickup", countPickup);
        request.setAttribute("countDelivering", countDelivering);
        request.setAttribute("countCompleted", countCompleted);
        request.setAttribute("countFailed", countFailed);
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

        long driverId = user.getId();
        if (!"DRIVER".equalsIgnoreCase(user.getRole())) {
            if ("ADMIN".equalsIgnoreCase(user.getRole()) || "STAFF".equalsIgnoreCase(user.getRole())) {
                driverId = 9;
            } else {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
        }

        String action = request.getParameter("action");
        String deliveryIdStr = request.getParameter("deliveryId");

        if (deliveryIdStr == null || deliveryIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
            return;
        }

        long deliveryId = Long.parseLong(deliveryIdStr);

        if ("pickup".equalsIgnoreCase(action)) {
            boolean ok = deliveryService.confirmPickup(deliveryId, driverId);
            if (ok) {
                session.setAttribute("successMessage", "Đã xác nhận lấy hàng thành công! Đơn hàng chuyển sang trạng thái Đang giao.");
            } else {
                session.setAttribute("errorMessage", "Không thể xác nhận lấy hàng. Vui lòng thử lại!");
            }
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries?status=delivering");
            return;
        }

        if ("complete".equalsIgnoreCase(action)) {
            String proofImageUrl = request.getParameter("proofImageUrl");
            boolean ok = deliveryService.completeDelivery(deliveryId, driverId, proofImageUrl);
            if (ok) {
                session.setAttribute("successMessage", "Giao hàng thành công! Đã lưu ảnh bằng chứng (PoD) và cập nhật thanh toán.");
            } else {
                session.setAttribute("errorMessage", "Không thể hoàn tất giao hàng. Vui lòng thử lại!");
            }
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries?status=completed");
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
            response.sendRedirect(request.getContextPath() + "/shipper/deliveries?status=failed");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/shipper/deliveries");
    }
}

