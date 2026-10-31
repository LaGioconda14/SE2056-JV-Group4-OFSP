package controller.shop;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.DriverProfile;
import service.IDriverService;
import service.impl.DriverServiceImpl;

@WebServlet(name = "ShopShippersServlet", urlPatterns = {"/shop/shippers", "/shop/delivery-staff"})
public class ShopShippersServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ShopShippersServlet.class.getName());
    private final IDriverService driverService = new DriverServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        Long shopId = (session != null && session.getAttribute("shopId") != null)
                ? ((Number) session.getAttribute("shopId")).longValue() : null;

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<DriverProfile> drivers = driverService.getDriversByShopId(shopId, null, null);

        request.setAttribute("drivers", drivers);
        request.setAttribute("activeMenu", "shippers");

        request.getRequestDispatcher("/views/shop/shop-shippers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        Long shopId = (session != null && session.getAttribute("shopId") != null)
                ? ((Number) session.getAttribute("shopId")).longValue() : null;

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                String fullName = request.getParameter("fullName");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String password = request.getParameter("password");
                String vehicleType = request.getParameter("vehicleType");
                String vehiclePlate = request.getParameter("vehiclePlate");
                String coldStorageType = request.getParameter("coldStorageType");
                String operatingDistricts = request.getParameter("operatingDistricts");

                if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty() || phone == null || phone.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?error=missing_fields");
                    return;
                }

                boolean ok = driverService.createShopShipper(shopId, fullName.trim(), email.trim(), phone.trim(),
                        password != null ? password.trim() : "123456",
                        vehicleType != null ? vehicleType.trim() : "Xe máy thùng lạnh FreshBox",
                        vehiclePlate != null ? vehiclePlate.trim().toUpperCase() : "29-X1 999.99",
                        coldStorageType != null ? coldStorageType.trim() : "Thùng giữ nhiệt lạnh 2-5°C",
                        operatingDistricts != null ? operatingDistricts.trim() : "Nội thành");

                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?success=created");
                } else {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?error=create_failed");
                }
                return;
            }

            if ("edit".equalsIgnoreCase(action)) {
                long driverId = Long.parseLong(request.getParameter("driverId"));
                String fullName = request.getParameter("fullName");
                String phone = request.getParameter("phone");
                String vehicleType = request.getParameter("vehicleType");
                String vehiclePlate = request.getParameter("vehiclePlate");
                String coldStorageType = request.getParameter("coldStorageType");
                String operatingDistricts = request.getParameter("operatingDistricts");
                String availabilityStatus = request.getParameter("availabilityStatus");

                boolean ok = driverService.updateShopShipper(driverId, shopId,
                        fullName != null ? fullName.trim() : "",
                        phone != null ? phone.trim() : "",
                        vehicleType != null ? vehicleType.trim() : "",
                        vehiclePlate != null ? vehiclePlate.trim().toUpperCase() : "",
                        coldStorageType != null ? coldStorageType.trim() : "",
                        operatingDistricts != null ? operatingDistricts.trim() : "",
                        availabilityStatus != null ? availabilityStatus.trim() : "AVAILABLE");

                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?success=updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?error=update_failed");
                }
                return;
            }

            if ("toggle_status".equalsIgnoreCase(action)) {
                long driverId = Long.parseLong(request.getParameter("driverId"));
                String newStatus = request.getParameter("newStatus");
                boolean ok = driverService.toggleShipperStatus(driverId, shopId, newStatus);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?success=status_changed");
                } else {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?error=toggle_failed");
                }
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                long driverId = Long.parseLong(request.getParameter("driverId"));
                boolean ok = driverService.deleteShopShipper(driverId, shopId);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?success=deleted");
                } else {
                    response.sendRedirect(request.getContextPath() + "/shop/shippers?error=cannot_delete_active_shipper");
                }
                return;
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error handling shop shipper post action", ex);
            response.sendRedirect(request.getContextPath() + "/shop/shippers?error=system_error");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/shop/shippers");
    }
}
