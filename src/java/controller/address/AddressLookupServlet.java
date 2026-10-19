package controller.address;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CustomerAddress;
import model.User;
import service.IAddressLookupService;
import service.ICustomerAddressService;
import service.impl.AddressLookupServiceImpl;
import service.impl.CustomerAddressServiceImpl;

@WebServlet(name = "AddressLookupServlet", urlPatterns = {
    "/api/address/provinces",
    "/api/address/districts",
    "/api/address/wards",
    "/api/address/create"
})
public class AddressLookupServlet extends HttpServlet {

    private final IAddressLookupService addressLookupService = new AddressLookupServiceImpl();
    private final ICustomerAddressService customerAddressService = new CustomerAddressServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "public, max-age=3600");

        String path = request.getServletPath();
        String json;

        if ("/api/address/provinces".equals(path)) {
            json = addressLookupService.getProvincesJson();
        } else if ("/api/address/districts".equals(path)) {
            String provinceCode = request.getParameter("provinceCode");
            json = addressLookupService.getDistrictsJson(provinceCode);
        } else if ("/api/address/wards".equals(path)) {
            String districtCode = request.getParameter("districtCode");
            json = addressLookupService.getWardsJson(districtCode);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            json = "{\"error\":\"Endpoint not found\"}";
        }

        response.getWriter().write(json);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để lưu địa chỉ!\"}");
            return;
        }

        String recipientName = request.getParameter("recipientName");
        String recipientPhone = request.getParameter("recipientPhone");
        String streetAddress = request.getParameter("streetAddress");
        String city = request.getParameter("city");
        String district = request.getParameter("district");
        String ward = request.getParameter("ward");
        boolean isDefault = "true".equalsIgnoreCase(request.getParameter("isDefault"));

        if (recipientName == null || recipientName.trim().isEmpty()
                || recipientPhone == null || recipientPhone.trim().isEmpty()
                || streetAddress == null || streetAddress.trim().isEmpty()
                || city == null || city.trim().isEmpty()
                || district == null || district.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng điền đầy đủ các thông tin bắt buộc!\"}");
            return;
        }

        CustomerAddress newAddress = new CustomerAddress();
        newAddress.setUserId((long) user.getId());
        newAddress.setRecipientName(recipientName.trim());
        newAddress.setRecipientPhone(recipientPhone.trim());
        newAddress.setStreetAddress(streetAddress.trim());
        newAddress.setCity(city.trim());
        newAddress.setDistrict(district.trim());
        newAddress.setWard(ward != null ? ward.trim() : "");
        newAddress.setDefault(isDefault);

        try {
            boolean saved = customerAddressService.addAddress(newAddress);
            if (saved) {
                String fullAddress = newAddress.getFullAddress();
                String json = "{\"success\":true,\"addressId\":" + newAddress.getAddressId()
                        + ",\"recipientName\":\"" + escapeJson(newAddress.getRecipientName()) + "\""
                        + ",\"recipientPhone\":\"" + escapeJson(newAddress.getRecipientPhone()) + "\""
                        + ",\"fullAddress\":\"" + escapeJson(fullAddress) + "\""
                        + ",\"isDefault\":" + newAddress.isDefault() + "}";
                response.getWriter().write(json);
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu địa chỉ vào cơ sở dữ liệu!\"}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
