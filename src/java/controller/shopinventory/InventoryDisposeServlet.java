package controller.shopinventory;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.IInventoryService;
import service.impl.InventoryServiceImpl;

@WebServlet(name = "InventoryDisposeServlet", urlPatterns = {"/shop/inventory/dispose"})
public class InventoryDisposeServlet extends HttpServlet {

    private static final List<String> ALLOWED_REASONS =
            Arrays.asList("EXPIRED", "DAMAGED", "STORAGE_ISSUE", "QUALITY_FAIL", "LOST");

    private final IInventoryService inventoryService = new InventoryServiceImpl();

    private void flash(HttpSession session, boolean success, String message) {
        session.setAttribute("inventoryAdjustSuccess", success);
        session.setAttribute("inventoryAdjustMessage", message);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        Long shopIdObj = null;
        Long userIdObj = null;
        
        Object sId = session.getAttribute("shopId");
        Object uId = session.getAttribute("userId");
        
        if (sId instanceof Long) shopIdObj = (Long) sId;
        else if (sId instanceof Integer) shopIdObj = ((Integer) sId).longValue();
        
        if (uId instanceof Long) userIdObj = (Long) uId;
        else if (uId instanceof Integer) userIdObj = ((Integer) uId).longValue();

        // Fallback lấy từ object user nếu session chưa set trực tiếp shopId/userId
        if (shopIdObj == null || userIdObj == null) {
            model.User user = (model.User) session.getAttribute("user");
            if (user != null) {
                userIdObj = (long) user.getId();
                dao.ShopDAO sDao = new dao.ShopDAO();
                shopIdObj = sDao.getShopIdByOwnerId(userIdObj);
            }
        }

        if (shopIdObj == null || userIdObj == null || shopIdObj <= 0 || userIdObj <= 0) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int shopId = shopIdObj.intValue();
        int userId = userIdObj.intValue();

        try {
            int batchId = Integer.parseInt(request.getParameter("batchId"));
            int variantId = Integer.parseInt(request.getParameter("variantId"));

            String reasonCode = request.getParameter("reason");
            if (reasonCode == null || !ALLOWED_REASONS.contains(reasonCode)) {
                flash(session, false, "Lý do hủy lô không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/shop/inventory");
                return;
            }

            String description = request.getParameter("description");
            description = (description == null) ? "" : description.trim();

            boolean success = inventoryService.disposeBatch(batchId, variantId, shopId, userId, reasonCode, description);

            if (success) {
                flash(session, true, "Đã xuất hủy toàn bộ lô hàng và ngưng bán thành công!");
            } else {
                flash(session, false, "Hủy lô thất bại! Lô hàng không tồn tại hoặc đã hết hàng.");
            }

        } catch (NumberFormatException e) {
            flash(session, false, "Dữ liệu gửi lên không hợp lệ.");
        } catch (IllegalArgumentException e) {
            flash(session, false, e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            flash(session, false, "Lỗi hệ thống: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/shop/inventory");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/shop/inventory");
    }
}