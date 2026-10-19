<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                <p class="text-sm text-slate-500 mt-1">Chọn sản phẩm, mức giảm và thời gian. Giá sau khuyến mãi sẽ được áp dụng tự động cho khách hàng.</p>
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
                        <h2 class="mk-h2"><i class="fa-solid fa-percent"></i> Mức giảm giá</h2>
                        <div class="mk-seg self-start">
                            <label><input type="radio" name="promotionType" value="PERCENTAGE" ${promotion.promotionType != 'FIXED_AMOUNT' ? 'checked' : ''}><span><i class="fa-solid fa-percent"></i> Theo phần trăm</span></label>
                            <label><input type="radio" name="promotionType" value="FIXED_AMOUNT" ${promotion.promotionType == 'FIXED_AMOUNT' ? 'checked' : ''}><span><i class="fa-solid fa-money-bill"></i> Số tiền cố định</span></label>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="mk-label">Mức giảm <span class="text-red-500">*</span></label>
                                <div class="mk-suffix">
                                    <input type="text" id="discountValue" name="discountValue" class="mk-input" inputmode="decimal"
                                           value="<c:if test='${not empty promotion.discountValue}'><fmt:formatNumber value='${promotion.discountValue}' groupingUsed='false' maxFractionDigits='1'/></c:if>" required>
                                    <span id="valueUnit">%</span>
                                </div>
                                <p class="mk-hint">Giảm trên <b>mỗi đơn vị</b> sản phẩm. Phần trăm tối đa 90%.</p>
                            </div>
                            <div data-show-pct>
                                <label class="mk-label">Giảm tối đa mỗi sản phẩm</label>
                                <div class="mk-suffix">
                                    <input type="text" id="maxDiscountAmount" name="maxDiscountAmount" class="mk-input" inputmode="numeric" placeholder="Không giới hạn"
                                           value="<c:if test='${not empty promotion.maxDiscountAmount}'><fmt:formatNumber value='${promotion.maxDiscountAmount}' groupingUsed='false' maxFractionDigits='0'/></c:if>">
                                    <span>₫</span>
                                </div>
                            </div>
                        </div>
                        <div class="bg-emerald-50 border border-emerald-100 rounded-xl px-4 py-3 text-sm text-emerald-900" id="promoExample"></div>
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
        // Ví dụ trực quan: sản phẩm giá 100.000đ sẽ còn bao nhiêu sau khi giảm
        document.addEventListener('DOMContentLoaded', function () {
            var box = document.getElementById('promoExample');
            function num(id, money) {
                var el = document.getElementById(id);
                if (!el) return 0;
                var v = (el.value || '').trim();
                return money ? (parseInt(v.replace(/[^\d]/g, ''), 10) || 0) : (parseFloat(v.replace(',', '.')) || 0);
            }
            function render() {
                var type = (document.querySelector('input[name="promotionType"]:checked') || {}).value;
                var base = 100000, v = num('discountValue', type === 'FIXED_AMOUNT'), max = num('maxDiscountAmount', true), d;
                if (type === 'FIXED_AMOUNT') { d = v; } else { d = Math.round(base * v / 100); if (max > 0 && d > max) d = max; }
                d = Math.max(0, Math.min(d, base));
                var f = function (n) { return new Intl.NumberFormat('vi-VN').format(n) + '₫'; };
                box.innerHTML = '<i class="fa-solid fa-lightbulb text-amber-500 mr-1"></i> Ví dụ: sản phẩm giá <b>' + f(base) + '</b> → khách trả <b class="text-emerald-700">' + f(base - d) + '</b> (giảm ' + f(d) + ')';
            }
            ['discountValue', 'maxDiscountAmount'].forEach(function (id) { var el = document.getElementById(id); if (el) el.addEventListener('input', render); });
            document.querySelectorAll('input[name="promotionType"]').forEach(function (r) { r.addEventListener('change', render); });
            render();
        });
    </script>
</body>
</html>
