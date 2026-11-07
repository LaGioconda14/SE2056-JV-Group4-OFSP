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
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import model.InventoryTransaction;
import model.ProductBatch;
import dao.ShopDAO;

@WebServlet(name = "InventoryHistoryServlet", urlPatterns = {"/shop/inventory/history"})
public class InventoryHistoryServlet extends HttpServlet {

    private final IInventoryService inventoryService = new InventoryServiceImpl();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = session.getAttribute("shopId") instanceof Long
                ? (Long) session.getAttribute("shopId") : null;
        if (shopId == null || shopId <= 0) {
            response.sendRedirect(request.getContextPath() + "/shop/inventory");
            return;
        }

        try {
            int variantId = Integer.parseInt(request.getParameter("variantId"));
            int batchId = Integer.parseInt(request.getParameter("batchId"));
            String productName = request.getParameter("productName");

            int shopIdInt = Math.toIntExact(shopId);

            // 1. Lấy lịch sử biến động kho của lô cụ thể
            List<InventoryTransaction> transactionHistoryList = inventoryService.getInventoryHistory(variantId, batchId, shopIdInt);
            
            // 2. Lấy toàn bộ danh sách lô hàng và gom nhóm theo variantBatchMap (giống luồng hiển thị kho chính)
            List<ProductBatch> batchList = inventoryService.getBatchesByShopId(shopId);
            Map<Long, List<ProductBatch>> variantBatchMap = new LinkedHashMap<>();
            int totalStock = 0;
            int nearExpiryCount = 0;

            for (ProductBatch b : batchList) {
                totalStock += b.getCurrentQuantity();
                if ("Quá hạn".equals(b.getStatusText()) || "Cận date".equals(b.getStatusText())) {
                    nearExpiryCount++;
                }
                variantBatchMap.computeIfAbsent(b.getVariantId(), k -> new ArrayList<>()).add(b);
            }

            int totalBatches = batchList.size();
            int lowStockCount = shopDAO.getLowStockCountByShopId(shopId);

            // 3. Đẩy đầy đủ tất cả các biến dữ liệu kho ra request attribute
            request.setAttribute("variantBatchMap", variantBatchMap);
            request.setAttribute("totalStock", totalStock);
            request.setAttribute("totalBatches", totalBatches);
            request.setAttribute("nearExpiryCount", nearExpiryCount);
            request.setAttribute("lowStockCount", lowStockCount);

            // Dữ liệu phục vụ riêng cho Modal Lịch sử
            request.setAttribute("transactionHistoryList", transactionHistoryList);
            request.setAttribute("currentProductName", productName);
            request.setAttribute("isOpenHistoryModal", true);

            // 4. Forward về trang dashboard kho
            request.getRequestDispatcher("/views/inventory/inventory-dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/shop/inventory");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}