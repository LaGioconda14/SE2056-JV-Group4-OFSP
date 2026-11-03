package service.impl;

import dao.OrderFulfillmentDAO;
import java.util.List;
import model.SubOrder;
import enums.SubOrderStatus;
import service.IOrderFulfillmentService;

public class OrderFulfillmentServiceImpl implements IOrderFulfillmentService {

    private final OrderFulfillmentDAO fulfillmentDAO = new OrderFulfillmentDAO();

    @Override
    public SubOrder getSubOrderDetails(String subOrderCode) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return null;
        }
        return fulfillmentDAO.getSubOrderDetails(subOrderCode.trim());
    }

    @Override
    public String getFirstSubOrderCode(long shopId) {
        return fulfillmentDAO.getFirstSubOrderCode(shopId);
    }

    @Override
    public boolean cancelSubOrder(String subOrderCode, String cancelReason, Long cancelledBy) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return false;
        }
        return fulfillmentDAO.cancelSubOrder(subOrderCode.trim(), cancelReason, cancelledBy);
    }

    @Override
    public boolean cancelSubOrderWithRestock(String subOrderCode, String cancelReason, Long cancelledBy) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return false;
        }
        return fulfillmentDAO.cancelSubOrderWithRestock(subOrderCode.trim(), cancelReason, cancelledBy);
    }

    @Override
    public boolean cancelSubOrderOutOfStock(String subOrderCode, String cancelReason, Long cancelledBy) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return false;
        }
        return fulfillmentDAO.cancelSubOrderOutOfStock(subOrderCode.trim(), cancelReason, cancelledBy);
    }

    @Override
    public boolean processReturnedOrderRestock(String subOrderCode, String note, Long processedBy) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty()) {
            return false;
        }
        return fulfillmentDAO.processReturnedOrderRestock(subOrderCode.trim(), note, processedBy);
    }

    @Override
    public boolean updateSubOrderStatus(String subOrderCode, SubOrderStatus newStatus) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty() || newStatus == null) {
            return false;
        }
        return fulfillmentDAO.updateSubOrderStatus(subOrderCode.trim(), newStatus);
    }

    @Override
    public boolean isSubOrderOwnedByShop(long subOrderId, long shopId) {
        return fulfillmentDAO.isSubOrderOwnedByShop(subOrderId, shopId);
    }

    @Override
    public List<SubOrder> getSubOrdersByShop(long shopId, SubOrderStatus status, String keyword) {
        return fulfillmentDAO.getSubOrdersByShop(shopId, status, keyword);
    }

    @Override
    public int countSubOrdersByShop(long shopId, SubOrderStatus status) {
        return fulfillmentDAO.countSubOrdersByShop(shopId, status);
    }
}
