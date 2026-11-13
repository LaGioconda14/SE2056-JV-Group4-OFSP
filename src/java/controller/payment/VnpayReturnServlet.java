package controller.payment;

import dao.VnpayPaymentDAO.CallbackResult;
import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.VnpayPaymentService;
import util.VnpayUtil;

/**
 * Servlet tiếp nhận kết quả thanh toán từ VNPAY chuyển hướng về trình duyệt (Return URL).
 * Endpoint: /payment/vnpay/return
 */
@WebServlet(name = "VnpayReturnServlet", urlPatterns = {"/payment/vnpay/return"})
public class VnpayReturnServlet extends HttpServlet {

    private final VnpayPaymentService paymentService = new VnpayPaymentService();

    /**
     * Xử lý yêu cầu HTTP GET khi khách hàng hoàn tất thanh toán trên cổng VNPAY và được chuyển hướng về website:
     * - Trích xuất mã đơn hàng vnp_TxnRef.
     * - Xác thực chữ ký số (Checksum) nhằm bảo đảm toàn vẹn dữ liệu.
     * - Gọi paymentService để ghi nhận kết quả thanh toán.
     * - Chuyển hướng người dùng về trang xác nhận đơn hàng kèm trạng thái kết quả (success, failed, invalid).
     *
     * @param request  yêu cầu HTTP chứa các tham số phản hồi từ VNPAY
     * @param response phản hồi HTTP redirect sang trang xác nhận đơn
     * @throws IOException nếu xảy ra lỗi vào/ra dữ liệu
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String paymentResult = "invalid";
        long orderId;
        try {
            orderId = VnpayPaymentService.parseOrderId(request.getParameter("vnp_TxnRef"));
            if (VnpayUtil.isValidSignature(request.getParameterMap())) {
                CallbackResult result = paymentService.processCallback(request.getParameterMap());
                if (result == CallbackResult.SUCCESS || result == CallbackResult.ALREADY_CONFIRMED) {
                    paymentResult = "success";
                } else if (result == CallbackResult.PAYMENT_FAILED) {
                    paymentResult = "failed";
                }
            }
            response.sendRedirect(request.getContextPath() + "/order/confirmation?orderId="
                    + orderId + "&payment=" + paymentResult);
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/profile?payment=invalid#orders");
        }
    }
}
