package controller.shop;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.OrderItem;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.SubOrder;
import model.DriverProfile;
import enums.SubOrderStatus;
import service.IOrderFulfillmentService;
import service.IDriverService;
import service.IInventoryWasteService;
import service.impl.OrderFulfillmentServiceImpl;
import service.impl.DriverServiceImpl;
import service.impl.InventoryWasteServiceImpl;

@WebServlet(name = "ShopOrderDetailServlet", urlPatterns = {"/shop/order-detail", "/shop/orders/detail"})
public class ShopOrderDetailServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ShopOrderDetailServlet.class.getName());
    private final IOrderFulfillmentService fulfillmentService = new OrderFulfillmentServiceImpl();
    private final IDriverService driverService = new DriverServiceImpl();
    private final IInventoryWasteService wasteService = new InventoryWasteServiceImpl();

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

        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shop/orders");
            return;
        }

        SubOrder subOrder = fulfillmentService.getSubOrderDetails(code);
        if (subOrder == null) {
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=order_not_found");
            return;
        }

        if (subOrder.getShopId() != shopId) {
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=access_denied");
            return;
        }

        int shopSubOrdersCount = fulfillmentService.countSubOrdersByShop(shopId, (SubOrderStatus) null);
        session.setAttribute("shopSubOrdersCount", shopSubOrdersCount);
        request.setAttribute("shopSubOrdersCount", shopSubOrdersCount);

        // Lấy danh sách nhân viên giao hàng của Shop
        List<DriverProfile> shopShippers = driverService.getDriversByShopId(shopId, null, null);
        request.setAttribute("shopShippers", shopShippers);

        request.setAttribute("subOrder", subOrder);
        request.setAttribute("activeMenu", "orders");
        request.getRequestDispatcher("/views/shop/shop-order-detail.jsp").forward(request, response);
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

        // Bắt buộc đăng nhập và có quyền SHOP_OWNER
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=missing_code");
            return;
        }

        SubOrder targetOrder = fulfillmentService.getSubOrderDetails(code);
        if (targetOrder == null) {
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=order_not_found");
            return;
        }
        if (targetOrder.getShopId() != shopId) {
            response.sendRedirect(request.getContextPath() + "/shop/orders?error=access_denied");
            return;
        }

        Long currentUserId = (long) user.getId();

        // Hủy đơn hàng con
        if ("cancel_sub_order".equals(action)) {
            String category = request.getParameter("cancelReasonCategory");
            String note = request.getParameter("cancelReasonNote");
            StringBuilder sb = new StringBuilder();
            if (category != null && !category.trim().isEmpty()) {
                sb.append(category.trim());
            }
            if (note != null && !note.trim().isEmpty()) {
                if (sb.length() > 0) {
                    sb.append(" - ");
                }
                sb.append(note.trim());
            }
            String reason = sb.length() > 0 ? sb.toString() : "Shop hủy đơn do không đủ điều kiện cung cấp nông sản đạt chuẩn.";

            boolean ok;
            // Khớp với FE: Tùy chọn 1 là "Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng)"
            if (category != null && (category.toLowerCase().contains("chất lượng") 
                    || category.toLowerCase().contains("dập") 
                    || category.toLowerCase().contains("hỏng"))) {
                Map<Long, Integer> wastedQtyMap = new HashMap<>();
                if (targetOrder.getItems() != null) {
                    for (OrderItem it : targetOrder.getItems()) {
                        if (it.getVariantId() != null) {
                            String paramVal = request.getParameter("wastedQty_" + it.getVariantId());
                            if (paramVal != null && !paramVal.trim().isEmpty()) {
                                try {
                                    int wQty = Integer.parseInt(paramVal.trim());
                                    // Đảm bảo số lượng hỏng hợp lệ trong khoảng [0, it.getQuantity()]
                                    wQty = Math.max(0, Math.min(wQty, it.getQuantity()));
                                    wastedQtyMap.put(it.getVariantId(), wQty);
                                } catch (NumberFormatException ignored) {
                                    wastedQtyMap.put(it.getVariantId(), it.getQuantity());
                                }
                            } else {
                                wastedQtyMap.put(it.getVariantId(), it.getQuantity());
                            }
                        }
                    }
                }
                ok = wasteService.logOrderCancellationWaste(targetOrder.getSubOrderId(), reason, currentUserId, wastedQtyMap);
            } else {
                // Khớp với FE: Tùy chọn 2 là "Lý do khác" (Quả còn tươi nguyên) -> Hoàn lại 100% kho bán
                ok = fulfillmentService.cancelSubOrderWithRestock(code, reason, currentUserId);
            }
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + SubOrderStatus.CANCELLED.name() + "&cancelled=1");
            } else {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&error=cancel_failed");
            }
            return;
        }

        // Xử lý hàng hoàn: Nhập lại kho hoa quả tươi
        if ("return_restock".equals(action)) {
            String note = request.getParameter("restockNote");
            boolean ok = fulfillmentService.processReturnedOrderRestock(code, note, currentUserId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&restocked=1");
            } else {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&error=restock_failed");
            }
            return;
        }

        // Xử lý hàng hoàn: Báo hỏng do vận chuyển / đứt chuỗi lạnh
        if ("return_waste".equals(action)) {
            String note = request.getParameter("wasteNote");
            Map<Long, Integer> wastedQtyMap = new HashMap<>();
            if (targetOrder.getItems() != null) {
                for (OrderItem it : targetOrder.getItems()) {
                    if (it.getVariantId() != null) {
                        String paramVal = request.getParameter("wastedQty_" + it.getVariantId());
                        if (paramVal != null && !paramVal.trim().isEmpty()) {
                            try {
                                int wQty = Integer.parseInt(paramVal.trim());
                                wastedQtyMap.put(it.getVariantId(), wQty);
                            } catch (NumberFormatException ignored) {
                                wastedQtyMap.put(it.getVariantId(), it.getQuantity());
                            }
                        } else {
                            wastedQtyMap.put(it.getVariantId(), it.getQuantity());
                        }
                    }
                }
            }
            boolean ok = wasteService.logTransitDamageWaste(targetOrder.getSubOrderId(), note, currentUserId, wastedQtyMap);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&waste_logged=1");
            } else {
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&error=waste_failed");
            }
            return;
        }

        // Xác nhận đơn -> bắt đầu đóng gói
        if ("confirm".equals(action)) {
            fulfillmentService.updateSubOrderStatus(code, SubOrderStatus.PACKING);
            response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + SubOrderStatus.PACKING.name() + "&success=1");
            return;
        }

        // Phân công shipper của Shop
        if ("assign_shipper".equals(action)) {
            String driverUserIdStr = request.getParameter("driverUserId");
            if (driverUserIdStr == null || driverUserIdStr.trim().isEmpty()) {
                driverUserIdStr = request.getParameter("driverId");
            }
            if (driverUserIdStr != null && !driverUserIdStr.trim().isEmpty()) {
                try {
                    long driverUserId = Long.parseLong(driverUserIdStr.trim());
                    SubOrder so = fulfillmentService.getSubOrderDetails(code);
                    if (so != null) {
                        boolean assigned = driverService.assignDriverToSubOrder(so.getSubOrderId(), driverUserId);
                        if (assigned) {
                            response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&assigned=1");
                            return;
                        }
                    }
                } catch (Exception ex) {
                    LOGGER.log(Level.SEVERE, "Error assigning shop shipper", ex);
                }
            }
            response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&error=assign_failed");
            return;
        }

        // Sẵn sàng giao: chuyển sang SHIPPING & gán driver nếu có
        if ("ready_to_ship".equals(action)) {
            String driverUserIdStr = request.getParameter("driverUserId");
            SubOrder so = fulfillmentService.getSubOrderDetails(code);
            if (so != null && driverUserIdStr != null && !driverUserIdStr.trim().isEmpty()) {
                try {
                    long driverUserId = Long.parseLong(driverUserIdStr.trim());
                    driverService.assignDriverToSubOrder(so.getSubOrderId(), driverUserId);
                } catch (Exception ex) {
                    LOGGER.log(Level.SEVERE, "Error assigning driver in ready_to_ship", ex);
                }
            } else {
                fulfillmentService.updateSubOrderStatus(code, SubOrderStatus.SHIPPING);
            }
            response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + SubOrderStatus.SHIPPING.name() + "&success=1");
            return;
        }

        String newStatus = request.getParameter("newStatus");
        if (newStatus != null && !newStatus.trim().isEmpty()) {
            SubOrderStatus statusEnum = SubOrderStatus.from(newStatus);
            if (statusEnum != null) {
                fulfillmentService.updateSubOrderStatus(code, statusEnum);
                response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + statusEnum.name() + "&success=1");
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code);
    }
}