/* OFSP FE-10 • Vanilla JS • secure DOM rendering; no additional JS dependency. */
(function () {
    'use strict';
    // FE10_PRODUCT_DETAIL_INTEGRATION_START
    (function mountProductDetailReviews() {
        const loader = document.currentScript;
        if (!loader || loader.dataset.fe10ProductDetail !== 'true')
            return;

        const productId = String(loader.dataset.productId || '').trim();
        const contextPath = loader.dataset.ctx || '';
        const container = document.getElementById('tab-content-reviews');
        if (!/^[1-9][0-9]*$/.test(productId) || !container)
            return;
        if (container.querySelector('[data-fe10-widget]'))
            return;

        const cssPath = contextPath + '/assets/css/reviews.css';
        if (!Array.from(document.querySelectorAll('link[rel="stylesheet"]'))
                .some(link => link.getAttribute('href') === cssPath)) {
            const link = document.createElement('link');
            link.rel = 'stylesheet';
            link.href = cssPath;
            document.head.appendChild(link);
        }

        const root = document.createElement('div');
        root.className = 'rv-root rv-app rv-embed';
        root.dataset.fe10Widget = 'true';
        root.dataset.fe10ProductDetail = 'true';
        root.dataset.ctx = contextPath;
        root.dataset.mode = 'widget';
        root.dataset.type = 'PRODUCT';
        root.dataset.targetId = productId;
        root.style.minHeight = '0';
        // All markup below is static. Product data is never inserted as HTML.
        root.innerHTML = [
            '<div class="rv-container">',
            '<section class="rv-surface">',
            '<div class="rv-surface-header">',
            '<div><h2>Đánh giá xác thực từ người mua</h2>',
            '<p class="rv-sub">Bình luận từ khách hàng đã mua sản phẩm này</p></div>',
            '<span class="rv-pill green">✓ Người mua xác thực</span>',
            '</div>',
            '<div class="rv-rating-panel">',
            '<div class="rv-rating-panel-top"><div>',
            '<span class="rv-section-tag">TỔNG QUAN ĐÁNH GIÁ</span>',
            '<h3>Chất lượng từ trải nghiệm thực tế</h3>',
            '</div></div>',
            '<div class="rv-rating-layout" data-score></div>',
            '</div>',
            '<div class="rv-toolbar" data-rating-filter></div>',
            '<div class="rv-card-list" data-list></div>',
            '<div class="rv-pagination">',
            '<button class="rv-btn secondary" type="button" data-prev>← Trước</button>',
            '<span data-page>Trang 1</span>',
            '<button class="rv-btn secondary" type="button" data-next>Sau →</button>',
            '</div>',
            '<div class="rv-toolbar" style="border-top:1px solid #edf2ee">',
            '<span class="rv-mini-note">Chỉ sản phẩm thuộc đơn đã giao mới được đánh giá.</span>',
            '<a class="rv-btn" data-review-center-link>★ Viết đánh giá</a>',
            '</div>',
            '</section>',
            '<div class="rv-message" data-message role="status" aria-live="polite"></div>',
            '</div>'
        ].join('');
        root.querySelector('[data-review-center-link]').href = contextPath + '/review-center';

        // Replace demo-only cards only inside the Product review tab.
        // No Product controllers, forms, pricing, or other tabs are touched.
        container.replaceChildren(root);
        const tabButton = document.getElementById('tab-btn-reviews');
        if (tabButton)
            tabButton.textContent = 'Đánh Giá Sản Phẩm (đang tải)';
        const topLink = document.querySelector('a[href="#tab-reviews"]');
        if (topLink)
            topLink.textContent = 'Đang tải đánh giá xác thực…';
    })();

    function updateProductDetailSummary(root, summary) {
        if (root.dataset.fe10ProductDetail !== 'true')
            return;
        const count = Number(summary && summary.total || 0);
        const average = Number(summary && summary.average || 0);
        const tabButton = document.getElementById('tab-btn-reviews');
        if (tabButton)
            tabButton.textContent = 'Đánh Giá Sản Phẩm (' + count + ')';
        const topLink = document.querySelector('a[href="#tab-reviews"]');
        if (topLink) {
            topLink.textContent = count + ' đánh giá xác thực';
            const starsContainer = topLink.previousElementSibling && topLink.previousElementSibling.previousElementSibling;
            const avg = starsContainer && starsContainer.querySelector('span.font-extrabold');
            if (avg)
                avg.textContent = (count ? average.toFixed(1) : '—') + ' / 5.0';
        }
    }
    // FE10_PRODUCT_DETAIL_INTEGRATION_END

    document.querySelectorAll('.rv-app').forEach(start);

    function start(root) {
        const ctx = root.dataset.ctx || '';
        const mode = root.dataset.mode || 'center';
        const state = {type: root.dataset.type || 'PRODUCT', page: 1, records: [], purchases: [], token: '', score: null, filter: 0};
        const body = root.querySelector('[data-list]');
        const toast = root.querySelector('[data-message]');
        const layer = root.querySelector('[data-layer]');
        const form = root.querySelector('[data-form]');
        let chosenRating = 5;
        const $ = (sel) => root.querySelector(sel);
        const url = (path) => ctx + path;
        const icons = {'PRODUCT': '🍏', 'SHOP': '🌿'};
        const txt = (s) => document.createTextNode(s == null ? '' : String(s));
        function node(tag, className, value) {
            const n = document.createElement(tag);
            if (className)
                n.className = className;
            if (value != null)
                n.textContent = String(value);
            return n;
        }
        function append(parent, children) {
            children.forEach(child => child && parent.appendChild(typeof child === 'string' ? txt(child) : child));
            return parent;
        }
        function button(text, variant, fn, disabled) {
            const b = node('button', 'rv-btn' + (variant ? ' ' + variant : ''), text);
            b.type = 'button';
            b.disabled = !!disabled;
            b.addEventListener('click', fn);
            return b;
        }
        function stars(value) {
            return '★'.repeat(Math.max(0, Math.min(5, Number(value) || 0))) + '☆'.repeat(Math.max(0, 5 - (Number(value) || 0)));
        }
        function stamp(s) {
            if (!s)
                return '';
            const d = new Date(s);
            return isNaN(d) ? String(s).slice(0, 16) : d.toLocaleDateString('vi-VN');
        }
        function flash(message, good) {
            if (!toast)
                return;
            toast.textContent = message;
            toast.className = 'rv-message show ' + (good ? 'success' : 'error');
            toast.scrollIntoView({behavior: 'smooth', block: 'nearest'});
        }
        function clearFlash() {
            if (toast)
                toast.className = 'rv-message';
        }
        function empty(message) {
            if (!body)
                return;
            body.replaceChildren();
            const e = node('div', 'rv-empty');
            e.setAttribute('role', 'status');
            append(e, [node('div', 'rv-empty-icon', '🪴'), node('strong', '', message || 'Chưa có đánh giá nào'), node('div', '', 'Bạn có thể quay lại sau hoặc chọn tab khác.')]);
            body.appendChild(e);
        }
        function loading() {
            if (body) {
                body.replaceChildren();
                body.appendChild(node('div', 'rv-empty', 'Đang tải dữ liệu đánh giá…'));
            }
        }
        async function api(path, options = {}) {
            const response = await fetch(url(path), {credentials: 'same-origin', cache: 'no-store', ...options});
            let result;
            try {
                result = await response.json();
            } catch (e) {
                throw new Error('Máy chủ trả về dữ liệu không hợp lệ. Kiểm tra Tomcat/JSTL.');
            }
            if (!response.ok)
                throw new Error(result.error || 'Thao tác chưa thành công (' + response.status + ').');
            return result;
        }
        async function token() {
            if (!state.token)
                state.token = (await api('/reviews/csrf')).csrfToken;
            return state.token;
        }
        async function post(path, fields, images) {
            const headers = {'X-CSRF-Token': await token()};
            let bodyData;
            if (images) {
                bodyData = new FormData();
                Object.keys(fields).forEach(k => bodyData.append(k, fields[k]));
                bodyData.append('image', images);
            } else {
                bodyData = new URLSearchParams();
                Object.keys(fields).forEach(k => bodyData.append(k, fields[k]));
            }
            return api(path, {method: 'POST', headers, body: bodyData});
        }
        function updateTabs() {
            root.querySelectorAll('[data-type]').forEach(el => {
                const on = el.dataset.type === state.type;
                el.setAttribute('aria-selected', on ? 'true' : 'false');
            });
        }
        root.querySelectorAll('[data-type]').forEach(el => el.addEventListener('click', () => {
                state.type = el.dataset.type;
                state.page = 1;
                state.filter = 0;
                clearFlash();
                updateTabs();
                refresh();
            }));
        const back = $('[data-prev]'), next = $('[data-next]');
        if (back)
            back.addEventListener('click', () => {
                if (state.page > 1) {
                    state.page--;
                    refresh();
                }
            });
        if (next)
            next.addEventListener('click', () => {
                state.page++;
                refresh();
            });
        function pages(count) {
            const page = $('[data-page]');
            if (page)
                page.textContent = 'Trang ' + state.page;
            if (back)
                back.disabled = state.page <= 1;
            if (next)
                next.disabled = count < 15;
        }
        function thumb(src, type) {
            if (!src || !/^https?:\/\/|^\//i.test(src))
                return node('div', 'rv-thumb', icons[type] || '🌱');
            const img = node('img', 'rv-thumb');
            img.src = src;
            img.alt = 'Ảnh sản phẩm';
            img.loading = 'lazy';
            img.onerror = () => img.replaceWith(node('div', 'rv-thumb', '🍏'));
            return img;
        }
        function card(review, customerOptions, ownShop) {
            const row = node('article', 'rv-item');
            const img = thumb(review.thumbnailUrl, review.type);
            row.appendChild(img);
            const main = node('div', 'rv-main');
            row.appendChild(main);
            const top = node('div', 'rv-title-row');
            main.appendChild(top);
            const titleWrap = node('div', '');
            append(titleWrap, [node('h3', '', review.productName || review.shopName || 'Đánh giá'), node('div', 'rv-meta', (review.customerName || 'Khách hàng') + '  ·  ' + stamp(review.createdAt) + '  ·  Đã mua hàng')]);
            top.appendChild(titleWrap);
            const rating = node('div', 'rv-stars small', stars(review.rating));
            rating.setAttribute('aria-label', review.rating + ' trên 5 sao');
            top.appendChild(rating);
            const copy = node('p', 'rv-copy', review.comment || 'Người mua đã chấm điểm mà không để lại bình luận.');
            main.appendChild(copy);
            if (review.status === 'HIDDEN' || review.status === 'REMOVED')
                main.appendChild(node('span', 'rv-pill red', 'Đánh giá đang bị ẩn'));
            if (review.replyComment) {
                const reply = node('div', 'rv-owner-reply');
                append(reply, [node('strong', '', '🌿 Phản hồi từ nhà vườn\n'), txt(review.replyComment)]);
                main.appendChild(reply);
            }
            if (review.type === 'PRODUCT' && review.status === 'APPROVED')
                photos(main, review.reviewId);
            const actions = node('div', 'rv-actions');
            main.appendChild(actions);
            if (customerOptions) {
                append(actions, [button('✏ Sửa đánh giá', 'secondary', () => open('edit', review)), button('Xóa', 'danger', () => open('delete', review))]);
            } else if (ownShop) {
                append(actions, [button('↩ Phản hồi', 'secondary', () => open('reply', review)), button('⚑ Báo cáo', 'ghost', () => open('report', review))]);
            } else if (mode === 'explore' || mode === 'widget') {
                append(actions, [button('⚑ Báo cáo', 'ghost', () => open('report', review))]);
            }
            return row;
        }
        // FE10_IMAGES_IN_REVIEWS_COLUMN: display image URLs returned by ReviewImageServlet.
        async function photos(target, reviewId) {
            try {
                const data = await api('/reviews/images?reviewId=' + encodeURIComponent(reviewId));
                const urls = Array.isArray(data.imageUrls) ? data.imageUrls : [];
                if (!urls.length || !target.isConnected)
                    return;
                const gallery = node('div', 'rv-review-images');
                for (const imageUrl of urls) {
                    if (typeof imageUrl !== 'string' || !imageUrl.startsWith(ctx + '/reviews/images?'))
                        continue;
                    const img = node('img', '');
                    img.src = imageUrl;
                    img.alt = 'Ảnh đánh giá từ khách hàng';
                    img.loading = 'lazy';
                    gallery.appendChild(img);
                }
                if (!gallery.childElementCount)
                    return;
                const actions = target.querySelector('.rv-actions');
                if (actions)
                    target.insertBefore(gallery, actions);
                else
                    target.appendChild(gallery);
            } catch (error) {
                // No images yet, or the review is not visible to this user.
            }
        }
        function renderReviews(records, mine, shop) {
            if (!body)
                return;
            if (!records.length) {
                empty('Chưa có đánh giá nào');
                pages(0);
                return;
            }
            body.replaceChildren();
            records.forEach(r => body.appendChild(card(r, mine, shop)));
            pages(records.length);
        }
        function renderPurchases(items) {
            if (!body)
                return;
            body.replaceChildren();
            if (!items.length) {
                empty('Bạn chưa có đơn đã giao đủ điều kiện đánh giá');
                return;
            }
            items.forEach(p => {
                const row = node('article', 'rv-item');
                row.appendChild(thumb(p.thumbnailUrl, p.type));
                const main = node('div', 'rv-main');
                row.appendChild(main);
                const top = node('div', 'rv-title-row');
                main.appendChild(top);
                const left = node('div', '');
                append(left, [node('h3', '', p.productName || p.shopName), node('div', 'rv-meta', 'Đơn ' + (p.orderCode || '') + ' · ' + (p.shopName || '')), node('span', 'rv-pill ' + (p.canReview ? 'green' : 'gray'), p.canReview ? '✓ Đã giao · Có thể đánh giá' : '✓ Đã đánh giá')]);
                top.appendChild(left);
                const right = node('div', 'rv-actions');
                top.appendChild(right);
                if (p.canReview)
                    right.appendChild(button('★ Viết đánh giá', '', () => open('create', p)));
                else
                    right.appendChild(
                            button('Xem đánh giá', 'secondary', () => {
                                const reviewedTab = root.querySelector('[data-view="mine"]');

                                if (reviewedTab) {
                                    reviewedTab.click();
                                }
                            })
                            );
                body.appendChild(row);
            });
        }
        function renderScore(rating) {
            const wrap = $('[data-score]');
            if (!wrap)
                return;
            wrap.replaceChildren();
            const total = Number(rating?.total || 0), avg = Number(rating?.average || 0);
            const pane = node('div', '');
            append(pane, [node('div', 'rv-score', total ? avg.toFixed(1) : '—'), node('div', 'rv-stars', stars(Math.round(avg))), node('div', 'rv-sub', total + ' đánh giá xác thực')]);
            wrap.appendChild(pane);
            const hist = node('div', '');
            wrap.appendChild(hist);
            for (let i = 5; i >= 1; i--) {
                let n = Number(rating?.distribution?.[i] || 0), line = node('div', 'rv-chart-row');
                line.appendChild(node('span', '', i + ' ★'));
                let bar = node('div', 'rv-bar'), value = node('b', '');
                value.style.width = total ? Math.round(n / total * 100) + '%' : '0%';
                bar.appendChild(value);
                line.appendChild(bar);
                line.appendChild(node('span', '', String(n)));
                hist.appendChild(line);
            }
            const bar = $('[data-rating-filter]');
            if (bar) {
                bar.replaceChildren();
                [0, 5, 4, 3, 2, 1].forEach(n => {
                    const b = button(n === 0 ? 'Tất cả' : n + ' sao', state.filter === n ? '' : 'secondary', () => {
                        state.filter = n;
                        refresh();
                    });
                    bar.appendChild(b);
                });
            }
        }
        async function refresh() {
            clearFlash();
            loading();
            try {
                if (mode === 'center') {
                    const view = root.querySelector('[data-view].active')?.dataset.view || 'purchases';
                    if (view === 'purchases') {
                        const d = await api('/reviews/purchases?type=' + state.type);
                        state.purchases = d.purchases || [];
                        renderPurchases(state.purchases);
                        if ($('[data-stat-eligible]'))
                            $('[data-stat-eligible]').textContent = state.purchases.filter(p => p.canReview).length;
                    } else {
                        const d = await api('/reviews/mine?type=' + state.type + '&page=' + state.page);
                        state.records = d.reviews || [];
                        renderReviews(state.records, true, false);
                        if ($('[data-stat-reviewed]'))
                            $('[data-stat-reviewed]').textContent = state.records.length;
                    }
                } else if (mode === 'shop') {
                    const d = await api('/reviews/shop-owned?type=' + state.type + '&page=' + state.page);
                    state.records = d.reviews || [];
                    renderReviews(state.records, false, true);
                    if ($('[data-stat-reviewed]'))
                        $('[data-stat-reviewed]').textContent = state.records.length;
                } else if (mode === 'admin') {
                    const d = await api('/admin/review-reports?page=' + state.page);
                    renderReports(d.reports || []);
                } else {
                    const t = encodeURIComponent(state.type), target = Number(root.dataset.targetId || 0);
                    if (!target)
                        throw new Error('Thiếu ID sản phẩm hoặc cửa hàng để hiển thị đánh giá.');
                    const d = await api('/reviews?type=' + t + '&targetId=' + target + '&page=' + state.page);
                    state.records = d.reviews || [];
                    state.score = d.rating;
                    renderScore(d.rating);
                    if (mode === 'widget')
                        updateProductDetailSummary(root, d.rating);
                    renderReviews(state.filter ? state.records.filter(r => r.rating === state.filter) : state.records, false, false);
                }
            } catch (e) {
                empty('Không tải được đánh giá');
                flash(e.message, false);
                pages(0);
            }
        }
        // FE10_MODERATION_PRODUCT_SHOP_FIX_UI: render reports for both review types.
        // FE10_BRANDED_CONFIRM_START: a single accessible dialog for destructive actions.
        function confirmDecision( {title, message, confirmText, destructive = false}) {
            return new Promise(resolve => {
                const previousFocus = document.activeElement;
                const previousOverflow = document.body.style.overflow;
                const backdrop = node('div', 'fe10-confirm-backdrop');
                const dialog = node('section', 'fe10-confirm-dialog');
                dialog.setAttribute('role', 'alertdialog');
                dialog.setAttribute('aria-modal', 'true');
                dialog.setAttribute('aria-labelledby', 'fe10-confirm-title');
                dialog.setAttribute('aria-describedby', 'fe10-confirm-description');

                const header = node('div', 'fe10-confirm-header');
                const symbol = node('span', 'fe10-confirm-symbol' + (destructive ? ' danger' : ''), destructive ? '!' : '✓');
                symbol.setAttribute('aria-hidden', 'true');
                const closeButton = node('button', 'fe10-confirm-close', '×');
                closeButton.type = 'button';
                closeButton.setAttribute('aria-label', 'Đóng hộp thoại');
                append(header, [symbol, closeButton]);
                const eyebrow = node('div', 'fe10-confirm-eyebrow', 'GỐC VƯỜN · XÁC NHẬN THAO TÁC');
                const heading = node('h2', 'fe10-confirm-title', title);
                heading.id = 'fe10-confirm-title';
                const description = node('p', 'fe10-confirm-description', message);
                description.id = 'fe10-confirm-description';
                const footer = node('div', 'fe10-confirm-actions');
                const cancel = node('button', 'fe10-confirm-btn cancel', 'Hủy bỏ');
                const accept = node('button', 'fe10-confirm-btn accept' + (destructive ? ' danger' : ''), confirmText || 'Xác nhận');
                cancel.type = 'button';
                accept.type = 'button';
                append(footer, [cancel, accept]);
                append(dialog, [header, eyebrow, heading, description, footer]);
                backdrop.appendChild(dialog);

                let finished = false;
                function finish(confirmed) {
                    if (finished)
                        return;
                    finished = true;
                    document.removeEventListener('keydown', handleKey, true);
                    backdrop.remove();
                    document.body.style.overflow = previousOverflow;
                    if (previousFocus && previousFocus.isConnected && typeof previousFocus.focus === 'function')
                        previousFocus.focus();
                    resolve(confirmed);
                }
                function handleKey(e) {
                    if (e.key === 'Escape') {
                        e.preventDefault();
                        e.stopPropagation();
                        finish(false);
                    } else if (e.key === 'Tab') {
                        const controls = [closeButton, cancel, accept];
                        const first = controls[0], last = controls[controls.length - 1];
                        if (e.shiftKey && document.activeElement === first) {
                            e.preventDefault();
                            last.focus();
                        } else if (!e.shiftKey && document.activeElement === last) {
                            e.preventDefault();
                            first.focus();
                        }
                    }
                }
                cancel.addEventListener('click', () => finish(false));
                closeButton.addEventListener('click', () => finish(false));
                accept.addEventListener('click', () => finish(true));
                backdrop.addEventListener('click', e => {
                    if (e.target === backdrop)
                        finish(false);
                });
                document.body.appendChild(backdrop);
                document.body.style.overflow = 'hidden';
                document.addEventListener('keydown', handleKey, true);
                cancel.focus();
            });
        }
        // FE10_BRANDED_CONFIRM_END
        function renderReports(items) {
            if (!body)
                return;
            body.replaceChildren();
            if (!items.length) {
                empty('Không còn báo cáo chờ kiểm duyệt');
                pages(0);
                return;
            }
            const statusLabels = {
                APPROVED: 'Đang hiển thị',
                HIDDEN: 'Đang ẩn',
                REMOVED: 'Đã gỡ',
                DELETED: 'Đã xóa'
            };
            items.forEach(r => {
                const shopReport = r.reviewType === 'SHOP';
                const row = node('article', 'rv-report');
                const inside = node('div', 'rv-report-body');
                const actions = node('div', 'rv-report-actions');
                row.appendChild(inside);
                row.appendChild(actions);
                const category = shopReport ? 'Cửa hàng' : 'Sản phẩm';
                const currentStatus = statusLabels[r.reviewStatus] || 'Không tìm thấy đánh giá';
                const score = r.reviewRating == null ? '' : ' · ' + r.reviewRating + '/5 sao';
                append(inside, [
                    node('div', 'rv-tagline', 'Báo cáo #' + r.reportId + ' · ' + category + ' · Review #' + r.reviewId),
                    node('h3', '', (shopReport ? 'Đánh giá gian hàng' : 'Đánh giá sản phẩm') + ' · ' + (r.shopName || 'Không xác định')),
                    node('div', 'rv-meta', 'Người đánh giá: ' + (r.reviewerName || 'Không xác định') + score + ' · ' + currentStatus),
                    node('p', 'rv-copy', r.reviewComment || 'Không có nội dung đánh giá'),
                    node('span', 'rv-pill orange', '⚑ ' + r.reason),
                    node('div', 'rv-meta', 'Người báo cáo: ' + (r.reporterName || 'Không xác định') + ' · ' + stamp(r.createdAt))
                ]);
                // Images for product reports are retrieved with the existing admin-authorized endpoint.
                if (!shopReport && r.reviewStatus && !['DELETED', 'REMOVED'].includes(r.reviewStatus))
                    photos(inside, r.reviewId);

                const reviewAvailable = !!r.reviewStatus && !['DELETED', 'REMOVED'].includes(r.reviewStatus);
                // A deleted/removed review cannot be brought back by moderation.
                const choices = reviewAvailable
                        ? [['✓ Bác bỏ báo cáo', 'REJECT', 'secondary'],
                            ['✓ Duyệt hiển thị', 'APPROVE', 'ghost'],
                            ['◌ Ẩn đánh giá', 'HIDE', 'secondary'],
                            ['✕ Gỡ đánh giá', 'REMOVE', 'danger']]
                        : [['✓ Bác bỏ báo cáo', 'REJECT', 'secondary']];
                choices.forEach(([label, action, variant]) => {
                    actions.appendChild(button(label, variant, () => moderate(r, action)));
                });
                body.appendChild(row);
            });
            pages(items.length);
        }

        async function moderate(record, action) {
            // FE10_CONFIRM_ALL_ADMIN_ACTIONS: show Goc Vuon popup for every admin decision.
            const options = {
                REJECT: {
                    title: 'Giữ lại đánh giá này?',
                    message: 'Báo cáo này sẽ bị bác bỏ. Đánh giá vẫn giữ nguyên trạng thái hiện tại và tiếp tục hiển thị nếu đang được công khai.',
                    confirmText: 'Giữ đánh giá',
                    destructive: false
                },
                APPROVE: {
                    title: 'Duyệt hiển thị đánh giá?',
                    message: 'Đánh giá sẽ được chuyển sang trạng thái đã duyệt và hiển thị trên trang công khai.',
                    confirmText: 'Duyệt hiển thị',
                    destructive: false
                },
                HIDE: {
                    title: 'Ẩn đánh giá này?',
                    message: 'Đánh giá sẽ không còn xuất hiện công khai. Bạn có thể xét duyệt hiển thị lại sau.',
                    confirmText: 'Ẩn đánh giá',
                    destructive: false
                },
                REMOVE: {
                    title: 'Gỡ đánh giá này?',
                    message: 'Đánh giá sẽ bị gỡ khỏi trang công khai. Hãy chắc chắn nội dung vi phạm quy định trước khi xác nhận.',
                    confirmText: 'Gỡ đánh giá',
                    destructive: true
                }
            };
            const choice = options[action];
            if (!choice) {
                flash('Hành động kiểm duyệt không hợp lệ.', false);
                return;
            }
            const confirmed = await confirmDecision(choice);
            if (!confirmed)
                return; // Cancel, X, outside click or Esc: no API request.
            try {
                await post('/admin/review-reports', {reportId: record.reportId, action});
                flash('Đã xử lý báo cáo thành công.', true);
                await refresh();
            } catch (e) {
                flash(e.message, false);
            }
        }
        root.querySelectorAll('[data-view]').forEach(b => b.addEventListener('click', () => {
                root.querySelectorAll('[data-view]').forEach(x => x.classList.toggle('active', x === b));
                state.page = 1;
                refresh();
            }));
        function open(action, data) {
            if (!layer || !form)
                return;
            form.reset();
            form.dataset.action = action;
            form.dataset.reviewId = data.reviewId || '';
            form.dataset.purchaseRef = data.purchaseRef || '';
            form.dataset.kind = data.type || state.type;
            chosenRating = action === 'edit' ? data.rating || 5 : 5;
            paintStars();
            const title = $('[data-dialog-title]');
            if (title)
                title.textContent = ({'create': 'Đánh giá sau khi mua', 'edit': 'Chỉnh sửa đánh giá', 'delete': 'Xóa đánh giá', 'reply': 'Phản hồi khách hàng', 'report': 'Báo cáo đánh giá'})[action] || 'Đánh giá';
            const caption = $('[data-dialog-caption]');
            if (caption)
                caption.textContent = data.productName || data.shopName || 'Đánh giá từ người mua';
            const text = $('[data-comment]');
            if (text) {
                text.value = (action === 'edit' ? data.comment : (action === 'reply' ? data.replyComment : '')) || '';
                text.placeholder = action === 'report' ? 'Mô tả lý do báo cáo (10–500 ký tự)' : action === 'reply' ? 'Gửi phản hồi đến khách hàng...' : 'Chia sẻ trải nghiệm của bạn về sản phẩm...';
                text.closest('[data-comment-box]').hidden = action === 'delete';
            }
            const rate = $('[data-rate]');
            if (rate)
                rate.hidden = !['create', 'edit'].includes(action);
            const file = $('[data-file-box]');
            if (file)
                file.hidden = !['create', 'edit'].includes(action) || (data.type || state.type) !== 'PRODUCT';
            const submit = $('[data-submit]');
            if (submit)
                submit.textContent = ({create: 'Gửi đánh giá', edit: 'Lưu thay đổi', delete: 'Xác nhận xóa', report: 'Gửi báo cáo', reply: 'Gửi phản hồi'})[action];
            layer.classList.add('open');
            layer.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';
            const ta = $('[data-comment]');
            if (ta && !ta.closest('[data-comment-box]').hidden)
                ta.focus();
        }
        function close() {
            if (layer) {
                layer.classList.remove('open');
                layer.setAttribute('aria-hidden', 'true');
                document.body.style.overflow = '';
            }
        }
        root.querySelectorAll('[data-close]').forEach(b => b.addEventListener('click', close));
        if (layer)
            layer.addEventListener('click', e => {
                if (e.target === layer)
                    close();
            });
        document.addEventListener('keydown', e => {
            if (e.key === 'Escape')
                close();
        });
        const rateContainer = $('[data-rate]');
        if (rateContainer) {
            for (let i = 1; i <= 5; i++) {
                const b = node('button', '', '★');
                b.type = 'button';
                b.setAttribute('aria-label', i + ' sao');
                b.addEventListener('click', () => {
                    chosenRating = i;
                    paintStars();
                });
                rateContainer.appendChild(b);
            }
        }
        function paintStars() {
            if (rateContainer)
                Array.from(rateContainer.querySelectorAll('button')).forEach((b, i) => b.classList.toggle('on', i < chosenRating));
        }
        if (form)
            form.addEventListener('submit', async e => {
                e.preventDefault();
                const action = form.dataset.action;
                const submit = $('[data-submit]');
                if (submit)
                    submit.disabled = true;
                try {
                    const type = form.dataset.kind;
                    const comment = ($('[data-comment]')?.value || '').trim();
                    let payload = {action, type};
                    if (action === 'create') {
                        payload = {...payload, purchaseRef: form.dataset.purchaseRef, rating: chosenRating, comment};
                    } else if (action === 'edit') {
                        payload = {...payload, reviewId: form.dataset.reviewId, rating: chosenRating, comment};
                    } else if (action === 'delete') {
                        if (!(await confirmDecision({
                            title: 'Xóa đánh giá của bạn?',
                            message: 'Đánh giá sẽ bị xóa khỏi danh sách công khai. Thao tác này không thể hoàn tác trong giao diện.',
                            confirmText: 'Xóa đánh giá',
                            destructive: true
                        }))) {
                            if (submit)
                                submit.disabled = false;
                            return;
                        }
                        payload.reviewId = form.dataset.reviewId;
                    } else if (action === 'reply') {
                        payload = {...payload, reviewId: form.dataset.reviewId, comment};
                    } else if (action === 'report') {
                        payload = {...payload, reviewId: form.dataset.reviewId, reason: comment};
                    }
                    // FE10_PHOTO_EDIT_AND_DUPLICATE_GUARD
                    // Validate photo selections before creating/updating a review.
                    const imageInput = $('[data-image-input]');
                    const photos = (type === 'PRODUCT' && ['create', 'edit'].includes(action) && imageInput)
                            ? Array.from(imageInput.files || []) : [];
                    if (photos.length > 3)
                        throw new Error('Chỉ được chọn tối đa 3 ảnh.');
                    for (const photo of photos) {
                        if (!['image/jpeg', 'image/png'].includes(photo.type))
                            throw new Error('Chỉ chấp nhận ảnh JPG hoặc PNG.');
                        if (!photo.size || photo.size > 3 * 1024 * 1024)
                            throw new Error('Mỗi ảnh phải lớn hơn 0 byte và không vượt quá 3MB.');
                    }
                    if (action === 'edit' && photos.length) {
                        const existing = await api('/reviews/images?reviewId=' + encodeURIComponent(form.dataset.reviewId));
                        const oldCount = Array.isArray(existing.imageIds) ? existing.imageIds.length : 0;
                        if (oldCount + photos.length > 3)
                            throw new Error('Đánh giá đã có ' + oldCount + ' ảnh. Tổng số ảnh không được vượt quá 3.');
                    }
                    if (action === 'create') {
                        const eligibility = await api('/reviews/eligible?type=' + encodeURIComponent(type)
                                + '&purchaseRef=' + encodeURIComponent(form.dataset.purchaseRef));
                        if (!eligibility.eligible)
                            throw new Error('Đơn này chưa đủ điều kiện hoặc đã có đánh giá. Nếu đã đánh giá, mở tab “Đã đánh giá”, chọn “Sửa đánh giá” để thêm ảnh.');
                    }

                    const result = await post('/reviews', payload);
                    const savedReviewId = action === 'create' ? result.reviewId : form.dataset.reviewId;
                    const imageErrors = [];
                    if (photos.length) {
                        for (const photo of photos) {
                            try {
                                await post('/reviews/images', {reviewId: savedReviewId}, photo);
                            } catch (photoError) {
                                imageErrors.push(photo.name + ': ' + photoError.message);
                            }
                        }
                    }
                    // A successful review POST must not be retried just because an image failed.
                    close();
                    await refresh();
                    if (imageErrors.length)
                        flash('Đánh giá đã được lưu, nhưng một số ảnh chưa tải lên được: ' + imageErrors.join('; ') + '. Vào Đã đánh giá → Sửa đánh giá để thử lại.', false);
                    else
                        flash('Thao tác đã được lưu thành công.', true);
                } catch (err) {
                    if (action === 'create' && /Purchased and delivered item required|review already exists|Đơn này chưa đủ điều kiện/i.test(err.message)) {
                        close();
                        await refresh();
                        flash('Không thể tạo đánh giá mới: đơn hàng chưa đủ điều kiện hoặc đã có đánh giá. Nếu muốn bổ sung ảnh, vào “Đã đánh giá” → “Sửa đánh giá”.', false);
                    } else {
                        flash(err.message, false);
                    }
                } finally {
                    if (submit)
                        submit.disabled = false;
                }
            });
        if (mode === 'center' || mode === 'shop')
            updateTabs();
        refresh();
    }
})();

/* FE-10: Xem ảnh đánh giá phóng to */
(function () {
    "use strict";

    let lightbox = null;
    let previousOverflow = "";

    function closeReviewImage() {
        if (!lightbox)
            return;

        lightbox.remove();
        lightbox = null;
        document.body.style.overflow = previousOverflow;
    }

    function openReviewImage(src, alt) {
        if (!src)
            return;

        closeReviewImage();

        previousOverflow = document.body.style.overflow;

        lightbox = document.createElement("div");
        lightbox.className = "fe10-lightbox";
        lightbox.setAttribute("role", "dialog");
        lightbox.setAttribute("aria-modal", "true");
        lightbox.setAttribute("aria-label", "Xem ảnh đánh giá");

        const image = document.createElement("img");
        image.src = src;
        image.alt = alt || "Ảnh đánh giá sản phẩm";
        image.className = "fe10-lightbox-image";

        const closeButton = document.createElement("button");
        closeButton.type = "button";
        closeButton.className = "fe10-lightbox-close";
        closeButton.textContent = "×";
        closeButton.setAttribute("aria-label", "Đóng ảnh");

        closeButton.addEventListener("click", closeReviewImage);

        lightbox.addEventListener("click", function (event) {
            if (event.target === lightbox) {
                closeReviewImage();
            }
        });

        lightbox.appendChild(image);
        lightbox.appendChild(closeButton);

        document.body.appendChild(lightbox);
        document.body.style.overflow = "hidden";

        closeButton.focus();
    }

    // Bắt sự kiện ảnh, kể cả ảnh được tải động từ API.
    document.addEventListener("click", function (event) {
        if (!(event.target instanceof Element))
            return;

        const image = event.target.closest(
                ".rv-review-images img"
                );

        if (!image)
            return;

        event.preventDefault();

        openReviewImage(
                image.currentSrc || image.src,
                image.alt
                );
    });

    // Nhấn ESC để đóng ảnh.
    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && lightbox) {
            closeReviewImage();
        }
    });
})();

