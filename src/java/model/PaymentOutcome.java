package model;

/** Kết quả xử lý phản hồi từ cổng thanh toán. */
public class PaymentOutcome {

    private final boolean success;
    private final long orderId;
    private final String transactionCode;
    private final String responseCode;
    private final String message;

    public PaymentOutcome(boolean success, long orderId, String transactionCode,
            String responseCode, String message) {
        this.success = success;
        this.orderId = orderId;
        this.transactionCode = transactionCode;
        this.responseCode = responseCode;
        this.message = message;
    }

    public boolean isSuccess() { return success; }
    public long getOrderId() { return orderId; }
    public String getTransactionCode() { return transactionCode; }
    public String getResponseCode() { return responseCode; }
    public String getMessage() { return message; }
}
