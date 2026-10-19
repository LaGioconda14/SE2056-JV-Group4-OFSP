/**
 * FreshFruit Homepage Scripts
 * - Category Dropdown Menu Toggle
 * - Featured Products Tab Filter
 */

// Function to filter featured products by tab
function filterHomeProducts(slug, btn) {
    // Update active tab button style
    document.querySelectorAll('.home-tab-btn').forEach(b => {
        b.classList.remove('active');
    });
    if (btn) {
        btn.classList.add('active');
    }

    // Filter cards by category slugs from DB
    const cards = document.querySelectorAll('.product-card');
    let visibleCount = 0;
    const targetSlug = (slug || 'all').toLowerCase();

    cards.forEach(card => {
        const slugs = (card.getAttribute('data-category-slugs') || '').toLowerCase();
        if (targetSlug === 'all' || slugs.includes(targetSlug)) {
            card.style.display = 'flex';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });

    // Handle empty state message
    let emptyNotice = document.getElementById('homeEmptyNotice');
    if (visibleCount === 0) {
        if (!emptyNotice) {
            emptyNotice = document.createElement('div');
            emptyNotice.id = 'homeEmptyNotice';
            emptyNotice.className = 'col-span-full text-center py-12 bg-white rounded-3xl border border-gray-100 shadow-sm';
            emptyNotice.innerHTML = '<i class="fa-solid fa-box-open text-4xl text-gray-300 mb-3"></i><p class="text-gray-500 font-medium text-base">Hiện chưa có sản phẩm nào thuộc mục này.</p>';
            const grid = document.getElementById('homeProductGrid');
            if (grid) grid.appendChild(emptyNotice);
        } else {
            emptyNotice.style.display = 'block';
        }
    } else {
        if (emptyNotice) emptyNotice.style.display = 'none';
    }
}

// Make filterHomeProducts available globally
window.filterHomeProducts = filterHomeProducts;

// Initialize dropdown toggles and event listeners
document.addEventListener('DOMContentLoaded', function () {
    const catToggle = document.getElementById('categoryMenuToggle');
    const catPanel = document.getElementById('categoryDropdownPanel');
    const catChevron = document.getElementById('categoryChevron');

    if (catToggle && catPanel) {
        // Click to toggle dropdown
        catToggle.addEventListener('click', function (e) {
            e.stopPropagation();
            const isHidden = catPanel.classList.toggle('hidden');
            if (catChevron) {
                if (!isHidden) {
                    catChevron.classList.add('rotate-180');
                } else {
                    catChevron.classList.remove('rotate-180');
                }
            }
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', function (e) {
            if (!catToggle.contains(e.target) && !catPanel.contains(e.target)) {
                catPanel.classList.add('hidden');
                if (catChevron) {
                    catChevron.classList.remove('rotate-180');
                }
            }
        });
    }
});

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
