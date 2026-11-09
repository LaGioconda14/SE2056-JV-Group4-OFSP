package service;

import java.util.List;
import model.SubOrder;
import enums.SubOrderStatus;

public interface IOrderFulfillmentService {

    SubOrder getSubOrderDetails(String subOrderCode);

    boolean cancelSubOrderWithRestock(String subOrderCode, String cancelReason, Long cancelledBy);

    boolean processReturnedOrderRestock(String subOrderCode, String note, Long processedBy);

    boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus);

    List<SubOrder> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword);

    int countSubOrdersByShop(long shopId, SubOrderStatus status);
}
