/**
 * Interactive Scripts for Product Detail (Image Switcher, Variant Selection, Quantity Increment, Tabs)
 */

document.addEventListener("DOMContentLoaded", () => {
    // 1. Gallery Thumbnail Switcher
    const mainImg = document.getElementById("mainProductImg");
    const thumbs = document.querySelectorAll(".detail-thumb-btn");

    thumbs.forEach(thumb => {
        thumb.addEventListener("click", () => {
            thumbs.forEach(t => t.classList.remove("active"));
            thumb.classList.add("active");
            const newSrc = thumb.getAttribute("data-img");
            if (mainImg && newSrc) {
                mainImg.src = newSrc;
            }
        });
    });

    // 2. Quantity Counter & Dynamic Total Price
    const qtyInput = document.getElementById("qtyInput");
    const btnMinus = document.getElementById("btnMinus");
    const btnPlus = document.getElementById("btnPlus");
    const totalPriceDisplay = document.getElementById("totalPriceDisplay");

    let currentPrice = parseFloat(document.getElementById("activeVariantPrice")?.value || 75000);

    function formatMoney(amount) {
        if (amount >= 1000) {
            return new Intl.NumberFormat('vi-VN').format(Math.round(amount)) + ' ₫';
        }
        return '$' + amount.toFixed(2);
    }

    function updatePrice() {
        let qty = parseInt(qtyInput.value) || 1;
        if (qty < 1) qty = 1;
        qtyInput.value = qty;
        let total = qty * currentPrice;
        if (totalPriceDisplay) {
            totalPriceDisplay.textContent = formatMoney(total);
        }
    }

    if (btnMinus && btnPlus && qtyInput) {
        btnMinus.addEventListener("click", () => {
            let val = parseInt(qtyInput.value) || 1;
            if (val > 1) {
                qtyInput.value = val - 1;
                updatePrice();
            }
        });

        btnPlus.addEventListener("click", () => {
            let val = parseInt(qtyInput.value) || 1;
            qtyInput.value = val + 1;
            updatePrice();
        });

        qtyInput.addEventListener("change", updatePrice);
    }

    // 3. Variant Package Selection
    const variantCards = document.querySelectorAll(".variant-option-card");
    variantCards.forEach(card => {
        card.addEventListener("click", () => {
            variantCards.forEach(c => c.classList.remove("active"));
            card.classList.add("active");
            const price = parseFloat(card.getAttribute("data-price"));
            if (price) {
                currentPrice = price;
                const priceMainEl = document.getElementById("mainPriceVal");
                if (priceMainEl) {
                    priceMainEl.textContent = formatMoney(price);
                }
                const oldPriceEl = document.getElementById("mainOldPriceVal");
                const oldPrice = parseFloat(card.getAttribute("data-oldprice"));
                if (oldPriceEl && oldPrice) {
                    oldPriceEl.textContent = formatMoney(oldPrice);
                }
                updatePrice();
            }
        });
    });

    // 4. Detail Tabs Switcher
    const tabBtns = document.querySelectorAll(".detail-tab-btn");
    const tabPanes = document.querySelectorAll(".detail-tab-pane");

    tabBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            tabBtns.forEach(b => b.classList.remove("active"));
            tabPanes.forEach(p => p.classList.add("hidden"));

            btn.classList.add("active");
            const targetId = btn.getAttribute("data-target");
            const targetPane = document.getElementById(targetId);
            if (targetPane) {
                targetPane.classList.remove("hidden");
            }
        });
    });
});

