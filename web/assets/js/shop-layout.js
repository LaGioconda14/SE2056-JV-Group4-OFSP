/**
 * JS dùng chung cho layout Kênh Người Bán (sidebar + header)
 *  - Ctrl/⌘ + K: focus ô tìm kiếm trên header
 *  - Màn hình nhỏ: nút ☰ mở/đóng sidebar, bấm nền tối hoặc phím Esc để đóng
 */
(function () {
    'use strict';

    var body = document.body;

    function closeSidebar() {
        body.classList.remove('shop-sidebar-open');
    }

    document.addEventListener('DOMContentLoaded', function () {
        var toggle = document.getElementById('shopSidebarToggle');
        var overlay = document.getElementById('shopSidebarOverlay');
        var search = document.getElementById('shopHeaderSearch');

        if (toggle) {
            toggle.addEventListener('click', function () {
                body.classList.toggle('shop-sidebar-open');
            });
        }
        if (overlay) {
            overlay.addEventListener('click', closeSidebar);
        }

        document.addEventListener('keydown', function (e) {
            if ((e.ctrlKey || e.metaKey) && (e.key === 'k' || e.key === 'K')) {
                if (search) {
                    e.preventDefault();
                    search.focus();
                    search.select();
                }
            } else if (e.key === 'Escape') {
                closeSidebar();
            }
        });
    });
})();
