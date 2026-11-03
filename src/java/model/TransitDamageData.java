package model;

import java.util.ArrayList;
import java.util.List;

/**
 * DTO dữ liệu phục vụ quy trình xử lý đơn hàng hoàn bị hư dập do vận chuyển / đứt chuỗi lạnh.
 */
public class TransitDamageData {

    private long shopId;
    private String currentReason;
    private List<Object[]> items = new ArrayList<>();

    public TransitDamageData() {
    }

    public TransitDamageData(long shopId, String currentReason, List<Object[]> items) {
        this.shopId = shopId;
        this.currentReason = currentReason;
        this.items = items != null ? items : new ArrayList<>();
    }

    public long getShopId() {
        return shopId;
    }

    public void setShopId(long shopId) {
        this.shopId = shopId;
    }

    public String getCurrentReason() {
        return currentReason;
    }

    public void setCurrentReason(String currentReason) {
        this.currentReason = currentReason;
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

    /**
     * Kiểm tra xem đơn hàng hoàn này đã từng được kiểm định / xử lý trước đó hay chưa.
     */
    public boolean isAlreadyProcessed() {
        return currentReason != null && currentReason.contains("[ĐÃ XỬ LÝ");
    }
}
