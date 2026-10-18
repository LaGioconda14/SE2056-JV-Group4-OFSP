(() => {
    let selectedVoucher = null;
    let selectedKey = '';
    let requestId = 0;
    let pendingRequest = null;
    let lastFocus = null;

    function selection() {
        const params = new URLSearchParams();
        document.querySelectorAll('[id^="cart-item-"]').forEach(row => {
            const checkbox = row.querySelector('.item-checkbox');
            const quantity = row.querySelector('input[name="quantity"]');
            if (row.dataset.cartStatus === 'AVAILABLE' && checkbox && checkbox.checked && quantity) {
                params.append('itemId', row.dataset.itemId);
                params.append('quantity', quantity.value);
            }
        });
        return params.toString();
    }

    function status(message, error = false) {
        const element = document.getElementById('voucher-status');
        element.textContent = message;
        element.classList.toggle('text-error', error);
    }

    function clearRequest() {
        requestId++;
        if (pendingRequest) pendingRequest.abort();
        pendingRequest = null;
    }

    async function fetchVouchers(key) {
        clearRequest();
        const currentId = requestId;
        const controller = new AbortController();
        pendingRequest = controller;
        const modal = document.getElementById('voucher-modal');
        try {
            const response = await fetch(modal.dataset.vouchersUrl + (key ? '?' + key : ''), {
                credentials: 'same-origin',
                cache: 'no-store',
                headers: {Accept: 'application/json'},
                signal: controller.signal
            });
            if (currentId !== requestId || key !== selection()) return null;
            if (response.redirected || response.status === 401) {
                throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
            }
            if (!(response.headers.get('content-type') || '').includes('application/json')) {
                throw new Error('Không tải được voucher (HTTP ' + response.status + '). Vui lòng tải lại trang hoặc thử lại sau.');
            }
            const result = await response.json();
            if (currentId !== requestId || key !== selection()) return null;
            if (!response.ok) throw new Error(result.error || 'Không tải được voucher. Vui lòng thử lại.');
            if (!Array.isArray(result.vouchers)) throw new Error('Dữ liệu voucher không hợp lệ.');
            return result.vouchers;
        } catch (error) {
            if (error.name === 'AbortError' || currentId !== requestId || key !== selection()) return null;
            throw error;
        } finally {
            if (currentId === requestId) pendingRequest = null;
        }
    }

    function textElement(tag, className, text) {
        const element = document.createElement(tag);
        element.className = className;
        element.textContent = text;
        return element;
    }

    function renderVouchers(vouchers) {
        const list = document.getElementById('voucher-list');
        list.replaceChildren();
        const eligibleCount = vouchers.filter(voucher => voucher.eligible === true).length;
        status(vouchers.length ? eligibleCount + '/' + vouchers.length + ' voucher có thể sử dụng.' : 'Hiện chưa có voucher nào đang phát hành.');
        [...vouchers].sort((a, b) => Number(b.eligible === true) - Number(a.eligible === true)).forEach(voucher => {
            const eligible = voucher.eligible === true;
            const card = textElement('div', 'p-4 rounded-xl border flex items-center justify-between gap-4 '
                + (eligible ? 'border-primary/40 bg-primary/5' : 'border-outline-variant/30 bg-surface-container-low opacity-50'), '');
            const details = textElement('div', 'flex flex-col gap-1 min-w-0', '');
            const scope = voucher.issuerType === 'SHOP' ? 'Shop: ' + (voucher.shopName || voucher.shopId) : 'Voucher sàn';
            const target = voucher.applyTo === 'SHIPPING' ? 'Giảm phí ship' : 'Giảm tiền hàng';
            const reduction = voucher.discountType === 'PERCENTAGE'
                ? voucher.discountValue + '%' + (voucher.maxDiscountAmount == null ? '' : ' (tối đa ' + formatVND(voucher.maxDiscountAmount) + ')')
                : formatVND(voucher.discountValue);
            details.append(
                textElement('strong', 'text-sm text-primary break-all', voucher.code),
                textElement('span', 'text-xs font-semibold text-on-surface', scope),
                textElement('span', 'text-sm', target + ' ' + reduction),
                textElement('span', 'text-xs text-on-surface-variant', 'Tiền hàng ' + (voucher.issuerType === 'SHOP' ? 'của shop ' : '') + 'từ ' + formatVND(voucher.minOrderValue)),
                textElement('span', 'text-xs text-outline', 'HSD: ' + voucher.endDate),
                textElement('span', 'text-xs font-semibold ' + (eligible ? 'text-primary' : 'text-on-surface-variant'),
                    eligible ? 'Tạm giảm: ' + formatVND(voucher.discountAmount) : (voucher.reason || 'Chưa đủ điều kiện sử dụng'))
            );
            const button = textElement('button', 'px-3.5 py-1.5 rounded-lg font-semibold text-xs shrink-0 '
                + (eligible ? 'bg-primary text-on-primary' : 'bg-surface-container-high text-on-surface-variant cursor-not-allowed'), eligible ? 'Chọn' : 'Chưa đủ điều kiện');
            button.type = 'button';
            button.disabled = !eligible;
            if (eligible) button.addEventListener('click', () => chooseVoucher(voucher.code));
            card.append(details, button);
            list.append(card);
        });
    }

    window.openVoucherModal = async function () {
        const modal = document.getElementById('voucher-modal');
        lastFocus = document.activeElement;
        if (!modal.open) modal.showModal();
        document.getElementById('voucher-list').replaceChildren();
        const key = selection();
        status('Đang tải voucher...');
        try {
            const vouchers = await fetchVouchers(key);
            if (vouchers) renderVouchers(vouchers);
        } catch (error) {
            status(error.message, true);
        }
    };

    window.closeVoucherModal = function () {
        document.getElementById('voucher-modal').close();
        clearRequest();
        if (lastFocus) lastFocus.focus();
    };

    window.chooseVoucher = async function (code) {
        const modal = document.getElementById('voucher-modal');
        if (!modal.open) {
            lastFocus = document.activeElement;
            modal.showModal();
        }
        const key = selection();
        document.getElementById('voucher-list').replaceChildren();
        status('Đang kiểm tra mã...');
        try {
            const vouchers = await fetchVouchers(key);
            if (!vouchers) return;
            const voucher = vouchers.find(item => item.code.toUpperCase() === code.trim().toUpperCase());
            if (!voucher || voucher.eligible !== true) {
                renderVouchers(vouchers);
                status(voucher ? voucher.reason || 'Voucher chưa đủ điều kiện sử dụng.' : 'Mã không hợp lệ hoặc đã hết hạn. Hãy chọn mã khác.', true);
                return;
            }
            selectedVoucher = voucher;
            selectedKey = key;
            document.getElementById('coupon-input').value = voucher.code;
            closeVoucherModal();
            recalcTotals();
        } catch (error) {
            status(error.message, true);
        }
    };

    window.applyCoupon = function () {
        const input = document.getElementById('coupon-input');
        if (!input.value.trim()) {
            openVoucherModal();
            return;
        }
        chooseVoucher(input.value);
    };

    window.removeCoupon = function () {
        clearRequest();
        selectedVoucher = null;
        selectedKey = '';
        document.getElementById('coupon-input').value = '';
        recalcTotals();
    };

    window.cartVoucherSavings = function (subtotal, delivery) {
        if (selectedVoucher && selectedKey !== selection()) {
            selectedVoucher = null;
            selectedKey = '';
            document.getElementById('coupon-input').value = '';
        }
        const shipping = selectedVoucher && selectedVoucher.applyTo === 'SHIPPING'
            ? Math.min(delivery, Number(selectedVoucher.discountAmount)) : 0;
        const product = selectedVoucher && selectedVoucher.applyTo === 'PRODUCT'
            ? Math.min(subtotal, Number(selectedVoucher.discountAmount)) : 0;
        const pill = document.getElementById('applied-pill');
        if (pill) {
            pill.style.display = selectedVoucher ? 'inline-flex' : 'none';
            document.getElementById('applied-code-text').textContent = selectedVoucher ? selectedVoucher.code : '';
            document.getElementById('applied-discount-text').textContent = selectedVoucher ? '−' + formatVND(product + shipping) : '';
            document.getElementById('promo-row').style.display = product + shipping > 0 ? 'flex' : 'none';
            document.getElementById('promo-amount').textContent = '−' + formatVND(product + shipping);
        }
        return {product, shipping};
    };

    document.addEventListener('DOMContentLoaded', () => {
        const modal = document.getElementById('voucher-modal');
        modal.addEventListener('cancel', clearRequest);
        modal.addEventListener('click', event => {
            if (event.target === modal) closeVoucherModal();
        });
        const input = document.getElementById('coupon-input');
        if (input) input.addEventListener('keydown', event => {
            if (event.key === 'Enter') {
                event.preventDefault();
                applyCoupon();
            }
        });
    });
})();
