package controller.shop;

import dao.OrderFulfillmentDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.OrderItem;
import model.ShippingAddress;
import model.SubOrder;

@WebServlet(name = "ShopOrderDetailServlet", urlPatterns = {"/shop/order-detail", "/shop/orders/detail"})
public class ShopOrderDetailServlet extends HttpServlet {

    private final OrderFulfillmentDAO fulfillmentDAO = new OrderFulfillmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        long shopId = 1L;
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("shopId") != null) {
            try {
                shopId = ((Number) session.getAttribute("shopId")).longValue();
            } catch (Exception ignored) {
            }
        }

        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            code = fulfillmentDAO.getFirstSubOrderCode(shopId);
            if (code == null || code.trim().isEmpty()) {
                code = "SUB-9001-1";
            }
        }

        String simulateStatus = request.getParameter("status"); // For simulation toggle

        SubOrder subOrder = fulfillmentDAO.getSubOrderDetails(code);

        // If not found with given code, try getting latest real sub-order from DB
        if (subOrder == null) {
            String fallbackCode = fulfillmentDAO.getFirstSubOrderCode(shopId);
            if (fallbackCode != null && !fallbackCode.equalsIgnoreCase(code)) {
                subOrder = fulfillmentDAO.getSubOrderDetails(fallbackCode);
            }
        }

        // Only fallback to mock if DB is completely empty
        if (subOrder == null) {
            subOrder = createMockSubOrder(code);
        }

        // If user triggers status simulation parameter
        if (simulateStatus != null && !simulateStatus.trim().isEmpty()) {
            subOrder.setStatus(simulateStatus.toUpperCase());
        }

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

        String action = request.getParameter("action");
        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            code = "SUB-8821-1";
        }

        String newStatus = "PACKING";
        if ("ready_to_ship".equals(action)) {
            newStatus = "SHIPPING";
        } else if ("confirm".equals(action)) {
            newStatus = "PACKING";
        } else if (request.getParameter("newStatus") != null) {
            newStatus = request.getParameter("newStatus");
        }

        fulfillmentDAO.updateSubOrderStatus(code, newStatus);

        response.sendRedirect(request.getContextPath() + "/shop/order-detail?code=" + code + "&status=" + newStatus + "&success=1");
    }

    private SubOrder createMockSubOrder(String code) {
        SubOrder so = new SubOrder();
        so.setSubOrderId(98241L);
        so.setSubOrderCode(code);
        so.setOrderId(98241L);
        so.setOrderCode("ORD-98241");
        so.setShopId(1L);
        so.setShopName("Nông Trại Hữu Cơ Mộc Châu");
        so.setStatus("PACKING"); // Default: Đang đóng gói
        so.setPaymentMethod("COD");
        so.setPaymentStatus("PENDING");
        so.setDeliverySlot("Cold - Chain Express");
        so.setTrackingNumber("FFX-98241-VN");
        so.setCarrierName("FreshFruit Cold-Chain");
        so.setShopSubtotal(new BigDecimal("680000"));
        so.setShopShippingFee(BigDecimal.ZERO);
        so.setShopDiscount(BigDecimal.ZERO);
        so.setShopTotal(new BigDecimal("680000"));
        so.setCreatedAt(new Timestamp(System.currentTimeMillis() - 45 * 60 * 1000)); // 45 mins ago

        // Shipping Address
        ShippingAddress addr = new ShippingAddress();
        addr.setRecipientName("Nguyễn Thu Trang");
        addr.setRecipientPhone("0912 *** 882");
        addr.setStreetAddress("Căn hộ 14.02, Tháp B2, Vinhomes Central Park");
        addr.setWard("Phường 22");
        addr.setDistrict("Quận Bình Thạnh");
        addr.setCity("TP.HCM");
        so.setShippingAddress(addr);

        // Items with full product info
        List<OrderItem> items = new ArrayList<>();

        OrderItem item1 = new OrderItem();
        item1.setOrderItemId(1L);
        item1.setSubOrderId(98241L);
        item1.setProductNameSnapshot("Dâu Tây Hana Mộc Châu Loại 1");
        item1.setVariantNameSnapshot("Hữu cơ");
        item1.setSkuSnapshot("DAU-HANA-1KG");
        item1.setUnit("Hộp 1kg");
        item1.setUnitPrice(new BigDecimal("190000"));
        item1.setQuantity(2);
        item1.setTotalPrice(new BigDecimal("380000"));
        item1.setImageUrl("https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=150&h=150&fit=crop");
        item1.setStockQuantity(18);
        item1.setWeightKg(new BigDecimal("1.0"));
        item1.setOrigin("Mộc Châu, Sơn La");
        item1.setCertification("VietGAP");
        item1.setStorageTemp("2-5°C");
        items.add(item1);

        OrderItem item2 = new OrderItem();
        item2.setOrderItemId(2L);
        item2.setSubOrderId(98241L);
        item2.setProductNameSnapshot("Bưởi Da Xanh Bến Tre OCOP 4 Sao");
        item2.setVariantNameSnapshot("OCOP 4⭐");
        item2.setSkuSnapshot("BUOI-DAXANH-T4");
        item2.setUnit("Thùng (4 quả)");
        item2.setUnitPrice(new BigDecimal("300000"));
        item2.setQuantity(1);
        item2.setTotalPrice(new BigDecimal("300000"));
        item2.setImageUrl("https://images.unsplash.com/photo-1605333396915-47ed6b68a00e?w=150&h=150&fit=crop");
        item2.setStockQuantity(35);
        item2.setWeightKg(new BigDecimal("1.25"));
        item2.setOrigin("Bến Tre");
        item2.setCertification("OCOP 4 sao");
        item2.setStorageTemp("10-14°C");
        items.add(item2);

        so.setItems(items);
        return so;
    }
}
