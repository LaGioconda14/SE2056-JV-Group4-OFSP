(() => {
    // Định dạng tiền theo kiểu Việt Nam, đơn vị VND và không có phần thập phân.
    const currency = new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
        maximumFractionDigits: 0
    });

    // Lưu phần tử giỏ hàng và nút đã mở hộp thoại để trả lại tiêu điểm khi đóng.
    let cart;
    let lastVariantTrigger = null;

    // Chuyển giá trị sang số; trả về 0 nếu không phải số hữu hạn.
    function numberValue(value) {
        const parsed = Number(value);
        return Number.isFinite(parsed) ? parsed : 0;
    }

    // Làm tròn và giới hạn số lượng trong khoảng min, max của ô nhập.
    function clampQuantity(input) {
        const minimum = numberValue(input.min) || 1;
        const maximum = input.max ? numberValue(input.max) : Number.MAX_SAFE_INTEGER;
        const value = Math.round(numberValue(input.value)) || minimum;
        input.value = String(Math.min(Math.max(value, minimum), maximum));
        return Number(input.value);
    }

    // Lấy các dòng sản phẩm; chỉ dòng có trạng thái AVAILABLE mới được mua.
    function rows() {
        return cart ? Array.from(cart.querySelectorAll('[data-cart-row]')) : [];
    }

    function purchasableRows() {
        return rows().filter(row => row.dataset.cartStatus === 'AVAILABLE');
    }

    // Thành tiền một dòng có khuyến mãi (khớp logic Promotion.calcLineDiscount ở server; server vẫn là nguồn chính thức)
    function lineAmount(row, qty) {
        const price = numberValue(row.dataset.unitPrice);
        const gross = price * qty;
        const type = row.dataset.promoType;
        if (!type) return gross;
        const remain = numberValue(row.dataset.promoRemain);   // -1 = không giới hạn suất
        // Chỉ áp dụng giảm giá cho số lượng còn trong hạn mức khuyến mãi.
        const units = remain >= 0 ? Math.min(qty, remain) : qty;
        if (units <= 0) return gross;
        const value = numberValue(row.dataset.promoValue);
        const max = numberValue(row.dataset.promoMax);
        // Tính mức giảm cho một đơn vị theo loại khuyến mãi, không vượt quá giá bán.
        const perUnit = () => {
            let d;
            if (type === 'FIXED_AMOUNT' || type === 'TIME_WINDOW') d = value;
            else if (type === 'FIXED_PRICE') d = price - value;
            else { d = Math.round(price * value / 100); if (max > 0 && d > max) d = max; }
            return Math.max(0, Math.min(d, price));
        };
        let discount = 0;
        // Khuyến mãi theo số lượng chỉ áp dụng khi đạt số lượng tối thiểu.
        if (type === 'VOLUME') {
            if (qty >= numberValue(row.dataset.promoMin)) discount = perUnit() * units;
        } else {
            discount = perUnit() * units;
        }
        return Math.max(0, gross - Math.min(discount, gross));
    }

    // Lấy số lượng hợp lệ của dòng; dùng 1 nếu dòng không có ô nhập.
    function rowQuantity(row) {
        const input = row.querySelector('[data-quantity-input]');
        return input ? clampQuantity(input) : 1;
    }

    // Chỉ gom các dòng AVAILABLE đã chọn; số liệu dùng cho UI, không phải giá trị đặt hàng chính thức.
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
            const lineSubtotal = lineAmount(row, quantity);
            items.push({itemId: String(row.dataset.itemId), shopId, quantity, unitPrice, subtotal: lineSubtotal});
            subtotal += lineSubtotal;
            shopSubtotals[shopId] = (shopSubtotals[shopId] || 0) + lineSubtotal;
        });

        return {items, subtotal, shopSubtotals};
    }

    // Đồng bộ checkbox chọn tất cả và checkbox từng shop với các dòng được chọn.
    function updateCheckboxes() {
        const itemCheckboxes = purchasableRows().map(row => row.querySelector('[data-cart-item]')).filter(Boolean);
        const selectedCount = itemCheckboxes.filter(checkbox => checkbox.checked).length;
        const allChecked = itemCheckboxes.length > 0 && selectedCount === itemCheckboxes.length;

        cart.querySelectorAll('[data-select-all]').forEach(checkbox => {
            checkbox.checked = allChecked;
            checkbox.indeterminate = false;
        });
        cart.querySelectorAll('[data-shop-select]').forEach(shopCheckbox => {
            const shopItems = purchasableRows()
                .filter(row => String(row.dataset.shopId) === String(shopCheckbox.dataset.shopId))
                .map(row => row.querySelector('[data-cart-item]'))
                .filter(Boolean);
            const shopSelected = shopItems.filter(checkbox => checkbox.checked).length;
            shopCheckbox.checked = shopItems.length > 0 && shopSelected === shopItems.length;
            shopCheckbox.indeterminate = false;
        });
    }

    // Cập nhật thành tiền từng dòng, số món đã chọn, tổng tiền và nút mua hàng.
    function updateSummary() {
        if (!cart) return;
        purchasableRows().forEach(row => {
            const output = row.querySelector('[data-line-subtotal]');
            if (output) output.textContent = currency.format(lineAmount(row, rowQuantity(row)));
        });
        updateCheckboxes();

        const currentSnapshot = snapshot();
        const selectedCount = currentSnapshot.items.length;
        const totalCount = purchasableRows().length;

        document.querySelectorAll('[data-selected-summary-count]').forEach(output => {
            output.replaceChildren('Đã chọn: ');
            const strong = document.createElement('strong');
            strong.className = 'text-gray-900 font-bold';
            strong.textContent = selectedCount + '/' + totalCount + ' món';
            output.append(strong);
        });
        const countOutput = document.getElementById('items-count-text');
        const label = document.getElementById('btn-checkout-label');
        const checkout = document.getElementById('btn-checkout');
        const totalOutput = document.getElementById('summary-total');
        if (countOutput) countOutput.textContent = selectedCount + ' món';
        if (label) label.textContent = selectedCount ? 'Mua hàng (' + selectedCount + ')' : 'Chọn món để mua';
        if (checkout) {
            checkout.disabled = selectedCount === 0;
            checkout.setAttribute('aria-disabled', String(selectedCount === 0));
        }
        if (totalOutput) totalOutput.textContent = currency.format(currentSnapshot.subtotal);
    }

    // Nút cộng/trừ thay đổi số lượng trên giao diện; cần lưu riêng để cập nhật server.
    function changeQuantity(button, offset) {
        const row = button.closest('[data-cart-row]');
        const input = row && row.querySelector('[data-quantity-input]');
        if (!input) return;
        input.value = String(numberValue(input.value) + offset);
        clampQuantity(input);
        updateSummary();
    }

    // Mở hoặc đóng hộp thoại chọn phân loại tương ứng với mã dòng giỏ hàng.
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

    // Hiện hoặc ẩn bảng thông báo và cập nhật trạng thái hỗ trợ truy cập.
    function toggleNotifications(button) {
        const popover = document.getElementById('header-noti-popover');
        if (!popover) return;
        const opening = popover.classList.contains('hidden');
        popover.classList.toggle('hidden', !opening);
        button.setAttribute('aria-expanded', String(opening));
    }

    // Gửi ID dòng đã chọn, không gửi giá; buộc lưu số lượng đã sửa trước khi dựng bản nháp.
    function submitCheckout() {
        const currentSnapshot = snapshot();
        if (!currentSnapshot.items.length) {
            window.alert('Vui lòng chọn ít nhất một sản phẩm để mua hàng!');
            return;
        }
        // So sánh số lượng hiện tại với số lượng đã lưu trước khi thanh toán.
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
        coupon.value = '';
        container.replaceChildren(...hiddenInputs);
        form.submit();
    }

    // Tạo trường ẩn để đưa ID sản phẩm đã chọn vào biểu mẫu thanh toán.
    function hiddenInput(name, value) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value;
        return input;
    }

    // Dựa vào data-cart-action để xử lý các nút thông qua một sự kiện click chung.
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
    }

    // Chọn tất cả, chọn theo shop hoặc cập nhật khi checkbox/số lượng thay đổi.
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

    // Khởi tạo sự kiện khi trang có vùng giỏ hàng.
    function init() {
        cart = document.querySelector('[data-cart]');
        if (!cart) return;
        document.addEventListener('click', handleAction);
        cart.addEventListener('change', handleChange);
        cart.addEventListener('input', event => {
            if (event.target.matches('[data-quantity-input]')) updateSummary();
        });
        // Đóng hộp thoại khi bấm bên ngoài và trả tiêu điểm về nút đã mở.
        document.querySelectorAll('[data-variant-dialog]').forEach(dialog => {
            dialog.addEventListener('click', event => { if (event.target === dialog) dialog.close(); });
            dialog.addEventListener('close', () => {
                document.querySelectorAll('[data-cart-action="open-variant"][data-item-id="' + CSS.escape(dialog.dataset.itemId) + '"]')
                    .forEach(trigger => trigger.setAttribute('aria-expanded', 'false'));
                if (lastVariantTrigger) lastVariantTrigger.focus();
                lastVariantTrigger = null;
            });
        });
        // Đóng bảng thông báo khi bấm ra ngoài hoặc nhấn Escape.
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

    // Cung cấp các thao tác giỏ hàng cho mã khác và cập nhật lại khi trang được hiển thị.
    window.CartPage = {formatCurrency: value => currency.format(numberValue(value)), snapshot, recalculate: updateSummary};
    window.addEventListener('pageshow', updateSummary);
    document.addEventListener('DOMContentLoaded', init);
})();
