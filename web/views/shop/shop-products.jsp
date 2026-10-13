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
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-products.css">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/shop-products.js" defer></script>
</head>
<body class="bg-background font-body-md text-on-surface antialiased pb-32">

    <!-- SIDEBAR NAVIGATION -->
    <aside class="shop-sidebar">
        <div class="flex flex-col gap-4">
            <div class="flex items-center gap-2 px-1 pt-1">
                <div class="shop-brand-logo">
                    <span class="material-symbols-outlined text-[24px]">eco</span>
                </div>
                <div class="flex flex-col">
                    <span class="font-bold text-lg text-on-surface leading-tight tracking-tight">FreshFruit</span>
                    <span class="text-[11px] font-bold text-primary tracking-wider uppercase">Seller Center</span>
                </div>
            </div>

            <!-- Shop Info Card -->
            <div class="shop-info-card">
                <div class="flex items-center gap-2 overflow-hidden">
                    <div class="shop-avatar-box">
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
                <a class="nav-item" href="${pageContext.request.contextPath}/shop/dashboard">
                    <span class="material-symbols-outlined text-[20px]">dashboard</span>
                    <span>Tổng quan</span>
                </a>
                <a class="nav-item active" href="${pageContext.request.contextPath}/shop/products">
                    <span class="material-symbols-outlined text-[20px]">inventory_2</span>
                    <span>Sản phẩm & Kho hàng</span>
                </a>
                <a class="nav-item" href="${pageContext.request.contextPath}/shop/orders">
                    <span class="material-symbols-outlined text-[20px]">local_shipping</span>
                    <span>Quản lý đơn hàng</span>
                </a>
                <a class="nav-item" href="${pageContext.request.contextPath}/shop/profile">
                    <span class="material-symbols-outlined text-[20px]">storefront</span>
                    <span>Hồ sơ cửa hàng</span>
                </a>
                <a class="nav-item" href="${pageContext.request.contextPath}/shop/finance">
                    <span class="material-symbols-outlined text-[20px]">account_balance_wallet</span>
                    <span>Doanh thu & Ví</span>
                </a>
                <a class="nav-item" href="${pageContext.request.contextPath}/shop/reviews">
                    <span class="material-symbols-outlined text-[20px]">reviews</span>
                    <span>Đánh giá từ khách</span>
                </a>
            </nav>
        </div>

        <!-- Support Box -->
        <div class="sidebar-support-card">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-lg bg-primary-container flex items-center justify-center text-on-primary shrink-0">
                    <span class="material-symbols-outlined text-[18px]">support_agent</span>
                </div>
                <div class="flex flex-col">
                    <span class="text-sm text-on-surface font-semibold">Hỗ trợ nhà vườn 24/7</span>
                    <span class="text-xs text-on-surface-variant">Chuyên viên nông nghiệp</span>
                </div>
            </div>
            <a class="sidebar-support-btn" href="tel:19006868">Hotline: 1900 6868</a>
        </div>
    </aside>

    <!-- MAIN CONTENT AREA -->
    <div class="pl-72">
        <header class="shop-top-header">
            <div class="flex items-center gap-4">
                <div class="flex items-center gap-2 bg-surface-container-low px-3 py-1.5 rounded-lg">
                    <span class="material-symbols-outlined text-primary text-[18px]">potted_plant</span>
                    <span class="text-sm text-on-surface font-semibold">${sessionScope.shopName}</span>
                    <span class="text-xs text-on-surface-variant">• Gian hàng nông sản sạch</span>
                    <span class="material-symbols-outlined text-on-surface-variant text-[16px] ml-1">expand_more</span>
                </div>
                <div class="shop-status-badge">
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
                    <button class="header-icon-btn" type="button">
                        <span class="material-symbols-outlined text-[20px]">chat</span>
                    </button>
                    <button class="header-icon-btn relative" type="button">
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
                                <button class="btn-secondary-action" type="button">
                                    <span class="material-symbols-outlined text-[20px] text-primary">file_download</span>
                                    <span>Xuất file tồn kho (.xlsx)</span>
                                </button>
                                <a href="${pageContext.request.contextPath}/shop/product/add" class="btn-primary-action">
                                    <span class="material-symbols-outlined text-[20px]">add_circle</span>
                                    <span>Thêm sản phẩm mới</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Section 2: Quick Stat KPI Summary -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                        <div class="kpi-card">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="kpi-title">Tổng số sản phẩm đang bán</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="kpi-value">${requestScope.totalSKU}</span>
                                        <span class="text-xs text-on-surface-variant">mã SKU</span>
                                    </div>
                                </div>
                                <div class="kpi-icon-box bg-secondary-container text-primary">
                                    <span class="material-symbols-outlined text-[24px]">inventory_2</span>
                                </div>
                            </div>
                            <div class="kpi-footer">
                                <span class="text-primary font-semibold flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">trending_up</span> +4 mã trong tháng</span>
                                <span class="text-on-surface-variant">Đạt chuẩn 100%</span>
                            </div>
                        </div>

                        <div class="kpi-card">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="kpi-title text-tertiary">Cảnh báo sắp hết hàng</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="kpi-value text-tertiary">${requestScope.lowStockCount}</span>
                                        <span class="text-xs text-on-surface-variant">loại quả</span>
                                    </div>
                                </div>
                                <div class="kpi-icon-box bg-tertiary-fixed text-tertiary">
                                    <span class="material-symbols-outlined text-[24px]">warning_amber</span>
                                </div>
                            </div>
                            <div class="kpi-footer">
                                <span class="text-tertiary font-medium">&lt; 10kg tại kho lạnh</span>
                                <a class="text-tertiary underline font-bold hover:opacity-80" href="#table-section">Bổ sung ngay</a>
                            </div>
                        </div>

                        <div class="kpi-card">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="kpi-title">Tạm ẩn / Hết mùa vụ</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="kpi-value">05</span>
                                        <span class="text-xs text-on-surface-variant">mã lưu trữ</span>
                                    </div>
                                </div>
                                <div class="kpi-icon-box bg-surface-container-high text-secondary">
                                    <span class="material-symbols-outlined text-[24px]">visibility_off</span>
                                </div>
                            </div>
                            <div class="kpi-footer">
                                <span class="text-on-surface-variant">Đang đợi mùa thu hoạch mới</span>
                                <span class="w-2 h-2 rounded-full bg-secondary"></span>
                            </div>
                        </div>

                        <div class="kpi-card">
                            <div class="flex items-start justify-between">
                                <div class="flex flex-col">
                                    <span class="kpi-title">Tổng giá trị kho tươi</span>
                                    <div class="flex items-baseline gap-2 mt-1">
                                        <span class="kpi-value text-primary text-2xl">${requestScope.totalValue}Đ</span>
                                    </div>
                                </div>
                                <div class="kpi-icon-box bg-secondary-container text-primary">
                                    <span class="material-symbols-outlined text-[24px]">savings</span>
                                </div>
                            </div>
                            <div class="kpi-footer">
                                <span class="text-primary font-semibold flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">verified</span> Độ tươi đạt 96.8%</span>
                                <span class="text-on-surface-variant">Cập nhật trước</span>
                            </div>
                        </div>
                    </div>

                    <!-- Section 3: Toolbar & Advanced Filtering (Form GET để lọc dữ liệu) -->
                    <form method="GET" action="${pageContext.request.contextPath}/shop/products" class="bg-surface-container-lowest rounded-2xl p-4 shadow-sm flex flex-col gap-4">
                        <div class="flex items-center gap-2 overflow-x-auto pb-1">
                            <a href="${pageContext.request.contextPath}/shop/products" class="filter-tab filter-tab-active">Tất cả</a>
                            <a href="${pageContext.request.contextPath}/shop/products?status=active" class="filter-tab filter-tab-inactive">Đang bán (48)</a>
                            <a href="${pageContext.request.contextPath}/shop/products?stockLevel=low" class="filter-tab filter-tab-inactive text-tertiary flex items-center gap-1.5">
                                <span class="w-2 h-2 rounded-full bg-tertiary"></span> Sắp hết hàng (3)
                            </a>
                            <a href="${pageContext.request.contextPath}/shop/products?status=hidden" class="filter-tab filter-tab-inactive">Tạm ẩn (5)</a>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-12 gap-3 items-center">
                            <div class="xl:col-span-5 relative flex items-center">
                                <span class="material-symbols-outlined absolute left-3 text-on-surface-variant text-[20px]">search</span>
                                <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên quả, mã SKU, xuất xứ..." class="filter-input">
                            </div>
                            <div class="xl:col-span-3 relative flex items-center">
                                <span class="material-symbols-outlined absolute left-3 text-on-surface-variant text-[20px]">category</span>
                                <select name="categoryId" class="filter-select">
                                    <option value="">Danh mục: Tất cả</option>
                                    <option value="1" ${param.categoryId == '1' ? 'selected' : ''}>Trái Cây Theo Mùa</option>
                                    <option value="2" ${param.categoryId == '2' ? 'selected' : ''}>Dâu & Quả mọng</option>
                                </select>
                                <span class="material-symbols-outlined absolute right-3 text-on-surface-variant text-[18px] pointer-events-none">expand_more</span>
                            </div>
                            <div class="xl:col-span-3 relative flex items-center">
                                <span class="material-symbols-outlined absolute left-3 text-on-surface-variant text-[20px]">shelves</span>
                                <select name="stockLevel" class="filter-select">
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
                                        <th class="shop-table-th w-10 text-center">
                                            <input class="w-4 h-4 rounded cursor-pointer accent-primary-container" id="selectAll" type="checkbox">
                                        </th>
                                        <th class="shop-table-th w-28">Mã SKU</th>
                                        <th class="shop-table-th min-w-[240px]">Sản phẩm &amp; Biến thể</th>
                                        <th class="shop-table-th min-w-[150px]">Danh mục &amp; Chứng nhận</th>
                                        <th class="shop-table-th min-w-[130px]">Giá bán lẻ</th>
                                        <th class="shop-table-th min-w-[140px]">Tồn kho khả dụng</th>
                                        <th class="shop-table-th min-w-[110px] text-center">Trạng thái</th>
                                        <th class="shop-table-th min-w-[140px] text-center">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100 text-sm">
                                    <c:choose>
                                        <c:when test="${not empty listVariants}">
                                            <c:forEach var="v" items="${listVariants}">
                                                <tr class="hover:bg-surface-container-low/50 transition-colors group">
                                                    <td class="shop-table-td text-center">
                                                        <input class="row-checkbox w-4 h-4 rounded cursor-pointer accent-primary-container" type="checkbox" name="selectedIds" value="${v.variantId}">
                                                    </td>
                                                    <td class="shop-table-td font-mono text-xs font-semibold text-primary">
                                                        ${v.sku}
                                                    </td>
                                                    <td class="shop-table-td">
                                                        <div class="flex items-center gap-3">
                                                            <div class="table-product-thumb">
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
                                                    <td class="shop-table-td">
                                                        <div class="flex flex-col items-start gap-1">
                                                            <span class="text-xs text-on-surface">${not empty v.categoryName ? v.categoryName : 'Trái Cây Tươi'}</span>
                                                            <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-secondary-container text-on-primary-fixed-variant text-[10px] font-bold">
                                                                <span class="material-symbols-outlined text-[12px]">verified</span> ${not empty v.certification ? v.certification : 'VietGAP'}
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td class="shop-table-td">
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
                                                    <td class="shop-table-td">
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
                                                    <td class="shop-table-td text-center">
                                                        <c:choose>
                                                            <c:when test="${v.isActive}">
                                                                <span class="badge-selling">
                                                                    <span class="w-1.5 h-1.5 rounded-full bg-primary-container"></span> Đang bán
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-hidden">
                                                                    <span class="w-1.5 h-1.5 rounded-full bg-secondary"></span> Tạm ẩn
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="shop-table-td text-right">
                                                        <div class="inline-flex items-center gap-1 justify-center">
                                                            <a href="${pageContext.request.contextPath}/shop/product/edit?id=${v.variantId}" class="btn-row-action btn-row-edit" title="Chỉnh sửa">
                                                                <span class="material-symbols-outlined text-[18px]">edit</span>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/shop/product/toggle?id=${v.variantId}" class="btn-row-action btn-row-toggle" title="Ẩn/Hiện">
                                                                <span class="material-symbols-outlined text-[18px]">visibility</span>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/shop/product/delete?id=${v.variantId}" onclick="return confirm('Bạn có chắc muốn xóa sản phẩm này?');" class="btn-row-action btn-row-delete" title="Xóa">
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
                                <button class="pagination-btn pagination-btn-default opacity-50" disabled><span class="material-symbols-outlined text-[18px]">chevron_left</span></button>
                                <button class="pagination-btn pagination-btn-active">1</button>
                                <button class="pagination-btn pagination-btn-default">2</button>
                                <button class="pagination-btn pagination-btn-default"><span class="material-symbols-outlined text-[18px]">chevron_right</span></button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </main>
    </div>

    <!-- FLOATING BULK ACTION BAR -->
    <div class="floating-bulk-bar">
        <div class="flex items-center gap-3 pr-4 border-r border-gray-700">
            <div class="w-7 h-7 rounded-full bg-primary-container text-on-primary flex items-center justify-center font-bold text-xs" id="selectedCount">0</div>
            <span class="text-sm font-semibold whitespace-nowrap">Sản phẩm đã chọn</span>
        </div>
        <div class="flex items-center gap-2">
            <button class="bulk-btn-action" type="button">Cập nhật giá loạt</button>
            <button class="bulk-btn-action" type="button">Ẩn sản phẩm</button>
            <button class="bulk-btn-danger" type="button">Xóa đã chọn</button>
        </div>
    </div>
</body>
</html>
