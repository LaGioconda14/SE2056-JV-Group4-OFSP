/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Bac
 */
public class CartItem {
    private long cartItemID;
    private ProductVariant variant;
    private int quantity;
    private int previousQuantity;
    private boolean quantityAdjusted;
    private String availabilityStatus = "AVAILABLE";
    private List<ProductVariant> alternativeVariants = new ArrayList<>();

    public CartItem() {
    }

    public CartItem(long cartItemID, ProductVariant variant, int quantity) {
        this.cartItemID = cartItemID;
        this.variant = variant;
        this.quantity = quantity;
    }

    public long getCartItemID() {
        return cartItemID;
    }

    public void setCartItemID(long cartItemID) {
        this.cartItemID = cartItemID;
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
        return availabilityStatus;
    }

    public void setAvailabilityStatus(String availabilityStatus) {
        this.availabilityStatus = availabilityStatus;
    }

    public List<ProductVariant> getAlternativeVariants() {
        return alternativeVariants;
    }

    public void setAlternativeVariants(List<ProductVariant> alternativeVariants) {
        this.alternativeVariants = alternativeVariants != null
                ? alternativeVariants : new ArrayList<>();
    }

    public boolean isPurchasable() {
        return "AVAILABLE".equals(availabilityStatus);
    }

    public BigDecimal getSubtotal() {
        if (variant == null || variant.getPrice() == null) {
            return BigDecimal.ZERO;
        }
        return variant.getPrice()
                .multiply(BigDecimal.valueOf(quantity));
    }
}
