package service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import dao.CartVoucherDAO;
import model.CartVoucher;
import model.VoucherCartItem;
import model.VoucherCoupon;

public class CartVoucherServiceTest {

    private static int checks;

    public static void main(String[] args) throws SQLException {
        selectionValidation();
        cartValidation();
        eligibility();
        shipping();
        serviceBoundary();
        System.out.println("CartVoucherServiceTest: " + checks + " checks passed");
    }

    private static void selectionValidation() {
        check(CartVoucherService.parseSelection(null, null).isEmpty(), "Empty selection");
        check(CartVoucherService.parseSelection(new String[0], new String[0]).isEmpty(), "Empty arrays");
        check(CartVoucherService.parseSelection(new String[]{"9007199254740993", "2"},
                new String[]{"3", "3"}).size() == 2, "Long IDs and repeated quantity values");
        invalid(() -> CartVoucherService.parseSelection(new String[]{"1"}, null));
        invalid(() -> CartVoucherService.parseSelection(null, new String[]{"1"}));
        invalid(() -> CartVoucherService.parseSelection(new String[]{"1", "01"}, new String[]{"1", "2"}));
        for (String bad : new String[]{"0", "-1", "+1", "1.5", "", " 1", "x", null,
                "9223372036854775808"}) {
            invalid(() -> CartVoucherService.parseSelection(new String[]{bad}, new String[]{"1"}));
        }
        for (String bad : new String[]{"0", "-1", "1.5", "", "x", null, "2147483648"}) {
            invalid(() -> CartVoucherService.parseSelection(new String[]{"1"}, new String[]{bad}));
        }
    }

    private static void cartValidation() {
        Map<Long, VoucherCartItem> cart = Map.of(
                1L, item(1, 1, "10000.25", 3, true),
                2L, item(2, 1, "5000.50", 5, true),
                3L, item(3, 2, "12000", 1, true),
                4L, item(4, 2, "1000", 4, false),
                5L, item(5, 2, "1000", 0, true));
        Map<Long, BigDecimal> subtotals = CartVoucherService.shopSubtotals(Map.of(1L, 3, 2L, 2, 3L, 1), cart);
        money("40001.75", subtotals.get(1L), "Database prices multiplied by selected quantities");
        money("12000.00", subtotals.get(2L), "Separate shop subtotal");
        invalid(() -> CartVoucherService.shopSubtotals(Map.of(99L, 1), cart));
        invalid(() -> CartVoucherService.shopSubtotals(Map.of(4L, 1), cart));
        invalid(() -> CartVoucherService.shopSubtotals(Map.of(5L, 1), cart));
        invalid(() -> CartVoucherService.shopSubtotals(Map.of(1L, 4), cart));
        invalid(() -> CartVoucherService.shopSubtotals(Map.of(1L, 0), cart));
    }

    private static void eligibility() {
        VoucherCoupon fixed = coupon(1, null, "PRODUCT", "FIXED_AMOUNT", "100000", "0", null);
        VoucherCoupon percent = coupon(2, null, "PRODUCT", "PERCENTAGE", "12.5", "0", "100000");
        VoucherCoupon capped = coupon(3, 1L, "PRODUCT", "PERCENTAGE", "90", "0", "2000");
        VoucherCoupon missingShop = coupon(4, 9L, "PRODUCT", "FIXED_AMOUNT", "10000", "0", null);
        VoucherCoupon shopMinimum = coupon(5, 1L, "PRODUCT", "FIXED_AMOUNT", "1000", "20000", null);
        VoucherCoupon platformMinimum = coupon(6, null, "PRODUCT", "FIXED_AMOUNT", "1000", "40000", null);
        List<CartVoucher> vouchers = CartVoucherService.eligibleVouchers(Map.of(1L, bd("10000"), 2L, bd("30000")),
                List.of(fixed, percent, capped, missingShop, shopMinimum, platformMinimum));
        check(vouchers.size() == 6, "All available campaigns remain listed");
        enabled(vouchers.get(0));
        enabled(vouchers.get(1));
        enabled(vouchers.get(2));
        disabled(vouchers.get(3), "Vui lòng chọn sản phẩm của cửa hàng áp dụng mã.");
        disabled(vouchers.get(4), "Giá trị sản phẩm đã chọn của cửa hàng chưa đạt mức tối thiểu áp dụng mã.");
        enabled(vouchers.get(5));
        money("40000.00", vouchers.get(0).discountAmount(), "Fixed bounded by product base");
        money("5000.00", vouchers.get(1).discountAmount(), "Percentage total");
        money("2000.00", vouchers.get(2).discountAmount(), "Percentage cap");
        check("6".equals(vouchers.get(3).couponId()), "Inclusive minimum boundary");
        check(vouchers.get(0).shopId() == null, "Platform null shop ID");
        check("1".equals(vouchers.get(2).shopId()), "Shop ID is string");
        check("31/12/2026 23:59".equals(vouchers.get(0).endDate()), "Formatted expiry");
        money("0.13", CartVoucherService.eligibleVouchers(Map.of(1L, bd("1.00")),
                List.of(percent)).get(0).discountAmount(), "Half up percentage cents");
        check(CartVoucherService.eligibleVouchers(Map.of(1L, bd("0.01")), List.of(percent)).isEmpty(),
                "Rounded zero savings omitted");
        check(CartVoucherService.eligibleVouchers(Map.of(), List.of(fixed)).isEmpty(), "No items no vouchers");
        check(CartVoucherService.eligibleVouchers(Map.of(1L, bd("0")), List.of(fixed)).isEmpty(),
                "Zero product base no vouchers");
        money("10000.00", CartVoucherService.eligibleVouchers(Map.of(1L, bd("10000")), List.of(
                coupon(7, 1L, "PRODUCT", "FIXED_AMOUNT", "50000", "0", null))).get(0).discountAmount(),
                "Shop fixed bounded by shop product base");
    }

    private static void shipping() {
        VoucherCoupon platform = coupon(1, null, "SHIPPING", "FIXED_AMOUNT", "50000", "0", null);
        List<VoucherCoupon> coupons = List.of(platform,
                coupon(2, 1L, "SHIPPING", "FIXED_AMOUNT", "50000", "0", null),
                coupon(3, 2L, "SHIPPING", "FIXED_AMOUNT", "50000", "0", null),
                coupon(4, 3L, "SHIPPING", "FIXED_AMOUNT", "50000", "0", null));
        List<CartVoucher> vouchers = CartVoucherService.eligibleVouchers(
                Map.of(1L, bd("10000"), 2L, bd("10000"), 3L, bd("10000")), coupons);
        money("25000.00", vouchers.get(0).discountAmount(), "Single platform shipping estimate");
        money("8333.33", vouchers.get(1).discountAmount(), "First proportional allocation rounds down");
        money("8333.33", vouchers.get(2).discountAmount(), "Second allocation rounds down");
        money("8333.34", vouchers.get(3).discountAmount(), "Last shop receives remaining cents");
        money("25000.00", vouchers.subList(1, 4).stream().map(CartVoucher::discountAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add), "Allocation preserves total fee");
        vouchers = CartVoucherService.eligibleVouchers(Map.of(1L, bd("10000"), 2L, bd("30000")), coupons);
        money("6250.00", vouchers.get(1).discountAmount(), "Unequal shop allocation");
        money("18750.00", vouchers.get(2).discountAmount(), "Unequal remaining allocation");
        for (String total : new String[]{"0", "200000", "200000.01"}) {
            check(CartVoucherService.eligibleVouchers(Map.of(1L, bd(total)), coupons).isEmpty(),
                    "Free shipping excludes shipping vouchers at " + total);
        }
        money("25000.00", CartVoucherService.eligibleVouchers(Map.of(1L, bd("199999.99")),
                List.of(platform)).get(0).discountAmount(), "Immediately below free shipping threshold");
        check(CartVoucherService.eligibleVouchers(Map.of(1L, bd("10000"), 2L, bd("30000")),
                List.of(coupon(1, 1L, "SHIPPING", "FIXED_AMOUNT", "1000", "20000", null))).isEmpty(),
                "Shipping shop minimum uses goods subtotal, not whole cart");
    }

    private static void serviceBoundary() throws SQLException {
        StubDAO dao = new StubDAO();
        CartVoucherService service = new CartVoucherService(dao);
        check(service.findEligible(7, null, null).isEmpty() && dao.calls == 0,
                "Empty selection never opens database");
        invalid(() -> service.findEligible(7, new String[]{"1", "1"}, new String[]{"1", "2"}));
        check(dao.calls == 0, "Malformed request rejected before DAO");
        invalid(() -> service.findEligible(7, new String[]{"2"}, new String[]{"1"}));
        check(dao.calls == 1, "Foreign item rejected before coupon lookup");
        money("5000.00", service.findEligible(7, new String[]{"1"}, new String[]{"2"})
                .get(0).discountAmount(), "Service uses selected quantity and DB price");
        check(dao.calls == 3, "Valid request reads cart and coupons only");
    }

    private static class StubDAO extends CartVoucherDAO {
        private int calls;

        @Override
        public Map<Long, VoucherCartItem> findCartItems(long customerId) {
            calls++;
            check(customerId == 7, "DAO scoped to session user");
            return Map.of(1L, item(1, 1, "2500", 3, true));
        }

        @Override
        public List<VoucherCoupon> findActiveCoupons() {
            calls++;
            return List.of(coupon(1, null, "PRODUCT", "FIXED_AMOUNT", "10000", "0", null));
        }
    }

    private static VoucherCartItem item(long id, long shop, String price, int stock, boolean available) {
        return new VoucherCartItem(id, shop, bd(price), stock, available);
    }

    private static VoucherCoupon coupon(long id, Long shopId, String applyTo, String type,
            String value, String minimum, String cap) {
        return new VoucherCoupon(id, "CODE" + id, shopId == null ? "PLATFORM" : "SHOP", shopId,
                shopId == null ? null : "Shop " + shopId, applyTo, type, bd(value), bd(minimum),
                cap == null ? null : bd(cap), LocalDateTime.of(2026, 12, 31, 23, 59));
    }

    private static BigDecimal bd(String value) {
        return new BigDecimal(value);
    }

    private static void money(String expected, BigDecimal actual, String message) {
        check(bd(expected).equals(actual), message + ": " + actual);
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static void invalid(CheckedRunnable action) {
        try {
            action.run();
            throw new AssertionError("Expected invalid selection/cart");
        } catch (IllegalArgumentException expected) {
            checks++;
        } catch (Exception unexpected) {
            throw new AssertionError(unexpected);
        }
    }

    private interface CheckedRunnable {
        void run() throws Exception;
    }
}
