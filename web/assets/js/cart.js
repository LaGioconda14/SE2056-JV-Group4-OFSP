(() => {
    const currency = new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
        maximumFractionDigits: 0
    });

    let cart;
    let lastVariantTrigger = null;

    function numberValue(value) {
        const parsed = Number(value);
        return Number.isFinite(parsed) ? parsed : 0;
    }

    function clampQuantity(input) {
        const minimum = numberValue(input.min) || 1;
        const maximum = input.max ? numberValue(input.max) : Number.MAX_SAFE_INTEGER;
        const value = Math.round(numberValue(input.value)) || minimum;
        input.value = String(Math.min(Math.max(value, minimum), maximum));
        return Number(input.value);
    }

    function rows() {
        return cart ? Array.from(cart.querySelectorAll('[data-cart-row]')) : [];
    }

    function purchasableRows() {
        return rows().filter(row => row.dataset.cartStatus === 'AVAILABLE');
    }

    function rowQuantity(row) {
        const input = row.querySelector('[data-quantity-input]');
        return input ? clampQuantity(input) : 1;
    }

    function snapshot() {
        const items = [];
        const shopSubtotals = {};
        let subtotal = 0;

        purchasableRows().forEach(row => {
            const checkbox = row.querySelector('[data-cart-item]');
            if (!checkbox || !checkbox.checked) return;
            const quantity = rowQuantity(row);
            const unitPrice = numberValue(row.dataset.unitPrice);
            const shopId = String(row.dataset.shopId);
            const lineSubtotal = unitPrice * quantity;
            items.push({itemId: String(row.dataset.itemId), shopId, quantity, unitPrice, subtotal: lineSubtotal});
            subtotal += lineSubtotal;
            shopSubtotals[shopId] = (shopSubtotals[shopId] || 0) + lineSubtotal;
        });

        return {items, subtotal, shopSubtotals};
    }

    function selectionKey(currentSnapshot) {
        return currentSnapshot.items.map(item => item.itemId + ':' + item.quantity).join('|');
    }

    function updateCheckboxes() {
        const itemCheckboxes = purchasableRows().map(row => row.querySelector('[data-cart-item]')).filter(Boolean);
        const selectedCount = itemCheckboxes.filter(checkbox => checkbox.checked).length;
        const allChecked = itemCheckboxes.length > 0 && selectedCount === itemCheckboxes.length;

        cart.querySelectorAll('[data-select-all]').forEach(checkbox => {
            checkbox.checked = allChecked;
            checkbox.indeterminate = selectedCount > 0 && !allChecked;
        });
        cart.querySelectorAll('[data-shop-select]').forEach(shopCheckbox => {
            const shopItems = purchasableRows()
                .filter(row => String(row.dataset.shopId) === String(shopCheckbox.dataset.shopId))
                .map(row => row.querySelector('[data-cart-item]'))
                .filter(Boolean);
            const shopSelected = shopItems.filter(checkbox => checkbox.checked).length;
            shopCheckbox.checked = shopItems.length > 0 && shopSelected === shopItems.length;
            shopCheckbox.indeterminate = shopSelected > 0 && shopSelected < shopItems.length;
        });
    }

    function updateSummary() {
        if (!cart) return;
        purchasableRows().forEach(row => {
            const output = row.querySelector('[data-line-subtotal]');
            if (output) output.textContent = currency.format(numberValue(row.dataset.unitPrice) * rowQuantity(row));
        });
        updateCheckboxes();

        const currentSnapshot = snapshot();
        const selectedCount = currentSnapshot.items.length;
        const totalCount = purchasableRows().length;
        const savings = window.CartVouchers
            ? window.CartVouchers.getSavings(currentSnapshot)
            : {product: 0, shipping: 0};
        const delivery = Math.max(0, 0 - numberValue(savings.shipping));
        const total = Math.max(0, currentSnapshot.subtotal - numberValue(savings.product) + delivery);

        document.querySelectorAll('[data-selected-summary-count]').forEach(output => {
            output.replaceChildren('Đã chọn: ');
            const strong = document.createElement('strong');
            strong.className = 'text-on-surface font-bold';
            strong.textContent = selectedCount + '/' + totalCount + ' món';
            output.append(strong);
        });
        const countOutput = document.getElementById('items-count-text');
        const label = document.getElementById('btn-checkout-label');
        const checkout = document.getElementById('btn-checkout');
        const subtotalOutput = document.getElementById('summary-subtotal');
        const deliveryOutput = document.getElementById('summary-delivery');
        const totalOutput = document.getElementById('summary-total');
        if (countOutput) countOutput.textContent = selectedCount + ' món';
        if (label) label.textContent = selectedCount ? 'Mua hàng (' + selectedCount + ')' : 'Chọn món để mua';
        if (checkout) {
            checkout.disabled = selectedCount === 0;
            checkout.setAttribute('aria-disabled', String(selectedCount === 0));
        }
        if (subtotalOutput) subtotalOutput.textContent = currency.format(currentSnapshot.subtotal);
        if (deliveryOutput) deliveryOutput.textContent = currency.format(delivery);
        if (totalOutput) totalOutput.textContent = currency.format(total);

        document.dispatchEvent(new CustomEvent('cart:selection-changed', {
            detail: {...currentSnapshot, key: selectionKey(currentSnapshot)}
        }));
    }

    function changeQuantity(button, offset) {
        const row = button.closest('[data-cart-row]');
        const input = row && row.querySelector('[data-quantity-input]');
        if (!input) return;
        input.value = String(numberValue(input.value) + offset);
        clampQuantity(input);
        updateSummary();
    }

    function openVariant(button) {
        const itemId = button.dataset.itemId;
        const dialog = document.getElementById('variant-dialog-' + itemId);
        if (!dialog || typeof dialog.showModal !== 'function') return;
        lastVariantTrigger = button;
        button.setAttribute('aria-expanded', 'true');
        dialog.showModal();
    }

    function closeVariant(itemId) {
        const dialog = document.getElementById('variant-dialog-' + itemId);
        if (dialog && dialog.open) dialog.close();
    }

    function toggleNotifications(button) {
        const popover = document.getElementById('header-noti-popover');
        if (!popover) return;
        const opening = popover.classList.contains('hidden');
        popover.classList.toggle('hidden', !opening);
        button.setAttribute('aria-expanded', String(opening));
    }

    function submitCheckout() {
        const currentSnapshot = snapshot();
        if (!currentSnapshot.items.length) {
            window.alert('Vui lòng chọn ít nhất một sản phẩm để mua hàng!');
            return;
        }
        const dirty = currentSnapshot.items.some(item => {
            const row = cart.querySelector('[data-cart-row][data-item-id="' + CSS.escape(item.itemId) + '"]');
            const input = row && row.querySelector('[data-quantity-input]');
            return input && String(input.value) !== String(input.dataset.savedQuantity);
        });
        if (dirty) {
            window.alert('Bạn đã thay đổi số lượng. Vui lòng bấm biểu tượng lưu tại từng sản phẩm trước khi mua hàng!');
            return;
        }

        const form = document.getElementById('checkout-form');
        const container = document.getElementById('checkout-form-items');
        const coupon = document.getElementById('checkout-form-coupon');
        if (!form || !container || !coupon) return;
        const hiddenInputs = currentSnapshot.items.map(item => hiddenInput('cartItemIds', item.itemId));
        const vouchers = window.CartVouchers ? window.CartVouchers.getSelected() : {platform: null, shops: {}};
        coupon.value = vouchers.platform && vouchers.platform.code ? vouchers.platform.code : '';
        Object.entries(vouchers.shops || {}).forEach(([shopId, voucher]) => {
            if (voucher && voucher.code) hiddenInputs.push(hiddenInput('shopCoupon_' + shopId, voucher.code));
        });
        container.replaceChildren(...hiddenInputs);
        form.submit();
    }

    function hiddenInput(name, value) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value;
        return input;
    }

    function handleAction(event) {
        const button = event.target.closest('[data-cart-action]');
        if (!button) return;
        const action = button.dataset.cartAction;
        if (action === 'increment') changeQuantity(button, 1);
        if (action === 'decrement') changeQuantity(button, -1);
        if (action === 'open-variant') openVariant(button);
        if (action === 'close-variant') closeVariant(button.dataset.itemId);
        if (action === 'checkout') submitCheckout();
        if (action === 'toggle-notifications') toggleNotifications(button);
        if (action === 'clear-notifications') document.getElementById('header-noti-badge')?.classList.add('hidden');
        if (action === 'open-platform-vouchers') window.CartVouchers?.open('PLATFORM', null, null, button);
        if (action === 'open-shop-vouchers') window.CartVouchers?.open('SHOP', button.dataset.shopId, button.dataset.shopName, button);
        if (action === 'apply-coupon') window.CartVouchers?.applyInput();
        if (action === 'remove-platform-voucher') window.CartVouchers?.removePlatform();
        if (action === 'remove-shop-voucher') window.CartVouchers?.removeShop(button.dataset.shopId);
    }

    function handleChange(event) {
        if (event.target.matches('[data-select-all]')) {
            purchasableRows().forEach(row => { row.querySelector('[data-cart-item]').checked = event.target.checked; });
        } else if (event.target.matches('[data-shop-select]')) {
            purchasableRows().filter(row => String(row.dataset.shopId) === String(event.target.dataset.shopId))
                .forEach(row => { row.querySelector('[data-cart-item]').checked = event.target.checked; });
        } else if (!event.target.matches('[data-cart-item], [data-quantity-input]')) {
            return;
        }
        updateSummary();
    }

    function init() {
        cart = document.querySelector('[data-cart]');
        if (!cart) return;
        document.addEventListener('click', handleAction);
        cart.addEventListener('change', handleChange);
        cart.addEventListener('input', event => {
            if (event.target.matches('[data-quantity-input]')) updateSummary();
        });
        cart.querySelectorAll('[data-remove-form]').forEach(form => form.addEventListener('submit', event => {
            if (!window.confirm('Bạn có chắc muốn xóa sản phẩm này?')) event.preventDefault();
        }));
        document.querySelectorAll('[data-variant-dialog]').forEach(dialog => {
            dialog.addEventListener('click', event => { if (event.target === dialog) dialog.close(); });
            dialog.addEventListener('close', () => {
                document.querySelectorAll('[data-cart-action="open-variant"][data-item-id="' + CSS.escape(dialog.dataset.itemId) + '"]')
                    .forEach(trigger => trigger.setAttribute('aria-expanded', 'false'));
                if (lastVariantTrigger) lastVariantTrigger.focus();
                lastVariantTrigger = null;
            });
        });
        document.addEventListener('click', event => {
            const container = document.getElementById('header-noti-container');
            const popover = document.getElementById('header-noti-popover');
            const button = document.getElementById('header-noti-btn');
            if (container && popover && !container.contains(event.target)) {
                popover.classList.add('hidden');
                button?.setAttribute('aria-expanded', 'false');
            }
        });
        document.addEventListener('keydown', event => {
            if (event.key !== 'Escape') return;
            const popover = document.getElementById('header-noti-popover');
            const button = document.getElementById('header-noti-btn');
            if (popover && !popover.classList.contains('hidden')) {
                popover.classList.add('hidden');
                button?.setAttribute('aria-expanded', 'false');
                button?.focus();
            }
        });
        updateSummary();
    }

    window.CartPage = {formatCurrency: value => currency.format(numberValue(value)), snapshot, recalculate: updateSummary};
    window.addEventListener('pageshow', updateSummary);
    document.addEventListener('DOMContentLoaded', init);
})();
