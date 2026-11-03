package model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class WasteStatisticDTO {

    private int totalWasteQuantity;
    private BigDecimal totalLossAmount = BigDecimal.ZERO;
    private int totalLogsCount;
    private double wasteRatePercent;
    private List<TopWasteItem> topWastedVariants = new ArrayList<>();

    public WasteStatisticDTO() {
    }

    public int getTotalWasteQuantity() {
        return totalWasteQuantity;
    }

    public void setTotalWasteQuantity(int totalWasteQuantity) {
        this.totalWasteQuantity = totalWasteQuantity;
    }

    public BigDecimal getTotalLossAmount() {
        return totalLossAmount;
    }

    public void setTotalLossAmount(BigDecimal totalLossAmount) {
        this.totalLossAmount = totalLossAmount;
    }

    public int getTotalLogsCount() {
        return totalLogsCount;
    }

    public void setTotalLogsCount(int totalLogsCount) {
        this.totalLogsCount = totalLogsCount;
    }

    public double getWasteRatePercent() {
        return wasteRatePercent;
    }

    public void setWasteRatePercent(double wasteRatePercent) {
        this.wasteRatePercent = wasteRatePercent;
    }

    public List<TopWasteItem> getTopWastedVariants() {
        return topWastedVariants;
    }

    public void setTopWastedVariants(List<TopWasteItem> topWastedVariants) {
        this.topWastedVariants = topWastedVariants;
    }

    public static class TopWasteItem {
        private long variantId;
        private String productName;
        private String variantName;
        private String unit;
        private int quantity;
        private BigDecimal totalLoss;

        public TopWasteItem() {
        }

        public long getVariantId() {
            return variantId;
        }

        public void setVariantId(long variantId) {
            this.variantId = variantId;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public String getVariantName() {
            return variantName;
        }

        public void setVariantName(String variantName) {
            this.variantName = variantName;
        }

        public String getUnit() {
            return unit;
        }

        public void setUnit(String unit) {
            this.unit = unit;
        }

        public int getQuantity() {
            return quantity;
        }

        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }

        public BigDecimal getTotalLoss() {
            return totalLoss;
        }

        public void setTotalLoss(BigDecimal totalLoss) {
            this.totalLoss = totalLoss;
        }
    }
}
