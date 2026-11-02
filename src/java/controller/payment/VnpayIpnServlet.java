package controller.payment;

import com.google.gson.Gson;
import dao.VnpayPaymentDAO.CallbackResult;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.VnpayPaymentService;
import util.VnpayUtil;

@WebServlet(name = "VnpayIpnServlet", urlPatterns = {"/payment/vnpay/ipn"})
public class VnpayIpnServlet extends HttpServlet {

    private final VnpayPaymentService paymentService = new VnpayPaymentService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String code = "99";
        String message = "Unknown error";
        try {
            if (!VnpayUtil.isValidSignature(request.getParameterMap())) {
                code = "97";
                message = "Invalid checksum";
            } else {
                CallbackResult result = paymentService.processCallback(request.getParameterMap());
                switch (result) {
                    case SUCCESS:
                        code = "00";
                        message = "Confirm success";
                        break;
                    case ALREADY_CONFIRMED:
                        code = "02";
                        message = "Order already confirmed";
                        break;
                    case ORDER_NOT_FOUND:
                        code = "01";
                        message = "Order not found";
                        break;
                    case INVALID_AMOUNT:
                        code = "04";
                        message = "Invalid amount";
                        break;
                    case INVALID_ORDER:
                        code = "01";
                        message = "Invalid order";
                        break;
                    case PAYMENT_FAILED:
                        code = "00";
                        message = "Confirm success";
                        break;
                    default:
                        break;
                }
            }
        } catch (IllegalArgumentException ex) {
            code = "01";
            message = "Invalid order";
        }

        Map<String, String> payload = new LinkedHashMap<>();
        payload.put("RspCode", code);
        payload.put("Message", message);
        response.getWriter().write(gson.toJson(payload));
    }
}
