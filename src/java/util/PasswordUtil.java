package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * High-security Password Utility using PBKDF2 with HMAC-SHA256 and a 16-byte cryptographic salt.
 * 
 * Stored format:
 *   PBKDF2$<iterations>$<hexSalt>$<hexHash>
 * 
 * Features:
 *   - Strong PBKDF2WithHmacSHA256 hashing (65,536 iterations, 16-byte salt, 256-bit key)
 *   - Constant-time comparison to prevent timing attacks
 *   - Backward compatibility verifying legacy SHA-256 hashes and plain-text test accounts
 *   - Automatic password upgrade mechanism (needsUpgrade) on successful user login
 */
public class PasswordUtil {

    private static final Logger LOGGER = Logger.getLogger(PasswordUtil.class.getName());

    public static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    public static final int ITERATIONS = 65536;
    public static final int SALT_BYTES = 16;       // 16 bytes = 128 bits
    public static final int KEY_LENGTH_BITS = 256; // 32 bytes = 256 bits

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    /**
     * Hashes a raw password string using PBKDF2WithHmacSHA256 with a 16-byte random salt.
     *
     * @param rawPassword The plain text password
     * @return Formatted string: PBKDF2$<iterations>$<saltHex>$<hashHex>
     */
    public static String hashPassword(String rawPassword) {
        if (rawPassword == null) {
            return null;
        }

        byte[] salt = new byte[SALT_BYTES];
        SECURE_RANDOM.nextBytes(salt);

        byte[] hash = pbkdf2(rawPassword.toCharArray(), salt, ITERATIONS, KEY_LENGTH_BITS);
        return "PBKDF2$" + ITERATIONS + "$" + bytesToHex(salt) + "$" + bytesToHex(hash);
    }

    /**
     * Verifies if a raw password matches the stored password.
     * Supports PBKDF2WithHmacSHA256, legacy SHA-256, and plain-text test passwords.
     *
     * @param rawPassword    The plain password entered by user
     * @param storedPassword The password stored in the database
     * @return true if credentials match, false otherwise
     */
    public static boolean verifyPassword(String rawPassword, String storedPassword) {
        if (rawPassword == null || storedPassword == null) {
            return false;
        }

        // 1. Verify PBKDF2 hash (PBKDF2$<iterations>$<saltHex>$<hashHex> or <iterations>:<saltHex>:<hashHex>)
        if (isPbkdf2Hash(storedPassword)) {
            return verifyPbkdf2(rawPassword, storedPassword);
        }

        // 2. Backward compatibility: verify legacy SHA-256 hash (64 hex characters)
        if (isSha256Hex(storedPassword)) {
            String sha256 = hashLegacySha256(rawPassword);
            if (MessageDigest.isEqual(sha256.toLowerCase().getBytes(StandardCharsets.UTF_8),
                    storedPassword.toLowerCase().getBytes(StandardCharsets.UTF_8))) {
                return true;
            }
        }

        // 3. Backward compatibility: direct plain-text match (for development / seed data)
        return rawPassword.equals(storedPassword);
    }

    /**
     * Checks if a stored password should be upgraded to the current PBKDF2 standard.
     * Returns true if the stored password is plain text, legacy SHA-256, or uses
     * outdated PBKDF2 iteration parameters.
     *
     * @param storedPassword Password string currently stored in DB
     * @return true if password needs to be re-hashed and updated in DB
     */
    public static boolean needsUpgrade(String storedPassword) {
        if (storedPassword == null || storedPassword.trim().isEmpty()) {
            return false;
        }

        // If not in PBKDF2 format, it's legacy (plain text or SHA-256) -> needs upgrade
        if (!isPbkdf2Hash(storedPassword)) {
            return true;
        }

        // If PBKDF2 format, verify iteration count is at least current target
        try {
            String clean = storedPassword.trim();
            if (clean.startsWith("PBKDF2$")) {
                String[] parts = clean.split("\\$");
                if (parts.length == 4) {
                    int iterations = Integer.parseInt(parts[1]);
                    return iterations < ITERATIONS;
                }
            } else if (clean.contains(":")) {
                String[] parts = clean.split(":");
                if (parts.length == 3) {
                    int iterations = Integer.parseInt(parts[0]);
                    return iterations < ITERATIONS;
                }
            }
        } catch (Exception ex) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether the stored password matches PBKDF2 format.
     */
    public static boolean isPbkdf2Hash(String storedPassword) {
        if (storedPassword == null) {
            return false;
        }
        String clean = storedPassword.trim();
        if (clean.startsWith("PBKDF2$") && clean.split("\\$").length == 4) {
            return true;
        }
        if (clean.contains(":")) {
            String[] parts = clean.split(":");
            return parts.length == 3 && parts[1].length() == SALT_BYTES * 2;
        }
        return false;
    }

    /**
     * Verifies PBKDF2 hash using constant-time comparison.
     */
    private static boolean verifyPbkdf2(String rawPassword, String storedPassword) {
        try {
            int iterations;
            byte[] salt;
            byte[] expectedHash;

            String clean = storedPassword.trim();
            if (clean.startsWith("PBKDF2$")) {
                String[] parts = clean.split("\\$");
                iterations = Integer.parseInt(parts[1]);
                salt = hexToBytes(parts[2]);
                expectedHash = hexToBytes(parts[3]);
            } else {
                String[] parts = clean.split(":");
                iterations = Integer.parseInt(parts[0]);
                salt = hexToBytes(parts[1]);
                expectedHash = hexToBytes(parts[2]);
            }

            int keyLengthBits = expectedHash.length * 8;
            byte[] computedHash = pbkdf2(rawPassword.toCharArray(), salt, iterations, keyLengthBits);

            return MessageDigest.isEqual(computedHash, expectedHash);
        } catch (Exception ex) {
            LOGGER.log(Level.WARNING, "Error verifying PBKDF2 password hash", ex);
            return false;
        }
    }

    /**
     * Compute PBKDF2 key derivation.
     */
    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLengthBits) {
        try {
            KeySpec spec = new PBEKeySpec(password, salt, iterations, keyLengthBits);
            SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGORITHM);
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("PBKDF2 key derivation failed with algorithm " + ALGORITHM, e);
        }
    }

    /**
     * Computes legacy SHA-256 for backward compatibility.
     */
    public static String hashLegacySha256(String rawPassword) {
        if (rawPassword == null) {
            return null;
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }

    /**
     * Check if string matches 64 hex characters (SHA-256 hash).
     */
    private static boolean isSha256Hex(String s) {
        if (s == null || s.length() != 64) {
            return false;
        }
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            boolean isHex = (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
            if (!isHex) {
                return false;
            }
        }
        return true;
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    private static byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                    + Character.digit(hex.charAt(i + 1), 16));
        }
        return data;
    }
}
