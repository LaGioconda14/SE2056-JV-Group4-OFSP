<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Sản Phẩm & Tồn Kho - FreshFruit Seller Center</title>
    <!-- Google Fonts & Material Symbols -->
    <link href="https://fonts.googleapis.com" rel="preconnect">
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
    
    <style>
        @layer base {
            html, body { margin: 0; padding: 0; }
            body { overscroll-behavior: none; }
        }
        ::-webkit-scrollbar { display: none; }
    </style>
    <script src="https://cdn.tailwindcss.com"></script>
    <script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              colors: {
                "background": "#faf8ff",
                "primary": "#00652c",
                "primary-container": "#15803d",
                "on-primary": "#ffffff",
                "secondary-container": "#d9e6dd",
                "on-secondary-fixed": "#131e19",
                "surface-container-lowest": "#ffffff",
                "surface-container-low": "#f2f3ff",
                "surface-container-high": "#e2e7ff",
                "surface-container": "#eaedff",
                "on-surface": "#131b2e",
                "on-surface-variant": "#3f493f",
                "tertiary": "#913e00",
                "tertiary-container": "#b85000",
                "tertiary-fixed": "#ffdbca",
                "inverse-surface": "#283044",
                "inverse-on-surface": "#eef0ff",
                "error": "#ba1a1a",
                "error-container": "#ffdad6",
                "on-error": "#ffffff"
              },
              fontFamily: {
                "body-md": ["Plus Jakarta Sans"],
                "headline-sm": ["Plus Jakarta Sans"],
                "body-sm": ["Plus Jakarta Sans"],
                "label-caps": ["Plus Jakarta Sans"],
                "headline-lg": ["Plus Jakarta Sans"]
              }
            }
          }
        }
    </script>
</head>
<body class="bg-background font-body-md text-on-surface antialiased pb-32">

    <!-- SIDEBAR NAVIGATION -->
    <aside class="fixed left-0 top-0 h-full w-72 bg-surface-container-lowest z-50 flex flex-col justify-between p-4 shadow-[0_1px_8px_rgba(0,0,0,0.04)]">
        <div class="flex flex-col gap-4">
            <div class="flex items-center gap-2 px-1 pt-1">
                <div class="w-10 h-10 rounded-xl bg-primary-container flex items-center justify-center text-on-primary shadow-sm">
                    <span class="material-symbols-outlined text-[24px]">eco</span>
                </div>
                <div class="flex flex-col">
                    <span class="font-bold text-lg text-on-surface leading-tight tracking-tight">FreshFruit</span>
                    <span class="text-[11px] font-bold text-primary tracking-wider uppercase">Seller Center</span>
                </div>
            </div>

            <!-- Shop Info Card -->
            <div class="bg-surface-container-low rounded-xl p-3 flex items-center justify-between">
                <div class="flex items-center gap-2 overflow-hidden">
                    <div class="w-9 h-9 rounded-lg bg-secondary-container flex items-center justify-center shrink-0 text-on-secondary-fixed overflow-hidden">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.avatarUrl}">
                                <img src="${sessionScope.shopLogo}" alt="Shop Logo" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <span class="material-symbols-outlined text-[20px]">agriculture</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="flex flex-col min-w-0">
                        <div class="flex items-center gap-1">
                            <span class="text-sm text-on-surface truncate font-semibold">${not empty sessionScope.shopName ? sessionScope.shopName : 'Cửa hàng của tôi'}</span>
                            <span class="material-symbols-outlined text-primary text-[16px] shrink-0">verified</span>
                        </div>
                        <span class="text-xs text-on-surface-variant truncate">Gian hàng chuẩn VietGAP</span>
                    </div>
                </div>
                <span class="material-symbols-outlined text-on-surface-variant text-[18px]">unfold_more</span>
            </div>

            <!-- Menu Links -->
            <nav class="flex flex-col gap-1 pt-1">
                <a class="flex items-center gap-3 px-4 py-2.5 rounded-xl text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-all" href="${pageContext.request.contextPath}/shop/dashboard">
                    <span class="material-symbols-outlined text-[20px]">dashboard</span>
                    <span>Tổng quan</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition-all bg-primary-container text-on-primary font-semibold shadow-[0_4px_16px_-2px_rgba(20,83,45,0.18)]" href="${pageContext.request.contextPath}/shop/products">
                    <span class="material-symbols-outlined text-[20px]">inventory_2</span>
                    <span>Sản phẩm & Kho hàng</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-2.5 rounded-xl text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-all" href="${pageContext.request.contextPath}/shop/orders">
                    <span class="material-symbols-outlined text-[20px]">local_shipping</span>
                    <span>Quản lý đơn hàng</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-2.5 rounded-xl text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-all" href="${pageContext.request.contextPath}/shop/profile">
                    <span class="material-symbols-outlined text-[20px]">storefront</span>
                    <span>Hồ sơ cửa hàng</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-2.5 rounded-xl text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-all" href="${pageContext.request.contextPath}/shop/finance">
                    <span class="material-symbols-outlined text-[20px]">account_balance_wallet</span>
                    <span>Doanh thu & Ví</span>
                </a>
                <a class="flex items-center gap-3 px-4 py-2.5 rounded-xl text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-all" href="${pageContext.request.contextPath}/shop/reviews">
                    <span class="material-symbols-outlined text-[20px]">reviews</span>
                    <span>Đánh giá từ khách</span>
                </a>
            </nav>
        </div>

        <!-- Support Box -->
        <div class="bg-surface-container-low rounded-xl p-4 flex flex-col gap-1">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg bg-primary-container flex items-center justify-center text-on-primary shrink-0">
                    <span class="material-symbols-outlined text-[18px]">support_agent</span>
                </div>
                <div class="flex flex-col">
                    <span class="text-sm text-on-surface font-semibold">Hỗ trợ nhà vườn 24/7</span>
                    <span class="text-xs text-on-surface-variant">Chuyên viên nông nghiệp</span>
                </div>
            </div>
            <a class="mt-1 text-center py-1.5 px-2 rounded-lg bg-surface-container-lowest text-primary font-semibold text-xs hover:bg-surface-container-high transition-colors" href="tel:19006868">Hotline: 1900 6868</a>
        </div>
    </aside>

    <!-- MAIN CONTENT AREA -->
    <div class="pl-72">
        <header class="fixed top-0 left-72 right-0 h-16 bg-surface-container-lowest/90 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)] z-40 px-6 flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="flex items-center gap-2 bg-surface-container-low px-3 py-1.5 rounded-lg">
                    <span class="material-symbols-outlined text-primary text-[18px]">potted_plant</span>
                    <span class="text-sm text-on-surface font-semibold">${sessionScope.shopName}</span>
                    <span class="text-xs text-on-surface-variant">• Gian hàng nông sản sạch</span>
                    <span class="material-symbols-outlined text-on-surface-variant text-[16px] ml-1">expand_more</span>
                </div>
                <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-secondary-container text-on-secondary-fixed">
                    <span class="w-2 h-2 rounded-full bg-primary-container animate-pulse"></span>
                    <span class="text-xs font-medium">Đang hoạt động</span>
                </div>
            </div>
            <div class="flex items-center gap-4">
                <div class="hidden md:flex items-center bg-surface-container-low px-3 py-1.5 rounded-xl text-on-surface-variant gap-2">
                    <span class="material-symbols-outlined text-[18px]">search</span>
                    <input type="text" placeholder="Tìm sản phẩm, mã đơn..." class="bg-transparent text-sm focus:outline-none w-48">
                    <kbd class="px-1.5 py-0.5 rounded bg-surface-container-lowest text-xs shadow-sm">⌘K</kbd>
                </div>
                <div class="flex items-center gap-2">
                    <button class="w-10 h-10 rounded-xl bg-surface-container-low hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant transition-colors" type="button">
                        <span class="material-symbols-outlined text-[20px]">chat</span>
                    </button>
                    <button class="relative w-10 h-10 rounded-xl bg-surface-container-low hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant transition-colors" type="button">
                        <span class="material-symbols-outlined text-[20px]">notifications</span>
                        <span class="absolute top-2 right-2 w-2 h-2 rounded-full bg-tertiary-container"></span>
                    </button>
                </div>
                
                <!-- USER AVATAR & INFO -->
                <div class="flex items-center gap-3 pl-2 border-l border-surface-container-high">
                    <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center shrink-0 text-on-primary overflow-hidden">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.avatarUrl}">
                                <img src="${sessionScope.user.avatarUrl}" alt="User Avatar" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <span class="material-symbols-outlined text-[18px]">person</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="hidden xl:flex flex-col text-left">
                        <span class="text-xs text-on-surface font-semibold leading-tight">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : sessionScope.shopName}</span>
                        <span class="text-[11px] text-on-surface-variant leading-tight">${sessionScope.user.email}</span>
                    </div>
                </div>
            </div>
        </header>

        <main class="relative pt-16 bg-background min-h-screen">
            <div class="flex flex-col w-full">
                <div class="px-6 lg:px-10 py-6 flex flex-col gap-6 max-w-[1440px] mx-auto w-full">
                    
                    <!-- Section 1: Breadcrumb & Page Header -->
                    <div class="flex flex-col gap-2">
                        <nav class="flex items-center gap-1 text-on-surface-variant text-xs">
                            <a class="hover:text-primary transition-colors flex items-center gap-1" href="#">
                                <span class="material-symbols-outlined text-[16px]">storefront</span>
                                <span>Kênh Người Bán</span>
                            </a>
                            <span class="material-symbols-outlined text-[14px]">chevron_right</span>
                            <span>Sản phẩm & Kho hàng</span>
                            <span class="material-symbols-outlined text-[14px]">chevron_right</span>
                            <span class="text-primary font-semibold">Danh sách sản phẩm</span>
                        </nav>
                        <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4 mt-1">
                            <div class="flex flex-col gap-1 max-w-2xl">
                                <div class="flex items-center gap-3">
                                    <h1 class="text-2xl font-bold text-on-surface tracking-tight">Quản Lý Sản Phẩm & Tồn Kho</h1>
                                    <span class="px-2.5 py-0.5 rounded-full bg-secondary-container text-on-secondary-fixed text-xs font-bold uppercase">Vụ Mùa 2025</span>
                                </div>
                                <p class="text-sm text-on-surface-variant">
                                    Kiểm soát danh mục trái cây đặc sản, phân loại biến thể, cập nhật giá khuyến mãi và theo dõi tồn kho tươi theo lô thu hoạch tại vườn.
                                </p>
                            </div>
                            <div class="flex items-center flex-wrap gap-3">
                                <button class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-surface-container-lowest text-on-surface font-semibold text-sm hover:bg-surface-container shadow-sm transition-all" type="button">
                                    <span class="material-symbols-outlined text-[20px] text-primary">file_download</span>
                                    <span>Xuất file tồn kho (.xlsx)</span>
                                </button>
                                <a href="${pageContext.request.contextPath}/shop/product/add" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-primary-container text-on-primary font-semibold text-sm shadow-[0_4px_16px_-2px_rgba(21,128,61,0.25)] hover:bg-primary transition-all">
                                    <span class="material-symbols-outlined text-[20px]">add_circle</span>
                                    <span>Thêm sản phẩm mới</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Section 2: Quick Stat KPI Summary -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                        <div class="bg-surface-container-lowest rounded-2xl p-5 shadow-sm flex flex-col justify-between relative overflow-hidden">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Tổng số sản phẩm đang bán</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="text-3xl font-extrabold text-on-surface">${requestScope.totalSKU}</span>
                                        <span class="text-xs text-on-surface-variant">mã SKU</span>
                                    </div>
                                </div>
                                <div class="w-11 h-11 rounded-xl bg-secondary-container flex items-center justify-center text-primary shrink-0">
                                    <span class="material-symbols-outlined text-[24px]">inventory_2</span>
                                </div>
                            </div>
                            <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs">
                                <span class="text-primary font-semibold flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">trending_up</span> +4 mã trong tháng</span>
                                <span class="text-on-surface-variant">Đạt chuẩn 100%</span>
                            </div>
                        </div>

                        <div class="bg-surface-container-lowest rounded-2xl p-5 shadow-sm flex flex-col justify-between relative overflow-hidden">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-tertiary uppercase tracking-wider">Cảnh báo sắp hết hàng</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="text-3xl font-extrabold text-tertiary">${requestScope.lowStockCount}</span>
                                        <span class="text-xs text-on-surface-variant">loại quả</span>
                                    </div>
                                </div>
                                <div class="w-11 h-11 rounded-xl bg-tertiary-fixed flex items-center justify-center text-tertiary shrink-0">
                                    <span class="material-symbols-outlined text-[24px]">warning_amber</span>
                                </div>
                            </div>
                            <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs">
                                <span class="text-tertiary font-medium">&lt; 10kg tại kho lạnh</span>
                                <a class="text-tertiary underline font-bold hover:opacity-80" href="#table-section">Bổ sung ngay</a>
                            </div>
                        </div>

                        <div class="bg-surface-container-lowest rounded-2xl p-5 shadow-sm flex flex-col justify-between relative overflow-hidden">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Tạm ẩn / Hết mùa vụ</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="text-3xl font-extrabold text-on-surface">05</span>
                                        <span class="text-xs text-on-surface-variant">mã lưu trữ</span>
                                    </div>
                                </div>
                                <div class="w-11 h-11 rounded-xl bg-surface-container-high flex items-center justify-center text-secondary shrink-0">
                                    <span class="material-symbols-outlined text-[24px]">visibility_off</span>
                                </div>
                            </div>
                            <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs">
                                <span class="text-on-surface-variant">Đang đợi mùa thu hoạch mới</span>
                                <span class="w-2 h-2 rounded-full bg-secondary"></span>
                            </div>
                        </div>

                        <div class="bg-surface-container-lowest rounded-2xl p-5 shadow-sm flex flex-col justify-between relative overflow-hidden">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Tổng giá trị kho tươi</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="text-2xl font-extrabold text-primary">${requestScope.totalValue}Đ</span>
                                    </div>
                                </div>
                                <div class="w-11 h-11 rounded-xl bg-secondary-container flex items-center justify-center text-primary shrink-0">
                                    <span class="material-symbols-outlined text-[24px]">savings</span>
                                </div>
                            </div>
                            <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs">
                                <span class="text-primary font-semibold flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">verified</span> Độ tươi đạt 96.8%</span>
                                <span class="text-on-surface-variant">Cập nhật trước</span>
                            </div>
                        </div>
                    </div>

                    <!-- Section 3: Toolbar & Advanced Filtering (Form GET để lọc dữ liệu) -->
                    <form method="GET" action="${pageContext.request.contextPath}/shop/products" class="bg-surface-container-lowest rounded-2xl p-4 shadow-sm flex flex-col gap-4">
                        <div class="flex items-center gap-2 overflow-x-auto pb-1">
                            <a href="${pageContext.request.contextPath}/shop/products" class="px-4 py-2 rounded-xl bg-primary-container text-on-primary font-semibold text-sm shrink-0 shadow-sm">Tất cả (56)</a>
                            <a href="${pageContext.request.contextPath}/shop/products?status=active" class="px-4 py-2 rounded-xl bg-surface-container-low text-on-surface-variant hover:bg-surface-container text-sm font-semibold shrink-0 transition-all">Đang bán (48)</a>
                            <a href="${pageContext.request.contextPath}/shop/products?stockLevel=low" class="px-4 py-2 rounded-xl bg-surface-container-low text-tertiary hover:bg-tertiary-fixed text-sm font-semibold shrink-0 transition-all flex items-center gap-1.5">
                                <span class="w-2 h-2 rounded-full bg-tertiary"></span> Sắp hết hàng (3)
                            </a>
                            <a href="${pageContext.request.contextPath}/shop/products?status=hidden" class="px-4 py-2 rounded-xl bg-surface-container-low text-on-surface-variant hover:bg-surface-container text-sm font-semibold shrink-0 transition-all">Tạm ẩn (5)</a>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-12 gap-3 items-center">
                            <div class="xl:col-span-5 relative flex items-center">
                                <span class="material-symbols-outlined absolute left-3 text-on-surface-variant text-[20px]">search</span>
                                <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên quả, mã SKU, xuất xứ..." class="w-full pl-10 pr-4 py-2.5 bg-surface-container-low rounded-xl text-sm focus:outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary/20">
                            </div>
                            <div class="xl:col-span-3 relative flex items-center">
                                <span class="material-symbols-outlined absolute left-3 text-on-surface-variant text-[20px]">category</span>
                                <select name="categoryId" class="w-full pl-10 pr-8 py-2.5 bg-surface-container-low rounded-xl text-sm appearance-none focus:outline-none cursor-pointer">
                                    <option value="">Danh mục: Tất cả</option>
                                    <option value="1" ${param.categoryId == '1' ? 'selected' : ''}>Trái Cây Theo Mùa</option>
                                    <option value="2" ${param.categoryId == '2' ? 'selected' : ''}>Dâu & Quả mọng</option>
                                </select>
                                <span class="material-symbols-outlined absolute right-3 text-on-surface-variant text-[18px] pointer-events-none">expand_more</span>
                            </div>
                            <div class="xl:col-span-3 relative flex items-center">
                                <span class="material-symbols-outlined absolute left-3 text-on-surface-variant text-[20px]">shelves</span>
                                <select name="stockLevel" class="w-full pl-10 pr-8 py-2.5 bg-surface-container-low rounded-xl text-sm appearance-none focus:outline-none cursor-pointer">
                                    <option value="">Tồn kho: Tất cả mức</option>
                                    <option value="low" ${param.stockLevel == 'low' ? 'selected' : ''}>Sắp hết (&lt;= 10)</option>
                                    <option value="high" ${param.stockLevel == 'high' ? 'selected' : ''}>Đủ hàng (&gt; 10)</option>
                                </select>
                                <span class="material-symbols-outlined absolute right-3 text-on-surface-variant text-[18px] pointer-events-none">expand_more</span>
                            </div>
                            <div class="xl:col-span-1 flex items-center gap-2">
                                <button type="submit" class="w-full py-2.5 bg-primary text-on-primary rounded-xl font-semibold text-sm hover:opacity-90 transition-opacity flex items-center justify-center">
                                    <span class="material-symbols-outlined text-[20px]">filter_alt</span>
                                </button>
                            </div>
                        </div>
                    </form>

                    <!-- Section 4: Cold Chain Notice -->
                    <div class="bg-secondary-container/60 rounded-2xl p-4 flex flex-col md:flex-row items-start md:items-center justify-between gap-4 shadow-sm">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-primary-container text-on-primary flex items-center justify-center shrink-0 shadow-sm">
                                <span class="material-symbols-outlined text-[22px]">ac_unit</span>
                            </div>
                            <div>
                                <div class="flex items-center gap-2">
                                    <span class="font-semibold text-sm text-on-surface">Cam kết tiêu chuẩn quả tươi hái trong ngày</span>
                                    <span class="bg-primary-container text-on-primary text-[10px] font-bold px-2 py-0.5 rounded-full">Chuỗi Lạnh VietGAP</span>
                                </div>
                                <p class="text-xs text-on-surface-variant mt-0.5">Duy trì nhiệt độ bảo quản lạnh 4°C - 8°C. Hãy cập nhật đúng số kg tồn tươi và kiểm tra mã QR nguồn gốc trước giờ giao vận 14:00 hàng ngày.</p>
                            </div>
                        </div>
                        <button class="px-3 py-1.5 rounded-lg bg-surface-container-lowest text-primary text-xs font-semibold hover:bg-surface-container shadow-xs transition-colors shrink-0" type="button">
                            Xem hướng dẫn bảo quản
                        </button>
                    </div>

                    <!-- Section 5: Data Table (JSTL Integration kết nối DB) -->
                    <div class="bg-surface-container-lowest rounded-2xl shadow-sm overflow-hidden flex flex-col" id="table-section">
                        <div class="overflow-x-auto">
                            <table class="w-full text-left border-collapse">
                                <thead class="bg-surface-container-low/80 text-on-surface-variant text-[11px] font-bold uppercase tracking-wider whitespace-nowrap">
                                    <tr>
                                        <th class="py-3.5 px-3 w-10 text-center">
                                            <input class="w-4 h-4 rounded cursor-pointer accent-primary-container" id="selectAll" type="checkbox">
                                        </th>
                                        <th class="py-3.5 px-3 w-28">Mã SKU</th>
                                        <th class="py-3.5 px-4 min-w-[240px]">Sản phẩm &amp; Biến thể</th>
                                        <th class="py-3.5 px-3 min-w-[150px]">Danh mục &amp; Chứng nhận</th>
                                        <th class="py-3.5 px-3 min-w-[130px]">Giá bán lẻ</th>
                                        <th class="py-3.5 px-3 min-w-[140px]">Tồn kho khả dụng</th>
                                        <th class="py-3.5 px-3 min-w-[110px] text-center">Trạng thái</th>
                                        <th class="py-3.5 px-4 min-w-[140px] text-center">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100 text-sm">
                                    
                                    <c:choose>
                                        <c:when test="${not empty listVariants}">
                                            <c:forEach var="v" items="${listVariants}">
                                                <tr class="hover:bg-surface-container-low/50 transition-colors group">
                                                    <td class="py-4 px-4 text-center">
                                                        <input class="row-checkbox w-4 h-4 rounded cursor-pointer accent-primary-container" type="checkbox" name="selectedIds" value="${v.variantId}">
                                                    </td>
                                                    <td class="py-4 px-4 font-mono text-xs font-semibold text-primary">
                                                        ${v.sku}
                                                    </td>
                                                    <td class="py-4 px-4">
                                                        <div class="flex items-center gap-3">
                                                            <div class="w-12 h-12 rounded-xl overflow-hidden shrink-0 bg-surface-container shadow-sm relative">
                                                                <img class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" src="${not empty v.image ? v.image : 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=100&h=100&fit=crop'}" alt="Product">
                                                            </div>
                                                            <div class="flex flex-col min-w-0">
                                                                <span class="font-semibold text-on-surface truncate group-hover:text-primary transition-colors">${v.productName}</span>
                                                                <span class="text-xs text-on-surface-variant truncate">Biến thể: <strong>${v.variantName}</strong></span>
                                                                <div class="flex items-center gap-1 mt-0.5 text-primary text-[11px] font-medium">
                                                                    <span class="material-symbols-outlined text-[13px]">location_on</span>
                                                                    <span>${not empty v.origin ? v.origin : 'Đà Lạt, Lâm Đồng'}</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td class="py-4 px-4">
                                                        <div class="flex flex-col items-start gap-1">
                                                            <span class="text-xs text-on-surface">${not empty v.categoryName ? v.categoryName : 'Trái Cây Tươi'}</span>
                                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-secondary-container text-on-primary-fixed-variant text-[10px] font-bold">
                                                                <span class="material-symbols-outlined text-[12px]">verified</span> ${not empty v.certification ? v.certification : 'VietGAP'}
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td class="py-4 px-4">
                                                        <div class="flex flex-col">
                                                            <div class="flex items-baseline gap-1">
                                                                <span class="font-bold text-tertiary-container">
                                                                    <fmt:formatNumber value="${v.price}" type="number" pattern="#,###" /> đ
                                                                </span>
                                                            </div>
                                                            <c:if test="${v.originalPrice > v.price}">
                                                                <span class="line-through text-xs text-on-surface-variant">
                                                                    <fmt:formatNumber value="${v.originalPrice}" type="number" pattern="#,###" /> đ
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                    <td class="py-4 px-4">
                                                        <div class="flex flex-col gap-1">
                                                            <div class="flex items-center justify-between">
                                                                <span class="font-semibold text-on-surface">${v.stockQuantity} ${v.unit}</span>
                                                            </div>
                                                            <c:choose>
                                                                <c:when test="${v.stockQuantity <= 10}">
                                                                    <span class="text-[10px] font-bold text-tertiary bg-tertiary-fixed px-1.5 py-0.5 rounded w-max">Sắp hết hàng</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-[11px] font-semibold text-primary">Đủ hàng ổn định</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </td>
                                                    <td class="py-4 px-4 text-center">
                                                        <c:choose>
                                                            <c:when test="${v.isActive}">
                                                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-secondary-container text-on-primary-fixed-variant text-xs font-semibold">
                                                                    <span class="w-1.5 h-1.5 rounded-full bg-primary-container"></span> Đang bán
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-surface-container-high text-on-surface text-xs font-semibold">
                                                                    <span class="w-1.5 h-1.5 rounded-full bg-secondary"></span> Tạm ẩn
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="py-4 px-4 text-right">
                                                        <div class="inline-flex items-center gap-1 justify-center">
                                                            <a href="${pageContext.request.contextPath}/shop/product/edit?id=${v.variantId}" class="w-8 h-8 rounded-lg bg-surface-container-low hover:bg-surface-container flex items-center justify-center text-on-surface-variant hover:text-on-surface transition-colors" title="Chỉnh sửa">
                                                                <span class="material-symbols-outlined text-[18px]">edit</span>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/shop/product/toggle?id=${v.variantId}" class="w-8 h-8 rounded-lg bg-surface-container-low hover:bg-surface-container flex items-center justify-center text-primary transition-colors" title="Ẩn/Hiện">
                                                                <span class="material-symbols-outlined text-[18px]">visibility</span>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/shop/product/delete?id=${v.variantId}" onclick="return confirm('Bạn có chắc muốn xóa sản phẩm này?');" class="w-8 h-8 rounded-lg bg-surface-container-low hover:bg-error-container flex items-center justify-center text-error transition-colors" title="Xóa">
                                                                <span class="material-symbols-outlined text-[18px]">delete</span>
                                                            </a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" class="py-10 text-center text-on-surface-variant">
                                                    Không tìm thấy sản phẩm nào trong kho hàng của bạn.
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination Footer -->
                        <div class="p-4 bg-surface-container-lowest flex flex-col md:flex-row items-center justify-between gap-4 border-t border-gray-100">
                            <span class="text-xs text-on-surface-variant"></span>
                            <div class="flex items-center gap-1">
                                <button class="w-9 h-9 rounded-xl bg-surface-container-low text-on-surface-variant opacity-50 flex items-center justify-center" disabled><span class="material-symbols-outlined text-[18px]">chevron_left</span></button>
                                <button class="w-9 h-9 rounded-xl bg-primary-container text-on-primary font-semibold text-sm flex items-center justify-center shadow-xs">1</button>
                                <button class="w-9 h-9 rounded-xl bg-surface-container-low hover:bg-surface-container text-on-surface font-semibold text-sm flex items-center justify-center transition-colors">2</button>
                                <button class="w-9 h-9 rounded-xl bg-surface-container-low hover:bg-surface-container text-on-surface flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[18px]">chevron_right</span></button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </main>
    </div>

    <!-- FLOATING BULK ACTION BAR -->
    <div class="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 flex items-center gap-4 px-6 py-3 bg-inverse-surface text-inverse-on-surface rounded-2xl shadow-2xl backdrop-blur-xl border border-outline/20">
        <div class="flex items-center gap-3 pr-4 border-r border-gray-700">
            <div class="w-7 h-7 rounded-full bg-primary-container text-on-primary flex items-center justify-center font-bold text-xs" id="selectedCount">0</div>
            <span class="text-sm font-semibold whitespace-nowrap">Sản phẩm đã chọn</span>
        </div>
        <div class="flex items-center gap-2">
            <button class="px-3 py-1.5 rounded-xl bg-gray-800 hover:bg-gray-700 text-xs font-semibold transition-all" type="button">Cập nhật giá loạt</button>
            <button class="px-3 py-1.5 rounded-xl bg-gray-800 hover:bg-gray-700 text-xs font-semibold transition-all" type="button">Ẩn sản phẩm</button>
            <button class="px-3 py-1.5 rounded-xl bg-error text-on-error hover:bg-error/90 text-xs font-semibold transition-all" type="button">Xóa đã chọn</button>
        </div>
    </div>

    <script>
        const selectAll = document.getElementById('selectAll');
        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const selectedCountEl = document.getElementById('selectedCount');

        function updateSelectedCount() {
            const checkedCount = document.querySelectorAll('.row-checkbox:checked').length;
            if (selectedCountEl) {
                selectedCountEl.textContent = checkedCount;
            }
        }

        if (selectAll) {
            selectAll.addEventListener('change', (e) => {
                rowCheckboxes.forEach(cb => cb.checked = e.target.checked);
                updateSelectedCount();
            });
        }

        rowCheckboxes.forEach(cb => {
            cb.addEventListener('change', updateSelectedCount);
        });
    </script>
</body>
</html>