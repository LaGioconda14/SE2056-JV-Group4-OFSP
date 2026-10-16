/**
 * FreshFruit Seller Center - Shop Orders Management Scripts
 */

// Tailwind theme extension
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
    // Optional client-side utilities or toasts
    const searchInput = document.querySelector('input[name="keyword"]');
    if (searchInput) {
        // Press Escape to clear search
        searchInput.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                searchInput.value = '';
                searchInput.focus();
            }
        });
    }
});

