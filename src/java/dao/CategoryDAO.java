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
}
