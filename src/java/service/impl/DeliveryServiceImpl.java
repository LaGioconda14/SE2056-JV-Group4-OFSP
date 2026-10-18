package service.impl;

import dao.DeliveryDAO;
import java.math.BigDecimal;
import java.util.List;
import model.Delivery;
import service.IDeliveryService;

public class DeliveryServiceImpl implements IDeliveryService {

    private final DeliveryDAO deliveryDAO = new DeliveryDAO();

    @Override
    public List<Delivery> getDeliveriesByDriver(long driverId, String statusFilter, String keyword) {
        return deliveryDAO.getDeliveriesByDriver(driverId, statusFilter, keyword);
    }

    @Override
    public Delivery getDeliveryById(long deliveryId, long driverId) {
        return deliveryDAO.getDeliveryById(deliveryId, driverId);
    }

    @Override
    public boolean confirmPickup(long deliveryId, long driverId) {
        return deliveryDAO.confirmPickup(deliveryId, driverId);
    }

    @Override
    public boolean completeDelivery(long deliveryId, long driverId, String proofImageUrl) {
        return deliveryDAO.completeDelivery(deliveryId, driverId, proofImageUrl);
    }

    @Override
    public boolean recordFailedDelivery(long deliveryId, long driverId, String failureReason) {
        return deliveryDAO.recordFailedDelivery(deliveryId, driverId, failureReason);
    }

    @Override
    public int countDeliveries(long driverId, String statusFilter) {
        return deliveryDAO.countDeliveries(driverId, statusFilter);
    }

    @Override
    public BigDecimal getTotalCodCollected(long driverId) {
        return deliveryDAO.getTotalCodCollected(driverId);
    }
}

