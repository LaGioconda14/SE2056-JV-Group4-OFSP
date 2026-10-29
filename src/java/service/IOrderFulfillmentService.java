package service;

import java.util.List;
import model.SubOrder;
import enums.SubOrderStatus;

public interface IOrderFulfillmentService {

    SubOrder getSubOrderDetails(String subOrderCode);

    String getFirstSubOrderCode(long shopId);

    boolean cancelSubOrder(String subOrderCode, String cancelReason, Long cancelledBy);

    boolean cancelSubOrderWithRestock(String subOrderCode, String cancelReason, Long cancelledBy);

    boolean cancelSubOrderOutOfStock(String subOrderCode, String cancelReason, Long cancelledBy);

    boolean processReturnedOrderRestock(String subOrderCode, String note, Long processedBy);

    boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus);

    boolean isSubOrderOwnedByShop(long subOrderId, long shopId);

    List<SubOrder> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword);

    int countSubOrdersByShop(long shopId, SubOrderStatus status);
}
