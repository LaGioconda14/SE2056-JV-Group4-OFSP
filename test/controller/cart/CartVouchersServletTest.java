package controller.cart;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Proxy;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.CartVoucher;
import model.User;
import service.CartVoucherService;

public class CartVouchersServletTest {

    private static int checks;

    public static void main(String[] args) throws Exception {
        StubService service = new StubService();
        CartVouchersServlet servlet = new CartVouchersServlet(service);
        Capture response = call(servlet, null, Map.of());
        check(response.status == 401, "Missing session returns 401");
        check(response.json().has("error"), "Unauthorized JSON error");
        check(!service.called, "Missing session never reads cart");
        response = call(servlet, "invalid", Map.of());
        check(response.status == 401, "Unexpected session attribute rejected");
        User user = new User();
        user.setId(7);
        user.setStatus(0);
        response = call(servlet, user, Map.of());
        check(response.status == 401, "Inactive user rejected");
        user.setStatus(1);
        service.result = List.of(new CartVoucher("1", "SAN10K", "PLATFORM", null,
                null, "PRODUCT", "FIXED_AMOUNT", new BigDecimal("10000.00"),
                new BigDecimal("20000.00"), null, "31/12/2026 23:59", new BigDecimal("0.00"),
                false, "Vui lòng chọn sản phẩm để sử dụng mã giảm giá."));
        response = call(servlet, user, Map.of());
        check(response.status == 200, "Authenticated empty selection succeeds");
        JsonObject disabled = response.json().getAsJsonArray("vouchers").get(0).getAsJsonObject();
        check(!disabled.get("eligible").getAsBoolean(), "Empty selection lists disabled voucher");
        check("Vui lòng chọn sản phẩm để sử dụng mã giảm giá.".equals(disabled.get("reason").getAsString()),
                "Empty selection reason preserved");
        check(disabled.get("discountAmount").getAsBigDecimal().signum() == 0, "Disabled discount zero");
        check(service.itemIds == null && service.quantities == null, "Empty selection forwarded");
        service.result = List.of(new CartVoucher("9007199254740993", "SAN10K", "PLATFORM", null,
                null, "PRODUCT", "FIXED_AMOUNT", new BigDecimal("10000.00"),
                new BigDecimal("20000.00"), null, "31/12/2026 23:59", new BigDecimal("10000.00"),
                true, ""), service.result.get(0));
        response = call(servlet, user, Map.of("itemId", new String[]{"1", "2"}, "quantity", new String[]{"3", "4"}));
        JsonArray vouchers = response.json().getAsJsonArray("vouchers");
        JsonObject voucher = vouchers.get(0).getAsJsonObject();
        check(voucher.size() == 14, "Exact voucher field count");
        check(vouchers.size() == 2 && !vouchers.get(1).getAsJsonObject().get("eligible").getAsBoolean(),
                "Eligible and disabled campaigns returned together");
        check(voucher.get("eligible").getAsJsonPrimitive().isBoolean()
                && voucher.get("eligible").getAsBoolean(), "Eligibility boolean serialized");
        check(voucher.get("reason").getAsJsonPrimitive().isString()
                && "".equals(voucher.get("reason").getAsString()), "Eligible reason is empty string");
        check(voucher.get("couponId").getAsJsonPrimitive().isString(), "Coupon ID serialized as string");
        check("9007199254740993".equals(voucher.get("couponId").getAsString()), "Long ID preserved");
        check(voucher.get("shopId").isJsonNull(), "Nullable shop ID included");
        check(voucher.get("maxDiscountAmount").isJsonNull(), "Nullable cap included");
        check(voucher.get("discountValue").getAsJsonPrimitive().isNumber(), "Discount numeric");
        check(voucher.get("minOrderValue").getAsJsonPrimitive().isNumber(), "Minimum numeric");
        check(voucher.get("discountAmount").getAsJsonPrimitive().isNumber(), "Savings numeric");
        check("31/12/2026 23:59".equals(voucher.get("endDate").getAsString()), "Date string preserved");
        check(service.customerId == 7 && service.itemIds.length == 2
                && "4".equals(service.quantities[1]), "Session ID and aligned parameters passed to service");
        service.failure = new IllegalArgumentException("internal details");
        response = call(servlet, user, Map.of());
        check(response.status == 400, "Invalid cart returns 400");
        check(!response.body.toString().contains("internal details"), "Validation detail not exposed");
        service.failure = new SQLException("secret database connection");
        response = call(servlet, user, Map.of());
        check(response.status == 500, "Database failure returns 500");
        check(!response.body.toString().contains("secret"), "Database detail not exposed");
        service.failure = new IllegalStateException("secret runtime detail");
        response = call(servlet, user, Map.of());
        check(response.status == 500, "Unexpected failure returns 500");
        check(!response.body.toString().contains("secret"), "Runtime detail not exposed");
        System.out.println("CartVouchersServletTest: " + checks + " checks passed");
    }

    private static Capture call(CartVouchersServlet servlet, Object user, Map<String, String[]> parameters)
            throws Exception {
        HttpSession session = user == null ? null : proxy(HttpSession.class, (object, method, arguments) -> {
            if ("getAttribute".equals(method.getName())) {
                return user;
            }
            throw new AssertionError("Unexpected session call: " + method.getName());
        });
        HttpServletRequest request = proxy(HttpServletRequest.class, (object, method, arguments) -> {
            if ("getSession".equals(method.getName())) {
                check(arguments.length == 1 && Boolean.FALSE.equals(arguments[0]), "Does not create session");
                return session;
            }
            if ("getParameterValues".equals(method.getName())) {
                return parameters.get(arguments[0]);
            }
            throw new AssertionError("Unexpected request call: " + method.getName());
        });
        Capture capture = new Capture();
        HttpServletResponse response = proxy(HttpServletResponse.class, (object, method, arguments) -> {
            switch (method.getName()) {
                case "setStatus":
                    capture.status = (Integer) arguments[0];
                    return null;
                case "setContentType":
                    capture.contentType = (String) arguments[0];
                    return null;
                case "setCharacterEncoding":
                    capture.encoding = (String) arguments[0];
                    return null;
                case "setHeader":
                    capture.headers.put((String) arguments[0], (String) arguments[1]);
                    return null;
                case "getWriter":
                    return new PrintWriter(capture.body);
                default:
                    throw new AssertionError("Unexpected response call: " + method.getName());
            }
        });
        servlet.doGet(request, response);
        check("no-store".equals(capture.headers.get("Cache-Control")), "Response never cached");
        check("application/json".equals(capture.contentType), "JSON content type");
        check("UTF-8".equals(capture.encoding), "UTF-8 encoding");
        capture.json();
        return capture;
    }

    private static <T> T proxy(Class<T> type, InvocationHandler handler) {
        return type.cast(Proxy.newProxyInstance(type.getClassLoader(), new Class<?>[]{type}, handler));
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static class Capture {
        private int status = 200;
        private String contentType;
        private String encoding;
        private final Map<String, String> headers = new HashMap<>();
        private final StringWriter body = new StringWriter();

        private JsonObject json() {
            return JsonParser.parseString(body.toString()).getAsJsonObject();
        }
    }

    private static class StubService extends CartVoucherService {
        private boolean called;
        private long customerId;
        private String[] itemIds;
        private String[] quantities;
        private List<CartVoucher> result = List.of();
        private Exception failure;

        @Override
        public List<CartVoucher> findVouchers(long userId, String[] ids, String[] counts) throws SQLException {
            called = true;
            customerId = userId;
            itemIds = ids;
            quantities = counts;
            if (failure instanceof SQLException sqlException) {
                throw sqlException;
            }
            if (failure instanceof RuntimeException runtimeException) {
                throw runtimeException;
            }
            return result;
        }
    }
}
