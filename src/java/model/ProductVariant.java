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
public class ProductVariant {

    private long variantId;
    private Product product;
    private String sku;
    private String variantName;
    private String unit;
    private BigDecimal weightKg;
    private BigDecimal price;
    private int stockQuantity;
    private int lowStockThreshold;
    private boolean active;

    public ProductVariant() {
    }

    public ProductVariant(long variantId, Product product, String sku, String variantName,
            String unit, BigDecimal weightKg, BigDecimal price, int stockQuantity,
            int lowStockThreshold, boolean active) {
        this.variantId = variantId;
        this.product = product;
        this.sku = sku;
        this.variantName = variantName;
        this.unit = unit;
        this.weightKg = weightKg;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.lowStockThreshold = lowStockThreshold;
        this.active = active;
    }

    public long getVariantId() {
        return variantId;
    }

    public void setVariantId(long variantId) {
        this.variantId = variantId;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getVariantName() {
        return variantName;
    }

    public void setVariantName(String variantName) {
        this.variantName = variantName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public BigDecimal getWeightKg() {
        return weightKg;
    }

    public void setWeightKg(BigDecimal weightKg) {
        this.weightKg = weightKg;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public int getLowStockThreshold() {
        return lowStockThreshold;
    }

    public void setLowStockThreshold(int lowStockThreshold) {
        this.lowStockThreshold = lowStockThreshold;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
