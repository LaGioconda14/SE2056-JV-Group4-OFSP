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
import model.CartItem;
import model.CustomerAddress;
import model.Order;
import model.User;
import service.IOrderService;
import service.impl.OrderServiceImpl;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private final IOrderService orderService = new OrderServiceImpl();
    private static final int MAX_CHECKOUT_ITEMS = 100;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processCheckout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processCheckout(request, response);
    }

    private void processCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để tiến hành thanh toán!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Đọc danh sách cartItemIds được gửi từ giỏ hàng
        String[] itemIdParams = request.getParameterValues("cartItemIds");
        List<Long> cartItemIds = new ArrayList<>();

        if (itemIdParams != null && itemIdParams.length > 0) {
            for (String s : itemIdParams) {
                try {
                    cartItemIds.add(Long.parseLong(s.trim()));
                } catch (NumberFormatException ignored) {
                }
            }
            // Lưu vào session để phòng trường hợp khách hàng F5 tải lại trang checkout
            session.setAttribute("checkoutItemIds", cartItemIds);
        } else {
            // Lấy lại từ session nếu người dùng F5 hoặc truy cập trực tiếp
            @SuppressWarnings("unchecked")
            List<Long> savedIds = (List<Long>) (session != null ? session.getAttribute("checkoutItemIds") : null);
            if (savedIds != null) {
                cartItemIds = savedIds;
            }
        }

        if (cartItemIds.isEmpty()) {
            session.setAttribute("cartError", "Vui lòng chọn ít nhất một sản phẩm từ giỏ hàng để mua!");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }
        if (cartItemIds.size() > MAX_CHECKOUT_ITEMS) {
            session.setAttribute("cartError", "Bạn chỉ có thể thanh toán tối đa 100 dòng sản phẩm mỗi lần!");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        String couponCode = request.getParameter("couponCode");
        if (couponCode != null && couponCode.trim().isEmpty()) {
            couponCode = null;
            if (session != null) session.removeAttribute("checkoutCouponCode");
        } else if (couponCode == null && session != null) {
            couponCode = (String) session.getAttribute("checkoutCouponCode");
        } else if (couponCode != null && session != null) {
            session.setAttribute("checkoutCouponCode", couponCode);
        }

        try {
            List<CartItem> selectedItems = orderService.getSelectedItemsForCheckout((long) user.getId(), cartItemIds);
            Order draftOrder = orderService.buildDraftOrder((long) user.getId(), selectedItems, couponCode);
            CustomerAddress defaultAddress = orderService.getDefaultCustomerAddress((long) user.getId());
            List<CustomerAddress> customerAddresses = orderService.getCustomerAddresses((long) user.getId());
            request.setAttribute("availableCoupons",
                    orderService.getAvailableCoupons(draftOrder.getTotalGoodsAmount()));

            request.setAttribute("selectedItems", selectedItems);
            request.setAttribute("draftOrder", draftOrder);
            request.setAttribute("defaultAddress", defaultAddress);
            request.setAttribute("customerAddresses", customerAddresses);
            request.setAttribute("cartItemIds", cartItemIds);
            request.setAttribute("couponCode", couponCode);

            request.getRequestDispatcher("/views/order/checkout.jsp").forward(request, response);

        } catch (Exception ex) {
            session.setAttribute("cartError", ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }
}
