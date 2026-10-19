package service;

import dao.CartVoucherDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import model.CartVoucher;
import model.VoucherCartItem;
import model.VoucherCoupon;

public class CartVoucherService {

    private static final BigDecimal ZERO = new BigDecimal("0.00");
    private static final BigDecimal SHIPPING_FEE = new BigDecimal("25000.00");
    private static final BigDecimal FREE_SHIPPING_MINIMUM = new BigDecimal("200000.00");
    private final CartVoucherDAO voucherDAO;

    public CartVoucherService() {
        this(new CartVoucherDAO());
    }

    public CartVoucherService(CartVoucherDAO voucherDAO) {
        this.voucherDAO = voucherDAO;
    }

    public List<CartVoucher> findEligible(long customerId, String[] itemIds, String[] quantities)
            throws SQLException {
        return findVouchers(customerId, itemIds, quantities);
    }

    public List<CartVoucher> findVouchers(long customerId, String[] itemIds, String[] quantities,
            String scope, Long shopId) throws SQLException {
        if (customerId <= 0) {
            throw new IllegalArgumentException("Invalid customer");
        }
        Map<Long, Integer> selection = parseSelection(itemIds, quantities);
        Map<Long, BigDecimal> subtotals = selection.isEmpty() ? Collections.emptyMap()
                : shopSubtotals(selection, voucherDAO.findCartItems(customerId));
        return evaluateVouchers(subtotals, voucherDAO.findActiveCoupons(customerId, scope, shopId));
    }

    public List<CartVoucher> findVouchers(long customerId, String[] itemIds, String[] quantities)
            throws SQLException {
        return findVouchers(customerId, itemIds, quantities, null, null);
    }

    public static Map<Long, Integer> parseSelection(String[] itemIds, String[] quantities) {
        int itemCount = itemIds == null ? 0 : itemIds.length;
        int quantityCount = quantities == null ? 0 : quantities.length;
        if (itemCount != quantityCount) {
            throw new IllegalArgumentException("Invalid selection");
        }
        Map<Long, Integer> selection = new LinkedHashMap<>();
        for (int index = 0; index < itemCount; index++) {
            String itemId = itemIds[index];
            String quantity = quantities[index];
            if (itemId == null || quantity == null || !itemId.matches("[0-9]+")
                    || !quantity.matches("[0-9]+")) {
                throw new IllegalArgumentException("Invalid selection");
            }
            long id = Long.parseLong(itemId);
            int count = Integer.parseInt(quantity);
            if (id <= 0 || count <= 0 || selection.putIfAbsent(id, count) != null) {
                throw new IllegalArgumentException("Invalid selection");
            }
        }
        return selection;
    }

    public static Map<Long, BigDecimal> shopSubtotals(Map<Long, Integer> selection,
            Map<Long, VoucherCartItem> cartItems) {
        Map<Long, BigDecimal> subtotals = new TreeMap<>();
        for (Map.Entry<Long, Integer> entry : selection.entrySet()) {
            VoucherCartItem item = cartItems.get(entry.getKey());
            int quantity = entry.getValue();
            if (item == null || item.itemId() != entry.getKey() || !item.available()
                    || quantity <= 0 || quantity > item.stockQuantity()
                    || item.price() == null || item.price().signum() < 0) {
                throw new IllegalArgumentException("Invalid cart item or quantity");
            }
            BigDecimal subtotal = item.price().multiply(BigDecimal.valueOf(quantity))
                    .setScale(2, RoundingMode.HALF_UP);
            subtotals.merge(item.shopId(), subtotal, BigDecimal::add);
        }
        return subtotals;
    }

    public static List<CartVoucher> eligibleVouchers(Map<Long, BigDecimal> shopSubtotals,
            List<VoucherCoupon> coupons) {
        return evaluateVouchers(shopSubtotals, coupons);
    }

    public static List<CartVoucher> evaluateVouchers(Map<Long, BigDecimal> shopSubtotals,
            List<VoucherCoupon> coupons) {
        List<CartVoucher> vouchers = new ArrayList<>();
        BigDecimal total = shopSubtotals.values().stream().reduce(ZERO, BigDecimal::add);
        BigDecimal shippingFee = total.signum() == 0 || total.compareTo(FREE_SHIPPING_MINIMUM) >= 0
                ? ZERO : SHIPPING_FEE;
        Map<Long, BigDecimal> shopShipping = allocateShipping(shopSubtotals, total, shippingFee);
        for (VoucherCoupon coupon : coupons) {
            vouchers.add(evaluateVoucher(coupon, shopSubtotals, total, shippingFee, shopShipping));
        }
        return vouchers;
    }

    private static CartVoucher evaluateVoucher(VoucherCoupon coupon, Map<Long, BigDecimal> shopSubtotals,
            BigDecimal total, BigDecimal shippingFee, Map<Long, BigDecimal> shopShipping) {
        if (shopSubtotals.isEmpty()) {
            return ineligible(coupon, "Vui lòng chọn sản phẩm để sử dụng mã giảm giá.");
        }
        boolean shopCoupon = "SHOP".equals(coupon.issuerType());
        if (!shopCoupon && !"PLATFORM".equals(coupon.issuerType())) {
            return ineligible(coupon, "Mã giảm giá không hỗ trợ giỏ hàng này.");
        }
        if (shopCoupon && (coupon.shopId() == null || !shopSubtotals.containsKey(coupon.shopId()))) {
            return ineligible(coupon, "Vui lòng chọn sản phẩm của cửa hàng áp dụng mã.");
        }
        BigDecimal subtotal = shopCoupon ? shopSubtotals.get(coupon.shopId()) : total;
        if (subtotal.compareTo(coupon.minOrderValue()) < 0) {
            return ineligible(coupon, shopCoupon
                    ? "Giá trị sản phẩm đã chọn của cửa hàng chưa đạt mức tối thiểu áp dụng mã."
                    : "Tổng giá trị sản phẩm đã chọn chưa đạt mức tối thiểu áp dụng mã.");
        }
        BigDecimal base;
        if ("PRODUCT".equals(coupon.applyTo())) {
            base = subtotal;
        } else if ("SHIPPING".equals(coupon.applyTo())) {
            base = shopCoupon ? shopShipping.get(coupon.shopId()) : shippingFee;
            if (base.signum() <= 0) {
                return ineligible(coupon, "Không có phí vận chuyển để áp dụng mã.");
            }
        } else {
            return ineligible(coupon, "Mã giảm giá không hỗ trợ giỏ hàng này.");
        }
        BigDecimal amount;
        if ("FIXED_AMOUNT".equals(coupon.discountType())) {
            amount = coupon.discountValue();
        } else if ("PERCENTAGE".equals(coupon.discountType())) {
            amount = base.multiply(coupon.discountValue()).movePointLeft(2);
            if (coupon.maxDiscountAmount() != null) {
                amount = amount.min(coupon.maxDiscountAmount());
            }
        } else {
            return ineligible(coupon, "Mã giảm giá không hỗ trợ giỏ hàng này.");
        }
        amount = amount.min(base).setScale(2, RoundingMode.HALF_UP);
        return amount.signum() > 0 ? CartVoucher.from(coupon, amount)
                : ineligible(coupon, "Mã không tạo ra giảm giá cho sản phẩm đã chọn.");
    }

    private static CartVoucher ineligible(VoucherCoupon coupon, String reason) {
        return CartVoucher.from(coupon, ZERO, false, reason);
    }

    private static Map<Long, BigDecimal> allocateShipping(Map<Long, BigDecimal> subtotals,
            BigDecimal total, BigDecimal shippingFee) {
        Map<Long, BigDecimal> allocated = new TreeMap<>();
        BigDecimal remaining = shippingFee;
        int index = 0;
        for (Map.Entry<Long, BigDecimal> shop : new TreeMap<>(subtotals).entrySet()) {
            index++;
            BigDecimal fee = shippingFee.signum() == 0 ? ZERO
                    : index == subtotals.size() ? remaining
                    : shippingFee.multiply(shop.getValue()).divide(total, 2, RoundingMode.DOWN);
            allocated.put(shop.getKey(), fee);
            remaining = remaining.subtract(fee);
        }
        return allocated;
    }
}
