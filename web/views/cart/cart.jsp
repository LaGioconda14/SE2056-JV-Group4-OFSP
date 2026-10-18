<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN"/>
<c:url var="homeUrl" value="/home.jsp"/>
<c:url var="productsUrl" value="/products"/>
<c:url var="cartUrl" value="/cart"/>
<c:url var="updateUrl" value="/cart/update"/>
<c:url var="removeUrl" value="/cart/remove"/>
<c:url var="changeVariantUrl" value="/cart/change-variant"/>
<c:url var="checkoutUrl" value="/views/order/checkout.jsp"/>
<c:url var="vouchersUrl" value="/cart/vouchers"/>
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
            <!-- Nút Thông Báo (Bell Button) -->
            <div class="relative" id="header-noti-container">
                <button type="button" id="header-noti-btn" onclick="toggleHeaderNotification(event)"
                        class="relative flex items-center justify-center w-10 h-10 rounded-full border border-outline-variant/30 bg-surface-container-low hover:bg-surface-container text-on-surface-variant hover:text-primary transition-colors cursor-pointer"
                        title="Thông báo">
                    <span class="material-symbols-outlined text-[22px]">notifications</span>
                    <span id="header-noti-badge" class="absolute -top-1 -right-1 min-w-[18px] h-[18px] px-1 bg-error text-on-error rounded-full text-[10px] font-bold flex items-center justify-center border-2 border-white shadow-xs">
                        1
                    </span>
                </button>

                <!-- Dropdown Thông Báo -->
                <div id="header-noti-popover" class="hidden absolute right-0 mt-2 w-80 sm:w-96 bg-surface-container-lowest rounded-2xl shadow-2xl border border-outline-variant/30 p-4 z-50 transform origin-top-right transition-all">
                    <div class="flex items-center justify-between pb-3 border-b border-outline-variant/20 mb-3">
                        <div class="flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary text-[20px]">notifications_active</span>
                            <span class="font-bold text-on-surface text-sm">Thông báo</span>
                        </div>
                        <button type="button" onclick="clearAllNotifications(event)" class="text-xs text-primary hover:underline font-semibold cursor-pointer">Đánh dấu đã đọc</button>
                    </div>
                    <div class="max-h-72 overflow-y-auto space-y-2.5" id="header-noti-list">
                        <div class="flex items-start gap-3 p-2.5 rounded-xl bg-primary/10 border border-primary/20 text-xs text-on-surface shadow-2xs">
                            <span class="material-symbols-outlined text-primary text-[18px] shrink-0 mt-0.5">shopping_bag</span>
                            <div class="flex-1">
                                <p class="font-bold text-on-surface">Giỏ hàng của bạn</p>
                                <p class="text-on-surface-variant text-[11px] mt-0.5">Bạn đang có <strong class="text-primary"><c:out value="${cart ne null ? cart.totalQuantity : 0}"/></strong> món trong giỏ hàng.</p>
                            </div>
                        </div>
                        <div class="flex items-start gap-3 p-2.5 rounded-xl bg-tertiary-fixed/60 border border-tertiary-fixed text-xs text-on-surface shadow-2xs">
                            <span class="material-symbols-outlined text-tertiary text-[18px] shrink-0 mt-0.5">confirmation_number</span>
                            <div class="flex-1">
                                <p class="font-bold text-on-surface">Mã giảm giá</p>
                                <p class="text-on-surface-variant text-[11px] mt-0.5">Mã sàn SAN10K và mã Shop đã sẵn sàng trong giỏ hàng.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Cart Button Pill (BÊN TRÁI PROFILE) -->
            <a class="flex items-center gap-2.5 py-1.5 px-3.5 rounded-full border border-primary/30 bg-primary/5 hover:bg-primary/10 transition-colors" data-path="cart" href="<c:out value='${cartUrl}'/>">
                <div class="relative flex items-center justify-center">
                    <span class="material-symbols-outlined text-primary text-[24px]">shopping_cart</span>
                    <span class="absolute -top-1.5 -right-2 min-w-[16px] h-4 px-1 bg-error text-on-error rounded-full font-label-caps text-[10px] flex items-center justify-center" id="nav-cart-badge">
                        <c:out value="${cart ne null ? (cart.totalQuantity gt 99 ? '99+' : cart.totalQuantity) : 0}"/>
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
                <span hidden="" class="flex items-center gap-1.5 px-3 py-1 bg-tertiary-fixed text-on-tertiary-fixed rounded-full font-label-caps text-label-caps font-semibold">
                    <span class="material-symbols-outlined text-[14px] text-tertiary">bolt</span>
                    <span hidden="">Flash Sale Hôm Nay: <strong>Giảm 30% Cam &amp; Bưởi Da Xanh</strong></span>
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
    <c:if test="${not empty stockNotice}">
        <div class="mb-4 p-4 rounded-xl bg-amber-50 text-amber-800 border border-amber-200 font-semibold flex items-center gap-2 shadow-sm" role="status">
            <span class="material-symbols-outlined">inventory</span> <c:out value="${stockNotice}"/>
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
            <div class="space-y-4 pb-4">
                <div class="hidden lg:grid grid-cols-[minmax(0,1fr)_140px_180px_150px_72px] items-center rounded-2xl border border-outline-variant/20 bg-surface-container-lowest px-5 py-4 text-xs font-bold uppercase tracking-wider text-on-surface-variant shadow-sm">
                    <label class="flex items-center gap-3 normal-case text-sm text-on-surface cursor-pointer">
                        <input checked id="select-all-checkbox" onchange="toggleSelectAll(this.checked)" type="checkbox" class="select-all-toggle w-4 h-4 accent-primary">
                        Sản phẩm (<span id="select-all-count"><c:out value="${cart.items.size()}"/></span>)
                    </label>
                    <span class="text-center">Đơn giá</span><span class="text-center">Số lượng</span><span class="text-center">Số tiền</span><span class="text-center">Thao tác</span>
                </div>

                <c:forEach var="shopEntry" items="${cart.itemsByShop}">
                    <c:set var="shopItems" value="${shopEntry.value}"/>
                    <c:set var="shop" value="${shopItems[0].variant.product}"/>
                    <section class="overflow-hidden rounded-2xl border border-outline-variant/25 bg-surface-container-lowest shadow-sm" data-shop-group="${shopEntry.key}">
                        <div class="flex flex-wrap items-center justify-between gap-3 border-b border-outline-variant/20 px-5 py-4">
                            <label class="flex items-center gap-3 cursor-pointer">
                                <input checked type="checkbox" class="shop-checkbox w-4 h-4 accent-primary" data-shop-id="${shopEntry.key}" onchange="toggleShop('${shopEntry.key}', this.checked)">
                                <span class="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary"><span class="material-symbols-outlined text-[19px]">storefront</span></span>
                                <strong class="text-sm sm:text-base text-on-surface"><c:out value="${not empty shop.shopName ? shop.shopName : 'FreshFruit Store'}"/></strong>
                                <span class="material-symbols-outlined text-[18px] text-tertiary">chat</span>
                            </label>
                            <a href="<c:out value='${productsUrl}'/>" class="text-xs font-semibold text-primary hover:underline">Xem Shop</a>
                        </div>

                        <c:forEach var="item" items="${shopItems}">
                            <c:set var="available" value="${item.availabilityStatus eq 'AVAILABLE'}"/>
                            <c:set var="variantUnavailable" value="${item.availabilityStatus eq 'VARIANT_UNAVAILABLE'}"/>
                            <div class="grid grid-cols-1 gap-4 border-b border-outline-variant/15 px-5 py-5 transition hover:bg-surface-container-low/30 lg:grid-cols-[minmax(0,1fr)_140px_180px_150px_72px] lg:items-center"
                                 data-item-id="${item.cartItemID}" data-shop-id="${shopEntry.key}" data-cart-status="<c:out value='${item.availabilityStatus}'/>" id="cart-item-${item.cartItemID}">
                                <div class="flex min-w-0 items-start gap-3">
                                    <input <c:if test="${available}">checked</c:if> <c:if test="${not available}">disabled</c:if> type="checkbox" data-target="${item.cartItemID}" onchange="handleItemCheckChange()" class="item-checkbox mt-8 h-4 w-4 shrink-0 accent-primary disabled:opacity-40">
                                    <div class="h-24 w-24 shrink-0 overflow-hidden rounded-xl border border-outline-variant/20 bg-surface-container">
                                        <c:choose><c:when test="${not empty item.variant.product.image}"><img class="h-full w-full object-cover" src="<c:out value='${item.variant.product.image}'/>" alt="<c:out value='${item.variant.product.name}'/>"></c:when><c:otherwise><div class="flex h-full w-full items-center justify-center text-outline"><span class="material-symbols-outlined">image</span></div></c:otherwise></c:choose>
                                    </div>
                                    <div class="min-w-0 py-1">
                                        <a href="${pageContext.request.contextPath}/detail?id=${item.variant.product.productId}" class="line-clamp-2 text-sm font-bold text-on-surface hover:text-primary"><c:out value="${item.variant.product.name}"/></a>
                                        <button type="button" class="mt-2 flex max-w-full items-center gap-1 rounded-md bg-surface-container-low px-2 py-1 text-left text-xs text-on-surface-variant hover:text-primary" onclick="openVariantDialog('${item.cartItemID}')">
                                            <span class="truncate">Phân loại: <c:out value="${item.variant.variantName}"/><c:if test="${not empty item.variant.unit}">, <c:out value="${item.variant.unit}"/></c:if></span><span class="material-symbols-outlined text-[15px]">arrow_drop_down</span>
                                        </button>
                                        <c:choose><c:when test="${available}"><span class="mt-2 block text-[11px] font-semibold text-primary">Còn hàng · Kho <c:out value="${item.variant.stockQuantity}"/></span></c:when><c:otherwise><span class="mt-2 block text-[11px] font-semibold text-error">Sản phẩm hiện không khả dụng</span></c:otherwise></c:choose>
                                    </div>
                                </div>

                                <div class="flex items-center justify-between lg:justify-center"><span class="text-xs text-on-surface-variant lg:hidden">Đơn giá</span><strong class="text-sm"><fmt:formatNumber value="${item.variant.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                <div class="flex items-center justify-between lg:justify-center">
                                    <span class="text-xs text-on-surface-variant lg:hidden">Số lượng</span>
                                    <c:choose><c:when test="${available}"><form method="post" action="<c:out value='${updateUrl}'/>" class="flex items-center gap-2" id="qty-form-${item.cartItemID}"><input type="hidden" name="cartItemId" value="${item.cartItemID}"><c:if test="${not empty sessionScope.cartCsrfToken}"><input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}"></c:if><div class="flex overflow-hidden rounded-lg border border-outline-variant/40"><button type="button" class="h-8 w-8 hover:bg-surface-container" onclick="decrementQty('qty-${item.cartItemID}', ${item.variant.price}, 'sub-${item.cartItemID}')">−</button><input id="qty-${item.cartItemID}" name="quantity" type="number" min="1" max="${item.variant.stockQuantity}" value="${item.quantity}" data-saved-quantity="${item.quantity}" onchange="recalcTotals()" class="h-8 w-11 border-x border-outline-variant/30 text-center text-sm font-bold outline-none"><button type="button" class="h-8 w-8 hover:bg-surface-container" onclick="incrementQty('qty-${item.cartItemID}', ${item.variant.price}, 'sub-${item.cartItemID}')">+</button></div><button type="submit" class="text-primary" title="Lưu số lượng"><span class="material-symbols-outlined text-[18px]">save</span></button></form></c:when><c:otherwise><button type="button" onclick="openVariantDialog('${item.cartItemID}')" class="rounded-lg bg-primary px-3 py-2 text-xs font-bold text-white">Đổi phân loại</button></c:otherwise></c:choose>
                                </div>
                                <div class="flex items-center justify-between lg:justify-center"><span class="text-xs text-on-surface-variant lg:hidden">Số tiền</span><strong data-price="${item.variant.price}" id="sub-${item.cartItemID}" class="text-sm text-tertiary"><fmt:formatNumber value="${item.subtotal}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong></div>
                                <form method="post" action="<c:out value='${removeUrl}'/>" onsubmit="return confirm('Bạn có chắc muốn xóa sản phẩm này?');" class="flex justify-end lg:justify-center"><input type="hidden" name="cartItemId" value="${item.cartItemID}"><c:if test="${not empty sessionScope.cartCsrfToken}"><input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}"></c:if><button type="submit" class="flex items-center gap-1 text-xs text-error hover:underline"><span class="material-symbols-outlined text-[17px]">delete</span>Xóa</button></form>
                            </div>

                            <c:if test="${item.availabilityStatus ne 'NOT_FOUND'}">
                                <dialog id="variant-dialog-${item.cartItemID}" class="w-[min(520px,calc(100%-24px))] rounded-2xl border border-outline-variant/40 p-0 shadow-2xl backdrop:bg-black/40"><form method="post" action="<c:out value='${changeVariantUrl}'/>" class="p-5"><input type="hidden" name="cartItemId" value="${item.cartItemID}"><c:if test="${not empty sessionScope.cartCsrfToken}"><input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}"></c:if><div class="mb-4 flex items-start justify-between"><div><h3 class="text-lg font-bold">Chọn phân loại hàng</h3><p class="text-sm text-on-surface-variant"><c:out value="${item.variant.product.name}"/></p></div><button type="button" onclick="closeVariantDialog('${item.cartItemID}')"><span class="material-symbols-outlined">close</span></button></div><div class="flex max-h-[55vh] flex-col gap-2 overflow-y-auto"><label class="flex items-center gap-3 rounded-xl border-2 ${available ? 'border-primary bg-primary/5' : 'opacity-50'} p-3"><input type="radio" name="variantId" value="${item.variant.variantId}" <c:if test="${available}">checked</c:if> <c:if test="${not available}">disabled</c:if> required><span class="flex-1"><strong class="block"><c:out value="${item.variant.variantName}"/></strong><small><fmt:formatNumber value="${item.variant.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/> · Kho <c:out value="${item.variant.stockQuantity}"/></small></span><span class="text-xs font-bold text-primary">Đang chọn</span></label><c:forEach var="alternative" items="${item.alternativeVariants}"><c:set var="alternativeAvailable" value="${alternative.active and alternative.stockQuantity > 0}"/><label class="flex items-center gap-3 rounded-xl border border-outline-variant/40 p-3 ${alternativeAvailable ? 'cursor-pointer hover:border-primary' : 'opacity-50'}"><input type="radio" name="variantId" value="${alternative.variantId}" <c:if test="${not alternativeAvailable}">disabled</c:if> required><span class="flex-1"><strong class="block"><c:out value="${alternative.variantName}"/></strong><small><fmt:formatNumber value="${alternative.price}" type="currency" currencyCode="VND" maxFractionDigits="0"/> · Kho <c:out value="${alternative.stockQuantity}"/></small></span></label></c:forEach></div><div class="mt-5 flex justify-end gap-2"><button type="button" class="rounded-xl border px-4 py-2" onclick="closeVariantDialog('${item.cartItemID}')">Trở lại</button><button type="submit" class="rounded-xl bg-primary px-4 py-2 font-bold text-white">Xác nhận</button></div></form></dialog>
                            </c:if>
                        </c:forEach>

                        <div class="flex flex-wrap items-center justify-between gap-3 bg-surface-container-low/60 px-5 py-3 text-xs" id="shop-voucher-row-${shopEntry.key}">
                            <div class="flex items-center gap-2 text-tertiary">
                                <span class="material-symbols-outlined text-[18px]">confirmation_number</span>
                                <span>Voucher của Shop:</span>
                                <span id="shop-voucher-badge-${shopEntry.key}"></span>
                            </div>
                            <div class="flex items-center gap-2">
                                <button type="button" onclick="openVoucherModal('SHOP', '${shopEntry.key}', '<c:out value="${not empty shop.shopName ? shop.shopName : 'Shop'}"/>')" class="font-semibold text-primary hover:underline">
                                    Xem thêm voucher
                                </button>
                                <button type="button" id="btn-remove-shop-voucher-${shopEntry.key}" style="display:none;" onclick="removeShopVoucher('${shopEntry.key}')" class="text-error hover:underline ml-1">
                                    Bỏ chọn
                                </button>
                            </div>
                        </div>
                    </section>
                </c:forEach>

                <div class="sticky bottom-0 z-30 overflow-hidden rounded-2xl border border-outline-variant/30 bg-surface-container-lowest/95 shadow-[0_-10px_35px_rgba(15,23,42,0.14)] backdrop-blur-xl">
                    <div class="flex flex-wrap items-center justify-end gap-3 border-b border-outline-variant/20 px-5 py-3">
                        <span class="material-symbols-outlined text-[19px] text-tertiary">confirmation_number</span><strong class="text-sm">FreshFruit Voucher (Sàn)</strong>
                        <button type="button" onclick="openVoucherModal('PLATFORM')" class="text-xs font-semibold text-primary hover:underline">Chọn hoặc nhập mã</button>
                        <div class="flex min-w-[210px] items-center rounded-lg border border-outline-variant/40 px-3 py-2"><input id="coupon-input" type="text" placeholder="Nhập mã giảm giá" class="w-full bg-transparent text-xs outline-none"><button type="button" onclick="applyCoupon()" class="font-bold text-primary">Áp dụng</button></div>
                        <div id="applied-pill" style="display:none" class="items-center gap-2 rounded-lg bg-tertiary-fixed px-3 py-2 text-xs"><strong id="applied-code-text"></strong><span id="applied-discount-text"></span><button type="button" onclick="removeCoupon()"><span class="material-symbols-outlined text-[14px]">close</span></button></div>
                    </div>
                    <div class="flex flex-col gap-4 px-5 py-4 lg:flex-row lg:items-center lg:justify-between">
                        <div class="flex flex-wrap items-center gap-5 text-sm"><label class="flex cursor-pointer items-center gap-2"><input checked type="checkbox" class="select-all-toggle h-4 w-4 accent-primary" onchange="toggleSelectAll(this.checked)">Chọn tất cả</label><a href="<c:out value='${productsUrl}'/>" class="text-primary hover:underline">Tiếp tục mua hàng</a><span id="selected-summary-count">Đã chọn: <strong><c:out value="${cart.items.size()}"/>/<c:out value="${cart.items.size()}"/> món</strong></span></div>
                        <div class="flex items-center justify-between gap-5 lg:justify-end"><div class="text-right"><div class="text-xs text-on-surface-variant">Tổng cộng (<span id="items-count-text"><c:out value="${cart.items.size()}"/> món</span>)</div><strong id="summary-total" class="text-2xl text-tertiary"><fmt:formatNumber value="${cart.totalAmount}" type="currency" currencyCode="VND" maxFractionDigits="0"/></strong><span id="summary-subtotal" class="hidden"></span><span id="summary-delivery" class="hidden"></span><span id="promo-row" style="display:none"><span id="promo-amount"></span></span></div><a href="<c:out value='${checkoutUrl}'/>" onclick="submitCheckout(event)" id="btn-checkout" class="inline-flex min-w-[180px] items-center justify-center gap-2 rounded-xl bg-tertiary px-6 py-3 font-bold text-white shadow-lg transition hover:brightness-95"><span id="btn-checkout-label">Mua hàng (<c:out value="${cart.items.size()}"/>)</span><span class="material-symbols-outlined text-[18px]">arrow_forward</span></a></div>
                    </div>
                </div>

                <form id="checkout-form" method="post" action="${pageContext.request.contextPath}/checkout" class="hidden"><c:if test="${not empty sessionScope.cartCsrfToken}"><input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}"></c:if><input type="hidden" name="couponCode" id="checkout-form-coupon" value=""><div id="checkout-form-items"></div></form>
            </div>
        </c:otherwise>
    </c:choose>
</section>
</div>
</main>

<!-- ==================== MODAL CHỌN MÃ KHUYẾN MÃI ==================== -->
<dialog id="voucher-modal" aria-labelledby="voucher-modal-title" data-vouchers-url="<c:out value='${vouchersUrl}'/>" class="p-0 rounded-2xl w-[min(520px,calc(100%-24px))] backdrop:bg-black/50 backdrop:backdrop-blur-sm">
    <div class="bg-surface-container-lowest w-full max-w-lg rounded-2xl shadow-2xl border border-outline-variant/30 overflow-hidden transform transition-all">
        <!-- Modal Header -->
        <div class="px-6 py-4 border-b border-outline-variant/20 flex items-center justify-between bg-surface-container-low/50">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-primary text-[24px]">confirmation_number</span>
                <h3 id="voucher-modal-title" class="font-headline-sm text-headline-sm text-on-surface">Chọn voucher</h3>
            </div>
            <button type="button" aria-label="Đóng danh sách voucher" onclick="closeVoucherModal()" class="w-8 h-8 rounded-full hover:bg-surface-container flex items-center justify-center text-on-surface-variant transition-colors cursor-pointer">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
        </div>

        <!-- Scope Tabs (Voucher Sàn & Voucher Shop) -->
        <div id="voucher-tabs-container" class="hidden border-b border-outline-variant/20 px-6 pt-2 bg-surface-container-low/30 gap-6">
            <button type="button" id="tab-voucher-platform" onclick="setVoucherFilter('PLATFORM')"
                    class="pb-2.5 text-sm font-bold border-b-2 border-primary text-primary transition-colors cursor-pointer">
                Voucher Sàn
            </button>
            <button type="button" id="tab-voucher-shop" onclick="setVoucherFilter('SHOP')"
                    class="pb-2.5 text-sm font-semibold border-b-2 border-transparent text-on-surface-variant hover:text-primary transition-colors cursor-pointer">
                Voucher Shop
            </button>
        </div>

        <!-- Modal Body (Danh sách voucher) -->
        <div class="p-6 max-h-[60vh] overflow-y-auto flex flex-col gap-3">
            <p id="voucher-status" class="text-sm text-on-surface-variant" role="status" aria-live="polite"></p>
            <div id="voucher-list" class="flex flex-col gap-3"></div>
            <p class="text-xs text-outline">Điều kiện được xét trên các sản phẩm đang chọn. Phí ship và số tiền giảm là tạm tính.</p>
        </div>

        <!-- Modal Footer -->
        <div class="px-6 py-3 border-t border-outline-variant/20 bg-surface-container-low/30 text-right">
            <button type="button" onclick="closeVoucherModal()" class="px-4 py-1.5 rounded-xl border border-outline-variant/40 text-sm font-semibold text-on-surface hover:bg-surface-container transition-colors">
                Đóng
            </button>
        </div>
    </div>
</dialog>

<!-- ==================== FOOTER ==================== -->
<footer class="w-full mt-space-xl border-t border-primary/10 bg-[#f2f7f2] text-on-surface-variant">
    <div class="max-w-[1360px] mx-auto px-margin-sm lg:px-margin">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-16 py-10">
            <div class="max-w-md">
                <div class="flex items-center gap-3 mb-4">
                    <span class="inline-flex items-center justify-center w-11 h-11 rounded-2xl bg-primary text-on-primary shrink-0">
                        <span class="material-symbols-outlined text-[25px]" aria-hidden="true">eco</span>
                    </span>
                    <div>
                        <p class="text-xl font-bold tracking-tight text-primary">FreshFruit</p>
                        <p class="text-[11px] font-semibold tracking-widest uppercase text-primary/70">Tươi ngon mỗi ngày</p>
                    </div>
                </div>
                <p class="text-sm leading-relaxed">Một chút tươi xanh cho bữa ăn, một chút ngọt lành cho ngày mới. Cảm ơn bạn đã chọn FreshFruit cho giỏ hàng của mình.</p>
            </div>
            <div class="flex flex-col sm:flex-row md:flex-col lg:flex-row items-start gap-5 lg:items-center md:justify-self-end">
                <div>
                    <p class="text-xs font-bold tracking-widest uppercase text-primary mb-2">Đồng hành cùng bạn</p>
                    <h2 class="text-lg font-semibold text-on-surface">Cần hỗ trợ đơn hàng?</h2>
                    <p class="text-sm leading-relaxed mt-1 max-w-xs">Liên hệ để được hỗ trợ về sản phẩm, giao nhận và đơn hàng của bạn.</p>
                </div>
                <a href="tel:19006868" aria-label="Gọi hỗ trợ đặt hàng: 1900 6868" class="inline-flex items-center gap-3 px-5 py-3 rounded-2xl bg-white border border-primary/15 text-primary shadow-sm hover:bg-primary hover:text-on-primary transition-colors focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-primary shrink-0">
                    <span class="material-symbols-outlined text-[22px]" aria-hidden="true">support_agent</span>
                    <span class="flex flex-col">
                        <span class="text-[11px] font-medium">Hotline hỗ trợ</span>
                        <span class="text-lg font-bold tracking-wide">1900 6868</span>
                    </span>
                </a>
            </div>
        </div>
        <div class="border-t border-primary/10 py-5 flex flex-col sm:flex-row sm:items-center justify-between gap-2 text-xs">
            <p>© 2026 FreshFruit Marketplace. Bảo lưu mọi quyền.</p>
            <span class="inline-flex items-center gap-1.5 text-primary">
                <span class="material-symbols-outlined text-[16px]" aria-hidden="true">favorite</span>
                Cảm ơn bạn đã mua sắm cùng FreshFruit
            </span>
        </div>
    </div>
</footer>

<!-- ==================== JAVASCRIPT ==================== -->
<script src="<c:url value='/assets/js/cart-vouchers.js?v=20261019'/>"></script>
<script>
    function formatVND(val) {
        return Math.round(val).toLocaleString('vi-VN') + ' ₫';
    }

    function incrementQty(qtyId, price, subId) {
        const input = document.getElementById(qtyId);
        if (!input) return;
        let val = parseInt(input.value) || 1;
        const max = parseInt(input.max) || Number.MAX_SAFE_INTEGER;
        val = Math.min(val + 1, max);
        input.value = val;
        const sub = document.getElementById(subId);
        if (sub) {
            sub.innerText = formatVND(val * price);
        }
        recalcTotals();
    }

    function decrementQty(qtyId, price, subId) {
        const input = document.getElementById(qtyId);
        if (!input) return;
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
        const checkboxes = document.querySelectorAll('.item-checkbox:not(:disabled)');
        checkboxes.forEach(cb => {
            cb.checked = isChecked;
        });
        document.querySelectorAll('.select-all-toggle').forEach(cb => {
            cb.checked = isChecked;
            cb.indeterminate = false;
        });
        document.querySelectorAll('.shop-checkbox').forEach(cb => {
            cb.checked = isChecked;
            cb.indeterminate = false;
        });
        recalcTotals();
    }

    function toggleShop(shopId, isChecked) {
        document.querySelectorAll('.item-checkbox:not(:disabled)').forEach(cb => {
            const row = cb.closest('[data-shop-id]');
            if (row && row.dataset.shopId === String(shopId)) cb.checked = isChecked;
        });
        handleItemCheckChange();
    }

    function handleItemCheckChange() {
        const checkboxes = Array.from(document.querySelectorAll('.item-checkbox:not(:disabled)'));
        const allChecked = checkboxes.length > 0 && checkboxes.every(cb => cb.checked);
        const someChecked = checkboxes.some(cb => cb.checked);
        document.querySelectorAll('.select-all-toggle').forEach(cb => {
            cb.checked = allChecked;
            cb.indeterminate = !allChecked && someChecked;
        });
        document.querySelectorAll('.shop-checkbox').forEach(shopCheckbox => {
            const shopItems = Array.from(document.querySelectorAll('.item-checkbox:not(:disabled)')).filter(cb => {
                const row = cb.closest('[data-shop-id]');
                return row && row.dataset.shopId === shopCheckbox.dataset.shopId;
            });
            shopCheckbox.checked = shopItems.length > 0 && shopItems.every(cb => cb.checked);
            shopCheckbox.indeterminate = shopItems.some(cb => cb.checked) && !shopCheckbox.checked;
        });
        recalcTotals();
    }
    function recalcTotals() {
        const allRows = document.querySelectorAll('[id^="cart-item-"]');
        const purchasableRows = Array.from(allRows).filter(row => row.dataset.cartStatus === 'AVAILABLE');
        const totalRowsCount = purchasableRows.length;
        let checkedCount = 0;
        let totalItemsQty = 0;
        let selectedSubtotal = 0;

        purchasableRows.forEach(row => {
            const checkbox = row.querySelector('.item-checkbox');
            const qtyInput = row.querySelector('input[name="quantity"]');
            const subEl = row.querySelector('[id^="sub-"]');
            const unitPrice = parseFloat(subEl ? subEl.getAttribute('data-price') : 0) || 0;
            const max = parseInt(qtyInput ? qtyInput.max : 1) || 1;
            const qty = Math.max(1, Math.min(max, parseInt(qtyInput ? qtyInput.value : 1) || 1));
            if (qtyInput) qtyInput.value = qty;
            if (subEl) subEl.innerText = formatVND(unitPrice * qty);

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
        const baseDelivery = 0;
        const savings = typeof window.cartVoucherSavings === 'function'
            ? window.cartVoucherSavings(selectedSubtotal, baseDelivery)
            : {product: 0, shipping: 0};
        const discount = savings.product;
        const delivery = baseDelivery - savings.shipping;
        const promoRow = document.getElementById('promo-row');
        if (promoRow) {
            promoRow.style.display = (discount > 0) ? 'flex' : 'none';
        }
        const grandTotal = Math.max(0, selectedSubtotal - discount + delivery);

        const subEl = document.getElementById('summary-subtotal');
        if (subEl) subEl.innerText = formatVND(selectedSubtotal);

        const delEl = document.getElementById('summary-delivery');
        if (delEl) {
            delEl.innerText = formatVND(delivery);
        }

        const totEl = document.getElementById('summary-total');
        if (totEl) totEl.innerText = formatVND(grandTotal);

        const navBadge = document.getElementById('nav-cart-badge');
        if (navBadge) navBadge.innerText = totalItemsQty > 99 ? '99+' : totalItemsQty;

    }

    function openVariantDialog(cartItemId) {
        const dialog = document.getElementById('variant-dialog-' + cartItemId);
        if (dialog && typeof dialog.showModal === 'function') dialog.showModal();
    }

    function closeVariantDialog(cartItemId) {
        const dialog = document.getElementById('variant-dialog-' + cartItemId);
        if (dialog) dialog.close();
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
        if (couponInput && formCoupon) {
            formCoupon.value = couponInput.value.trim();
        }

        document.getElementById('checkout-form').submit();
    }

    function toggleHeaderNotification(e) {
        if (e) e.stopPropagation();
        const popover = document.getElementById('header-noti-popover');
        if (popover) {
            popover.classList.toggle('hidden');
        }
    }

    function clearAllNotifications(e) {
        if (e) e.stopPropagation();
        const badge = document.getElementById('header-noti-badge');
        if (badge) badge.classList.add('hidden');
    }

    document.addEventListener('click', function(e) {
        const container = document.getElementById('header-noti-container');
        const popover = document.getElementById('header-noti-popover');
        if (container && popover && !container.contains(e.target)) {
            popover.classList.add('hidden');
        }
    });

    document.addEventListener('DOMContentLoaded', () => {
        handleItemCheckChange();
    });
</script>

</body>
</html>
