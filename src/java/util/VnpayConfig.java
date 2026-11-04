package util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class VnpayConfig {

    private static final Properties PROPERTIES = loadProperties();

    private VnpayConfig() {
    }
    public static boolean isConfigured() {
        String tmn = value("VNPAY_TMN_CODE", "vnpay.tmn_code", null);
        String secret = value("VNPAY_HASH_SECRET", "vnpay.hash_secret", null);
        return tmn != null && !tmn.isBlank() && !tmn.contains("YOUR_")
                && secret != null && !secret.isBlank() && !secret.contains("YOUR_");
    }


    public static String getTmnCode() {
        return required("VNPAY_TMN_CODE", "vnpay.tmn_code");
    }

    public static String getHashSecret() {
        return required("VNPAY_HASH_SECRET", "vnpay.hash_secret");
    }

    public static String getPaymentUrl() {
        return value("VNPAY_PAYMENT_URL", "vnpay.payment_url",
                "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html");
    }

    public static String getReturnUrl() {
        return value("VNPAY_RETURN_URL", "vnpay.return_url", "");
    }

    public static String getVersion() {
        return value("VNPAY_VERSION", "vnpay.version", "2.1.0");
    }

    public static String getCommand() {
        return value("VNPAY_COMMAND", "vnpay.command", "pay");
    }

    public static String getLocale() {
        return value("VNPAY_LOCALE", "vnpay.locale", "vn");
    }

    public static int getOrderTimeoutMinutes() {
        try {
            return Integer.parseInt(value("VNPAY_ORDER_TIMEOUT_MINUTES",
                    "vnpay.order_timeout_minutes", "15"));
        } catch (NumberFormatException ex) {
            return 15;
        }
    }

    private static Properties loadProperties() {
        Properties properties = new Properties();
        try (InputStream input = VnpayConfig.class.getClassLoader()
                .getResourceAsStream("vnpay.properties")) {
            if (input != null) {
                properties.load(input);
            }
        } catch (IOException ignored) {
        }
        return properties;
    }

    private static String required(String environmentName, String propertyName) {
        String configured = value(environmentName, propertyName, null);
        if (configured == null || configured.isBlank() || configured.contains("YOUR_")) {
            throw new IllegalStateException("Thiếu cấu hình " + propertyName
                    + ". Vui lòng thiết lập trong file vnpay.properties hoặc biến môi trường.");
        }
        return configured;
    }

    private static String value(String environmentName, String propertyName, String defaultValue) {
        String environmentValue = System.getenv(environmentName);
        if (environmentValue != null && !environmentValue.isBlank()) {
            return environmentValue.trim();
        }
        String propertyValue = PROPERTIES.getProperty(propertyName);
        return propertyValue != null && !propertyValue.isBlank()
                ? propertyValue.trim() : defaultValue;
    }
}
