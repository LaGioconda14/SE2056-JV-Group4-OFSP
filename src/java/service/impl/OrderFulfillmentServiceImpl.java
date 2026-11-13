package service.impl;

import dao.OrderFulfillmentDAO;
import java.util.List;
import model.dto.order.SubOrderDTO;
import model.dto.order.SubOrderDetailDTO;
import enums.SubOrderStatus;
import service.IOrderFulfillmentService;

/**
 * Triển khai nghiệp vụ thực hiện và hoàn tất đơn hàng phía người bán (IOrderFulfillmentService):
 * - Tra cứu chi tiết đơn hàng con.
 * - Cập nhật quy trình xử lý đơn (chặn xác nhận nếu đơn trực tuyến chưa thanh toán).
 * - Hoàn trả tồn kho khi hủy đơn hoặc trả hàng.
 */
public class OrderFulfillmentServiceImpl implements IOrderFulfillmentService {

    private final OrderFulfillmentDAO fulfillmentDAO = new OrderFulfillmentDAO();

    /**
     * Lấy thông tin chi tiết của một đơn hàng con theo mã subOrderCode.
     *
     * @param subOrderCode mã đơn con
     * @return SubOrderDetailDTO hoặc null nếu mã rỗng
     */
    @Override
    public SubOrderDetailDTO getSubOrderDetails(String subOrderCode) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return null;
        }
        return fulfillmentDAO.getSubOrderDetails(subOrderCode.trim());
    }

    /**
     * Hủy đơn hàng con và tự động hoàn trả số lượng sản phẩm vào kho của shop.
     *
     * @param subOrderCode mã đơn con
     * @param cancelReason lý do hủy
     * @param cancelledBy  ID tài khoản người hủy
     * @return true nếu hủy thành công
     */
    @Override
    public boolean cancelSubOrderWithRestock(String subOrderCode, String cancelReason, Long cancelledBy) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return false;
        }
        return fulfillmentDAO.cancelSubOrderWithRestock(subOrderCode.trim(), cancelReason, cancelledBy);
    }

    /**
     * Xử lý nhập lại kho đối với đơn giao không thành công hoặc khách trả hàng.
     *
     * @param subOrderCode mã đơn con
     * @param note         ghi chú nhận xét hàng hoàn
     * @param processedBy  ID tài khoản người xử lý
     * @return true nếu ghi nhận hoàn kho thành công
     */
    @Override
    public boolean processReturnedOrderRestock(String subOrderCode, String note, Long processedBy) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return false;
        }
        return fulfillmentDAO.processReturnedOrderRestock(subOrderCode.trim(), note, processedBy);
    }

    /**
     * Cập nhật trạng thái đơn hàng con.
     * Quy tắc nghiệp vụ: Không cho phép chuyển sang trạng thái xác nhận, đóng gói hoặc giao hàng
     * nếu đơn hàng thanh toán trực tuyến (VNPAY/Card) chưa hoàn tất thanh toán.
     *
     * @param subOrderCode mã đơn con
     * @param newStatus    trạng thái mới
     * @return true nếu cập nhật thành công, false nếu vi phạm điều kiện thanh toán hoặc lỗi
     */
    @Override
    public boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty() || newStatus == null) {
            return false;
        }
        // Không cho phép xác nhận / đóng gói / giao hàng nếu đơn thanh toán trực tuyến chưa hoàn tất thanh toán
        if (newStatus != SubOrderStatus.CANCELLED && newStatus != SubOrderStatus.NEW && newStatus != SubOrderStatus.FAILED) {
            SubOrderDetailDTO details = fulfillmentDAO.getSubOrderDetails(subOrderCode.trim());
            if (details != null && details.isWaitingOnlinePayment()) {
                return false;
            }
        }
        return fulfillmentDAO.updateSubOrderStatus(subOrderCode.trim(), newStatus);
    }

    /**
     * Lấy danh sách các đơn con của một shop có phân trang/lọc theo trạng thái và tìm kiếm theo từ khóa.
     *
     * @param shopId  ID cửa hàng
     * @param status  trạng thái lọc
     * @param keyword từ khóa tìm kiếm
     * @return danh sách đơn con
     */
    @Override
    public List<SubOrderDTO> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword) {
        return fulfillmentDAO.getSubOrdersByShop(shopId, status, keyword);
    }

    /**
     * Đếm tổng số lượng đơn hàng con của shop theo trạng thái.
     *
     * @param shopId ID cửa hàng
     * @param status trạng thái lọc
     * @return số lượng đơn con
     */
    @Override
    public int countSubOrdersByShop(long shopId, SubOrderStatus status) {
        return fulfillmentDAO.countSubOrdersByShop(shopId, status);
    }
}
