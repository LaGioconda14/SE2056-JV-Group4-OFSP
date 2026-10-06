/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.security.Timestamp;
import java.util.ArrayList;

/**
 *
 * @author Admin
 */
public class Order {

    private long orderId;
    private long customerId;
    private int couponId;

    private BigDecimal totalGoodAmount;
    private BigDecimal totalShippingFee;

    private BigDecimal platformDiscount;
    private BigDecimal finalAmount;

    private String paymentStatus;

    private Timestamp createAt;
    private Timestamp updateAt;
    
    private List<SubOrder> subOrders = new ArrayList<>();
}
