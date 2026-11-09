package model.entity.inventory;
 
import java.sql.Timestamp;
 
public class InventoryTransaction {
 
    private int transactionId;
    private int batchId;
    private int variantId;
    private int shopId;
    private int userId;
    private String transactionType;
    private int quantityChanged;
    private int previousStock;
    private int newStock;
    private String reason;
    private java.sql.Timestamp createdAt;
 
    // Thông tin bổ sung từ bảng users
    private String fullName;
    private String userAvatar;
    private String userEmail;
 
    // Constructors, Getters và Setters
    public InventoryTransaction() {
        
    }
 
    public InventoryTransaction(int transactionId, int batchId, int variantId, int shopId, int userId, String transactionType, int quantityChanged, int previousStock, int newStock, String reason, Timestamp createdAt) {
        this.transactionId = transactionId;
        this.batchId = batchId;
        this.variantId = variantId;
        this.shopId = shopId;
        this.userId = userId;
        this.transactionType = transactionType;
        this.quantityChanged = quantityChanged;
        this.previousStock = previousStock;
        this.newStock = newStock;
        this.reason = reason;
        this.createdAt = createdAt;
    }
 
    public int getTransactionId() {
        return transactionId;
    }
 
    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }
 
    public int getBatchId() {
        return batchId;
    }
 
    public void setBatchId(int batchId) {
        this.batchId = batchId;
    }
 
    public int getVariantId() {
        return variantId;
    }
 
    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }
 
    public int getShopId() {
        return shopId;
    }
 
    public void setShopId(int shopId) {
        this.shopId = shopId;
    }
 
    public int getUserId() {
        return userId;
    }
 
    public void setUserId(int userId) {
        this.userId = userId;
    }
 
    public String getTransactionType() {
        return transactionType;
    }
 
    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }
 
    public int getQuantityChanged() {
        return quantityChanged;
    }
 
    public void setQuantityChanged(int quantityChanged) {
        this.quantityChanged = quantityChanged;
    }
 
    public int getPreviousStock() {
        return previousStock;
    }
 
    public void setPreviousStock(int previousStock) {
        this.previousStock = previousStock;
    }
 
    public int getNewStock() {
        return newStock;
    }
 
    public void setNewStock(int newStock) {
        this.newStock = newStock;
    }
 
    public String getReason() {
        return reason;
    }
 
    public void setReason(String reason) {
        this.reason = reason;
    }
 
    public java.sql.Timestamp getCreatedAt() {
        return createdAt;
    }
 
    public void setCreatedAt(java.sql.Timestamp createdAt) {
        this.createdAt = createdAt;
    }
 
    public String getFullName() {
        return fullName;
    }
 
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
 
    public String getUserAvatar() {
        return userAvatar;
    }
 
    public void setUserAvatar(String userAvatar) {
        this.userAvatar = userAvatar;
    }
 
    public String getUserEmail() {
        return userEmail;
    }
 
    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }
}