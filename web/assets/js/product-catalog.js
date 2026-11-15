/**
 * Interactive View Switcher & Sorting for Product Catalog
 */
document.addEventListener('DOMContentLoaded', function () {
    initViewSwitcher();
});

/**
 * Grid / List View Switcher
 */
function initViewSwitcher() {
    const gridBtn = document.getElementById('gridViewBtn');
    const listBtn = document.getElementById('listViewBtn');
    const container = document.getElementById('catalogContainer');
    const productGrid = document.getElementById('productGrid');

    if (!gridBtn || !listBtn) return;

    gridBtn.addEventListener('click', function () {
        if (container) container.classList.remove('view-list');
        if (productGrid) productGrid.className = 'grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-5';
        gridBtn.classList.add('text-emerald-700');
        gridBtn.classList.remove('text-slate-400');
        listBtn.classList.remove('text-emerald-700');
        listBtn.classList.add('text-slate-400');
    });

    listBtn.addEventListener('click', function () {
        if (container) container.classList.add('view-list');
        if (productGrid) productGrid.className = 'grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5';
        listBtn.classList.add('text-emerald-700');
        listBtn.classList.remove('text-slate-400');
        gridBtn.classList.remove('text-emerald-700');
        gridBtn.classList.add('text-slate-400');
    });
}

/**
 * Handle Sort By Change
 */
window.changeCatalogSort = function(sortVal) {
    const form = document.getElementById('catalogFilterForm');
    if (form) {
        let sortInput = form.querySelector('input[name="sortBy"]');
        if (!sortInput) {
            sortInput = document.createElement('input');
            sortInput.type = 'hidden';
            sortInput.name = 'sortBy';
            form.appendChild(sortInput);
        }
        sortInput.value = sortVal;
        form.submit();
    } else {
        const url = new URL(window.location.href);
        url.searchParams.set('sortBy', sortVal);
        window.location.href = url.toString();
    }
};
