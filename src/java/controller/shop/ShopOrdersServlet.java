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

@WebServlet(name = "ShopOrdersServlet", urlPatterns = {"/shop/orders"})
public class ShopOrdersServlet extends HttpServlet {

    private final OrderFulfillmentDAO fulfillmentDAO = new OrderFulfillmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String statusTab = request.getParameter("status");
        if (statusTab == null || statusTab.trim().isEmpty()) {
            statusTab = "ALL";
        }

        long shopId = 1L; // Default current shop
        List<SubOrder> list = fulfillmentDAO.getSubOrdersByShop(shopId, statusTab);

        // Fallback mock list if DB has no orders yet
        if (list == null || list.isEmpty()) {
            list = createMockSubOrdersList();
            final String filterTab = statusTab;
            if (!"ALL".equalsIgnoreCase(filterTab)) {
                list.removeIf(o -> !o.getStatus().equalsIgnoreCase(filterTab));
            }
        }

        request.setAttribute("orderList", list);
        request.setAttribute("currentTab", statusTab.toUpperCase());
        request.setAttribute("activeMenu", "orders");
        request.getRequestDispatcher("/views/shop/shop-orders.jsp").forward(request, response);
    }

    private List<SubOrder> createMockSubOrdersList() {
        List<SubOrder> list = new ArrayList<>();

        // Order 1 (PACKING)
        SubOrder so1 = new SubOrder();
        so1.setSubOrderId(98241L);
        so1.setSubOrderCode("SUB-98241");
        so1.setOrderId(98241L);
        so1.setOrderCode("ORD-98241");
        so1.setStatus("PACKING");
        so1.setPaymentMethod("COD");
        so1.setShopTotal(new BigDecimal("680000"));
        so1.setDeliverySlot("Cold - Chain Express");
        so1.setCreatedAt(new Timestamp(System.currentTimeMillis() - 45 * 60 * 1000));
        ShippingAddress addr1 = new ShippingAddress();
        addr1.setRecipientName("Nguyễn Thu Trang");
        addr1.setRecipientPhone("0912 *** 882");
        addr1.setCity("TP.HCM");
        so1.setShippingAddress(addr1);
        List<OrderItem> items1 = new ArrayList<>();
        items1.add(new OrderItem(1L, 98241L, 1L, "Dâu Tây Hana Mộc Châu", "Hộp 1kg", "DAU-01", "Hộp", new BigDecimal("190000"), 2, new BigDecimal("380000")));
        items1.add(new OrderItem(2L, 98241L, 2L, "Bưởi Da Xanh Bến Tre", "Thùng 4 quả", "BUOI-02", "Thùng", new BigDecimal("300000"), 1, new BigDecimal("300000")));
        so1.setItems(items1);
        list.add(so1);

        // Order 2 (NEW)
        SubOrder so2 = new SubOrder();
        so2.setSubOrderId(98242L);
        so2.setSubOrderCode("SUB-98242");
        so2.setOrderId(98242L);
        so2.setOrderCode("ORD-98242");
        so2.setStatus("NEW");
        so2.setPaymentMethod("VNPAY (Đã TT)");
        so2.setShopTotal(new BigDecimal("420000"));
        so2.setDeliverySlot("Giao Tiết Kiệm");
        so2.setCreatedAt(new Timestamp(System.currentTimeMillis() - 15 * 60 * 1000));
        ShippingAddress addr2 = new ShippingAddress();
        addr2.setRecipientName("Trần Hoàng Nam");
        addr2.setRecipientPhone("0988 *** 119");
        addr2.setCity("Hà Nội");
        so2.setShippingAddress(addr2);
        List<OrderItem> items2 = new ArrayList<>();
        items2.add(new OrderItem(3L, 98242L, 3L, "Cam Sành Hàm Yên OCOP", "Túi 5kg", "CAM-01", "Túi", new BigDecimal("210000"), 2, new BigDecimal("420000")));
        so2.setItems(items2);
        list.add(so2);

        // Order 3 (SHIPPING)
        SubOrder so3 = new SubOrder();
        so3.setSubOrderId(98243L);
        so3.setSubOrderCode("SUB-98243");
        so3.setOrderId(98243L);
        so3.setOrderCode("ORD-98243");
        so3.setStatus("SHIPPING");
        so3.setPaymentMethod("COD");
        so3.setShopTotal(new BigDecimal("550000"));
        so3.setDeliverySlot("Cold - Chain Express");
        so3.setCreatedAt(new Timestamp(System.currentTimeMillis() - 120 * 60 * 1000));
        ShippingAddress addr3 = new ShippingAddress();
        addr3.setRecipientName("Lê Minh Tú");
        addr3.setRecipientPhone("0934 *** 667");
        addr3.setCity("Đà Nẵng");
        so3.setShippingAddress(addr3);
        List<OrderItem> items3 = new ArrayList<>();
        items3.add(new OrderItem(4L, 98243L, 4L, "Nho Mẫu Đơn Ninh Thuận", "Chùm 1kg", "NHO-01", "Kg", new BigDecimal("550000"), 1, new BigDecimal("550000")));
        so3.setItems(items3);
        list.add(so3);

        return list;
    }
}
