/**
 * Gốc Vườn Seller Center - Shop Order Detail Interaction Scripts
 * Option 1: Clean Fulfillment Lifecycle & Cancellation Modal
 */

// Tailwind theme configuration
if (typeof tailwind !== 'undefined') {
    tailwind.config = {
        theme: {
            extend: {
                colors: {
                    emerald: {
                        50: '#f0fdf4',
                        100: '#dcfce7',
                        200: '#bbf7d0',
                        500: '#22c55e',
                        600: '#16a34a',
                        700: '#15803d',
                        800: '#166534',
                        900: '#14532d'
                    }
                },
                boxShadow: {
                    'xs': '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
                    '2xs': '0 1px 1px 0 rgba(0, 0, 0, 0.03)'
                }
            }
        }
    };
}

document.addEventListener('DOMContentLoaded', function () {

    // ==========================================
    // 1. QC Packaging Checklist Counter & Driver Selection Validation
    // ==========================================
    const checkboxes = document.querySelectorAll('.qc-check');
    const qcCountEl = document.getElementById('qcCount');
    const qcBadge = document.getElementById('qcProgressBadge');
    const btnFinish = document.getElementById('btnFinishPacking');
    const formReadyToShip = document.getElementById('formReadyToShip');
    const driverSelect = document.getElementById('driverUserIdSelect') || document.querySelector('select[name="driverUserId"]');

    function updateQcProgress() {
        if (!checkboxes || checkboxes.length === 0) return;
        let checkedCount = 0;
        checkboxes.forEach(cb => {
            const parentLabel = cb.closest('.qc-check-label');
            if (cb.checked) {
                checkedCount++;
                if (parentLabel) parentLabel.classList.add('is-checked');
            } else {
                if (parentLabel) parentLabel.classList.remove('is-checked');
            }
        });

        if (qcCountEl) qcCountEl.textContent = checkedCount;

        // Shipper must be selected if dropdown exists
        const isDriverSelected = driverSelect ? (driverSelect.value && driverSelect.value.trim() !== '') : true;

        if (checkedCount === 4 && isDriverSelected) {
            if (qcBadge) {
                qcBadge.className = "px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 font-bold text-xs border border-emerald-300 transition-all";
                qcBadge.innerHTML = '<i class="fa-solid fa-check mr-1"></i> Đã hoàn tất 4/4 tiêu chuẩn';
            }
            if (btnFinish) {
                btnFinish.disabled = false;
                btnFinish.className = "w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-sm transition shadow-md flex items-center justify-center gap-2 cursor-pointer";
            }
        } else {
            if (qcBadge) {
                if (checkedCount === 4 && !isDriverSelected) {
                    qcBadge.className = "px-3 py-1 rounded-full bg-amber-50 text-amber-700 font-bold text-xs border border-amber-300 transition-all";
                    qcBadge.innerHTML = '<i class="fa-solid fa-motorcycle mr-1"></i> Vui lòng chọn 1 shipper';
                } else {
                    qcBadge.className = "px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200/60 transition-all";
                    qcBadge.innerHTML = 'Bắt buộc hoàn thành <span id="qcCount">' + checkedCount + '</span>/4';
                }
            }
            if (btnFinish) {
                btnFinish.disabled = true;
                btnFinish.className = "w-full py-3 px-4 rounded-xl bg-slate-200 text-slate-400 font-extrabold text-sm transition shadow-sm flex items-center justify-center gap-2 cursor-not-allowed";
            }
        }
    }

    checkboxes.forEach(cb => {
        cb.addEventListener('change', updateQcProgress);
    });

    if (driverSelect) {
        driverSelect.addEventListener('change', updateQcProgress);
    }

    if (formReadyToShip) {
        formReadyToShip.addEventListener('submit', function (e) {
            let checkedCount = 0;
            checkboxes.forEach(cb => {
                if (cb.checked) checkedCount++;
            });
            if (checkedCount < 4) {
                e.preventDefault();
                alert('Vui lòng kiểm tra và tích chọn đủ 4/4 tiêu chuẩn đóng gói!');
                return false;
            }
            if (driverSelect && (!driverSelect.value || driverSelect.value.trim() === '')) {
                e.preventDefault();
                alert('Vui lòng chọn 1 nhân viên giao hàng của Shop trước khi hoàn tất!');
                driverSelect.focus();
                return false;
            }
        });
    }

    updateQcProgress();

    // ==========================================
    // 2. Cancel Sub-Order Modal
    // ==========================================
    const cancelModal = document.getElementById('cancelOrderModal');
    const cancelModalBackdrop = document.getElementById('cancelModalBackdrop');
    const btnCloseCancelModal = document.getElementById('btnCloseCancelModal');
    const btnDismissCancelModal = document.getElementById('btnDismissCancelModal');
    const cancelTriggers = document.querySelectorAll('.btn-open-cancel-modal');

    function openCancelModal() {
        if (cancelModal && cancelModalBackdrop) {
            cancelModal.classList.remove('hidden');
            cancelModalBackdrop.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }
    }

    function closeCancelModal() {
        if (cancelModal && cancelModalBackdrop) {
            cancelModal.classList.add('hidden');
            cancelModalBackdrop.classList.add('hidden');
            document.body.style.overflow = '';
        }
    }

    cancelTriggers.forEach(btn => {
        btn.addEventListener('click', openCancelModal);
    });

    if (btnCloseCancelModal) btnCloseCancelModal.addEventListener('click', closeCancelModal);
    if (btnDismissCancelModal) btnDismissCancelModal.addEventListener('click', closeCancelModal);
    if (cancelModalBackdrop) cancelModalBackdrop.addEventListener('click', closeCancelModal);

    // Cancel Reason Radio options highlight
    const cancelReasonRadios = document.querySelectorAll('input[name="cancelReasonCategory"]');
    cancelReasonRadios.forEach(radio => {
        radio.addEventListener('change', function () {
            cancelReasonRadios.forEach(r => {
                const optCard = r.closest('.cancel-reason-option');
                if (optCard) {
                    if (r.checked) optCard.classList.add('is-selected');
                    else optCard.classList.remove('is-selected');
                }
            });
        });
    });

    // ==========================================
    // 3. Notification Toast for URL Query Params
    // ==========================================
    const urlParams = new URLSearchParams(window.location.search);

    function showToast(message, iconClass, bgClass) {
        const toast = document.createElement('div');
        toast.className = `fixed bottom-5 right-5 z-50 ${bgClass} text-white px-5 py-3 rounded-2xl shadow-xl flex items-center gap-3 text-xs font-bold transition-all animate-bounce`;
        toast.innerHTML = `<i class="${iconClass} text-base"></i> <span>${message}</span>`;
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 4500);
    }

    if (urlParams.get('cancelled') === '1') {
        showToast('Đã hủy đơn hàng con thành công. Hệ thống đã kích hoạt thông báo và hoàn tiền cho khách.', 'fa-solid fa-circle-xmark', 'bg-rose-600');
    } else if (urlParams.get('success') === '1') {
        showToast('Cập nhật trạng thái đơn hàng thành công!', 'fa-solid fa-circle-check', 'bg-emerald-700');
    } else if (urlParams.get('error')) {
        const err = urlParams.get('error');
        let errMsg = 'Đã xảy ra lỗi trong quá trình xử lý!';
        if (err === 'cancel_failed') errMsg = 'Hủy đơn hàng thất bại, vui lòng thử lại!';
        else if (err === 'order_not_found') errMsg = 'Không tìm thấy đơn hàng tương ứng!';
        showToast(errMsg, 'fa-solid fa-triangle-exclamation', 'bg-rose-600');
    }
});
