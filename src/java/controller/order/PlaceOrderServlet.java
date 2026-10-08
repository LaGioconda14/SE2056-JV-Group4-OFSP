package controller.order;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ShippingAddress;
import model.User;
import service.IOrderService;
import service.impl.OrderServiceImpl;

@WebServlet(name = "PlaceOrderServlet", urlPatterns = {"/order/place"})
public class PlaceOrderServlet extends HttpServlet {

    private final IOrderService orderService = new OrderServiceImpl();
    private static final int MAX_CHECKOUT_ITEMS = 100;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để hoàn tất đơn hàng!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy danh sách cartItemIds
        String[] itemIdParams = request.getParameterValues("cartItemIds");
        List<Long> cartItemIds = new ArrayList<>();
        if (itemIdParams != null) {
            for (String s : itemIdParams) {
                try {
                    cartItemIds.add(Long.parseLong(s.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
        }

        if (cartItemIds.isEmpty()) {
            session.setAttribute("cartError", "Không có sản phẩm nào được chọn!");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }
        if (cartItemIds.size() > MAX_CHECKOUT_ITEMS) {
            session.setAttribute("checkoutError", "Bạn chỉ có thể đặt tối đa 100 dòng sản phẩm mỗi lần!");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        String addressSelection = request.getParameter("addressSelection");
        String deliverySlot = request.getParameter("deliverySlot");
        String paymentMethod = request.getParameter("paymentMethod");
        String couponCode = request.getParameter("couponCode");
        boolean saveAddress = "true".equalsIgnoreCase(request.getParameter("saveAddress"));

        ShippingAddress shippingAddress = new ShippingAddress();
        if (addressSelection != null && addressSelection.startsWith("saved:")) {
            try {
                long addressId = Long.parseLong(addressSelection.substring("saved:".length()));
                model.CustomerAddress savedAddress = orderService.getCustomerAddress((long) user.getId(), addressId);
                if (savedAddress == null) {
                    throw new IllegalArgumentException("Địa chỉ giao hàng không thuộc tài khoản của bạn!");
                }
                shippingAddress.setRecipientName(savedAddress.getRecipientName());
                shippingAddress.setRecipientPhone(savedAddress.getRecipientPhone());
                shippingAddress.setStreetAddress(savedAddress.getStreetAddress());
                shippingAddress.setWard(savedAddress.getWard());
                shippingAddress.setDistrict(savedAddress.getDistrict());
                shippingAddress.setCity(savedAddress.getCity());
            } catch (NumberFormatException ex) {
                session.setAttribute("checkoutError", "Địa chỉ giao hàng không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }
        } else if ("new".equals(addressSelection)) {
            shippingAddress.setRecipientName(request.getParameter("recipientName"));
            shippingAddress.setRecipientPhone(request.getParameter("recipientPhone"));
            shippingAddress.setStreetAddress(request.getParameter("streetAddress"));
            shippingAddress.setWard(request.getParameter("ward"));
            shippingAddress.setDistrict(request.getParameter("district"));
            shippingAddress.setCity(request.getParameter("city"));
        } else {
            session.setAttribute("checkoutError", "Vui lòng chọn hoặc thêm địa chỉ giao hàng!");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        try {
            long orderId = orderService.placeOrder((long) user.getId(), cartItemIds, shippingAddress,
                    deliverySlot, paymentMethod, couponCode,
                    "new".equals(addressSelection) && saveAddress);

            // Dọn dẹp session sau khi đặt hàng thành công
            session.removeAttribute("checkoutItemIds");
            session.removeAttribute("checkoutCouponCode");
            session.setAttribute("orderSuccess", "Chúc mừng bạn đã đặt hàng thành công! Mã đơn: #" + orderId);

            response.sendRedirect(request.getContextPath() + "/order/confirmation?orderId=" + orderId);

        } catch (Exception ex) {
            session.setAttribute("checkoutError", ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/checkout");
        }
    }
}
