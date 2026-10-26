package controller.order;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Dispute;
import model.User;
import service.IDisputeService;
import service.impl.DisputeServiceImpl;

@WebServlet(name = "CustomerReturnServlet", urlPatterns = {"/customer/return"})
public class CustomerReturnServlet extends HttpServlet {

    private final IDisputeService disputeService = new DisputeServiceImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String subOrderIdStr = request.getParameter("subOrderId");
        String disputeCode = request.getParameter("disputeCode");

        Dispute dispute = null;
        if (subOrderIdStr != null && !subOrderIdStr.trim().isEmpty()) {
            dispute = disputeService.getDisputeBySubOrderId(Long.parseLong(subOrderIdStr));
        } else if (disputeCode != null && !disputeCode.trim().isEmpty()) {
            dispute = disputeService.getDisputeByCode(disputeCode.trim());
        }

        if (dispute != null) {
            out.print(gson.toJson(dispute));
        } else {
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("message", "Không tìm thấy thông tin khiếu nại trả hàng");
            out.print(gson.toJson(err));
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String subOrderIdStr = request.getParameter("subOrderId");
        String shopIdStr = request.getParameter("shopId");
        String reasonCategory = request.getParameter("reasonCategory");
        String complaintText = request.getParameter("complaintText");
        String claimAmountStr = request.getParameter("claimAmount");
        String evidenceImageUrl = request.getParameter("evidenceImageUrl");

        long subOrderId = 0;
        long shopId = 0;
        BigDecimal claimAmount = BigDecimal.ZERO;

        try {
            if (subOrderIdStr != null) subOrderId = Long.parseLong(subOrderIdStr);
            if (shopIdStr != null) shopId = Long.parseLong(shopIdStr);
            if (claimAmountStr != null && !claimAmountStr.trim().isEmpty()) {
                claimAmount = new BigDecimal(claimAmountStr.replaceAll("[^0-9.]", ""));
            }
        } catch (Exception ignored) {
        }

        Dispute dispute = new Dispute();
        dispute.setSubOrderId(subOrderId);
        dispute.setCustomerId(user.getId());
        dispute.setShopId(shopId > 0 ? shopId : 1);
        dispute.setReasonCategory(reasonCategory);
        dispute.setComplaintText(complaintText);
        dispute.setClaimAmount(claimAmount);
        dispute.setEvidenceImageUrl(evidenceImageUrl != null && !evidenceImageUrl.trim().isEmpty()
                ? evidenceImageUrl.trim()
                : "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&fit=crop");

        boolean ok = disputeService.createDispute(dispute);

        if (ok) {
            session.setAttribute("successMessage", "Yêu cầu Trả hàng / Hoàn tiền mã [" + dispute.getDisputeCode() + "] đã được gửi tới Người bán & Sàn FreshFruit.");
        } else {
            session.setAttribute("errorMessage", "Không thể gửi yêu cầu trả hàng. Vui lòng thử lại!");
        }

        response.sendRedirect(request.getContextPath() + "/profile#orders");
    }
}

