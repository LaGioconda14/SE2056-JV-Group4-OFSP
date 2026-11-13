package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.dto.order.DeliveryDTO;
import model.dto.order.OrderItemFulfillmentDTO;
import model.dto.order.SubOrderDTO;
import model.dto.order.SubOrderDetailDTO;
import model.entity.order.ShippingAddress;
import enums.SubOrderStatus;
import enums.OrderStatus;
import util.DBContext;

/**
 * DAO xử lý các thao tác hoàn tất đơn hàng (Fulfillment) cho người bán (Shop):
 * - Tra cứu chi tiết đơn hàng con (sub_order) kèm thông tin giao hàng, tài xế và sản phẩm.
 * - Cập nhật trạng thái đơn con và tự động đồng bộ trạng thái đơn cha (orders).
 * - Hủy đơn con và hoàn trả tồn kho sản phẩm.
 * - Xử lý nhập lại kho đối với đơn giao thất bại hoặc trả hàng.
 */
public class OrderFulfillmentDAO extends DBContext {

    private static final Logger LOGGER = Logger.getLogger(OrderFulfillmentDAO.class.getName());
    private final PromotionDAO promotionDAO = new PromotionDAO();

    /**
     * Lấy thông tin chi tiết một đơn con theo subOrderCode.
     *
     * @param subOrderCode mã đơn con
     * @return SubOrderDetailDTO hoặc null nếu không tìm thấy
     */
    public SubOrderDetailDTO getSubOrderDetails(String subOrderCode) {
        String sql = "SELECT so.sub_order_id, so.sub_order_code, so.order_id, so.shop_id, so.delivery_slot, "
                + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                + "       so.status, so.cancel_reason, so.cancelled_at, so.created_at, so.updated_at, "
                + "       s.shop_name, "
                + "       o.order_code, o.payment_status, o.payment_method, o.created_at AS order_created_at, "
                + "       u.full_name AS customer_name, u.phone AS customer_phone, "
                + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city, "
                + "       d.tracking_number, d.delivery_status, d.failure_reason, d.proof_image_url, d.delivered_at, "
                + "       d.driver_id, "
                + "       u_driver.full_name AS driver_name, u_driver.phone AS driver_phone, u_driver.avatar_url AS driver_avatar, "
                + "       dp.vehicle_plate AS driver_vehicle_plate, dp.vehicle_type AS driver_vehicle_type "
                + "FROM sub_orders so "
                + "JOIN orders o ON so.order_id = o.order_id "
                + "LEFT JOIN shops s ON so.shop_id = s.shop_id "
                + "LEFT JOIN users u ON o.customer_id = u.user_id "
                + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                + "LEFT JOIN deliveries d ON so.sub_order_id = d.sub_order_id "
                + "LEFT JOIN users u_driver ON d.driver_id = u_driver.user_id "
                + "LEFT JOIN driver_profiles dp ON dp.user_id = d.driver_id "
                + "WHERE so.sub_order_code = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return null;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subOrderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SubOrderDetailDTO so = new SubOrderDetailDTO();
                    so.setSubOrderId(rs.getLong("sub_order_id"));
                    so.setSubOrderCode(rs.getString("sub_order_code"));
                    so.setOrderId(rs.getLong("order_id"));
                    so.setOrderCode(rs.getString("order_code"));
                    so.setShopId(rs.getLong("shop_id"));
                    so.setShopName(rs.getString("shop_name"));
                    so.setDeliverySlot(rs.getString("delivery_slot"));
                    so.setShopSubtotal(rs.getBigDecimal("shop_subtotal"));
                    so.setShopShippingFee(rs.getBigDecimal("shop_shipping_fee"));
                    so.setShopDiscount(rs.getBigDecimal("shop_discount"));
                    so.setShopTotal(rs.getBigDecimal("shop_total"));
                    so.setStatus(rs.getString("status"));
                    so.setCancelReason(rs.getString("cancel_reason"));
                    so.setCancelledAt(rs.getTimestamp("cancelled_at"));
                    so.setPaymentMethod(rs.getString("payment_method"));
                    so.setPaymentStatus(rs.getString("payment_status"));
                    so.setCreatedAt(rs.getTimestamp("created_at"));
                    so.setUpdatedAt(rs.getTimestamp("updated_at"));
                    so.setOrderCreatedAt(rs.getTimestamp("order_created_at"));
                    so.setCustomerName(rs.getString("customer_name"));
                    so.setCustomerPhone(rs.getString("customer_phone"));

                    DeliveryDTO delivery = new DeliveryDTO();
                    delivery.setTrackingNumber(rs.getString("tracking_number"));
                    delivery.setDeliveryStatus(rs.getString("delivery_status"));
                    delivery.setFailureReason(rs.getString("failure_reason"));
                    delivery.setProofImageUrl(rs.getString("proof_image_url"));
                    delivery.setDeliveredAt(rs.getTimestamp("delivered_at"));
                    delivery.setDriverId(rs.getObject("driver_id") != null ? rs.getLong("driver_id") : null);
                    delivery.setDriverName(rs.getString("driver_name"));
                    delivery.setDriverPhone(rs.getString("driver_phone"));
                    delivery.setDriverAvatarUrl(rs.getString("driver_avatar"));
                    delivery.setDriverVehiclePlate(rs.getString("driver_vehicle_plate"));
                    delivery.setDriverVehicleType(rs.getString("driver_vehicle_type"));
                    so.setDelivery(delivery);

                    // Shipping Address
                    ShippingAddress addr = new ShippingAddress();
                    addr.setOrderId(rs.getLong("order_id"));
                    addr.setRecipientName(rs.getString("recipient_name"));
                    addr.setRecipientPhone(rs.getString("recipient_phone"));
                    addr.setStreetAddress(rs.getString("street_address"));
                    addr.setWard(rs.getString("ward"));
                    addr.setDistrict(rs.getString("district"));
                    addr.setCity(rs.getString("city"));
                    so.setShippingAddress(addr);

                    // Tái sử dụng cùng kết nối hiện tại để nạp danh sách sản phẩm
                    so.setItems(getOrderItemsBySubOrderId(conn, so.getSubOrderId()));
                    return so;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting suborder details for " + subOrderCode, ex);
        }
        return null;
    }

    /**
     * Lấy danh sách sản phẩm trong một đơn con theo subOrderId.
     *
     * @param subOrderId ID đơn con
     * @return danh sách OrderItemFulfillmentDTO
     */
    public List<OrderItemFulfillmentDTO> getOrderItemsBySubOrderId(long subOrderId) {
        Connection conn = getConnection();
        if (conn == null) {
            return Collections.emptyList();
        }
        try (conn) {
            return getOrderItemsBySubOrderId(conn, subOrderId);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting items for subOrderId " + subOrderId, ex);
            return Collections.emptyList();
        }
    }

    private List<OrderItemFulfillmentDTO> getOrderItemsBySubOrderId(Connection conn, long subOrderId) throws SQLException {
        List<OrderItemFulfillmentDTO> list = new ArrayList<>();
        String sql = "SELECT oi.order_item_id, oi.sub_order_id, oi.variant_id, pv.product_id, oi.product_name_snapshot, "
                + "       oi.variant_name_snapshot, oi.sku_snapshot, oi.unit, oi.unit_price, oi.quantity, oi.total_price, "
                + "       pv.stock_quantity, pv.weight_kg, "
                + "       p.origin, p.certification, p.storage_temp, "
                + "       (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = p.product_id ORDER BY pi.is_thumbnail DESC, pi.display_order ASC) AS image_url "
                + "FROM order_items oi "
                + "LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "LEFT JOIN products p ON pv.product_id = p.product_id "
                + "WHERE oi.sub_order_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, subOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItemFulfillmentDTO item = new OrderItemFulfillmentDTO();
                    item.setOrderItemId(rs.getLong("order_item_id"));
                    item.setSubOrderId(rs.getLong("sub_order_id"));
                    item.setVariantId(rs.getObject("variant_id") != null ? rs.getLong("variant_id") : null);
                    item.setProductId(rs.getObject("product_id") != null ? rs.getLong("product_id") : null);
                    item.setProductNameSnapshot(rs.getString("product_name_snapshot"));
                    item.setVariantNameSnapshot(rs.getString("variant_name_snapshot"));
                    item.setSkuSnapshot(rs.getString("sku_snapshot"));
                    item.setUnit(rs.getString("unit"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setTotalPrice(rs.getBigDecimal("total_price"));
                    item.setStockQuantity(rs.getInt("stock_quantity"));
                    item.setWeightKg(rs.getBigDecimal("weight_kg"));
                    item.setOrigin(rs.getString("origin"));
                    item.setCertification(rs.getString("certification"));
                    item.setStorageTemp(rs.getString("storage_temp"));
                    item.setImageUrl(rs.getString("image_url"));

                    list.add(item);
                }
            }
        }
        return list;
    }

    /**
     * Cập nhật trạng thái đơn hàng con và tự động đồng bộ trạng thái đơn hàng cha (orders):
     * - Khi đơn con chuyển sang SHIPPING -> đơn cha cập nhật thành SHIPPING.
     * - Khi tất cả các đơn con của đơn cha đều DELIVERED (hoặc CANCELLED/REFUNDED) -> đơn cha cập nhật thành COMPLETED.
     *
     * @param subOrderCode mã đơn con
     * @param newStatus    trạng thái mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus) {
        if (newStatus == null)
            return false;
        String sql = "UPDATE sub_orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_code = ?";
        Connection conn = getConnection();
        if (conn == null) {
            return false;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus.name());
            ps.setString(2, subOrderCode);
            int updated = ps.executeUpdate();
            if (updated > 0) {
                // Synchronize parent order status
                if (newStatus == SubOrderStatus.SHIPPING) {
                    String syncShipping = "UPDATE o SET o.order_status = '" + OrderStatus.SHIPPING.name()
                            + "', o.updated_at = CURRENT_TIMESTAMP "
                            + "FROM orders o JOIN sub_orders so ON o.order_id = so.order_id WHERE so.sub_order_code = ?";
                    try (PreparedStatement psSync = conn.prepareStatement(syncShipping)) {
                        psSync.setString(1, subOrderCode);
                        psSync.executeUpdate();
                    }
                } else if (newStatus == SubOrderStatus.DELIVERED) {
                    // Cập nhật đơn cha thành COMPLETED nếu tất cả các đơn con (trừ các đơn đã hủy/hoàn tiền) đều đã DELIVERED
                    String syncDelivered = "UPDATE o SET o.order_status = '" + OrderStatus.COMPLETED.name()
                            + "', o.updated_at = CURRENT_TIMESTAMP "
                            + "FROM orders o JOIN sub_orders so ON o.order_id = so.order_id "
                            + "WHERE so.sub_order_code = ? "
                            + "  AND NOT EXISTS (SELECT 1 FROM sub_orders other WHERE other.order_id = o.order_id "
                            + "                  AND other.status NOT IN ('" + SubOrderStatus.DELIVERED.name() + "', '"
                            + SubOrderStatus.CANCELLED.name() + "', 'REFUNDED'))";
                    try (PreparedStatement psSync = conn.prepareStatement(syncDelivered)) {
                        psSync.setString(1, subOrderCode);
                        psSync.executeUpdate();
                    }
                }
                return true;
            }
            return false;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating sub_orders status to " + newStatus, ex);
            return false;
        }
    }

    /**
     * Lấy danh sách các đơn con thuộc một shop kèm thông tin người nhận và sản phẩm, hỗ trợ lọc trạng thái và tìm kiếm.
     *
     * @param shopId  ID cửa hàng
     * @param status  trạng thái lọc
     * @param keyword từ khóa tìm kiếm (mã đơn, tên/sđt người nhận)
     * @return danh sách SubOrderDTO
     */
    public List<SubOrderDTO> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword) {
        List<SubOrderDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT so.sub_order_id, so.sub_order_code, so.order_id, so.shop_id, so.delivery_slot, "
                        + "       so.shop_subtotal, so.shop_shipping_fee, so.shop_discount, so.shop_total, "
                        + "       so.status, so.cancel_reason, so.created_at, so.updated_at, "
                        + "       o.order_code, o.payment_status, o.payment_method, "
                        + "       osa.recipient_name, osa.recipient_phone, osa.street_address, osa.ward, osa.district, osa.city "
                        + "FROM sub_orders so "
                        + "JOIN orders o ON so.order_id = o.order_id "
                        + "LEFT JOIN order_shipping_addresses osa ON o.order_id = osa.order_id "
                        + "WHERE 1=1 ");
        if (shopId > 0) {
            sql.append(" AND so.shop_id = ? ");
        }
        if (status != null) {
            sql.append(" AND so.status = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (so.sub_order_code LIKE ? OR o.order_code LIKE ? OR osa.recipient_name LIKE ? OR osa.recipient_phone LIKE ?) ");
        }
        sql.append(" ORDER BY so.created_at DESC");

        Connection conn = getConnection();
        if (conn == null)
            return list;

        try (conn; PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (shopId > 0) {
                ps.setLong(paramIndex++, shopId);
            }
            if (status != null) {
                ps.setString(paramIndex++, status.name());
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SubOrderDTO so = new SubOrderDTO();
                    so.setSubOrderId(rs.getLong("sub_order_id"));
                    so.setSubOrderCode(rs.getString("sub_order_code"));
                    so.setOrderId(rs.getLong("order_id"));
                    so.setOrderCode(rs.getString("order_code"));
                    so.setShopId(rs.getLong("shop_id"));
                    so.setDeliverySlot(rs.getString("delivery_slot"));
                    so.setShopSubtotal(rs.getBigDecimal("shop_subtotal"));
                    so.setShopShippingFee(rs.getBigDecimal("shop_shipping_fee"));
                    so.setShopDiscount(rs.getBigDecimal("shop_discount"));
                    so.setShopTotal(rs.getBigDecimal("shop_total"));
                    so.setStatus(rs.getString("status"));
                    so.setCancelReason(rs.getString("cancel_reason"));
                    so.setPaymentMethod(rs.getString("payment_method"));
                    so.setPaymentStatus(rs.getString("payment_status"));
                    so.setCreatedAt(rs.getTimestamp("created_at"));
                    so.setUpdatedAt(rs.getTimestamp("updated_at"));

                    ShippingAddress addr = new ShippingAddress();
                    addr.setRecipientName(rs.getString("recipient_name"));
                    addr.setRecipientPhone(rs.getString("recipient_phone"));
                    addr.setStreetAddress(rs.getString("street_address"));
                    addr.setWard(rs.getString("ward"));
                    addr.setDistrict(rs.getString("district"));
                    addr.setCity(rs.getString("city"));
                    so.setShippingAddress(addr);

                    // Tái sử dụng cùng kết nối hiện tại để nạp danh sách món, triệt tiêu N+1 Connection
                    so.setItems(new ArrayList<>(getOrderItemsBySubOrderId(conn, so.getSubOrderId())));
                    list.add(so);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting suborders for shop " + shopId, ex);
        }
        return list;
    }

    /**
     * Đếm tổng số đơn hàng con của shop theo trạng thái.
     *
     * @param shopId ID cửa hàng
     * @param status trạng thái lọc (null để đếm tất cả)
     * @return số lượng đơn
     */
    public int countSubOrdersByShop(long shopId, SubOrderStatus status) {
        boolean isAll = (status == null);

        String sql = isAll
                ? "SELECT COUNT(*) FROM sub_orders WHERE shop_id = ?"
                : "SELECT COUNT(*) FROM sub_orders WHERE shop_id = ? AND status = ?";

        Connection conn = getConnection();
        if (conn == null) {
            return 0;
        }

        try (conn; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shopId);
            if (!isAll) {
                ps.setString(2, status.name());
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting suborders for shop " + shopId, ex);
        }
        return 0;
    }
    /**
     * Hủy đơn hàng con và tự động hoàn trả số lượng vào tồn kho của biến thể:
     * - Cập nhật trạng thái CANCELLED, lưu lý do hủy và người hủy.
     * - Hoàn lại stock_quantity = stock_quantity + quantity cho từng sản phẩm trong đơn.
     *
     * @param subOrderCode mã đơn con
     * @param cancelReason lý do hủy
     * @param cancelledBy  ID tài khoản thực hiện hủy
     * @return true nếu hủy thành công
     */
    public boolean cancelSubOrderWithRestock(String subOrderCode, String cancelReason, Long cancelledBy) {
        Connection conn = getConnection();
        if (conn == null) return false;
        try (conn) {
            conn.setAutoCommit(false);
            boolean ok = cancelSubOrderInternal(conn, subOrderCode, cancelReason, cancelledBy);
            if (ok) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "Error cancelling sub order with restock: " + subOrderCode, e);
            return false;
        } finally {
            closeQuietly(conn);
        }
    }

    private boolean cancelSubOrderInternal(Connection conn, String subOrderCode, String cancelReason,
            Long cancelledBy) throws SQLException {
        String findSql = "SELECT sub_order_id, order_id, shop_id, status FROM sub_orders WHERE sub_order_code = ?";
        long subOrderId = -1;
        long parentOrderId = -1;
        long shopId = -1;
        String currentStatus = null;

        try (PreparedStatement psFind = conn.prepareStatement(findSql)) {
            psFind.setString(1, subOrderCode);
            try (ResultSet rs = psFind.executeQuery()) {
                if (rs.next()) {
                    subOrderId = rs.getLong("sub_order_id");
                    parentOrderId = rs.getLong("order_id");
                    shopId = rs.getLong("shop_id");
                    currentStatus = rs.getString("status");
                }
            }
        }

        if (subOrderId == -1 || SubOrderStatus.CANCELLED.name().equalsIgnoreCase(currentStatus)
                || SubOrderStatus.DELIVERED.name().equalsIgnoreCase(currentStatus)) {
            return false;
        }

        String cancelSql = "UPDATE sub_orders SET status = '" + SubOrderStatus.CANCELLED.name()
                + "', cancel_reason = ?, cancelled_by = ?, "
                + "       cancelled_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP "
                + "WHERE sub_order_id = ?";
        try (PreparedStatement psCancel = conn.prepareStatement(cancelSql)) {
            psCancel.setNString(1, cancelReason);
            if (cancelledBy != null) {
                psCancel.setLong(2, cancelledBy);
            } else {
                psCancel.setNull(2, java.sql.Types.BIGINT);
            }
            psCancel.setLong(3, subOrderId);
            int rows = psCancel.executeUpdate();
            if (rows <= 0) {
                return false;
            }
        }

        // 1. Hoàn trả 100% tồn kho bán vì hoa quả còn tươi nguyên
        String restoreSql = "UPDATE pv SET pv.stock_quantity = pv.stock_quantity + oi.quantity, pv.updated_at = CURRENT_TIMESTAMP "
                + "FROM product_variants pv "
                + "JOIN order_items oi ON pv.variant_id = oi.variant_id "
                + "WHERE oi.sub_order_id = ? AND oi.variant_id IS NOT NULL";
        try (PreparedStatement psRestock = conn.prepareStatement(restoreSql)) {
            psRestock.setLong(1, subOrderId);
            psRestock.executeUpdate();
        }
        // 2. Giải phóng quota Flash Sale / Khuyến mãi
        promotionDAO.releaseQuotaBySubOrder(conn, subOrderId);

        // 3. Hoàn lại lượt voucher shop của sub_order này (nếu có)
        String restoreShopVoucherSql = "UPDATE c SET c.used_count = CASE WHEN c.used_count > 0 THEN c.used_count - 1 ELSE 0 END "
                + "FROM coupons c INNER JOIN coupon_usages u ON u.coupon_id = c.coupon_id "
                + "WHERE u.order_id = ? AND c.shop_id = ?";
        try (PreparedStatement psVoucher = conn.prepareStatement(restoreShopVoucherSql)) {
            psVoucher.setLong(1, parentOrderId);
            psVoucher.setLong(2, shopId);
            psVoucher.executeUpdate();
        }
        String deleteShopUsageSql = "DELETE u FROM coupon_usages u "
                + "INNER JOIN coupons c ON u.coupon_id = c.coupon_id "
                + "WHERE u.order_id = ? AND c.shop_id = ?";
        try (PreparedStatement psDel = conn.prepareStatement(deleteShopUsageSql)) {
            psDel.setLong(1, parentOrderId);
            psDel.setLong(2, shopId);
            psDel.executeUpdate();
        }

        // 4. Đồng bộ trạng thái đơn cha (nếu tất cả đơn con đã CANCELLED)
        String checkOthersSql = "SELECT 1 FROM sub_orders WHERE order_id = ? AND status <> '" + SubOrderStatus.CANCELLED.name() + "'";
        boolean hasActiveSubOrders = false;
        try (PreparedStatement psCheck = conn.prepareStatement(checkOthersSql)) {
            psCheck.setLong(1, parentOrderId);
            try (ResultSet rsCheck = psCheck.executeQuery()) {
                hasActiveSubOrders = rsCheck.next();
            }
        }

        if (!hasActiveSubOrders) {
            String syncParentSql = "UPDATE orders SET order_status = '" + OrderStatus.CANCELLED.name()
                    + "', updated_at = CURRENT_TIMESTAMP WHERE order_id = ?";
            try (PreparedStatement psSync = conn.prepareStatement(syncParentSql)) {
                psSync.setLong(1, parentOrderId);
                psSync.executeUpdate();
            }

            // Hoàn tiếp voucher sàn (nếu có)
            String restorePlatformVoucherSql = "UPDATE c SET c.used_count = CASE WHEN c.used_count > 0 THEN c.used_count - 1 ELSE 0 END "
                    + "FROM coupons c INNER JOIN coupon_usages u ON u.coupon_id = c.coupon_id "
                    + "WHERE u.order_id = ? AND c.shop_id IS NULL";
            try (PreparedStatement psPV = conn.prepareStatement(restorePlatformVoucherSql)) {
                psPV.setLong(1, parentOrderId);
                psPV.executeUpdate();
            }
            String deletePlatformUsageSql = "DELETE u FROM coupon_usages u "
                    + "INNER JOIN coupons c ON u.coupon_id = c.coupon_id "
                    + "WHERE u.order_id = ? AND c.shop_id IS NULL";
            try (PreparedStatement psDelP = conn.prepareStatement(deletePlatformUsageSql)) {
                psDelP.setLong(1, parentOrderId);
                psDelP.executeUpdate();
            }
        }

        return true;
    }

    /**
     * Xử lý hoàn kho đối với đơn giao hàng thất bại hoặc khách trả hàng (trạng thái RETURNED):
     * - Hoàn lại tồn kho cho từng sản phẩm trong sub_order.
     * - Cập nhật trạng thái sub_order thành RETURNED kèm ghi chú.
     *
     * @param subOrderCode mã đơn con
     * @param note         ghi chú khi hoàn kho
     * @param processedBy  ID tài khoản người xử lý
     * @return true nếu xử lý hoàn kho thành công
     */
    public boolean processReturnedOrderRestock(String subOrderCode, String note, Long processedBy) {
        Connection conn = getConnection();
        if (conn == null) return false;
        try (conn) {
            conn.setAutoCommit(false);

            String checkSql = "SELECT cancel_reason FROM sub_orders WHERE sub_order_code = ?";
            String currentReason = "";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setString(1, subOrderCode);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        currentReason = rs.getString("cancel_reason");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (currentReason != null && currentReason.contains("[ĐÃ XỬ LÝ")) {
                conn.rollback();
                return true;
            }

            String updatedReason = (currentReason != null ? currentReason : "")
                    + " [ĐÃ XỬ LÝ NHẬP KHO: Hoa quả còn tươi nguyên, đã kiểm định và nhập lại kho"
                    + (note != null && !note.isBlank() ? " - " + note.trim() : "") + "]";

            String updateSubSql = "UPDATE sub_orders SET cancel_reason = ?, updated_at = CURRENT_TIMESTAMP WHERE sub_order_code = ?";
            try (PreparedStatement psUp = conn.prepareStatement(updateSubSql)) {
                psUp.setNString(1, updatedReason);
                psUp.setString(2, subOrderCode);
                psUp.executeUpdate();
            }

            String restockSql = "UPDATE pv SET pv.stock_quantity = pv.stock_quantity + oi.quantity, pv.updated_at = CURRENT_TIMESTAMP "
                    + "FROM product_variants pv "
                    + "JOIN order_items oi ON pv.variant_id = oi.variant_id "
                    + "JOIN sub_orders so ON oi.sub_order_id = so.sub_order_id "
                    + "WHERE so.sub_order_code = ? AND oi.variant_id IS NOT NULL";
            try (PreparedStatement psRestock = conn.prepareStatement(restockSql)) {
                psRestock.setString(1, subOrderCode);
                psRestock.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            LOGGER.log(Level.SEVERE, "Error restocking returned sub order: " + subOrderCode, e);
            return false;
        } finally {
            closeQuietly(conn);
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Rollback failed", ex);
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error closing connection", ex);
            }
        }
    }
}
