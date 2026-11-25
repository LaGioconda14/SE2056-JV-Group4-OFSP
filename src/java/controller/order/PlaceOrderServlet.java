package controller.order;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import enums.PaymentMethod;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.order.ShippingAddress;
import model.entity.user.User;
import service.IOrderService;
import service.impl.OrderServiceImpl;
import service.INotificationService;
import service.impl.NotificationServiceImpl;

/** Chốt đơn từ form checkout; giá/tồn kho/voucher được kiểm tra lại tại service/DAO. */
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

        // Chi user dang hoat dong duoc dat hang; session cu bi huy truoc khi chuyen login.
        if (user == null || !user.isActive()) {
            if (session != null) session.invalidate();
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để hoàn tất đơn hàng!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // checkoutMode=buyNow can variantId va quantity la so duong; loi quay ve checkout.
        boolean buyNow = "buyNow".equals(request.getParameter("checkoutMode"));
        Long buyNowVariantId = null;
        Integer buyNowQuantity = null;
        if (buyNow) {
            try {
                buyNowVariantId = Long.parseLong(request.getParameter("variantId"));
                buyNowQuantity = Integer.parseInt(request.getParameter("quantity"));
                if (buyNowVariantId <= 0 || buyNowQuantity <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException ex) {
                session.setAttribute("checkoutError", "Sản phẩm mua ngay không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/checkout");
                return;
            }
        }

        // Lấy danh sách cartItemIds
        // Moi gia tri khong parse duoc bi bo qua; luong gio hang can it nhat mot ID
        // va danh sach parse duoc khong vuot 100 dong. Service tiep tuc kiem tra nghiep vu.
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

        if (!buyNow && cartItemIds.isEmpty()) {
            session.setAttribute("cartError", "Không có sản phẩm nào được chọn!");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }
        if (cartItemIds.size() > MAX_CHECKOUT_ITEMS) {
            session.setAttribute("checkoutError", "Bạn chỉ có thể đặt tối đa 100 dòng sản phẩm mỗi lần!");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        // Form gui lua chon dia chi, ngay/khung giao, phuong thuc thanh toan va couponCode;
        // saveAddress=true chi duoc chuyen cho service khi dang dung dia chi moi.
        String addressSelection = request.getParameter("addressSelection");
        String deliveryDate = request.getParameter("deliveryDate");
        String deliverySlot = request.getParameter("deliverySlot");
        String paymentMethod = request.getParameter("paymentMethod");
        String couponCode = request.getParameter("couponCode");
        boolean saveAddress = "true".equalsIgnoreCase(request.getParameter("saveAddress"));

        // Thu thập shop coupon codes và shop notes
        // Ten tham so shopCoupon_<id> va shopNote_<id> duoc tach ID so; gia tri rong
        // hoac ID khong parse duoc bi bo qua. Ma duoc trim/viet hoa, ghi chu duoc trim.
        // Neu khong co ma shop nao trong request, dung danh sach da luu trong session.
        Map<Long, String> shopCouponCodes = new LinkedHashMap<>();
        Map<Long, String> shopNotes = new LinkedHashMap<>();
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String pName = paramNames.nextElement();
            if (pName.startsWith("shopCoupon_")) {
                try {
                    long sId = Long.parseLong(pName.substring("shopCoupon_".length()));
                    String val = request.getParameter(pName);
                    if (val != null && !val.trim().isEmpty()) {
                        shopCouponCodes.put(sId, val.trim().toUpperCase(Locale.ROOT));
                    }
                } catch (NumberFormatException ignored) {
                }
            } else if (pName.startsWith("shopNote_")) {
                try {
                    long sId = Long.parseLong(pName.substring("shopNote_".length()));
                    String val = request.getParameter(pName);
                    if (val != null && !val.trim().isEmpty()) {
                        shopNotes.put(sId, val.trim());
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        if (shopCouponCodes.isEmpty() && session != null) {
            @SuppressWarnings("unchecked")
            Map<Long, String> savedShopCoupons = (Map<Long, String>) session.getAttribute("checkoutShopCoupons");
            if (savedShopCoupons != null) {
                shopCouponCodes.putAll(savedShopCoupons);
            }
        }

        // Địa chỉ đã lưu phải được tìm theo chính customerId, không tin ID địa chỉ trong form.
        // saved:<id> lay thong tin tu service; new doc recipientName, recipientPhone,
        // streetAddress, ward va city tu form. Lua chon thieu va ID sai dinh dang ve checkout.
        ShippingAddress shippingAddress = new ShippingAddress();
        if (addressSelection != null && addressSelection.startsWith("saved:")) {
            try {
                long addressId = Long.parseLong(addressSelection.substring("saved:".length()));
                model.entity.user.CustomerAddress savedAddress = orderService.getCustomerAddress((long) user.getId(), addressId);
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
            shippingAddress.setDistrict("");
            shippingAddress.setCity(request.getParameter("city"));
        } else {
            session.setAttribute("checkoutError", "Vui lòng chọn hoặc thêm địa chỉ giao hàng!");
            response.sendRedirect(request.getContextPath() + "/checkout");
            return;
        }

        // Hai luồng mua ngay/giỏ hàng cùng đi qua nghiệp vụ tạo đơn; thanh toán VNPay bắt đầu sau khi đơn đã lưu.
        try {
            long orderId;
            if (buyNow) {
                orderId = orderService.placeBuyNowOrder((long) user.getId(), buyNowVariantId,
                        buyNowQuantity, shippingAddress, deliveryDate, deliverySlot, paymentMethod, couponCode,
                        shopCouponCodes, shopNotes, "new".equals(addressSelection) && saveAddress);
            } else {
                orderId = orderService.placeOrder((long) user.getId(), cartItemIds, shippingAddress,
                        deliveryDate, deliverySlot, paymentMethod, couponCode, shopCouponCodes, shopNotes,
                        "new".equals(addressSelection) && saveAddress);
            }

            // Dọn dẹp session sau khi đặt hàng thành công
            session.removeAttribute("checkoutItemIds");
            session.removeAttribute("checkoutMode");
            session.removeAttribute("checkoutBuyNowVariantId");
            session.removeAttribute("checkoutBuyNowQuantity");
            session.removeAttribute("checkoutCouponCode");
            session.removeAttribute("checkoutShopCoupons");
            session.removeAttribute("checkoutFormDraft");
            // Các mặt hàng vừa đặt đã bị xóa khỏi DB; buộc badge đọc lại số lượng còn lại.
            session.removeAttribute("cartSize");
            session.setAttribute("orderSuccess", "Chúc mừng bạn đã đặt hàng thành công! Mã đơn: #" + orderId);
            // Thông báo là tác vụ phụ, lỗi gửi thông báo không làm đảo ngược đơn đã tạo.
            try {
                INotificationService notiService = new NotificationServiceImpl();
                notiService.notifyOrderPlaced(user.getId(), orderId, String.valueOf(orderId), 0);
                notiService.notifyShopsNewOrder(orderId);
                notiService.checkAndNotifyLowStock(orderId);
                if (user.getEmail() != null && !user.getEmail().isBlank()) {
                    String subject = "Xác nhận đặt hàng thành công #" + orderId + " - Gốc Vườn";
                    String html = "<p>Xin chào <strong>" + user.getFullName() + "</strong>,</p>"
                            + "<p>Đơn hàng <strong>#" + orderId + "</strong> của bạn đã được tiếp nhận thành công trên sàn Gốc Vườn.</p>"
                            + "<p>Nhà vườn đang chuẩn bị đóng gói hoa quả tươi để chuyển tới bạn sớm nhất!</p>";
                    util.EmailUtil.sendNotificationEmailAsync(user.getEmail(), subject, html);
                }
            } catch (Exception ignored) {}

            // Don da duoc tao truoc redirect: VNPAY sang tao thanh toan, con lai sang xac nhan.
            if (PaymentMethod.VNPAY.name().equalsIgnoreCase(paymentMethod)) {
                response.sendRedirect(request.getContextPath() + "/payment/vnpay/create?orderId=" + orderId);
            } else {
                response.sendRedirect(request.getContextPath() + "/order/confirmation?orderId=" + orderId);
            }

        } catch (Exception ex) {
            // Loi trong khoi dat don duoc luu message vao session va chuyen ve checkout.
            session.setAttribute("checkoutError", ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/checkout");
        }
    }
}
