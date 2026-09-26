package util;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.GoogleAccount;

/**
 * Utility helper for Google OAuth 2.0 authentication flow.
 */
public class GoogleOAuthUtil {

    private static final Logger LOGGER = Logger.getLogger(GoogleOAuthUtil.class.getName());

    // NOTE: Ban co the thay the Client ID va Client Secret duoc tao tu Google Cloud Console vao day
    // Hoac dat bien moi truong he thong: GOOGLE_CLIENT_ID va GOOGLE_CLIENT_SECRET
    public static final String DEFAULT_CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com";
    public static final String DEFAULT_CLIENT_SECRET = "YOUR_GOOGLE_CLIENT_SECRET";

    public static final String GOOGLE_REDIRECT_URI = "http://localhost:8080/SE2056-JV-Group4-OFSP/login-google";
    public static final String GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/auth";
    public static final String GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
    public static final String GOOGLE_USER_INFO_URL = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=";

    private static final Gson gson = new Gson();

    public static String getClientId() {
        String envId = System.getenv("GOOGLE_CLIENT_ID");
        if (envId != null && !envId.trim().isEmpty()) {
            return envId.trim();
        }
        return DEFAULT_CLIENT_ID;
    }

    public static String getClientSecret() {
        String envSecret = System.getenv("GOOGLE_CLIENT_SECRET");
        if (envSecret != null && !envSecret.trim().isEmpty()) {
            return envSecret.trim();
        }
        return DEFAULT_CLIENT_SECRET;
    }

    public static boolean isConfigured() {
        String id = getClientId();
        String secret = getClientSecret();
        return id != null && !id.contains("YOUR_GOOGLE_CLIENT_ID")
                && secret != null && !secret.contains("YOUR_GOOGLE_CLIENT_SECRET");
    }

    /**
     * Generate Google OAuth authorization URL to redirect user for consent.
     */
    public static String getGoogleLoginUrl() {
        return GOOGLE_AUTH_URL
                + "?scope=email%20profile"
                + "&redirect_uri=" + URLEncoder.encode(GOOGLE_REDIRECT_URI, StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&client_id=" + URLEncoder.encode(getClientId(), StandardCharsets.UTF_8)
                + "&approval_prompt=force";
    }

    /**
     * Exchange authorization code for Google access token.
     *
     * @param code Authorization code returned from Google
     * @return access_token string
     * @throws IOException on network or HTTP error
     */
    public static String getToken(String code) throws IOException {
        String params = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                + "&client_id=" + URLEncoder.encode(getClientId(), StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(getClientSecret(), StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(GOOGLE_REDIRECT_URI, StandardCharsets.UTF_8)
                + "&grant_type=authorization_code";

        URL url = URI.create(GOOGLE_TOKEN_URL).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setRequestProperty("Accept", "application/json");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8));
            os.flush();
        }

        int status = conn.getResponseCode();
        BufferedReader reader;
        if (status >= 200 && status < 300) {
            reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
        } else {
            reader = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
        }

        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();

        if (status != 200) {
            LOGGER.severe("Error getting Google token. HTTP " + status + ": " + response.toString());
            throw new IOException("Failed to obtain token from Google: " + response.toString());
        }

        JsonObject jsonObject = gson.fromJson(response.toString(), JsonObject.class);
        if (jsonObject.has("access_token")) {
            return jsonObject.get("access_token").getAsString();
        } else {
            throw new IOException("No access_token found in Google response: " + response.toString());
        }
    }

    /**
     * Fetch user profile info using access token.
     *
     * @param accessToken Google access token
     * @return GoogleAccount model
     * @throws IOException on network or HTTP error
     */
    public static GoogleAccount getUserInfo(String accessToken) throws IOException {
        URL url = URI.create(GOOGLE_USER_INFO_URL + accessToken).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Accept", "application/json");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);

        int status = conn.getResponseCode();
        BufferedReader reader;
        if (status >= 200 && status < 300) {
            reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
        } else {
            reader = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
        }

        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();

        if (status != 200) {
            LOGGER.severe("Error getting Google user info. HTTP " + status + ": " + response.toString());
            throw new IOException("Failed to get user info from Google: " + response.toString());
        }

        return gson.fromJson(response.toString(), GoogleAccount.class);
    }
}
