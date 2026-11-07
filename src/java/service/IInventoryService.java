/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package service;

import java.util.List;
import model.InventoryTransaction;
import model.ProductBatch;

/**
 *
 * @author ADMIN
 */
public interface IInventoryService {
    //lấy danh sách kho
    List<ProductBatch> getBatchesByShopId(long shopId);
    
    boolean restockBatch(long variantId, long shopId, long userId, int quantity, String expiryDate, String note) throws Exception;
    
    boolean adjustBatch(int batchId, int variantId, int shopId, int userId, int deductQuantity,
            String transactionType, String reason) throws Exception;

    boolean disposeBatch(long batchId, long variantId, long shopId, long userId, String reasonCode, String description) throws Exception;

    List<InventoryTransaction> getInventoryHistory(int variantId, int batchId, int shopId);
}
