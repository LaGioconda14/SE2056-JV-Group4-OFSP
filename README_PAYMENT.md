# FE-06 Payment Management - bản v3 (khớp nhánh dev 96 commit, đã bỏ Pay with Loyalty Points)

Giải nén đè vào thư mục gốc project (đường dẫn giữ nguyên `src/java/...`, `web/...`).

## Thứ tự chạy SQL
1. (đã có) file 1 + file 2 của nhóm
2. `sql/04_refund_payout_schema.sql`  - BẮT BUỘC: bảng `refunds` + 3 cột ngân hàng cho `shops`
3. `sql/03_payment_seed.sql`           - tuỳ chọn: dữ liệu mẫu lịch sử thanh toán (ngày tương đối theo hôm nay)
4. `sql/05_refund_payout_seed.sql`    - tuỳ chọn: tài khoản ngân hàng 4 shop + 1 khoản hoàn mẫu

## Chức năng và nơi code
| Chức năng | Màn hình / URL | Lõi xử lý |
|---|---|---|
| COD, Online (mock VNPay/Bank), Process/Verify, Payment history | /payment/history, /payment/gateway, /payment/return ... | PaymentDAO, PaymentServiceImpl |
| Retry Failed Payment (đổi phương thức khác, kể cả sang COD) | /payment/failed?orderId= | PaymentActionServlet, PaymentDAO.switchToCod |
| Refund & Partial Refund | /admin/refunds (trang Khiếu nại cũ đã bị xóa khỏi dev; khiếu nại tự sinh khi shipper ghi nhận giao thất bại cũng hiện ở đây) | RefundDAO |
| Vendor Payout / Settlement Calculation | /admin/payouts (tạo kỳ) | PayoutDAO.generate |
| Process Vendor Withdrawal | /admin/payouts (xác nhận chuyển tiền), /shop/finance (chủ shop) | PayoutDAO.markCompleted |
| Payment Analytics & Cashflow | /admin/payment-analytics | PaymentAnalyticsDAO |

## Công thức cần thuộc
- Settlement: Net = Gross (shop_total các sub-order DELIVERED trong kỳ) - Hoa hồng (sub_orders.commission_amount) - Khấu trừ khiếu nại (refunds DISPUTE/MANUAL)
- Refund: tổng hoàn của 1 sub-order <= shop_total; hoàn đủ -> sub_orders.status = REFUNDED; mọi sub-order đã hủy/hoàn -> orders.payment_status = REFUNDED
- Hủy đơn đã thanh toán online -> tự hoàn toàn phần (hook trong OrderServiceImpl / OrderFulfillmentServiceImpl)
- Dòng tiền ròng = Tiền thu - Tiền hoàn - Tiền đã chi trả cho shop

## Ghi chú v3 (tích hợp với code mới của nhóm)
- Đã vá lại OrderFulfillmentDAO, DeliveryDAO, OrderFulfillmentServiceImpl trên bản mới nhất của dev (không ghi đè phần quản lý tài xế).
- enums/PaymentMethod: thêm BANK_TRANSFER.
- admin/layout/sidebar.jsp: thêm mục "TÀI CHÍNH" (4 link). Không còn sửa disputes.jsp (file đã bị xóa khỏi dev).
- shop-finance.jsp dùng layout chung /views/shop/layout/sidebar.jsp và header.jsp.
- Không có VNPayService.java trong zip; file đó là của nhóm/bạn và không bị đụng tới.
