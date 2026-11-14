<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>
<%-- Picker promotion: chọn theo biến thể; sản phẩm không có biến thể sẽ chọn trực tiếp theo product_id. --%>
<div class="mk-picker" id="productPicker">
    <div class="mk-picker-head">
        <div class="relative flex-1 min-w-[160px]">
            <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
            <input type="text" id="pickerSearch" class="mk-input mk-picker-search-input" placeholder="Tìm sản phẩm...">
        </div>
        <button type="button" id="pickerAll" class="text-xs font-bold text-emerald-700 hover:underline">Chọn tất cả</button>
        <button type="button" id="pickerNone" class="text-xs font-bold text-slate-500 hover:underline">Bỏ chọn</button>
        <span class="text-xs text-slate-500">Đã chọn: <b id="pickerCount" class="text-emerald-700">0</b></span>
    </div>
    <div class="mk-picker-list">
        <c:forEach var="p" items="${pickerProducts}">
            <c:choose>
            <c:when test="${variantPickerEnabled}">
            <div class="mk-picker-item mk-picker-product" data-name="<c:out value='${p.name}'/>">
                <div class="mk-picker-product-head">
                    <c:choose>
                        <c:when test="${not empty p.variants}">
                            <input type="checkbox" data-product-toggle ${selectedIds.contains(p.productId) ? 'checked' : ''} aria-label="Chọn tất cả biến thể">
                        </c:when>
                        <c:otherwise>
                            <input type="checkbox" class="mk-picker-product-target" name="productIds" value="${p.productId}" ${selectedIds.contains(p.productId) ? 'checked' : ''}>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${not empty p.image}"><img src="${p.image}" alt=""></c:when>
                        <c:otherwise><span class="mk-picker-ph"><i class="fa-solid fa-apple-whole"></i></span></c:otherwise>
                    </c:choose>
                    <span class="flex-1 min-w-0">
                        <span class="block text-sm font-semibold text-slate-800 truncate"><c:out value="${p.name}"/></span>
                        <span class="block text-[11px] text-slate-400"><c:if test="${not empty p.minPrice}">Từ <fmt:formatNumber value="${p.minPrice}" pattern="#,##0"/> ₫</c:if></span>
                    </span>
                    <c:if test="${not empty p.variants}"><span class="text-[10px] font-semibold text-slate-400">${fn:length(p.variants)} biến thể</span></c:if>
                </div>
                <c:if test="${not empty p.variants}">
                    <div class="mk-picker-variants">
                        <c:forEach var="v" items="${p.variants}">
                            <label class="mk-picker-variant">
                                <input type="checkbox" name="variantIds" value="${v.variantId}"
                                       ${selectedIds.contains(p.productId) or selectedVariantIds.contains(v.variantId) ? 'checked' : ''}>
                                <span class="flex-1"><c:out value="${v.variantName}"/> <span class="text-slate-400">(<c:out value="${v.unit}"/>)</span></span>
                                <span class="text-[11px] text-slate-500"><fmt:formatNumber value="${v.price}" pattern="#,##0"/> ₫</span>
                            </label>
                        </c:forEach>
                    </div>
                </c:if>
            </div>
            </c:when>
            <c:otherwise>
            <label class="mk-picker-item" data-name="<c:out value='${p.name}'/>">
                <input type="checkbox" name="productIds" value="${p.productId}" ${selectedIds.contains(p.productId) ? 'checked' : ''}>
                <c:choose>
                    <c:when test="${not empty p.image}"><img src="${p.image}" alt=""></c:when>
                    <c:otherwise><span class="mk-picker-ph"><i class="fa-solid fa-apple-whole"></i></span></c:otherwise>
                </c:choose>
                <span class="flex-1 min-w-0">
                    <span class="block text-sm font-semibold text-slate-800 truncate"><c:out value="${p.name}"/></span>
                    <span class="block text-[11px] text-slate-400">
                        <c:if test="${not empty p.minPrice}">Từ <fmt:formatNumber value="${p.minPrice}" pattern="#,##0"/> ₫</c:if>
                    </span>
                </span>
            </label>
            </c:otherwise>
            </c:choose>
        </c:forEach>
        <c:if test="${empty pickerProducts}">
            <div class="mk-empty"><i class="fa-solid fa-box-open"></i>Shop chưa có sản phẩm nào đang bán.</div>
        </c:if>
    </div>
</div>
