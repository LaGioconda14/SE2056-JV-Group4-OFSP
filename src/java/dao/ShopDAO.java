package dao;

import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Shop;
import util.DBContext;

public class ShopDAO extends DBContext {

    /**
     * Lấy shopID bằng id người dùng đã được lưu bằng session
     */
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
            e.printStackTrace();
        }

        return shopId;
    }

    /**
     * Lấy toàn bộ thông tin Shop theo ownerId để lưu vào Session khi đăng nhập
     */
    public Shop getShopByOwnerId(long ownerId) {
        String sql = "SELECT * FROM shops WHERE owner_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Lấy thông tin Shop theo shop_id
     */
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
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Lấy thông tin Shop theo slug
     */
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
            e.printStackTrace();
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

    /**
     * Tìm kiếm shop theo tên, mô tả hoặc tỉnh thành
     */
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
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return total;
    }

    public java.math.BigDecimal getTotalInventoryValueByShopId(long shopId) {
        java.math.BigDecimal totalValue = java.math.BigDecimal.ZERO;
        String sql = "SELECT SUM(pv.price * pv.stock_quantity) "
                + "FROM shops s "
                + "JOIN products p ON s.shop_id = p.shop_id "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE s.shop_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.math.BigDecimal val = rs.getBigDecimal(1);
                    if (val != null) {
                        totalValue = val;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
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
            e.printStackTrace();
        }
        return total;
    }
}
