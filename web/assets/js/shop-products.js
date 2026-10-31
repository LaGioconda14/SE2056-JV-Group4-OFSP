/**
 * Tailwind Configuration & Interactive Scripts for Shop Products Management
 */

tailwind.config = {
    darkMode: "class",
    theme: {
        extend: {
            colors: {
                "background": "#faf8ff",
                "primary": "#00652c",
                "primary-container": "#15803d",
                "on-primary": "#ffffff",
                "secondary-container": "#d9e6dd",
                "on-secondary-fixed": "#131e19",
                "surface-container-lowest": "#ffffff",
                "surface-container-low": "#f2f3ff",
                "surface-container-high": "#e2e7ff",
                "surface-container": "#eaedff",
                "on-surface": "#131b2e",
                "on-surface-variant": "#3f493f",
                "tertiary": "#913e00",
                "tertiary-container": "#b85000",
                "tertiary-fixed": "#ffdbca",
                "inverse-surface": "#283044",
                "inverse-on-surface": "#eef0ff",
                "error": "#ba1a1a",
                "error-container": "#ffdad6",
                "on-error": "#ffffff"
            },
            fontFamily: {
                "body-md": ["Plus Jakarta Sans"],
                "headline-sm": ["Plus Jakarta Sans"],
                "body-sm": ["Plus Jakarta Sans"],
                "label-caps": ["Plus Jakarta Sans"],
                "headline-lg": ["Plus Jakarta Sans"]
            }
        }
    }
};

document.addEventListener("DOMContentLoaded", () => {
    const selectAll = document.getElementById("selectAll");
    const rowCheckboxes = document.querySelectorAll(".row-checkbox");
    const selectedCountEl = document.getElementById("selectedCount");

    function updateSelectedCount() {
        const checkedCount = document.querySelectorAll(".row-checkbox:checked").length;
        if (selectedCountEl) {
            selectedCountEl.textContent = checkedCount;
        }
    }

    if (selectAll) {
        selectAll.addEventListener("change", (e) => {
            rowCheckboxes.forEach(cb => cb.checked = e.target.checked);
            updateSelectedCount();
        });
    }

    rowCheckboxes.forEach(cb => {
        cb.addEventListener("change", updateSelectedCount);
    });
});



document.addEventListener('DOMContentLoaded', function () {
    const selectAll = document.getElementById('selectAllCheckbox');
    const rowCheckboxes = document.querySelectorAll('.variant-row-checkbox');

    if (selectAll) {
        selectAll.addEventListener('change', function () {
            rowCheckboxes.forEach(cb => cb.checked = selectAll.checked);
        });
    }
});

function toggleShopUserDropdown(event) {
    if (event) event.stopPropagation();
    const menu = document.getElementById('shopUserDropdownMenu');
    const arrow = document.getElementById('shopUserDropdownArrow');
    if (!menu) return;
    menu.classList.toggle('hidden');
    if (arrow) arrow.classList.toggle('rotate-180');
}

document.addEventListener('click', function(e) {
    const container = document.getElementById('shopUserDropdownContainer');
    const menu = document.getElementById('shopUserDropdownMenu');
    const arrow = document.getElementById('shopUserDropdownArrow');
    if (container && menu && !container.contains(e.target)) {
        menu.classList.add('hidden');
        if (arrow) arrow.classList.remove('rotate-180');
    }
});
