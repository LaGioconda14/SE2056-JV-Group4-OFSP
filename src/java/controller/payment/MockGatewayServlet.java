package controller.payment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import model.User;
import util.PaymentGatewayUtil;

/**
 * CỔNG THANH TOÁN GIẢ LẬP (Mock VNPay) - đóng vai "Payment Gateway" trong business flow.
 *
 * GET  /payment/gateway : nhận yêu cầu đã ký từ hệ thống, hiển thị giao diện thanh toán.
 * POST /payment/gateway : khách bấm kết quả (thành công / không đủ số dư / hủy),
 *                         cổng ký phản hồi và chuyển khách về vnp_ReturnUrl.
 *
 * Toàn bộ logic ở đây chỉ để demo. Khi dùng VNPay Sandbox thật, servlet này bị bỏ đi
 * và PaymentServiceImpl trỏ sang địa chỉ cổng thật.
 */
@WebServlet(name = "MockGatewayServlet", urlPatterns = {"/payment/gateway"})
public class MockGatewayServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isLoggedIn(request, response)) {
            return;
        }

        Map<String, String> params = PaymentGatewayUtil.readGatewayParams(request);
        if (!isValidRequest(params)) {
            flashAndGoHistory(request, response, "Yêu cầu thanh toán không hợp lệ hoặc đã bị thay đổi!");
            return;
        }
        if (isExpired(params)) {
            redirectToReturn(params, PaymentGatewayUtil.RESP_TIMEOUT, response);
            return;
        }

        long gatewayAmount = Long.parseLong(params.get("vnp_Amount"));
        request.setAttribute("gwParams", params);
        request.setAttribute("gwTxnRef", params.get("vnp_TxnRef"));
        request.setAttribute("gwAmount", BigDecimal.valueOf(gatewayAmount, 2));
        request.setAttribute("gwOrderInfo", params.get("vnp_OrderInfo"));
        request.setAttribute("gwBankTransfer", "VNBANK".equals(params.get("vnp_BankCode")));
        request.setAttribute("gwExpireMillis", parseDate(params.get("vnp_ExpireDate")).getTime());
        request.getRequestDispatcher("/views/payment/gateway.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isLoggedIn(request, response)) {
            return;
        }

        Map<String, String> params = PaymentGatewayUtil.readGatewayParams(request);
        if (!isValidRequest(params)) {
            flashAndGoHistory(request, response, "Yêu cầu thanh toán không hợp lệ hoặc đã bị thay đổi!");
            return;
        }

        String result = request.getParameter("result");
        String code;
        if (isExpired(params)) {
            code = PaymentGatewayUtil.RESP_TIMEOUT;
        } else if ("SUCCESS".equals(result)) {
            code = PaymentGatewayUtil.RESP_SUCCESS;
        } else if ("INSUFFICIENT".equals(result)) {
            code = PaymentGatewayUtil.RESP_INSUFFICIENT;
        } else {
            code = PaymentGatewayUtil.RESP_CANCELLED;
        }
        redirectToReturn(params, code, response);
    }

    /** Cổng gửi phản hồi đã ký về website (Send payment transaction response to system). */
    private void redirectToReturn(Map<String, String> req, String responseCode, HttpServletResponse response)
            throws IOException {
        boolean ok = PaymentGatewayUtil.RESP_SUCCESS.equals(responseCode);

        Map<String, String> res = new LinkedHashMap<>();
        res.put("vnp_TmnCode", PaymentGatewayUtil.TMN_CODE);
        res.put("vnp_Amount", req.get("vnp_Amount"));
        res.put("vnp_BankCode", req.get("vnp_BankCode"));
        res.put("vnp_OrderInfo", req.get("vnp_OrderInfo"));
        res.put("vnp_TxnRef", req.get("vnp_TxnRef"));
        res.put("vnp_TransactionNo", ok ? PaymentGatewayUtil.generateGatewayTransactionNo() : "0");
        res.put("vnp_PayDate", PaymentGatewayUtil.formatDate(new Date()));
        res.put("vnp_ResponseCode", responseCode);
        res.put("vnp_TransactionStatus", ok ? "00" : "02");

        response.sendRedirect(req.get("vnp_ReturnUrl") + "?" + PaymentGatewayUtil.signedQuery(res));
    }

    private boolean isValidRequest(Map<String, String> params) {
        return PaymentGatewayUtil.TMN_CODE.equals(params.get("vnp_TmnCode"))
                && params.get("vnp_TxnRef") != null
                && params.get("vnp_ReturnUrl") != null
                && params.get("vnp_ExpireDate") != null
                && isNumber(params.get("vnp_Amount"))
                && PaymentGatewayUtil.verify(params);
    }

    private boolean isNumber(String s) {
        if (s == null || s.isEmpty()) {
            return false;
        }
        try {
            Long.parseLong(s);
            return true;
        } catch (NumberFormatException ex) {
            return false;
        }
    }

    private boolean isExpired(Map<String, String> params) {
        return new Date().after(parseDate(params.get("vnp_ExpireDate")));
    }

    private Date parseDate(String value) {
        try {
            return new SimpleDateFormat("yyyyMMddHHmmss").parse(value);
        } catch (ParseException ex) {
            return new Date(0);
        }
    }

    private boolean isLoggedIn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập để thanh toán!");
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private void flashAndGoHistory(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        request.getSession(true).setAttribute("paymentError", message);
        response.sendRedirect(request.getContextPath() + "/payment/history");
    }
}
