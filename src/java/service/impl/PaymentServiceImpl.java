package service.impl;

import dao.OrderDAO;
import dao.PaymentDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import model.Payment;
import model.PaymentOutcome;
import model.PaymentStats;
import service.IPaymentService;
import util.PaymentGatewayUtil;

public class PaymentServiceImpl implements IPaymentService {

    private final PaymentDAO paymentDAO;
    private final OrderDAO orderDAO;

    public PaymentServiceImpl() {
        this.paymentDAO = new PaymentDAO();
        this.orderDAO = new OrderDAO();
    }

    public PaymentServiceImpl(PaymentDAO paymentDAO, OrderDAO orderDAO) {
        this.paymentDAO = paymentDAO;
        this.orderDAO = orderDAO;
    }

    @Override
    public boolean isOnlineProvider(String provider) {
        if (provider == null) {
            return false;
        }
        String p = provider.trim().toUpperCase(Locale.ROOT);
        return Payment.PROVIDER_VNPAY.equals(p) || Payment.PROVIDER_BANK_TRANSFER.equals(p);
    }

    // ------------------------------------------------------------------
    // Bước hệ thống: Initialize payment transaction -> Generate gateway request
    // ------------------------------------------------------------------
    @Override
    public String startOnlinePayment(long customerId, long orderId, String provider, String baseUrl)
            throws Exception {
        if (!isOnlineProvider(provider)) {
            throw new IllegalArgumentException("Phương thức thanh toán online không hợp lệ!");
        }
        String normalized = provider.trim().toUpperCase(Locale.ROOT);
        String txnCode = PaymentGatewayUtil.generateTransactionCode(normalized);

        Payment payment = paymentDAO.initiateTransaction(orderId, customerId, normalized, txnCode);

        Date now = new Date();
        Date expire = new Date(now.getTime() + PaymentGatewayUtil.EXPIRE_MINUTES * 60_000L);

        Map<String, String> req = new LinkedHashMap<>();
        req.put("vnp_Version", "2.1.0");
        req.put("vnp_Command", "pay");
        req.put("vnp_TmnCode", PaymentGatewayUtil.TMN_CODE);
        req.put("vnp_Amount", String.valueOf(toGatewayAmount(payment.getAmount())));
        req.put("vnp_CurrCode", "VND");
        req.put("vnp_TxnRef", txnCode);
        req.put("vnp_OrderInfo", "Thanh toan don hang " + payment.getOrderCode());
        req.put("vnp_OrderType", "other");
        req.put("vnp_Locale", "vn");
        req.put("vnp_ReturnUrl", baseUrl + "/payment/return");
        req.put("vnp_BankCode", Payment.PROVIDER_BANK_TRANSFER.equals(normalized) ? "VNBANK" : "VNPAYQR");
        req.put("vnp_CreateDate", PaymentGatewayUtil.formatDate(now));
        req.put("vnp_ExpireDate", PaymentGatewayUtil.formatDate(expire));

        return baseUrl + "/payment/gateway?" + PaymentGatewayUtil.signedQuery(req);
    }

    // ------------------------------------------------------------------
    // Bước hệ thống: Process payment & verify transaction signature
    // ------------------------------------------------------------------
    @Override
    public PaymentOutcome processGatewayReturn(Map<String, String> params, long customerId) {
        String txnRef = params.get("vnp_TxnRef");
        Payment payment = txnRef == null ? null : paymentDAO.findByTransactionCode(txnRef);

        // Giao dịch không tồn tại hoặc không thuộc khách đang đăng nhập.
        if (payment == null || payment.getCustomerId() != customerId) {
            return new PaymentOutcome(false, 0, txnRef, "01", "Không tìm thấy giao dịch thanh toán");
        }

        // Cổng gọi lại nhiều lần / khách F5: trả đúng kết quả đã ghi nhận, không xử lý lại.
        if (!payment.isPending()) {
            return new PaymentOutcome(payment.isSuccess(), payment.getOrderId(), txnRef,
                    payment.isSuccess() ? PaymentGatewayUtil.RESP_SUCCESS : "02",
                    payment.isSuccess() ? "Giao dịch đã được ghi nhận thành công"
                            : (payment.getFailureReason() != null ? payment.getFailureReason()
                                    : "Giao dịch đã kết thúc không thành công"));
        }

        if (!PaymentGatewayUtil.verify(params)) {
            return fail(payment, PaymentGatewayUtil.RESP_INVALID_SIGNATURE);
        }

        long expectedAmount = toGatewayAmount(payment.getAmount());
        long receivedAmount;
        try {
            receivedAmount = Long.parseLong(params.getOrDefault("vnp_Amount", "-1"));
        } catch (NumberFormatException ex) {
            receivedAmount = -1;
        }
        if (receivedAmount != expectedAmount) {
            return fail(payment, PaymentGatewayUtil.RESP_WRONG_AMOUNT);
        }

        String code = params.get("vnp_ResponseCode");
        boolean gatewayOk = PaymentGatewayUtil.RESP_SUCCESS.equals(code)
                && PaymentGatewayUtil.RESP_SUCCESS.equals(params.get("vnp_TransactionStatus"));
        if (!gatewayOk) {
            return fail(payment, code);
        }

        if (paymentDAO.markSuccess(txnRef)) {
            return new PaymentOutcome(true, payment.getOrderId(), txnRef,
                    PaymentGatewayUtil.RESP_SUCCESS, "Thanh toán thành công");
        }
        // markSuccess trả false khi giao dịch vừa được xử lý ở request khác.
        Payment latest = paymentDAO.findByTransactionCode(txnRef);
        boolean ok = latest != null && latest.isSuccess();
        return new PaymentOutcome(ok, payment.getOrderId(), txnRef,
                ok ? PaymentGatewayUtil.RESP_SUCCESS : "02",
                ok ? "Giao dịch đã được ghi nhận thành công" : "Giao dịch không thành công");
    }

    private PaymentOutcome fail(Payment payment, String responseCode) {
        String reason = PaymentGatewayUtil.messageForResponseCode(responseCode);
        paymentDAO.markFailed(payment.getTransactionCode(), reason);
        return new PaymentOutcome(false, payment.getOrderId(), payment.getTransactionCode(),
                responseCode, reason);
    }

    @Override
    public String switchToCod(long customerId, long orderId) throws Exception {
        return paymentDAO.switchToCod(orderId, customerId);
    }

    // ------------------------------------------------------------------
    // Khách chọn hủy đơn sau khi thanh toán thất bại
    // ------------------------------------------------------------------
    @Override
    public void cancelUnpaidOrder(long customerId, long orderId) throws Exception {
        Payment payment = paymentDAO.findLatestByOrderId(orderId);
        if (payment == null || payment.getCustomerId() != customerId) {
            throw new IllegalArgumentException("Không tìm thấy đơn hàng!");
        }
        if ("PAID".equalsIgnoreCase(payment.getOrderPaymentStatus())
                || !"PENDING".equalsIgnoreCase(payment.getOrderStatus())) {
            throw new IllegalStateException("Chỉ có thể hủy đơn đang chờ thanh toán!");
        }
        // Dùng lại luồng hủy của nhóm: hoàn kho, hoàn lượt dùng voucher, đồng bộ trạng thái.
        orderDAO.cancelOrderByCustomer(customerId, payment.getOrderCode(),
                "Khách hàng hủy đơn do chưa thanh toán online");
        paymentDAO.failPendingForOrder(orderId, "Khách hàng hủy đơn hàng");
    }

    @Override
    public Payment getLatestPaymentByOrder(long orderId) {
        return paymentDAO.findLatestByOrderId(orderId);
    }

    @Override
    public Payment getPaymentByTransactionCode(String transactionCode) {
        return paymentDAO.findByTransactionCode(transactionCode);
    }

    @Override
    public List<Payment> searchPayments(Long customerId, String keyword, String provider, String status,
            int days, int page, int pageSize) {
        return paymentDAO.search(customerId, keyword, provider, status, days, page, pageSize);
    }

    @Override
    public int countPayments(Long customerId, String keyword, String provider, String status, int days) {
        return paymentDAO.count(customerId, keyword, provider, status, days);
    }

    @Override
    public PaymentStats getStats(Long customerId) {
        return paymentDAO.getStats(customerId);
    }

    /** VNPay tính tiền theo đơn vị nhỏ nhất: số tiền VND x 100. */
    private long toGatewayAmount(BigDecimal amount) {
        return amount.setScale(0, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).longValueExact();
    }
}
