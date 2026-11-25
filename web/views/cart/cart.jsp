<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="homeUrl" value="/home"/>
<c:url var="productsUrl" value="/products"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="updateUrl" value="/cart/update"/>
<c:url var="removeUrl" value="/cart/remove"/>
<c:url var="changeVariantUrl" value="/cart/change-variant"/>
<c:url var="checkoutUrl" value="/checkout"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <title>Giỏ hàng - Gốc Vườn</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="dns-prefetch" href="https://cdn.tailwindcss.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="<c:url value='/assets/js/cart-tailwind-config.js'/>"></script>
    <style>
        @layer base {
            html, body { margin: 0; padding: 0; }
            body { overscroll-behavior: none; }
            main > :first-child { margin-top: 0 !important; }
            main > :last-child { margin-bottom: 0 !important; }
        }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-surface font-body-md text-on-surface antialiased">
<jsp:include page="/views/common/header.jsp" />

<main class="w-full pt-6 bg-surface min-h-[calc(100vh-280px)]" data-cart>
    <div class="flex flex-col w-full">
        <section class="w-full max-w-[1360px] mx-auto px-margin-sm lg:px-margin pb-space-xl">
            <c:if test="${not empty errorMessage}">
                <div class="mb-4 p-4 rounded-xl bg-error-container text-on-error-container font-semibold flex items-center gap-2 shadow-sm" role="alert">
                    <span class="material-symbols-outlined">error</span> <c:out value="${errorMessage}"/>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="mb-4 p-4 rounded-xl bg-primary-fixed text-on-primary-fixed font-semibold flex items-center gap-2 shadow-sm" role="status">
                    <span class="material-symbols-outlined">check_circle</span> <c:out value="${successMessage}"/>
                </div>
            </c:if>
            <c:if test="${not empty stockNotice}">
                <div class="mb-4 p-4 rounded-xl bg-amber-50 text-amber-800 border border-amber-200 font-semibold flex items-center gap-2 shadow-sm" role="status">
                    <span class="material-symbols-outlined">inventory</span> <c:out value="${stockNotice}"/>
                </div>
            </c:if>

            <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 pt-4 pb-6">
                <div class="flex flex-col gap-1.5">
                    <nav class="flex items-center gap-1.5 text-xs text-gray-500 font-medium" aria-label="Breadcrumb">
                        <a class="hover:text-[#00652c] transition-colors flex items-center gap-1" href="<c:out value='${homeUrl}'/>"><span class="material-symbols-outlined text-[16px]">home</span><span>Trang Chủ</span></a>
                        <span class="text-gray-300">/</span><a class="hover:text-[#00652c] transition-colors" href="<c:out value='${productsUrl}'/>">Cửa Hàng</a><span class="text-gray-300">/</span><span class="text-gray-900 font-bold">Giỏ Hàng</span>
                    </nav>
                    <div class="flex items-center gap-3 mt-1.5 flex-wrap">
                        <h1 class="text-2xl sm:text-3xl font-extrabold text-gray-900 tracking-tight">Giỏ Hàng Của Bạn</h1>
                        <span class="px-3 py-1 rounded-full bg-emerald-100 text-[#00652c] font-bold text-xs shadow-xs" id="badge-total-items"><c:out value="${cart ne null and not empty cart.items ? cart.items.size() : 0}"/> món trong giỏ</span>
                    </div>
                </div>
                <c:if test="${cart ne null and not empty cart.items}">
                    <div class="flex items-center gap-2 text-xs font-semibold text-gray-700 bg-white px-3.5 py-2 rounded-xl shadow-xs border border-gray-200">
                        <span class="material-symbols-outlined text-[#00652c] text-[18px]">verified</span>
                        <span data-selected-summary-count aria-live="polite">Đã chọn: <strong class="text-gray-900 font-bold"><c:out value="${cart.items.size()}"/>/<c:out value="${cart.items.size()}"/> món</strong></span>
                    </div>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${cart eq null or empty cart.items}">
                    <div class="bg-surface-container-lowest rounded-2xl p-12 text-center border border-outline-variant/20 shadow-sm my-6">
                        <div class="w-20 h-20 mx-auto rounded-full bg-primary/10 flex items-center justify-center text-primary mb-4"><span class="material-symbols-outlined text-[42px]">shopping_basket</span></div>
                        <h2 class="text-headline-sm font-headline-sm text-on-surface mb-2">Giỏ hàng của bạn đang trống</h2>
                        <p class="text-on-surface-variant text-body-md mb-6 max-w-md mx-auto">Hãy khám phá các loại trái cây tươi ngon từ nông trại sạch của Gốc Vườn và thêm vào giỏ hàng ngay nhé!</p>
                        <a href="<c:out value='${productsUrl}'/>" class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-primary text-on-primary font-semibold hover:bg-on-primary-fixed-variant transition-colors shadow-md"><span class="material-symbols-outlined">storefront</span> Mua sắm ngay</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="space-y-4 pb-4">
                        <div class="hidden lg:grid grid-cols-[minmax(0,1fr)_140px_180px_150px_72px] gap-4 items-center rounded-2xl border border-gray-200/80 bg-white px-5 py-4 text-xs font-bold uppercase tracking-wider text-gray-500 shadow-xs">
                            <label class="flex items-center gap-3 normal-case text-sm text-gray-900 cursor-pointer"><input type="checkbox" data-select-all class="select-all-toggle w-4 h-4 rounded accent-[#00652c]" aria-label="Chọn tất cả sản phẩm">Sản phẩm (<span id="select-all-count"><c:out value="${cart.items.size()}"/></span>)</label>
                            <span class="text-center">Đơn giá</span><span class="text-center">Số lượng</span><span class="text-center">Số tiền</span><span class="text-center">Thao tác</span>
                        </div>
                        <%-- Nhóm theo shop chỉ để hiển thị/chọn nhanh; danh sách dòng mua thực tế do form checkout gửi. --%>
                        <c:forEach var="shopEntry" items="${cart.itemsByShop}">
                            <c:set var="shopItems" value="${shopEntry.value}"/>
                            <c:set var="shop" value="${shopItems[0].variant}"/>
                            <%@ include file="components/cart-shop.jsp" %>
                        </c:forEach>
                        <%@ include file="components/cart-summary.jsp" %>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<!-- Footer Chuẩn Đồng Bộ Website Gốc Vườn -->
<jsp:include page="/views/common/site-footer.jsp" />
<script src="<c:url value='/assets/js/cart.js?v=20261104b'/>"></script>
</body>
</html>
