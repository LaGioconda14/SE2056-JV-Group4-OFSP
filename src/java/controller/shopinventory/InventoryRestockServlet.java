package controller.shopinventory;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.IInventoryService;
import service.impl.InventoryServiceImpl;

@WebServlet(name = "InventoryRestockServlet", urlPatterns = {"/shop/inventory/restock"})
public class InventoryRestockServlet extends HttpServlet {

    private final IInventoryService inventoryService = new InventoryServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        Long shopId = session == null ? null : (Long) session.getAttribute("shopId");

        // Kiểm tra bảo mật quyền Shop Owner
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole()) || shopId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Lấy dữ liệu từ form modal nhập kho
            String variantIdStr = request.getParameter("variantId");
            String quantityStr = request.getParameter("quantity");
            String expiryDate = request.getParameter("expiryDate");
            String note = request.getParameter("note");

            if (variantIdStr == null || variantIdStr.trim().isEmpty() ||
                quantityStr == null || quantityStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng điền đầy đủ thông tin bắt buộc.");
            }

            long variantId = Long.parseLong(variantIdStr);
            int quantity = Integer.parseInt(quantityStr);

            // Gọi Service thực thi nghiệp vụ (tạo lô, sinh mã tự động, cộng dồn tổng kho, ghi log)
            inventoryService.restockBatch(variantId, shopId, user.getId(), quantity, expiryDate, note);

            // Bắn thông báo thành công qua session flash message
            session.setAttribute("inventoryRestockSuccess", true);
            session.setAttribute("inventoryRestockMessage", "Nhập kho lô mới thành công!");

        } catch (Exception e) {
            // Bắn thông báo lỗi nếu có ngoại lệ xảy ra
            session.setAttribute("inventoryRestockSuccess", false);
            session.setAttribute("inventoryRestockMessage", "Nhập kho thất bại: " + e.getMessage());
        }

        // Điều hướng quay trở lại trang quản lý kho
        response.sendRedirect(request.getContextPath() + "/shop/inventory");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chặn truy cập GET trực tiếp vào URL action này, đẩy về trang dashboard kho
        response.sendRedirect(request.getContextPath() + "/shop/inventory");
    }
}