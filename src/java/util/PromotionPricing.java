package util;

import dao.PromotionDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import model.dto.product.ProductCardDTO;
import model.dto.product.ProductDetailDTO;
import model.dto.product.ProductVariantDetailDTO;
import model.entity.cart.CartItem;
import model.entity.promotion.Promotion;
/**
 * Điểm áp dụng Promotion TẬP TRUNG cho mọi nơi khách hàng nhìn thấy / trả tiền:
 *   - danh sách sản phẩm (home, tìm kiếm, danh mục, shop, wishlist)  -> applyToProducts
 *   - trang chi tiết (sản phẩm + các phân loại)                       -> applyToProductDetail
 *   - giỏ hàng / checkout / tạo đơn                                  -> applyToCartItems
 * Giá luôn được tính lại từ DB ở phía server, không tin dữ liệu từ trình duyệt.
 */
public final class PromotionPricing {

    private PromotionPricing() {
    }

    // ------------------------------------------------------------------
    // Danh sách sản phẩm
    // ------------------------------------------------------------------

    public static void applyToProducts(Collection<ProductCardDTO> products) {
        if (products == null || products.isEmpty()) {
            return;
        }
        Set<Long> ids = new HashSet<>();
        for (ProductCardDTO p : products) {
            ids.add(p.getProductId());
        }
        Map<Long, Promotion> promos = new PromotionDAO().getActivePromotionsByProducts(ids);
        for (ProductCardDTO p : products) {
            applyToProductCard(p, promos.get(p.getProductId()));
        }
    }

    /** Dùng cho trang chi tiết: áp lên sản phẩm và cả các phân loại (variant) của nó. */
    public static void applyToProductDetail(ProductDetailDTO product) {
        if (product == null) {
            return;
        }
        Set<Long> ids = new HashSet<>();
        ids.add(product.getId());
        Promotion promo = new PromotionDAO().getActivePromotionsByProducts(ids).get(product.getId());
        applyToProductDetail(product, promo);
        if (promo != null && promo.isUnitPriceType() && product.getVariants() != null) {
            for (ProductVariantDetailDTO v : product.getVariants()) {
                BigDecimal base = v.getPrice();
                if (base == null) continue;
                BigDecimal discounted = promo.calcDiscountedPrice(base);
                if (discounted.compareTo(base) < 0) {
                    v.setOriginalPrice(base);
                    v.setPrice(discounted);
                }
            }
        }
    }

    private static void applyToProductCard(ProductCardDTO p, Promotion promo) {
        if (p == null || promo == null) {
            return;
        }
        p.setPromotionId(promo.getPromotionId());
        p.setPromotionName(promo.getName());
        p.setPromotionLabel(promo.getBadgeLabel());
        p.setPromotionType(promo.getPromotionType());
        if (promo.isUnitPriceType() && p.getPrice() != null) {
            BigDecimal base = p.getPrice();
            BigDecimal discounted = promo.calcDiscountedPrice(base);
            if (discounted.compareTo(base) < 0) {
                p.setOldPrice(base);
                p.setPrice(discounted);
                int pct = base.signum() <= 0 ? 0
                        : base.subtract(discounted).multiply(BigDecimal.valueOf(100))
                                .divide(base, 0, RoundingMode.HALF_UP).intValue();
                p.setDiscountPercent(pct);
            }
        }
    }

    private static void applyToProductDetail(ProductDetailDTO p, Promotion promo) {
        if (p == null || promo == null) {
            return;
        }
        p.setPromotionId(promo.getPromotionId());
        p.setPromotionName(promo.getName());
        p.setPromotionLabel(promo.getBadgeLabel());
        p.setPromotionCondition(promo.getConditionText());
        p.setPromotionType(promo.getPromotionType());
        p.setPromotionSchedule(promo.getScheduleText());
        p.setPromotionEndDate(promo.getEndDate());
        if (promo.isUnitPriceType() && p.getPrice() != null) {
            BigDecimal base = p.getPrice();
            BigDecimal discounted = promo.calcDiscountedPrice(base);
            if (discounted.compareTo(base) < 0) {
                p.setOldPrice(base);
                p.setPrice(discounted);
                int pct = base.signum() <= 0 ? 0
                        : base.subtract(discounted).multiply(BigDecimal.valueOf(100))
                                .divide(base, 0, RoundingMode.HALF_UP).intValue();
                p.setDiscountPercent(pct);
            }
        }
    }

    // ------------------------------------------------------------------
    // Giỏ hàng / checkout / tạo đơn
    // ------------------------------------------------------------------

    /** Gắn promotion + tiền giảm vào từng dòng giỏ hàng. CartItem.getSubtotal() sẽ là số tiền phải trả. */
    public static void applyToCartItems(Collection<CartItem> items) {
        if (items == null || items.isEmpty()) {
            return;
        }
        Set<Long> ids = new HashSet<>();
        for (CartItem item : items) {
            if (item.getVariant() != null && item.getVariant().getProductId() > 0) {
                ids.add(item.getVariant().getProductId());
            }
        }
        Map<Long, Promotion> promos = new PromotionDAO().getActivePromotionsByProducts(ids);

        // Cùng một sản phẩm có thể nằm ở nhiều phân loại: suất ưu đãi (quota) dùng chung, nên trừ dần theo thứ tự dòng.
        Map<Long, Integer> remaining = new java.util.HashMap<>();
        for (CartItem item : items) {
            item.clearPromotion();
            if (!item.isPurchasable() || item.getVariant() == null
                    || item.getVariant().getPrice() == null) {
                continue;
            }
            Promotion promo = promos.get(item.getVariant().getProductId());
            if (promo == null) {
                continue;
            }
            int left = remaining.computeIfAbsent(promo.getPromotionId(), k -> promo.getRemainingQuota());
            if (left <= 0) {
                continue;
            }
            // Mượn bản sao quota còn lại để tính đúng khi nhiều dòng cùng chia sẻ một chương trình
            Promotion view = copyWithRemaining(promo, left);
            int units = view.eligibleUnits(item.getQuantity());
            BigDecimal discount = view.calcLineDiscount(item.getVariant().getPrice(), item.getQuantity());
            item.setPromotion(promo); // luôn gắn để giao diện gợi ý điều kiện (vd: mua thêm để đủ số lượng)
            if (discount.signum() > 0) {
                item.setPromotionDiscount(discount);
                item.setPromotionUnits(units);
                if (left != Integer.MAX_VALUE) {
                    remaining.put(promo.getPromotionId(), left - units);
                }
            }
        }
    }

    private static Promotion copyWithRemaining(Promotion src, int remaining) {
        Promotion c = new Promotion();
        c.setPromotionId(src.getPromotionId());
        c.setShopId(src.getShopId());
        c.setName(src.getName());
        c.setPromotionType(src.getPromotionType());
        c.setDiscountValue(src.getDiscountValue());
        c.setMaxDiscountAmount(src.getMaxDiscountAmount());
        c.setMinQuantity(src.getMinQuantity());
        if (remaining != Integer.MAX_VALUE) {
            c.setQuota(remaining);
            c.setSoldQuantity(0);
        }
        return c;
    }
}
