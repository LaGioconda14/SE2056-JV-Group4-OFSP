package util;

import java.io.UnsupportedEncodingException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtil {

    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    private static final Properties CONFIG = loadConfiguration();
    private static final String SMTP_HOST = getConfig("mail.smtp.host", "SMTP_HOST", "smtp.gmail.com");
    private static final String SMTP_PORT = getConfig("mail.smtp.port", "SMTP_PORT", "587");
    private static final String SMTP_USERNAME = getConfig("mail.smtp.username", "SMTP_USERNAME", "");
    private static final String SMTP_PASSWORD = getConfig("mail.smtp.password", "SMTP_PASSWORD", "");
    private static final String SENDER_EMAIL = getConfig("mail.from.email", "SMTP_FROM_EMAIL", SMTP_USERNAME);
    private static final String SENDER_NAME = getConfig("mail.from.name", "SMTP_FROM_NAME", "Gốc Vườn");

    private static final SecureRandom RANDOM = new SecureRandom();

    public static String generateOTP() {
        int otp = 100000 + RANDOM.nextInt(900000);
        return String.valueOf(otp);
    }

    public static boolean isConfigured() {
        return !SMTP_USERNAME.isBlank() && !SMTP_PASSWORD.isBlank() && !SENDER_EMAIL.isBlank();
    }

    public static boolean sendOtpEmail(String recipientEmail, String recipientName, String otp) {
        if (!isConfigured()) {
            LOGGER.severe("SMTP is not configured. Set SMTP_USERNAME and SMTP_PASSWORD or create mail.properties.");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", SMTP_HOST);
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, SENDER_NAME, "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Mã xác thực đặt lại mật khẩu - Online Fruit Shop", "UTF-8");

            String displayName = (recipientName != null && !recipientName.trim().isEmpty()) ? recipientName : "Quý khách";
            String htmlContent = "<!DOCTYPE html>"
                    + "<html>"
                    + "<head><meta charset='UTF-8'></head>"
                    + "<body style='font-family: Arial, sans-serif; background-color: #f4fbf6; margin: 0; padding: 20px;'>"
                    + "  <div style='max-width: 550px; margin: 0 auto; background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.08); border-top: 6px solid #28a745;'>"
                    + "    <div style='padding: 30px 25px; text-align: center; background-color: #eafaf1;'>"
                    + "      <h1 style='color: #218838; margin: 0; font-size: 24px;'>Online Fruit Shop 🍎🍊🍇</h1>"
                    + "      <p style='color: #495057; font-size: 14px; margin-top: 5px;'>Trái cây tươi ngon mỗi ngày</p>"
                    + "    </div>"
                    + "    <div style='padding: 30px 25px;'>"
                    + "      <p style='font-size: 16px; color: #333333;'>Xin chào <strong>" + displayName + "</strong>,</p>"
                    + "      <p style='font-size: 15px; color: #555555; line-height: 1.6;'>"
                    + "        Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn tại <strong>Online Fruit Shop</strong>."
                    + "      </p>"
                    + "      <div style='text-align: center; margin: 30px 0;'>"
                    + "        <span style='display: inline-block; font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #28a745; background-color: #eafaf1; padding: 12px 30px; border-radius: 8px; border: 2px dashed #28a745;'>"
                    +            otp
                    + "        </span>"
                    + "      </div>"
                    + "      <p style='font-size: 14px; color: #dc3545; text-align: center; margin-bottom: 25px;'>"
                    + "        ⚠️ Mã xác thực có hiệu lực trong vòng <strong>5 phút</strong>. Vui lòng không chia sẻ mã này cho bất kỳ ai!"
                    + "      </p>"
                    + "      <p style='font-size: 14px; color: #777777; line-height: 1.5;'>"
                    + "        Nếu bạn không yêu cầu hành động này, vui lòng bỏ qua email hoặc liên hệ với bộ phận CSKH của chúng tôi để được hỗ trợ bảo mật tài khoản."
                    + "      </p>"
                    + "    </div>"
                    + "    <div style='background-color: #f8f9fa; padding: 15px; text-align: center; font-size: 12px; color: #888888; border-top: 1px solid #eeeeee;'>"
                    + "      &copy; 2026 Online Fruit Shop. All rights reserved."
                    + "    </div>"
                    + "  </div>"
                    + "</body>"
                    + "</html>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            LOGGER.info("OTP email successfully sent to: " + recipientEmail);
            return true;
        } catch (UnsupportedEncodingException | MessagingException ex) {
            LOGGER.log(Level.SEVERE, "Failed to send OTP email to " + recipientEmail + ": " + ex.getMessage(), ex);
            return false;
        }
    }

    public static void sendNotificationEmailAsync(String recipientEmail, String subject, String htmlContent) {
        if (recipientEmail == null || recipientEmail.isBlank()) {
            return;
        }
        new Thread(() -> {
            try {
                if (!isConfigured()) {
                    LOGGER.warning("Notification email skipped because SMTP is not configured.");
                    return;
                }
                Properties props = new Properties();
                props.put("mail.smtp.host", SMTP_HOST);
                props.put("mail.smtp.port", SMTP_PORT);
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");
                props.put("mail.smtp.ssl.protocols", "TLSv1.2");
                props.put("mail.smtp.ssl.trust", SMTP_HOST);
                props.put("mail.smtp.connectiontimeout", "10000");
                props.put("mail.smtp.timeout", "10000");

                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
                    }
                });

                MimeMessage message = new MimeMessage(session);
                message.setFrom(new InternetAddress(SENDER_EMAIL, SENDER_NAME, "UTF-8"));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
                message.setSubject(subject, "UTF-8");
                message.setContent(htmlContent, "text/html; charset=UTF-8");
                Transport.send(message);
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING, "Failed to send notification email to " + recipientEmail, ex);
            }
        }).start();
    }

    private static Properties loadConfiguration() {
        Properties properties = new Properties();
        try (InputStream input = EmailUtil.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (input != null) {
                properties.load(new InputStreamReader(input, StandardCharsets.UTF_8));
                LOGGER.info("Successfully loaded SMTP configuration from mail.properties");
            }
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Could not load mail.properties", ex);
        }
        return properties;
    }

    private static String getConfig(String propertyName, String environmentName, String defaultValue) {
        String environmentValue = System.getenv(environmentName);
        if (environmentValue != null && !environmentValue.isBlank()) {
            return environmentValue.trim();
        }
        String propertyValue = CONFIG.getProperty(propertyName);
        return propertyValue == null || propertyValue.isBlank() ? defaultValue : propertyValue.trim();
    }
}
