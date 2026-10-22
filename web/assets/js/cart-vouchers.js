(() => {
    let selectedPlatformVoucher = null;
    const selectedShopVouchers = {};
    let currentSnapshot = {items: [], subtotal: 0, shopSubtotals: {}, key: ''};
    let requestSequence = 0;
    let pendingRequest = null;
    let lastFocus = null;
    let cachedVouchers = null;
    let revalidateTimer = null;
    let validatedKey = '';
    let currentFilter = {scope: 'PLATFORM', shopId: null, shopName: null};

    const formatCurrency = value => window.CartPage
        ? window.CartPage.formatCurrency(value)
        : new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND', maximumFractionDigits: 0}).format(Number(value) || 0);

    function selectionQuery(snapshot = currentSnapshot) {
        const params = new URLSearchParams();
        snapshot.items.forEach(item => {
            params.append('itemId', item.itemId);
            params.append('quantity', item.quantity);
        });
        return params;
    }

    function setStatus(message, error = false) {
        const output = document.getElementById('voucher-status');
        if (!output) return;
        output.textContent = message;
        output.classList.toggle('text-error', error);
    }

    function cancelRequest() {
        requestSequence += 1;
        pendingRequest?.abort();
        pendingRequest = null;
    }

    async function fetchVouchers(filter = currentFilter, snapshot = currentSnapshot) {
        cancelRequest();
        const requestId = requestSequence;
        const controller = new AbortController();
        pendingRequest = controller;
        const modal = document.getElementById('voucher-modal');
        if (!modal) return null;
        const params = selectionQuery(snapshot);
        if (filter.scope) params.set('scope', filter.scope);
        if (filter.shopId) params.set('shopId', filter.shopId);
        try {
            const response = await fetch(modal.dataset.vouchersUrl + '?' + params.toString(), {
                credentials: 'same-origin', cache: 'no-store', headers: {Accept: 'application/json'}, signal: controller.signal
            });
            if (requestId !== requestSequence || snapshot.key !== currentSnapshot.key) return null;
            if (response.redirected || response.status === 401) throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
            if (!(response.headers.get('content-type') || '').includes('application/json')) throw new Error('Không tải được voucher (HTTP ' + response.status + '). Vui lòng thử lại sau.');
            const result = await response.json();
            if (requestId !== requestSequence || snapshot.key !== currentSnapshot.key) return null;
            if (!response.ok) throw new Error(result.error || 'Không tải được voucher. Vui lòng thử lại.');
            if (!Array.isArray(result.vouchers)) throw new Error('Dữ liệu voucher không hợp lệ.');
            return result.vouchers;
        } catch (error) {
            if (error.name === 'AbortError' || requestId !== requestSequence) return null;
            throw error;
        } finally {
            if (requestId === requestSequence) pendingRequest = null;
        }
    }

    function textElement(tag, className, text) {
        const element = document.createElement(tag);
        element.className = className;
        element.textContent = text;
        return element;
    }

    function filteredVouchers(vouchers) {
        return vouchers.filter(voucher => currentFilter.scope === 'SHOP'
            ? voucher.issuerType === 'SHOP' && (!currentFilter.shopId || String(voucher.shopId) === String(currentFilter.shopId))
            : voucher.issuerType === 'PLATFORM');
    }

    function renderVouchers(vouchers) {
        const list = document.getElementById('voucher-list');
        if (!list) return;
        list.replaceChildren();
        const filtered = filteredVouchers(vouchers);
        const scopeDescription = currentFilter.scope === 'SHOP' ? 'cửa hàng ' + (currentFilter.shopName || 'được chọn') : 'sàn Gốc Vườn';
        if (!filtered.length) {
            setStatus('Hiện chưa có voucher khả dụng cho ' + scopeDescription + '.');
            return;
        }
        setStatus(filtered.filter(voucher => voucher.eligible === true).length + '/' + filtered.length + ' voucher ' + scopeDescription + ' có thể áp dụng.');
        [...filtered].sort((a, b) => Number(b.eligible === true) - Number(a.eligible === true)).forEach(voucher => {
            const eligible = voucher.eligible === true;
            const isShop = voucher.issuerType === 'SHOP';
            const card = textElement('div', 'p-4 rounded-xl border flex items-center justify-between gap-4 transition-colors ' + (eligible ? 'border-primary/40 bg-primary/5 hover:border-primary' : 'border-outline-variant/30 bg-surface-container-low opacity-60'), '');
            const details = textElement('div', 'flex flex-col gap-1 min-w-0', '');
            const header = textElement('div', 'flex items-center gap-2', '');
            header.append(textElement('strong', 'text-base font-bold text-primary break-all', voucher.code), textElement('span', 'px-2 py-0.5 rounded text-[11px] font-semibold ' + (isShop ? 'bg-amber-100 text-amber-900' : 'bg-primary/10 text-primary'), isShop ? 'Shop: ' + (voucher.shopName || voucher.shopId) : 'Voucher Sàn'));
            const reduction = voucher.discountType === 'PERCENTAGE' ? voucher.discountValue + '%' + (voucher.maxDiscountAmount == null ? '' : ' (tối đa ' + formatCurrency(voucher.maxDiscountAmount) + ')') : formatCurrency(voucher.discountValue);
            details.append(header, textElement('span', 'text-sm font-semibold text-on-surface', (voucher.applyTo === 'SHIPPING' ? 'Giảm phí ship ' : 'Giảm tiền hàng ') + reduction), textElement('span', 'text-xs text-on-surface-variant', 'Đơn tối thiểu ' + (isShop ? 'của shop ' : '') + formatCurrency(voucher.minOrderValue)), textElement('span', 'text-xs text-outline', 'HSD: ' + voucher.endDate), textElement('span', 'text-xs font-semibold ' + (eligible ? 'text-primary' : 'text-error'), eligible ? 'Ưu đãi: -' + formatCurrency(voucher.discountAmount) : voucher.reason || 'Chưa đủ điều kiện sử dụng'));
            const button = textElement('button', 'px-4 py-2 rounded-xl font-bold text-xs shrink-0 cursor-pointer shadow-xs transition ' + (eligible ? 'bg-primary text-on-primary hover:bg-[#005323]' : 'bg-surface-container-high text-on-surface-variant cursor-not-allowed'), eligible ? 'Chọn mã' : 'Chưa đủ điều kiện');
            button.type = 'button';
            button.disabled = !eligible;
            if (eligible) button.addEventListener('click', () => chooseVoucher(voucher.code));
            card.append(details, button);
            list.append(card);
        });
    }

    function updateTabs() {
        const platformTab = document.getElementById('tab-voucher-platform');
        const shopTab = document.getElementById('tab-voucher-shop');
        if (!platformTab || !shopTab) return;
        const platform = currentFilter.scope === 'PLATFORM';
        platformTab.className = 'pb-2.5 text-sm font-bold border-b-2 transition-colors cursor-pointer ' + (platform ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant hover:text-primary');
        shopTab.className = 'pb-2.5 text-sm font-bold border-b-2 transition-colors cursor-pointer ' + (!platform ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant hover:text-primary');
        shopTab.textContent = currentFilter.shopName ? 'Voucher Shop (' + currentFilter.shopName + ')' : 'Voucher Cửa Hàng';
    }

    function renderSelection() {
        const validating = Boolean(selectedPlatformVoucher || Object.keys(selectedShopVouchers).length)
            && validatedKey !== currentSnapshot.key;
        const pill = document.getElementById('applied-pill');
        const code = document.getElementById('applied-code-text');
        const discount = document.getElementById('applied-discount-text');
        const input = document.getElementById('coupon-input');
        if (pill) {
            pill.hidden = !selectedPlatformVoucher;
            pill.classList.toggle('inline-flex', Boolean(selectedPlatformVoucher));
        }
        if (code) code.textContent = selectedPlatformVoucher?.code || '';
        if (discount) discount.textContent = selectedPlatformVoucher
            ? (validating ? 'Đang kiểm tra...' : '−' + formatCurrency(selectedPlatformVoucher.discountAmount)) : '';
        if (input && selectedPlatformVoucher) input.value = selectedPlatformVoucher.code;
        document.querySelectorAll('[data-shop-voucher-badge]').forEach(badge => {
            const voucher = selectedShopVouchers[badge.dataset.shopVoucherBadge];
            badge.replaceChildren();
            if (voucher) badge.append(textElement('span', 'px-2 py-0.5 rounded bg-primary/10 text-primary font-bold text-xs', voucher.code + (validating ? ' (đang kiểm tra)' : ' (-' + formatCurrency(voucher.discountAmount) + ')')));
        });
        document.querySelectorAll('[data-cart-action="remove-shop-voucher"]').forEach(button => {
            button.hidden = !selectedShopVouchers[button.dataset.shopId];
        });
        const totalDiscount = getSavings(currentSnapshot).product + getSavings(currentSnapshot).shipping;
        const promoRow = document.getElementById('promo-row');
        const promoAmount = document.getElementById('promo-amount');
        if (promoRow) {
            promoRow.hidden = totalDiscount <= 0;
            promoRow.classList.toggle('flex', totalDiscount > 0);
        }
        if (promoAmount) promoAmount.textContent = '−' + formatCurrency(totalDiscount);
    }

    async function open(scope = 'PLATFORM', shopId = null, shopName = null, trigger = null) {
        const modal = document.getElementById('voucher-modal');
        if (!modal) return;
        lastFocus = trigger || document.activeElement;
        currentFilter = {scope, shopId: shopId ? String(shopId) : null, shopName};
        const title = document.getElementById('voucher-modal-title');
        if (title) title.textContent = scope === 'SHOP' ? 'Voucher của ' + (shopName || 'Cửa hàng') : 'Voucher Sàn Gốc Vườn';
        updateTabs();
        if (!modal.open) modal.showModal();
        document.getElementById('voucher-list')?.replaceChildren();
        setStatus('Đang tải danh sách voucher...');
        try {
            cachedVouchers = await fetchVouchers();
            if (cachedVouchers) renderVouchers(cachedVouchers);
        } catch (error) {
            setStatus(error.message, true);
        }
    }

    function close() {
        const modal = document.getElementById('voucher-modal');
        if (modal?.open) modal.close();
        cancelRequest();
        lastFocus?.focus();
        lastFocus = null;
    }

    async function chooseVoucher(code) {
        setStatus('Đang kiểm tra voucher...');
        try {
            const vouchers = await fetchVouchers();
            if (!vouchers) return;
            const voucher = vouchers.find(item => item.code.toUpperCase() === code.trim().toUpperCase());
            if (!voucher || voucher.eligible !== true) {
                renderVouchers(vouchers);
                setStatus(voucher ? voucher.reason || 'Voucher chưa đủ điều kiện sử dụng.' : 'Mã không hợp lệ hoặc đã hết hạn. Hãy chọn mã khác.', true);
                return;
            }
            if (voucher.issuerType === 'SHOP' && voucher.shopId) selectedShopVouchers[String(voucher.shopId)] = voucher;
            else selectedPlatformVoucher = voucher;
            validatedKey = currentSnapshot.key;
            renderSelection();
            close();
            window.CartPage?.recalculate();
        } catch (error) {
            setStatus(error.message, true);
        }
    }

    async function revalidate() {
        const selected = [selectedPlatformVoucher, ...Object.values(selectedShopVouchers)].filter(Boolean);
        if (!selected.length) return;
        try {
            const vouchers = await fetchVouchers({scope: null, shopId: null}, currentSnapshot);
            if (!vouchers) return;
            let removed = false;
            if (selectedPlatformVoucher) {
                const refreshed = vouchers.find(voucher => voucher.issuerType === 'PLATFORM' && voucher.code === selectedPlatformVoucher.code && voucher.eligible === true);
                if (refreshed) selectedPlatformVoucher = refreshed;
                else { selectedPlatformVoucher = null; removed = true; }
            }
            Object.keys(selectedShopVouchers).forEach(shopId => {
                const selectedVoucher = selectedShopVouchers[shopId];
                const refreshed = vouchers.find(voucher => voucher.issuerType === 'SHOP' && String(voucher.shopId) === shopId && voucher.code === selectedVoucher.code && voucher.eligible === true);
                if (refreshed) selectedShopVouchers[shopId] = refreshed;
                else { delete selectedShopVouchers[shopId]; removed = true; }
            });
            validatedKey = currentSnapshot.key;
            renderSelection();
            if (removed) setStatus('Voucher đã được bỏ vì lựa chọn hiện tại không còn đủ điều kiện.', true);
            window.CartPage?.recalculate();
        } catch (error) {
            setStatus('Không thể kiểm tra lại voucher. Voucher tạm thời không được tính.', true);
            selectedPlatformVoucher = null;
            Object.keys(selectedShopVouchers).forEach(shopId => delete selectedShopVouchers[shopId]);
            validatedKey = '';
            renderSelection();
            window.CartPage?.recalculate();
        }
    }

    function getSavings(snapshot) {
        if (validatedKey !== snapshot.key) return {product: 0, shipping: 0};
        let product = 0;
        let shipping = 0;
        const apply = (voucher, base) => {
            if (!voucher) return;
            const amount = Math.min(Math.max(0, Number(base) || 0), Math.max(0, Number(voucher.discountAmount) || 0));
            if (voucher.applyTo === 'SHIPPING') shipping += Math.min(0, amount);
            else product += amount;
        };
        apply(selectedPlatformVoucher, snapshot.subtotal);
        Object.entries(selectedShopVouchers).forEach(([shopId, voucher]) => apply(voucher, snapshot.shopSubtotals[shopId] || 0));
        return {product: Math.min(product, snapshot.subtotal), shipping};
    }

    function removePlatform() {
        selectedPlatformVoucher = null;
        if (!Object.keys(selectedShopVouchers).length) validatedKey = '';
        const input = document.getElementById('coupon-input');
        if (input) input.value = '';
        renderSelection();
        window.CartPage?.recalculate();
    }

    function removeShop(shopId) {
        delete selectedShopVouchers[String(shopId)];
        if (!selectedPlatformVoucher && !Object.keys(selectedShopVouchers).length) validatedKey = '';
        renderSelection();
        window.CartPage?.recalculate();
    }

    function applyInput() {
        const input = document.getElementById('coupon-input');
        if (!input?.value.trim()) open('PLATFORM', null, null, input);
        else {
            currentFilter = {scope: 'PLATFORM', shopId: null, shopName: null};
            chooseVoucher(input.value.trim());
        }
    }

    function init() {
        currentSnapshot = {...(window.CartPage?.snapshot() || currentSnapshot), key: ''};
        currentSnapshot.key = currentSnapshot.items.map(item => item.itemId + ':' + item.quantity).join('|');
        const modal = document.getElementById('voucher-modal');
        modal?.addEventListener('cancel', event => { event.preventDefault(); close(); });
        modal?.addEventListener('click', event => { if (event.target === modal) close(); });
        modal?.addEventListener('click', event => {
            const button = event.target.closest('[data-voucher-action]');
            if (!button) return;
            if (button.dataset.voucherAction === 'close') close();
            if (button.dataset.voucherAction === 'filter') {
                currentFilter.scope = button.dataset.scope;
                updateTabs();
                if (cachedVouchers) renderVouchers(cachedVouchers);
            }
        });
        document.getElementById('coupon-input')?.addEventListener('keydown', event => {
            if (event.key === 'Enter') { event.preventDefault(); applyInput(); }
        });
        document.addEventListener('cart:selection-changed', event => {
            const changed = currentSnapshot.key !== event.detail.key;
            currentSnapshot = event.detail;
            if (changed && (selectedPlatformVoucher || Object.keys(selectedShopVouchers).length)) {
                validatedKey = '';
                renderSelection();
                window.CartPage?.recalculate();
                window.clearTimeout(revalidateTimer);
                revalidateTimer = window.setTimeout(revalidate, 250);
            }
        });
    }

    window.CartVouchers = {
        open, applyInput, removePlatform, removeShop, getSavings,
        getSelected: () => validatedKey === currentSnapshot.key
            ? {platform: selectedPlatformVoucher, shops: {...selectedShopVouchers}}
            : {platform: null, shops: {}}
    };
    document.addEventListener('DOMContentLoaded', init);
})();
