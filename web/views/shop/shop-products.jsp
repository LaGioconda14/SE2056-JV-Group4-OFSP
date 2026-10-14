<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Sản Phẩm Nông Sản - Kênh Người Bán Đà Lạt Organic</title>
    
    <!-- Google Fonts & Font Awesome 6 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Tailwind CSS (utility helper) -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Custom CSS matching mockup -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-products.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <!-- ========================================================
         1. SIDEBAR NAVIGATION (KÊNH NGƯỜI BÁN)
         ======================================================== -->
    <aside class="shop-sidebar">
        <div>
            <!-- Shop Brand Header -->
            <div class="shop-sidebar-brand">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-full bg-[#166534] flex items-center justify-center text-white text-lg shrink-0 shadow-sm">
                        <i class="fa-solid fa-leaf text-white text-sm"></i>
                    </div>
                    <div>
                        <span class="font-extrabold text-sm text-gray-900 leading-tight block">
                            ${not empty sessionScope.shopName ? sessionScope.shopName : 'Đà Lạt Organic'}
                        </span>
                        <span class="text-[10px] font-bold text-[#15803d] tracking-wider uppercase block">Kênh Người Bán</span>
                    </div>
                </div>
                <span class="px-2 py-0.5 rounded-md bg-[#f1f5f9] text-[#64748b] text-[10px] font-black uppercase tracking-wider">SHOP</span>
            </div>

            <!-- Sidebar Navigation Groups -->
            <nav class="space-y-1 mt-3">
                <!-- Group: TỔNG QUAN -->
                <div class="shop-sidebar-group-title">TỔNG QUAN</div>
                <a href="${pageContext.request.contextPath}/shop/products" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-table-cells-large text-slate-400 text-sm w-4 text-center"></i>
                        <span>Tổng quan Shop</span>
                    </span>
                </a>

                <!-- Group: SẢN PHẨM & KHO -->
                <div class="shop-sidebar-group-title">SẢN PHẨM & KHO</div>
                <a href="${pageContext.request.contextPath}/shop/products" class="shop-sidebar-link active">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-apple-whole text-white text-sm w-4 text-center"></i>
                        <span>Tất cả sản phẩm</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/product/add" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-plus text-slate-400 text-sm w-4 text-center"></i>
                        <span>Thêm mới nông sản</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/inventory" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-boxes-stacked text-slate-400 text-sm w-4 text-center"></i>
                        <span>Kho & Cảnh báo tồn</span>
                    </span>
                    <span class="badge-counter-red">${not empty lowStockCount ? lowStockCount : 3}</span>
                </a>

                <!-- Group: ĐƠN HÀNG -->
                <div class="shop-sidebar-group-title">ĐƠN HÀNG</div>
                <a href="${pageContext.request.contextPath}/shop/orders" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-receipt text-slate-400 text-sm w-4 text-center"></i>
                        <span>Đơn hàng con</span>
                    </span>
                    <span class="badge-counter-orange">8</span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/shipping" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-truck-fast text-slate-400 text-sm w-4 text-center"></i>
                        <span>Đóng gói & Vận đơn</span>
                    </span>
                </a>

                <!-- Group: TIẾP THỊ & KHÁCH HÀNG -->
                <div class="shop-sidebar-group-title">TIẾP THỊ & KHÁCH HÀNG</div>
                <a href="${pageContext.request.contextPath}/shop/coupons" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-tag text-slate-400 text-sm w-4 text-center"></i>
                        <span>Mã giảm giá Shop</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/reviews" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-regular fa-star text-slate-400 text-sm w-4 text-center"></i>
                        <span>Đánh giá từ khách</span>
                    </span>
                </a>

                <!-- Group: TÀI CHÍNH & THIẾT LẬP -->
                <div class="shop-sidebar-group-title">TÀI CHÍNH & THIẾT LẬP</div>
                <a href="${pageContext.request.contextPath}/shop/finance" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-regular fa-credit-card text-slate-400 text-sm w-4 text-center"></i>
                        <span>Doanh thu & Rút tiền</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/settings" class="shop-sidebar-link">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-gear text-slate-400 text-sm w-4 text-center"></i>
                        <span>Cài đặt Shop</span>
                    </span>
                </a>
            </nav>
        </div>

        <!-- Sidebar Footer Links -->
        <div class="pt-4 border-t border-slate-100 space-y-1">
            <a href="${pageContext.request.contextPath}/home" class="shop-sidebar-link text-slate-600 hover:text-emerald-700">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-store text-xs w-4 text-center"></i>
                    <span>Xem trang mua sắm</span>
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="shop-sidebar-link text-red-600 hover:bg-red-50 hover:text-red-700">
                <span class="flex items-center gap-3">
                    <i class="fa-solid fa-arrow-right-from-bracket text-xs w-4 text-center"></i>
                    <span>Đăng xuất</span>
                </span>
            </a>
        </div>
    </aside>

    <!-- ========================================================
         2. TOP HEADER NAVBAR
         ======================================================== -->
    <header class="shop-header">
        <!-- Search bar -->
        <div class="header-search-container">
            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
            <form action="${pageContext.request.contextPath}/shop/products" method="GET">
                <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo SKU, tên trái cây, hoặc mã đơn con (Ctrl + K)..." class="header-search-input">
            </form>
        </div>

        <!-- Right Header Items -->
        <div class="flex items-center gap-4">
            <!-- Active receiving orders status -->
            <div class="status-receiving-orders">
                <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                <span>Đang nhận đơn</span>
            </div>

            <!-- Chat icon -->
            <button class="header-icon-action" type="button" title="Tin nhắn">
                <i class="fa-regular fa-comment-dots text-sm"></i>
            </button>

            <!-- Notification icon with badge 5 -->
            <button class="header-icon-action" type="button" title="Thông báo">
                <i class="fa-regular fa-bell text-sm"></i>
                <span class="header-icon-badge">5</span>
            </button>

            <!-- User profile -->
            <div class="flex items-center gap-3 pl-3 border-l border-slate-200">
                <div class="text-right hidden sm:block">
                    <span class="text-xs font-bold text-gray-900 block leading-tight">
                        ${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Phạm Văn Nông'}
                    </span>
                    <span class="text-[11px] text-gray-500 block leading-tight">Chủ Vườn Đà Lạt</span>
                </div>
                <div class="w-9 h-9 rounded-full bg-[#166534] text-white flex items-center justify-center font-bold text-sm shrink-0 shadow-xs">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatarUrl}">
                            <img src="${sessionScope.user.avatarUrl}" alt="Avatar" class="w-full h-full rounded-full object-cover">
                        </c:when>
                        <c:otherwise>
                            <i class="fa-regular fa-user text-xs"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <!-- ========================================================
         3. MAIN CONTENT
         ======================================================== -->
    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <!-- Success Notification Alert -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="mb-4 bg-emerald-50 border border-emerald-300 text-emerald-800 px-4 py-3 rounded-xl flex items-center justify-between shadow-sm">
                    <div class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-check text-emerald-600 text-lg"></i>
                        <span class="text-sm font-semibold">${sessionScope.successMessage}</span>
                    </div>
                    <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-800">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>

            <!-- Breadcrumb & Header Title -->
            <div class="flex flex-col gap-2 mb-6">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span>Sản phẩm & Kho</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-slate-800 font-semibold">Tất cả sản phẩm</span>
                </nav>

                <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4 mt-1">
                    <div>
                        <div class="flex items-center flex-wrap gap-3">
                            <h1 class="text-2xl font-black text-gray-900 tracking-tight">Danh Sách Sản Phẩm Nông Sản</h1>
                            <span class="title-badge-pill">
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span>
                                ${not empty totalProducts && totalProducts > 0 ? totalProducts : 42} SẢN PHẨM / ${not empty totalSKU && totalSKU > 0 ? totalSKU : 115} SKUS
                            </span>
                        </div>
                        <p class="text-xs text-slate-500 mt-1">
                            Quản lý định danh quả, biến thể bao bì, tồn kho nông trại và chứng nhận tiêu chuẩn VietGAP/OCOP.
                        </p>
                    </div>

                    <!-- Action buttons -->
                    <div class="flex items-center flex-wrap gap-2.5">
                        <button type="button" class="btn-export-excel" onclick="alert('Đang xuất dữ liệu danh sách nông sản ra file Excel (.xlsx)...');">
                            <i class="fa-solid fa-arrow-down-to-bracket text-xs text-slate-600"></i>
                            <span>Xuất dữ liệu Excel</span>
                        </button>
                        <button type="button" class="btn-sync-price" onclick="alert('Hệ thống đang đồng bộ bảng giá loạt...');">
                            <i class="fa-solid fa-bolt text-xs text-purple-600"></i>
                            <span>Đồng bộ giá loạt</span>
                        </button>
                        <a href="${pageContext.request.contextPath}/shop/product/add" class="btn-add-product-main">
                            <i class="fa-solid fa-plus-circle text-sm"></i>
                            <span>+ Thêm mới nông sản</span>
                        </a>
                    </div>
                </div>
            </div>

            <!-- ========================================================
                 5. STATUS TABS
                 ======================================================== -->
            <div class="flex items-center gap-2 overflow-x-auto pb-1 text-sm">
                <a href="${pageContext.request.contextPath}/shop/products?statusTab=all" 
                   class="status-tab-btn ${empty statusTab || statusTab == 'all' ? 'active' : ''}">
                    <span>Tất cả</span>
                    <span class="status-tab-badge">${not empty tabAllCount && tabAllCount > 0 ? tabAllCount : 42}</span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/products?statusTab=active" 
                   class="status-tab-btn ${statusTab == 'active' ? 'active' : ''}">
                    <span>Đang mở bán</span>
                    <span class="status-tab-badge">${not empty tabActiveCount && tabActiveCount > 0 ? tabActiveCount : 38}</span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/products?statusTab=vietgap" 
                   class="status-tab-btn ${statusTab == 'vietgap' ? 'active' : ''}">
                    <span>Chờ duyệt VietGAP</span>
                    <span class="status-tab-badge bg-orange-100 text-orange-700">${not empty tabVietgapCount && tabVietgapCount > 0 ? tabVietgapCount : 2}</span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/products?statusTab=hidden" 
                   class="status-tab-btn ${statusTab == 'hidden' ? 'active' : ''}">
                    <span>Hết hàng / Tạm ẩn</span>
                    <span class="status-tab-badge bg-rose-100 text-rose-700">${not empty tabHiddenCount && tabHiddenCount > 0 ? tabHiddenCount : 2}</span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/products?statusTab=warning" 
                   class="status-tab-btn ${statusTab == 'warning' ? 'active' : ''}">
                    <span>Vi phạm / Cảnh báo</span>
                    <span class="status-tab-badge">${not empty tabWarningCount ? tabWarningCount : 0}</span>
                </a>
            </div>

            <!-- ========================================================
                 6. SEARCH & FILTER TOOLBAR
                 ======================================================== -->
            <form action="${pageContext.request.contextPath}/shop/products" method="GET" class="filter-card">
                <input type="hidden" name="statusTab" value="${statusTab}">
                
                <!-- Main Filters Row -->
                <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-12 gap-3 items-center">
                    <!-- Search Input -->
                    <div class="xl:col-span-5 filter-input-wrapper">
                        <i class="fa-solid fa-magnifying-glass absolute left-3 text-slate-400 text-xs pointer-events-none"></i>
                        <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên trái cây, mã SKU, mã lô nông sản..." class="filter-search-box">
                    </div>

                    <!-- Category Filter -->
                    <div class="xl:col-span-3">
                        <select name="categoryId" class="filter-select-box" onchange="this.form.submit()">
                            <option value="">Tất cả danh mục quả</option>
                            <c:forEach var="c" items="${categories}">
                                <option value="${c.categoryId}" ${param.categoryId == c.categoryId ? 'selected' : ''}>
                                    ${c.categoryName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Certification Filter -->
                    <div class="xl:col-span-2">
                        <select name="certification" class="filter-select-box" onchange="this.form.submit()">
                            <option value="">Chứng nhận: Tất cả</option>
                            <option value="VietGAP" ${param.certification == 'VietGAP' ? 'selected' : ''}>VietGAP</option>
                            <option value="OCOP" ${param.certification == 'OCOP' ? 'selected' : ''}>OCOP</option>
                            <option value="GlobalGAP" ${param.certification == 'GlobalGAP' ? 'selected' : ''}>GlobalGAP</option>
                            <option value="Organic" ${param.certification == 'Organic' ? 'selected' : ''}>Organic</option>
                        </select>
                    </div>

                    <!-- Stock Level Filter -->
                    <div class="xl:col-span-2">
                        <select name="stockLevel" class="filter-select-box" onchange="this.form.submit()">
                            <option value="">Tồn kho: Tất cả</option>
                            <option value="critical" ${param.stockLevel == 'critical' ? 'selected' : ''}>Tồn &lt; 5 đơn vị</option>
                            <option value="low" ${param.stockLevel == 'low' ? 'selected' : ''}>Sắp hết (&lt;= 15)</option>
                            <option value="stable" ${param.stockLevel == 'stable' ? 'selected' : ''}>Ổn định (16 - 40)</option>
                            <option value="abundant" ${param.stockLevel == 'abundant' ? 'selected' : ''}>Dồi dào (&gt; 40)</option>
                        </select>
                    </div>
                </div>

                <!-- Quick Filter Chips & Count -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2 border-t border-slate-100 text-xs">
                    <div class="flex items-center flex-wrap gap-2">
                        <span class="font-extrabold text-[10px] uppercase tracking-wider text-slate-400 mr-1">LỌC NHANH:</span>
                        
                        <a href="${pageContext.request.contextPath}/shop/products?stockLevel=critical" 
                           class="quick-filter-chip ${param.stockLevel == 'critical' ? 'active' : ''}">
                            <i class="fa-solid fa-circle-exclamation text-red-500"></i> Tồn &lt; 5 đơn vị
                        </a>
                        
                        <a href="${pageContext.request.contextPath}/shop/products?certification=VietGAP" 
                           class="quick-filter-chip ${param.certification == 'VietGAP' ? 'active' : ''}">
                            <i class="fa-solid fa-check text-emerald-600"></i> Chuẩn VietGAP 2024
                        </a>

                        <a href="${pageContext.request.contextPath}/shop/products?certification=OCOP" 
                           class="quick-filter-chip ${param.certification == 'OCOP' ? 'active' : ''}">
                            <i class="fa-solid fa-star text-amber-500"></i> OCOP 4 Sao Tỉnh
                        </a>

                        <a href="${pageContext.request.contextPath}/shop/products" class="text-slate-500 hover:text-red-600 font-semibold ml-2 underline">
                            Xóa bộ lọc
                        </a>
                    </div>

                    <div class="text-slate-500 font-medium">
                        Hiển thị: <span class="font-bold text-slate-800">${not empty listVariants ? listVariants.size() : 0}</span> trên tổng <span class="font-bold text-slate-800">${not empty totalVariantsCount ? totalVariantsCount : (not empty listVariants ? listVariants.size() : 0)}</span> nông sản
                    </div>
                </div>
            </form>

            <!-- ========================================================
                 7. DATA TABLE
                 ======================================================== -->
            <div class="table-container-card">
                <div class="overflow-x-auto">
                    <table class="products-table">
                        <thead>
                            <tr>
                                <th class="w-10 text-center">
                                    <input type="checkbox" id="selectAllCheckbox" class="w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                                </th>
                                <th class="min-w-[280px]">SẢN PHẨM & PHÂN LOẠI</th>
                                <th class="min-w-[170px]">QUY CÁCH ĐÓNG GÓI</th>
                                <th class="min-w-[140px]">GIÁ BÁN LẺ</th>
                                <th class="min-w-[190px]">TỒN KHO THỰC TẾ</th>
                                <th class="min-w-[170px] text-right">CHỨNG NHẬN / THAO TÁC</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty listVariants}">
                                    <c:forEach var="v" items="${listVariants}">
                                        <tr>
                                            <!-- Checkbox -->
                                            <td class="text-center">
                                                <input type="checkbox" name="variantIds" value="${v.variantId}" class="variant-row-checkbox w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                                            </td>

                                            <!-- SẢN PHẨM & PHÂN LOẠI -->
                                            <td>
                                                <div class="flex items-center gap-3">
                                                    <img src="${v.image}" alt="${v.productName}" class="table-product-thumb-img" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                                                    <div class="flex flex-col min-w-0">
                                                        <span class="font-bold text-sm text-slate-900 truncate leading-snug hover:text-emerald-700 transition-colors cursor-pointer">
                                                            ${v.productName}
                                                        </span>
                                                        <span class="text-xs text-slate-500 truncate leading-snug">
                                                            ${not empty v.categoryName ? v.categoryName : 'Trái Cây Tươi'}
                                                        </span>
                                                        <span class="font-mono text-[11px] text-slate-400 mt-0.5">
                                                            SKU: ${v.sku}
                                                        </span>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- QUY CÁCH ĐÓNG GÓI -->
                                            <td>
                                                <div class="flex flex-col items-start gap-1">
                                                    <span class="font-semibold text-xs text-slate-800">
                                                        ${v.variantName}
                                                    </span>
                                                    <c:choose>
                                                        <c:when test="${v.totalVariantsCount > 1}">
                                                            <span class="badge-variant-pill">
                                                                ${v.totalVariantsCount} Biến thể (+${v.unit})
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="px-2 py-0.5 rounded-md bg-slate-100 text-slate-600 text-[10px] font-bold">
                                                                1 Biến thể duy nhất
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>

                                            <!-- GIÁ BÁN LẺ -->
                                            <td>
                                                <div class="flex flex-col">
                                                    <span class="font-extrabold text-sm text-[#166534]">
                                                        ₫${v.formattedPrice}
                                                    </span>
                                                    <c:choose>
                                                        <c:when test="${v.originalPrice > v.price}">
                                                            <span class="line-through text-xs text-slate-400">
                                                                ₫${v.formattedOriginalPrice}
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-[11px] text-slate-400">
                                                                / ${not empty v.unit ? v.unit : 'tiêu chuẩn'}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>

                                            <!-- TỒN KHO THỰC TẾ -->
                                            <td>
                                                <div class="flex flex-col">
                                                    <div class="flex items-center justify-between gap-2 max-w-[140px]">
                                                        <!-- Left Icon & Count -->
                                                        <c:choose>
                                                            <c:when test="${v.stockQuantity <= 5}">
                                                                <span class="text-xs font-bold text-red-600 flex items-center gap-1">
                                                                    <i class="fa-solid fa-circle-minus text-red-500 text-[11px]"></i> ${v.stockQuantity} ${v.unit}
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${v.stockQuantity <= 15}">
                                                                <span class="text-xs font-bold text-amber-600 flex items-center gap-1">
                                                                    <i class="fa-solid fa-triangle-exclamation text-amber-500 text-[11px]"></i> ${v.stockQuantity} ${v.unit}
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-xs font-bold text-emerald-600 flex items-center gap-1">
                                                                    <i class="fa-solid fa-check text-emerald-600 text-[11px]"></i> ${v.stockQuantity} ${v.unit}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <!-- Right Status text -->
                                                        <span class="text-[11px] text-slate-500 font-medium">
                                                            ${v.stockStatusText}
                                                        </span>
                                                    </div>

                                                    <!-- Visual progress bar -->
                                                    <div class="stock-progress-track">
                                                        <div class="stock-progress-fill ${v.stockBarColor}" style="width: ${v.stockProgressPercent}%;"></div>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- CHỨNG NHẬN / THAO TÁC -->
                                            <td class="text-right">
                                                <div class="flex items-center justify-end gap-2">
                                                    <!-- Certification Pill -->
                                                    <c:choose>
                                                        <c:when test="${v.certification == 'VietGAP'}">
                                                            <span class="badge-cert-vietgap">
                                                                <i class="fa-solid fa-shield-check text-[10px]"></i> VietGAP
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${v.certification != null && v.certification.contains('OCOP')}">
                                                            <span class="badge-cert-ocop">
                                                                <i class="fa-solid fa-star text-[10px]"></i> ${v.certification}
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${v.certification == 'GlobalGAP'}">
                                                            <span class="badge-cert-globalgap">
                                                                <i class="fa-solid fa-certificate text-[10px]"></i> GlobalGAP
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="px-2 py-0.5 rounded-full bg-slate-100 text-slate-600 text-[10px] font-bold">
                                                                ${not empty v.certification ? v.certification : 'Tiêu chuẩn'}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <!-- Action buttons -->
                                                    <div class="inline-flex items-center gap-1">
                                                        <a href="${pageContext.request.contextPath}/shop/product/edit?id=${v.variantId}" class="action-icon-btn" title="Chỉnh sửa">
                                                            <i class="fa-solid fa-pen text-xs"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/shop/product/toggle?id=${v.variantId}" class="action-icon-btn" title="Ẩn / Hiện">
                                                            <i class="fa-regular fa-eye text-xs"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/shop/product/delete?id=${v.variantId}" onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');" class="action-icon-btn delete" title="Xóa">
                                                            <i class="fa-regular fa-trash-can text-xs"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="py-16 text-center text-slate-400">
                                            <i class="fa-solid fa-basket-shopping text-3xl mb-2 text-slate-300 block"></i>
                                            <span class="text-sm font-semibold">Không tìm thấy nông sản nào phù hợp với bộ lọc.</span>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer -->
                <div class="table-pagination-footer">
                    <div class="flex items-center gap-2 text-xs text-slate-500">
                        <span>Hiển thị</span>
                        <select class="px-2 py-1 rounded border border-slate-200 text-xs font-semibold bg-white cursor-pointer" onchange="location.href='${pageContext.request.contextPath}/shop/products?page=1&pageSize=' + this.value;">
                            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
                        </select>
                        <span>trên tổng <strong class="text-slate-800">${not empty totalVariantsCount ? totalVariantsCount : (not empty listVariants ? listVariants.size() : 0)}</strong> nông sản</span>
                    </div>

                    <div class="flex items-center gap-1.5">
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/shop/products?page=${currentPage - 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="page-num-btn">
                                <i class="fa-solid fa-chevron-left text-[11px]"></i>
                            </a>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="p">
                            <a href="${pageContext.request.contextPath}/shop/products?page=${p}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="page-num-btn ${p == currentPage ? 'active' : ''}">
                                ${p}
                            </a>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/shop/products?page=${currentPage + 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="page-num-btn">
                                <i class="fa-solid fa-chevron-right text-[11px]"></i>
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- Checkbox selection helper script -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const selectAll = document.getElementById('selectAllCheckbox');
            const rowCheckboxes = document.querySelectorAll('.variant-row-checkbox');
            
            if (selectAll) {
                selectAll.addEventListener('change', function() {
                    rowCheckboxes.forEach(cb => cb.checked = selectAll.checked);
                });
            }
        });
    </script>
</body>
</html>
