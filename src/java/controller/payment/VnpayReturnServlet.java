package controller.payment;

import dao.VnpayPaymentDAO.CallbackResult;
import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.VnpayPaymentService;
import util.VnpayUtil;

@WebServlet(name = "VnpayReturnServlet", urlPatterns = {"/payment/vnpay/return"})
public class VnpayReturnServlet extends HttpServlet {

    private final VnpayPaymentService paymentService = new VnpayPaymentService();

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
