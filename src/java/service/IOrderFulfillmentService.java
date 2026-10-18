package service;

import java.util.List;
import model.SubOrder;

public interface IOrderFulfillmentService {

    SubOrder getSubOrderDetails(String subOrderCode);

    String getFirstSubOrderCode(long shopId);

    boolean cancelSubOrder(String subOrderCode, String cancelReason, Long cancelledBy);

    boolean updateSubOrderStatus(String subOrderCode, String newStatus);

    boolean isSubOrderOwnedByShop(long subOrderId, long shopId);

    List<SubOrder> getSubOrdersByShop(long shopId, String status, String keyword);

    int countSubOrdersByShop(long shopId, String status);
}

