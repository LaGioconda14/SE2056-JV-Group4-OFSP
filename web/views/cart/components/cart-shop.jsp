<%@page pageEncoding="UTF-8"%>
<section class="overflow-hidden rounded-2xl border border-outline-variant/25 bg-surface-container-lowest shadow-sm" data-shop-group="${shopEntry.key}">
    <div class="flex flex-wrap items-center justify-between gap-3 border-b border-outline-variant/20 px-5 py-4">
        <div class="flex items-center gap-3">
            <label class="flex items-center cursor-pointer">
                <input type="checkbox" class="shop-checkbox w-4 h-4 accent-primary" data-shop-select data-shop-id="${shopEntry.key}" aria-label="Chọn tất cả sản phẩm của shop">
            </label>
            <a href="${pageContext.request.contextPath}/store?id=${shopEntry.key}" class="flex items-center gap-2 group hover:opacity-85 transition-opacity">
                <span class="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary"><span class="material-symbols-outlined text-[19px]">storefront</span></span>
                <strong class="text-sm sm:text-base text-on-surface group-hover:text-primary transition-colors"><c:out value="${not empty shop.shopName ? shop.shopName : 'Gian hàng Gốc Vườn'}"/></strong>
            </a>
        </div>
        <a href="${pageContext.request.contextPath}/store?id=${shopEntry.key}" class="text-xs font-semibold text-primary hover:underline">Xem Shop</a>
    </div>
    <c:forEach var="item" items="${shopItems}">
        <c:set var="available" value="${item.availabilityStatus eq 'AVAILABLE'}"/>
        <%@ include file="cart-item.jsp" %>
        <c:if test="${item.availabilityStatus ne 'NOT_FOUND'}"><%@ include file="variant-dialog.jsp" %></c:if>
    </c:forEach>
</section>
