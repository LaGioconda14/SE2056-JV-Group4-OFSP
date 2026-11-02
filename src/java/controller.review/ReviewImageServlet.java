package controller.review;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

/**
 * FE-10 photos: storage file on disk; up to 3 filenames in
 * dbo.reviews.image_urls JSON.
 */
@WebServlet(name = "ReviewImageServlet", urlPatterns = {"/reviews/images"})
@MultipartConfig(maxFileSize = 3 * 1024 * 1024, maxRequestSize = 4 * 1024 * 1024)
public class ReviewImageServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(ReviewImageServlet.class.getName());
    private static final int MAX_BYTES = 3 * 1024 * 1024;
    private final ReviewDAO dao = new ReviewDAO();

    private Path imageDirectory() throws IOException {
        // Files survive redeploy. For other machines/servers, configure same persistent storage.
        // Optional JVM parameter: -Dofsp.review.uploadDir=D:/OFSP/review-images
        String dirValue = System.getProperty("ofsp.review.uploadDir");
        if (dirValue == null || dirValue.trim().isEmpty()) {
            dirValue = Paths.get(System.getProperty("user.home"), "ofsp-review-images").toString();
        }
        Path dir = Paths.get(dirValue).toAbsolutePath().normalize();
        Files.createDirectories(dir);
        return dir;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Path saved = null;
        try {
            User user = ReviewHttp.authorized(req, "CUSTOMER");
            ReviewHttp.requireCsrf(req);
            long reviewId = ReviewHttp.positive(req, "reviewId");
            Part part = req.getPart("image");
            if (part == null || part.getSize() < 1 || part.getSize() > MAX_BYTES) {
                throw new IllegalArgumentException("Each JPG/PNG image must be 1 byte to 3 MB");
            }

            byte[] header = new byte[8];
            int read = 0;
            try (InputStream in = part.getInputStream()) {
                while (read < header.length) {
                    int next = in.read(header, read, header.length - read);
                    if (next < 0) {
                        break;
                    }
                    read += next;
                }
            }
            boolean png = read == 8 && (header[0] & 255) == 137 && header[1] == 80
                    && header[2] == 78 && header[3] == 71 && header[4] == 13
                    && header[5] == 10 && header[6] == 26 && header[7] == 10;
            boolean jpeg = read >= 3 && (header[0] & 255) == 255
                    && (header[1] & 255) == 216 && (header[2] & 255) == 255;
            if (!png && !jpeg) {
                throw new IllegalArgumentException("Only JPG and PNG images are accepted");
            }
            String filename = UUID.randomUUID().toString() + (png ? ".png" : ".jpg");
            saved = imageDirectory().resolve(filename);
            try (InputStream in = part.getInputStream()) {
                Files.copy(in, saved, StandardCopyOption.REPLACE_EXISTING);
            }

            // DAO performs permission check and concurrency-safe max-3 check.
            int index = dao.appendProductImage(reviewId, user.getId(), filename);
            ReviewHttp.send(resp, 201, ReviewHttp.result(
                    "index", index,
                    "imageUrl", req.getContextPath() + "/reviews/images?reviewId=" + reviewId + "&index=" + index));
        } catch (Exception ex) {
            if (saved != null) {
                try {
                    Files.deleteIfExists(saved);
                } catch (IOException ignored) {
                }
            }
            LOG.log(Level.WARNING, "FE-10 image upload failed", ex);
            ReviewHttp.error(resp, ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            long reviewId = ReviewHttp.positive(req, "reviewId");
            User viewer = null;
            try {
                viewer = ReviewHttp.user(req);
            } catch (SecurityException ignored) {
            }
            long viewerId = viewer == null ? 0 : viewer.getId();
            boolean isAdmin = viewer != null && ReviewHttp.role(viewer, "ADMIN");
            List<String> filenames = dao.getProductImages(reviewId, viewerId, isAdmin);
            if (filenames == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            String indexParam = req.getParameter("index");
            if (indexParam == null) {
                List<String> urls = new ArrayList<>();
                List<Integer> indexes = new ArrayList<>(); // compatibility for previous FE-10 edit guard
                for (int i = 0; i < filenames.size(); i++) {
                    urls.add(req.getContextPath() + "/reviews/images?reviewId=" + reviewId + "&index=" + i);
                    indexes.add(i);
                }
                ReviewHttp.send(resp, 200, ReviewHttp.result("imageUrls", urls, "imageIds", indexes));
                return;
            }
            int index;
            try {
                index = Integer.parseInt(indexParam);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Invalid image index");
            }
            if (index < 0 || index >= filenames.size()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            String filename = filenames.get(index);
            if (filename == null || !filename.matches("[0-9a-fA-F-]{36}\\.(jpg|png)")) {
                throw new IOException("Invalid stored review image name");
            }
            Path directory = imageDirectory();
            Path imagePath = directory.resolve(filename).normalize();
            if (!imagePath.startsWith(directory) || !Files.isRegularFile(imagePath)) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            resp.setContentType(filename.endsWith(".png") ? "image/png" : "image/jpeg");
            resp.setHeader("X-Content-Type-Options", "nosniff");
            resp.setHeader("Cache-Control", "private, max-age=60");
            try (java.io.OutputStream out = resp.getOutputStream()) {
                Files.copy(imagePath, out);
            }
        } catch (Exception ex) {
            LOG.log(Level.WARNING, "FE-10 image GET failed", ex);
            ReviewHttp.error(resp, ex);
        }
    }
}
