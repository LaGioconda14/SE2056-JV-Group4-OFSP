/**
 * Gốc Vườn - Wishlist (yêu thích)
 *  - Bấm nút trái tim (.wishlist-btn) trên sản phẩm: thêm / bỏ yêu thích, không tải lại trang
 *  - Bấm nút Xóa (.wishlist-remove-btn) ở trang danh sách yêu thích
 *  - Cập nhật số đếm trên nút trái tim nổi (#wishlistFabBadge) và tiêu đề trang (#wishlistPageCount)
 *
 * Cấu hình do /views/common/wishlist-fab.jsp tạo ra:
 *   window.WISHLIST = { ctx, csrf, loggedIn, count }
 *
 * Dùng event delegation nên sản phẩm nào có class .wishlist-btn (kể cả sản phẩm mới thêm
 * vào trang) đều hoạt động mà không cần gắn thêm script.
 */
(function () {
    'use strict';

    var cfg = window.WISHLIST || {};
    var ctx = cfg.ctx || window.contextPath || '';

    function toast(message, type, withWishlistLink) {
        if (typeof window.showToast === 'function') {
            window.showToast(message, type || 'success',
                    withWishlistLink ? {href: ctx + '/wishlist', text: 'Xem yêu thích'} : null);
        } else {
            alert(message);
        }
    }

    function post(url, params) {
        var body = new URLSearchParams(params);
        body.append('csrfToken', cfg.csrf || '');
        body.append('ajax', 'true');
        return fetch(url, {
            method: 'POST',
            body: body,
            credentials: 'same-origin',
            headers: {'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json'}
        }).then(function (res) {
            return res.json().catch(function () {
                return {success: false, message: 'Không thể xử lý yêu cầu. Vui lòng tải lại trang và thử lại!'};
            }).then(function (data) {
                data._status = res.status;
                return data;
            });
        });
    }

    function setCount(n) {
        cfg.count = n;
        var badge = document.getElementById('wishlistFabBadge');
        if (badge) {
            badge.textContent = n > 99 ? '99+' : n;
            badge.hidden = n <= 0;
        }
        var fab = document.getElementById('wishlistFab');
        if (fab) {
            fab.classList.remove('bump');
            void fab.offsetWidth; // chạy lại animation
            fab.classList.add('bump');
        }
        var pageCount = document.getElementById('wishlistPageCount');
        if (pageCount) {
            pageCount.textContent = n;
        }
    }

    function setHeart(productId, wished) {
        var buttons = document.querySelectorAll('.wishlist-btn[data-product-id="' + productId + '"]');
        buttons.forEach(function (btn) {
            btn.classList.toggle('active', wished);
            btn.setAttribute('aria-pressed', wished ? 'true' : 'false');
            btn.title = wished ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích';
            var icon = btn.querySelector('i');
            if (icon) {
                icon.classList.toggle('fa-solid', wished);
                icon.classList.toggle('fa-regular', !wished);
            }
            btn.classList.remove('pop');
            void btn.offsetWidth;
            btn.classList.add('pop');
        });
    }

    function requireLogin() {
        if (cfg.loggedIn) {
            return false;
        }
        toast('Vui lòng đăng nhập để dùng danh sách yêu thích!', 'error', false);
        setTimeout(function () {
            window.location.href = ctx + '/login';
        }, 900);
        return true;
    }

    function handleAuthRedirect(data) {
        if (data._status === 401 || data.redirect) {
            window.location.href = data.redirect || (ctx + '/login');
            return true;
        }
        return false;
    }

    function toggleHeart(btn) {
        if (requireLogin()) {
            return;
        }
        var productId = btn.getAttribute('data-product-id');
        btn.disabled = true;
        post(ctx + '/wishlist/toggle', {productId: productId}).then(function (data) {
            btn.disabled = false;
            if (handleAuthRedirect(data)) {
                return;
            }
            if (data.success) {
                setHeart(productId, data.wished);
                setCount(data.count);
                toast(data.message, 'success', data.wished);
            } else {
                toast(data.message || 'Không thể cập nhật danh sách yêu thích!', 'error', false);
            }
        }).catch(function () {
            btn.disabled = false;
            toast('Lỗi kết nối. Vui lòng thử lại!', 'error', false);
        });
    }

    function removeFromWishlist(btn) {
        if (requireLogin()) {
            return;
        }
        var productId = btn.getAttribute('data-product-id');
        btn.disabled = true;
        post(ctx + '/wishlist/remove', {productId: productId}).then(function (data) {
            btn.disabled = false;
            if (handleAuthRedirect(data)) {
                return;
            }
            if (!data.success) {
                toast(data.message || 'Không thể xóa sản phẩm!', 'error', false);
                return;
            }
            var card = btn.closest('[data-wishlist-item]');
            if (card) {
                card.classList.add('wishlist-card-removing');
                setTimeout(function () {
                    card.remove();
                    if (data.count <= 0) {
                        var grid = document.getElementById('wishlistGrid');
                        var empty = document.getElementById('wishlistEmpty');
                        if (grid) grid.classList.add('hidden');
                        if (empty) empty.classList.remove('hidden');
                    }
                }, 250);
            }
            setCount(data.count);
            toast(data.message, 'success', false);
        }).catch(function () {
            btn.disabled = false;
            toast('Lỗi kết nối. Vui lòng thử lại!', 'error', false);
        });
    }

    document.addEventListener('click', function (e) {
        var heart = e.target.closest('.wishlist-btn');
        if (heart) {
            e.preventDefault();
            e.stopPropagation();
            toggleHeart(heart);
            return;
        }
        var remove = e.target.closest('.wishlist-remove-btn');
        if (remove) {
            e.preventDefault();
            removeFromWishlist(remove);
        }
    });
})();
