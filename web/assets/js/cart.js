document.addEventListener('DOMContentLoaded', function () {
    const cart = document.querySelector('[data-cart]');
    if (!cart) return;

    const itemChecks = Array.from(cart.querySelectorAll('[data-cart-item]'));
    const selectAll = cart.querySelector('[data-select-all]');
    const selectedLineOutputs = document.querySelectorAll('[data-selected-lines], [data-summary-lines]');
    const selectedQuantityOutput = document.querySelector('[data-summary-quantity]');
    const subtotalOutput = document.querySelector('[data-summary-subtotal]');
    const totalOutput = document.querySelector('[data-summary-total]');
    const progress = document.querySelector('[data-delivery-progress]');
    const progressCurrent = document.querySelector('[data-delivery-current]');
    const progressTitle = document.querySelector('[data-delivery-title]');
    const progressMessage = document.querySelector('[data-delivery-message]');
    const progressSection = document.querySelector('[data-delivery-goal]');
    const currency = new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
        maximumFractionDigits: 0
    });

    function numberValue(value) {
        const parsed = Number(value);
        return Number.isFinite(parsed) ? parsed : 0;
    }

    function inputQuantity(row) {
        const input = row.querySelector('[data-quantity-input]');
        return input ? Math.max(1, numberValue(input.value)) : 1;
    }

    function updateLineSubtotal(row) {
        const check = row.querySelector('[data-cart-item]');
        const output = row.querySelector('[data-line-subtotal]');
        if (!check || !output) return;
        output.textContent = currency.format(numberValue(check.dataset.unitPrice) * inputQuantity(row));
    }

    function updateSummary() {
        let lines = 0;
        let quantity = 0;
        let subtotal = 0;

        itemChecks.forEach(function (check) {
            const row = check.closest('[data-cart-row]');
            if (!row || !check.checked) return;
            const rowQuantity = inputQuantity(row);
            lines += 1;
            quantity += rowQuantity;
            subtotal += numberValue(check.dataset.unitPrice) * rowQuantity;
        });

        selectedLineOutputs.forEach(function (output) {
            output.textContent = String(lines);
        });
        if (selectedQuantityOutput) selectedQuantityOutput.textContent = String(quantity);
        if (subtotalOutput) subtotalOutput.textContent = currency.format(subtotal);
        if (totalOutput) totalOutput.textContent = currency.format(subtotal);

        if (selectAll) {
            selectAll.checked = itemChecks.length > 0 && lines === itemChecks.length;
            selectAll.indeterminate = lines > 0 && lines < itemChecks.length;
        }

        if (progressSection) {
            const goal = numberValue(progressSection.dataset.deliveryGoal);
            const percentage = goal > 0 ? Math.min((subtotal / goal) * 100, 100) : 0;
            if (progress) progress.style.width = percentage + '%';
            if (progressCurrent) progressCurrent.textContent = currency.format(subtotal);
            if (subtotal >= goal) {
                if (progressTitle) progressTitle.textContent = 'Bạn đã đạt mốc ưu đãi giao hàng!';
                if (progressMessage) progressMessage.textContent = 'Chỉ báo này mang tính minh họa; phí thực tế được tính ở bước thanh toán.';
            } else {
                if (progressTitle) progressTitle.textContent = 'Gần đạt ưu đãi giao hàng!';
                if (progressMessage) progressMessage.textContent = 'Còn ' + currency.format(goal - subtotal) + ' để đạt mốc minh họa.';
            }
        }
    }

    if (selectAll) {
        selectAll.addEventListener('change', function () {
            itemChecks.forEach(function (check) {
                check.checked = selectAll.checked;
            });
            updateSummary();
        });
    }

    itemChecks.forEach(function (check) {
        check.addEventListener('change', updateSummary);
    });

    cart.querySelectorAll('[data-cart-row]').forEach(function (row) {
        const input = row.querySelector('[data-quantity-input]');
        const form = row.querySelector('[data-quantity-form]');
        const minus = row.querySelector('[data-quantity-minus]');
        const plus = row.querySelector('[data-quantity-plus]');
        if (!input || !form) return;

        const initialValue = input.value;

        function clampQuantity(value) {
            const minimum = numberValue(input.min) || 1;
            const maximum = input.max ? numberValue(input.max) : Number.MAX_SAFE_INTEGER;
            return Math.min(Math.max(Math.round(numberValue(value)) || minimum, minimum), maximum);
        }

        function applyQuantity(value) {
            input.value = String(clampQuantity(value));
            form.classList.toggle('quantity-form--dirty', input.value !== initialValue);
            updateLineSubtotal(row);
            updateSummary();
        }

        if (minus) minus.addEventListener('click', function () { applyQuantity(numberValue(input.value) - 1); });
        if (plus) plus.addEventListener('click', function () { applyQuantity(numberValue(input.value) + 1); });
        input.addEventListener('input', function () {
            form.classList.toggle('quantity-form--dirty', input.value !== initialValue);
            updateLineSubtotal(row);
            updateSummary();
        });
        input.addEventListener('change', function () { applyQuantity(input.value); });
    });

    cart.querySelectorAll('[data-remove-form]').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!window.confirm('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?')) {
                event.preventDefault();
            }
        });
    });

    window.addEventListener('pageshow', updateSummary);
    updateSummary();
});
