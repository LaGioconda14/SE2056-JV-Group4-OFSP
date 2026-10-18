package service.impl;

import dao.OrderFulfillmentDAO;
import java.util.List;
import model.SubOrder;
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
    public boolean updateSubOrderStatus(String subOrderCode, String newStatus) {
        if (subOrderCode == null || subOrderCode.trim().isEmpty() || newStatus == null || newStatus.trim().isEmpty()) {
            return false;
        }
        return fulfillmentDAO.updateSubOrderStatus(subOrderCode.trim(), newStatus.trim());
    }

    @Override
    public boolean isSubOrderOwnedByShop(long subOrderId, long shopId) {
        return fulfillmentDAO.isSubOrderOwnedByShop(subOrderId, shopId);
    }

    @Override
    public List<SubOrder> getSubOrdersByShop(long shopId, String status, String keyword) {
        return fulfillmentDAO.getSubOrdersByShop(shopId, status, keyword);
    }

    @Override
    public int countSubOrdersByShop(long shopId, String status) {
        return fulfillmentDAO.countSubOrdersByShop(shopId, status);
    }
}

