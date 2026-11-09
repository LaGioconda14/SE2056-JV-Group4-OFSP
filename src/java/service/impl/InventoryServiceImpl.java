package service.impl;

import dao.InventoryDAO;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import model.InventoryBatchItem;
import model.InventoryTransaction;
import model.ProductBatch;
import service.IInventoryService;

public class InventoryServiceImpl implements IInventoryService {

    private final InventoryDAO inventoryDAO;

    public InventoryServiceImpl() {
        this.inventoryDAO = new InventoryDAO();
    }

    @Override
    public List<InventoryBatchItem> getInventoryAlertItems(long shopId, String keyword, String riskLevel, 
                                                          String sortBy, String viewTab, int page, int pageSize) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return inventoryDAO.getInventoryAlertItems(shopId, keyword, riskLevel, sortBy, viewTab, page, pageSize);
    }

    @Override
    public int countInventoryAlertItems(long shopId, String keyword, String riskLevel, String viewTab) throws Exception {
        if (shopId <= 0) {
            throw new Exception("Mã gian hàng không hợp lệ!");
        }
        return inventoryDAO.countInventoryAlertItems(shopId, keyword, riskLevel, viewTab);
    }

    @Override
    public int getCriticalStockCount(long shopId) {
        return inventoryDAO.getCriticalStockCount(shopId);
    }

    @Override
    public String getCriticalItemNames(long shopId) {
        return inventoryDAO.getCriticalItemNames(shopId);
    }

    @Override
    public int getExpiringFreshnessCount(long shopId) {
        return inventoryDAO.getExpiringFreshnessCount(shopId);
    }

    @Override
    public BigDecimal getTotalInventoryValue(long shopId) {
        return inventoryDAO.getTotalInventoryValue(shopId);
    }

    @Override
    public boolean restockVariant(long variantId, int addedQuantity) throws Exception {
        if (variantId <= 0 || addedQuantity <= 0) {
            throw new Exception("Thông tin nhập kho không hợp lệ!");
        }
        return inventoryDAO.restockVariant(variantId, addedQuantity);
    }

    @Override
    public boolean applyFreshSaleDiscount(long variantId, int discountPercent) throws Exception {
        if (variantId <= 0 || discountPercent <= 0 || discountPercent > 90) {
            throw new Exception("Mức chiết khấu không hợp lệ!");
        }
        return inventoryDAO.applyFreshSaleDiscount(variantId, discountPercent);
    }

    @Override
    public List<ProductBatch> getBatchesByShopId(long shopId) {
        return inventoryDAO.getBatchesByShopId(shopId);
    }

    @Override
    public boolean restockBatch(long variantId, long shopId, long userId, int quantity, String expiryDate, String note) throws Exception {
        if (variantId <= 0 || shopId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Thông tin định danh (ID) không hợp lệ.");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng nhập kho phải lớn hơn 0.");
        }
        if (expiryDate == null || expiryDate.trim().isEmpty()) {
            throw new IllegalArgumentException("Hạn sử dụng là bắt buộc đối với nông sản.");
        }

        boolean success = inventoryDAO.restockBatch(variantId, shopId, userId, quantity, expiryDate, note);
        if (!success) {
            throw new RuntimeException("Không thể lưu thông tin lô mới vào cơ sở dữ liệu.");
        }
        return true;
    }

    @Override
    public boolean adjustBatch(int batchId, int variantId, int shopId, int userId,
            int deductQuantity, String transactionType, String reason) throws Exception {

        if (batchId <= 0 || variantId <= 0 || shopId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Thông tin định danh (ID) không hợp lệ.");
        }
        if (deductQuantity <= 0) {
            throw new IllegalArgumentException("Số lượng trừ hao phải lớn hơn 0.");
        }

        // Mở rộng danh sách loại giao dịch cho phép để khớp với các lựa chọn trên giao diện Modal
        if (!("DAMAGED".equals(transactionType)
                || "EXPIRED".equals(transactionType)
                || "LOST".equals(transactionType)
                || "QUALITY_FAIL".equals(transactionType)
                || "STORAGE_ISSUE".equals(transactionType))) {
            throw new IllegalArgumentException("Loại giao dịch trừ hao không hợp lệ.");
        }

        boolean isSuccess = inventoryDAO.adjustBatch(batchId, variantId, shopId, userId, deductQuantity, transactionType, reason);

        if (!isSuccess) {
            throw new Exception("Trừ hao kho thất bại! Có thể do số lượng trừ vượt quá tồn kho hiện tại của lô hoặc xảy ra lỗi kết nối cơ sở dữ liệu.");
        }

        return true;
    }

    @Override
    public boolean disposeBatch(long batchId, long variantId, long shopId, long userId, String reasonCode, String description) throws Exception {
        if (batchId <= 0 || variantId <= 0 || shopId <= 0 || userId <= 0) {
            throw new IllegalArgumentException("Thông tin ID không hợp lệ.");
        }

        List<String> allowedReasons = Arrays.asList(
                "EXPIRED",
                "DAMAGED",
                "STORAGE_ISSUE",
                "QUALITY_FAIL",
                "LOST"
        );

        if (reasonCode == null || !allowedReasons.contains(reasonCode)) {
            throw new IllegalArgumentException("Lý do hủy lô không hợp lệ.");
        }

        description = (description == null) ? "" : description.trim();
        if (description.length() > 150) {
            description = description.substring(0, 150);
        }

        boolean success = inventoryDAO.disposeBatch(
                batchId,
                variantId,
                shopId,
                userId,
                reasonCode,
                description
        );

        if (!success) {
            throw new Exception("Hủy lô thất bại! Lô hàng không tồn tại hoặc đã hết hàng từ trước.");
        }

        return true;
    }

    @Override
    public List<InventoryTransaction> getInventoryHistory(int variantId, int batchId, int shopId) {
        if (variantId <= 0 || batchId <= 0 || shopId <= 0) {
            return new ArrayList<>();
        }

        boolean isOwnedByShop = inventoryDAO.checkBatchBelongsToShop(variantId, batchId, shopId);
        if (!isOwnedByShop) {
            return new ArrayList<>();
        }

        return inventoryDAO.getInventoryHistory(variantId, batchId, shopId);
    }
}
