/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;

/**
 *
 * @author Bac
 */
public class CartItem {
    private long cartItemID;
    private ProductVariant variant;
    private int quantity;

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

    public BigDecimal getSubtotal() {
        return variant.getPrice()
                .multiply(BigDecimal.valueOf(quantity));
    }
}
