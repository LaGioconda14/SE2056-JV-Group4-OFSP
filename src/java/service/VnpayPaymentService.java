package service;

import dao.VnpayPaymentDAO;
import dao.VnpayPaymentDAO.CallbackResult;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;
import model.entity.order.Order;
import util.VnpayConfig;
import util.VnpayUtil;

public class VnpayPaymentService {

    private static final ZoneId VNPAY_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNPAY_TIME = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private final VnpayPaymentDAO paymentDAO = new VnpayPaymentDAO();

    public String createPaymentUrl(Order order, String clientIp, String returnUrl) {
        if (order == null || order.getFinalAmount() == null) {
            throw new IllegalArgumentException("Đơn hàng thanh toán không hợp lệ");
        }
        if (returnUrl == null || returnUrl.isBlank()) {
            throw new IllegalArgumentException("Return URL của VNPAY không hợp lệ");
        }
        ZonedDateTime createdAt = ZonedDateTime.now(VNPAY_ZONE);
        Map<String, String> parameters = new LinkedHashMap<>();
        parameters.put("vnp_Version", VnpayConfig.getVersion());
        parameters.put("vnp_Command", VnpayConfig.getCommand());
        parameters.put("vnp_TmnCode", VnpayConfig.getTmnCode());
        parameters.put("vnp_Amount", order.getFinalAmount().movePointRight(2)
                .setScale(0, RoundingMode.HALF_UP).toPlainString());
        parameters.put("vnp_CurrCode", "VND");
        parameters.put("vnp_TxnRef", Long.toString(order.getOrderId()));
        parameters.put("vnp_OrderInfo", "Thanh toan don hang " + order.getOrderCode());
        parameters.put("vnp_OrderType", "other");
        parameters.put("vnp_Locale", VnpayConfig.getLocale());
        parameters.put("vnp_ReturnUrl", returnUrl);
        parameters.put("vnp_IpAddr", clientIp);
        parameters.put("vnp_CreateDate", VNPAY_TIME.format(createdAt));
        parameters.put("vnp_ExpireDate", VNPAY_TIME.format(
                createdAt.plusMinutes(VnpayConfig.getOrderTimeoutMinutes())));
        return VnpayUtil.buildPaymentUrl(parameters);
    }

    public CallbackResult processCallback(Map<String, String[]> parameters) {
        long orderId = parseOrderId(first(parameters.get("vnp_TxnRef")));
        BigDecimal amount = parseAmount(first(parameters.get("vnp_Amount")));
        boolean successful = "00".equals(first(parameters.get("vnp_ResponseCode")))
                && "00".equals(first(parameters.get("vnp_TransactionStatus")));
        return paymentDAO.processCallback(orderId, amount, successful);
    }

    public Order getOrder(long orderId) {
        return paymentDAO.getVnpayOrder(orderId);
    }

    public static long parseOrderId(String transactionReference) {
        try {
            long orderId = Long.parseLong(transactionReference);
            if (orderId <= 0) {
                throw new NumberFormatException();
            }
            return orderId;
        } catch (NumberFormatException | NullPointerException ex) {
            throw new IllegalArgumentException("Mã giao dịch VNPAY không hợp lệ", ex);
        }
    }

    private static BigDecimal parseAmount(String amount) {
        try {
            return new BigDecimal(amount).movePointLeft(2);
        } catch (NumberFormatException | NullPointerException ex) {
            throw new IllegalArgumentException("Số tiền VNPAY không hợp lệ", ex);
        }
    }

    private static String first(String[] values) {
        return values != null && values.length > 0 ? values[0] : null;
    }
}
