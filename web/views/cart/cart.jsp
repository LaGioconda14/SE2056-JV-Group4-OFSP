<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="homeUrl" value="/home.jsp"/>
<c:url var="productsUrl" value="/products"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="updateUrl" value="/cart/update"/>
<c:url var="removeUrl" value="/cart/remove"/>
<c:url var="checkoutUrl" value="/views/order/checkout.jsp"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <title>Giỏ hàng - FreshFruit</title>
    <!-- Google Fonts & Material Symbols -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        'on-tertiary-container': '#fff1eb',
                        'secondary-fixed': '#d9e6dd',
                        'inverse-on-surface': '#eef0ff',
                        'on-secondary-container': '#5b6760',
                        'primary-container': '#15803d',
                        'on-tertiary-fixed-variant': '#783200',
                        'inverse-primary': '#79db8d',
                        'on-tertiary-fixed': '#341100',
                        'on-surface': '#131b2e',
                        'background': '#faf8ff',
                        'surface-container-high': '#e2e7ff',
                        'on-error-container': '#93000a',
                        'on-secondary-fixed': '#131e19',
                        'surface-container-highest': '#dae2fd',
                        'secondary': '#55615a',
                        'surface-bright': '#faf8ff',
                        'error': '#ba1a1a',
                        'on-secondary': '#ffffff',
                        'on-primary-fixed-variant': '#005323',
                        'on-primary': '#ffffff',
                        'surface-container-low': '#f2f3ff',
                        'on-primary-fixed': '#00210a',
                        'error-container': '#ffdad6',
                        'surface-tint': '#006d30',
                        'tertiary-container': '#b85000',
                        'primary-fixed-dim': '#79db8d',
                        'on-secondary-fixed-variant': '#3e4943',
                        'on-surface-variant': '#3f493f',
                        'surface-dim': '#d2d9f4',
                        'tertiary': '#913e00',
                        'primary-fixed': '#95f8a7',
                        'outline-variant': '#becabc',
                        'secondary-fixed-dim': '#bdcac1',
                        'secondary-container': '#d9e6dd',
                        'surface': '#faf8ff',
                        'surface-container-lowest': '#ffffff',
                        'surface-container': '#eaedff',
                        'on-tertiary': '#ffffff',
                        'on-primary-container': '#d3ffd5',
                        'tertiary-fixed': '#ffdbca',
                        'outline': '#6f7a6e',
                        'tertiary-fixed-dim': '#ffb690',
                        'on-error': '#ffffff',
                        'surface-variant': '#dae2fd',
                        'primary': '#00652c',
                        'on-background': '#131b2e',
                        'inverse-surface': '#283044'
                    },
                    borderRadius: {
                        'DEFAULT': '0.25rem',
                        'lg': '0.5rem',
                        'xl': '0.75rem',
                        'full': '9999px'
                    },
                    spacing: {
                        'margin-sm': '1rem',
                        'space-xs': '0.25rem',
                        'space-lg': '1.5rem',
                        'space-xl': '2.5rem',
                        'space-sm': '0.5rem',
                        'margin': '2rem',
                        'space-md': '1rem',
                        'gutter': '1.5rem',
                        'margin-lg': '4rem',
                        'gutter-sm': '1rem'
                    },
                    fontFamily: {
                        'label-caps': ['Plus Jakarta Sans', 'sans-serif'],
                        'body-lg': ['Plus Jakarta Sans', 'sans-serif'],
                        'headline-md': ['Plus Jakarta Sans', 'sans-serif'],
                        'display-hero': ['Plus Jakarta Sans', 'sans-serif'],
                        'body-md': ['Plus Jakarta Sans', 'sans-serif'],
                        'headline-lg': ['Plus Jakarta Sans', 'sans-serif'],
                        'headline-lg-mobile': ['Plus Jakarta Sans', 'sans-serif'],
                        'body-sm': ['Plus Jakarta Sans', 'sans-serif'],
                        'display-hero-mobile': ['Plus Jakarta Sans', 'sans-serif'],
                        'price-hero': ['Plus Jakarta Sans', 'sans-serif'],
                        'headline-sm': ['Plus Jakarta Sans', 'sans-serif'],
                        'price-md': ['Plus Jakarta Sans', 'sans-serif']
                    },
                    fontSize: {
                        'label-caps': ['11px', { lineHeight: '14px', letterSpacing: '0.06em', fontWeight: '700' }],
                        'body-lg': ['16px', { lineHeight: '24px', letterSpacing: '-0.005em', fontWeight: '400' }],
                        'headline-md': ['22px', { lineHeight: '28px', letterSpacing: '-0.015em', fontWeight: '700' }],
                        'display-hero': ['48px', { lineHeight: '56px', letterSpacing: '-0.025em', fontWeight: '800' }],
                        'body-md': ['14px', { lineHeight: '20px', letterSpacing: '0em', fontWeight: '400' }],
                        'headline-lg': ['32px', { lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '700' }],
                        'headline-lg-mobile': ['26px', { lineHeight: '32px', letterSpacing: '-0.015em', fontWeight: '700' }],
                        'body-sm': ['12px', { lineHeight: '16px', letterSpacing: '0.01em', fontWeight: '500' }],
                        'display-hero-mobile': ['34px', { lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '800' }],
                        'price-hero': ['28px', { lineHeight: '32px', letterSpacing: '-0.02em', fontWeight: '800' }],
                        'headline-sm': ['18px', { lineHeight: '24px', letterSpacing: '-0.01em', fontWeight: '600' }],
                        'price-md': ['18px', { lineHeight: '22px', letterSpacing: '-0.01em', fontWeight: '700' }]
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
        ::-webkit-scrollbar { display: none; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
    </style>
</head>
<body class="bg-surface font-body-md text-on-surface antialiased">

<!-- ==================== HEADER ==================== -->
<header class="fixed top-0 left-0 right-0 w-full z-50 bg-surface-container-lowest/95 backdrop-blur-xl shadow-[0_4px_20px_rgba(20,83,45,0.06)]">
    <!-- Main Header Bar -->
    <div class="max-w-[1360px] mx-auto px-margin-sm lg:px-margin h-20 flex items-center justify-between gap-space-lg">
        <!-- Brand Logo -->
        <a href="<c:out value='${homeUrl}'/>" class="flex items-center gap-3 shrink-0 no-underline">
            <!-- Apple Icon -->
            <svg class="h-9 w-9" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M19 4C19 4 24 4 23 9C20 9 18 7 19 4Z" fill="#16a34a"/>
                <path d="M18 6.5C17.5 8.5 16 10.5 15 11.5" stroke="#4b5563" stroke-width="2" stroke-linecap="round"/>
                <path d="M18 12.5C16 9.5 11 9.5 8 12.5C4 16.5 5 23.5 9 28.5C12 32.5 15 32.5 18 30.5C21 32.5 24 32.5 27 28.5C31 23.5 32 16.5 28 12.5C25 9.5 20 9.5 18 12.5Z" fill="url(#appleGrad)"/>
                <defs>
                    <linearGradient id="appleGrad" x1="8" y1="11" x2="28" y2="33" gradientUnits="userSpaceOnUse">
                        <stop stop-color="#fb7185"/>
                        <stop offset="0.6" stop-color="#ef4444"/>
                        <stop offset="1" stop-color="#dc2626"/>
                    </linearGradient>
                </defs>
            </svg>
            <div class="flex flex-col">
                <span class="font-headline-md text-headline-md text-primary tracking-tight leading-none">FreshFruit</span>
                <span class="text-[9px] font-bold tracking-widest text-primary/80 uppercase mt-0.5">DIRECT FROM ORCHARD</span>
            </div>
        </a>

        <!-- Search Bar -->
        <form method="get" action="<c:out value='${productsUrl}'/>" class="flex-1 max-w-2xl hidden md:flex items-center bg-surface-container-low rounded-full px-4 py-1.5 border border-outline-variant/30 focus-within:border-primary transition-colors">
            <div class="flex items-center gap-1 pr-3 text-on-surface-variant font-body-sm text-body-sm cursor-pointer shrink-0">
                <select name="categoryId" class="bg-transparent border-0 outline-none text-on-surface cursor-pointer text-sm font-medium pr-1">
                    <option value="">Tất cả danh mục</option>
                    <option value="1">Trái Cây Nội Địa</option>
                    <option value="2">Trái Cây Nhập Khẩu</option>
                    <option value="3">Hộp Quà & Combo</option>
                    <option value="4">Trái Cây Sấy</option>
                </select>
            </div>
            <div class="h-5 w-px bg-outline-variant/40 mr-3"></div>
            <div class="flex items-center flex-1 gap-space-sm">
                <input class="w-full bg-transparent border-0 outline-none text-on-surface placeholder:text-on-surface-variant/70 font-body-sm text-body-sm"
                       name="search" placeholder="Tìm kiếm dâu tây, bơ sáp, nho mẫu đơn..." type="text">
                <button type="submit" class="w-8 h-8 rounded-full bg-primary text-on-primary flex items-center justify-center hover:bg-on-primary-fixed-variant transition-colors shrink-0">
                    <span class="material-symbols-outlined text-[18px]">search</span>
                </button>
            </div>
        </form>

        <!-- Right Header Action Pills -->
        <div class="flex items-center gap-space-md shrink-0">
            <!-- Cart Button Pill -->
            <a class="flex items-center gap-2.5 py-1.5 px-3.5 rounded-full border border-primary/30 bg-primary/5 hover:bg-primary/10 transition-colors" data-path="cart" href="<c:out value='${cartUrl}'/>">
                <div class="relative flex items-center justify-center">
                    <span class="material-symbols-outlined text-primary text-[24px]">shopping_cart</span>
                    <span class="absolute -top-1.5 -right-2 w-4 h-4 bg-error text-on-error rounded-full font-label-caps text-[10px] flex items-center justify-center" id="nav-cart-badge">
                        <c:out value="${cart ne null ? cart.totalQuantity : 0}"/>
                    </span>
                </div>
                <div class="flex flex-col text-left">
                    <span class="text-price-md font-price-md text-primary font-bold leading-tight" id="nav-cart-total">
                        <fmt:formatNumber value="${cart ne null ? cart.totalAmount : 0}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                    </span>
                </div>
            </a>

            <!-- User Account Pill -->
            <div class="relative group">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div class="flex items-center gap-2 py-1.5 px-3 rounded-full bg-surface-container-low hover:bg-surface-container transition-colors cursor-pointer border border-outline-variant/30">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.avatarUrl}">
                                    <img alt="Profile" class="w-7 h-7 rounded-full object-cover" src="<c:out value='${sessionScope.user.avatarUrl}'/>">
                                </c:when>
                                <c:otherwise>
                                    <span class="w-7 h-7 rounded-full bg-primary/20 text-primary flex items-center justify-center text-xs font-bold">
                                        <c:out value="${sessionScope.user.fullName.substring(0, 1)}"/>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <span class="font-medium text-sm text-on-surface max-w-[140px] truncate"><c:out value="${sessionScope.user.fullName}"/></span>
                            <span class="material-symbols-outlined text-on-surface-variant text-[18px]">expand_more</span>
                        </div>
                        <!-- Dropdown Menu -->
                        <div class="absolute right-0 mt-1 w-48 bg-surface-container-lowest rounded-xl shadow-lg border border-outline-variant/30 py-2 hidden group-hover:block z-50">
                            <a href="<c:url value='/profile'/>" class="flex items-center gap-2 px-4 py-2 text-sm text-on-surface hover:bg-surface-container-low transition-colors">
                                <span class="material-symbols-outlined text-[18px]">person</span> Hồ sơ cá nhân
                            </a>
                            <a href="<c:url value='/change-password'/>" class="flex items-center gap-2 px-4 py-2 text-sm text-on-surface hover:bg-surface-container-low transition-colors">
                                <span class="material-symbols-outlined text-[18px]">key</span> Đổi mật khẩu
                            </a>
                            <div class="h-px bg-outline-variant/20 my-1"></div>
                            <a href="<c:url value='/logout'/>" class="flex items-center gap-2 px-4 py-2 text-sm text-error hover:bg-error-container/20 transition-colors">
                                <span class="material-symbols-outlined text-[18px]">logout</span> Đăng xuất
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="<c:url value='/login'/>" class="flex items-center gap-1.5 py-1.5 px-3 rounded-full bg-primary text-on-primary text-sm font-semibold hover:bg-on-primary-fixed-variant transition-colors">
                            <span class="material-symbols-outlined text-[18px]">login</span> Đăng nhập
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Category Navigation Bar -->
    <div class="bg-surface-container-lowest border-t border-outline-variant/20 shadow-[0_1px_4px_rgba(0,0,0,0.02)]">
        <div class="max-w-[1360px] mx-auto px-margin-sm lg:px-margin h-11 flex items-center justify-between">
            <nav class="flex items-center gap-space-lg text-body-md font-body-md">
                <a class="text-on-surface-variant hover:text-primary transition-colors font-medium" href="<c:out value='${homeUrl}'/>">Trang Chủ</a>
                <a class="text-on-surface-variant hover:text-primary transition-colors font-medium" href="<c:out value='${productsUrl}'/>">Cửa Hàng</a>
                <a class="text-on-surface-variant hover:text-primary transition-colors font-medium" href="<c:out value='${productsUrl}'/>">Danh Mục Trái Cây</a>
                <a class="text-on-surface-variant hover:text-primary transition-colors font-medium" href="<c:out value='${productsUrl}'/>">Hộp Quà &amp; Combo</a>
                <a class="text-on-surface-variant hover:text-primary transition-colors font-medium" href="<c:out value='${homeUrl}'/>#about">Về Nông Trại</a>
                <a class="text-on-surface-variant hover:text-primary transition-colors font-medium" href="<c:out value='${homeUrl}'/>#contact">Liên Hệ</a>
            </nav>
            <div class="flex items-center">
                <span class="flex items-center gap-1.5 px-3 py-1 bg-tertiary-fixed text-on-tertiary-fixed rounded-full font-label-caps text-label-caps font-semibold">
                    <span class="material-symbols-outlined text-[14px] text-tertiary">bolt</span>
                    <span>Flash Sale Hôm Nay: <strong>Giảm 30% Cam &amp; Bưởi Da Xanh</strong></span>
                </span>
            </div>
        </div>
    </div>
</header>

<!-- ==================== MAIN CONTENT ==================== -->
<main class="w-full pt-36 bg-surface min-h-[calc(100vh-280px)]">
<div class="flex flex-col w-full">
<section class="w-full max-w-[1360px] mx-auto px-margin-sm lg:px-margin pb-space-xl">

    <!-- Thông báo lỗi hoặc thành công -->
    <c:if test="${not empty errorMessage}">
        <div class="mb-4 p-4 rounded-xl bg-error-container text-on-error-container font-semibold flex items-center gap-2 shadow-sm">
            <span class="material-symbols-outlined">error</span> <c:out value="${errorMessage}"/>
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="mb-4 p-4 rounded-xl bg-primary-fixed text-on-primary-fixed font-semibold flex items-center gap-2 shadow-sm">
            <span class="material-symbols-outlined">check_circle</span> <c:out value="${successMessage}"/>
        </div>
    </c:if>

    <!-- Breadcrumb & Tiêu đề trang -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-space-md pt-space-md pb-space-lg">
        <div class="flex flex-col gap-space-xs">
            <nav class="flex items-center gap-space-xs text-body-sm font-body-sm text-on-surface-variant">
                <a class="hover:text-primary transition-colors flex items-center gap-1" href="<c:out value='${homeUrl}'/>">
                    <span class="material-symbols-outlined text-[16px]">home</span>
                    <span>Trang Chủ</span>
                </a>
                <span>/</span>
                <a class="hover:text-primary transition-colors" href="<c:out value='${productsUrl}'/>">Cửa Hàng</a>
                <span>/</span>
                <span class="text-on-surface font-semibold">Giỏ Hàng</span>
            </nav>
            <div class="flex items-center gap-space-sm mt-1">
                <h1 class="text-headline-lg font-headline-lg text-on-surface tracking-tight">Shopping Cart</h1>
                <span class="px-space-sm py-0.5 rounded-full bg-secondary-container text-on-secondary-container font-label-caps text-label-caps" id="badge-total-items">
                    <c:out value="${cart ne null and not empty cart.items ? cart.items.size() : 0}"/> món trong giỏ
                </span>
            </div>
        </div>
        <c:if test="${cart ne null and not empty cart.items}">
            <div class="flex items-center gap-space-sm text-body-sm font-medium text-on-surface-variant bg-surface-container-lowest px-space-md py-2 rounded-xl shadow-sm border border-outline-variant/30">
                <span class="material-symbols-outlined text-primary text-[18px]">verified</span>
                <span id="selected-summary-count">Đã chọn: <strong class="text-on-surface font-bold"><c:out value="${cart.items.size()}"/>/<c:out value="${cart.items.size()}"/> món</strong></span>
            </div>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${cart eq null or empty cart.items}">
            <!-- Trạng thái giỏ hàng trống -->
            <div class="bg-surface-container-lowest rounded-2xl p-12 text-center border border-outline-variant/20 shadow-sm my-6">
                <div class="w-20 h-20 mx-auto rounded-full bg-primary/10 flex items-center justify-center text-primary mb-4">
                    <span class="material-symbols-outlined text-[42px]">shopping_basket</span>
                </div>
                <h2 class="text-headline-sm font-headline-sm text-on-surface mb-2">Giỏ hàng của bạn đang trống</h2>
                <p class="text-on-surface-variant text-body-md mb-6 max-w-md mx-auto">Hãy khám phá các loại trái cây tươi ngon từ nông trại sạch của FreshFruit và thêm vào giỏ hàng ngay nhé!</p>
                <a href="<c:out value='${productsUrl}'/>" class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-primary text-on-primary font-semibold hover:bg-on-primary-fixed-variant transition-colors shadow-md">
                    <span class="material-symbols-outlined">storefront</span> Mua sắm ngay
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Banner Tiến Độ Ưu Đãi Giao Hàng -->
            <div class="mb-space-lg p-space-md rounded-2xl bg-surface-container-low shadow-sm flex flex-col sm:flex-row items-center justify-between gap-space-md">
                <div class="flex items-center gap-space-md w-full sm:w-auto">
                    <div class="w-12 h-12 rounded-xl bg-primary-fixed flex items-center justify-center text-on-primary-fixed shrink-0 shadow-sm" id="progress-icon-box">
                        <span class="material-symbols-outlined text-[26px]">rocket_launch</span>
                    </div>
                    <div class="flex flex-col">
                        <div class="flex items-center gap-2">
                            <span class="font-headline-sm text-headline-sm text-on-surface" id="delivery-progress-title">Gần đạt ưu đãi rồi!</span>
                            <span class="text-body-sm font-semibold text-primary bg-primary/10 px-2 py-0.5 rounded-md" id="delivery-progress-status">200.000 ₫</span>
                        </div>
                        <p class="text-body-sm font-body-sm text-on-surface-variant mt-0.5" id="delivery-progress-desc">
                            Thêm sản phẩm để đạt <span class="font-bold text-primary">Miễn phí giao hàng trong ngày!</span>
                        </p>
                    </div>
                </div>
                <div class="w-full sm:w-64 flex flex-col gap-1.5 shrink-0">
                    <div class="w-full bg-surface-container-highest rounded-full h-3 overflow-hidden p-0.5">
                        <div class="bg-primary h-full rounded-full transition-all duration-700 ease-out" id="delivery-progress-bar" style="width: 70%;"></div>
                    </div>
                    <div class="flex justify-between text-[11px] font-label-caps text-on-surface-variant">
                        <span id="progress-bar-current">Hiện tại</span>
                        <span class="text-primary font-bold">Mục tiêu: 200.000 ₫</span>
                    </div>
                </div>
            </div>

            <!-- Bảng giỏ hàng & Cột chi tiết -->
            <div class="grid grid-cols-1 gap-gutter items-start">
                <div class="flex flex-col gap-space-lg w-full">
                    <div class="bg-surface-container-lowest rounded-2xl shadow-sm overflow-hidden border border-outline-variant/20">
                        <!-- Table Header -->
                        <div class="px-space-md sm:px-space-lg py-space-md bg-surface-container-low text-on-surface-variant font-label-caps text-label-caps uppercase tracking-wider flex items-center justify-between border-b border-outline-variant/20">
                            <div class="flex items-center gap-3">
                                <label class="flex items-center gap-2.5 cursor-pointer select-none">
                                    <input checked class="w-4 h-4 rounded border-outline-variant text-primary focus:ring-primary/20 accent-primary cursor-pointer"
                                           id="select-all-checkbox" onchange="toggleSelectAll(this.checked)" type="checkbox">
                                    <span class="font-bold text-on-surface text-body-sm normal-case">
                                        Chọn tất cả / Select All (<span id="select-all-count"><c:out value="${cart.items.size()}"/></span>)
                                    </span>
                                </label>
                            </div>
                            <div class="hidden sm:grid grid-cols-12 gap-2 flex-1 max-w-[500px] text-right">
                                <div class="col-span-4 text-center">Đơn giá</div>
                                <div class="col-span-4 text-center">Số lượng</div>
                                <div class="col-span-4 text-right pr-1">Thành tiền</div>
                            </div>
                        </div>

                        <!-- Danh sách Cart Items -->
                        <c:forEach var="item" items="${cart.items}" varStatus="status">
                            <div class="p-space-md sm:px-space-lg sm:py-space-lg bg-surface-container-lowest transition-colors hover:bg-surface-container-low/30 border-b border-outline-variant/20 last:border-b-0"
                                 data-item-id="${item.cartItemID}" data-shop-id="${item.variant.product.shopId}" id="cart-item-${item.cartItemID}">
                                <div class="grid grid-cols-1 sm:grid-cols-12 gap-space-md items-center">
                                    <!-- Cột Sản phẩm & Ảnh -->
                                    <div class="sm:col-span-6 flex items-center gap-space-sm min-w-0">
                                        <input checked class="item-checkbox w-4 h-4 rounded border-outline-variant text-primary focus:ring-primary/20 accent-primary cursor-pointer shrink-0"
                                               data-target="${item.cartItemID}" onchange="handleItemCheckChange()" type="checkbox">
                                        <div class="relative w-20 h-20 rounded-xl overflow-hidden bg-surface-container shrink-0 shadow-sm ml-1">
                                            <c:choose>
                                                <c:when test="${not empty item.variant.product.image}">
                                                    <img class="w-full h-full object-cover" src="<c:out value='${item.variant.product.image}'/>" alt="<c:out value='${item.variant.product.name}'/>">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="w-full h-full flex items-center justify-center bg-surface-container-high text-on-surface-variant">
                                                        <span class="material-symbols-outlined text-[28px]">image</span>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="flex flex-col min-w-0 pl-1">
                                            <span class="font-headline-sm text-headline-sm text-on-surface truncate"><c:out value="${item.variant.product.name}"/></span>
                                            <span class="text-body-sm font-body-sm text-on-surface-variant">
                                                <c:out value="${item.variant.variantName}"/> <c:if test="${not empty item.variant.unit}">- <c:out value="${item.variant.unit}"/></c:if>
                                            </span>
                                            <div class="flex items-center gap-1.5 mt-1 text-primary text-[12px] font-medium">
                                                <span class="material-symbols-outlined text-[14px]">check_circle</span>
                                                <span>Còn hàng (Farm Fresh)</span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Cột Đơn giá -->
                                    <div class="sm:col-span-2 text-left sm:text-center">
                                        <span class="sm:hidden text-body-sm text-on-surface-variant mr-2">Đơn giá:</span>
                                        <span class="font-headline-sm text-headline-sm text-on-surface">
                                            <fmt:formatNumber value="${item.variant.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                        </span>
                                    </div>

                                    <!-- Cột Số lượng (Có nút + - và form cập nhật DB) -->
                                    <div class="sm:col-span-2 flex items-center justify-start sm:justify-center">
                                        <form method="post" action="<c:out value='${updateUrl}'/>" class="flex items-center gap-1.5" id="qty-form-${item.cartItemID}">
                                            <input type="hidden" name="cartItemId" value="${item.cartItemID}">
                                            <c:if test="${not empty sessionScope.cartCsrfToken}">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}">
                                            </c:if>
                                            <div class="flex items-center bg-surface-container-low rounded-xl p-1 shadow-sm border border-outline-variant/30">
                                                <button aria-label="Giảm số lượng" type="button"
                                                        class="w-8 h-8 rounded-lg bg-surface-container-lowest text-on-surface flex items-center justify-center hover:bg-surface-container hover:text-primary transition-all active:scale-95 shadow-sm"
                                                        onclick="decrementQty('qty-${item.cartItemID}', ${item.variant.price}, 'sub-${item.cartItemID}')">
                                                    <span class="material-symbols-outlined text-[16px]">remove</span>
                                                </button>
                                                <input class="w-10 text-center bg-transparent font-bold text-on-surface text-body-md outline-none"
                                                       id="qty-${item.cartItemID}" name="quantity" type="number" min="1" max="999"
                                                       value="${item.quantity}" data-saved-quantity="${item.quantity}" onchange="recalcTotals()">
                                                <button aria-label="Tăng số lượng" type="button"
                                                        class="w-8 h-8 rounded-lg bg-surface-container-lowest text-on-surface flex items-center justify-center hover:bg-surface-container hover:text-primary transition-all active:scale-95 shadow-sm"
                                                        onclick="incrementQty('qty-${item.cartItemID}', ${item.variant.price}, 'sub-${item.cartItemID}')">
                                                    <span class="material-symbols-outlined text-[16px]">add</span>
                                                </button>
                                            </div>
                                            <button type="submit" title="Lưu số lượng" class="p-1.5 rounded-lg text-primary hover:bg-primary/10 transition-colors hidden sm:inline-flex" id="btn-save-${item.cartItemID}">
                                                <span class="material-symbols-outlined text-[18px]">save</span>
                                            </button>
                                        </form>
                                    </div>

                                    <!-- Cột Thành tiền & Nút Xóa -->
                                    <div class="sm:col-span-2 flex items-center justify-between sm:justify-end gap-space-md">
                                        <div class="flex flex-col text-right">
                                            <span class="sm:hidden text-body-sm text-on-surface-variant">Thành tiền</span>
                                            <span class="font-price-md text-price-md text-primary font-bold" data-price="${item.variant.price}" id="sub-${item.cartItemID}">
                                                <fmt:formatNumber value="${item.subtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                            </span>
                                        </div>
                                        <form method="post" action="<c:out value='${removeUrl}'/>" onsubmit="return confirm('Bạn có chắc muốn xóa sản phẩm này?');">
                                            <input type="hidden" name="cartItemId" value="${item.cartItemID}">
                                            <c:if test="${not empty sessionScope.cartCsrfToken}">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}">
                                            </c:if>
                                            <button type="submit" class="p-2 rounded-xl text-on-surface-variant hover:text-error hover:bg-error-container/40 transition-colors" title="Xóa sản phẩm">
                                                <span class="material-symbols-outlined text-[20px]">delete</span>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>

                        <!-- Bottom Controls -->
                        <div class="p-space-md sm:p-space-lg bg-surface-container-low/70 flex flex-col gap-space-md border-t border-outline-variant/20">
                            <!-- Hàng hành động & Mã giảm giá -->
                            <div class="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-space-md pb-space-sm border-b border-outline-variant/20">
                                <div class="flex flex-wrap items-center gap-space-sm">
                                    <a class="inline-flex items-center gap-space-xs text-primary font-bold text-body-md hover:underline mr-space-md" href="<c:out value='${productsUrl}'/>">
                                        <span class="material-symbols-outlined text-[20px]">arrow_back</span>
                                        <span>Tiếp tục mua hàng / Continue Shopping</span>
                                    </a>
                                </div>
                                <div class="flex flex-wrap items-center gap-2 w-full lg:w-auto">
                                    <!-- Nút Chọn Mã Khuyến Mãi -->
                                    <button type="button" onclick="openVoucherModal()" class="px-3.5 py-2 rounded-xl bg-surface-container-lowest border border-outline-variant/40 hover:border-primary text-body-sm font-semibold text-on-surface shadow-sm transition-colors flex items-center gap-1.5 active:scale-95">
                                        <span class="material-symbols-outlined text-[18px] text-primary">confirmation_number</span>
                                        <span>Chọn mã</span>
                                        <span class="material-symbols-outlined text-[16px] text-on-surface-variant">chevron_right</span>
                                    </button>

                                    <!-- Ô Nhập Mã Khuyến Mãi (Mặc định không chọn) -->
                                    <div class="flex-1 sm:w-56 bg-surface-container-lowest rounded-xl border border-outline-variant/40 px-3.5 py-2 flex items-center shadow-sm focus-within:border-primary transition-colors">
                                        <span class="material-symbols-outlined text-[18px] text-outline mr-2">sell</span>
                                        <input class="w-full bg-transparent border-0 outline-none text-on-surface font-body-md text-[13px] placeholder:text-on-surface-variant/60"
                                               id="coupon-input" placeholder="Nhập mã giảm giá..." type="text" value="">
                                    </div>
                                    <button type="button" onclick="applyCoupon()" class="px-4 py-2 rounded-xl bg-on-background text-on-secondary font-semibold text-body-sm hover:bg-black active:scale-95 transition-all shadow-sm">
                                        Áp dụng
                                    </button>
                                    <!-- Pill Voucher Đang Chọn (Mặc định ẩn) -->
                                    <div class="inline-flex items-center justify-between p-1.5 px-2.5 rounded-xl bg-tertiary-fixed text-on-tertiary-fixed font-body-sm shadow-sm" id="applied-pill" style="display: none;">
                                        <div class="flex items-center gap-1.5">
                                            <span class="material-symbols-outlined text-[16px] text-tertiary">check_circle</span>
                                            <span class="font-bold text-xs" id="applied-code-text"></span>
                                            <span class="text-xs" id="applied-discount-text"></span>
                                        </div>
                                        <button type="button" class="w-5 h-5 rounded-full hover:bg-tertiary-fixed-dim/60 flex items-center justify-center transition-colors ml-1.5" onclick="removeCoupon()" title="Bỏ mã">
                                            <span class="material-symbols-outlined text-[13px]">close</span>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Hàng Tổng kết thanh toán -->
                            <div class="flex flex-col md:flex-row items-center justify-between gap-space-md">
                                <div class="flex flex-wrap items-center gap-space-md text-body-sm">
                                    <div class="flex items-center gap-2">
                                        <span class="text-on-surface-variant">Tạm tính (<span id="items-count-text" class="font-medium"><c:out value="${cart.items.size()}"/> món</span>):</span>
                                        <span class="font-bold text-on-surface text-price-md" id="summary-subtotal">
                                            <fmt:formatNumber value="${cart.totalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                        </span>
                                    </div>
                                    <div class="flex items-center gap-1 text-tertiary" id="promo-row" style="display: none;">
                                        <span class="material-symbols-outlined text-[16px]">sell</span>
                                        <span>Giảm giá:</span>
                                        <span class="font-bold" id="promo-amount">-0 ₫</span>
                                    </div>
                                    <div class="hidden sm:flex items-center gap-1 text-on-surface-variant">
                                        <span>Vận chuyển:</span>
                                        <span class="font-semibold text-on-surface" id="summary-delivery">Miễn phí</span>
                                    </div>
                                </div>
                                <div class="flex items-center justify-between sm:justify-end gap-space-lg w-full md:w-auto">
                                    <div class="flex flex-col text-right">
                                        <span class="text-[11px] font-label-caps text-on-surface-variant uppercase">Tổng thanh toán / Total</span>
                                        <span class="text-price-hero font-price-hero text-primary" id="summary-total">
                                            <fmt:formatNumber value="${cart.totalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/>
                                        </span>
                                    </div>
                                    <a href="<c:out value='${checkoutUrl}'/>" onclick="submitCheckout(event)" class="py-3 px-space-lg rounded-xl bg-primary text-on-primary font-headline-sm text-headline-sm flex items-center justify-center gap-space-sm hover:bg-on-primary-fixed-variant transition-all duration-200 active:scale-[0.98] shadow-md hover:shadow-lg no-underline cursor-pointer" id="btn-checkout">
                                        <span id="btn-checkout-label">Mua hàng (<c:out value="${cart.items.size()}"/>)</span>
                                        <span class="material-symbols-outlined text-[20px]">arrow_forward</span>
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Form ngầm gửi các cartItemId được chọn sang /checkout -->
                        <form id="checkout-form" method="post" action="${pageContext.request.contextPath}/checkout" class="hidden">
                            <c:if test="${not empty sessionScope.cartCsrfToken}">
                                <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}">
                            </c:if>
                            <input type="hidden" name="couponCode" id="checkout-form-coupon" value="">
                            <div id="checkout-form-items"></div>
                        </form>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</section>
</div>
</main>

<!-- ==================== MODAL CHỌN MÃ KHUYẾN MÃI ==================== -->
<div id="voucher-modal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 hidden">
    <div class="bg-surface-container-lowest w-full max-w-lg rounded-2xl shadow-2xl border border-outline-variant/30 overflow-hidden transform transition-all">
        <!-- Modal Header -->
        <div class="px-6 py-4 border-b border-outline-variant/20 flex items-center justify-between bg-surface-container-low/50">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-primary text-[24px]">confirmation_number</span>
                <h3 class="font-headline-sm text-headline-sm text-on-surface">Chọn Voucher Khuyến Mãi</h3>
            </div>
            <button type="button" onclick="closeVoucherModal()" class="w-8 h-8 rounded-full hover:bg-surface-container flex items-center justify-center text-on-surface-variant transition-colors">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
        </div>

        <!-- Modal Body (Danh sách voucher) -->
        <div class="p-6 max-h-[60vh] overflow-y-auto flex flex-col gap-3">
            <!-- Voucher 1: FRESH25 -->
            <div class="p-4 rounded-xl border border-outline-variant/30 bg-surface-container-lowest hover:border-primary/50 transition-colors flex items-center justify-between gap-4">
                <div class="flex flex-col gap-1">
                    <div class="flex items-center gap-2">
                        <span class="font-bold text-sm bg-primary/10 text-primary px-2.5 py-0.5 rounded-md tracking-wider">FRESH25</span>
                        <span class="font-semibold text-sm text-on-surface">Giảm 25.000 ₫</span>
                    </div>
                    <p class="text-xs text-on-surface-variant">Áp dụng cho đơn hàng từ 50.000 ₫</p>
                    <span class="text-[11px] text-outline">HSD: 31/12/2026</span>
                </div>
                <button type="button" onclick="chooseVoucher('FRESH25')" class="px-3.5 py-1.5 rounded-lg bg-primary text-on-primary font-semibold text-xs hover:bg-on-primary-fixed-variant transition-colors shadow-sm shrink-0">
                    Chọn
                </button>
            </div>

            <!-- Voucher 2: OFSPNEW -->
            <div class="p-4 rounded-xl border border-outline-variant/30 bg-surface-container-lowest hover:border-primary/50 transition-colors flex items-center justify-between gap-4">
                <div class="flex flex-col gap-1">
                    <div class="flex items-center gap-2">
                        <span class="font-bold text-sm bg-tertiary/10 text-tertiary px-2.5 py-0.5 rounded-md tracking-wider">OFSPNEW</span>
                        <span class="font-semibold text-sm text-on-surface">Giảm 10% (Tối đa 50k)</span>
                    </div>
                    <p class="text-xs text-on-surface-variant">Dành cho đơn hàng từ 200.000 ₫</p>
                    <span class="text-[11px] text-outline">HSD: 31/12/2026</span>
                </div>
                <button type="button" onclick="chooseVoucher('OFSPNEW')" class="px-3.5 py-1.5 rounded-lg bg-primary text-on-primary font-semibold text-xs hover:bg-on-primary-fixed-variant transition-colors shadow-sm shrink-0">
                    Chọn
                </button>
            </div>

            <!-- Voucher 3: FREESHIP -->
            <div class="p-4 rounded-xl border border-outline-variant/30 bg-surface-container-lowest hover:border-primary/50 transition-colors flex items-center justify-between gap-4">
                <div class="flex flex-col gap-1">
                    <div class="flex items-center gap-2">
                        <span class="font-bold text-sm bg-primary/10 text-primary px-2.5 py-0.5 rounded-md tracking-wider">FREESHIP</span>
                        <span class="font-semibold text-sm text-on-surface">Giảm 25.000 ₫</span>
                    </div>
                    <p class="text-xs text-on-surface-variant">Giảm cố định 25.000 ₫ cho đơn từ 150.000 ₫</p>
                    <span class="text-[11px] text-outline">HSD: 31/12/2026</span>
                </div>
                <button type="button" onclick="chooseVoucher('FREESHIP')" class="px-3.5 py-1.5 rounded-lg bg-primary text-on-primary font-semibold text-xs hover:bg-on-primary-fixed-variant transition-colors shadow-sm shrink-0">
                    Chọn
                </button>
            </div>
        </div>

        <!-- Modal Footer -->
        <div class="px-6 py-3 border-t border-outline-variant/20 bg-surface-container-low/30 text-right">
            <button type="button" onclick="closeVoucherModal()" class="px-4 py-1.5 rounded-xl border border-outline-variant/40 text-sm font-semibold text-on-surface hover:bg-surface-container transition-colors">
                Đóng
            </button>
        </div>
    </div>
</div>

<!-- ==================== FOOTER ==================== -->
<footer class="w-full bg-surface-container-low mt-space-xl pt-space-xl pb-space-lg text-on-surface-variant border-t border-outline-variant/20">
    <div class="max-w-[1360px] mx-auto px-margin-sm lg:px-margin">
        <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-space-lg pb-space-lg border-b border-outline-variant/20">
            <div class="flex flex-col gap-2">
                <div class="flex items-center gap-space-sm">
                    <span class="font-headline-sm text-headline-sm text-primary font-bold">🍎 FreshFruit</span>
                </div>
                <p class="font-body-sm text-body-sm text-on-surface-variant max-w-md">
                    Trái cây tươi hái tận vườn, giao hàng tận nơi. Nông trại sạch mang lại sức khỏe và an tâm cho mọi gia đình.
                </p>
            </div>
            <div class="flex flex-wrap items-center gap-space-lg font-body-sm">
                <a class="hover:text-primary transition-colors" href="<c:out value='${homeUrl}'/>">Trang Chủ</a>
                <a class="hover:text-primary transition-colors" href="<c:out value='${productsUrl}'/>">Cửa Hàng</a>
                <a class="hover:text-primary transition-colors" href="<c:out value='${productsUrl}'/>">Khuyến Mãi</a>
                <a class="hover:text-primary transition-colors" href="<c:out value='${homeUrl}'/>#about">Về Chúng Tôi</a>
                <a class="hover:text-primary transition-colors" href="<c:out value='${homeUrl}'/>#contact">Trợ Giúp &amp; Liên Hệ</a>
            </div>
            <div class="flex items-center gap-space-xs">
                <span class="material-symbols-outlined text-[16px] text-primary">call</span>
                <span class="font-body-sm font-semibold text-on-surface">1900 6868</span>
            </div>
        </div>
        <div class="pt-space-md flex flex-col md:flex-row items-center justify-between gap-space-sm font-body-sm text-body-sm text-on-surface-variant">
            <p>© 2026 FreshFruit Marketplace. Đã đăng ký bản quyền.</p>
            <div class="flex items-center gap-space-lg">
                <a class="hover:text-primary transition-colors" href="#">Chính sách bảo mật</a>
                <a class="hover:text-primary transition-colors" href="#">Điều khoản sử dụng</a>
            </div>
        </div>
    </div>
</footer>

<!-- ==================== JAVASCRIPT ==================== -->
<script>
    let couponApplied = false;
    const FREE_SHIPPING_GOAL = 200000;

    function formatVND(val) {
        return Math.round(val).toLocaleString('vi-VN') + ' ₫';
    }

    function incrementQty(qtyId, price, subId) {
        const input = document.getElementById(qtyId);
        let val = parseInt(input.value) || 1;
        val += 1;
        input.value = val;
        const sub = document.getElementById(subId);
        if (sub) {
            sub.innerText = formatVND(val * price);
        }
        recalcTotals();
    }

    function decrementQty(qtyId, price, subId) {
        const input = document.getElementById(qtyId);
        let val = parseInt(input.value) || 1;
        if (val > 1) {
            val -= 1;
            input.value = val;
            const sub = document.getElementById(subId);
            if (sub) {
                sub.innerText = formatVND(val * price);
            }
            recalcTotals();
        }
    }

    function toggleSelectAll(isChecked) {
        const checkboxes = document.querySelectorAll('.item-checkbox');
        checkboxes.forEach(cb => {
            cb.checked = isChecked;
        });
        recalcTotals();
    }

    function handleItemCheckChange() {
        const checkboxes = Array.from(document.querySelectorAll('.item-checkbox'));
        const selectAll = document.getElementById('select-all-checkbox');
        if (selectAll) {
            const allChecked = checkboxes.length > 0 && checkboxes.every(cb => cb.checked);
            const someChecked = checkboxes.some(cb => cb.checked);
            selectAll.checked = allChecked;
            selectAll.indeterminate = (!allChecked && someChecked);
        }
        recalcTotals();
    }

    function removeCoupon() {
        couponApplied = false;
        const pill = document.getElementById('applied-pill');
        const row = document.getElementById('promo-row');
        const input = document.getElementById('coupon-input');
        if (pill) pill.style.display = 'none';
        if (row) row.style.display = 'none';
        if (input) input.value = '';
        recalcTotals();
    }

    function openVoucherModal() {
        const modal = document.getElementById('voucher-modal');
        if (modal) modal.classList.remove('hidden');
    }

    function closeVoucherModal() {
        const modal = document.getElementById('voucher-modal');
        if (modal) modal.classList.add('hidden');
    }

    function chooseVoucher(code) {
        const input = document.getElementById('coupon-input');
        if (input) input.value = code;
        closeVoucherModal();
    }

    function applyCoupon() {
        const input = document.getElementById('coupon-input');
        const pill = document.getElementById('applied-pill');
        const row = document.getElementById('promo-row');
        if (input && input.value.trim() !== '') {
            couponApplied = true;
            const code = input.value.trim().toUpperCase();
            input.value = code;
            const codeOutput = document.getElementById('applied-code-text');
            const discountOutput = document.getElementById('applied-discount-text');
            if (codeOutput) codeOutput.innerText = code;
            if (discountOutput) discountOutput.innerText = '(Kiểm tra ở bước thanh toán)';
            if (pill) pill.style.display = 'inline-flex';
            if (row) row.style.display = 'none';
            recalcTotals();
        } else {
            alert('Vui lòng chọn hoặc nhập mã giảm giá!');
        }
    }

    function recalcTotals() {
        const allRows = document.querySelectorAll('[id^="cart-item-"]');
        const totalRowsCount = allRows.length;
        let checkedCount = 0;
        let totalItemsQty = 0;
        let selectedSubtotal = 0;

        allRows.forEach(row => {
            const checkbox = row.querySelector('.item-checkbox');
            const qtyInput = row.querySelector('input[name="quantity"]');
            const subEl = row.querySelector('[id^="sub-"]');
            const unitPrice = parseFloat(subEl ? subEl.getAttribute('data-price') : 0) || 0;
            const qty = parseInt(qtyInput ? qtyInput.value : 1) || 1;

            if (checkbox && checkbox.checked) {
                checkedCount++;
                totalItemsQty += qty;
                selectedSubtotal += (unitPrice * qty);
            }
        });

        // Cập nhật số lượng hiển thị
        const selectedSummaryCount = document.getElementById('selected-summary-count');
        if (selectedSummaryCount) {
            selectedSummaryCount.innerHTML = 'Đã chọn: <strong class="text-on-surface font-bold">' + checkedCount + '/' + totalRowsCount + ' món</strong>';
        }

        const itemsCountText = document.getElementById('items-count-text');
        if (itemsCountText) {
            itemsCountText.innerText = checkedCount + ' món';
        }

        const btnCheckoutLabel = document.getElementById('btn-checkout-label');
        const btnCheckout = document.getElementById('btn-checkout');
        if (btnCheckoutLabel) {
            btnCheckoutLabel.innerText = checkedCount > 0 ? ('Mua hàng (' + checkedCount + ')') : 'Chọn món để mua';
        }
        if (btnCheckout) {
            if (checkedCount === 0) {
                btnCheckout.classList.add('opacity-50', 'pointer-events-none');
            } else {
                btnCheckout.classList.remove('opacity-50', 'pointer-events-none');
            }
        }

        // Tính giảm giá & thành tiền
        const promoRow = document.getElementById('promo-row');
        const discount = 0;
        if (promoRow) {
            promoRow.style.display = (couponApplied && discount > 0) ? 'flex' : 'none';
        }

        const selectedRows = Array.from(document.querySelectorAll('[id^="cart-item-"]'))
                .filter(row => row.querySelector('.item-checkbox:checked'));
        const shopGroups = new Map();
        selectedRows.forEach(row => {
            const shopId = row.getAttribute('data-shop-id') || 'unknown';
            const qtyInput = row.querySelector('input[name="quantity"]');
            const priceEl = row.querySelector('[data-price]');
            const qty = parseInt(qtyInput ? qtyInput.value : '1') || 1;
            const price = parseFloat(priceEl ? priceEl.getAttribute('data-price') : '0') || 0;
            shopGroups.set(shopId, (shopGroups.get(shopId) || 0) + price * qty);
        });
        let delivery = 0;
        shopGroups.forEach(shopSubtotal => {
            if (shopSubtotal < FREE_SHIPPING_GOAL) delivery += 25000;
        });
        const grandTotal = Math.max(0, selectedSubtotal - discount + delivery);

        const subEl = document.getElementById('summary-subtotal');
        if (subEl) subEl.innerText = formatVND(selectedSubtotal);

        const delEl = document.getElementById('summary-delivery');
        if (delEl) {
            delEl.innerText = (selectedSubtotal >= FREE_SHIPPING_GOAL && selectedSubtotal > 0) ? 'Miễn phí' : formatVND(delivery);
        }

        const totEl = document.getElementById('summary-total');
        if (totEl) totEl.innerText = formatVND(grandTotal);

        const navTotal = document.getElementById('nav-cart-total');
        if (navTotal) navTotal.innerText = formatVND(selectedSubtotal);

        const navBadge = document.getElementById('nav-cart-badge');
        if (navBadge) navBadge.innerText = totalItemsQty;

        // Progress bar thanh trạng thái
        const pBar = document.getElementById('delivery-progress-bar');
        const pStatus = document.getElementById('delivery-progress-status');
        const pCurrent = document.getElementById('progress-bar-current');
        const pTitle = document.getElementById('delivery-progress-title');
        const pDesc = document.getElementById('delivery-progress-desc');

        const pct = Math.min(100, (selectedSubtotal / FREE_SHIPPING_GOAL) * 100);
        if (pBar) pBar.style.width = pct + '%';
        if (pCurrent) pCurrent.innerText = 'Hiện tại: ' + formatVND(selectedSubtotal);
        if (pStatus) pStatus.innerText = formatVND(selectedSubtotal) + ' / ' + formatVND(FREE_SHIPPING_GOAL);

        if (selectedSubtotal >= FREE_SHIPPING_GOAL) {
            if (pTitle) pTitle.innerText = '🎉 Chúc mừng bạn!';
            if (pDesc) pDesc.innerHTML = 'Đơn hàng của bạn đã đạt điều kiện <span class="font-bold text-primary">Miễn phí giao hàng trong ngày!</span>';
        } else {
            const rem = FREE_SHIPPING_GOAL - selectedSubtotal;
            if (pTitle) pTitle.innerText = 'Gần đạt ưu đãi rồi!';
            if (pDesc) pDesc.innerHTML = 'Mua thêm <span class="font-bold text-tertiary">' + formatVND(rem) + '</span> để được <span class="font-bold text-primary">Miễn phí giao hàng trong ngày!</span>';
        }
    }

    function submitCheckout(e) {
        if (e) e.preventDefault();
        const checkedBoxes = Array.from(document.querySelectorAll('.item-checkbox:checked'));
        if (checkedBoxes.length === 0) {
            alert('Vui lòng chọn ít nhất một sản phẩm để mua hàng!');
            return;
        }
        const changedQuantities = checkedBoxes.filter(cb => {
            const row = cb.closest('[id^="cart-item-"]');
            const qty = row ? row.querySelector('input[name="quantity"]') : null;
            return qty && qty.value !== qty.getAttribute('data-saved-quantity');
        });
        if (changedQuantities.length > 0) {
            alert('Bạn đã thay đổi số lượng. Vui lòng bấm biểu tượng lưu tại từng sản phẩm trước khi mua hàng!');
            return;
        }
        const container = document.getElementById('checkout-form-items');
        if (!container) return;
        container.innerHTML = '';
        checkedBoxes.forEach(cb => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'cartItemIds';
            input.value = cb.getAttribute('data-target');
            container.appendChild(input);
        });

        const couponInput = document.getElementById('coupon-input');
        const formCoupon = document.getElementById('checkout-form-coupon');
        if (couponApplied && couponInput && formCoupon) {
            formCoupon.value = couponInput.value.trim();
        }

        document.getElementById('checkout-form').submit();
    }

    document.addEventListener('DOMContentLoaded', () => {
        handleItemCheckChange();
    });
</script>

</body>
</html>
