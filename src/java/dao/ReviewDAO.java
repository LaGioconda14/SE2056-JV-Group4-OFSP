package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Review;
import model.ReviewReport;
import model.ReviewSummary;
import util.DBContext;

/**
 * SQL Server implementation of FE-10. This DAO uses the team's EXISTING
 * orders/sub_orders/order_items tables. It does not require Order History UI.
 */
public class ReviewDAO extends DBContext {

    private Connection connection() throws SQLException {
        Connection c = getConnection();
        if (c == null) {
            throw new SQLException("Cannot connect to the OFSP database");
        }
        return c;
    }

    private static boolean productType(String type) {
        return "PRODUCT".equals(type);
    }

    private static String table(String type) {
        if (productType(type)) {
            return "dbo.reviews";
        }
        if ("SHOP".equals(type)) {
            return "dbo.shop_reviews";
        }
        throw new IllegalArgumentException("Invalid review type");
    }

    private static String idColumn(String type) {
        return productType(type) ? "review_id" : "shop_review_id";
    }

    /**
     * Eligibility comes entirely from existing purchase records, not from a
     * client flag.
     */
    public boolean canReviewProduct(long customerId, long orderItemId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.order_items oi "
                + "JOIN dbo.sub_orders so ON so.sub_order_id=oi.sub_order_id "
                + "JOIN dbo.orders o ON o.order_id=so.order_id "
                + "JOIN dbo.product_variants pv ON pv.variant_id=oi.variant_id "
                + "WHERE oi.order_item_id=? AND o.customer_id=? "
                + "AND so.status='DELIVERED' "
                + "AND NOT EXISTS (SELECT 1 FROM dbo.reviews r "
                + "WHERE r.order_item_id=oi.order_item_id AND r.customer_id=? AND r.status <> 'DELETED')";
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderItemId);
            ps.setLong(2, customerId);
            ps.setLong(3, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean canReviewShop(long customerId, long subOrderId) throws SQLException {
        String sql = "SELECT 1 FROM dbo.sub_orders so "
                + "JOIN dbo.orders o ON o.order_id=so.order_id "
                + "WHERE so.sub_order_id=? AND o.customer_id=? "
                + "AND so.status='DELIVERED' "
                + "AND NOT EXISTS (SELECT 1 FROM dbo.shop_reviews sr "
                + "WHERE sr.sub_order_id=so.sub_order_id AND sr.customer_id=? AND sr.status <> 'DELETED')";
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, subOrderId);
            ps.setLong(2, customerId);
            ps.setLong(3, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long createProductReview(long customerId, long orderItemId, int rating, String comment) throws SQLException {
        // The INSERT itself checks eligibility and duplicate reviews; both are DB-side.
        String sql = "INSERT INTO dbo.reviews (order_item_id,customer_id,shop_id,rating,comment,status) "
                + "OUTPUT INSERTED.review_id "
                + "SELECT oi.order_item_id,o.customer_id,so.shop_id,?,?,'APPROVED' "
                + "FROM dbo.order_items oi "
                + "JOIN dbo.sub_orders so ON so.sub_order_id=oi.sub_order_id "
                + "JOIN dbo.orders o ON o.order_id=so.order_id "
                + "JOIN dbo.product_variants pv ON pv.variant_id=oi.variant_id "
                + "WHERE oi.order_item_id=? AND o.customer_id=? "
                + "AND so.status='DELIVERED' "
                + "AND NOT EXISTS (SELECT 1 FROM dbo.reviews r WITH(UPDLOCK,HOLDLOCK) "
                + "WHERE r.order_item_id=oi.order_item_id AND r.customer_id=? AND r.status <> 'DELETED')";
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, rating);
            ps.setString(2, comment);
            ps.setLong(3, orderItemId);
            ps.setLong(4, customerId);
            ps.setLong(5, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("Purchased and delivered item required, or review already exists");
                }
                return rs.getLong(1);
            }
        }
    }

    public long createShopReview(long customerId, long subOrderId, int rating, String comment) throws SQLException {
        String sql = "INSERT INTO dbo.shop_reviews (sub_order_id,customer_id,shop_id,rating,comment,status) "
                + "OUTPUT INSERTED.shop_review_id "
                + "SELECT so.sub_order_id,o.customer_id,so.shop_id,?,?,'APPROVED' "
                + "FROM dbo.sub_orders so JOIN dbo.orders o ON o.order_id=so.order_id "
                + "WHERE so.sub_order_id=? AND o.customer_id=? "
                + "AND so.status='DELIVERED' "
                + "AND NOT EXISTS (SELECT 1 FROM dbo.shop_reviews sr WITH(UPDLOCK,HOLDLOCK) "
                + "WHERE sr.sub_order_id=so.sub_order_id AND sr.customer_id=? AND sr.status <> 'DELETED')";
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                long id;
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, rating);
                    ps.setString(2, comment);
                    ps.setLong(3, subOrderId);
                    ps.setLong(4, customerId);
                    ps.setLong(5, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Delivered shop purchase required, or review already exists");
                        }
                        id = rs.getLong(1);
                    }
                }
                updateShopRating(c, shopIdForReview(c, id));
                c.commit();
                return id;
            } catch (SQLException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }

    public boolean updateReview(String type, long customerId, long reviewId, int rating, String comment) throws SQLException {
        String sql = "UPDATE " + table(type) + " SET rating=?,comment=?,updated_at=SYSUTCDATETIME() "
                + "WHERE " + idColumn(type) + "=? AND customer_id=? AND status NOT IN ('DELETED','REMOVED')";
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                Long shopId = productType(type) ? null : shopIdForReview(c, reviewId);
                int count;
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, rating);
                    ps.setString(2, comment);
                    ps.setLong(3, reviewId);
                    ps.setLong(4, customerId);
                    count = ps.executeUpdate();
                }
                if (count > 0 && shopId != null) {
                    updateShopRating(c, shopId);
                }
                c.commit();
                return count > 0;
            } catch (SQLException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }

    /**
     * Soft-delete preserves moderation/audit history and hides a review from
     * public lists.
     */
    public boolean deleteReview(String type, long customerId, long reviewId) throws SQLException {
        String sql = "UPDATE " + table(type) + " SET status='DELETED',updated_at=SYSUTCDATETIME() "
                + "WHERE " + idColumn(type) + "=? AND customer_id=? AND status NOT IN ('DELETED','REMOVED')";
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                Long shopId = productType(type) ? null : shopIdForReview(c, reviewId);
                int count;
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setLong(1, reviewId);
                    ps.setLong(2, customerId);
                    count = ps.executeUpdate();
                }
                if (count > 0 && shopId != null) {
                    updateShopRating(c, shopId);
                }
                c.commit();
                return count > 0;
            } catch (SQLException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }

    private Long shopIdForReview(Connection c, long shopReviewId) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("SELECT shop_id FROM dbo.shop_reviews WHERE shop_review_id=?")) {
            ps.setLong(1, shopReviewId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : null;
            }
        }
    }

    private void updateShopRating(Connection c, Long shopId) throws SQLException {
        if (shopId == null) {
            return;
        }
        String sql = "UPDATE dbo.shops SET rating=ISNULL((SELECT CAST(AVG(CAST(rating AS DECIMAL(5,2))) AS DECIMAL(3,2)) "
                + "FROM dbo.shop_reviews WHERE shop_id=? AND status='APPROVED'),5.00), "
                + "updated_at=SYSUTCDATETIME() WHERE shop_id=?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            ps.setLong(2, shopId);
            ps.executeUpdate();
        }
    }

    public List<Review> listPublic(String type, long targetId, int limit, int offset) throws SQLException {
        String sql;
        if (productType(type)) {
            sql = "SELECT r.review_id id,r.customer_id,r.shop_id,r.order_item_id, "
                    + "CAST(NULL AS BIGINT) sub_order_id,p.product_id,p.name product_name,s.shop_name, "
                    + "r.rating,r.comment,r.reply_comment,u.full_name customer_name, CAST((SELECT TOP 1 pi.image_url FROM dbo.product_images pi WHERE pi.product_id=p.product_id ORDER BY pi.is_thumbnail DESC,pi.display_order ASC) AS VARCHAR(500)) thumbnail_url, r.status,r.created_at,r.updated_at "
                    + "FROM dbo.reviews r JOIN dbo.order_items oi ON oi.order_item_id=r.order_item_id "
                    + "JOIN dbo.sub_orders so ON so.sub_order_id=oi.sub_order_id "
                    + "JOIN dbo.orders o ON o.order_id=so.order_id "
                    + "JOIN dbo.product_variants pv ON pv.variant_id=oi.variant_id "
                    + "JOIN dbo.products p ON p.product_id=pv.product_id "
                    + "JOIN dbo.shops s ON s.shop_id=r.shop_id JOIN dbo.users u ON u.user_id=r.customer_id "
                    + "WHERE p.product_id=? AND r.status='APPROVED' "
                    + "AND r.customer_id=o.customer_id AND r.shop_id=so.shop_id ";
        } else {
            table(type);
            sql = "SELECT sr.shop_review_id id,sr.customer_id,sr.shop_id,CAST(NULL AS BIGINT) order_item_id, "
                    + "sr.sub_order_id,CAST(NULL AS BIGINT) product_id,CAST(NULL AS NVARCHAR(200)) product_name, "
                    + "s.shop_name,sr.rating,sr.comment,sr.reply_comment,u.full_name customer_name, CAST(NULL AS VARCHAR(500)) thumbnail_url, sr.status,sr.created_at,sr.updated_at "
                    + "FROM dbo.shop_reviews sr JOIN dbo.shops s ON s.shop_id=sr.shop_id JOIN dbo.users u ON u.user_id=sr.customer_id "
                    + "WHERE sr.shop_id=? AND sr.status='APPROVED' ";
        }
        sql += productType(type)
                ? "ORDER BY r.created_at DESC,r.review_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
                : "ORDER BY sr.created_at DESC,sr.shop_review_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        List<Review> out = new ArrayList<>();
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, targetId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(mapReview(rs, type));
                }
            }
        }
        return out;
    }

    public ReviewSummary summary(String type, long targetId) throws SQLException {
        String sql;
        if (productType(type)) {
            sql = "SELECT r.rating,COUNT_BIG(*) n FROM dbo.reviews r "
                    + "JOIN dbo.order_items oi ON oi.order_item_id=r.order_item_id "
                    + "JOIN dbo.sub_orders so ON so.sub_order_id=oi.sub_order_id "
                    + "JOIN dbo.orders o ON o.order_id=so.order_id "
                    + "JOIN dbo.product_variants pv ON pv.variant_id=oi.variant_id "
                    + "WHERE pv.product_id=? AND r.status='APPROVED' "
                    + "AND r.customer_id=o.customer_id AND r.shop_id=so.shop_id GROUP BY r.rating";
        } else {
            table(type);
            sql = "SELECT rating,COUNT_BIG(*) n FROM dbo.shop_reviews "
                    + "WHERE shop_id=? AND status='APPROVED' GROUP BY rating";
        }
        ReviewSummary out = new ReviewSummary();
        long weighted = 0;
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, targetId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int stars = rs.getInt("rating");
                    long n = rs.getLong("n");
                    if (stars >= 1 && stars <= 5) {
                        out.distribution[stars] = n;
                        out.total += n;
                        weighted += stars * n;
                    }
                }
            }
        }
        if (out.total > 0) {
            out.average = Math.round((weighted * 100.0) / out.total) / 100.0;
        }
        return out;
    }

    /**
     * Customer history without relying on order-history.jsp.
     */
    public List<Review> listMine(String type, long customerId, int limit, int offset) throws SQLException {
        String sql;
        if (productType(type)) {
            sql = "SELECT r.review_id id,r.customer_id,r.shop_id,r.order_item_id, "
                    + "CAST(NULL AS BIGINT) sub_order_id,p.product_id,p.name product_name,s.shop_name, "
                    + "r.rating,r.comment,r.reply_comment,u.full_name customer_name, CAST((SELECT TOP 1 pi.image_url FROM dbo.product_images pi WHERE pi.product_id=p.product_id ORDER BY pi.is_thumbnail DESC,pi.display_order ASC) AS VARCHAR(500)) thumbnail_url, r.status,r.created_at,r.updated_at "
                    + "FROM dbo.reviews r JOIN dbo.order_items oi ON oi.order_item_id=r.order_item_id "
                    + "JOIN dbo.sub_orders so ON so.sub_order_id=oi.sub_order_id "
                    + "JOIN dbo.orders o ON o.order_id=so.order_id "
                    + "LEFT JOIN dbo.product_variants pv ON pv.variant_id=oi.variant_id "
                    + "LEFT JOIN dbo.products p ON p.product_id=pv.product_id "
                    + "JOIN dbo.shops s ON s.shop_id=r.shop_id JOIN dbo.users u ON u.user_id=r.customer_id WHERE r.customer_id=? AND r.status <> 'DELETED' "
                    + "AND r.customer_id=o.customer_id AND r.shop_id=so.shop_id ";
        } else {
            table(type);
            sql = "SELECT sr.shop_review_id id,sr.customer_id,sr.shop_id,CAST(NULL AS BIGINT) order_item_id, "
                    + "sr.sub_order_id,CAST(NULL AS BIGINT) product_id,CAST(NULL AS NVARCHAR(200)) product_name, "
                    + "s.shop_name,sr.rating,sr.comment,sr.reply_comment,u.full_name customer_name, CAST(NULL AS VARCHAR(500)) thumbnail_url, sr.status,sr.created_at,sr.updated_at "
                    + "FROM dbo.shop_reviews sr JOIN dbo.shops s ON s.shop_id=sr.shop_id JOIN dbo.users u ON u.user_id=sr.customer_id "
                    + "WHERE sr.customer_id=? AND sr.status <> 'DELETED' ";
        }
        sql += productType(type)
                ? "ORDER BY r.created_at DESC,r.review_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
                : "ORDER BY sr.created_at DESC,sr.shop_review_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        List<Review> out = new ArrayList<>();
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(mapReview(rs, type));
                }
            }
        }
        return out;
    }

    private Review mapReview(ResultSet rs, String type) throws SQLException {
        Review review = new Review();
        review.setType(type);
        review.setReviewId(rs.getLong("id"));
        review.setCustomerId(rs.getLong("customer_id"));
        review.setShopId(rs.getLong("shop_id"));
        review.setOrderItemId(nullableLong(rs, "order_item_id"));
        review.setSubOrderId(nullableLong(rs, "sub_order_id"));
        review.setProductId(nullableLong(rs, "product_id"));
        review.setProductName(rs.getString("product_name"));
        review.setShopName(rs.getString("shop_name"));
        review.setRating(rs.getInt("rating"));
        review.setComment(rs.getString("comment"));
        review.setCustomerName(rs.getString("customer_name"));
        review.setReplyComment(rs.getString("reply_comment"));
        review.setThumbnailUrl(rs.getString("thumbnail_url"));
        review.setStatus(rs.getString("status"));
        review.setCreatedAt(rs.getTimestamp("created_at"));
        review.setUpdatedAt(rs.getTimestamp("updated_at"));
        return review;
    }

    private Long nullableLong(ResultSet rs, String name) throws SQLException {
        long v = rs.getLong(name);
        return rs.wasNull() ? null : v;
    }

    public long reportReview(String type, long reviewId, long reporterId, String reason) throws SQLException {
        String sqlCheck = "SELECT 1 FROM " + table(type) + " WHERE " + idColumn(type) + "=? AND status='APPROVED'";
        String sqlInsert = "INSERT dbo.review_reports(review_type,review_id,reporter_id,reason) "
                + "OUTPUT INSERTED.report_id VALUES(?,?,?,?)";
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                try (PreparedStatement check = c.prepareStatement(sqlCheck)) {
                    check.setLong(1, reviewId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Review is not available for reporting");
                        }
                    }
                }
                long id;
                try (PreparedStatement ps = c.prepareStatement(sqlInsert)) {
                    ps.setString(1, type);
                    ps.setLong(2, reviewId);
                    ps.setLong(3, reporterId);
                    ps.setString(4, reason);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        id = rs.getLong(1);
                    }
                }
                c.commit();
                return id;
            } catch (SQLException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }

    public List<ReviewReport> listReports(int limit, int offset) throws SQLException {
        String sql = "SELECT rr.report_id, rr.review_type, rr.review_id, rr.reporter_id, "
                + "rr.reason, rr.status, rr.moderation_action, rr.reviewed_by, "
                + "rr.created_at, rr.reviewed_at, "
                + "r.comment AS review_comment, s.shop_name AS shop_name, "
                + "u.full_name AS reporter_name "
                + "FROM dbo.review_reports rr "
                + "JOIN dbo.users u ON u.user_id=rr.reporter_id "
                + "JOIN dbo.reviews r ON rr.review_type='PRODUCT' AND r.review_id=rr.review_id "
                + "JOIN dbo.shops s ON s.shop_id=r.shop_id "
                + "WHERE rr.status='PENDING' "
                + "ORDER BY rr.created_at, rr.report_id "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        List<ReviewReport> out = new ArrayList<>();
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReviewReport rr = new ReviewReport();
                    rr.reportId = rs.getLong("report_id");
                    rr.reviewType = rs.getString("review_type");
                    rr.reviewId = rs.getLong("review_id");
                    rr.reporterId = rs.getLong("reporter_id");
                    rr.reason = rs.getString("reason");
                    rr.status = rs.getString("status");
                    rr.reviewComment = rs.getString("review_comment");
                    rr.shopName = rs.getString("shop_name");
                    rr.reporterName = rs.getString("reporter_name");
                    rr.moderationAction = rs.getString("moderation_action");
                    rr.reviewedBy = nullableLong(rs, "reviewed_by");
                    rr.createdAt = rs.getTimestamp("created_at");
                    rr.reviewedAt = rs.getTimestamp("reviewed_at");
                    out.add(rr);
                }
            }
        }
        return out;

    }

    public boolean moderate(long reportId, long adminId, String action) throws SQLException {
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                String type;
                long reviewId;
                try (PreparedStatement ps = c.prepareStatement("SELECT review_type,review_id FROM dbo.review_reports "
                        + "WITH(UPDLOCK,HOLDLOCK) WHERE report_id=? AND status='PENDING'")) {
                    ps.setLong(1, reportId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            c.rollback();
                            return false;
                        }
                        type = rs.getString(1);
                        reviewId = rs.getLong(2);
                    }
                }
                if (!"REJECT".equals(action)) {
                    String newStatus = "APPROVE".equals(action) ? "APPROVED" : ("HIDE".equals(action) ? "HIDDEN" : "REMOVED");
                    String sql = "UPDATE " + table(type) + " SET status=?,updated_at=SYSUTCDATETIME() "
                            + "WHERE " + idColumn(type) + "=? AND status NOT IN('DELETED','REMOVED')";
                    try (PreparedStatement ps = c.prepareStatement(sql)) {
                        ps.setString(1, newStatus);
                        ps.setLong(2, reviewId);
                        if (ps.executeUpdate() != 1) {
                            throw new IllegalArgumentException("Review no longer exists");
                        }
                    }
                    if ("SHOP".equals(type)) {
                        updateShopRating(c, shopIdForReview(c, reviewId));
                    }
                }
                // Reject only this specific report; other reporters' pending claims remain open.
                // A review-level action resolves all pending reports for that same review.
                String change = "UPDATE dbo.review_reports SET status=?,moderation_action=?,reviewed_by=?,reviewed_at=SYSUTCDATETIME() "
                        + ("REJECT".equals(action) ? "WHERE report_id=? AND status='PENDING'"
                        : "WHERE review_type=? AND review_id=? AND status='PENDING'");
                try (PreparedStatement ps = c.prepareStatement(change)) {
                    ps.setString(1, "REJECT".equals(action) ? "REJECTED" : "RESOLVED");
                    ps.setString(2, action);
                    ps.setLong(3, adminId);
                    if ("REJECT".equals(action)) {
                        ps.setLong(4, reportId);
                    } else {
                        ps.setString(4, type);
                        ps.setLong(5, reviewId);
                    }
                    ps.executeUpdate();
                }
                c.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }

    // FE10_IMAGES_IN_REVIEWS_COLUMN: filenames are stored as JSON in reviews.image_urls.
    private static final com.google.gson.Gson IMAGE_JSON = new com.google.gson.Gson();

    private static List<String> parseImageNames(String json) {
        List<String> names = new ArrayList<>();
        if (json == null || json.trim().isEmpty()) return names;
        String[] loaded;
        try {
            loaded = IMAGE_JSON.fromJson(json, String[].class);
        } catch (com.google.gson.JsonSyntaxException ex) {
            throw new IllegalStateException("Invalid image_urls JSON in dbo.reviews", ex);
        }
        if (loaded == null) return names;
        for (String name : loaded) {
            if (name == null || !name.matches("[0-9a-fA-F-]{36}\\.(jpg|png)")) {
                throw new IllegalStateException("Invalid filename in dbo.reviews.image_urls");
            }
            names.add(name);
        }
        if (names.size() > 3) throw new IllegalStateException("Too many images in review image_urls");
        return names;
    }

    /** Returns the zero-based index of a saved image, or throws when not allowed. */
    public int appendProductImage(long reviewId, long customerId, String filename) throws SQLException {
        if (filename == null || !filename.matches("[0-9a-fA-F-]{36}\\.(jpg|png)")) {
            throw new IllegalArgumentException("Invalid image filename");
        }
        try (Connection c = connection()) {
            c.setAutoCommit(false);
            try {
                List<String> names;
                String sql = "SELECT image_urls FROM dbo.reviews WITH(UPDLOCK, HOLDLOCK) "
                        + "WHERE review_id=? AND customer_id=? AND status NOT IN('DELETED','REMOVED')";
                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setLong(1, reviewId);
                    ps.setLong(2, customerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new SecurityException("Review not found or you cannot upload images to it");
                        }
                        names = parseImageNames(rs.getString("image_urls"));
                    }
                }
                if (names.size() >= 3) {
                    throw new IllegalArgumentException("Review already has 3 images");
                }
                names.add(filename);
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE dbo.reviews SET image_urls=?,updated_at=SYSUTCDATETIME() "
                        + "WHERE review_id=? AND customer_id=?")) {
                    ps.setString(1, IMAGE_JSON.toJson(names));
                    ps.setLong(2, reviewId);
                    ps.setLong(3, customerId);
                    if (ps.executeUpdate() != 1) {
                        throw new IllegalArgumentException("Review no longer exists");
                    }
                }
                c.commit();
                return names.size() - 1;
            } catch (SQLException | RuntimeException ex) {
                c.rollback();
                throw ex;
            }
        }
    }

    /** Null means not visible to the viewer. Public APPROVED reviews are visible. */
    public List<String> getProductImages(long reviewId, long viewerId, boolean admin) throws SQLException {
        String sql = "SELECT image_urls,customer_id,status FROM dbo.reviews WHERE review_id=?";
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                String status = rs.getString("status");
                long authorId = rs.getLong("customer_id");
                if ("DELETED".equals(status) || "REMOVED".equals(status)) return null;
                if (!("APPROVED".equals(status) || admin || (viewerId > 0 && viewerId == authorId))) {
                    return null;
                }
                return parseImageNames(rs.getString("image_urls"));
            }
        }
    }

    public List<model.ReviewPurchase> listPurchases(String type, long customerId) throws SQLException {
        List<model.ReviewPurchase> out = new ArrayList<>();
        String sql;
        if ("PRODUCT".equals(type)) {
            sql = "SELECT TOP 80 oi.order_item_id purchase_ref,p.product_id target_id,so.shop_id,p.name product_name, "
                    + "s.shop_name,o.order_code, "
                    + "(SELECT TOP 1 pi.image_url FROM dbo.product_images pi WHERE pi.product_id=p.product_id ORDER BY pi.is_thumbnail DESC,pi.display_order ASC) thumbnail_url, "
                    + "(SELECT TOP 1 r.review_id FROM dbo.reviews r WHERE r.order_item_id=oi.order_item_id AND r.customer_id=? "
                    + "AND r.status <> 'DELETED' ORDER BY r.review_id DESC) existing_id "
                    + "FROM dbo.order_items oi JOIN dbo.sub_orders so ON so.sub_order_id=oi.sub_order_id "
                    + "JOIN dbo.orders o ON o.order_id=so.order_id "
                    + "JOIN dbo.product_variants pv ON pv.variant_id=oi.variant_id "
                    + "JOIN dbo.products p ON p.product_id=pv.product_id JOIN dbo.shops s ON s.shop_id=so.shop_id "
                    + "WHERE o.customer_id=? AND so.status='DELIVERED' ORDER BY oi.order_item_id DESC";
        } else if ("SHOP".equals(type)) {
            sql = "SELECT TOP 80 so.sub_order_id purchase_ref,so.shop_id target_id,so.shop_id, "
                    + "CAST(NULL AS NVARCHAR(200)) product_name,s.shop_name,o.order_code,s.logo_url thumbnail_url, "
                    + "(SELECT TOP 1 sr.shop_review_id FROM dbo.shop_reviews sr WHERE sr.sub_order_id=so.sub_order_id "
                    + "AND sr.customer_id=? AND sr.status <> 'DELETED' ORDER BY sr.shop_review_id DESC) existing_id "
                    + "FROM dbo.sub_orders so JOIN dbo.orders o ON o.order_id=so.order_id "
                    + "JOIN dbo.shops s ON s.shop_id=so.shop_id WHERE o.customer_id=? AND so.status='DELIVERED' "
                    + "ORDER BY so.sub_order_id DESC";
        } else {
            throw new IllegalArgumentException("Unknown review type");
        }
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setLong(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.ReviewPurchase item = new model.ReviewPurchase();
                    item.type = type;
                    item.purchaseRef = rs.getLong("purchase_ref");
                    item.targetId = rs.getLong("target_id");
                    item.shopId = rs.getLong("shop_id");
                    item.productName = rs.getString("product_name");
                    item.shopName = rs.getString("shop_name");
                    item.orderCode = rs.getString("order_code");
                    item.thumbnailUrl = rs.getString("thumbnail_url");
                    long existing = rs.getLong("existing_id");
                    item.existingReviewId = rs.wasNull() ? null : existing;
                    item.canReview = item.existingReviewId == null;
                    out.add(item);
                }
            }
        }
        return out;
    }

    /**
     * Shop owner sees only reviews of their own shops.
     */
    public List<Review> listOwned(String type, long ownerId, int limit, int offset) throws SQLException {
        String sql;
        if ("PRODUCT".equals(type)) {
            sql = "SELECT r.review_id id,r.customer_id,r.shop_id,r.order_item_id, "
                    + "CAST(NULL AS BIGINT) sub_order_id,p.product_id,p.name product_name,s.shop_name, "
                    + "r.rating,r.comment,r.reply_comment,u.full_name customer_name, "
                    + "(SELECT TOP 1 pi.image_url FROM dbo.product_images pi WHERE pi.product_id=p.product_id ORDER BY pi.is_thumbnail DESC,pi.display_order ASC) thumbnail_url, "
                    + "r.status,r.created_at,r.updated_at FROM dbo.reviews r "
                    + "JOIN dbo.shops s ON s.shop_id=r.shop_id JOIN dbo.users u ON u.user_id=r.customer_id "
                    + "JOIN dbo.order_items oi ON oi.order_item_id=r.order_item_id "
                    + "LEFT JOIN dbo.product_variants pv ON pv.variant_id=oi.variant_id "
                    + "LEFT JOIN dbo.products p ON p.product_id=pv.product_id "
                    + "WHERE s.owner_id=? AND r.status='APPROVED' "
                    + "ORDER BY r.created_at DESC,r.review_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        } else if ("SHOP".equals(type)) {
            sql = "SELECT sr.shop_review_id id,sr.customer_id,sr.shop_id,CAST(NULL AS BIGINT) order_item_id, "
                    + "sr.sub_order_id,CAST(NULL AS BIGINT) product_id,CAST(NULL AS NVARCHAR(200)) product_name, "
                    + "s.shop_name,sr.rating,sr.comment,sr.reply_comment,u.full_name customer_name, "
                    + "CAST(s.logo_url AS VARCHAR(500)) thumbnail_url,sr.status,sr.created_at,sr.updated_at "
                    + "FROM dbo.shop_reviews sr JOIN dbo.shops s ON s.shop_id=sr.shop_id "
                    + "JOIN dbo.users u ON u.user_id=sr.customer_id "
                    + "WHERE s.owner_id=? AND sr.status='APPROVED' "
                    + "ORDER BY sr.created_at DESC,sr.shop_review_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        } else {
            throw new IllegalArgumentException("Unknown review type");
        }
        List<Review> out = new ArrayList<>();
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, ownerId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(mapReview(rs, type));
                }
            }
        }
        return out;
    }

    public boolean replyAsOwner(String type, long ownerId, long reviewId, String comment) throws SQLException {
        String sql = "UPDATE r SET reply_comment=?,updated_at=SYSUTCDATETIME() "
                + "FROM " + table(type) + " r WHERE r." + idColumn(type) + "=? AND r.status='APPROVED' "
                + "AND EXISTS(SELECT 1 FROM dbo.shops s WHERE s.shop_id=r.shop_id AND s.owner_id=?)";
        try (Connection c = connection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, comment);
            ps.setLong(2, reviewId);
            ps.setLong(3, ownerId);
            return ps.executeUpdate() == 1;
        }
    }}
