package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import model.MembershipTier;
import service.ILoyaltyService;
import service.impl.LoyaltyServiceImpl;

/**
 * Admin quản lý hạng thành viên (FE-14): thêm, sửa, ngừng kích hoạt và xóa hạng. Bảo vệ bởi bộ lọc /admin/*.
 *
 * GET  /admin/membership-tiers[?q=][&edit=ID]
 * POST /admin/membership-tiers action=save (tierId trống = tạo mới) | delete
 */
@WebServlet(name = "AdminMembershipTierServlet", urlPatterns = {"/admin/membership-tiers"})
public class AdminMembershipTierServlet extends HttpServlet {

    private final ILoyaltyService loyaltyService = new LoyaltyServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String q = request.getParameter("q") == null ? "" : request.getParameter("q").trim();
        request.setAttribute("tiers", loyaltyService.listTiers(false, q));
        request.setAttribute("q", q);
        int editId = (int) parseLong(request.getParameter("edit"));
        if (editId > 0) {
            request.setAttribute("editTier", loyaltyService.findTier(editId));
        }
        request.getRequestDispatcher("/views/admin/membership-tiers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        String redirect = request.getContextPath() + "/admin/membership-tiers";
        try {
            if ("delete".equals(action)) {
                loyaltyService.deleteTier((int) parseLong(request.getParameter("tierId")));
                session.setAttribute("adminFlash", "Đã xóa hạng thành viên.");
            } else if ("save".equals(action)) {
                MembershipTier tier = readTier(request);
                if (tier.getTierId() > 0) {
                    loyaltyService.updateTier(tier);
                    session.setAttribute("adminFlash", "Đã cập nhật hạng \"" + tier.getTierName() + "\".");
                } else {
                    loyaltyService.createTier(tier);
                    session.setAttribute("adminFlash", "Đã tạo hạng \"" + tier.getTierName() + "\".");
                }
            } else {
                session.setAttribute("adminError", "Thao tác không hợp lệ!");
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            session.setAttribute("adminError", ex.getMessage());
            if ("save".equals(action) && parseLong(request.getParameter("tierId")) > 0) {
                redirect += "?edit=" + parseLong(request.getParameter("tierId"));
            }
        } catch (Exception ex) {
            session.setAttribute("adminError", "Không thể xử lý do lỗi hệ thống. Vui lòng thử lại!");
        }
        response.sendRedirect(redirect);
    }

    private MembershipTier readTier(HttpServletRequest request) {
        MembershipTier t = new MembershipTier();
        t.setTierId((int) parseLong(request.getParameter("tierId")));
        t.setTierName(request.getParameter("tierName"));
        try {
            t.setMinPoints(Integer.parseInt(request.getParameter("minPoints").trim()));
            t.setPointMultiplier(new BigDecimal(request.getParameter("pointMultiplier").trim().replace(',', '.')));
            String cap = request.getParameter("redeemCapPercent");
            t.setRedeemCapPercent(cap == null || cap.trim().isEmpty() ? null : new BigDecimal(cap.trim().replace(',', '.')));
        } catch (NumberFormatException | NullPointerException ex) {
            throw new IllegalArgumentException("Điểm tối thiểu, hệ số nhân và trần dùng điểm phải là số hợp lệ!");
        }
        String color = request.getParameter("badgeColor");
        t.setBadgeColor(color == null || color.isBlank() ? "#16a34a" : color.trim());
        String desc = request.getParameter("description");
        t.setDescription(desc == null || desc.isBlank() ? null : (desc.trim().length() > 255 ? desc.trim().substring(0, 255) : desc.trim()));
        t.setActive(request.getParameter("active") != null);
        return t;
    }

    private long parseLong(String s) {
        try {
            return Long.parseLong(s.trim());
        } catch (Exception ex) {
            return 0;
        }
    }
}
