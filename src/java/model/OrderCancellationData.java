package model;

import java.util.ArrayList;
import java.util.List;


public class OrderCancellationData {

    private long shopId;
    private long parentOrderId;
    private List<Object[]> items = new ArrayList<>();

    public OrderCancellationData() {
    }

    public OrderCancellationData(long shopId, long parentOrderId, List<Object[]> items) {
        this.shopId = shopId;
        this.parentOrderId = parentOrderId;
        this.items = items != null ? items : new ArrayList<>();
    }

    public long getShopId() {
        return shopId;
    }

    public void setShopId(long shopId) {
        this.shopId = shopId;
    }

    public long getParentOrderId() {
        return parentOrderId;
    }

    public void setParentOrderId(long parentOrderId) {
        this.parentOrderId = parentOrderId;
    }

    public List<Object[]> getItems() {
        return items;
    }

    public void setItems(List<Object[]> items) {
        this.items = items;
    }

    public void addItem(Object[] item) {
        if (this.items == null) {
            this.items = new ArrayList<>();
        }
        this.items.add(item);
    }
}
