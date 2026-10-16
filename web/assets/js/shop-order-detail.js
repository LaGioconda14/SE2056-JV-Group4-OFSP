/**
 * FreshFruit Seller Center - Shop Order Detail Interaction Scripts
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
    const checkboxes = document.querySelectorAll('.qc-check');
    const qcCountEl = document.getElementById('qcCount');
    const qcBadge = document.getElementById('qcProgressBadge');
    const btnFinish = document.getElementById('btnFinishPacking');

    // Update QC checklist counter and toggle primary action button
    function updateQcProgress() {
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

        if (qcCountEl) {
            qcCountEl.textContent = checkedCount;
        }

        if (checkedCount === 4) {
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
                qcBadge.className = "px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200/60 transition-all";
                qcBadge.innerHTML = 'Bắt buộc hoàn thành <span id="qcCount">' + checkedCount + '</span>/4';
            }
        }
    }

    checkboxes.forEach(cb => {
        cb.addEventListener('change', updateQcProgress);
    });

    // Run initial state check
    updateQcProgress();

    // Check query params for notification toast
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('success') === '1') {
        const toast = document.createElement('div');
        toast.className = 'fixed bottom-5 right-5 z-50 bg-emerald-700 text-white px-5 py-3 rounded-2xl shadow-xl flex items-center gap-3 text-xs font-bold animate-bounce';
        toast.innerHTML = '<i class="fa-solid fa-circle-check text-base"></i> Đã cập nhật trạng thái đơn hàng thành công!';
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 4000);
    }
});

