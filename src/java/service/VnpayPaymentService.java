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

/**
 * Service xử lý các nghiệp vụ thanh toán trực tuyến qua cổng VNPAY:
 * - Tạo URL thanh toán VNPAY có mã hóa chữ ký số HMAC-SHA512.
 * - Xử lý callback kết quả giao dịch (Return URL / IPN) từ VNPAY.
 * - Cập nhật trạng thái thanh toán của đơn hàng.
 */
public class VnpayPaymentService {

    private static final ZoneId VNPAY_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNPAY_TIME = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private final VnpayPaymentDAO paymentDAO;

    /**
     * Khởi tạo VnpayPaymentService với VnpayPaymentDAO mặc định.
     */
    public VnpayPaymentService() {
        this(new VnpayPaymentDAO());
    }

    /**
     * Khởi tạo VnpayPaymentService với VnpayPaymentDAO tùy chỉnh (hỗ trợ kiểm thử).
     *
     * @param paymentDAO DAO tương tác bảng payments và cập nhật trạng thái đơn
     */
    public VnpayPaymentService(VnpayPaymentDAO paymentDAO) {
        this.paymentDAO = paymentDAO;
    }

    /**
     * Tạo đường dẫn (URL) chuyển hướng người dùng sang cổng thanh toán VNPAY.
     * Các tham số bao gồm: mã merchant (vnp_TmnCode), số tiền x100 (vnp_Amount),
     * mã tham chiếu đơn hàng (vnp_TxnRef), IP khách hàng, thời gian tạo và hết hạn.
     *
     * @param order     đơn hàng cần thanh toán
     * @param clientIp  địa chỉ IP của khách hàng
     * @param returnUrl URL nhận kết quả trả về sau khi khách thanh toán xong trên VNPAY
     * @return URL hoàn chỉnh kèm chuỗi chữ ký bảo mật checksum HMAC-SHA512
     */
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
        // VNPAY quy định số tiền tính theo đơn vị xu (nhân 100 so với VND thực tế)
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

    /**
     * Xử lý kết quả callback (từ IPN hoặc Return URL) do VNPAY gửi về:
     * - Trích xuất mã đơn hàng (vnp_TxnRef) và số tiền (vnp_Amount).
     * - Kiểm tra mã phản hồi vnp_ResponseCode = "00" và mã trạng thái vnp_TransactionStatus = "00".
     * - Cập nhật trạng thái đơn hàng (PAID nếu thành công, FAILED nếu thất bại).
     *
     * @param parameters map tham số HTTP nhận từ callback của VNPAY
     * @return CallbackResult chứa trạng thái cập nhật đơn hàng và kết quả xử lý
     */
    public CallbackResult processCallback(Map<String, String[]> parameters) {
        long orderId = parseOrderId(first(parameters.get("vnp_TxnRef")));
        BigDecimal amount = parseAmount(first(parameters.get("vnp_Amount")));
        // Mã "00" thể hiện giao dịch thanh toán thành công
        boolean successful = "00".equals(first(parameters.get("vnp_ResponseCode")))
                && "00".equals(first(parameters.get("vnp_TransactionStatus")));
        return paymentDAO.processCallback(orderId, amount, successful);
    }

    /**
     * Lấy thông tin đơn hàng gắn liền với giao dịch VNPAY theo orderId.
     *
     * @param orderId ID đơn hàng
     * @return đối tượng Order tương ứng
     */
    public Order getOrder(long orderId) {
        return paymentDAO.getVnpayOrder(orderId);
    }

    /**
     * Chuyển đổi mã tham chiếu giao dịch (vnp_TxnRef) sang dạng số orderId.
     *
     * @param transactionReference chuỗi tham chiếu giao dịch
     * @return ID đơn hàng
     * @throws IllegalArgumentException nếu chuỗi rỗng hoặc không phải số nguyên dương hợp lệ
     */
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

    /**
     * Chuyển đổi số tiền trả về từ VNPAY (chia lại cho 100 để trở về mệnh giá VND thực tế).
     *
     * @param amount chuỗi số tiền từ VNPAY
     * @return số tiền BigDecimal theo VND
     * @throws IllegalArgumentException nếu dữ liệu số tiền không hợp lệ
     */
    private static BigDecimal parseAmount(String amount) {
        try {
            return new BigDecimal(amount).movePointLeft(2);
        } catch (NumberFormatException | NullPointerException ex) {
            throw new IllegalArgumentException("Số tiền VNPAY không hợp lệ", ex);
        }
    }

    /**
     * Lấy giá trị đầu tiên trong mảng tham số request HTTP.
     *
     * @param values mảng chuỗi giá trị
     * @return phần tử đầu tiên hoặc null nếu mảng rỗng
     */
    private static String first(String[] values) {
        return values != null && values.length > 0 ? values[0] : null;
    }
}
