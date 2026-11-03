document.addEventListener('DOMContentLoaded', function () {
    const modalBackdrop = document.getElementById('wasteModalBackdrop');
    const btnOpenModal = document.getElementById('btnOpenManualWasteModal');
    const btnCloseModal = document.getElementById('btnCloseManualWasteModal');
    const btnCancelModal = document.getElementById('btnCancelManualWasteModal');
    const variantSelect = document.getElementById('selectVariantWaste');
    const quantityInput = document.getElementById('inputWasteQuantity');
    const availableStockText = document.getElementById('textAvailableStock');
    const unitLabelText = document.getElementById('textUnitLabel');
    const formManualWaste = document.getElementById('formManualWaste');

    function openModal() {
        if (modalBackdrop) {
            modalBackdrop.classList.add('is-active');
            updateStockInfo();
        }
    }

    function closeModal() {
        if (modalBackdrop) {
            modalBackdrop.classList.remove('is-active');
        }
    }

    function updateStockInfo() {
        if (!variantSelect) return;
        const selectedOption = variantSelect.options[variantSelect.selectedIndex];
        if (!selectedOption || !selectedOption.value) {
            if (availableStockText) availableStockText.textContent = "0";
            if (unitLabelText) unitLabelText.textContent = "kg";
            if (quantityInput) {
                quantityInput.max = 0;
                quantityInput.value = "";
            }
            return;
        }

        const stock = parseInt(selectedOption.getAttribute('data-stock') || '0', 10);
        const unit = selectedOption.getAttribute('data-unit') || 'kg';

        if (availableStockText) availableStockText.textContent = stock.toString();
        if (unitLabelText) unitLabelText.textContent = unit;
        if (quantityInput) {
            quantityInput.max = stock;
            if (parseInt(quantityInput.value, 10) > stock) {
                quantityInput.value = stock;
            }
        }
    }

    if (btnOpenModal) {
        btnOpenModal.addEventListener('click', openModal);
    }

    if (btnCloseModal) {
        btnCloseModal.addEventListener('click', closeModal);
    }

    if (btnCancelModal) {
        btnCancelModal.addEventListener('click', closeModal);
    }

    if (modalBackdrop) {
        modalBackdrop.addEventListener('click', function (e) {
            if (e.target === modalBackdrop) {
                closeModal();
            }
        });
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeModal();
        }
    });

    if (variantSelect) {
        variantSelect.addEventListener('change', updateStockInfo);
    }

    if (formManualWaste) {
        formManualWaste.addEventListener('submit', function (e) {
            if (!variantSelect || !variantSelect.value) {
                e.preventDefault();
                alert("Vui lòng chọn một loại nông sản/variant cần tiêu hủy!");
                return;
            }

            const qty = parseInt(quantityInput.value, 10);
            const selectedOption = variantSelect.options[variantSelect.selectedIndex];
            const stock = parseInt(selectedOption.getAttribute('data-stock') || '0', 10);

            if (isNaN(qty) || qty <= 0) {
                e.preventDefault();
                alert("Số lượng tiêu hủy phải lớn hơn 0!");
                return;
            }

            if (qty > stock) {
                e.preventDefault();
                alert("Số lượng tiêu hủy (" + qty + ") vượt quá số lượng tồn kho khả dụng (" + stock + ")!");
                return;
            }

            const confirmMsg = "Xác nhận tiêu hủy " + qty + " " + (selectedOption.getAttribute('data-unit') || '') + " nông sản hỏng? Thao tác này sẽ tự động giảm trừ tồn kho và ghi nhận vào chi phí hao hụt.";
            if (!confirm(confirmMsg)) {
                e.preventDefault();
            }
        });
    }
});
