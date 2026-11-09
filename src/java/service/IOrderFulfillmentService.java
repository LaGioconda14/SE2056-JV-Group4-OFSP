package service;

import java.util.List;
import model.dto.order.SubOrderDTO;
import model.dto.order.SubOrderDetailDTO;
import enums.SubOrderStatus;

public interface IOrderFulfillmentService {

    SubOrderDetailDTO getSubOrderDetails(String subOrderCode);

    boolean cancelSubOrderWithRestock(String subOrderCode, String cancelReason, Long cancelledBy);

    boolean processReturnedOrderRestock(String subOrderCode, String note, Long processedBy);

    boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus);

    List<SubOrderDTO> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword);

    int countSubOrdersByShop(long shopId, SubOrderStatus status);
}
