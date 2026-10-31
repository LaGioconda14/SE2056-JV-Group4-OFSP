package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.ShopRequest;
import util.DBContext;

public class ShopRequestDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(ShopRequestDAO.class.getName());

    public boolean insertShopRequest(ShopRequest req) {
        String sql = "INSERT INTO [dbo].[shop_requests] ("
                + "[user_id], [shop_name], [business_type], [province], [district], [ward], [street_address], "
                + "[pickup_address], [return_address], [id_card_number], [tax_code], [id_card_front_url], "
                + "[id_card_back_url], [shop_description], [shop_logo_url], [shop_banner_url], "
                + "[bank_name], [bank_account_number], [bank_account_holder], [status], [created_at]"
                + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', GETDATE())";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

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
            LOGGER.log(Level.SEVERE, "Error inserting shop request for userId: " + req.getUserId(), e);
        }
        return false;
    }

    public ShopRequest getLatestRequestByUserId(int userId) {
        return getShopRequestByUserId(userId);
    }

    public ShopRequest getShopRequestByUserId(int userId) {
        String sql = "SELECT TOP 1 * FROM [dbo].[shop_requests] WHERE [user_id] = ? ORDER BY [request_id] DESC";

        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {

            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToShopRequest(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting shop request for userId: " + userId, e);
        }
        return null;
    }

    public boolean updateShopProfile(ShopRequest shop) {
        String sql = "UPDATE [dbo].[shop_requests] SET "
                + "[shop_name] = ?, [business_type] = ?, [shop_description] = ?, "
                + "[id_card_number] = ?, [tax_code] = ?, [province] = ?, [district] = ?, [ward] = ?, "
                + "[street_address] = ?, [pickup_address] = ?, [return_address] = ?, "
                + "[bank_name] = ?, [bank_account_number] = ?, [bank_account_holder] = ?, "
                + "[shop_logo_url] = COALESCE(?, [shop_logo_url]), "
                + "[shop_banner_url] = COALESCE(?, [shop_banner_url]) "
                + "WHERE [user_id] = ?";

        try (Connection conn = getConnection();
             PreparedStatement st = conn.prepareStatement(sql)) {

            st.setString(1, shop.getShopName());
            st.setString(2, shop.getBusinessType());
            st.setString(3, shop.getShopDescription());
            st.setString(4, shop.getIdCardNumber());
            st.setString(5, shop.getTaxCode());
            st.setString(6, shop.getProvince());
            st.setString(7, shop.getDistrict());
            st.setString(8, shop.getWard());
            st.setString(9, shop.getStreetAddress());
            st.setString(10, shop.getPickupAddress());
            st.setString(11, shop.getReturnAddress());
            st.setString(12, shop.getBankName());
            st.setString(13, shop.getBankAccountNumber());
            st.setString(14, shop.getBankAccountHolder());
            st.setString(15, shop.getShopLogoUrl());
            st.setString(16, shop.getShopBannerUrl());
            st.setInt(17, shop.getUserId());

            return st.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating shop profile for userId: " + shop.getUserId(), e);
        }
        return false;
    }

    private ShopRequest mapResultSetToShopRequest(ResultSet rs) throws SQLException {
        ShopRequest shop = new ShopRequest();
        shop.setRequestId(rs.getInt("request_id"));
        shop.setUserId(rs.getInt("user_id"));
        shop.setShopName(rs.getString("shop_name"));
        shop.setBusinessType(rs.getString("business_type"));
        shop.setProvince(rs.getString("province"));
        shop.setDistrict(rs.getString("district"));
        shop.setWard(rs.getString("ward"));
        shop.setStreetAddress(rs.getString("street_address"));
        shop.setPickupAddress(rs.getString("pickup_address"));
        shop.setReturnAddress(rs.getString("return_address"));
        shop.setIdCardNumber(rs.getString("id_card_number"));
        shop.setTaxCode(rs.getString("tax_code"));
        shop.setIdCardFrontUrl(rs.getString("id_card_front_url"));
        shop.setIdCardBackUrl(rs.getString("id_card_back_url"));
        shop.setShopDescription(rs.getString("shop_description"));
        shop.setShopLogoUrl(rs.getString("shop_logo_url"));
        shop.setShopBannerUrl(rs.getString("shop_banner_url"));
        shop.setBankName(rs.getString("bank_name"));
        shop.setBankAccountNumber(rs.getString("bank_account_number"));
        shop.setBankAccountHolder(rs.getString("bank_account_holder"));
        shop.setStatus(rs.getString("status"));
        shop.setReason(rs.getString("reason"));
        shop.setReviewedAt(rs.getTimestamp("reviewed_at"));
        shop.setCreatedAt(rs.getTimestamp("created_at"));
        return shop;
    }
}
