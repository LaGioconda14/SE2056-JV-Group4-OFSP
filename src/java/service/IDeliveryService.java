package service;

import java.math.BigDecimal;
import java.util.List;
import model.Delivery;

public interface IDeliveryService {

    List<Delivery> getDeliveriesByDriver(long driverId, String statusFilter, String keyword);

    Delivery getDeliveryById(long deliveryId, long driverId);

    boolean confirmPickup(long deliveryId, long driverId);

    boolean completeDelivery(long deliveryId, long driverId, String proofImageUrl);

    boolean recordFailedDelivery(long deliveryId, long driverId, String failureReason);

    int countDeliveries(long driverId, String statusFilter);

    BigDecimal getTotalCodCollected(long driverId);
}

