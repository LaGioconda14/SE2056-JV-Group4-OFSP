<div class="grid grid-cols-1 gap-4 border-b border-outline-variant/15 px-5 py-5 transition hover:bg-surface-container-low/30 lg:grid-cols-[minmax(0,1fr)_140px_180px_150px_72px] lg:items-center"
     id="cart-item-${item.cartItemID}" data-cart-row data-item-id="${item.cartItemID}" data-shop-id="${shopEntry.key}" data-cart-status="<c:out value='${item.availabilityStatus}'/>" data-unit-price="${item.variant.price}">
    <div class="flex min-w-0 items-start gap-3">
        <input <c:if test="${available}">checked</c:if> <c:if test="${not available}">disabled</c:if> type="checkbox" data-cart-item value="${item.cartItemID}" aria-label="Chọn <c:out value='${item.variant.product.name}'/>" class="item-checkbox mt-8 h-4 w-4 shrink-0 accent-primary disabled:opacity-40">
        <div class="h-24 w-24 shrink-0 overflow-hidden rounded-xl border border-outline-variant/20 bg-surface-container">
            <c:choose>
                <c:when test="${not empty item.variant.product.image}"><img class="h-full w-full object-cover" src="<c:out value='${item.variant.product.image}'/>" alt="<c:out value='${item.variant.product.name}'/>"></c:when>
                <c:otherwise><div class="flex h-full w-full items-center justify-center text-outline"><span class="material-symbols-outlined">image</span></div></c:otherwise>
            </c:choose>
        </div>
        <div class="min-w-0 py-1">
            <a href="${pageContext.request.contextPath}/detail?id=${item.variant.product.productId}" class="line-clamp-2 text-sm font-bold text-on-surface hover:text-primary"><c:out value="${item.variant.product.name}"/></a>
            <c:choose><c:when test="${item.availabilityStatus ne 'NOT_FOUND'}"><button type="button" data-cart-action="open-variant" data-item-id="${item.cartItemID}" aria-controls="variant-dialog-${item.cartItemID}" aria-expanded="false" class="mt-2 flex max-w-full items-center gap-1 rounded-md bg-surface-container-low px-2 py-1 text-left text-xs text-on-surface-variant hover:text-primary"><span class="truncate">Phân loại: <c:out value="${item.variant.variantName}"/><c:if test="${not empty item.variant.unit}">, <c:out value="${item.variant.unit}"/></c:if></span><span class="material-symbols-outlined text-[15px]">arrow_drop_down</span></button></c:when><c:otherwise><span class="mt-2 block text-xs text-on-surface-variant">Phân loại: <c:out value="${item.variant.variantName}"/></span></c:otherwise></c:choose>
            <c:choose><c:when test="${available}"><span class="mt-2 block text-[11px] font-semibold text-primary">Còn hàng · Kho <c:out value="${item.variant.stockQuantity}"/></span></c:when><c:otherwise><span class="mt-2 block text-[11px] font-semibold text-error">Sản phẩm hiện không khả dụng</span></c:otherwise></c:choose>
        </div>
    </div>
    <div class="flex items-center justify-between lg:justify-center"><span class="text-xs text-on-surface-variant lg:hidden">Đơn giá</span><strong class="text-sm"><fmt:formatNumber value="${item.variant.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
    <div class="flex items-center justify-between lg:justify-center">
        <span class="text-xs text-on-surface-variant lg:hidden">Số lượng</span>
        <c:choose>
            <c:when test="${available}">
                <form method="post" action="<c:out value='${updateUrl}'/>" class="flex items-center gap-2" data-quantity-form>
                    <input type="hidden" name="cartItemId" value="${item.cartItemID}"><c:if test="${not empty sessionScope.cartCsrfToken}"><input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}"></c:if>
                    <div class="flex overflow-hidden rounded-lg border border-outline-variant/40"><button type="button" data-cart-action="decrement" aria-label="Giảm số lượng" class="h-8 w-8 hover:bg-surface-container">−</button><input name="quantity" type="number" min="1" max="${item.variant.stockQuantity}" value="${item.quantity}" data-quantity-input data-saved-quantity="${item.quantityAdjusted ? item.previousQuantity : item.quantity}" aria-label="Số lượng <c:out value='${item.variant.product.name}'/>" class="h-8 w-11 border-x border-outline-variant/30 text-center text-sm font-bold outline-none"><button type="button" data-cart-action="increment" aria-label="Tăng số lượng" class="h-8 w-8 hover:bg-surface-container">+</button></div>
                    <button type="submit" class="text-primary" title="Lưu số lượng" aria-label="Lưu số lượng"><span class="material-symbols-outlined text-[18px]">save</span></button>
                </form>
            </c:when>
            <c:otherwise><c:if test="${item.availabilityStatus ne 'NOT_FOUND'}"><button type="button" data-cart-action="open-variant" data-item-id="${item.cartItemID}" aria-controls="variant-dialog-${item.cartItemID}" aria-expanded="false" class="rounded-lg bg-primary px-3 py-2 text-xs font-bold text-white">Đổi phân loại</button></c:if></c:otherwise>
        </c:choose>
    </div>
    <div class="flex items-center justify-between lg:justify-center"><span class="text-xs text-on-surface-variant lg:hidden">Số tiền</span><strong data-line-subtotal class="text-sm text-tertiary"><fmt:formatNumber value="${item.subtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
    <form method="post" action="<c:out value='${removeUrl}'/>" data-remove-form class="flex justify-end lg:justify-center"><input type="hidden" name="cartItemId" value="${item.cartItemID}"><c:if test="${not empty sessionScope.cartCsrfToken}"><input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}"></c:if><button type="submit" aria-label="Xóa <c:out value='${item.variant.product.name}'/>" class="flex items-center gap-1 text-xs text-error hover:underline"><span class="material-symbols-outlined text-[17px]">delete</span>Xóa</button></form>
</div>
