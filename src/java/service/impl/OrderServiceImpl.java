package service.impl;

import dao.OrderDAO;
import java.util.List;
import model.Order;
import service.IOrderService;

public class OrderServiceImpl implements IOrderService {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    public List<Order> getOrdersByCustomerId(long customerId) {
        return orderDAO.getOrdersByCustomerId(customerId);
    }
}

