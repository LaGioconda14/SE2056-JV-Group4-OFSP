/* OFSP FE-10 • Vanilla JS • secure DOM rendering; no additional JS dependency. */
(function () {
    'use strict';
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
        async function photos(target, reviewId) {
            try {
                const d = await api('/reviews/images?reviewId=' + encodeURIComponent(reviewId));
                if (!d.imageIds || !d.imageIds.length || !target.isConnected)
                    return;
                const gallery = node('div', 'rv-review-images');
                d.imageIds.forEach(id => {
                    const image = node('img', '');
                    image.src = url('/reviews/images?imageId=' + id);
                    image.alt = 'Ảnh từ người mua';
                    image.loading = 'lazy';
                    gallery.appendChild(image);
                });
                target.appendChild(gallery);
            } catch (e) { /* image list optional */
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
                    renderReviews(state.filter ? state.records.filter(r => r.rating === state.filter) : state.records, false, false);
                }
            } catch (e) {
                empty('Không tải được đánh giá');
                flash(e.message, false);
                pages(0);
            }
        }
        function renderReports(items) {
            if (!body)
                return;
            body.replaceChildren();
            if (!items.length) {
                empty('Không còn báo cáo chờ kiểm duyệt');
                pages(0);
                return;
            }
            items.forEach(r => {
                const row = node('article', 'rv-report'), inside = node('div', 'rv-report-body'), actions = node('div', 'rv-report-actions');
                row.appendChild(inside);
                row.appendChild(actions);
                append(inside, [node('div', 'rv-tagline', 'Báo cáo #' + r.reportId + ' · ' + (r.reviewType === 'SHOP' ? 'Cửa hàng' : 'Sản phẩm')),
                    node('h3', '', r.shopName || 'Đánh giá ' + r.reviewId), node('p', 'rv-copy', r.reviewComment || 'Không có nội dung đánh giá'),
                    node('span', 'rv-pill orange', '⚑ ' + r.reason), node('div', 'rv-meta', 'Người báo cáo: ' + (r.reporterName || '') + ' · ' + stamp(r.createdAt))]);
                [['✓ Giữ đánh giá', 'REJECT', 'secondary'], ['✓ Duyệt hiện', 'APPROVE', 'ghost'], ['◌ Ẩn đánh giá', 'HIDE', 'secondary'], ['✕ Gỡ đánh giá', 'REMOVE', 'danger']].forEach(([label, action, variant]) => actions.appendChild(button(label, variant, () => moderate(r, action))));
                body.appendChild(row);
            });
            pages(items.length);
        }
        async function moderate(record, action) {
            const msg = {'REJECT': 'Bác bỏ báo cáo này và giữ nguyên đánh giá?', 'APPROVE': 'Hiển thị lại đánh giá này?', 'HIDE': 'Ẩn đánh giá này khỏi trang công khai?', 'REMOVE': 'Gỡ đánh giá này khỏi trang công khai?'};
            if (!window.confirm(msg[action]))
                return;
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
                file.hidden = action !== 'create' || (data.type || state.type) !== 'PRODUCT';
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
                        if (!window.confirm('Bạn chắc chắn muốn xóa đánh giá này?')) {
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
                    const result = await post('/reviews', payload);
                    if (action === 'create' && type === 'PRODUCT') {
                        const input = $('[data-image-input]');
                        if (input?.files?.length) {
                            const photos = Array.from(input.files);
                            if (photos.length > 3)
                                throw new Error('Đã gửi đánh giá, nhưng chỉ được chọn tối đa 3 ảnh.');
                            const errors = [];
                            for (const photo of photos) {
                                try {
                                    await post('/reviews/images', {reviewId: result.reviewId}, photo); } catch (e) {
                                    errors.push(photo.name + ': ' + e.message);
                                }
                            }
                            if (errors.length)
                                throw new Error('Đánh giá đã lưu, nhưng một số ảnh không tải lên được:\n' + errors.join('\n'));
                        }
                    }
                    close();
                    await refresh();
                    flash('Thao tác đã được lưu thành công.', true);
                } catch (err) {
                    flash(err.message, false);
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
