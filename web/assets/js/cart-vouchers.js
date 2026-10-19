(() => {
    let selectedPlatformVoucher = null;
    let selectedShopVouchers = {}; // { [shopId]: voucher }
    let selectedKey = '';
    let requestId = 0;
    let pendingRequest = null;
    let lastFocus = null;
    let cachedVouchers = null;
    let currentFilter = { scope: 'PLATFORM', shopId: null, shopName: null };

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
        if (element) {
            element.textContent = message;
            element.classList.toggle('text-error', error);
        }
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
        if (!modal) return null;
        try {
            const params = new URLSearchParams(key || '');
            if (currentFilter.scope) {
                params.set('scope', currentFilter.scope);
            }
            if (currentFilter.shopId) {
                params.set('shopId', currentFilter.shopId);
            }
            const query = params.toString();
            const response = await fetch(modal.dataset.vouchersUrl + (query ? '?' + query : ''), {
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
                throw new Error('Không tải được voucher (HTTP ' + response.status + '). Vui lòng thử lại sau.');
            }
            const result = await response.json();
            if (currentId !== requestId || key !== selection()) return null;
            if (!response.ok) throw new Error(result.error || 'Không tải được voucher. Vui lòng thử lại.');
            if (!Array.isArray(result.vouchers)) throw new Error('Dữ liệu voucher không hợp lệ.');
            cachedVouchers = result.vouchers;
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

    function filterVouchers(vouchers) {
        if (!Array.isArray(vouchers)) return [];
        if (currentFilter.scope === 'SHOP') {
            return vouchers.filter(v => {
                if (v.issuerType !== 'SHOP') return false;
                if (currentFilter.shopId) {
                    return String(v.shopId) === String(currentFilter.shopId);
                }
                return true;
            });
        } else if (currentFilter.scope === 'PLATFORM') {
            return vouchers.filter(v => v.issuerType === 'PLATFORM');
        }
        return vouchers;
    }

    function renderVouchers(vouchers) {
        const list = document.getElementById('voucher-list');
        if (!list) return;
        list.replaceChildren();

        const filtered = filterVouchers(vouchers);
        const eligibleCount = filtered.filter(voucher => voucher.eligible === true).length;
        const scopeDesc = currentFilter.scope === 'SHOP'
            ? ('cửa hàng ' + (currentFilter.shopName || 'được chọn'))
            : 'sàn Gốc Vườn';

        if (filtered.length === 0) {
            status('Hiện chưa có voucher khả dụng cho ' + scopeDesc + '.');
            return;
        }

        status(eligibleCount + '/' + filtered.length + ' voucher ' + scopeDesc + ' có thể áp dụng.');

        [...filtered].sort((a, b) => Number(b.eligible === true) - Number(a.eligible === true)).forEach(voucher => {
            const eligible = voucher.eligible === true;
            const card = textElement('div', 'p-4 rounded-xl border flex items-center justify-between gap-4 transition-colors '
                + (eligible ? 'border-primary/40 bg-primary/5 hover:border-primary' : 'border-outline-variant/30 bg-surface-container-low opacity-60'), '');
            const details = textElement('div', 'flex flex-col gap-1 min-w-0', '');
            const isShop = voucher.issuerType === 'SHOP';
            const scopeTag = isShop ? ('Shop: ' + (voucher.shopName || voucher.shopId)) : 'Voucher Sàn';
            const target = voucher.applyTo === 'SHIPPING' ? 'Giảm phí ship' : 'Giảm tiền hàng';
            const reduction = voucher.discountType === 'PERCENTAGE'
                ? voucher.discountValue + '%' + (voucher.maxDiscountAmount == null ? '' : ' (tối đa ' + formatVND(voucher.maxDiscountAmount) + ')')
                : formatVND(voucher.discountValue);

            const headerRow = textElement('div', 'flex items-center gap-2', '');
            headerRow.append(
                textElement('strong', 'text-base font-bold text-primary break-all', voucher.code),
                textElement('span', 'px-2 py-0.5 rounded text-[11px] font-semibold ' + (isShop ? 'bg-amber-100 text-amber-900' : 'bg-primary/10 text-primary'), scopeTag)
            );

            details.append(
                headerRow,
                textElement('span', 'text-sm font-semibold text-on-surface', target + ' ' + reduction),
                textElement('span', 'text-xs text-on-surface-variant', 'Đơn tối thiểu ' + (isShop ? 'của shop ' : '') + formatVND(voucher.minOrderValue)),
                textElement('span', 'text-xs text-outline', 'HSD: ' + voucher.endDate),
                textElement('span', 'text-xs font-semibold ' + (eligible ? 'text-primary' : 'text-error'),
                    eligible ? 'Ưu đãi: -' + formatVND(voucher.discountAmount) : (voucher.reason || 'Chưa đủ điều kiện sử dụng'))
            );

            const button = textElement('button', 'px-4 py-2 rounded-xl font-bold text-xs shrink-0 cursor-pointer shadow-xs transition '
                + (eligible ? 'bg-primary text-on-primary hover:bg-[#005323]' : 'bg-surface-container-high text-on-surface-variant cursor-not-allowed'), eligible ? 'Chọn mã' : 'Chưa đủ điều kiện');
            button.type = 'button';
            button.disabled = !eligible;
            if (eligible) {
                button.addEventListener('click', () => chooseVoucher(voucher.code, voucher.issuerType, voucher.shopId));
            }
            card.append(details, button);
            list.append(card);
        });
    }

    function updateTabStyles() {
        const tabPlatform = document.getElementById('tab-voucher-platform');
        const tabShop = document.getElementById('tab-voucher-shop');
        if (tabPlatform && tabShop) {
            const isPlatform = currentFilter.scope === 'PLATFORM';
            tabPlatform.className = 'pb-2.5 text-sm font-bold border-b-2 transition-colors cursor-pointer '
                + (isPlatform ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant hover:text-primary');
            tabShop.className = 'pb-2.5 text-sm font-bold border-b-2 transition-colors cursor-pointer '
                + (!isPlatform ? 'border-primary text-primary' : 'border-transparent text-on-surface-variant hover:text-primary');
            if (currentFilter.shopName) {
                tabShop.textContent = 'Voucher Shop (' + currentFilter.shopName + ')';
            } else {
                tabShop.textContent = 'Voucher Cửa Hàng';
            }
        }
    }

    window.setVoucherFilter = function(scope) {
        currentFilter.scope = scope;
        updateTabStyles();
        const title = document.getElementById('voucher-modal-title');
        if (title) {
            title.textContent = scope === 'SHOP'
                ? ('Voucher của ' + (currentFilter.shopName || 'Cửa hàng'))
                : 'Voucher Sàn Gốc Vườn';
        }
        if (cachedVouchers) {
            renderVouchers(cachedVouchers);
        }
    };

    window.openVoucherModal = async function (scope = 'PLATFORM', shopId = null, shopName = null) {
        const modal = document.getElementById('voucher-modal');
        if (!modal) return;
        lastFocus = document.activeElement;
        currentFilter = { scope: scope || 'PLATFORM', shopId: shopId ? String(shopId) : null, shopName: shopName };

        const title = document.getElementById('voucher-modal-title');
        if (title) {
            title.textContent = scope === 'SHOP'
                ? ('Voucher của ' + (shopName || 'Cửa hàng'))
                : 'Voucher Sàn Gốc Vườn';
        }
        updateTabStyles();

        if (!modal.open) modal.showModal();
        const list = document.getElementById('voucher-list');
        if (list) list.replaceChildren();

        const key = selection();
        status('Đang tải danh sách voucher...');
        try {
            const vouchers = await fetchVouchers(key);
            if (vouchers) renderVouchers(vouchers);
        } catch (error) {
            status(error.message, true);
        }
    };

    window.closeVoucherModal = function () {
        const modal = document.getElementById('voucher-modal');
        if (modal && modal.open) modal.close();
        clearRequest();
        if (lastFocus) lastFocus.focus();
    };

    window.chooseVoucher = async function (code, issuerType = null, shopId = null) {
        const key = selection();
        status('Đang kiểm tra voucher...');
        try {
            const vouchers = await fetchVouchers(key);
            if (!vouchers) return;
            const voucher = vouchers.find(item => item.code.toUpperCase() === code.trim().toUpperCase());
            if (!voucher || voucher.eligible !== true) {
                renderVouchers(vouchers);
                status(voucher ? voucher.reason || 'Voucher chưa đủ điều kiện sử dụng.' : 'Mã không hợp lệ hoặc đã hết hạn. Hãy chọn mã khác.', true);
                return;
            }

            if (voucher.issuerType === 'SHOP' && voucher.shopId) {
                selectedShopVouchers[voucher.shopId] = voucher;
                const badge = document.getElementById('shop-voucher-badge-' + voucher.shopId);
                const btnRemove = document.getElementById('btn-remove-shop-voucher-' + voucher.shopId);
                if (badge) {
                    badge.innerHTML = '<span class="px-2 py-0.5 rounded bg-primary/10 text-primary font-bold text-xs">'
                        + voucher.code + ' (-' + formatVND(voucher.discountAmount) + ')</span>';
                }
                if (btnRemove) btnRemove.style.display = 'inline-block';
            } else {
                selectedPlatformVoucher = voucher;
                const pill = document.getElementById('applied-pill');
                const codeText = document.getElementById('applied-code-text');
                const discountText = document.getElementById('applied-discount-text');
                if (pill) pill.style.display = 'inline-flex';
                if (codeText) codeText.textContent = voucher.code;
                if (discountText) discountText.textContent = '−' + formatVND(voucher.discountAmount);
                const input = document.getElementById('coupon-input');
                if (input) input.value = voucher.code;

                // Sync main input for checkout form
                const formCoupon = document.getElementById('checkout-form-coupon');
                if (formCoupon) {
                    formCoupon.value = voucher.code;
                }
            }

            closeVoucherModal();
            recalcTotals();
        } catch (error) {
            status(error.message, true);
        }
    };

    window.getSelectedVouchers = function () {
        return {
            platform: selectedPlatformVoucher,
            shops: selectedShopVouchers
        };
    };

    window.applyCoupon = function () {
        const input = document.getElementById('coupon-input');
        if (!input || !input.value.trim()) {
            openVoucherModal('PLATFORM');
            return;
        }
        chooseVoucher(input.value.trim(), 'PLATFORM');
    };

    window.removeCoupon = function () {
        selectedPlatformVoucher = null;
        const pill = document.getElementById('applied-pill');
        if (pill) pill.style.display = 'none';
        const input = document.getElementById('coupon-input');
        if (input) input.value = '';
        const formCoupon = document.getElementById('checkout-form-coupon');
        if (formCoupon) formCoupon.value = '';
        recalcTotals();
    };

    window.removeShopVoucher = function (shopId) {
        if (selectedShopVouchers[shopId]) {
            delete selectedShopVouchers[shopId];
        }
        const badge = document.getElementById('shop-voucher-badge-' + shopId);
        if (badge) badge.innerHTML = '';
        const btnRemove = document.getElementById('btn-remove-shop-voucher-' + shopId);
        if (btnRemove) btnRemove.style.display = 'none';
        recalcTotals();
    };

    window.cartVoucherSavings = function (subtotal, delivery) {
        const key = selection();
        if (selectedKey !== key) {
            selectedKey = key;
        }

        let totalProduct = 0;
        let totalShipping = 0;

        if (selectedPlatformVoucher) {
            if (selectedPlatformVoucher.applyTo === 'SHIPPING') {
                totalShipping += Math.min(delivery, Number(selectedPlatformVoucher.discountAmount));
            } else {
                totalProduct += Math.min(subtotal, Number(selectedPlatformVoucher.discountAmount));
            }
        }

        Object.values(selectedShopVouchers).forEach(sv => {
            if (sv.applyTo === 'SHIPPING') {
                totalShipping += Math.min(delivery, Number(sv.discountAmount));
            } else {
                totalProduct += Math.min(subtotal, Number(sv.discountAmount));
            }
        });

        const promoRow = document.getElementById('promo-row');
        const promoAmount = document.getElementById('promo-amount');
        if (promoRow && promoAmount) {
            const totalDiscount = totalProduct + totalShipping;
            promoRow.style.display = totalDiscount > 0 ? 'flex' : 'none';
            promoAmount.textContent = '−' + formatVND(totalDiscount);
        }

        return { product: totalProduct, shipping: totalShipping };
    };

    document.addEventListener('DOMContentLoaded', () => {
        const modal = document.getElementById('voucher-modal');
        if (modal) {
            modal.addEventListener('cancel', clearRequest);
            modal.addEventListener('click', event => {
                if (event.target === modal) closeVoucherModal();
            });
        }
        const input = document.getElementById('coupon-input');
        if (input) {
            input.addEventListener('keydown', event => {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    applyCoupon();
                }
            });
        }
    });
})();
