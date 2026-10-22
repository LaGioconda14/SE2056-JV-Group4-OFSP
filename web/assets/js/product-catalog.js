/**
 * ==========================================================================
 * PRODUCT CATALOG INTERACTIVITY - OFSP MARKETPLACE (100% TIẾNG VIỆT)
 * ==========================================================================
 */

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
