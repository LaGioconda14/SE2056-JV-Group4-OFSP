package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ProductBatch;
import util.DBContext;

public class InventoryDAO extends DBContext {

    public List<ProductBatch> getBatchesByShopId(long shopId) {
        List<ProductBatch> list = new ArrayList<>();
        String sql = "SELECT b.batch_id, b.batch_code, b.variant_id, b.initial_quantity, " +
                     "       b.current_quantity, b.expiry_date, b.status, " +
                     "       pv.sku, pv.variant_name, p.name AS product_name, " +
                     "       c.category_name, product_image.image_url " +
                     "FROM product_batches b " +
                     "JOIN product_variants pv ON b.variant_id = pv.variant_id " +
                     "JOIN products p ON pv.product_id = p.product_id " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "OUTER APPLY (SELECT TOP 1 pi.image_url FROM product_images pi " +
                     "             WHERE pi.product_id = p.product_id " +
                     "             ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) product_image " +
                     "WHERE p.shop_id = ? " +
                     "ORDER BY b.expiry_date ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setLong(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductBatch batch = new ProductBatch();
                    batch.setBatchId(rs.getLong("batch_id"));
                    batch.setBatchCode(rs.getString("batch_code"));
                    batch.setVariantId(rs.getLong("variant_id"));
                    batch.setInitialQuantity(rs.getInt("initial_quantity"));
                    batch.setCurrentQuantity(rs.getInt("current_quantity"));
                    batch.setExpiryDate(rs.getDate("expiry_date"));
                    batch.setStatus(rs.getString("status"));
                    batch.setSku(rs.getString("sku"));
                    batch.setVariantName(rs.getString("variant_name"));
                    batch.setProductName(rs.getString("product_name") + " (" + rs.getString("variant_name") + ")");
                    
                    // Lấy tên danh mục từ CSDL, nếu null thì gán mặc định "Nông sản"
                    String catName = rs.getString("category_name");
                    batch.setCategoryName(catName != null && !catName.trim().isEmpty() ? catName : "Nông sản");
                    
                    batch.setImageUrl(rs.getString("image_url"));
                    
                    list.add(batch);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}