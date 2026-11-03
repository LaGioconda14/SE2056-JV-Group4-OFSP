/* ==========================================================================
   GỐC VƯỜN EXPRESS - SHIPPER / DRIVER PORTAL JS (CORE MVP)
   ========================================================================== */

function openCompleteModal(deliveryId, trackingNum, amountText, isCod) {
    document.getElementById('completeDeliveryId').value = deliveryId;
    document.getElementById('completeTrackingNumber').textContent = trackingNum;
    
    const codBox = document.getElementById('completeCodInfoBox');
    const codAmount = document.getElementById('completeCodAmount');
    if (isCod) {
        codBox.classList.remove('d-none');
        codAmount.textContent = amountText;
    } else {
        codBox.classList.add('d-none');
    }
    clearPoDSelection();

    const modalEl = document.getElementById('completeDeliveryModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    }
}

function openFailedModal(deliveryId, trackingNum) {
    document.getElementById('failedDeliveryId').value = deliveryId;
    document.getElementById('failedTrackingNumber').textContent = trackingNum;

    const modalEl = document.getElementById('failedDeliveryModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    }
}

function selectPoDPreset(url) {
    const input = document.getElementById('proofImageUrlInput');
    const preview = document.getElementById('podPreviewImg');
    if (input) input.value = url;
    if (preview) {
        preview.src = url;
        preview.classList.remove('d-none');
    }
}

function handlePoDFileSelect(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        if (!file.type.startsWith('image/')) {
            alert('Vui lòng chọn tệp hình ảnh (JPG, PNG, WEBP)!');
            input.value = '';
            return;
        }
        if (file.size > 10 * 1024 * 1024) {
            alert('Kích thước ảnh không được vượt quá 10MB!');
            input.value = '';
            return;
        }

        const reader = new FileReader();
        reader.onload = function(e) {
            const preview = document.getElementById('podPreviewImg');
            const wrapper = document.getElementById('podPreviewWrapper');
            const placeholder = document.getElementById('podUploadPlaceholder');
            if (preview && wrapper && placeholder) {
                preview.src = e.target.result;
                wrapper.classList.remove('d-none');
                placeholder.classList.add('d-none');
            }
        };
        reader.readAsDataURL(file);
    }
}

function clearPoDSelection() {
    const fileInput = document.getElementById('proofImageFile');
    const preview = document.getElementById('podPreviewImg');
    const wrapper = document.getElementById('podPreviewWrapper');
    const placeholder = document.getElementById('podUploadPlaceholder');
    const manualInput = document.getElementById('proofImageUrlInput');
    if (fileInput) fileInput.value = '';
    if (preview) preview.src = '';
    if (wrapper) wrapper.classList.add('d-none');
    if (placeholder) placeholder.classList.remove('d-none');
    if (manualInput) manualInput.value = '';
}

function viewImageModal(url) {
    const preview = document.getElementById('imageViewModalImg');
    if (preview) preview.src = url;
    const modalEl = document.getElementById('imageViewModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    }
}
