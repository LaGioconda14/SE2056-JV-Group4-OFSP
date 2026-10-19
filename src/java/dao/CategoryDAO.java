package dao;

import java.util.ArrayList;
import java.util.List;
import model.Category;
import util.DBContext;
import java.sql.*;

public class CategoryDAO extends DBContext {

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, parent_id, category_name, slug, description, image_url, icon_class, display_order, is_active "
                + "FROM categories WHERE is_active = 1 ORDER BY display_order ASC, category_id ASC";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setParentId(rs.getObject("parent_id") != null ? rs.getInt("parent_id") : null);
                c.setCategoryName(rs.getString("category_name"));
                c.setSlug(rs.getString("slug"));
                c.setDescription(rs.getString("description"));
                c.setImageUrl(rs.getString("image_url"));
                c.setIconClass(rs.getString("icon_class"));
                c.setDisplayOrder(rs.getInt("display_order"));
                c.setIsActive(rs.getBoolean("is_active"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Category> getAllCategoriesWithCount() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.parent_id, c.category_name, c.slug, c.description, c.image_url, c.icon_class, c.display_order, c.is_active, "
                + "(SELECT COUNT(*) FROM products p WHERE p.is_active = 1 "
                + "  AND (p.category_id = c.category_id "
                + "       OR p.category_id IN (SELECT sub.category_id FROM categories sub WHERE sub.parent_id = c.category_id))) AS product_count "
                + "FROM categories c WHERE c.is_active = 1 ORDER BY c.display_order ASC, c.category_id ASC";

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setParentId(rs.getObject("parent_id") != null ? rs.getInt("parent_id") : null);
                c.setCategoryName(rs.getString("category_name"));
                c.setSlug(rs.getString("slug"));
                c.setDescription(rs.getString("description"));
                c.setImageUrl(rs.getString("image_url"));
                c.setIconClass(rs.getString("icon_class"));
                c.setDisplayOrder(rs.getInt("display_order"));
                c.setIsActive(rs.getBoolean("is_active"));
                c.setProductCount(rs.getInt("product_count"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
