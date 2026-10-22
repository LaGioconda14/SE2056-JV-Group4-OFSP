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

    public BigDecimal getSubtotal() {
        if (variant == null || variant.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        return variant.getPrice()
                .multiply(BigDecimal.valueOf(quantity));
    }
}
