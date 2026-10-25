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
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        'on-tertiary-container': '#fff1eb', 'secondary-fixed': '#d9e6dd',
                        'inverse-on-surface': '#eef0ff', 'on-secondary-container': '#5b6760',
                        'primary-container': '#15803d', 'on-tertiary-fixed-variant': '#783200',
                        'inverse-primary': '#79db8d', 'on-tertiary-fixed': '#341100',
                        'on-surface': '#131b2e', 'background': '#faf8ff',
                        'surface-container-high': '#e2e7ff', 'on-error-container': '#93000a',
                        'on-secondary-fixed': '#131e19', 'surface-container-highest': '#dae2fd',
                        'secondary': '#55615a', 'surface-bright': '#faf8ff', 'error': '#ba1a1a',
                        'on-secondary': '#ffffff', 'on-primary-fixed-variant': '#005323',
                        'on-primary': '#ffffff', 'surface-container-low': '#f2f3ff',
                        'on-primary-fixed': '#00210a', 'error-container': '#ffdad6',
                        'surface-tint': '#006d30', 'tertiary-container': '#b85000',
                        'primary-fixed-dim': '#79db8d', 'on-secondary-fixed-variant': '#3e4943',
                        'on-surface-variant': '#3f493f', 'surface-dim': '#d2d9f4',
                        'tertiary': '#913e00', 'primary-fixed': '#95f8a7',
                        'outline-variant': '#becabc', 'secondary-fixed-dim': '#bdcac1',
                        'secondary-container': '#d9e6dd', 'surface': '#faf8ff',
                        'surface-container-lowest': '#ffffff', 'surface-container': '#eaedff',
                        'on-tertiary': '#ffffff', 'on-primary-container': '#d3ffd5',
                        'tertiary-fixed': '#ffdbca', 'outline': '#6f7a6e',
                        'tertiary-fixed-dim': '#ffb690', 'on-error': '#ffffff',
                        'surface-variant': '#dae2fd', 'primary': '#00652c',
                        'on-background': '#131b2e', 'inverse-surface': '#283044'
                    },
                    borderRadius: {DEFAULT: '0.25rem', lg: '0.5rem', xl: '0.75rem', full: '9999px'},
                    spacing: {
                        'margin-sm': '1rem', 'space-xs': '0.25rem', 'space-lg': '1.5rem',
                        'space-xl': '2.5rem', 'space-sm': '0.5rem', margin: '2rem',
                        'space-md': '1rem', gutter: '1.5rem', 'margin-lg': '4rem', 'gutter-sm': '1rem'
                    },
                    fontFamily: {
                        'label-caps': ['Plus Jakarta Sans', 'sans-serif'], 'body-lg': ['Plus Jakarta Sans', 'sans-serif'],
                        'headline-md': ['Plus Jakarta Sans', 'sans-serif'], 'display-hero': ['Plus Jakarta Sans', 'sans-serif'],
                        'body-md': ['Plus Jakarta Sans', 'sans-serif'], 'headline-lg': ['Plus Jakarta Sans', 'sans-serif'],
                        'headline-lg-mobile': ['Plus Jakarta Sans', 'sans-serif'], 'body-sm': ['Plus Jakarta Sans', 'sans-serif'],
                        'display-hero-mobile': ['Plus Jakarta Sans', 'sans-serif'], 'price-hero': ['Plus Jakarta Sans', 'sans-serif'],
                        'headline-sm': ['Plus Jakarta Sans', 'sans-serif'], 'price-md': ['Plus Jakarta Sans', 'sans-serif']
                    },
                    fontSize: {
                        'label-caps': ['11px', {lineHeight: '14px', letterSpacing: '0.06em', fontWeight: '700'}],
                        'body-lg': ['16px', {lineHeight: '24px', letterSpacing: '-0.005em', fontWeight: '400'}],
                        'headline-md': ['22px', {lineHeight: '28px', letterSpacing: '-0.015em', fontWeight: '700'}],
                        'display-hero': ['48px', {lineHeight: '56px', letterSpacing: '-0.025em', fontWeight: '800'}],
                        'body-md': ['14px', {lineHeight: '20px', letterSpacing: '0em', fontWeight: '400'}],
                        'headline-lg': ['32px', {lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '700'}],
                        'headline-lg-mobile': ['26px', {lineHeight: '32px', letterSpacing: '-0.015em', fontWeight: '700'}],
                        'body-sm': ['12px', {lineHeight: '16px', letterSpacing: '0.01em', fontWeight: '500'}],
                        'display-hero-mobile': ['34px', {lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '800'}],
                        'price-hero': ['28px', {lineHeight: '32px', letterSpacing: '-0.02em', fontWeight: '800'}],
                        'headline-sm': ['18px', {lineHeight: '24px', letterSpacing: '-0.01em', fontWeight: '600'}],
                        'price-md': ['18px', {lineHeight: '22px', letterSpacing: '-0.01em', fontWeight: '700'}]
                    }
                }
            }
        };
    </script>
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
<%@ include file="components/cart-header.jsp" %>

<main class="w-full pt-36 bg-surface min-h-[calc(100vh-280px)]" data-cart>
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

            <div class="flex flex-col md:flex-row md:items-center justify-between gap-space-md pt-space-md pb-space-lg">
                <div class="flex flex-col gap-space-xs">
                    <nav class="flex items-center gap-space-xs text-body-sm font-body-sm text-on-surface-variant" aria-label="Breadcrumb">
                        <a class="hover:text-primary transition-colors flex items-center gap-1" href="<c:out value='${homeUrl}'/>"><span class="material-symbols-outlined text-[16px]">home</span><span>Trang Chủ</span></a>
                        <span>/</span><a class="hover:text-primary transition-colors" href="<c:out value='${productsUrl}'/>">Cửa Hàng</a><span>/</span><span class="text-on-surface font-semibold">Giỏ Hàng</span>
                    </nav>
                    <div class="flex items-center gap-space-sm mt-1">
                        <h1 class="text-headline-lg font-headline-lg text-on-surface tracking-tight">Shopping Cart</h1>
                        <span class="px-space-sm py-0.5 rounded-full bg-secondary-container text-on-secondary-container font-label-caps text-label-caps" id="badge-total-items"><c:out value="${cart ne null and not empty cart.items ? cart.items.size() : 0}"/> món trong giỏ</span>
                    </div>
                </div>
                <c:if test="${cart ne null and not empty cart.items}">
                    <div class="flex items-center gap-space-sm text-body-sm font-medium text-on-surface-variant bg-surface-container-lowest px-space-md py-2 rounded-xl shadow-sm border border-outline-variant/30">
                        <span class="material-symbols-outlined text-primary text-[18px]">verified</span>
                        <span data-selected-summary-count aria-live="polite">Đã chọn: <strong class="text-on-surface font-bold"><c:out value="${cart.items.size()}"/>/<c:out value="${cart.items.size()}"/> món</strong></span>
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
                        <div class="hidden lg:grid grid-cols-[minmax(0,1fr)_140px_180px_150px_72px] items-center rounded-2xl border border-outline-variant/20 bg-surface-container-lowest px-5 py-4 text-xs font-bold uppercase tracking-wider text-on-surface-variant shadow-sm">
                            <label class="flex items-center gap-3 normal-case text-sm text-on-surface cursor-pointer"><input checked type="checkbox" data-select-all class="select-all-toggle w-4 h-4 accent-primary" aria-label="Chọn tất cả sản phẩm">Sản phẩm (<span id="select-all-count"><c:out value="${cart.items.size()}"/></span>)</label>
                            <span class="text-center">Đơn giá</span><span class="text-center">Số lượng</span><span class="text-center">Số tiền</span><span class="text-center">Thao tác</span>
                        </div>
                        <c:forEach var="shopEntry" items="${cart.itemsByShop}">
                            <c:set var="shopItems" value="${shopEntry.value}"/>
                            <c:set var="shop" value="${shopItems[0].variant.product}"/>
                            <%@ include file="components/cart-shop.jsp" %>
                        </c:forEach>
                        <%@ include file="components/cart-summary.jsp" %>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<%@ include file="components/cart-footer.jsp" %>
<script src="<c:url value='/assets/js/cart.js?v=20261024'/>"></script>
</body>
</html>
