package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Review;
import util.DBContext;

public class ReviewDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ReviewDAO.class.getName());

    public ReviewDAO() {
        initTable();
    }

    private void initTable() {
        String sql = "IF OBJECT_ID(N'dbo.review_images', N'U') IS NULL "
                + "BEGIN "
                + "    CREATE TABLE [dbo].[review_images] ( "
                + "        [image_id]   BIGINT IDENTITY(1,1) PRIMARY KEY, "
                + "        [review_id]  BIGINT NOT NULL, "
                + "        [image_url]  VARCHAR(500) NOT NULL, "
                + "        [created_at] DATETIME DEFAULT CURRENT_TIMESTAMP, "
                + "        CONSTRAINT FK_review_images_review FOREIGN KEY ([review_id]) REFERENCES [dbo].[reviews]([review_id]) ON DELETE CASCADE "
                + "    ); "
                + "END";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error initializing review_images table", e);
        }
    }

    public List<Review> getReviewsByProductId(long productId, Integer ratingFilter, int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.review_id, r.order_item_id, r.customer_id, r.shop_id, r.rating, ")
           .append("       r.comment, r.reply_comment, r.status, r.created_at, r.updated_at, ")
           .append("       u.full_name, u.avatar_url, ")
           .append("       oi.product_name_snapshot, oi.variant_name_snapshot, pv.product_id ")
           .append("FROM reviews r ")
           .append("JOIN order_items oi ON r.order_item_id = oi.order_item_id ")
           .append("JOIN product_variants pv ON oi.variant_id = pv.variant_id ")
           .append("JOIN users u ON r.customer_id = u.user_id ")
           .append("WHERE pv.product_id = ? AND r.status = 'APPROVED' ");

        List<Object> params = new ArrayList<>();
        params.add(productId);

        if (ratingFilter != null && ratingFilter >= 1 && ratingFilter <= 5) {
            sql.append(" AND r.rating = ? ");
            params.add(ratingFilter);
        }

        sql.append("ORDER BY r.created_at DESC ")
           .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = mapResultSetToReview(rs);
                    list.add(r);
                }
            }

            for (Review r : list) {
                r.setImages(getReviewImages(conn, r.getReviewId()));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting reviews for productId: " + productId, e);
        }
        return list;
    }

    public Map<String, Object> getRatingSummary(long productId) {
        Map<String, Object> map = new HashMap<>();
        int[] stars = new int[6];
        int total = 0;
        double sum = 0.0;

        String sql = "SELECT r.rating, COUNT(*) AS cnt "
                + "FROM reviews r "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "WHERE pv.product_id = ? AND r.status = 'APPROVED' "
                + "GROUP BY r.rating";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int star = rs.getInt("rating");
                    int count = rs.getInt("cnt");
                    if (star >= 1 && star <= 5) {
                        stars[star] = count;
                        total += count;
                        sum += star * count;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting rating summary for productId: " + productId, e);
        }

        double avg = total > 0 ? (Math.round((sum / total) * 10.0) / 10.0) : 5.0;
        map.put("avgRating", avg);
        map.put("totalReviews", total);
        for (int i = 1; i <= 5; i++) {
            map.put("star" + i, stars[i]);
            map.put("percent" + i, total > 0 ? (int) Math.round(stars[i] * 100.0 / total) : 0);
        }
        return map;
    }

    public boolean canCustomerReview(long customerId, long orderItemId) {
        String sql = "SELECT 1 FROM order_items oi "
                + "JOIN sub_orders so ON oi.sub_order_id = so.sub_order_id "
                + "JOIN orders o ON so.order_id = o.order_id "
                + "WHERE oi.order_item_id = ? AND o.customer_id = ? AND so.status = 'DELIVERED' "
                + "AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.order_item_id = oi.order_item_id)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderItemId);
            ps.setLong(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking if customer can review orderItemId: " + orderItemId, e);
        }
        return false;
    }

    public long insertReview(Review review, List<String> imageUrls) {
        String sqlReview = "INSERT INTO reviews (order_item_id, customer_id, shop_id, rating, comment, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, 'APPROVED', GETDATE(), GETDATE())";
        String sqlImages = "INSERT INTO review_images (review_id, image_url, created_at) VALUES (?, ?, GETDATE())";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            long reviewId = -1;

            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlReview, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setLong(1, review.getOrderItemId());
                    ps.setLong(2, review.getCustomerId());
                    ps.setLong(3, review.getShopId());
                    ps.setInt(4, review.getRating());
                    ps.setString(5, review.getComment());
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            reviewId = rs.getLong(1);
                        }
                    }
                }

                if (reviewId > 0 && imageUrls != null && !imageUrls.isEmpty()) {
                    try (PreparedStatement psImg = conn.prepareStatement(sqlImages)) {
                        for (String url : imageUrls) {
                            if (url != null && !url.trim().isEmpty()) {
                                psImg.setLong(1, reviewId);
                                psImg.setString(2, url.trim());
                                psImg.addBatch();
                            }
                        }
                        psImg.executeBatch();
                    }
                }

                conn.commit();
                return reviewId;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting review for orderItemId: " + review.getOrderItemId(), e);
        }
        return -1;
    }

    public List<Review> getReviewsByShop(long shopId, String tab, int page, int pageSize) {
        List<Review> list = new ArrayList<>();
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.review_id, r.order_item_id, r.customer_id, r.shop_id, r.rating, ")
           .append("       r.comment, r.reply_comment, r.status, r.created_at, r.updated_at, ")
           .append("       u.full_name, u.avatar_url, ")
           .append("       oi.product_name_snapshot, oi.variant_name_snapshot, ")
           .append("       pv.product_id, pi.image_url AS product_image ")
           .append("FROM reviews r ")
           .append("JOIN order_items oi ON r.order_item_id = oi.order_item_id ")
           .append("LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id ")
           .append("LEFT JOIN product_images pi ON pv.product_id = pi.product_id AND pi.is_thumbnail = 1 ")
           .append("JOIN users u ON r.customer_id = u.user_id ")
           .append("WHERE r.shop_id = ? ");

        if ("unreplied".equalsIgnoreCase(tab)) {
            sql.append(" AND (r.reply_comment IS NULL OR LTRIM(RTRIM(r.reply_comment)) = '') ");
        } else if ("positive".equalsIgnoreCase(tab)) {
            sql.append(" AND r.rating >= 4 ");
        } else if ("negative".equalsIgnoreCase(tab)) {
            sql.append(" AND r.rating <= 3 ");
        }

        sql.append("ORDER BY r.created_at DESC ")
           .append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, shopId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = mapResultSetToReview(rs);
                    String pImg = rs.getString("product_image");
                    r.setProductImage(pImg != null ? pImg : "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=100");
                    list.add(r);
                }
            }

            for (Review r : list) {
                r.setImages(getReviewImages(conn, r.getReviewId()));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting reviews for shopId: " + shopId, e);
        }
        return list;
    }

    public int countReviewsByShop(long shopId, String tab) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM reviews r WHERE r.shop_id = ?");
        if ("unreplied".equalsIgnoreCase(tab)) {
            sql.append(" AND (r.reply_comment IS NULL OR LTRIM(RTRIM(r.reply_comment)) = '')");
        } else if ("positive".equalsIgnoreCase(tab)) {
            sql.append(" AND r.rating >= 4");
        } else if ("negative".equalsIgnoreCase(tab)) {
            sql.append(" AND r.rating <= 3");
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting reviews for shopId: " + shopId, e);
        }
        return 0;
    }

    public boolean replyReview(long shopId, long reviewId, String replyComment) {
        String sql = "UPDATE reviews SET reply_comment = ?, updated_at = GETDATE() WHERE review_id = ? AND shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, replyComment);
            ps.setLong(2, reviewId);
            ps.setLong(3, shopId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error replying to reviewId: " + reviewId, e);
        }
        return false;
    }

    public Review getReviewById(long reviewId) {
        String sql = "SELECT r.review_id, r.order_item_id, r.customer_id, r.shop_id, r.rating, "
                + "       r.comment, r.reply_comment, r.status, r.created_at, r.updated_at, "
                + "       u.full_name, u.avatar_url, "
                + "       oi.product_name_snapshot, oi.variant_name_snapshot, pv.product_id "
                + "FROM reviews r "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "JOIN users u ON r.customer_id = u.user_id "
                + "WHERE r.review_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Review r = mapResultSetToReview(rs);
                    r.setImages(getReviewImages(conn, r.getReviewId()));
                    return r;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting review by ID: " + reviewId, e);
        }
        return null;
    }

    public Map<String, Object> getOrderItemForReview(long customerId, long orderItemId) {
        String sql = "SELECT oi.order_item_id, oi.product_name_snapshot, oi.variant_name_snapshot, "
                + "       oi.unit_price, oi.quantity, so.shop_id, s.shop_name, "
                + "       pv.product_id, pi.image_url "
                + "FROM order_items oi "
                + "JOIN sub_orders so ON oi.sub_order_id = so.sub_order_id "
                + "JOIN orders o ON so.order_id = o.order_id "
                + "JOIN shops s ON so.shop_id = s.shop_id "
                + "LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "LEFT JOIN product_images pi ON pv.product_id = pi.product_id AND pi.is_thumbnail = 1 "
                + "WHERE oi.order_item_id = ? AND o.customer_id = ? AND so.status = 'DELIVERED'";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderItemId);
            ps.setLong(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("orderItemId", rs.getLong("order_item_id"));
                    m.put("productName", rs.getString("product_name_snapshot"));
                    m.put("variantName", rs.getString("variant_name_snapshot"));
                    m.put("unitPrice", rs.getBigDecimal("unit_price"));
                    m.put("quantity", rs.getInt("quantity"));
                    m.put("shopId", rs.getLong("shop_id"));
                    m.put("shopName", rs.getString("shop_name"));
                    m.put("productId", rs.getLong("product_id"));
                    String img = rs.getString("image_url");
                    m.put("imageUrl", img != null ? img : "https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=100");
                    return m;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting order item for review: " + orderItemId, e);
        }
        return null;
    }

    private List<String> getReviewImages(Connection conn, long reviewId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT image_url FROM review_images WHERE review_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("image_url"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting images for reviewId: " + reviewId, e);
        }
        return list;
    }

    private Review mapResultSetToReview(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getLong("review_id"));
        r.setOrderItemId(rs.getLong("order_item_id"));
        r.setCustomerId(rs.getLong("customer_id"));
        r.setShopId(rs.getLong("shop_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setReplyComment(rs.getString("reply_comment"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));

        String name = rs.getString("full_name");
        r.setCustomerName(name != null && !name.trim().isEmpty() ? name : "Khách hàng");
        String avatar = rs.getString("avatar_url");
        r.setCustomerAvatar(avatar != null && !avatar.trim().isEmpty() ? avatar : "https://ui-avatars.com/api/?name=" + (name != null ? name.replace(" ", "+") : "User") + "&background=10b981&color=fff");

        try {
            r.setProductName(rs.getString("product_name_snapshot"));
            r.setVariantName(rs.getString("variant_name_snapshot"));
            r.setProductId(rs.getLong("product_id"));
        } catch (Exception ignored) {
        }

        return r;
    }
}

