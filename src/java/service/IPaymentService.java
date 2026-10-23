package service;

import java.util.List;
import java.util.Map;
import model.Payment;
import model.PaymentOutcome;
import model.PaymentStats;

public interface IPaymentService {

    /** VNPAY hoặc BANK_TRANSFER. COD không đi qua cổng thanh toán. */
    boolean isOnlineProvider(String provider);

    /**
     * Khởi tạo giao dịch cho đơn đang chờ thanh toán và dựng yêu cầu gửi cổng.
     *
     * @param baseUrl scheme://host:port/context, dùng dựng URL quay về
     * @return URL của cổng thanh toán (đã ký) để redirect khách hàng sang
     */
    String startOnlinePayment(long customerId, long orderId, String provider, String baseUrl) throws Exception;

    /** Xác thực chữ ký, đối chiếu số tiền và cập nhật trạng thái theo phản hồi của cổng. */
    PaymentOutcome processGatewayReturn(Map<String, String> gatewayParams, long customerId);

    /**
     * Thanh toán lại bằng phương thức khác: đổi đơn chờ thanh toán online sang COD
     * mà không phải tạo lại giỏ hàng.
     *
     * @return mã đơn hàng
     */
    String switchToCod(long customerId, long orderId) throws Exception;

    /** Khách chọn "hủy đơn" sau khi thanh toán thất bại. */
    void cancelUnpaidOrder(long customerId, long orderId) throws Exception;

    Payment getLatestPaymentByOrder(long orderId);

    Payment getPaymentByTransactionCode(String transactionCode);

    List<Payment> searchPayments(Long customerId, String keyword, String provider, String status,
            int days, int page, int pageSize);

    int countPayments(Long customerId, String keyword, String provider, String status, int days);

    PaymentStats getStats(Long customerId);
}
