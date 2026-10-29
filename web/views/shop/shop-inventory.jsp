<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản Lý Tồn Kho & Cảnh Báo Độ Tươi Nông Sản - Kênh Người Bán Đà Lạt Organic</title>

    <!-- Head chung: meta, font, Font Awesome, Tailwind, shop-layout.css/js -->
    <jsp:include page="/views/shop/layout/head.jsp" />

    <!-- CSS riêng của trang -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-products.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-inventory.css">
</head>
<body class="bg-[#f8fafc] text-[#0f172a]">

    <!-- Flash Messages (if any) -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div id="flashMsg" class="fixed top-20 right-8 z-50 bg-emerald-600 text-white px-5 py-3 rounded-xl shadow-lg flex items-center gap-3 text-xs font-bold animate-bounce">
            <i class="fa-solid fa-circle-check text-base"></i>
            <span>${sessionScope.successMessage}</span>
            <button onclick="this.parentElement.remove()" class="ml-2 text-white/80 hover:text-white">&times;</button>
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <!-- ========================================================
         SIDEBAR + HEADER DÙNG CHUNG (views/shop/layout/)
         ======================================================== -->
    <jsp:include page="/views/shop/layout/sidebar.jsp">
        <jsp:param name="active" value="inventory" />
    </jsp:include>
    <jsp:include page="/views/shop/layout/header.jsp">
        <jsp:param name="searchAction" value="/shop/inventory" />
    </jsp:include>

    <!-- ========================================================
         3. MAIN CONTENT
         ======================================================== -->
    <main class="shop-main-wrapper">
        <div class="shop-content-container">

            <!-- Breadcrumb & Header Title -->
            <div class="flex flex-col gap-2 mb-6">
                <nav class="flex items-center gap-2 text-xs text-slate-500 font-medium">
                    <span>Kênh Người Bán</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span>Sản phẩm & Kho</span>
                    <i class="fa-solid fa-chevron-right text-[10px] text-slate-400"></i>
                    <span class="text-slate-800 font-semibold">Kho & Cảnh báo tồn</span>
                </nav>

                <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4 mt-1">
                    <div>
                        <div class="flex items-center flex-wrap gap-3">
                            <h1 class="text-2xl font-black text-gray-900 tracking-tight">Quản Lý Tồn Kho & Cảnh Báo Độ Tươi Nông Sản</h1>
                            <span class="px-2.5 py-0.5 rounded-full bg-red-100 text-red-600 font-extrabold text-[11px] uppercase tracking-wider flex items-center gap-1.5">
                                <span class="w-1.5 h-1.5 rounded-full bg-red-500 animate-ping"></span>
                                ${criticalStockCount} Mặt Hàng Cần Nhập Kho Gấp
                            </span>
                        </div>
                        <p class="text-xs text-slate-500 mt-1">
                            Giám sát độ tươi nhiệt độ kho lạnh 4°C - 8°C tại vườn Đà Lạt, cảnh báo thiếu hụt SKU và quản lý vòng đời hái trái trong ngày.
                        </p>
                    </div>

                    <!-- Action buttons -->
                    <div class="flex items-center flex-wrap gap-2.5">
                        <button type="button" onclick="openRestockModal()" class="btn-add-product-main">
                            <i class="fa-solid fa-dolly text-sm"></i>
                            <span>+ Nhập kho nhanh (Restock)</span>
                        </button>
                        <button type="button" class="btn-export-excel" onclick="alert('Đang tạo phiếu kiểm kê kho tươi...');">
                            <i class="fa-solid fa-clipboard-check text-xs text-slate-600"></i>
                            <span>Tạo phiếu kiểm kê</span>
                        </button>
                        <button type="button" class="btn-export-excel" onclick="alert('Đang xuất báo cáo tồn kho ra file Excel...');">
                            <i class="fa-solid fa-arrow-down-to-bracket text-xs text-slate-600"></i>
                            <span>Xuất Excel</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- ========================================================
                 6. VIEW TABS & WAREHOUSE FILTER
                 ======================================================== -->
            <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div class="flex items-center gap-2 overflow-x-auto pb-1 text-sm">
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=waste" 
                       class="inv-tab-btn ${viewTab == 'waste' ? 'active' : ''}">
                        <i class="fa-solid fa-trash-can text-rose-500 text-xs"></i>
                        <span>Hao hụt &amp; Tiêu hủy</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=alert" 
                       class="inv-tab-btn ${viewTab == 'alert' ? 'active' : ''}">
                        <i class="fa-solid fa-triangle-exclamation text-red-500 text-xs"></i>
                        <span>Cảnh báo khẩn & Tồn thấp</span>
                        <span class="px-1.5 py-0.2 rounded-full bg-red-100 text-red-600 text-[10px] font-black">${criticalStockCount}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=all" 
                       class="inv-tab-btn ${viewTab == 'all' ? 'active' : ''}">
                        <i class="fa-solid fa-boxes-stacked text-slate-500 text-xs"></i>
                        <span>Quản lý toàn bộ tồn kho</span>
                        <span class="text-slate-400 text-xs">${totalSkus}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/inventory?viewTab=freshness" 
                       class="inv-tab-btn ${viewTab == 'freshness' ? 'active' : ''}">
                        <i class="fa-regular fa-clock text-slate-500 text-xs"></i>
                        <span>Độ tươi & Ngày hái lô hàng</span>
                        <span class="px-1.5 py-0.2 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-black">12 LÔ</span>
                    </a>
                </div>

                <div class="flex items-center gap-2 text-xs">
                    <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">LỌC THEO:</span>
                    <a href="#" class="inv-filter-pill active">Tất cả kho lạnh</a>
                    <a href="#" class="inv-filter-pill">Kho hái sáng (06:00)</a>
                    <a href="#" class="inv-filter-pill">Kho hái chiều (14:00)</a>
                </div>
            </div>

                        <c:if test="${viewTab == 'waste'}">
                <div class="flex justify-end mb-4">
                    <button type="button" id="btnOpenManualWasteModal" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-sm cursor-pointer">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Báo Tiêu Hủy Nông Sản Kho</span>
                    </button>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${viewTab == 'waste'}">

                </c:when>
                <c:otherwise>
<!-- ========================================================
                 7. SEARCH & RISK TOOLBAR
                 ======================================================== -->
            <form action="${pageContext.request.contextPath}/shop/inventory" method="GET" class="bg-white p-3.5 rounded-2xl border border-slate-200/80 shadow-xs flex flex-col md:flex-row items-center gap-3">
                <input type="hidden" name="viewTab" value="${viewTab}">
                
                <div class="relative flex-1 w-full">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                    <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo mã SKU, tên trái cây (Dâu, Bơ, Nho,...), mã lô thu hoạch" class="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-800 focus:bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500/20">
                </div>

                <div class="w-full md:w-56">
                    <select name="riskLevel" class="filter-select-box !py-2 text-xs" onchange="this.form.submit()">
                        <option value="">Mức độ rủi ro: Tất cả</option>
                        <option value="critical" ${param.riskLevel == 'critical' ? 'selected' : ''}>Nguy cấp (&lt;= 5)</option>
                        <option value="warning" ${param.riskLevel == 'warning' ? 'selected' : ''}>Cảnh báo vàng</option>
                        <option value="safe" ${param.riskLevel == 'safe' ? 'selected' : ''}>An toàn</option>
                    </select>
                </div>

                <div class="w-full md:w-60">
                    <select name="sortBy" class="filter-select-box !py-2 text-xs" onchange="this.form.submit()">
                        <option value="stock_asc" ${sortBy == 'stock_asc' ? 'selected' : ''}>Sắp xếp: Tồn kho ít nhất trước ⇅</option>
                        <option value="stock_desc" ${sortBy == 'stock_desc' ? 'selected' : ''}>Sắp xếp: Tồn kho nhiều nhất trước</option>
                        <option value="freshness_desc" ${sortBy == 'freshness_desc' ? 'selected' : ''}>Sắp xếp: Độ tươi cao nhất trước</option>
                        <option value="freshness_asc" ${sortBy == 'freshness_asc' ? 'selected' : ''}>Sắp xếp: Độ tươi giảm dần</option>
                    </select>
                </div>
            </form>

            <!-- ========================================================
                 8. INVENTORY DATA TABLE
                 ======================================================== -->
            <div class="table-container-card">
                <div class="overflow-x-auto">
                    <table class="inventory-table">
                        <thead>
                            <tr>
                                <th class="min-w-[280px]">SẢN PHẨM & LÔ HÀNG</th>
                                <th class="min-w-[170px]">NGÀY HÁI TẠI VƯỜN</th>
                                <th class="min-w-[140px]">TỒN HIỆN TẠI</th>
                                <th class="min-w-[140px]">NGƯỠNG AN TOÀN</th>
                                <th class="min-w-[160px]">MỨC ĐỘ RỦI RO</th>
                                <th class="min-w-[140px]">ĐANG CHỜ ĐÓNG GÓI</th>
                                <th class="min-w-[150px] text-right">THAO TÁC NHANH</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty listItems}">
                                    <c:forEach var="item" items="${listItems}">
                                        <tr>
                                            <!-- SẢN PHẨM & LÔ HÀNG -->
                                            <td>
                                                <div class="flex items-center gap-3">
                                                    <div class="inv-thumb-wrapper">
                                                        <img src="${item.image}" alt="${item.productName}" class="inv-thumb-img" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                                                        <span class="inv-thumb-cert-badge">
                                                            ${not empty item.certification ? item.certification : 'BIO'}
                                                        </span>
                                                    </div>
                                                    <div class="flex flex-col min-w-0">
                                                        <div class="flex items-center gap-1.5 flex-wrap">
                                                            <span class="font-bold text-sm text-slate-900 truncate hover:text-emerald-700 transition-colors cursor-pointer">
                                                                ${item.productName}
                                                            </span>
                                                            <span class="px-1.5 py-0.2 rounded bg-orange-100 text-orange-700 text-[10px] font-black">
                                                                ${item.batchType}
                                                            </span>
                                                        </div>
                                                        <div class="flex items-center gap-2 font-mono text-[11px] text-slate-400 mt-0.5">
                                                            <span>SKU: ${item.sku}</span>
                                                            <span>•</span>
                                                            <span>Lô: ${item.batchCode}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- NGÀY HÁI TẠI VƯỜN -->
                                            <td>
                                                <div class="flex flex-col">
                                                    <span class="font-bold text-xs text-slate-900 leading-snug">
                                                        ${item.harvestTimeLabel}
                                                    </span>
                                                    <span class="text-[11px] text-slate-500 leading-snug mt-0.5">
                                                        ${item.freshnessNote}
                                                    </span>
                                                </div>
                                            </td>

                                            <!-- TỒN HIỆN TẠI -->
                                            <td>
                                                <div class="flex flex-col">
                                                    <div class="flex items-baseline gap-1 text-xs">
                                                        <span class="font-black text-sm ${item.stockNumberColor}">
                                                            ${item.currentQuantity}
                                                        </span>
                                                        <span class="text-slate-400 font-semibold">
                                                            / ${item.initialQuantity} ${item.unit}
                                                        </span>
                                                    </div>
                                                    <div class="stock-progress-track max-w-[110px]">
                                                        <div class="stock-progress-fill ${item.progressBarColor}" style="width: ${item.stockProgressPercent}%;"></div>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- NGƯỠNG AN TOÀN -->
                                            <td>
                                                <div class="safety-threshold-box">
                                                    Tối thiểu ${item.lowStockThreshold} ${item.unit}
                                                </div>
                                            </td>

                                            <!-- MỨC ĐỘ RỦI RO -->
                                            <td>
                                                <span class="risk-pill ${item.riskBadgeClass}">
                                                    ${item.riskText}
                                                </span>
                                            </td>

                                            <!-- ĐANG CHỜ ĐÓNG GÓI -->
                                            <td>
                                                <div class="flex items-center gap-1.5 text-xs font-semibold text-slate-700">
                                                    <i class="fa-regular fa-calendar-check text-slate-400 text-sm"></i>
                                                    <span>${item.pendingPackingText}</span>
                                                </div>
                                            </td>

                                            <!-- THAO TÁC NHANH -->
                                            <td class="text-right">
                                                <div class="flex items-center justify-end gap-1.5">
                                                    <c:choose>
                                                        <c:when test="${item.riskLevel == 'CRITICAL'}">
                                                            <button type="button" onclick="quickRestockItem(${item.variantId}, '${item.productName}', '${item.unit}')" class="btn-table-restock">
                                                                <i class="fa-solid fa-plus-circle text-xs"></i>
                                                                <span>Nhập kho</span>
                                                            </button>
                                                            <form action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="inline">
                                                                <input type="hidden" name="action" value="toggle">
                                                                <input type="hidden" name="variantId" value="${item.variantId}">
                                                                <button type="submit" class="btn-table-icon" title="Ẩn tạm thời">
                                                                    <i class="fa-regular fa-eye-slash text-xs"></i>
                                                                </button>
                                                            </form>
                                                        </c:when>
                                                        <c:when test="${item.riskLevel == 'WARNING'}">
                                                            <button type="button" onclick="quickDiscountItem(${item.variantId}, '${item.productName}')" class="btn-table-discount">
                                                                <i class="fa-solid fa-bolt text-xs"></i>
                                                                <span>Xả tươi -15%</span>
                                                            </button>
                                                            <a href="${pageContext.request.contextPath}/shop/product/edit?id=${item.variantId}" class="btn-table-icon" title="Chi tiết">
                                                                <i class="fa-regular fa-circle-question text-xs"></i>
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" onclick="quickRestockItem(${item.variantId}, '${item.productName}', '${item.unit}')" class="btn-table-edit">
                                                                <i class="fa-solid fa-pen text-xs"></i>
                                                                <span>Cập nhật</span>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="py-16 text-center text-slate-400">
                                            <i class="fa-solid fa-boxes-stacked text-3xl mb-2 text-slate-300 block"></i>
                                            <span class="text-sm font-semibold">Tất cả mặt hàng đang trong ngưỡng an toàn tuyệt đối.</span>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Table Footer & Pagination -->
                <div class="table-pagination-footer">
                    <div class="text-xs text-slate-500">
                        Hiển thị <strong class="text-slate-800">${not empty listItems ? listItems.size() : 0}</strong> trên <strong class="text-slate-800">${totalCount}</strong> mặt hàng nông sản • <span class="text-emerald-700 font-semibold">Tự động đồng bộ với cảm biến kho lạnh Đà Lạt</span>
                    </div>

                    <div class="flex items-center gap-1.5">
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/shop/inventory?page=${currentPage - 1}&pageSize=${pageSize}&keyword=${param.keyword}&riskLevel=${param.riskLevel}&sortBy=${sortBy}&viewTab=${viewTab}" class="page-num-btn">
                                <i class="fa-solid fa-chevron-left text-[11px]"></i>
                            </a>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="p">
                            <a href="${pageContext.request.contextPath}/shop/inventory?page=${p}&pageSize=${pageSize}&keyword=${param.keyword}&riskLevel=${param.riskLevel}&sortBy=${sortBy}&viewTab=${viewTab}" class="page-num-btn ${p == currentPage ? 'active' : ''}">
                                ${p}
                            </a>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/shop/inventory?page=${currentPage + 1}&pageSize=${pageSize}&keyword=${param.keyword}&riskLevel=${param.riskLevel}&sortBy=${sortBy}&viewTab=${viewTab}" class="page-num-btn">
                                <i class="fa-solid fa-chevron-right text-[11px]"></i>
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- ========================================================
                 9. BOTTOM TWO SENSOR & SCHEDULE WIDGETS
                 ======================================================== -->
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-5 mt-2">
                <!-- Widget 1: Cảm Biến Kho Lạnh Lô Hái -->
                <div class="lg:col-span-5 sensor-card-widget">
                    <div class="flex items-start justify-between pb-3 border-b border-slate-100">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center shrink-0">
                                <i class="fa-solid fa-temperature-arrow-down text-lg"></i>
                            </div>
                            <div>
                                <h4 class="font-extrabold text-sm text-slate-900 leading-tight">Cảm Biến Kho Lạnh Lô Hái</h4>
                                <span class="text-xs text-slate-500 leading-tight block mt-0.5">Khu vực phân loại đóng gói Vườn 01</span>
                            </div>
                        </div>
                        <span class="px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-extrabold text-[10px] flex items-center gap-1.5 uppercase">
                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse"></span> Tối ưu
                        </span>
                    </div>

                    <div class="grid grid-cols-2 gap-4 mt-4">
                        <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-100">
                            <span class="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">NHIỆT ĐỘ HIỆN TẠI</span>
                            <div class="flex items-baseline gap-1.5 mt-1">
                                <span class="text-2xl font-black text-slate-900">5.2°C</span>
                                <span class="text-xs font-bold text-emerald-600 bg-emerald-50 px-1 py-0.2 rounded">±0.3</span>
                            </div>
                            <span class="text-[11px] text-slate-400 block mt-1">Ngưỡng chuẩn: 4°C - 8°C</span>
                        </div>

                        <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-100">
                            <span class="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block">ĐỘ ẨM KHÔNG KHÍ</span>
                            <div class="flex items-baseline gap-1.5 mt-1">
                                <span class="text-2xl font-black text-slate-900">88%</span>
                                <span class="text-xs font-bold text-slate-600">Ẩm dịu</span>
                            </div>
                            <span class="text-[11px] text-slate-400 block mt-1">Giữ lớp phấn tự nhiên</span>
                        </div>
                    </div>
                </div>

                <!-- Widget 2: Lịch Trình Hái Bổ Sung Trong Ngày -->
                <div class="lg:col-span-7 sensor-card-widget">
                    <div class="flex items-start justify-between pb-3 border-b border-slate-100">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-emerald-800 text-white flex items-center justify-center shrink-0">
                                <i class="fa-solid fa-leaf text-base"></i>
                            </div>
                            <div>
                                <h4 class="font-extrabold text-sm text-slate-900 leading-tight">Lịch Trình Hái Bổ Sung Trong Ngày</h4>
                                <span class="text-xs text-slate-500 leading-tight block mt-0.5">Đội ngũ thu hái trực tiếp từ đồi thông & nhà màng</span>
                            </div>
                        </div>
                        <a href="#" class="text-xs font-bold text-emerald-700 hover:text-emerald-800 underline">
                            Xem toàn bộ lịch hái
                        </a>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-4">
                        <!-- Card 1 -->
                        <div class="schedule-item-card">
                            <div class="flex items-center justify-between">
                                <span class="font-bold text-xs text-slate-900">Dâu Tây Tochi</span>
                                <span class="px-1.5 py-0.2 rounded bg-pink-100 text-pink-700 text-[10px] font-bold">Đang hái</span>
                            </div>
                            <div class="mt-2 text-xs text-slate-600">
                                Dự kiến nhập: <strong class="text-slate-900">35 hộp</strong> lúc 11:30
                            </div>
                            <div class="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden mt-3">
                                <div class="bg-orange-500 h-full rounded-full" style="width: 65%;"></div>
                            </div>
                        </div>

                        <!-- Card 2 -->
                        <div class="schedule-item-card">
                            <div class="flex items-center justify-between">
                                <span class="font-bold text-xs text-slate-900">Nho Hạ Đen</span>
                                <span class="px-1.5 py-0.2 rounded bg-orange-100 text-orange-700 text-[10px] font-bold">Đóng giỏ</span>
                            </div>
                            <div class="mt-2 text-xs text-slate-600">
                                Dự kiến nhập: <strong class="text-slate-900">50 chùm</strong> lúc 14:00
                            </div>
                            <div class="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden mt-3">
                                <div class="bg-red-700 h-full rounded-full" style="width: 40%;"></div>
                            </div>
                        </div>

                        <!-- Card 3 -->
                        <div class="schedule-item-card">
                            <div class="flex items-center justify-between">
                                <span class="font-bold text-xs text-slate-900">Bơ Sáp 034</span>
                                <span class="px-1.5 py-0.2 rounded bg-slate-200 text-slate-700 text-[10px] font-bold">Chờ hái chiều</span>
                            </div>
                            <div class="mt-2 text-xs text-slate-600">
                                Dự kiến nhập: <strong class="text-slate-900">120 kg</strong> lúc 16:30
                            </div>
                            <div class="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden mt-3">
                                <div class="bg-slate-400 h-full rounded-full" style="width: 15%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    
                </c:otherwise>
            </c:choose>
</main>

    <!-- ========================================================
         MODAL: NHẬP KHO NHANH (RESTOCK)
         ======================================================== -->
    <div id="restockModal" class="modal-overlay hidden">
        <div class="modal-box">
            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                <div class="flex items-center gap-2 text-slate-900">
                    <i class="fa-solid fa-boxes-packing text-emerald-700 text-base"></i>
                    <h3 class="font-black text-base">Nhập Kho Nhanh Nông Sản (Restock)</h3>
                </div>
                <button onclick="closeRestockModal()" class="text-slate-400 hover:text-slate-600 text-lg">&times;</button>
            </div>
            
            <form action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="mt-4 space-y-4">
                <input type="hidden" name="action" value="restock">
                
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Mặt hàng cần nhập thêm</label>
                    <select id="modalVariantSelect" name="variantId" class="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-emerald-500">
                        <c:forEach var="item" items="${listItems}">
                            <option value="${item.variantId}">${item.productName} (${item.sku}) - Hiện còn: ${item.currentQuantity} ${item.unit}</option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Số lượng thu hoạch bổ sung</label>
                    <div class="flex items-center gap-2">
                        <input type="number" name="quantity" min="1" max="1000" value="20" required class="flex-1 p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold focus:outline-none focus:ring-2 focus:ring-emerald-500">
                        <span id="modalUnitLabel" class="text-xs font-bold text-slate-500">đơn vị</span>
                    </div>
                </div>

                <div class="p-3 bg-emerald-50 border border-emerald-100 rounded-xl text-[11px] text-emerald-800 flex items-start gap-2">
                    <i class="fa-solid fa-circle-info text-emerald-600 mt-0.5"></i>
                    <span>Số lượng nhập mới sẽ tự động cập nhật vào đợt hái trong ngày và giải tỏa cảnh báo nguy cấp.</span>
                </div>

                <div class="flex items-center justify-end gap-2 pt-2">
                    <button type="button" onclick="closeRestockModal()" class="px-4 py-2 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Hủy</button>
                    <button type="submit" class="px-5 py-2 rounded-xl bg-[#166534] text-white text-xs font-bold hover:bg-[#14532d] shadow-sm">Xác nhận nhập kho</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ========================================================
         MODAL: XẢ TƯƠI CHIẾT KHẤU
         ======================================================== -->
    <div id="discountModal" class="modal-overlay hidden">
        <div class="modal-box">
            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                <div class="flex items-center gap-2 text-slate-900">
                    <i class="fa-solid fa-bolt text-orange-600 text-base"></i>
                    <h3 class="font-black text-base">Đề Xuất Xả Tươi Nông Sản</h3>
                </div>
                <button onclick="closeDiscountModal()" class="text-slate-400 hover:text-slate-600 text-lg">&times;</button>
            </div>
            
            <form action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="mt-4 space-y-4">
                <input type="hidden" name="action" value="discount">
                <input type="hidden" id="discountVariantId" name="variantId" value="">
                
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Mặt hàng áp dụng xả tươi</label>
                    <input type="text" id="discountProductName" readonly class="w-full p-2.5 bg-slate-100 border border-slate-200 rounded-xl text-xs font-bold text-slate-800">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">Mức giảm giá trực tiếp (%)</label>
                    <select name="discountPercent" class="w-full p-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-orange-700">
                        <option value="10">Giảm 10% (Ưu tiên xả trong 12h)</option>
                        <option value="15" selected>Giảm 15% (Đề xuất tối ưu cho quả 50h tuổi)</option>
                        <option value="20">Giảm 20% (Xả gấp thu hồi vốn)</option>
                    </select>
                </div>

                <div class="flex items-center justify-end gap-2 pt-2">
                    <button type="button" onclick="closeDiscountModal()" class="px-4 py-2 rounded-xl border border-slate-200 text-xs font-bold text-slate-600 hover:bg-slate-50">Hủy</button>
                    <button type="submit" class="px-5 py-2 rounded-xl bg-[#ea580c] text-white text-xs font-bold hover:bg-[#c2410c] shadow-sm">Áp dụng giảm giá</button>
                </div>
            </form>
        </div>
    </div>

    <!-- JavaScript Handlers -->
    <script>
        function openRestockModal() {
            document.getElementById('restockModal').classList.remove('hidden');
        }
        function closeRestockModal() {
            document.getElementById('restockModal').classList.add('hidden');
        }
        function quickRestockItem(variantId, name, unit) {
            const select = document.getElementById('modalVariantSelect');
            if (select) select.value = variantId;
            const unitLabel = document.getElementById('modalUnitLabel');
            if (unitLabel && unit) unitLabel.textContent = unit;
            openRestockModal();
        }

        function openDiscountModal() {
            document.getElementById('discountModal').classList.remove('hidden');
        }
        function closeDiscountModal() {
            document.getElementById('discountModal').classList.add('hidden');
        }
        function quickDiscountItem(variantId, name) {
            document.getElementById('discountVariantId').value = variantId;
            document.getElementById('discountProductName').value = name;
            openDiscountModal();
        }

        // Auto hide flash message after 4s
        setTimeout(function() {
            const f = document.getElementById('flashMsg');
            if (f) f.remove();
        }, 4000);
    </script>

    <!-- Modal Báo Tiêu Hủy Nông Sản -->
<div id="wasteModalBackdrop" class="waste-modal-backdrop">
            <div class="waste-modal-dialog">
                <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                    <div class="flex items-center gap-2.5">
                        <div class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-sm font-bold border border-rose-200">
                            <i class="fa-solid fa-trash-can"></i>
                        </div>
                        <div>
                            <h3 class="text-sm font-black text-slate-900">Báo Tiêu Hủy Nông Sản Kho Lạnh</h3>
                            <p class="text-[10px] text-slate-400">Trừ trực tiếp số lượng tồn kho và ghi nhận chi phí hao hụt</p>
                        </div>
                    </div>
                    <button type="button" id="btnCloseManualWasteModal" class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                        <i class="fa-solid fa-xmark text-sm"></i>
                    </button>
                </div>

                <form id="formManualWaste" action="${pageContext.request.contextPath}/shop/inventory" method="POST" class="p-5 space-y-4">
                    <input type="hidden" name="action" value="manual_waste">

                    <div>
                        <label for="selectVariantWaste" class="block text-xs font-bold text-slate-700 mb-1.5">
                            1. Chọn nông sản / biến thể cần tiêu hủy: <span class="text-rose-500">*</span>
                        </label>
                        <select name="variantId" id="selectVariantWaste" required class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-medium">
                            <option value="">-- Chọn một sản phẩm trong kho --</option>
                            <c:forEach items="${variants}" var="v">
                                <option value="${v.variantId}" data-stock="${v.stockQuantity}" data-unit="${v.unit}" data-price="${v.price}">
                                    ${v.productName} - ${v.variantName} [Tồn kho: ${v.stockQuantity} ${v.unit}]
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <label for="inputWasteQuantity" class="block text-xs font-bold text-slate-700 mb-1.5">
                                2. Số lượng tiêu hủy: <span class="text-rose-500">*</span>
                            </label>
                            <div class="relative">
                                <input type="number" name="quantity" id="inputWasteQuantity" min="1" required placeholder="0" class="w-full p-2.5 text-xs rounded-xl border border-slate-300 bg-white focus:outline-none focus:border-rose-500 font-bold text-rose-600">
                                <span id="textUnitLabel" class="absolute right-3 top-2.5 text-xs font-bold text-slate-400">kg</span>
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-bold text-slate-700 mb-1.5">Tồn kho khả dụng:</label>
                            <div class="p-2.5 rounded-xl bg-slate-50 border border-slate-200 text-xs font-black text-slate-800 flex items-center justify-between">
                                <span id="textAvailableStock">0</span>
                                <span class="text-[11px] font-normal text-slate-400">trong kho</span>
                            </div>
                        </div>
                    </div>
    <script src="${pageContext.request.contextPath}/assets/js/shop-inventory.js"></script>

</body>
</html>

