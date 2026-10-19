package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Dispute;
import util.DBContext;

public class DisputeDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(DisputeDAO.class.getName());

    /**
     * Create a new Return / Dispute request from a Customer
     */
    public boolean createDispute(Dispute dispute) {
        String insertSql = "INSERT INTO disputes (dispute_code, sub_order_id, customer_id, shop_id, reason_category, "
            + "                   complaint_text, claim_amount, evidence_image_url, status, created_at) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OPEN', CURRENT_TIMESTAMP)";

        Connection conn = getConnection();
        if (conn == null) return false;

        try (conn) {
            // Defensive lookup: ensure valid sub_order_id and shop_id if order_id was provided
            long actualSubOrderId = dispute.getSubOrderId();
            long actualShopId = dispute.getShopId();

            String lookupSql = "SELECT TOP 1 sub_order_id, shop_id FROM sub_orders "
                             + "WHERE sub_order_id = ? OR order_id = ? "
                             + "ORDER BY CASE WHEN sub_order_id = ? THEN 0 ELSE 1 END";
            try (PreparedStatement psLookup = conn.prepareStatement(lookupSql)) {
                psLookup.setLong(1, dispute.getSubOrderId());
                psLookup.setLong(2, dispute.getSubOrderId());
                psLookup.setLong(3, dispute.getSubOrderId());
                try (ResultSet rsLookup = psLookup.executeQuery()) {
                    if (rsLookup.next()) {
                        actualSubOrderId = rsLookup.getLong("sub_order_id");
                        if (actualShopId <= 0) {
                            actualShopId = rsLookup.getLong("shop_id");
                        }
                    }
                }
            } catch (SQLException ignore) {
            }

            dispute.setSubOrderId(actualSubOrderId);
            dispute.setShopId(actualShopId > 0 ? actualShopId : 1);

            String code = dispute.getDisputeCode();
            if (code == null || code.trim().isEmpty()) {
                code = "DIS-" + System.currentTimeMillis() % 1000000;
                dispute.setDisputeCode(code);
            }

            int rows;
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, code);
                ps.setLong(2, dispute.getSubOrderId());
                ps.setLong(3, dispute.getCustomerId());
                ps.setLong(4, dispute.getShopId());
                ps.setNString(5, dispute.getReasonCategory() != null ? dispute.getReasonCategory() : "Yêu cầu Trả hàng / Hoàn tiền");
                ps.setNString(6, dispute.getComplaintText() != null ? dispute.getComplaintText() : "");
                ps.setBigDecimal(7, dispute.getClaimAmount() != null ? dispute.getClaimAmount() : BigDecimal.ZERO);
                ps.setString(8, dispute.getEvidenceImageUrl());
                rows = ps.executeUpdate();
            }

            if (rows > 0) {
                // Update sub_order status to RETURNED
                String updateSub = "UPDATE sub_orders SET status = 'RETURNED', cancel_reason = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_id = ?";
                try (PreparedStatement psSub = conn.prepareStatement(updateSub)) {
                    psSub.setNString(1, dispute.getReasonCategory() + ": " + dispute.getComplaintText());
                    psSub.setLong(2, dispute.getSubOrderId());
                    psSub.executeUpdate();
                }

                // Update parent order status to RETURNED
                String updateOrd = "UPDATE o SET o.order_status = 'RETURNED', o.updated_at = CURRENT_TIMESTAMP "
                    + "FROM orders o JOIN sub_orders so ON o.order_id = so.order_id WHERE so.sub_order_id = ?";
                try (PreparedStatement psOrd = conn.prepareStatement(updateOrd)) {
                    psOrd.setLong(1, dispute.getSubOrderId());
                    psOrd.executeUpdate();
                }
                return true;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating dispute for sub_order " + dispute.getSubOrderId(), ex);
        }
        return false;
    }

    /**
     * Get dispute details by SubOrder ID or Order ID
     */
    public Dispute getDisputeBySubOrderId(long subOrderId) {
        String sql = "SELECT d.dispute_id, d.dispute_code, d.sub_order_id, d.customer_id, d.shop_id, "
            + "       d.reason_category, d.complaint_text, d.claim_amount, d.evidence_image_url, "
            + "       d.status, d.resolution_decision, d.resolution_note, d.resolved_by, d.resolved_at, d.created_at, "
            + "       so.sub_order_code, s.shop_name, u.full_name AS customer_name, u.phone AS customer_phone "
            + "FROM disputes d "
            + "JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
            + "LEFT JOIN shops s ON d.shop_id = s.shop_id "
            + "LEFT JOIN users u ON d.customer_id = u.user_id "
            + "WHERE (d.sub_order_id = ? OR so.order_id = ?) "
            + "ORDER BY d.dispute_id DESC";

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, subOrderId);
            ps.setLong(2, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractDisputeFromResultSet(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting dispute by subOrderId " + subOrderId, ex);
        }
        return null;
    }

    /**
     * Get dispute details by Dispute Code (e.g. DIS-892)
     */
    public Dispute getDisputeByCode(String disputeCode) {
        String sql = "SELECT d.dispute_id, d.dispute_code, d.sub_order_id, d.customer_id, d.shop_id, "
            + "       d.reason_category, d.complaint_text, d.claim_amount, d.evidence_image_url, "
            + "       d.status, d.resolution_decision, d.resolution_note, d.resolved_by, d.resolved_at, d.created_at, "
            + "       so.sub_order_code, s.shop_name, u.full_name AS customer_name, u.phone AS customer_phone "
            + "FROM disputes d "
            + "JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
            + "LEFT JOIN shops s ON d.shop_id = s.shop_id "
            + "LEFT JOIN users u ON d.customer_id = u.user_id "
            + "WHERE d.dispute_code = ?";

        Connection conn = getConnection();
        if (conn == null) return null;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, disputeCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractDisputeFromResultSet(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting dispute by code " + disputeCode, ex);
        }
        return null;
    }

    /**
     * Get list of disputes submitted by a Customer
     */
    public List<Dispute> getDisputesByCustomerId(long customerId) {
        List<Dispute> list = new ArrayList<>();
        String sql = "SELECT d.dispute_id, d.dispute_code, d.sub_order_id, d.customer_id, d.shop_id, "
            + "       d.reason_category, d.complaint_text, d.claim_amount, d.evidence_image_url, "
            + "       d.status, d.resolution_decision, d.resolution_note, d.resolved_by, d.resolved_at, d.created_at, "
            + "       so.sub_order_code, s.shop_name, u.full_name AS customer_name, u.phone AS customer_phone "
            + "FROM disputes d "
            + "JOIN sub_orders so ON d.sub_order_id = so.sub_order_id "
            + "LEFT JOIN shops s ON d.shop_id = s.shop_id "
            + "LEFT JOIN users u ON d.customer_id = u.user_id "
            + "WHERE d.customer_id = ? "
            + "ORDER BY d.dispute_id DESC";

        Connection conn = getConnection();
        if (conn == null) return list;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractDisputeFromResultSet(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting disputes for customer " + customerId, ex);
        }
        return list;
    }

    private Dispute extractDisputeFromResultSet(ResultSet rs) throws SQLException {
        Dispute d = new Dispute();
        d.setDisputeId(rs.getLong("dispute_id"));
        d.setDisputeCode(rs.getString("dispute_code"));
        d.setSubOrderId(rs.getLong("sub_order_id"));
        d.setCustomerId(rs.getLong("customer_id"));
        d.setShopId(rs.getLong("shop_id"));
        d.setReasonCategory(rs.getString("reason_category"));
        d.setComplaintText(rs.getString("complaint_text"));
        d.setClaimAmount(rs.getBigDecimal("claim_amount"));
        d.setEvidenceImageUrl(rs.getString("evidence_image_url"));
        d.setStatus(rs.getString("status"));
        d.setResolutionDecision(rs.getString("resolution_decision"));
        d.setResolutionNote(rs.getString("resolution_note"));
        d.setResolvedBy(rs.getLong("resolved_by"));
        d.setResolvedAt(rs.getTimestamp("resolved_at"));
        d.setCreatedAt(rs.getTimestamp("created_at"));
        d.setUpdatedAt(rs.getTimestamp("created_at"));

        d.setSubOrderCode(rs.getString("sub_order_code"));
        d.setShopName(rs.getString("shop_name"));
        d.setCustomerName(rs.getString("customer_name"));
        d.setCustomerPhone(rs.getString("customer_phone"));
        return d;
    }
}
