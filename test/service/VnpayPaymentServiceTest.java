package service;

import dao.VnpayPaymentDAO;
import dao.VnpayPaymentDAO.CallbackResult;
import model.Order;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import util.VnpayConfig;

import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Unit Tests for VnpayPaymentService")
class VnpayPaymentServiceTest {

    @Mock
    private VnpayPaymentDAO paymentDAO;

    @InjectMocks
    private VnpayPaymentService vnpayPaymentService;

    @BeforeAll
    static void configureVnpayProperties() throws Exception {
        // Ensure VnpayConfig has valid test credentials even if not configured on environment
        Field propField = VnpayConfig.class.getDeclaredField("PROPERTIES");
        propField.setAccessible(true);
        Properties props = (Properties) propField.get(null);
        props.setProperty("vnpay.tmn_code", "TEST_TMN_CODE");
        props.setProperty("vnpay.hash_secret", "TEST_HASH_SECRET_1234567890ABCDEF");
        props.setProperty("vnpay.payment_url", "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html");
        props.setProperty("vnpay.return_url", "http://localhost:8080/vnpay-return");
        props.setProperty("vnpay.version", "2.1.0");
        props.setProperty("vnpay.command", "pay");
        props.setProperty("vnpay.locale", "vn");
        props.setProperty("vnpay.order_timeout_minutes", "15");
    }

    @Nested
    @DisplayName("createPaymentUrl Tests")
    class CreatePaymentUrlTests {

        @Test
        @DisplayName("Order null should throw IllegalArgumentException")
        void testCreatePaymentUrl_OrderNull() {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> vnpayPaymentService.createPaymentUrl(null, "127.0.0.1", "http://localhost/return"));
            assertEquals("Đơn hàng thanh toán không hợp lệ", ex.getMessage());
        }

        @Test
        @DisplayName("Order with null finalAmount should throw IllegalArgumentException")
        void testCreatePaymentUrl_FinalAmountNull() {
            Order order = new Order();
            order.setOrderId(100L);
            order.setFinalAmount(null);

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> vnpayPaymentService.createPaymentUrl(order, "127.0.0.1", "http://localhost/return"));
            assertEquals("Đơn hàng thanh toán không hợp lệ", ex.getMessage());
        }

        @ParameterizedTest
        @NullAndEmptySource
        @ValueSource(strings = {"   ", "\t\n"})
        @DisplayName("Blank returnUrl should throw IllegalArgumentException")
        void testCreatePaymentUrl_BlankReturnUrl(String invalidReturnUrl) {
            Order order = new Order();
            order.setOrderId(100L);
            order.setOrderCode("ORD-100");
            order.setFinalAmount(BigDecimal.valueOf(100000));

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> vnpayPaymentService.createPaymentUrl(order, "127.0.0.1", invalidReturnUrl));
            assertEquals("Return URL của VNPAY không hợp lệ", ex.getMessage());
        }

        @Test
        @DisplayName("Valid order should build URL with multiplied amount and hash")
        void testCreatePaymentUrl_Success() {
            Order order = new Order();
            order.setOrderId(888L);
            order.setOrderCode("OFSP-888");
            order.setFinalAmount(BigDecimal.valueOf(250000)); // 250,000 VND

            String url = vnpayPaymentService.createPaymentUrl(order, "192.168.1.1", "http://localhost:8080/return");

            assertNotNull(url);
            assertTrue(url.startsWith("https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?"));
            assertTrue(url.contains("vnp_Amount=25000000")); // Multiplied by 100
            assertTrue(url.contains("vnp_TxnRef=888"));
            assertTrue(url.contains("vnp_Command=pay"));
            assertTrue(url.contains("vnp_TmnCode=TEST_TMN_CODE"));
            assertTrue(url.contains("vnp_SecureHash="));
        }
    }

    @Nested
    @DisplayName("parseOrderId Tests")
    class ParseOrderIdTests {

        @ParameterizedTest(name = "Valid orderId string: \"{0}\" => {1}")
        @CsvSource({
            "1, 1",
            "12345, 12345",
            "999999999, 999999999"
        })
        @DisplayName("Valid positive numeric string should parse to long")
        void testParseOrderId_Valid(String input, long expected) {
            assertEquals(expected, VnpayPaymentService.parseOrderId(input));
        }

        @ParameterizedTest(name = "Invalid orderId string: \"{0}\"")
        @NullAndEmptySource
        @ValueSource(strings = {"0", "-1", "-99", "abc", "12a", "   "})
        @DisplayName("Non-positive or non-numeric strings should throw IllegalArgumentException")
        void testParseOrderId_Invalid(String input) {
            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> VnpayPaymentService.parseOrderId(input));
            assertEquals("Mã giao dịch VNPAY không hợp lệ", ex.getMessage());
        }
    }

    @Nested
    @DisplayName("processCallback Tests")
    class ProcessCallbackTests {

        private Map<String, String[]> createCallbackParams(String txnRef, String amount,
                                                           String responseCode, String transactionStatus) {
            Map<String, String[]> map = new HashMap<>();
            map.put("vnp_TxnRef", new String[]{txnRef});
            map.put("vnp_Amount", new String[]{amount});
            map.put("vnp_ResponseCode", new String[]{responseCode});
            map.put("vnp_TransactionStatus", new String[]{transactionStatus});
            return map;
        }

        @Test
        @DisplayName("Success callback (00 & 00) should pass successful=true to DAO")
        void testProcessCallback_Success() {
            // 20,000,000 / 100 = 200,000.00
            Map<String, String[]> params = createCallbackParams("555", "20000000", "00", "00");
            when(paymentDAO.processCallback(555L, new BigDecimal("200000.00"), true))
                .thenReturn(CallbackResult.SUCCESS);

            CallbackResult result = vnpayPaymentService.processCallback(params);

            assertEquals(CallbackResult.SUCCESS, result);
            verify(paymentDAO).processCallback(555L, new BigDecimal("200000.00"), true);
        }

        @ParameterizedTest(name = "Failed responseCode={0}, txnStatus={1}")
        @CsvSource({
            "24, 02", // User cancelled
            "07, 00", // Suspected fraud
            "09, 00", // Card not registered
            "00, 01"  // Incomplete
        })
        @DisplayName("Non-00 codes should pass successful=false to DAO")
        void testProcessCallback_Failure(String responseCode, String txnStatus) {
            Map<String, String[]> params = createCallbackParams("555", "15000000", responseCode, txnStatus);
            when(paymentDAO.processCallback(555L, new BigDecimal("150000.00"), false))
                .thenReturn(CallbackResult.PAYMENT_FAILED);

            CallbackResult result = vnpayPaymentService.processCallback(params);

            assertEquals(CallbackResult.PAYMENT_FAILED, result);
            verify(paymentDAO).processCallback(555L, new BigDecimal("150000.00"), false);
        }

        @Test
        @DisplayName("Callback with invalid amount string should throw IllegalArgumentException")
        void testProcessCallback_InvalidAmount_Throws() {
            Map<String, String[]> params = createCallbackParams("555", "not_a_number", "00", "00");

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> vnpayPaymentService.processCallback(params));
            assertEquals("Số tiền VNPAY không hợp lệ", ex.getMessage());
            verifyNoInteractions(paymentDAO);
        }

        @Test
        @DisplayName("Callback with invalid txnRef should throw IllegalArgumentException")
        void testProcessCallback_InvalidTxnRef_Throws() {
            Map<String, String[]> params = createCallbackParams("invalid_ref", "10000000", "00", "00");

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> vnpayPaymentService.processCallback(params));
            assertEquals("Mã giao dịch VNPAY không hợp lệ", ex.getMessage());
            verifyNoInteractions(paymentDAO);
        }
    }

    @Nested
    @DisplayName("getOrder Tests")
    class GetOrderTests {

        @Test
        @DisplayName("getOrder should delegate to paymentDAO.getVnpayOrder")
        void testGetOrder_Success() {
            Order mockOrder = new Order();
            mockOrder.setOrderId(999L);
            when(paymentDAO.getVnpayOrder(999L)).thenReturn(mockOrder);

            Order result = vnpayPaymentService.getOrder(999L);

            assertEquals(mockOrder, result);
            verify(paymentDAO).getVnpayOrder(999L);
        }
    }
}
