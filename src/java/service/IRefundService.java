package service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import model.Refund;

public interface IRefundService {

    Refund issueManualRefund(String subOrderCode, BigDecimal amount, String reason, long adminId) throws Exception;

    /** decision: REFUND_BUYER | PARTIAL_REFUND | REJECT_CLAIM. Trả về null khi bác bỏ khiếu nại. */
    Refund resolveDispute(String disputeCode, String decision, BigDecimal partialAmount, String note, long adminId)
            throws Exception;

    void requestMoreInfo(String disputeCode, String note, long adminId) throws Exception;

    /** Gọi sau khi hủy đơn: tự hoàn toàn phần nếu đơn đã thanh toán online. */
    List<Refund> autoRefundOnCancel(Long customerId, String identifier) throws Exception;

    List<Refund> search(String keyword, String source, int page, int pageSize);

    int count(String keyword, String source);

    Map<String, Object> getSummary();

    List<Map<String, Object>> listPendingDisputes();
}
