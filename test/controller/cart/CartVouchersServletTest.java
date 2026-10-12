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
        response = call(servlet, user, Map.of());
        check(response.status == 200, "Authenticated empty selection succeeds");
        check(response.json().getAsJsonArray("vouchers").isEmpty(), "Empty selection response");
        service.result = List.of(new CartVoucher("9007199254740993", "SAN10K", "PLATFORM", null,
                null, "PRODUCT", "FIXED_AMOUNT", new BigDecimal("10000.00"),
                new BigDecimal("20000.00"), null, "31/12/2026 23:59", new BigDecimal("10000.00")));
        response = call(servlet, user, Map.of("itemId", new String[]{"1", "2"}, "quantity", new String[]{"3", "4"}));
        JsonArray vouchers = response.json().getAsJsonArray("vouchers");
        JsonObject voucher = vouchers.get(0).getAsJsonObject();
        check(voucher.size() == 12, "Exact voucher field count");
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
        public List<CartVoucher> findEligible(long userId, String[] ids, String[] counts) throws SQLException {
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
