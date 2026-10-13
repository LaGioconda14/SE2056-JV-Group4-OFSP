package service;

import java.util.List;
import model.Order;

public interface IOrderService {

    List<Order> getOrdersByCustomerId(long customerId);
}

