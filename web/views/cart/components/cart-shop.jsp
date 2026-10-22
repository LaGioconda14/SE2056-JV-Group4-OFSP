<section class="overflow-hidden rounded-2xl border border-outline-variant/25 bg-surface-container-lowest shadow-sm" data-shop-group="${shopEntry.key}">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-outline-variant/20 px-5 py-4">
        <label class="flex items-center gap-3 cursor-pointer">
            <input checked type="checkbox" class="shop-checkbox w-4 h-4 accent-primary" data-shop-select data-shop-id="${shopEntry.key}" aria-label="Chọn tất cả sản phẩm của shop">
            <span class="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary"><span class="material-symbols-outlined text-[19px]">storefront</span></span>
            <strong class="text-sm sm:text-base text-on-surface"><c:out value="${not empty shop.shopName ? shop.shopName : 'Gian hàng Gốc Vườn'}"/></strong>
            <span class="material-symbols-outlined text-[18px] text-tertiary">chat</span>
        </label>
        <a href="<c:out value='${productsUrl}'/>" class="text-xs font-semibold text-primary hover:underline">Xem Shop</a>
    </div>
    <c:forEach var="item" items="${shopItems}">
        <c:set var="available" value="${item.availabilityStatus eq 'AVAILABLE'}"/>
        <%@ include file="cart-item.jsp" %>
        <c:if test="${item.availabilityStatus ne 'NOT_FOUND'}"><%@ include file="variant-dialog.jsp" %></c:if>
    </c:forEach>
    <div class="flex flex-wrap items-center justify-between gap-3 bg-surface-container-low/60 px-5 py-3 text-xs" id="shop-voucher-row-${shopEntry.key}">
        <div class="flex items-center gap-2 text-tertiary"><span class="material-symbols-outlined text-[18px]">confirmation_number</span><span>Voucher của Shop:</span><span data-shop-voucher-badge="${shopEntry.key}"></span></div>
        <div class="flex items-center gap-2">
            <button type="button" data-cart-action="open-shop-vouchers" data-shop-id="${shopEntry.key}" data-shop-name="<c:out value='${not empty shop.shopName ? shop.shopName : "Shop"}'/>" class="font-semibold text-primary hover:underline">Xem thêm voucher</button>
            <button type="button" data-cart-action="remove-shop-voucher" data-shop-id="${shopEntry.key}" hidden class="text-error hover:underline ml-1">Bỏ chọn</button>
        </div>
    </div>
</section>
