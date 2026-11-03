<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="en_US"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="editing" value="${mode == 'edit'}" />
<c:set var="selectedIds" value="${promotion.productIds}" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${editing ? 'Chỉnh sửa' : 'Tạo'} khuyến mãi - Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-marketing.css"/>
    <script src="${ctx}/assets/js/shop-marketing.js" defer></script>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp"><jsp:param name="active" value="promotions" /></jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <a href="${ctx}/shop/promotions" class="hover:text-emerald-700">Khuyến mãi</a>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-800 font-semibold">${editing ? 'Chỉnh sửa chương trình' : 'Tạo khuyến mãi mới'}</span>
            </nav>

            <div>
                <h1 class="text-2xl font-black text-slate-900 tracking-tight">${editing ? 'Chỉnh sửa khuyến mãi' : 'Tạo khuyến mãi mới'}</h1>
                <p class="text-sm text-slate-500 mt-1">Chọn loại khuyến mãi, sản phẩm và thời gian. Ưu đãi được áp dụng tự động cho khách trên trang sản phẩm, giỏ hàng và thanh toán — không cần nhập mã.</p>
            </div>

            <c:if test="${not empty formError}">
                <div class="mk-alert-error"><i class="fa-solid fa-circle-exclamation mt-0.5"></i><span><c:out value="${formError}"/></span></div>
            </c:if>

            <form method="post" action="${ctx}/shop/promotions" class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                <input type="hidden" name="action" value="save">
                <c:if test="${editing}"><input type="hidden" name="promotionId" value="${promotion.promotionId}"></c:if>

                <div class="xl:col-span-8 flex flex-col gap-6">

                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-circle-info"></i> Thông tin chương trình</h2>
                        <div>
                            <label class="mk-label">Tên chương trình <span class="text-red-500">*</span></label>
                            <input type="text" name="name" class="mk-input" maxlength="150" value="<c:out value='${promotion.name}'/>" placeholder="VD: Flash Sale Dâu Tây Cuối Tuần" required>
                        </div>
                        <div>
                            <label class="mk-label">Mô tả</label>
                            <textarea name="description" rows="2" maxlength="500" class="mk-input" placeholder="Mô tả ngắn về chương trình (tuỳ chọn)"><c:out value="${promotion.description}"/></textarea>
                        </div>
                    </div>

                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-wand-magic-sparkles"></i> Loại khuyến mãi &amp; ưu đãi</h2>
                        <c:if test="${promotion.legacyType}">
                            <div class="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
                                <i class="fa-solid fa-triangle-exclamation mr-1"></i> Chương trình này dùng loại cũ (<b><c:out value="${promotion.typeLabel}"/></b>) vì trùng chức năng voucher. Hãy chọn một loại mới bên dưới rồi lưu lại.
                            </div>
                        </c:if>
                        <div class="mk-seg mk-seg-wrap self-start">
                            <label><input type="radio" name="promotionType" value="FIXED_PRICE" ${promotion.promotionType == 'FIXED_PRICE' or promotion.legacyType ? 'checked' : ''}><span><i class="fa-solid fa-tag"></i> Đồng giá</span></label>
                            <label><input type="radio" name="promotionType" value="VOLUME" ${promotion.promotionType == 'VOLUME' ? 'checked' : ''}><span><i class="fa-solid fa-layer-group"></i> Mua nhiều giảm sâu</span></label>
                            <label><input type="radio" name="promotionType" value="TIME_WINDOW" ${promotion.promotionType == 'TIME_WINDOW' ? 'checked' : ''}><span><i class="fa-solid fa-clock"></i> Giảm tiền theo giờ / ngày</span></label>
                        </div>
                        <p class="mk-hint" id="typeHint"></p>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div data-types="FIXED_PRICE,VOLUME,TIME_WINDOW">
                                <label class="mk-label" id="valueLabel">Giá đồng giá <span class="text-red-500">*</span></label>
                                <div class="mk-suffix">
                                    <input type="text" id="discountValue" name="discountValue" class="mk-input" inputmode="decimal"
                                           value="<c:if test='${not empty promotion.discountValue and promotion.discountValue > 0}'><fmt:formatNumber value='${promotion.discountValue}' groupingUsed='false' maxFractionDigits='1'/></c:if>">
                                    <span id="valueUnit">₫</span>
                                </div>
                            </div>
                            <div data-types="VOLUME">
                                <label class="mk-label">Giảm tối đa mỗi sản phẩm</label>
                                <div class="mk-suffix">
                                    <input type="text" id="maxDiscountAmount" name="maxDiscountAmount" class="mk-input" inputmode="numeric" placeholder="Không giới hạn"
                                           value="<c:if test='${not empty promotion.maxDiscountAmount}'><fmt:formatNumber value='${promotion.maxDiscountAmount}' groupingUsed='false' maxFractionDigits='0'/></c:if>">
                                    <span>₫</span>
                                </div>
                            </div>
                            <div data-types="VOLUME">
                                <label class="mk-label">Mua từ (số lượng tối thiểu) <span class="text-red-500">*</span></label>
                                <div class="mk-suffix">
                                    <input type="text" id="minQuantity" name="minQuantity" class="mk-input" inputmode="numeric" placeholder="VD: 3" value="${promotion.minQuantity}">
                                    <span>sản phẩm</span>
                                </div>
                                <p class="mk-hint">Đạt số lượng này, <b>mọi</b> sản phẩm trong dòng hàng đều được giảm.</p>
                            </div>
                            <div>
                                <label class="mk-label">Suất ưu đãi (tuỳ chọn)</label>
                                <div class="mk-suffix">
                                    <input type="text" id="quota" name="quota" class="mk-input" inputmode="numeric" placeholder="Không giới hạn" value="${promotion.quota}">
                                    <span>sản phẩm</span>
                                </div>
                                <p class="mk-hint">Tổng số sản phẩm được hưởng ưu đãi (kiểu flash sale). Hết suất, giá trở về bình thường.<c:if test="${editing and promotion.soldQuantity > 0}"> Đã dùng: <b>${promotion.soldQuantity}</b>.</c:if></p>
                            </div>
                        </div>
                        <div class="bg-emerald-50 border border-emerald-100 rounded-xl px-4 py-3 text-sm text-emerald-900" id="promoExample"></div>
                    </div>

                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-clock"></i> Lịch áp dụng trong tuần <span class="text-xs font-semibold text-slate-400" id="scheduleOptional">(tuỳ chọn)</span></h2>
                        <p class="mk-hint">Để trống = áp dụng mọi ngày, cả ngày (trong khoảng thời gian chương trình ở bên dưới). Chọn thứ và/hoặc khung giờ để giới hạn, ví dụ chỉ <b>Thứ 7, Chủ nhật</b> hoặc chỉ <b>19:00–21:00</b> mỗi ngày.</p>
                        <div>
                            <label class="mk-label">Các ngày trong tuần</label>
                            <div class="flex flex-wrap gap-2" id="dayPicker">
                                <c:set var="dayNames" value="${fn:split('Thứ 2,Thứ 3,Thứ 4,Thứ 5,Thứ 6,Thứ 7,Chủ nhật', ',')}"/>
                                <c:forEach var="dn" items="${dayNames}" varStatus="st">
                                    <label class="inline-flex cursor-pointer items-center gap-1.5 rounded-full border border-slate-200 bg-white px-3 py-1.5 text-sm font-semibold text-slate-700 hover:border-emerald-400">
                                        <input type="checkbox" name="activeDays" value="${st.index + 1}" class="accent-emerald-600" ${promotion.isDayActive(st.index + 1) ? 'checked' : ''}>
                                        <c:out value="${dn}"/>
                                    </label>
                                </c:forEach>
                            </div>
                            <div class="mt-2 flex flex-wrap gap-2 text-xs">
                                <button type="button" class="font-semibold text-emerald-700 hover:underline" data-days="1,2,3,4,5,6,7">Cả tuần</button>
                                <span class="text-slate-300">|</span>
                                <button type="button" class="font-semibold text-emerald-700 hover:underline" data-days="1,2,3,4,5">Thứ 2 – Thứ 6</button>
                                <span class="text-slate-300">|</span>
                                <button type="button" class="font-semibold text-emerald-700 hover:underline" data-days="6,7">Cuối tuần</button>
                                <span class="text-slate-300">|</span>
                                <button type="button" class="font-semibold text-slate-500 hover:underline" data-days="">Bỏ chọn</button>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="mk-label">Từ giờ</label>
                                <input type="time" id="dailyStartTime" name="dailyStartTime" class="mk-input" value="${promotion.dailyStartTime}">
                            </div>
                            <div>
                                <label class="mk-label">Đến giờ</label>
                                <input type="time" id="dailyEndTime" name="dailyEndTime" class="mk-input" value="${promotion.dailyEndTime}">
                                <p class="mk-hint">Không áp dụng khung giờ qua đêm. Bỏ trống cả hai ô = cả ngày.</p>
                            </div>
                        </div>
                    </div>

                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-calendar-days"></i> Thời gian diễn ra</h2>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="mk-label">Bắt đầu <span class="text-red-500">*</span></label>
                                <input type="datetime-local" name="startDate" class="mk-input" value="${promotion.startDateInput}" required>
                            </div>
                            <div>
                                <label class="mk-label">Kết thúc <span class="text-red-500">*</span></label>
                                <input type="datetime-local" name="endDate" class="mk-input" value="${promotion.endDateInput}" required>
                            </div>
                        </div>
                        <p class="mk-hint"><i class="fa-solid fa-circle-info"></i> Mỗi sản phẩm chỉ tham gia một chương trình khuyến mãi tại một thời điểm.</p>
                    </div>

                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-apple-whole"></i> Sản phẩm tham gia <span class="text-red-500">*</span></h2>
                        <jsp:include page="/views/shop/layout/mk-product-picker.jsp" />
                    </div>
                </div>

                <div class="xl:col-span-4">
                    <div class="xl:sticky xl:top-24 flex flex-col gap-4">
                        <div class="mk-card mk-card-pad flex flex-col gap-4">
                            <div class="flex items-center justify-between">
                                <div>
                                    <div class="text-sm font-bold text-slate-800">Kích hoạt chương trình</div>
                                    <div class="text-[11px] text-slate-500">Tắt để lưu nháp, chưa áp dụng giá giảm.</div>
                                </div>
                                <label class="mk-switch"><input type="checkbox" name="active" ${promotion.active ? 'checked' : ''}><i></i></label>
                            </div>
                            <button type="submit" class="mk-btn-primary justify-center"><i class="fa-solid fa-floppy-disk"></i> ${editing ? 'Lưu thay đổi' : 'Tạo chương trình'}</button>
                            <a href="${ctx}/shop/promotions" class="mk-btn-ghost justify-center">Hủy</a>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </main>

    <script>
        // Form khuyến mãi: hiện đúng trường theo loại + ví dụ trực quan (sản phẩm giá 100.000đ)
        document.addEventListener('DOMContentLoaded', function () {
            var box = document.getElementById('promoExample');
            var hint = document.getElementById('typeHint');
            var groups = Array.prototype.slice.call(document.querySelectorAll('[data-types]'));
            var HINTS = {
                FIXED_PRICE: 'Bán đồng giá: giá mới phải thấp hơn giá bán hiện tại của sản phẩm.',
                VOLUME: 'Mua từ N sản phẩm trở lên thì mọi sản phẩm đều được giảm theo phần trăm.',
                TIME_WINDOW: 'Giảm một số tiền cho mỗi sản phẩm, chỉ vào những ngày trong tuần / khung giờ bạn chọn ở mục "Lịch áp dụng" bên dưới. Ngoài khung giờ đó giá về bình thường.'
            };
            var LABELS = { FIXED_PRICE: 'Giá đồng giá', VOLUME: 'Mức giảm', TIME_WINDOW: 'Số tiền giảm mỗi sản phẩm' };
            var UNITS = { FIXED_PRICE: '₫', VOLUME: '%', TIME_WINDOW: '₫' };
            var DAYS = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

            function type() { return (document.querySelector('input[name="promotionType"]:checked') || {}).value || 'FIXED_PRICE'; }
            function num(id, money) {
                var el = document.getElementById(id);
                if (!el) return 0;
                var v = (el.value || '').trim();
                return money ? (parseInt(v.replace(/[^\d]/g, ''), 10) || 0) : (parseFloat(v.replace(',', '.')) || 0);
            }
            function f(n) { return new Intl.NumberFormat('vi-VN').format(n) + '₫'; }

            function scheduleText() {
                var checked = Array.prototype.map.call(document.querySelectorAll('input[name="activeDays"]:checked'), function (c) { return parseInt(c.value, 10); });
                var st = (document.getElementById('dailyStartTime') || {}).value, en = (document.getElementById('dailyEndTime') || {}).value;
                var days = (checked.length === 0 || checked.length === 7) ? 'mỗi ngày' : checked.map(function (d) { return DAYS[d]; }).join(', ');
                var time = (st && en) ? (st + '–' + en) : 'cả ngày';
                return days + ' · ' + time;
            }
            function hasSchedule() {
                var n = document.querySelectorAll('input[name="activeDays"]:checked').length;
                return (n > 0 && n < 7) || (document.getElementById('dailyStartTime').value && document.getElementById('dailyEndTime').value);
            }

            function render() {
                var t = type(), base = 100000, html = '';
                var isMoney = t === 'TIME_WINDOW' || t === 'FIXED_PRICE';
                var v = num('discountValue', isMoney), max = num('maxDiscountAmount', true);
                if (t === 'FIXED_PRICE') {
                    html = 'sản phẩm giá <b>' + f(base) + '</b> → đồng giá <b class="text-emerald-700">' + f(Math.min(v, base)) + '</b>';
                } else if (t === 'VOLUME') {
                    var m = num('minQuantity', true);
                    var d3 = Math.round(base * v / 100); if (max > 0 && d3 > max) d3 = max; d3 = Math.max(0, Math.min(d3, base));
                    if (m > 0) html = 'mua <b>' + m + '</b> sản phẩm giá ' + f(base) + ' → trả <b class="text-emerald-700">' + f((base - d3) * m) + '</b> (giảm ' + f(d3) + '/sản phẩm). Mua ít hơn ' + m + ' thì không giảm.';
                    else html = 'nhập số lượng tối thiểu để xem ví dụ.';
                } else if (t === 'TIME_WINDOW') {
                    var d4 = Math.max(0, Math.min(v, base));
                    if (!hasSchedule()) html = '<span class="text-amber-700">hãy chọn ít nhất một thứ trong tuần hoặc khung giờ ở mục "Lịch áp dụng".</span>';
                    else html = 'vào <b>' + scheduleText() + '</b>: sản phẩm giá <b>' + f(base) + '</b> → khách trả <b class="text-emerald-700">' + f(base - d4) + '</b> (giảm ' + f(d4) + '). Ngoài khung này giá vẫn <b>' + f(base) + '</b>.';
                }
                if (hasSchedule() && t !== 'TIME_WINDOW') html += '<br><span class="text-slate-600">Chỉ áp dụng: ' + scheduleText() + '.</span>';
                box.innerHTML = '<i class="fa-solid fa-lightbulb text-amber-500 mr-1"></i> Ví dụ: ' + html;
            }

            function refresh() {
                var t = type();
                groups.forEach(function (g) {
                    var show = g.getAttribute('data-types').split(',').indexOf(t) !== -1;
                    g.style.display = show ? '' : 'none';
                    Array.prototype.forEach.call(g.querySelectorAll('input'), function (i) { i.disabled = !show; });
                });
                ['discountValue', 'minQuantity'].forEach(function (id) {
                    var el = document.getElementById(id);
                    if (el) el.required = !el.disabled;
                });
                var lab = document.getElementById('valueLabel');
                if (lab && LABELS[t]) lab.innerHTML = LABELS[t] + ' <span class="text-red-500">*</span>';
                var unit = document.getElementById('valueUnit');
                if (unit && UNITS[t]) unit.textContent = UNITS[t];
                var opt = document.getElementById('scheduleOptional');
                if (opt) {
                    opt.textContent = t === 'TIME_WINDOW' ? '(bắt buộc chọn thứ hoặc khung giờ)' : '(tuỳ chọn)';
                    opt.className = 'text-xs font-semibold ' + (t === 'TIME_WINDOW' ? 'text-rose-500' : 'text-slate-400');
                }
                hint.textContent = HINTS[t] || '';
                render();
            }

            ['discountValue', 'maxDiscountAmount', 'minQuantity', 'dailyStartTime', 'dailyEndTime'].forEach(function (id) {
                var el = document.getElementById(id);
                if (el) { el.addEventListener('input', render); el.addEventListener('change', render); }
            });
            Array.prototype.forEach.call(document.querySelectorAll('input[name="activeDays"]'), function (c) { c.addEventListener('change', render); });
            Array.prototype.forEach.call(document.querySelectorAll('[data-days]'), function (btn) {
                btn.addEventListener('click', function () {
                    var set = (btn.getAttribute('data-days') || '').split(',').filter(Boolean);
                    Array.prototype.forEach.call(document.querySelectorAll('input[name="activeDays"]'), function (c) { c.checked = set.indexOf(c.value) !== -1; });
                    render();
                });
            });
            Array.prototype.forEach.call(document.querySelectorAll('input[name="promotionType"]'), function (r) { r.addEventListener('change', refresh); });
            refresh();
        });
    </script>
</body>
</html>
