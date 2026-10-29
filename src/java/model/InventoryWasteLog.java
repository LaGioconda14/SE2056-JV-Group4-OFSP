package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class InventoryWasteLog {

    private long wasteId;
    private long shopId;
    private long variantId;
    private Long subOrderId;
    private String wasteStage;
    private int quantity;
    private String unit;
    private BigDecimal costPrice;
    private BigDecimal estimatedLoss;
    private String reasonNote;
    private String imageProofUrl;
    private Long loggedBy;
    private Timestamp createdAt;

    private String productName;
    private String variantName;
    private String sku;
    private String subOrderCode;
    private String loggedByName;

    public InventoryWasteLog() {
    }

    public long getWasteId() {
        return wasteId;
    }

    public void setWasteId(long wasteId) {
        this.wasteId = wasteId;
    }

    public long getShopId() {
        return shopId;
    }

    public void setShopId(long shopId) {
        this.shopId = shopId;
    }

    public long getVariantId() {
        return variantId;
    }

    public void setVariantId(long variantId) {
        this.variantId = variantId;
    }

    public Long getSubOrderId() {
        return subOrderId;
    }

    public void setSubOrderId(Long subOrderId) {
        this.subOrderId = subOrderId;
    }

    public String getWasteStage() {
        return wasteStage;
    }

    public void setWasteStage(String wasteStage) {
        this.wasteStage = wasteStage;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public BigDecimal getEstimatedLoss() {
        return estimatedLoss;
    }

    public void setEstimatedLoss(BigDecimal estimatedLoss) {
        this.estimatedLoss = estimatedLoss;
    }

    public String getReasonNote() {
        return reasonNote;
    }

    public void setReasonNote(String reasonNote) {
        this.reasonNote = reasonNote;
    }

    public String getImageProofUrl() {
        return imageProofUrl;
    }

    public void setImageProofUrl(String imageProofUrl) {
        this.imageProofUrl = imageProofUrl;
    }

    public Long getLoggedBy() {
        return loggedBy;
    }

    public void setLoggedBy(Long loggedBy) {
        this.loggedBy = loggedBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
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

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getSubOrderCode() {
        return subOrderCode;
    }

    public void setSubOrderCode(String subOrderCode) {
        this.subOrderCode = subOrderCode;
    }

    public String getLoggedByName() {
        return loggedByName;
    }

    public void setLoggedByName(String loggedByName) {
        this.loggedByName = loggedByName;
    }
}
