/**
 * Gốc Vườn - Logic giao diện trang Thanh toán (Checkout)
 * Xử lý: Đổi địa chỉ, chọn voucher shop, chọn voucher sàn, chọn ngày/khung giờ giao hàng chuỗi lạnh,
 * và chuyển đổi phương thức thanh toán.
 */
(() => {
    'use strict';

    function getConfig() {
        return window.CHECKOUT_CONFIG || {};
    }

    function submitCheckoutAction(action, values) {
        values = values || {};
        const form = document.getElementById('checkout-form');
        if (!form) return;
        const actionInput = document.getElementById('checkout-action');
        if (actionInput) {
            actionInput.disabled = false;
            actionInput.value = action;
        }
        ['targetShopId', 'newCouponCode', 'newShopCouponCode'].forEach(id => {
            const input = form.elements.namedItem(id);
            if (input) {
                input.disabled = !(id in values);
                input.value = values[id] || '';
            }
        });
        form.action = getConfig().checkoutUrl || form.action;
        form.submit();
    }

    function openAddressModal() {
        document.getElementById('address-modal')?.showModal();
    }

    function closeAddressModal() {
        const dialog = document.getElementById('address-modal');
        if (dialog) dialog.close();
    }

    function confirmAddressSelection() {
        const selected = document.querySelector('input[name="addressSelection"]:checked');
        if (!selected) {
            closeAddressModal();
            return;
        }

        const nameEl = document.getElementById('display-recipient-name');
        const addrEl = document.getElementById('display-recipient-address');
        const badgeEl = document.getElementById('display-default-badge');

        if (selected.value === 'new') {
            const name = (document.querySelector('input[name="recipientName"]')?.value || '').trim();
            const phone = (document.querySelector('input[name="recipientPhone"]')?.value || '').trim();
            const street = (document.querySelector('input[name="streetAddress"]')?.value || '').trim();
            const city = (document.getElementById('checkoutCitySelect')?.value || '').trim();
            const ward = (document.getElementById('checkoutWardSelect')?.value || '').trim();
            if (!name || !phone || !street || !city || !ward) {
                alert('Vui lòng điền đầy đủ họ tên, số điện thoại, tỉnh/thành phố, phường/xã và địa chỉ cụ thể!');
                return;
            }
            submitCheckoutAction('createAddress');
            return;
        }

        const name = selected.dataset.name;
        const phone = selected.dataset.phone;
        const full = selected.dataset.full;
        const isDef = selected.dataset.default === 'true';

        if (nameEl) nameEl.textContent = name + ' (' + phone + ')';
        if (addrEl) addrEl.textContent = full;
        if (badgeEl) {
            if (isDef) badgeEl.classList.remove('hidden');
            else badgeEl.classList.add('hidden');
        }
        closeAddressModal();
        submitCheckoutAction('selectAddress');
    }

    let currentModalShopId = null;

    function formatVND(amount) {
        if (amount == null) return '0₫';
        return Number(amount).toLocaleString('vi-VN') + '₫';
    }

    function openShopVoucherModal(shopId, shopName, shopSubtotal) {
        currentModalShopId = String(shopId);
        const dialog = document.getElementById('shop-voucher-modal');
        const title = document.getElementById('shop-voucher-modal-title');
        const input = document.getElementById('manual-shop-coupon-input');
        const container = document.getElementById('shop-voucher-list-container');

        if (title) title.textContent = 'Chọn Voucher của ' + (shopName || 'Shop');
        if (input) input.value = '';

        if (container) {
            container.innerHTML = '';
            const config = getConfig();
            const shopCouponsData = config.shopCouponsData || {};
            const appliedShopCouponsData = config.appliedShopCouponsData || {};
            const coupons = shopCouponsData[currentModalShopId] || [];
            const currentApplied = appliedShopCouponsData[currentModalShopId] || '';

            if (coupons.length === 0) {
                container.innerHTML = '<div class="p-6 text-center text-xs text-gray-500 bg-gray-50 rounded-xl border border-gray-100">'
                    + '<span class="material-symbols-outlined text-gray-400 text-3xl mb-1 block">sentiment_dissatisfied</span>'
                    + 'Cửa hàng hiện chưa có voucher hiển thị sẵn. Bạn có thể nhập mã voucher ở trên nếu có!</div>';
            } else {
                coupons.forEach(c => {
                    const isApplied = currentApplied && currentApplied.toUpperCase() === c.code.toUpperCase();
                    const isEligible = Number(shopSubtotal) >= Number(c.minOrderValue);

                    let discountLabel = '';
                    if (c.discountType === 'PERCENTAGE') {
                        discountLabel = 'Giảm ' + c.discountValue + '%';
                        if (c.maxDiscountAmount) {
                            discountLabel += ' (tối đa ' + formatVND(c.maxDiscountAmount) + ')';
                        }
                    } else {
                        discountLabel = 'Giảm ' + formatVND(c.discountValue);
                    }

                    const card = document.createElement('div');
                    card.className = 'p-3.5 border rounded-xl flex items-center justify-between gap-3 text-xs '
                        + (isApplied ? 'border-amber-400 bg-amber-50/50' : (isEligible ? 'border-amber-200 bg-amber-50/30' : 'border-gray-200 bg-gray-50/60 opacity-60'));

                    const info = document.createElement('div');
                    info.className = 'min-w-0 flex-1';

                    const headerRow = document.createElement('div');
                    headerRow.className = 'flex items-center gap-2';

                    const codeStrong = document.createElement('strong');
                    codeStrong.className = 'text-sm font-bold text-amber-800';
                    codeStrong.textContent = c.code;
                    headerRow.appendChild(codeStrong);

                    const tag = document.createElement('span');
                    tag.className = 'px-1.5 py-0.5 rounded text-[10px] bg-amber-100 text-amber-900 font-semibold';
                    tag.textContent = 'Voucher Shop';
                    headerRow.appendChild(tag);

                    if (isApplied) {
                        const appliedBadge = document.createElement('span');
                        appliedBadge.className = 'px-1.5 py-0.5 rounded text-[10px] bg-emerald-100 text-emerald-800 font-bold';
                        appliedBadge.textContent = 'Đang dùng';
                        headerRow.appendChild(appliedBadge);
                    }

                    info.appendChild(headerRow);

                    const desc = document.createElement('p');
                    desc.className = 'text-gray-700 mt-1';
                    desc.textContent = discountLabel + ' · Đơn từ ' + formatVND(c.minOrderValue);
                    info.appendChild(desc);

                    if (!isEligible) {
                        const reason = document.createElement('p');
                        reason.className = 'text-[11px] text-red-500 mt-0.5';
                        reason.textContent = 'Chưa đủ điều kiện (Đơn tối thiểu ' + formatVND(c.minOrderValue) + ')';
                        info.appendChild(reason);
                    }

                    card.appendChild(info);

                    const btn = document.createElement('button');
                    btn.type = 'button';
                    if (isApplied) {
                        btn.className = 'px-3.5 py-1.5 bg-gray-200 text-gray-500 rounded-lg font-bold text-xs cursor-default';
                        btn.textContent = 'Đang chọn';
                        btn.disabled = true;
                    } else if (isEligible) {
                        btn.className = 'px-3.5 py-1.5 bg-amber-600 hover:bg-amber-700 text-white rounded-lg font-bold text-xs cursor-pointer transition';
                        btn.textContent = 'Áp dụng';
                        btn.onclick = function() {
                            applyShopCoupon(currentModalShopId, c.code);
                        };
                    } else {
                        btn.className = 'px-3.5 py-1.5 bg-gray-200 text-gray-400 rounded-lg font-bold text-xs cursor-not-allowed';
                        btn.textContent = 'Chưa đủ';
                        btn.disabled = true;
                    }
                    card.appendChild(btn);

                    container.appendChild(card);
                });
            }
        }

        if (dialog) dialog.showModal();
    }

    function closeShopVoucherModal() {
        const dialog = document.getElementById('shop-voucher-modal');
        if (dialog) dialog.close();
    }

    function applyShopCoupon(shopId, code) {
        if (!code || !code.trim()) return;
        submitCheckoutAction('applyShopCoupon', {targetShopId: shopId, newShopCouponCode: code.trim().toUpperCase()});
    }

    function applyManualShopCoupon() {
        const input = document.getElementById('manual-shop-coupon-input');
        if (!input || !input.value.trim()) {
            alert('Vui lòng nhập mã voucher của shop!');
            return;
        }
        if (currentModalShopId) {
            applyShopCoupon(currentModalShopId, input.value.trim().toUpperCase());
        }
    }

    function removeShopCoupon(shopId) {
        submitCheckoutAction('removeShopCoupon', {targetShopId: shopId});
    }

    function openCheckoutVoucherModal() {
        const dialog = document.getElementById('checkout-voucher-modal');
        if (dialog) dialog.showModal();
    }

    function closeCheckoutVoucherModal() {
        const dialog = document.getElementById('checkout-voucher-modal');
        if (dialog) dialog.close();
    }

    function applyCouponCode(code) {
        submitCheckoutAction('applyCoupon', {newCouponCode: code});
    }

    function applyManualCoupon() {
        const input = document.getElementById('manual-coupon-input');
        if (input && input.value.trim()) {
            applyCouponCode(input.value.trim().toUpperCase());
        }
    }

    function removeCheckoutCoupon() {
        submitCheckoutAction('removeCoupon');
    }

    function initDeliverySlotSystem() {
        const dateTabsContainer = document.getElementById('delivery-date-tabs');
        const slotsGridContainer = document.getElementById('delivery-slots-grid');
        const inputDeliveryDate = document.getElementById('checkout-delivery-date');
        const inputDeliverySlot = document.getElementById('checkout-delivery-slot');

        if (!dateTabsContainer || !slotsGridContainer) return;

        const today = new Date();
        const dates = [];
        const dayNames = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];

        for (let i = 0; i < 4; i++) {
            const d = new Date(today);
            d.setDate(today.getDate() + i);
            const yyyy = d.getFullYear();
            const mm = String(d.getMonth() + 1).padStart(2, '0');
            const dd = String(d.getDate()).padStart(2, '0');
            const dateStr = yyyy + '-' + mm + '-' + dd;

            let label = dd + '/' + mm;
            if (i === 0) label = 'Hôm nay (' + dd + '/' + mm + ')';
            else if (i === 1) label = 'Ngày mai (' + dd + '/' + mm + ')';
            else label = dayNames[d.getDay()] + ' (' + dd + '/' + mm + ')';

            dates.push({ dateStr: dateStr, label: label, isToday: (i === 0) });
        }

        const baseSlots = [
            { code: '08:00 - 10:00', displayLabel: '08:00 - 10:00', period: 'MORNING', periodText: 'Sáng', startHour: 8, startMin: 0, endHour: 10, endMin: 0 },
            { code: '10:00 - 12:00', displayLabel: '10:00 - 12:00', period: 'MORNING', periodText: 'Sáng', startHour: 10, startMin: 0, endHour: 12, endMin: 0 },
            { code: '13:00 - 15:00', displayLabel: '13:00 - 15:00', period: 'AFTERNOON', periodText: 'Chiều', startHour: 13, startMin: 0, endHour: 15, endMin: 0 },
            { code: '15:00 - 17:00', displayLabel: '15:00 - 17:00', period: 'AFTERNOON', periodText: 'Chiều', startHour: 15, startMin: 0, endHour: 17, endMin: 0 },
            { code: '17:00 - 19:00', displayLabel: '17:00 - 19:00', period: 'EVENING', periodText: 'Tối', startHour: 17, startMin: 0, endHour: 19, endMin: 0 },
            { code: '19:00 - 21:00', displayLabel: '19:00 - 21:00', period: 'EVENING', periodText: 'Tối', startHour: 19, startMin: 0, endHour: 21, endMin: 0 }
        ];

        let selectedDate = (inputDeliveryDate && inputDeliveryDate.value) ? inputDeliveryDate.value : dates[0].dateStr;
        let selectedSlotCode = (inputDeliverySlot && inputDeliverySlot.value) ? inputDeliverySlot.value : '';

        function renderDateTabs() {
            dateTabsContainer.innerHTML = '';
            dates.forEach(d => {
                const btn = document.createElement('button');
                btn.type = 'button';
                const isSelected = (d.dateStr === selectedDate);
                btn.className = 'px-4 py-2 rounded-xl text-xs font-semibold border transition cursor-pointer ' +
                    (isSelected
                        ? 'border-2 border-[#00652c] bg-emerald-50 text-[#00652c] font-bold shadow-xs'
                        : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300');
                btn.textContent = d.label;
                btn.addEventListener('click', () => {
                    selectedDate = d.dateStr;
                    if (inputDeliveryDate) inputDeliveryDate.value = selectedDate;
                    renderDateTabs();
                    evaluateAndRenderSlots();
                });
                dateTabsContainer.appendChild(btn);
            });
        }

        function evaluateAndRenderSlots() {
            const now = new Date();
            const isCurrentDateToday = (selectedDate === dates[0].dateStr);
            const currentMinutes = now.getHours() * 60 + now.getMinutes();

            const computedSlots = baseSlots.map(s => {
                const isPassed = isCurrentDateToday && (currentMinutes >= (s.startHour * 60 + s.startMin));
                return {
                    code: s.code,
                    displayLabel: s.displayLabel,
                    period: s.period,
                    periodText: s.periodText,
                    available: !isPassed,
                    statusBadge: isPassed ? 'Quá giờ' : null
                };
            });

            const currentValid = computedSlots.some(s => s.code === selectedSlotCode && s.available);
            if (!currentValid) {
                const firstAvail = computedSlots.find(s => s.available);
                selectedSlotCode = firstAvail ? firstAvail.code : '';
                if (inputDeliverySlot) inputDeliverySlot.value = selectedSlotCode;
            }

            renderSlots(computedSlots);
        }

        function renderSlots(slots) {
            slotsGridContainer.innerHTML = '';
            slots.forEach(slot => {
                const isSelected = (slot.code === selectedSlotCode && slot.available);
                const card = document.createElement('div');
                const periodIcon = slot.period === 'EVENING' ? 'bedtime' : 'wb_sunny';

                if (!slot.available) {
                    card.className = 'p-3 rounded-xl border border-gray-100 bg-gray-50/70 opacity-60 cursor-not-allowed flex items-center justify-between gap-2 text-xs select-none';
                    card.innerHTML =
                        '<div class="flex items-center gap-2.5 min-w-0">' +
                        '  <span class="material-symbols-outlined text-gray-300 text-[20px] shrink-0">' + periodIcon + '</span>' +
                        '  <div class="truncate leading-tight">' +
                        '    <span class="font-medium text-gray-600 block">' + slot.displayLabel + '</span>' +
                        '    <span class="text-[11px] text-gray-400">' + slot.periodText + '</span>' +
                        '  </div>' +
                        '</div>' +
                        '<span class="px-2.5 py-1 rounded-md text-[11px] font-medium shrink-0 bg-gray-100 text-gray-400 border border-gray-200/60">' +
                        (slot.statusBadge || 'Quá giờ') +
                        '</span>';
                } else {
                    card.className = 'p-3 rounded-xl border cursor-pointer transition select-none flex items-center justify-between gap-2 text-xs ' +
                        (isSelected
                            ? 'border-2 border-[#00652c] bg-emerald-50/60 shadow-xs'
                            : 'border-gray-200 hover:border-gray-300 bg-white');

                    card.innerHTML =
                        '<div class="flex items-center gap-2.5 min-w-0">' +
                        '  <span class="material-symbols-outlined ' + (isSelected ? 'text-[#00652c]' : 'text-gray-400') + ' text-[20px] shrink-0">' +
                        (isSelected ? 'check_circle' : periodIcon) +
                        '  </span>' +
                        '  <div class="truncate leading-tight">' +
                        '    <span class="font-bold ' + (isSelected ? 'text-[#00652c]' : 'text-gray-900') + ' block">' + slot.displayLabel + '</span>' +
                        '    <span class="text-[11px] ' + (isSelected ? 'text-emerald-700' : 'text-gray-500') + '">' + slot.periodText + '</span>' +
                        '  </div>' +
                        '</div>';

                    card.addEventListener('click', () => {
                        selectedSlotCode = slot.code;
                        if (inputDeliverySlot) inputDeliverySlot.value = selectedSlotCode;
                        evaluateAndRenderSlots();
                    });
                }
                slotsGridContainer.appendChild(card);
            });
        }

        renderDateTabs();
        if (inputDeliveryDate) inputDeliveryDate.value = selectedDate;
        evaluateAndRenderSlots();
    }

    function initPaymentMethodToggles() {
        const paymentLabels = document.querySelectorAll('.payment-method-pill');
        const submitBtn = document.getElementById('submit-order-btn');
        const paymentForm = document.getElementById('checkout-form');

        paymentLabels.forEach(label => {
            label.addEventListener('click', function() {
                paymentLabels.forEach(l => {
                    l.classList.remove('border-2', 'border-[#00652c]', 'bg-emerald-50/60', 'text-[#00652c]', 'font-bold');
                    l.classList.add('border-gray-200', 'text-gray-700', 'font-medium');
                    const checkIcon = l.querySelector('.material-symbols-outlined');
                    if (checkIcon) checkIcon.remove();
                });

                this.classList.add('border-2', 'border-[#00652c]', 'bg-emerald-50/60', 'text-[#00652c]', 'font-bold');
                this.classList.remove('border-gray-200', 'text-gray-700', 'font-medium');

                const check = document.createElement('span');
                check.className = 'material-symbols-outlined text-[16px]';
                check.textContent = 'check';
                this.prepend(check);

                const radio = this.querySelector('input[type="radio"]');
                if (radio) {
                    radio.checked = true;
                    if (radio.value === 'VNPAY') {
                        if (submitBtn) submitBtn.textContent = 'Thanh toán qua VNPAY';
                    } else {
                        if (submitBtn) submitBtn.textContent = 'Đặt hàng';
                    }
                }
            });
        });

        if (paymentForm) {
            paymentForm.addEventListener('submit', function(e) {
                const slotInput = document.getElementById('checkout-delivery-slot');
                if (!slotInput || !slotInput.value || slotInput.value.trim() === '') {
                    e.preventDefault();
                    alert('Vui lòng chọn khung giờ nhận hàng khả dụng (hoặc chuyển sang ngày khác nếu hôm nay đã quá giờ)!');
                    const slotSection = document.getElementById('delivery-slots-grid');
                    if (slotSection) {
                        slotSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                    return false;
                }
            });
        }

        if (paymentForm?.querySelector('input[name="paymentMethod"]:checked')?.value === 'VNPAY') {
            if (submitBtn) submitBtn.textContent = 'Thanh toán qua VNPAY';
        }
    }

    function initListeners() {
        document.getElementById('checkoutCitySelect')?.addEventListener('change', () => submitCheckoutAction('selectProvince'));

        document.getElementById('checkout-form')?.addEventListener('submit', function(event) {
            if (document.getElementById('checkout-action')?.disabled &&
                    document.querySelector('input[name="addressSelection"]:checked')?.value === 'new') {
                event.preventDefault();
                openAddressModal();
                alert('Vui lòng xác nhận và lưu địa chỉ mới trước khi đặt hàng!');
            }
        });

        document.querySelectorAll('input[name="addressSelection"]').forEach(radio => {
            radio.addEventListener('change', function() {
                const newInputs = document.getElementById('new-address-inputs');
                if (newInputs) {
                    if (this.value === 'new') {
                        newInputs.classList.remove('hidden');
                    } else {
                        newInputs.classList.add('hidden');
                    }
                }
            });
        });

        const manualPlatform = document.getElementById('manual-coupon-input');
        if (manualPlatform) {
            manualPlatform.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    applyManualCoupon();
                }
            });
        }

        const manualShop = document.getElementById('manual-shop-coupon-input');
        if (manualShop) {
            manualShop.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    applyManualShopCoupon();
                }
            });
        }

        const shopDialog = document.getElementById('shop-voucher-modal');
        if (shopDialog) {
            shopDialog.addEventListener('click', function(e) {
                if (e.target === shopDialog) closeShopVoucherModal();
            });
        }

        const platformDialog = document.getElementById('checkout-voucher-modal');
        if (platformDialog) {
            platformDialog.addEventListener('click', function(e) {
                if (e.target === platformDialog) closeCheckoutVoucherModal();
            });
        }

        if (getConfig().openAddressModal) {
            openAddressModal();
        }
    }

    // Xuất các hàm để các nút onclick trong HTML tiếp tục hoạt động
    window.submitCheckoutAction = submitCheckoutAction;
    window.openAddressModal = openAddressModal;
    window.closeAddressModal = closeAddressModal;
    window.confirmAddressSelection = confirmAddressSelection;
    window.openShopVoucherModal = openShopVoucherModal;
    window.closeShopVoucherModal = closeShopVoucherModal;
    window.applyShopCoupon = applyShopCoupon;
    window.applyManualShopCoupon = applyManualShopCoupon;
    window.removeShopCoupon = removeShopCoupon;
    window.openCheckoutVoucherModal = openCheckoutVoucherModal;
    window.closeCheckoutVoucherModal = closeCheckoutVoucherModal;
    window.applyCouponCode = applyCouponCode;
    window.applyManualCoupon = applyManualCoupon;
    window.removeCheckoutCoupon = removeCheckoutCoupon;

    document.addEventListener('DOMContentLoaded', () => {
        initDeliverySlotSystem();
        initPaymentMethodToggles();
        initListeners();
    });
})();
