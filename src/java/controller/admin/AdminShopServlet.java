package controller.admin;

import com.google.gson.Gson;
import dao.AdminManagementDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "AdminShopServlet", urlPatterns = {"/admin/shops"})
public class AdminShopServlet extends HttpServlet {
    private final AdminManagementDAO dao = new AdminManagementDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        // AJAX endpoint: Chi tiết hồ sơ KYC đăng ký gian hàng
        if ("requestDetail".equalsIgnoreCase(action)) {
            String reqIdStr = request.getParameter("requestId");
            response.setContentType("application/json; charset=UTF-8");
            if (reqIdStr != null && !reqIdStr.trim().isEmpty()) {
                try {
                    long reqId = Long.parseLong(reqIdStr.trim());
                    Map<String, Object> reqDetail = dao.getShopRequestDetail(reqId);
                    if (reqDetail != null) {
                        response.getWriter().write(gson.toJson(reqDetail));
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("{\"error\": \"Không tìm thấy thông tin hồ sơ đăng ký mở shop!\"}");
            return;
        }

        // AJAX endpoint: Chi tiết gian hàng
        if ("shopDetail".equalsIgnoreCase(action)) {
            String shopIdStr = request.getParameter("shopId");
            response.setContentType("application/json; charset=UTF-8");
            if (shopIdStr != null && !shopIdStr.trim().isEmpty()) {
                try {
                    long sId = Long.parseLong(shopIdStr.trim());
                    Map<String, Object> sDetail = dao.getShopDetail(sId);
                    if (sDetail != null) {
                        response.getWriter().write(gson.toJson(sDetail));
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("{\"error\": \"Không tìm thấy thông tin gian hàng!\"}");
            return;
        }

        // Handle flash session messages
        HttpSession session = request.getSession();
        if (session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }
        if (session.getAttribute("errorMessage") != null) {
            request.setAttribute("errorMessage", session.getAttribute("errorMessage"));
            session.removeAttribute("errorMessage");
        }

        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = request.getParameter("tab");
        }
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "ALL";
        }

        String cert = request.getParameter("cert");
        if (cert == null || cert.trim().isEmpty()) {
            cert = "ALL";
        }

        String search = request.getParameter("search");
        if (search != null) {
            search = search.trim();
        }

        request.setAttribute("selectedStatus", status.toUpperCase());
        request.setAttribute("selectedType", type);
        request.setAttribute("selectedCert", cert);
        request.setAttribute("searchKeyword", search != null ? search : "");
        request.setAttribute("shopStats", dao.getShopStats());
        request.setAttribute("shopsList", dao.getShopsList(status, type, cert, search));
        request.setAttribute("shopRequestsList", dao.getShopRequestsList(status.equals("PENDING_KYC") ? "ALL" : null, search));
        request.getRequestDispatcher("/views/admin/shops.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        User currentUser = (User) session.getAttribute("user");
        long adminId = currentUser != null ? currentUser.getId() : 1;

        String currentStatus = request.getParameter("currentStatus");
        if (currentStatus == null || currentStatus.trim().isEmpty()) {
            currentStatus = "ALL";
        }

        if ("approveRequest".equalsIgnoreCase(action)) {
            String reqIdStr = request.getParameter("requestId");
            String reviewNote = request.getParameter("reviewNote");
            String commRateStr = request.getParameter("commissionRate");
            double commissionRate = 8.0;
            if (commRateStr != null && !commRateStr.trim().isEmpty()) {
                try {
                    commissionRate = Double.parseDouble(commRateStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            if (reqIdStr != null && !reqIdStr.trim().isEmpty()) {
                try {
                    long reqId = Long.parseLong(reqIdStr.trim());
                    boolean ok = dao.approveShopRequest(reqId, adminId, reviewNote, commissionRate);
                    if (ok) {
                        session.setAttribute("successMessage", "Phê duyệt hồ sơ #" + reqId + " thành công! Gian hàng đã được kích hoạt ở trạng thái ACTIVE và cấp quyền SHOP_OWNER cho chủ tài khoản.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể phê duyệt hồ sơ mở shop. Vui lòng thử lại!");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Mã hồ sơ không hợp lệ!");
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/shops?status=PENDING_KYC");
            return;
        }

        if ("rejectRequest".equalsIgnoreCase(action)) {
            String reqIdStr = request.getParameter("requestId");
            String reviewNote = request.getParameter("reviewNote");

            if (reviewNote == null || reviewNote.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Bắt buộc phải nhập lý do từ chối để phản hồi cho nhà vườn!");
            } else if (reqIdStr != null && !reqIdStr.trim().isEmpty()) {
                try {
                    long reqId = Long.parseLong(reqIdStr.trim());
                    boolean ok = dao.rejectShopRequest(reqId, adminId, reviewNote.trim());
                    if (ok) {
                        session.setAttribute("successMessage", "Đã từ chối hồ sơ #" + reqId + " và lưu lý do phản hồi thành công.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể từ chối hồ sơ. Vui lòng thử lại!");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Mã hồ sơ không hợp lệ!");
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/shops?status=PENDING_KYC");
            return;
        }

        if ("suspendShop".equalsIgnoreCase(action)) {
            String shopIdStr = request.getParameter("shopId");
            String reason = request.getParameter("reason");

            if (reason == null || reason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập lý do đình chỉ hoạt động của gian hàng!");
            } else if (shopIdStr != null && !shopIdStr.trim().isEmpty()) {
                try {
                    long shopId = Long.parseLong(shopIdStr.trim());
                    boolean ok = dao.updateShopStatus(shopId, "SUSPENDED", reason.trim());
                    if (ok) {
                        session.setAttribute("successMessage", "Đã đình chỉ (SUSPENDED) hoạt động của gian hàng ID #" + shopId + " thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể đình chỉ gian hàng. Vui lòng thử lại!");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Mã gian hàng không hợp lệ!");
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/shops?status=" + URLEncoder.encode(currentStatus, StandardCharsets.UTF_8));
            return;
        }

        if ("reactivateShop".equalsIgnoreCase(action)) {
            String shopIdStr = request.getParameter("shopId");
            if (shopIdStr != null && !shopIdStr.trim().isEmpty()) {
                try {
                    long shopId = Long.parseLong(shopIdStr.trim());
                    boolean ok = dao.updateShopStatus(shopId, "ACTIVE", null);
                    if (ok) {
                        session.setAttribute("successMessage", "Đã mở lại hoạt động (ACTIVE) cho gian hàng ID #" + shopId + " thành công!");
                    } else {
                        session.setAttribute("errorMessage", "Không thể mở lại hoạt động gian hàng. Vui lòng thử lại!");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Mã gian hàng không hợp lệ!");
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/shops?status=" + URLEncoder.encode(currentStatus, StandardCharsets.UTF_8));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/shops");
    }
}
