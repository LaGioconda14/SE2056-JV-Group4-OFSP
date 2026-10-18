document.addEventListener('DOMContentLoaded', function () {
    const newsletterForm = document.getElementById('newsletterForm');
    if (newsletterForm) {
        newsletterForm.addEventListener('submit', function (e) {
            e.preventDefault();
            const emailInput = newsletterForm.querySelector('input[type="email"]');
            const email = emailInput ? emailInput.value.trim() : '';

            if (!email) {
                if (window.showToast) {
                    window.showToast('Vui lòng nhập địa chỉ email hợp lệ!', 'warning');
                } else {
                    alert('Vui lòng nhập địa chỉ email hợp lệ!');
                }
                return;
            }

            if (window.showToast) {
                window.showToast('Đăng ký nhận bản tin thành công!', 'success');
            } else {
                alert('Đăng ký nhận bản tin thành công!');
            }
            newsletterForm.reset();
        });
    }

    const imagesWithFallback = document.querySelectorAll('img[data-fallback]');
    imagesWithFallback.forEach(function (img) {
        img.addEventListener('error', function () {
            const fallbackSrc = this.getAttribute('data-fallback');
            if (fallbackSrc && this.src !== fallbackSrc) {
                this.src = fallbackSrc;
            }
        });
    });
});
