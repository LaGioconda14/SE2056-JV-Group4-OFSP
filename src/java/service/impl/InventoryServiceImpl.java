package service.impl;

import java.util.List;
import model.ProductBatch;
import service.IInventoryService;
import dao.InventoryDAO;
import java.util.ArrayList;
import model.InventoryTransaction;

public class InventoryServiceImpl implements IInventoryService {

    private final InventoryDAO inventoryDAO = new InventoryDAO();

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

        List<String> allowedReasons = java.util.Arrays.asList(
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

    @Override
    public List<ProductBatch> searchAndFilterBatches(long shopId, String keyword, String categoryId) {
        return inventoryDAO.searchAndFilterBatchesByShop(shopId, keyword, categoryId);
    }

}
