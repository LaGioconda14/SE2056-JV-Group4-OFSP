<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="en_US"/>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="editing" value="${mode == 'edit'}" />
<c:set var="selectedIds" value="${voucher.productIds}" scope="request" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${editing ? 'Chỉnh sửa' : 'Tạo'} voucher - Kênh Người Bán</title>
    <jsp:include page="/views/shop/layout/head.jsp" />
    <link rel="stylesheet" href="${ctx}/assets/css/shop-marketing.css"/>
    <script src="${ctx}/assets/js/shop-marketing.js" defer></script>
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <jsp:include page="/views/shop/layout/sidebar.jsp"><jsp:param name="active" value="vouchers" /></jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp" />

    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                <span>Kênh Người Bán</span>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <a href="${ctx}/shop/vouchers" class="hover:text-emerald-700">Voucher Shop</a>
                <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                <span class="text-slate-800 font-semibold">${editing ? 'Chỉnh sửa voucher' : 'Tạo voucher mới'}</span>
            </nav>

            <div>
                <h1 class="text-2xl font-black text-slate-900 tracking-tight">${editing ? 'Chỉnh sửa voucher' : 'Tạo voucher mới'}</h1>
                <p class="text-sm text-slate-500 mt-1">Thiết lập mức giảm, điều kiện áp dụng và thời gian hiệu lực của voucher.</p>
            </div>

            <c:if test="${not empty formError}">
                <div class="mk-alert-error"><i class="fa-solid fa-circle-exclamation mt-0.5"></i><span><c:out value="${formError}"/></span></div>
            </c:if>

            <form method="post" action="${ctx}/shop/vouchers" class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                <input type="hidden" name="action" value="save">
                <c:if test="${editing}"><input type="hidden" name="couponId" value="${voucher.couponId}"></c:if>

                <div class="xl:col-span-8 flex flex-col gap-6">

                    <!-- 1. Thông tin cơ bản -->
                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-circle-info"></i> Thông tin cơ bản</h2>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="mk-label">Mã voucher <span class="text-red-500">*</span></label>
                                <input type="text" id="codeInput" name="code" class="mk-input uppercase font-mono font-bold" maxlength="20"
                                       value="<c:out value='${voucher.code}'/>" placeholder="VD: DALAT10" ${editing ? 'readonly' : 'required'}>
                                <p class="mk-hint">${editing ? 'Không thể đổi mã sau khi tạo.' : '4–20 ký tự: chữ không dấu, số, "-" hoặc "_". Mã là duy nhất trên toàn sàn.'}</p>
                            </div>
                            <div>
                                <label class="mk-label">Tên chương trình <span class="text-red-500">*</span></label>
                                <input type="text" id="titleInput" name="title" class="mk-input" maxlength="150"
                                       value="<c:out value='${voucher.title}'/>" placeholder="VD: Giảm 10% toàn shop" required>
                            </div>
                        </div>
                        <div>
                            <label class="mk-label">Mô tả</label>
                            <textarea name="description" rows="2" maxlength="500" class="mk-input" placeholder="Mô tả ngắn điều kiện áp dụng (tuỳ chọn)"><c:out value="${voucher.description}"/></textarea>
                        </div>
                    </div>

                    <!-- 2. Mức giảm -->
                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-percent"></i> Mức giảm giá</h2>
                        <div class="mk-seg self-start">
                            <label><input type="radio" name="discountType" value="PERCENTAGE" ${voucher.discountType != 'FIXED_AMOUNT' ? 'checked' : ''}><span><i class="fa-solid fa-percent"></i> Theo phần trăm</span></label>
                            <label><input type="radio" name="discountType" value="FIXED_AMOUNT" ${voucher.discountType == 'FIXED_AMOUNT' ? 'checked' : ''}><span><i class="fa-solid fa-money-bill"></i> Số tiền cố định</span></label>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label class="mk-label">Mức giảm <span class="text-red-500">*</span></label>
                                <div class="mk-suffix">
                                    <input type="text" id="discountValue" name="discountValue" class="mk-input" inputmode="decimal"
                                           value="<c:if test='${not empty voucher.discountValue}'><fmt:formatNumber value='${voucher.discountValue}' groupingUsed='false' maxFractionDigits='1'/></c:if>" required>
                                    <span id="valueUnit">%</span>
                                </div>
                            </div>
                            <div data-show-pct>
                                <label class="mk-label">Giảm tối đa</label>
                                <div class="mk-suffix">
                                    <input type="text" id="maxDiscountAmount" name="maxDiscountAmount" class="mk-input" inputmode="numeric" placeholder="Không giới hạn"
                                           value="<c:if test='${not empty voucher.maxDiscountAmount}'><fmt:formatNumber value='${voucher.maxDiscountAmount}' groupingUsed='false' maxFractionDigits='0'/></c:if>">
                                    <span>₫</span>
                                </div>
                            </div>
                            <div>
                                <label class="mk-label">Đơn hàng tối thiểu</label>
                                <div class="mk-suffix">
                                    <input type="text" id="minOrderValue" name="minOrderValue" class="mk-input" inputmode="numeric" placeholder="0"
                                           value="<c:if test='${not empty voucher.minOrderValue}'><fmt:formatNumber value='${voucher.minOrderValue}' groupingUsed='false' maxFractionDigits='0'/></c:if>">
                                    <span>₫</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 3. Giới hạn & thời gian -->
                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-calendar-days"></i> Thời gian &amp; giới hạn sử dụng</h2>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="mk-label">Bắt đầu <span class="text-red-500">*</span></label>
                                <input type="datetime-local" name="startDate" class="mk-input" value="${voucher.startDateInput}" required>
                            </div>
                            <div>
                                <label class="mk-label">Kết thúc <span class="text-red-500">*</span></label>
                                <input type="datetime-local" name="endDate" class="mk-input" value="${voucher.endDateInput}" required>
                            </div>
                            <div>
                                <label class="mk-label">Tổng số lượt sử dụng <span class="text-red-500">*</span></label>
                                <input type="number" name="usageLimit" min="1" class="mk-input" value="${voucher.usageLimit > 0 ? voucher.usageLimit : 100}" required>
                                <c:if test="${editing}"><p class="mk-hint">Đã dùng ${voucher.usedCount} lượt, không thể đặt thấp hơn.</p></c:if>
                            </div>
                            <div>
                                <label class="mk-label">Tối đa mỗi khách <span class="text-red-500">*</span></label>
                                <input type="number" name="perUserLimit" min="1" class="mk-input" value="${voucher.perUserLimit > 0 ? voucher.perUserLimit : 1}" required>
                                <p class="mk-hint">Số lần một khách hàng được dùng mã này.</p>
                            </div>
                        </div>
                    </div>

                    <!-- 4. Phạm vi -->
                    <div class="mk-card mk-card-pad flex flex-col gap-4">
                        <h2 class="mk-h2"><i class="fa-solid fa-bullseye"></i> Phạm vi áp dụng</h2>
                        <div class="mk-seg self-start">
                            <label><input type="radio" name="appliesTo" value="ALL" ${voucher.appliesTo != 'PRODUCTS' ? 'checked' : ''}><span><i class="fa-solid fa-store"></i> Toàn bộ sản phẩm của shop</span></label>
                            <label><input type="radio" name="appliesTo" value="PRODUCTS" ${voucher.appliesTo == 'PRODUCTS' ? 'checked' : ''}><span><i class="fa-solid fa-apple-whole"></i> Sản phẩm được chọn</span></label>
                        </div>
                        <div id="scopeProducts" style="display:none;">
                            <jsp:include page="/views/shop/layout/mk-product-picker.jsp" />
                        </div>
                    </div>
                </div>

                <!-- Cột phải: xem trước + lưu -->
                <div class="xl:col-span-4">
                    <div class="xl:sticky xl:top-24 flex flex-col gap-4">
                        <div class="mk-card mk-card-pad flex flex-col gap-3">
                            <h2 class="mk-h2"><i class="fa-solid fa-eye"></i> Xem trước voucher</h2>
                            <div class="mk-ticket" id="ticketPreview">
                                <div class="mk-ticket-left"><div class="mk-ticket-val" id="pvVal">10%</div><div class="mk-ticket-sub">GIẢM</div></div>
                                <div class="mk-ticket-right">
                                    <div class="mk-ticket-title" id="pvTitle">Tên chương trình voucher</div>
                                    <div class="mk-ticket-meta" id="pvMeta"></div>
                                    <span class="mk-ticket-code" id="pvCode">MA-VOUCHER</span>
                                </div>
                            </div>
                        </div>

                        <div class="mk-card mk-card-pad flex flex-col gap-4">
                            <div class="flex items-center justify-between">
                                <div>
                                    <div class="text-sm font-bold text-slate-800">Kích hoạt voucher</div>
                                    <div class="text-[11px] text-slate-500">Tắt để lưu nháp, chưa cho khách dùng.</div>
                                </div>
                                <label class="mk-switch"><input type="checkbox" name="active" ${voucher.active ? 'checked' : ''}><i></i></label>
                            </div>
                            <button type="submit" class="mk-btn-primary justify-center"><i class="fa-solid fa-floppy-disk"></i> ${editing ? 'Lưu thay đổi' : 'Tạo voucher'}</button>
                            <a href="${ctx}/shop/vouchers" class="mk-btn-ghost justify-center">Hủy</a>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
