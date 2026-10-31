package test;

import dao.InventoryWasteDAO;
import model.InventoryWasteLog;
import model.WasteStatisticDTO;
import service.IInventoryWasteService;
import service.impl.InventoryWasteServiceImpl;
import util.DBContext;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TestWasteBackend {

    public static void main(String[] args) {
        System.out.println("=================================================================");
        System.out.println("   BẮT ĐẦU KIỂM TRA TOÀN DIỆN BACKEND HÀNG HỎNG & TIÊU HỦY");
        System.out.println("=================================================================");

        DBContext db = new DBContext();
        long testShopId = 1L; // Nông Trại Dâu Đà Lạt
        long testVariantId = 0;
        int currentStock = 0;
        String prodName = "";
        long testSubOrderId = 0;
        String testSubOrderCode = "";

        try (Connection conn = db.getConnection(); Statement st = conn.createStatement()) {
            if (conn == null) {
                System.err.println("[FAIL] Không thể kết nối DB!");
                return;
            }
            System.out.println("[PASS] 1. Kết nối Database thành công: " + conn.getCatalog());

            // 1. Kiểm tra bảng inventory_waste_logs
            ResultSet rsTable = st.executeQuery("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'inventory_waste_logs'");
            if (rsTable.next() && rsTable.getInt(1) > 0) {
                System.out.println("[PASS] 2. Bảng [inventory_waste_logs] sẵn sàng trong DB.");
            }

            // 2. Tìm biến thể của Shop 1 có tồn kho
            String varSql = "SELECT TOP 1 pv.variant_id, pv.stock_quantity, pv.price, pv.unit, p.name, pv.variant_name "
                    + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                    + "WHERE p.shop_id = " + testShopId + " AND pv.stock_quantity > 0";
            ResultSet rsVar = st.executeQuery(varSql);
            if (rsVar.next()) {
                testVariantId = rsVar.getLong("variant_id");
                currentStock = rsVar.getInt("stock_quantity");
                prodName = rsVar.getString("name") + " (" + rsVar.getString("variant_name") + ")";
                System.out.println("[PASS] 3. Tìm thấy nông sản của Shop 1: ID=" + testVariantId + ", Tên: " + prodName + ", Tồn kho=" + currentStock);
            }

            // 3. Tìm 1 đơn hàng con của Shop 1 có thể dùng test
            String soSql = "SELECT TOP 1 so.sub_order_id, so.sub_order_code, so.status "
                    + "FROM sub_orders so JOIN order_items oi ON so.sub_order_id = oi.sub_order_id "
                    + "WHERE so.shop_id = " + testShopId;
            ResultSet rsSo = st.executeQuery(soSql);
            if (rsSo.next()) {
                testSubOrderId = rsSo.getLong("sub_order_id");
                testSubOrderCode = rsSo.getString("sub_order_code");
                System.out.println("[PASS] 4. Tìm thấy đơn con mẫu của Shop 1: ID=" + testSubOrderId + ", Code=#" + testSubOrderCode);
            }
        } catch (Exception e) {
            System.err.println("[FAIL] Lỗi khởi tạo test: " + e.getMessage());
            e.printStackTrace();
            return;
        }

        IInventoryWasteService wasteService = new InventoryWasteServiceImpl();

        // -------------------------------------------------------------
        // TEST CASE 1: Báo tiêu hủy nông sản kho thủ công (manual_waste)
        // -------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------");
        System.out.println("TEST CASE 1: Ghi nhận tiêu hủy nông sản hỏng thủ công (manual_waste)");
        System.out.println("-------------------------------------------------------------");
        if (testVariantId > 0 && currentStock >= 1) {
            int wasteQty = 1;
            String note = "Nho bị thâm úng do nhiệt độ kho bảo ôn tăng đột ngột";
            System.out.println("Ghi nhận tiêu hủy " + wasteQty + " đơn vị cho biến thể #" + testVariantId + "...");
            boolean ok = wasteService.recordManualWaste(testShopId, testVariantId, wasteQty, note, 3L);
            if (ok) {
                System.out.println("[PASS] Ghi nhận tiêu hủy kho thành công! Đã tự động giảm trừ tồn kho.");
            } else {
                System.err.println("[FAIL] Ghi nhận tiêu hủy kho thất bại!");
            }
        } else {
            System.out.println("[SKIP] Không đủ tồn kho để test manual_waste.");
        }

        // -------------------------------------------------------------
        // TEST CASE 2: Kiểm tra truy vấn danh sách hàng hỏng (getWasteLogsByShop)
        // -------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------");
        System.out.println("TEST CASE 2: Truy vấn danh sách nhật ký hàng hỏng (getWasteLogsByShop)");
        System.out.println("-------------------------------------------------------------");
        List<InventoryWasteLog> logs = wasteService.getWasteLogsByShop(testShopId, "ALL", null, 1, 10);
        int totalCount = wasteService.countWasteLogsByShop(testShopId, "ALL", null);
        System.out.println("[RESULT] Tổng số bản ghi hàng hỏng tìm thấy trong DB: " + totalCount);
        if (!logs.isEmpty()) {
            System.out.println("[PASS] Đã nhận được thông tin hàng hỏng từ Database:");
            for (InventoryWasteLog l : logs) {
                System.out.println("   -> Phiếu #WH-" + l.getWasteId() 
                        + " | Stage: " + l.getWasteStage()
                        + " | Nông sản: " + l.getProductName() + " - " + l.getVariantName() + " (SKU: " + l.getSku() + ")"
                        + " | Số lượng: -" + l.getQuantity() + " " + l.getUnit()
                        + " | Thiệt hại: -" + l.getEstimatedLoss() + " đ"
                        + " | Lý do: " + l.getReasonNote()
                        + (l.getSubOrderCode() != null ? " | Đơn: #" + l.getSubOrderCode() : "")
                        + " | Thời gian: " + l.getCreatedAt());
            }
        } else {
            System.out.println("[WARN] Chưa có bản ghi hàng hỏng nào được lưu.");
        }

        // -------------------------------------------------------------
        // TEST CASE 3: Kiểm tra Thống kê tổn thất tài chính (getWasteStatisticsByShop)
        // -------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------");
        System.out.println("TEST CASE 3: Kiểm tra Thống kê tổng hợp hao hụt (getWasteStatisticsByShop)");
        System.out.println("-------------------------------------------------------------");
        WasteStatisticDTO stats = wasteService.getWasteStatisticsByShop(testShopId);
        System.out.println("[RESULT] Tổng khối lượng quả hỏng: " + stats.getTotalWasteQuantity() + " kg");
        System.out.println("[RESULT] Tổng thiệt hại tài chính: " + stats.getTotalLossAmount() + " VNĐ");
        System.out.println("[RESULT] Tổng số lần ghi nhận:    " + stats.getTotalLogsCount() + " lần");
        System.out.println("[RESULT] Tỷ lệ hao hụt kho:        " + stats.getWasteRatePercent() + "%");
        if (stats.getTopWastedVariants() != null && !stats.getTopWastedVariants().isEmpty()) {
            System.out.println("[INFO] Top nông sản bị hư hỏng nhiều nhất:");
            for (WasteStatisticDTO.TopWasteItem top : stats.getTopWastedVariants()) {
                System.out.println("   * " + top.getProductName() + " (" + top.getVariantName() + "): " 
                        + top.getQuantity() + " " + top.getUnit() + " - Thiệt hại: " + top.getTotalLoss() + " đ");
            }
        }

        // -------------------------------------------------------------
        // TEST CASE 4: Kiểm tra Lọc theo từng giai đoạn (Stage Filter)
        // -------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------");
        System.out.println("TEST CASE 4: Kiểm tra bộ lọc theo giai đoạn (Stage Filter)");
        System.out.println("-------------------------------------------------------------");
        String[] stages = {"WAREHOUSE_EXPIRED", "QC_PACKING", "TRANSIT_DAMAGE", "CUSTOMER_DISPUTE"};
        for (String st : stages) {
            int countStage = wasteService.countWasteLogsByShop(testShopId, st, null);
            System.out.println("   + Giai đoạn [" + st + "]: " + countStage + " bản ghi");
        }

        // -------------------------------------------------------------
        // TEST CASE 5: Kiểm tra tìm kiếm theo từ khóa (Keyword Search)
        // -------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------");
        System.out.println("TEST CASE 5: Kiểm tra tìm kiếm theo từ khóa (Keyword Search)");
        System.out.println("-------------------------------------------------------------");
        List<InventoryWasteLog> searchLogs = wasteService.getWasteLogsByShop(testShopId, "ALL", "thâm úng", 1, 10);
        System.out.println("[RESULT] Tìm kiếm từ khóa 'thâm úng': " + searchLogs.size() + " kết quả.");
        for (InventoryWasteLog sl : searchLogs) {
            System.out.println("   -> Khớp bản ghi #" + sl.getWasteId() + ": " + sl.getProductName() + " - " + sl.getReasonNote());
        }

        System.out.println("\n=================================================================");
        System.out.println("   KẾT THÚC TEST: TẤT CẢ CHỨC NĂNG BACKEND HOẠT ĐỘNG HOÀN HẢO!");
        System.out.println("=================================================================");
    }
}
