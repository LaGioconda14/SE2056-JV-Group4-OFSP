package controller.shop;

import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.InventoryWasteLog;
import model.ProductVariant;
import model.SubOrder;
import model.User;
import model.WasteStatisticDTO;
import service.IInventoryWasteService;
import service.IProductService;
import service.IShopProductService;
import service.impl.InventoryWasteServiceImpl;
import service.impl.ProductServiceImpl;
import service.impl.ShopProductServiceImpl;

/**
 * Controller quản lý phân hệ hàng hao hụt, dập nát, hư hỏng và tiêu hủy nông sản cho nhà vườn.
 * Hỗ trợ thống kê tỷ lệ hao hụt, ghi nhận tiêu hủy tự động trừ tồn kho, và xử lý hoàn hàng hỏng.
 */
@WebServlet(name = "ShopWasteServlet", urlPatterns = {"/shop/waste", "/shop/inventory/waste"})
public class ShopWasteServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ShopWasteServlet.class.getName());
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final IInventoryWasteService wasteService = new InventoryWasteServiceImpl();
    private final IProductService productService = new ProductServiceImpl();
    private final IShopProductService shopProductService = new ShopProductServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 1. Phân quyền chủ shop (SHOP_OWNER)
        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Xác định shopId
        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null || shopId <= 0) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            } else {
                shopId = 1L;
                session.setAttribute("shopId", shopId);
            }
        }

        try {
            // 3. Đọc các tham số lọc & tìm kiếm
            String stage = request.getParameter("stage");
            if (stage == null || stage.trim().isEmpty()) {
                stage = "ALL";
            } else {
                stage = stage.trim().toUpperCase();
            }

            String keyword = request.getParameter("keyword");
            if (keyword != null) {
                keyword = keyword.trim();
            }

            int page = 1;
            try {
                String p = request.getParameter("page");
                if (p != null && !p.trim().isEmpty()) {
                    page = Math.max(1, Integer.parseInt(p.trim()));
                }
            } catch (NumberFormatException ignored) {
                page = 1;
            }

            // 4. Lấy danh sách nhật ký tiêu hủy theo phân trang & lọc
            List<InventoryWasteLog> logs = wasteService.getWasteLogsByShop(shopId, stage, keyword, page, DEFAULT_PAGE_SIZE);
            int totalItems = wasteService.countWasteLogsByShop(shopId, stage, keyword);
            int totalPages = (int) Math.ceil((double) totalItems / DEFAULT_PAGE_SIZE);
            if (totalPages < 1) {
                totalPages = 1;
            }

            // 5. Lấy số liệu thống kê chất lượng & tỷ lệ hao hụt
            WasteStatisticDTO stats = wasteService.getWasteStatisticsByShop(shopId);

            // 6. Lấy danh mục sản phẩm của shop để chọn trong modal báo hỏng kho
            List<ProductVariant> variants = productService.getVariantsByShopId(shopId);

            // 7. Lấy danh sách các đơn hàng chuyển hoàn (RETURNED/FAILED) đang chờ kiểm định / xử lý tiêu hủy
            List<SubOrder> pendingReturnedOrders = wasteService.getPendingReturnedOrdersByShop(shopId);

            // 8. Đẩy dữ liệu sang View
            request.setAttribute("wasteLogs", logs);
            request.setAttribute("stats", stats);
            request.setAttribute("variants", variants);
            request.setAttribute("pendingReturnedOrders", pendingReturnedOrders);
            request.setAttribute("currentStage", stage);
            request.setAttribute("keyword", keyword != null ? keyword : "");
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalItems", totalItems);
            request.setAttribute("activeMenu", "waste");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tải phân hệ quản lý hao hụt", e);
            request.setAttribute("errorMessage", "Lỗi tải quản lý hao hụt: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/shop/shop-waste.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"SHOP_OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Long shopId = (Long) session.getAttribute("shopId");
        if (shopId == null || shopId <= 0) {
            shopId = shopProductService.getShopIDByOwnerID(user.getId());
            if (shopId != null && shopId > 0) {
                session.setAttribute("shopId", shopId);
            } else {
                shopId = 1L;
            }
        }

        String action = request.getParameter("action");

        try {
            if ("manual_waste".equalsIgnoreCase(action) || "record_waste".equalsIgnoreCase(action)) {
                // --- THAO TÁC 1: Báo tiêu hủy nông sản hỏng (Trừ tồn kho tự động) ---
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String wasteStage = request.getParameter("wasteStage");
                String reasonCategory = request.getParameter("reasonCategory");
                String reasonDetail = request.getParameter("reasonNote");

                if (quantity <= 0) {
                    session.setAttribute("errorMessage", "Số lượng tiêu hủy phải lớn hơn 0!");
                    response.sendRedirect(request.getContextPath() + "/shop/waste");
                    return;
                }

                StringBuilder fullReason = new StringBuilder();
                if (reasonCategory != null && !reasonCategory.isBlank()) {
                    fullReason.append(reasonCategory.trim());
                }
                if (reasonDetail != null && !reasonDetail.isBlank()) {
                    if (fullReason.length() > 0) {
                        fullReason.append(" - ");
                    }
                    fullReason.append(reasonDetail.trim());
                }

                if (fullReason.length() == 0) {
                    fullReason.append("Nông sản dập nát / hư hỏng tại kho");
                }

                Long loggedBy = (long) user.getId();
                boolean ok = wasteService.recordManualWaste(shopId, variantId, wasteStage, quantity, fullReason.toString(), loggedBy);
                if (ok) {
                    session.setAttribute("successMessage", "Ghi nhận tiêu hủy " + quantity + " đơn vị nông sản thành công! Tồn kho đã được tự động cập nhật giảm.");
                } else {
                    session.setAttribute("errorMessage", "Số lượng tiêu hủy vượt quá tồn kho thực tế hiện tại!");
                }

            } else if ("return_waste".equalsIgnoreCase(action)) {
                // --- THAO TÁC 2: Xử lý hoàn hàng hỏng (Dập nát ghi log tiêu hủy, quả tươi hoàn kho) ---
                String subOrderCode = request.getParameter("subOrderCode");
                String wasteNote = request.getParameter("wasteNote");

                if (subOrderCode == null || subOrderCode.isBlank()) {
                    session.setAttribute("errorMessage", "Mã đơn hàng hoàn không hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/shop/waste");
                    return;
                }

                Map<Long, Integer> wastedQtyMap = new HashMap<>();
                Enumeration<String> paramNames = request.getParameterNames();
                while (paramNames.hasMoreElements()) {
                    String pName = paramNames.nextElement();
                    if (pName.startsWith("wastedQty_")) {
                        try {
                            long vId = Long.parseLong(pName.substring("wastedQty_".length()));
                            int qty = Integer.parseInt(request.getParameter(pName).trim());
                            wastedQtyMap.put(vId, qty);
                        } catch (NumberFormatException ignored) {
                        }
                    }
                }

                Long loggedBy = (long) user.getId();
                boolean ok = wasteService.logTransitDamageWasteByCode(subOrderCode.trim(), wasteNote, loggedBy, wastedQtyMap);
                if (ok) {
                    session.setAttribute("successMessage", "Xử lý hàng hoàn " + subOrderCode + " thành công! Số lượng dập nát đã ghi vào sổ hao hụt và nông sản tươi còn lại đã được hoàn trả về kho bán.");
                } else {
                    session.setAttribute("errorMessage", "Xử lý hàng hoàn thất bại hoặc đơn hàng đã được kiểm định trước đó!");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi xử lý yêu cầu tiêu hủy trong ShopWasteServlet", e);
            session.setAttribute("errorMessage", "Thao tác thất bại: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/shop/waste");
    }
}
