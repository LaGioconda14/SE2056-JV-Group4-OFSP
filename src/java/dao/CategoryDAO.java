/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.util.ArrayList;
import java.util.List;
import model.Category;
import util.DBContext;
import java.sql.*;

/**
 *
 * @author ADMIN
 */
public class CategoryDAO extends DBContext{

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, category_name, slug, description, is_active "
                + "FROM categories WHERE is_active = 1 ORDER BY category_id ASC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setParentId(null);
                c.setCategoryName(rs.getString("category_name"));
                c.setSlug(rs.getString("slug"));
                c.setDescription(rs.getString("description"));
                c.setImageUrl(null);
                c.setIconClass(null);
                c.setDisplayOrder(rs.getInt("category_id"));
                c.setIsActive(rs.getBoolean("is_active"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
