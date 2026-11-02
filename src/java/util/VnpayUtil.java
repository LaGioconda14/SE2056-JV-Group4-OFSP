package util;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public final class VnpayUtil {

    private VnpayUtil() {
    }

    public static String buildPaymentUrl(Map<String, String> parameters) {
        String query = buildSignedData(parameters);
        return VnpayConfig.getPaymentUrl() + "?" + query + "&vnp_SecureHash="
                + hmacSha512(VnpayConfig.getHashSecret(), query);
    }

    public static boolean isValidSignature(Map<String, String[]> parameterMap) {
        String receivedHash = first(parameterMap.get("vnp_SecureHash"));
        if (receivedHash == null || receivedHash.isBlank()) {
            return false;
        }

        Map<String, String> fields = new java.util.HashMap<>();
        for (Map.Entry<String, String[]> entry : parameterMap.entrySet()) {
            if (entry.getKey().startsWith("vnp_")
                    && !"vnp_SecureHash".equals(entry.getKey())
                    && !"vnp_SecureHashType".equals(entry.getKey())) {
                fields.put(entry.getKey(), first(entry.getValue()));
            }
        }
        String calculatedHash = hmacSha512(VnpayConfig.getHashSecret(), buildSignedData(fields));
        return MessageDigest.isEqual(calculatedHash.toLowerCase(java.util.Locale.ROOT)
                        .getBytes(StandardCharsets.US_ASCII),
                receivedHash.toLowerCase(java.util.Locale.ROOT).getBytes(StandardCharsets.US_ASCII));
    }

    public static String buildSignedData(Map<String, String> parameters) {
        List<String> keys = new ArrayList<>(parameters.keySet());
        Collections.sort(keys);
        StringBuilder result = new StringBuilder();
        for (String key : keys) {
            String value = parameters.get(key);
            if (value == null || value.isBlank()) {
                continue;
            }
            if (result.length() > 0) {
                result.append('&');
            }
            result.append(urlEncode(key)).append('=').append(urlEncode(value));
        }
        return result.toString();
    }

    public static String getClientIp(jakarta.servlet.http.HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        String ip = forwardedFor != null && !forwardedFor.isBlank()
                ? forwardedFor.split(",")[0].trim() : request.getRemoteAddr();
        return ip != null && ip.length() <= 45 ? ip : "127.0.0.1";
    }

    private static String hmacSha512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] digest = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder result = new StringBuilder(digest.length * 2);
            for (byte value : digest) {
                result.append(String.format("%02x", value & 0xff));
            }
            return result.toString();
        } catch (NoSuchAlgorithmException | InvalidKeyException ex) {
            throw new IllegalStateException("Không thể tạo chữ ký VNPAY", ex);
        }
    }

    private static String urlEncode(String value) {
        // VNPAY's Java reference implementation signs application/x-www-form-urlencoded
        // values, where a space is represented by '+', not "%20".
        return java.net.URLEncoder.encode(value, StandardCharsets.US_ASCII);
    }

    private static String first(String[] values) {
        return values != null && values.length > 0 ? values[0] : null;
    }
}
