package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Review;
import model.Shop;
import util.DBContext;

public class ShopDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ShopDAO.class.getName());

    public long getShopIdByOwnerId(long ownerId) {
        long shopId = -1;
        String sql = "SELECT shop_id FROM shops WHERE owner_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    shopId = rs.getLong("shop_id");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting shopId by ownerId: " + ownerId, e);
        }
        return shopId;
    }

    public Shop getShopByOwnerId(long ownerId) {
        String sql = "SELECT * FROM shops WHERE owner_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShop(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting shop by ownerId: " + ownerId, e);
        }
        return null;
    }

    public Shop getShopById(long shopId) {
        String sql = "SELECT * FROM shops WHERE shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShop(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting shop by shopId: " + shopId, e);
        }
        return null;
    }

    public Shop getShopBySlug(String slug) {
        String sql = "SELECT * FROM shops WHERE slug = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShop(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting shop by slug: " + slug, e);
        }
        return null;
    }

    public Shop getFirstActiveShop() {
        String sql = "SELECT TOP 1 * FROM shops WHERE status = 'ACTIVE' ORDER BY shop_id ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return mapResultSetToShop(rs);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting first active shop", e);
        }
        return null;
    }

    private Shop mapResultSetToShop(ResultSet rs) throws Exception {
        Shop shop = new Shop();
        shop.setShopId(rs.getLong("shop_id"));
        shop.setOwnerId(rs.getLong("owner_id"));
        shop.setShopName(rs.getString("shop_name"));
        shop.setSlug(rs.getString("slug"));
        shop.setBusinessType(rs.getString("business_type"));
        shop.setDescription(rs.getString("description"));
        shop.setLogoUrl(rs.getString("logo_url"));
        shop.setBannerUrl(rs.getString("banner_url"));
        shop.setPhone(rs.getString("phone"));
        shop.setAddress(rs.getString("address"));
        shop.setProvince(rs.getString("province"));
        shop.setCertificationName(rs.getString("certification_name"));
        shop.setCommissionRate(rs.getBigDecimal("commission_rate"));
        shop.setRating(rs.getBigDecimal("rating"));
        shop.setTotalSalesAmount(rs.getBigDecimal("total_sales_amount"));
        shop.setTotalOrdersCount(rs.getInt("total_orders_count"));
        shop.setStatus(rs.getString("status"));
        shop.setCreatedAt(rs.getTimestamp("created_at"));
        shop.setUpdatedAt(rs.getTimestamp("updated_at"));
        return shop;
    }

    public List<Shop> searchShops(String keyword) {
        List<Shop> list = new ArrayList<>();
        String sql = "SELECT * FROM shops WHERE status = 'ACTIVE' ";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (shop_name COLLATE SQL_Latin1_General_CP1_CI_AI LIKE ? "
                +  "      OR description COLLATE SQL_Latin1_General_CP1_CI_AI LIKE ? "
                +  "      OR province COLLATE SQL_Latin1_General_CP1_CI_AI LIKE ?)";
        }
        sql += " ORDER BY rating DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (keyword != null && !keyword.trim().isEmpty()) {
                String p = "%" + keyword.trim() + "%";
                ps.setString(1, p);
                ps.setString(2, p);
                ps.setString(3, p);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToShop(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error searching shops with keyword: " + keyword, e);
        }
        return list;
    }

    public int getTotalSkusByShopId(long shopID) {
        int total = 0;
        String sql = "SELECT COUNT(pv.sku) "
                + "FROM shops s "
                + "JOIN products p ON s.shop_id = p.shop_id "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE s.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting total SKUs for shopId: " + shopID, e);
        }
        return total;
    }

    public BigDecimal getTotalInventoryValueByShopId(long shopId) {
        BigDecimal totalValue = BigDecimal.ZERO;
        String sql = "SELECT SUM(pv.price * pv.stock_quantity) "
                + "FROM shops s "
                + "JOIN products p ON s.shop_id = p.shop_id "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE s.shop_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal val = rs.getBigDecimal(1);
                    if (val != null) {
                        totalValue = val;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting total inventory value for shopId: " + shopId, e);
        }
        return totalValue;
    }

    public int getLowStockCountByShopId(long shopId) {
        int total = 0;
        String sql = "SELECT COUNT(pv.sku) "
                + "FROM shops s "
                + "JOIN products p ON s.shop_id = p.shop_id "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE s.shop_id = ? AND pv.stock_quantity <= 10";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting low stock count for shopId: " + shopId, e);
        }
        return total;
    }

    public int getTotalProductsCountByShopId(long shopId) {
        int total = 0;
        String sql = "SELECT COUNT(DISTINCT p.product_id) "
                + "FROM products p "
                + "WHERE p.shop_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting total products count for shopId: " + shopId, e);
        }
        return total;
    }

    public int getActiveSkusCountByShopId(long shopId) {
        int total = 0;
        String sql = "SELECT COUNT(pv.sku) "
                + "FROM products p "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE p.shop_id = ? AND pv.is_active = 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting active SKUs count for shopId: " + shopId, e);
        }
        return total;
    }

    public int getOcopOrVietgapCountByShopId(long shopId) {
        int total = 0;
        String sql = "SELECT COUNT(pv.sku) "
                + "FROM products p "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE p.shop_id = ? AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%' OR p.certification LIKE '%GlobalGAP%')";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting OCOP/VietGAP count for shopId: " + shopId, e);
        }
        return total;
    }

    public int getTabCountByShopId(long shopId, String tab) {
        int total = 0;
        String sql = "SELECT COUNT(pv.sku) FROM products p JOIN product_variants pv ON p.product_id = pv.product_id WHERE p.shop_id = ?";
        if ("active".equalsIgnoreCase(tab)) {
            sql += " AND pv.is_active = 1";
        } else if ("vietgap".equalsIgnoreCase(tab)) {
            sql += " AND (p.certification LIKE '%VietGAP%' OR p.certification LIKE '%OCOP%')";
        } else if ("hidden".equalsIgnoreCase(tab)) {
            sql += " AND (pv.stock_quantity = 0 OR pv.is_active = 0)";
        } else if ("warning".equalsIgnoreCase(tab)) {
            sql += " AND pv.stock_quantity <= 5";
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting tab count for shopId: " + shopId + ", tab: " + tab, e);
        }
        return total;
    }

    public boolean updateShopMedia(long ownerId, String logoUrl, String bannerUrl) {
        String sql = "UPDATE shops SET logo_url = COALESCE(?, logo_url), "
                + "banner_url = COALESCE(?, banner_url), updated_at = GETDATE() WHERE owner_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, logoUrl);
            ps.setString(2, bannerUrl);
            ps.setLong(3, ownerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating shop media for ownerId: " + ownerId, e);
        }
        return false;
    }

    public boolean updateShopStatusBySeller(long ownerId, String newStatus) {
        String sql = "UPDATE shops SET status = ?, updated_at = GETDATE() "
                + "WHERE owner_id = ? AND status IN ('ACTIVE', 'PAUSED', 'CLOSED')";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setLong(2, ownerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating shop status for ownerId: " + ownerId, e);
        }
        return false;
    }

    public List<Review> getReviewsByShopId(long shopId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.review_id, r.order_item_id, r.customer_id, r.shop_id, r.rating, "
                + "r.comment, r.reply_comment, r.status, r.created_at, "
                + "u.full_name, u.avatar_url "
                + "FROM reviews r "
                + "LEFT JOIN users u ON r.customer_id = u.user_id "
                + "WHERE r.shop_id = ? "
                + "ORDER BY r.created_at DESC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review rev = new Review();
                    rev.setReviewId(rs.getLong("review_id"));
                    rev.setOrderItemId(rs.getObject("order_item_id") != null ? rs.getLong("order_item_id") : null);
                    rev.setCustomerId(rs.getLong("customer_id"));
                    rev.setShopId(rs.getLong("shop_id"));
                    rev.setRating(rs.getInt("rating"));
                    rev.setComment(rs.getString("comment"));
                    rev.setReplyComment(rs.getString("reply_comment"));
                    rev.setStatus(rs.getString("status"));
                    rev.setCreatedAt(rs.getTimestamp("created_at"));

                    String name = rs.getString("full_name");
                    rev.setCustomerName(name != null && !name.trim().isEmpty() ? name : "Khách hàng");
                    String avatar = rs.getString("avatar_url");
                    rev.setCustomerAvatar(avatar != null && !avatar.trim().isEmpty() ? avatar : "https://ui-avatars.com/api/?name=" + (name != null ? name.replace(" ", "+") : "User") + "&background=10b981&color=fff");
                    list.add(rev);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting reviews for shopId: " + shopId, e);
        }
        return list;
    }
}
