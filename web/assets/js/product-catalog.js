/**
 * Interactive Filter & Wishlist handler for Product Catalog
 */

document.addEventListener("DOMContentLoaded", () => {
    // 1. Grid view toggles
    const gridViewBtn = document.getElementById("gridViewBtn");
    const listViewBtn = document.getElementById("listViewBtn");
    const productGrid = document.getElementById("productGrid");

    if (gridViewBtn && listViewBtn && productGrid) {
        gridViewBtn.addEventListener("click", () => {
            productGrid.className = "grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-5";
            gridViewBtn.classList.add("text-emerald-700");
            listViewBtn.classList.remove("text-emerald-700");
        });

        listViewBtn.addEventListener("click", () => {
            productGrid.className = "grid grid-cols-1 sm:grid-cols-2 gap-5";
            listViewBtn.classList.add("text-emerald-700");
            gridViewBtn.classList.remove("text-emerald-700");
        });
    }

    // 2. Wishlist Heart Toggle
    const wishlistBtns = document.querySelectorAll(".btn-wishlist");
    wishlistBtns.forEach(btn => {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
            const icon = btn.querySelector("i");
            if (icon) {
                if (icon.classList.contains("fa-regular")) {
                    icon.classList.remove("fa-regular");
                    icon.classList.add("fa-solid", "text-rose-500");
                } else {
                    icon.classList.remove("fa-solid", "text-rose-500");
                    icon.classList.add("fa-regular");
                }
            }
        });
    });

    // 3. Price slider dynamic output (if range inputs present)
    const priceRange = document.getElementById("priceRange");
    const priceDisplay = document.getElementById("priceDisplay");
    if (priceRange && priceDisplay) {
        priceRange.addEventListener("input", (e) => {
            priceDisplay.textContent = `$${e.target.value}`;
        });
    }
});



document.addEventListener('DOMContentLoaded', function () {
    initQuickPriceFilter();
    initCartAddAjax();
    initViewSwitcher();
});

/**
 * 1. Quick Price Range Buttons
 */
function initQuickPriceFilter() {
    const inputMin = document.getElementById('inputMinPrice');
    const inputMax = document.getElementById('inputMaxPrice');
    const quickBtns = document.querySelectorAll('.quick-price-btn');
    const filterForm = document.getElementById('catalogFilterForm');

    quickBtns.forEach(btn => {
        btn.addEventListener('click', function () {
            const min = this.getAttribute('data-min');
            const max = this.getAttribute('data-max');

            if (inputMin) inputMin.value = min || '';
            if (inputMax) inputMax.value = max || '';

            quickBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');

            if (filterForm) {
                filterForm.submit();
            }
        });
    });
}

/**
 * 2. AJAX Add to Cart
 */
function initCartAddAjax() {
    const addForms = document.querySelectorAll('.form-add-cart');
    addForms.forEach(form => {
        form.addEventListener('submit', function (e) {
            e.preventDefault();
            const btn = form.querySelector('.btn-card-add');
            if (btn) {
                btn.disabled = true;
                const originalHtml = btn.innerHTML;
                btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin text-[10px]"></i>';

                const formData = new FormData(form);
                const url = form.action;

                fetch(url, {
                    method: 'POST',
                    body: new URLSearchParams(formData),
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    }
                })
                .then(res => {
                    if (res.ok) {
                        return res.text();
                    }
                    throw new Error('Network response was not ok');
                })
                .then(() => {
                    // Cập nhật badge giỏ hàng trên header
                    const cartBadges = document.querySelectorAll('#header-cart-badge, .cart-count-badge');
                    cartBadges.forEach(b => {
                        let cnt = parseInt(b.textContent.trim()) || 0;
                        b.textContent = cnt + 1;
                        b.classList.remove('hidden');
                    });

                    if (window.showToast) {
                        window.showToast('Đã thêm sản phẩm vào giỏ hàng thành công!', 'success');
                    }
                })
                .catch(() => {
                    // Fallback submit form thông thường nếu ajax bị chặn
                    form.submit();
                })
                .finally(() => {
                    setTimeout(() => {
                        btn.disabled = false;
                        btn.innerHTML = originalHtml;
                    }, 400);
                });
            }
        });
    });
}

/**
 * 4. Grid / List View Switcher
 */
function initViewSwitcher() {
    const gridBtn = document.getElementById('gridViewBtn');
    const listBtn = document.getElementById('listViewBtn');
    const container = document.getElementById('catalogContainer');

    if (!gridBtn || !listBtn || !container) return;

    const savedView = localStorage.getItem('ofsp_catalog_view');
    if (savedView === 'list') {
        container.classList.add('view-list');
        listBtn.classList.add('text-emerald-700');
        gridBtn.classList.remove('text-emerald-700');
    }

    gridBtn.addEventListener('click', function () {
        container.classList.remove('view-list');
        gridBtn.classList.add('text-emerald-700');
        listBtn.classList.remove('text-emerald-700');
        localStorage.setItem('ofsp_catalog_view', 'grid');
    });

    listBtn.addEventListener('click', function () {
        container.classList.add('view-list');
        listBtn.classList.add('text-emerald-700');
        gridBtn.classList.remove('text-emerald-700');
        localStorage.setItem('ofsp_catalog_view', 'list');
    });
}
