package service;

import java.util.List;
import model.dto.order.SubOrderDTO;
import model.dto.order.SubOrderDetailDTO;
import enums.SubOrderStatus;

/**
 * Interface định nghĩa các nghiệp vụ xử lý và hoàn tất đơn hàng (Fulfillment) phía người bán (Shop):
 * - Xem chi tiết đơn hàng con (sub-order).
 * - Cập nhật trạng thái xử lý đơn (xác nhận, đóng gói, giao hàng, hủy...).
 * - Xử lý hoàn kho khi hủy đơn hoặc hàng hoàn trả.
 */
public interface IOrderFulfillmentService {

    /**
     * Lấy thông tin chi tiết của một đơn hàng con theo mã subOrderCode.
     *
     * @param subOrderCode mã định danh của đơn con (ví dụ: SO-xxxx)
     * @return SubOrderDetailDTO chứa sản phẩm, khách hàng, địa chỉ, trạng thái
     */
    SubOrderDetailDTO getSubOrderDetails(String subOrderCode);

    /**
     * Hủy đơn hàng con và hoàn lại số lượng tồn kho cho các sản phẩm trong đơn.
     *
     * @param subOrderCode mã đơn con
     * @param cancelReason lý do hủy
     * @param cancelledBy  ID người thực hiện hủy
     * @return true nếu hủy và hoàn kho thành công
     */
    boolean cancelSubOrderWithRestock(String subOrderCode, String cancelReason, Long cancelledBy);

    /**
     * Xử lý nhập lại kho đối với đơn hàng bị hoàn trả (giao không thành công / khách trả hàng).
     *
     * @param subOrderCode mã đơn con
     * @param note         ghi chú khi nhập hoàn kho
     * @param processedBy  ID người xử lý
     * @return true nếu cập nhật thành công
     */
    boolean processReturnedOrderRestock(String subOrderCode, String note, Long processedBy);

    /**
     * Cập nhật trạng thái của đơn hàng con (chuẩn bị hàng, gửi vận chuyển, hoàn thành...).
     *
     * @param subOrderCode mã đơn con
     * @param newStatus    trạng thái mới cần chuyển sang
     * @return true nếu cập nhật thành công
     */
    boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus);

    /**
     * Lấy danh sách các đơn hàng con thuộc một shop theo bộ lọc trạng thái và từ khóa tìm kiếm.
     *
     * @param shopId  ID cửa hàng
     * @param status  trạng thái cần lọc (null nếu lấy tất cả)
     * @param keyword từ khóa tìm kiếm (mã đơn, tên khách...)
     * @return danh sách SubOrderDTO
     */
    List<SubOrderDTO> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword);

    /**
     * Đếm tổng số đơn hàng con của shop theo trạng thái.
     *
     * @param shopId ID cửa hàng
     * @param status trạng thái cần đếm (null nếu đếm tất cả)
     * @return số lượng đơn
     */
    int countSubOrdersByShop(long shopId, SubOrderStatus status);
}

