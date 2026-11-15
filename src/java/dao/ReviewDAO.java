package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.review.Review;
import model.dto.review.ReviewSummary;
import util.DBContext;

public class ReviewDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ReviewDAO.class.getName());

    public boolean canReviewOrderItem(long customerId, long orderItemId) {
        String sql = "SELECT 1 FROM order_items oi "
                + "JOIN sub_orders so ON so.sub_order_id = oi.sub_order_id "
                + "JOIN orders o ON o.order_id = so.order_id "
                + "WHERE oi.order_item_id = ? AND o.customer_id = ? "
                + "  AND so.status = 'DELIVERED' "
                + "  AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.order_item_id = oi.order_item_id)";
        try (Connection conn = getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, orderItemId);
                ps.setLong(2, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking review eligibility", ex);
            return false;
        }
    }

    public long createReview(long customerId, long orderItemId, int rating, String comment) throws Exception {
        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException("Điểm đánh giá phải từ 1 đến 5 sao!");
        }
        if (comment == null) {
            comment = "";
        }

        String checkSql = "SELECT so.shop_id, pv.product_id FROM order_items oi "
                + "JOIN sub_orders so ON so.sub_order_id = oi.sub_order_id "
                + "JOIN orders o ON o.order_id = so.order_id "
                + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "WHERE oi.order_item_id = ? AND o.customer_id = ? AND so.status = 'DELIVERED'";

        String insertSql = "INSERT INTO reviews (order_item_id, customer_id, shop_id, rating, comment, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, 'APPROVED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";


        String updateShopSql = "UPDATE shops "
                + "SET rating = COALESCE((SELECT CAST(AVG(CAST(r.rating AS DECIMAL(3,2))) AS DECIMAL(3,2)) "
                + "                      FROM reviews r WHERE r.shop_id = shops.shop_id AND r.status = 'APPROVED'), 5.0) "
                + "WHERE shop_id = ?";

        Connection conn = getConnection();
        if (conn == null) {
            throw new SQLException("Không thể kết nối cơ sở dữ liệu!");
        }

        try {
            conn.setAutoCommit(false);
            long shopId;
            long productId;

            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setLong(1, orderItemId);
                psCheck.setLong(2, customerId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        throw new IllegalStateException("Đơn hàng chưa giao thành công hoặc không thuộc quyền đánh giá của bạn!");
                    }
                    shopId = rs.getLong("shop_id");
                    productId = rs.getLong("product_id");
                }
            }

            // Kiểm tra đã đánh giá chưa
            try (PreparedStatement psDup = conn.prepareStatement("SELECT 1 FROM reviews WHERE order_item_id = ?")) {
                psDup.setLong(1, orderItemId);
                try (ResultSet rs = psDup.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        throw new IllegalStateException("Sản phẩm này trong đơn hàng đã được đánh giá trước đó!");
                    }
                }
            }

            long reviewId = -1;
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                psInsert.setLong(1, orderItemId);
                psInsert.setLong(2, customerId);
                psInsert.setLong(3, shopId);
                psInsert.setInt(4, rating);
                psInsert.setString(5, comment.trim());
                psInsert.executeUpdate();
                try (ResultSet rs = psInsert.getGeneratedKeys()) {
                    if (rs.next()) {
                        reviewId = rs.getLong(1);
                    }
                }
            }

            // Cập nhật rating và reviews_count sản phẩm

            // Cập nhật rating shop
            try (PreparedStatement psShop = conn.prepareStatement(updateShopSql)) {
                psShop.setLong(1, shopId);
                psShop.executeUpdate();
            }

            conn.commit();
            return reviewId;
        } catch (Exception ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(true);
            conn.close();
        }
    }

    public List<Review> getReviewsByProduct(long productId, int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        String sql = "SELECT r.review_id, r.order_item_id, r.customer_id, u.full_name AS customer_name, u.avatar_url AS customer_avatar, "
                + "       r.shop_id, s.shop_name, pv.product_id, oi.product_name_snapshot, oi.variant_name_snapshot, "
                + "       r.rating, r.comment, r.reply_comment, r.status, r.created_at, r.updated_at "
                + "FROM reviews r "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "JOIN users u ON r.customer_id = u.user_id "
                + "JOIN shops s ON r.shop_id = s.shop_id "
                + "WHERE pv.product_id = ? AND r.status = 'APPROVED' "
                + "ORDER BY r.created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = getConnection()) {
            if (conn == null) return list;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, productId);
                ps.setInt(2, offset);
                ps.setInt(3, pageSize);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Review r = new Review();
                        r.setReviewId(rs.getLong("review_id"));
                        r.setOrderItemId(rs.getLong("order_item_id"));
                        r.setCustomerId(rs.getLong("customer_id"));
                        r.setCustomerName(rs.getString("customer_name"));
                        r.setCustomerAvatar(rs.getString("customer_avatar"));
                        r.setShopId(rs.getLong("shop_id"));
                        r.setShopName(rs.getString("shop_name"));
                        r.setProductId(rs.getLong("product_id"));
                        r.setProductName(rs.getString("product_name_snapshot"));
                        r.setVariantName(rs.getString("variant_name_snapshot"));
                        r.setRating(rs.getInt("rating"));
                        r.setComment(rs.getString("comment"));
                        r.setReplyComment(rs.getString("reply_comment"));
                        r.setStatus(rs.getString("status"));
                        r.setCreatedAt(rs.getTimestamp("created_at"));
                        r.setUpdatedAt(rs.getTimestamp("updated_at"));
                        list.add(r);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading product reviews for product " + productId, ex);
        }
        return list;
    }

    public ReviewSummary getReviewSummary(long productId) {
        ReviewSummary summary = new ReviewSummary();
        String sql = "SELECT r.rating, COUNT(*) AS cnt "
                + "FROM reviews r "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "WHERE pv.product_id = ? AND r.status = 'APPROVED' "
                + "GROUP BY r.rating";

        try (Connection conn = getConnection()) {
            if (conn == null) return summary;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    int total = 0;
                    double sumStars = 0;
                    while (rs.next()) {
                        int star = rs.getInt("rating");
                        int count = rs.getInt("cnt");
                        total += count;
                        sumStars += (star * count);
                        switch (star) {
                            case 5 -> summary.setStar5(count);
                            case 4 -> summary.setStar4(count);
                            case 3 -> summary.setStar3(count);
                            case 2 -> summary.setStar2(count);
                            case 1 -> summary.setStar1(count);
                        }
                    }
                    summary.setTotalReviews(total);
                    if (total > 0) {
                        summary.setAverageRating(Math.round((sumStars / total) * 10.0) / 10.0);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading review summary for product " + productId, ex);
        }
        return summary;
    }

    public List<Review> getReviewsByCustomer(long customerId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.review_id, r.order_item_id, r.customer_id, u.full_name AS customer_name, u.avatar_url AS customer_avatar, "
                + "       r.shop_id, s.shop_name, pv.product_id, oi.product_name_snapshot, oi.variant_name_snapshot, "
                + "       (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = pv.product_id ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) AS product_image, "
                + "       r.rating, r.comment, r.reply_comment, r.status, r.created_at, r.updated_at "
                + "FROM reviews r "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "JOIN users u ON r.customer_id = u.user_id "
                + "JOIN shops s ON r.shop_id = s.shop_id "
                + "WHERE r.customer_id = ? "
                + "ORDER BY r.created_at DESC";

        try (Connection conn = getConnection()) {
            if (conn == null) return list;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Review r = new Review();
                        r.setReviewId(rs.getLong("review_id"));
                        r.setOrderItemId(rs.getLong("order_item_id"));
                        r.setCustomerId(rs.getLong("customer_id"));
                        r.setCustomerName(rs.getString("customer_name"));
                        r.setCustomerAvatar(rs.getString("customer_avatar"));
                        r.setShopId(rs.getLong("shop_id"));
                        r.setShopName(rs.getString("shop_name"));
                        r.setProductId(rs.getLong("product_id"));
                        r.setProductName(rs.getString("product_name_snapshot"));
                        r.setVariantName(rs.getString("variant_name_snapshot"));
                        String rImg = rs.getString("product_image");
                        if (rImg == null || rImg.trim().isEmpty()) {
                            rImg = ProductDAO.getDefaultFruitImage(r.getProductName());
                        }
                        r.setProductImage(rImg);
                        r.setRating(rs.getInt("rating"));
                        r.setComment(rs.getString("comment"));
                        r.setReplyComment(rs.getString("reply_comment"));
                        r.setStatus(rs.getString("status"));
                        r.setCreatedAt(rs.getTimestamp("created_at"));
                        r.setUpdatedAt(rs.getTimestamp("updated_at"));
                        list.add(r);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading customer reviews for user " + customerId, ex);
        }
        return list;
    }

    public List<Review> getReviewsByShop(long shopId, int page, int pageSize) {
        return getReviewsByShop(shopId, null, null, null, page, pageSize);
    }

    public List<Review> getReviewsByShop(long shopId, Integer rating, String replyStatus, String keyword, int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.review_id, r.order_item_id, r.customer_id, u.full_name AS customer_name, u.avatar_url AS customer_avatar, ")
           .append("       r.shop_id, s.shop_name, pv.product_id, oi.product_name_snapshot, oi.variant_name_snapshot, ")
           .append("       (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = pv.product_id ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) AS product_image, ")
           .append("       r.rating, r.comment, r.reply_comment, r.status, r.created_at, r.updated_at ")
           .append("FROM reviews r ")
           .append("JOIN order_items oi ON r.order_item_id = oi.order_item_id ")
           .append("LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id ")
           .append("JOIN users u ON r.customer_id = u.user_id ")
           .append("LEFT JOIN shops s ON r.shop_id = s.shop_id ")
           .append("WHERE r.shop_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(shopId);

        if (rating != null && rating >= 1 && rating <= 5) {
            sql.append(" AND r.rating = ? ");
            params.add(rating);
        }

        if ("UNREPLIED".equalsIgnoreCase(replyStatus)) {
            sql.append(" AND (r.reply_comment IS NULL OR LTRIM(RTRIM(r.reply_comment)) = '') ");
        } else if ("REPLIED".equalsIgnoreCase(replyStatus)) {
            sql.append(" AND (r.reply_comment IS NOT NULL AND LTRIM(RTRIM(r.reply_comment)) <> '') ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (oi.product_name_snapshot LIKE ? OR u.full_name LIKE ? OR r.comment LIKE ?) ");
            String kwParam = "%" + keyword.trim() + "%";
            params.add(kwParam);
            params.add(kwParam);
            params.add(kwParam);
        }

        sql.append(" ORDER BY r.created_at DESC ")
           .append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = getConnection()) {
            if (conn == null) return list;
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Review r = new Review();
                        r.setReviewId(rs.getLong("review_id"));
                        r.setOrderItemId(rs.getLong("order_item_id"));
                        r.setCustomerId(rs.getLong("customer_id"));
                        r.setCustomerName(rs.getString("customer_name"));
                        r.setCustomerAvatar(rs.getString("customer_avatar"));
                        r.setShopId(rs.getLong("shop_id"));
                        r.setShopName(rs.getString("shop_name"));
                        r.setProductId(rs.getLong("product_id"));
                        r.setProductName(rs.getString("product_name_snapshot"));
                        r.setVariantName(rs.getString("variant_name_snapshot"));
                        String rImg = rs.getString("product_image");
                        if (rImg == null || rImg.trim().isEmpty()) {
                            rImg = ProductDAO.getDefaultFruitImage(r.getProductName());
                        }
                        r.setProductImage(rImg);
                        r.setRating(rs.getInt("rating"));
                        r.setComment(rs.getString("comment"));
                        r.setReplyComment(rs.getString("reply_comment"));
                        r.setStatus(rs.getString("status"));
                        r.setCreatedAt(rs.getTimestamp("created_at"));
                        r.setUpdatedAt(rs.getTimestamp("updated_at"));
                        list.add(r);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading shop reviews for shop " + shopId, ex);
        }
        return list;
    }

    public int countReviewsByShop(long shopId, Integer rating, String replyStatus, String keyword) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) ")
           .append("FROM reviews r ")
           .append("JOIN order_items oi ON r.order_item_id = oi.order_item_id ")
           .append("JOIN users u ON r.customer_id = u.user_id ")
           .append("WHERE r.shop_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(shopId);

        if (rating != null && rating >= 1 && rating <= 5) {
            sql.append(" AND r.rating = ? ");
            params.add(rating);
        }

        if ("UNREPLIED".equalsIgnoreCase(replyStatus)) {
            sql.append(" AND (r.reply_comment IS NULL OR LTRIM(RTRIM(r.reply_comment)) = '') ");
        } else if ("REPLIED".equalsIgnoreCase(replyStatus)) {
            sql.append(" AND (r.reply_comment IS NOT NULL AND LTRIM(RTRIM(r.reply_comment)) <> '') ");
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (oi.product_name_snapshot LIKE ? OR u.full_name LIKE ? OR r.comment LIKE ?) ");
            String kwParam = "%" + keyword.trim() + "%";
            params.add(kwParam);
            params.add(kwParam);
            params.add(kwParam);
        }

        try (Connection conn = getConnection()) {
            if (conn == null) return 0;
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting reviews for shop " + shopId, ex);
        }
        return 0;
    }

    public Map<String, Object> getShopReviewStats(long shopId) {
        Map<String, Object> stats = new HashMap<>();
        int[] counts = new int[6];
        int total = 0;
        double sum = 0.0;
        int unreplied = 0;

        String sql = "SELECT rating, "
                   + "       COUNT(*) AS total_count, "
                   + "       SUM(CASE WHEN reply_comment IS NULL OR LTRIM(RTRIM(reply_comment)) = '' THEN 1 ELSE 0 END) AS unreplied_count "
                   + "FROM reviews "
                   + "WHERE shop_id = ? AND status = 'APPROVED' "
                   + "GROUP BY rating";

        try (Connection conn = getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, shopId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int r = rs.getInt("rating");
                            int c = rs.getInt("total_count");
                            int u = rs.getInt("unreplied_count");
                            if (r >= 1 && r <= 5) {
                                counts[r] = c;
                                total += c;
                                sum += (double) r * c;
                                unreplied += u;
                            }
                        }
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error loading review stats for shop " + shopId, ex);
        }

        double avg = total > 0 ? (double) Math.round((sum / total) * 10.0) / 10.0 : 5.0;
        int positiveCount = counts[4] + counts[5];
        int positivePercent = total > 0 ? (int) Math.round((double) positiveCount * 100.0 / total) : 100;

        stats.put("total", total);
        stats.put("avgRating", avg);
        stats.put("unrepliedCount", unreplied);
        stats.put("repliedCount", total - unreplied);
        stats.put("positivePercent", positivePercent);
        for (int i = 1; i <= 5; i++) {
            stats.put("c" + i, counts[i]);
            stats.put("p" + i, total > 0 ? (int) Math.round((double) counts[i] * 100.0 / total) : 0);
        }
        return stats;
    }

    public boolean replyReview(long reviewId, long shopId, String replyComment) {
        String sql = "UPDATE reviews SET reply_comment = ?, updated_at = CURRENT_TIMESTAMP WHERE review_id = ? AND shop_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, replyComment != null ? replyComment.trim() : null);
                ps.setLong(2, reviewId);
                ps.setLong(3, shopId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error replying to review " + reviewId, ex);
            return false;
        }
    }

    public boolean updateReviewStatus(long reviewId, String status) {
        String sql = "UPDATE reviews SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE review_id = ?";
        try (Connection conn = getConnection()) {
            if (conn == null) return false;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setLong(2, reviewId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating review status " + reviewId, ex);
            return false;
        }
    }
}
