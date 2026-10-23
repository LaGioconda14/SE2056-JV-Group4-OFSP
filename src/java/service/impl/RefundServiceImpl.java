package service.impl;

import dao.RefundDAO;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.Refund;
import service.IRefundService;

public class RefundServiceImpl implements IRefundService {

    private final RefundDAO refundDAO = new RefundDAO();

    @Override
    public Refund issueManualRefund(String subOrderCode, BigDecimal amount, String reason, long adminId) throws Exception {
        String cleanReason = (reason == null || reason.trim().isEmpty()) ? "Admin hoàn tiền thủ công" : reason.trim();
        return refundDAO.issueManualRefund(subOrderCode, amount, cleanReason, adminId);
    }

    @Override
    public Refund resolveDispute(String disputeCode, String decision, BigDecimal partialAmount, String note,
            long adminId) throws Exception {
        return refundDAO.resolveDispute(disputeCode, decision, partialAmount, note, adminId);
    }

    @Override
    public void requestMoreInfo(String disputeCode, String note, long adminId) throws Exception {
        refundDAO.requestMoreInfo(disputeCode, note, adminId);
    }

    @Override
    public List<Refund> autoRefundOnCancel(Long customerId, String identifier) throws Exception {
        return refundDAO.autoRefundOnCancel(customerId, identifier);
    }

    @Override
    public List<Refund> search(String keyword, String source, int page, int pageSize) {
        return refundDAO.search(keyword, source, page, pageSize);
    }

    @Override
    public int count(String keyword, String source) {
        return refundDAO.count(keyword, source);
    }

    @Override
    public Map<String, Object> getSummary() {
        return refundDAO.getSummary();
    }

    @Override
    public List<Map<String, Object>> listPendingDisputes() {
        return refundDAO.listPendingDisputes();
    }
}
