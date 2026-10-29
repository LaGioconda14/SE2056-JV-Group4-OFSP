package model;

import java.sql.Timestamp;

public class InventoryBatchItem {
    private long batchId;
    private String batchCode;
    private long variantId;
    private long productId;
    private String sku;
    private String productName;
    private String variantName;
    private String certification;
    private String batchType;
    private String image;
    private Timestamp harvestDate;
    private String harvestTimeLabel;
    private int freshnessScore;
    private String freshnessNote;
    private int currentQuantity;
    private int initialQuantity;
    private int lowStockThreshold;
    private String unit;
    private String pendingPackingText;
    private double price;

    public InventoryBatchItem() {}

    // Getters and Setters
    public long getBatchId() { return batchId; }
    public void setBatchId(long batchId) { this.batchId = batchId; }

    public String getBatchCode() { return batchCode; }
    public void setBatchCode(String batchCode) { this.batchCode = batchCode; }

    public long getVariantId() { return variantId; }
    public void setVariantId(long variantId) { this.variantId = variantId; }

    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getVariantName() { return variantName; }
    public void setVariantName(String variantName) { this.variantName = variantName; }

    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }

    public String getBatchType() { return batchType; }
    public void setBatchType(String batchType) { this.batchType = batchType; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public Timestamp getHarvestDate() { return harvestDate; }
    public void setHarvestDate(Timestamp harvestDate) { this.harvestDate = harvestDate; }

    public String getHarvestTimeLabel() { return harvestTimeLabel; }
    public void setHarvestTimeLabel(String harvestTimeLabel) { this.harvestTimeLabel = harvestTimeLabel; }

    public int getFreshnessScore() { return freshnessScore; }
    public void setFreshnessScore(int freshnessScore) { this.freshnessScore = freshnessScore; }

    public String getFreshnessNote() { return freshnessNote; }
    public void setFreshnessNote(String freshnessNote) { this.freshnessNote = freshnessNote; }

    public int getCurrentQuantity() { return currentQuantity; }
    public void setCurrentQuantity(int currentQuantity) { this.currentQuantity = currentQuantity; }

    public int getInitialQuantity() { return initialQuantity; }
    public void setInitialQuantity(int initialQuantity) { this.initialQuantity = initialQuantity; }

    public int getLowStockThreshold() { return lowStockThreshold; }
    public void setLowStockThreshold(int lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public String getPendingPackingText() { return pendingPackingText; }
    public void setPendingPackingText(String pendingPackingText) { this.pendingPackingText = pendingPackingText; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    // Helpers for UI Display
    public String getRiskLevel() {
        int deficit = currentQuantity - lowStockThreshold;
        if (deficit <= -5 || currentQuantity <= 5) {
            return "CRITICAL";
        } else if (currentQuantity <= lowStockThreshold) {
            return "WARNING";
        }
        return "SAFE";
    }

    public String getRiskText() {
        int deficit = currentQuantity - lowStockThreshold;
        if (deficit <= -5 || currentQuantity <= 5) {
            return "NGUY CẤP (" + deficit + " " + (unit != null ? unit.toUpperCase() : "ĐV") + ")";
        } else if (currentQuantity <= lowStockThreshold) {
            return "CẢNH BÁO VÀNG";
        }
        return "AN TOÀN";
    }

    public String getRiskBadgeClass() {
        String level = getRiskLevel();
        if ("CRITICAL".equals(level)) {
            return "bg-[#fee2e2] text-red-700 border border-red-200";
        } else if ("WARNING".equals(level)) {
            return "bg-[#fef3c7] text-amber-800 border border-amber-200";
        }
        return "bg-[#ecfdf5] text-emerald-800 border border-emerald-200";
    }

    public int getStockProgressPercent() {
        if (initialQuantity <= 0) return 30;
        int pct = (int) Math.round(((double) currentQuantity / initialQuantity) * 100.0);
        return Math.min(100, Math.max(8, pct));
    }

    public String getStockNumberColor() {
        String level = getRiskLevel();
        if ("CRITICAL".equals(level)) return "text-red-600";
        if ("WARNING".equals(level)) return "text-amber-600";
        return "text-emerald-700";
    }

    public String getProgressBarColor() {
        String level = getRiskLevel();
        if ("CRITICAL".equals(level)) return "bg-red-500";
        if ("WARNING".equals(level)) return "bg-amber-500";
        return "bg-emerald-600";
    }
}

