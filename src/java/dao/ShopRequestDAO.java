package dao;

import model.ShopRequest;
import util.DBContext; // Import đúng package chứa DBContext của bạn

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class ShopRequestDAO extends DBContext {

    public boolean insertShopRequest(ShopRequest req) {
        String sql = "INSERT INTO [dbo].[shop_requests] ("
                + "[user_id], [shop_name], [business_type], [province], [district], [ward], [street_address], "
                + "[pickup_address], [return_address], [id_card_number], [tax_code], [id_card_front_url], "
                + "[id_card_back_url], [shop_description], [shop_logo_url], [shop_banner_url], "
                + "[bank_name], [bank_account_number], [bank_account_holder], [status], [created_at]"
                + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', GETDATE())";

        // Sử dụng try-with-resources để tự động đóng Connection và PreparedStatement, 
        // gọi hàm getConnection() được kế thừa từ DBContext
        try (Connection conn = this.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // Kiểm tra phòng hờ nếu kết nối bị null
            if (conn == null) {
                System.err.println(">>> Không thể kết nối tới Database!");
                return false;
            }

            ps.setInt(1, req.getUserId());
            ps.setString(2, req.getShopName());
            ps.setString(3, req.getBusinessType());
            ps.setString(4, req.getProvince());
            ps.setString(5, req.getDistrict());
            ps.setString(6, req.getWard());
            ps.setString(7, req.getStreetAddress());
            ps.setString(8, req.getPickupAddress());
            ps.setString(9, req.getReturnAddress());
            ps.setString(10, req.getIdCardNumber());
            ps.setString(11, req.getTaxCode());
            ps.setString(12, req.getIdCardFrontUrl());
            ps.setString(13, req.getIdCardBackUrl());
            ps.setString(14, req.getShopDescription());
            ps.setString(15, req.getShopLogoUrl());
            ps.setString(16, req.getShopBannerUrl());
            ps.setString(17, req.getBankName());
            ps.setString(18, req.getBankAccountNumber());
            ps.setString(19, req.getBankAccountHolder());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}