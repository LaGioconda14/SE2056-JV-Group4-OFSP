package util;

import jakarta.servlet.http.HttpServletRequest;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * Tiện ích cho cổng thanh toán GIẢ LẬP (Mock VNPay) của đồ án.
 * Cách ký/xác thực bám theo chuẩn VNPay: sắp xếp tham số theo tên, URL-encode,
 * rồi HMAC-SHA512 với khóa bí mật. Khi chuyển sang VNPay Sandbox thật chỉ cần
 * đổi TMN_CODE, HASH_SECRET và địa chỉ cổng.
 */
public final class PaymentGatewayUtil {

    /** Mã website do cổng cấp (giả lập). */
    public static final String TMN_CODE = "OFSPDEMO";
    /** Khóa bí mật dùng ký/xác thực - nên chuyển sang file cấu hình khi triển khai thật. */
    public static final String HASH_SECRET = "OFSP-MOCK-VNPAY-SECRET-KEY-GROUP4-2026";
    /** Thời gian chờ thanh toán (phút). */
    public static final int EXPIRE_MINUTES = 15;

    public static final String RESP_SUCCESS = "00";
    public static final String RESP_TIMEOUT = "15";
    public static final String RESP_CANCELLED = "24";
    public static final String RESP_INSUFFICIENT = "51";
    public static final String RESP_WRONG_AMOUNT = "04";
    public static final String RESP_INVALID_SIGNATURE = "97";

    private static final SecureRandom RANDOM = new SecureRandom();

    private PaymentGatewayUtil() {
    }

    public static String hmacSha512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(raw.length * 2);
            for (byte b : raw) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception ex) {
            throw new IllegalStateException("Không thể tạo chữ ký giao dịch", ex);
        }
    }

    /** Chuỗi dữ liệu để ký: bỏ vnp_SecureHash, sắp xếp theo tên, URL-encode giá trị. */
    public static String buildQuery(Map<String, String> params) {
        List<String> names = new ArrayList<>(params.keySet());
        Collections.sort(names);
        StringBuilder sb = new StringBuilder();
        for (String name : names) {
            if ("vnp_SecureHash".equals(name) || "vnp_SecureHashType".equals(name)) {
                continue;
            }
            String value = params.get(name);
            if (value == null || value.isEmpty()) {
                continue;
            }
            if (sb.length() > 0) {
                sb.append('&');
            }
            sb.append(name).append('=').append(URLEncoder.encode(value, StandardCharsets.UTF_8));
        }
        return sb.toString();
    }

    public static String sign(Map<String, String> params) {
        return hmacSha512(HASH_SECRET, buildQuery(params));
    }

    /** Trả về chuỗi query đã ký (đã kèm vnp_SecureHash). */
    public static String signedQuery(Map<String, String> params) {
        String query = buildQuery(params);
        return query + "&vnp_SecureHash=" + hmacSha512(HASH_SECRET, query);
    }

    public static boolean verify(Map<String, String> params) {
        String received = params.get("vnp_SecureHash");
        if (received == null || received.isEmpty()) {
            return false;
        }
        String expected = sign(params);
        return MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                received.toLowerCase().getBytes(StandardCharsets.UTF_8));
    }

    /** Lấy toàn bộ tham số vnp_* từ request thành Map. */
    public static Map<String, String> readGatewayParams(HttpServletRequest request) {
        Map<String, String> map = new LinkedHashMap<>();
        for (String name : Collections.list(request.getParameterNames())) {
            if (name.startsWith("vnp_")) {
                map.put(name, request.getParameter(name));
            }
        }
        return map;
    }

    public static String generateTransactionCode(String provider) {
        String prefix = "BANK_TRANSFER".equalsIgnoreCase(provider) ? "BANK" : "VNPAY";
        return prefix + "-" + new SimpleDateFormat("yyMMddHHmm").format(new Date())
                + String.format("%06d", RANDOM.nextInt(1_000_000));
    }

    public static String generateGatewayTransactionNo() {
        return String.valueOf(10_000_000L + RANDOM.nextInt(90_000_000));
    }

    public static String formatDate(Date date) {
        return new SimpleDateFormat("yyyyMMddHHmmss").format(date);
    }

    /** scheme://host[:port]/contextPath, dùng để dựng URL tuyệt đối cho vnp_ReturnUrl. */
    public static String baseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        int port = request.getServerPort();
        boolean defaultPort = ("http".equals(scheme) && port == 80)
                || ("https".equals(scheme) && port == 443);
        return scheme + "://" + request.getServerName() + (defaultPort ? "" : ":" + port)
                + request.getContextPath();
    }

    public static String messageForResponseCode(String code) {
        if (code == null) {
            return "Giao dịch không thành công";
        }
        switch (code) {
            case RESP_SUCCESS:
                return "Giao dịch thành công";
            case RESP_CANCELLED:
                return "Khách hàng đã hủy giao dịch";
            case RESP_INSUFFICIENT:
                return "Tài khoản không đủ số dư để thanh toán";
            case RESP_TIMEOUT:
                return "Hết thời gian chờ thanh toán (Timeout)";
            case RESP_WRONG_AMOUNT:
                return "Số tiền giao dịch không khớp với đơn hàng";
            case RESP_INVALID_SIGNATURE:
                return "Chữ ký giao dịch không hợp lệ";
            default:
                return "Giao dịch không thành công (mã lỗi " + code + ")";
        }
    }
}
