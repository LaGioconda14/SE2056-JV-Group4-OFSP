package controller.order;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Coupon;
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

        // 1. Xử lý Voucher Sàn (Platform Coupon)
        String couponCode = request.getParameter("couponCode");
        String removeCoupon = request.getParameter("removeCoupon");
        if ("true".equalsIgnoreCase(removeCoupon) || "1".equals(removeCoupon)
                || (couponCode != null && couponCode.trim().isEmpty())) {
            couponCode = null;
            if (session != null) {
                session.removeAttribute("checkoutCouponCode");
            }
        } else if (couponCode == null && session != null) {
            couponCode = (String) session.getAttribute("checkoutCouponCode");
        } else if (couponCode != null && session != null) {
            couponCode = couponCode.trim().toUpperCase(Locale.ROOT);
            session.setAttribute("checkoutCouponCode", couponCode);
        }

        // 2. Xử lý Voucher của từng Shop (Shop Coupons: Map<Long, String> shopId -> couponCode)
        @SuppressWarnings("unchecked")
        Map<Long, String> shopCouponCodes = session != null
                ? (Map<Long, String>) session.getAttribute("checkoutShopCoupons") : null;
        if (shopCouponCodes == null) {
            shopCouponCodes = new LinkedHashMap<>();
        } else {
            shopCouponCodes = new LinkedHashMap<>(shopCouponCodes);
        }

        // Kiểm tra xóa voucher của shop: ?removeShopCoupon=<shopId>
        String removeShopCouponParam = request.getParameter("removeShopCoupon");
        if (removeShopCouponParam != null && !removeShopCouponParam.trim().isEmpty()) {
            try {
                long rShopId = Long.parseLong(removeShopCouponParam.trim());
                shopCouponCodes.remove(rShopId);
            } catch (NumberFormatException ignored) {
            }
        }

        // Kiểm tra chọn/đổi voucher của shop: ?shopId=<shopId>&shopCouponCode=<code>
        String paramShopId = request.getParameter("shopId");
        String paramShopCouponCode = request.getParameter("shopCouponCode");
        if (paramShopId != null && paramShopCouponCode != null) {
            try {
                long sId = Long.parseLong(paramShopId.trim());
                if (!paramShopCouponCode.trim().isEmpty()) {
                    shopCouponCodes.put(sId, paramShopCouponCode.trim().toUpperCase(Locale.ROOT));
                } else {
                    shopCouponCodes.remove(sId);
                }
            } catch (NumberFormatException ignored) {
            }
        }

        // Kiểm tra các params dạng shopCoupon_<shopId>=<code> (từ cart submit sang)
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
            }
        }

        if (session != null) {
            session.setAttribute("checkoutShopCoupons", shopCouponCodes);
        }

        try {
            List<CartItem> selectedItems = orderService.getSelectedItemsForCheckout((long) user.getId(), cartItemIds);
            CustomerAddress defaultAddress = orderService.getDefaultCustomerAddress((long) user.getId());
            List<CustomerAddress> customerAddresses = orderService.getCustomerAddresses((long) user.getId());

            Map<Long, List<CartItem>> itemsByShop = new LinkedHashMap<>();
            for (CartItem item : selectedItems) {
                long shopId = (item.getVariant() != null && item.getVariant().getProduct() != null)
                        ? item.getVariant().getProduct().getShopId() : 1L;
                itemsByShop.computeIfAbsent(shopId, key -> new ArrayList<>()).add(item);
            }

            // Xây dựng đơn hàng nháp (kèm kiểm tra tính hợp lệ của voucher)
            Order draftOrder = null;
            try {
                draftOrder = orderService.buildDraftOrder((long) user.getId(), selectedItems, couponCode, shopCouponCodes);
            } catch (IllegalArgumentException ex) {
                request.setAttribute("checkoutError", ex.getMessage());
                // Nếu mã sàn lỗi, thử gỡ mã sàn để trang vẫn hiển thị
                if (couponCode != null) {
                    try {
                        draftOrder = orderService.buildDraftOrder((long) user.getId(), selectedItems, null, shopCouponCodes);
                        couponCode = null;
                        if (session != null) {
                            session.removeAttribute("checkoutCouponCode");
                        }
                    } catch (Exception ignored) {
                    }
                }
                // Nếu vẫn lỗi do mã shop, gỡ bỏ mã shop để trang vẫn hiển thị
                if (draftOrder == null) {
                    draftOrder = orderService.buildDraftOrder((long) user.getId(), selectedItems, null, Collections.emptyMap());
                    shopCouponCodes.clear();
                    if (session != null) {
                        session.removeAttribute("checkoutShopCoupons");
                    }
                }
            }

            // Lấy danh sách voucher sàn khả dụng
            request.setAttribute("availableCoupons",
                    orderService.getAvailableCoupons(draftOrder.getTotalGoodsAmount()));

            // Lấy danh sách voucher của từng shop khả dụng
            Map<Long, List<Coupon>> availableShopCoupons = new HashMap<>();
            for (Long sId : itemsByShop.keySet()) {
                availableShopCoupons.put(sId, orderService.getAvailableShopCoupons(sId));
            }
            request.setAttribute("availableShopCoupons", availableShopCoupons);

            request.setAttribute("selectedItems", selectedItems);
            request.setAttribute("itemsByShop", itemsByShop);
            request.setAttribute("draftOrder", draftOrder);
            request.setAttribute("defaultAddress", defaultAddress);
            request.setAttribute("customerAddresses", customerAddresses);
            request.setAttribute("cartItemIds", cartItemIds);
            request.setAttribute("couponCode", couponCode);
            request.setAttribute("shopCouponCodes", shopCouponCodes);

            request.getRequestDispatcher("/views/order/checkout.jsp").forward(request, response);

        } catch (Exception ex) {
            session.setAttribute("cartError", ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }
}
