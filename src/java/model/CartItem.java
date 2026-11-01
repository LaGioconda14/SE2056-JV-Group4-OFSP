package model;

import enums.CartItemAvailability;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class CartItem {
    private long cartItemId;
    private ProductVariant variant;
    private int quantity;
    private int previousQuantity;
    private boolean quantityAdjusted;
    private CartItemAvailability availability = CartItemAvailability.AVAILABLE;
    private List<ProductVariant> alternativeVariants = new ArrayList<>();
    private Promotion promotion;
    private BigDecimal promotionDiscount = BigDecimal.ZERO;
    private int promotionUnits;

    public CartItem() {
    }

    public CartItem(long cartItemId, ProductVariant variant, int quantity) {
        this.cartItemId = cartItemId;
        this.variant = variant;
        this.quantity = quantity;
    }

    public long getCartItemID() {
        return cartItemId;
    }

    public void setCartItemID(long cartItemId) {
        this.cartItemId = cartItemId;
    }

    public long getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(long cartItemId) {
        this.cartItemId = cartItemId;
    }

    public ProductVariant getVariant() {
        return variant;
    }

    public void setVariant(ProductVariant variant) {
        this.variant = variant;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getPreviousQuantity() {
        return previousQuantity;
    }

    public void setPreviousQuantity(int previousQuantity) {
        this.previousQuantity = previousQuantity;
    }

    public boolean isQuantityAdjusted() {
        return quantityAdjusted;
    }

    public void setQuantityAdjusted(boolean quantityAdjusted) {
        this.quantityAdjusted = quantityAdjusted;
    }

    public String getAvailabilityStatus() {
        return availability.name();
    }

    public void setAvailabilityStatus(String availabilityStatus) {
        this.availability = CartItemAvailability.from(availabilityStatus);
    }

    public CartItemAvailability getAvailability() {
        return availability;
    }

    public void setAvailability(CartItemAvailability availability) {
        this.availability = availability != null ? availability : CartItemAvailability.NOT_FOUND;
    }

    public List<ProductVariant> getAlternativeVariants() {
        return alternativeVariants;
    }

    public void setAlternativeVariants(List<ProductVariant> alternativeVariants) {
        this.alternativeVariants = alternativeVariants != null
                ? alternativeVariants : new ArrayList<>();
    }

    public boolean isPurchasable() {
        return availability == CartItemAvailability.AVAILABLE;
    }

    /** Thành tiền GỐC của dòng (chưa tính khuyến mãi). */
    public BigDecimal getOriginalSubtotal() {
        if (variant == null || variant.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        return variant.getPrice()
                .multiply(BigDecimal.valueOf(quantity));
    }

    /** Thành tiền khách phải trả = gốc - khuyến mãi (Promotion). */
    public BigDecimal getSubtotal() {
        return getOriginalSubtotal().subtract(promotionDiscount).max(BigDecimal.ZERO);
    }

    public Promotion getPromotion() { return promotion; }
    public void setPromotion(Promotion promotion) { this.promotion = promotion; }

    public BigDecimal getPromotionDiscount() { return promotionDiscount; }
    public void setPromotionDiscount(BigDecimal promotionDiscount) {
        this.promotionDiscount = promotionDiscount == null ? BigDecimal.ZERO : promotionDiscount;
    }

    public int getPromotionUnits() { return promotionUnits; }
    public void setPromotionUnits(int promotionUnits) { this.promotionUnits = promotionUnits; }

    public boolean isOnPromotion() { return promotion != null && promotionDiscount.signum() > 0; }

    public void clearPromotion() {
        this.promotion = null;
        this.promotionDiscount = BigDecimal.ZERO;
        this.promotionUnits = 0;
    }

    /** Đơn giá hiển thị: giá sau giảm nếu khuyến mãi theo đơn giá áp cho toàn bộ số lượng, ngược lại giá gốc. */
    public BigDecimal getDisplayUnitPrice() {
        if (variant == null || variant.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        if (isOnPromotion() && promotion.isUnitPriceType() && promotionUnits == quantity && quantity > 0) {
            return getSubtotal().divide(BigDecimal.valueOf(quantity), 0, java.math.RoundingMode.HALF_UP);
        }
        return variant.getPrice();
    }

    public boolean isUnitPriceReduced() {
        return variant != null && variant.getPrice() != null
                && getDisplayUnitPrice().compareTo(variant.getPrice()) < 0;
    }
}
