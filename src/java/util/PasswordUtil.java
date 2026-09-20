package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility for hashing and verifying passwords using SHA-256.
 */
public class PasswordUtil {

    /**
     * Hashes a raw password string using SHA-256.
     *
     * @param rawPassword The plain text password
     * @return 64-character hexadecimal SHA-256 string
     */
    public static String hashPassword(String rawPassword) {
        if (rawPassword == null) {
            return null;
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available in current environment", e);
        }
    }

    /**
     * Verifies if a raw password matches the stored password.
     * Supports both SHA-256 hashed passwords and plain text passwords (useful for sample/test data).
     *
     * @param rawPassword    The plain password entered by user
     * @param storedPassword The password stored in the database
     * @return true if matches, false otherwise
     */
    public static boolean verifyPassword(String rawPassword, String storedPassword) {
        if (rawPassword == null || storedPassword == null) {
            return false;
        }
        
        // 1. Direct plain-text match (for testing accounts)
        if (rawPassword.equals(storedPassword)) {
            return true;
        }

        // 2. SHA-256 hash match
        String hashed = hashPassword(rawPassword);
        return hashed.equalsIgnoreCase(storedPassword);
    }
}

