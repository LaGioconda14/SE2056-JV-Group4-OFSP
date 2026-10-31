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
 * 2. Grid / List View Switcher
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
