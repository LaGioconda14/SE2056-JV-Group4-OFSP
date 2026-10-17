/* ==========================================================================
   FRESHFRUIT EXPRESS - SHIPPER / DRIVER PORTAL JS (CORE MVP)
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

function viewImageModal(url) {
    const preview = document.getElementById('imageViewModalImg');
    if (preview) preview.src = url;
    const modalEl = document.getElementById('imageViewModal');
    if (modalEl && window.bootstrap && bootstrap.Modal) {
        const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
        modal.show();
    }
}
