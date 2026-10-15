<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Kho & Nông Sản - Kênh Người Bán</title>
    
    <!-- Google Fonts & Font Awesome 6 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Custom CSS matching mockup -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-products.css">
</head>
<body class="bg-[#f1f5f9] text-slate-800 font-['Plus_Jakarta_Sans',sans-serif] min-h-screen flex m-0">

    <!-- ========================================================
         1. SIDEBAR NAVIGATION (KÊNH NGƯỜI BÁN) - CỐ ĐỊNH BÊN TRÁI
         ======================================================== -->
    <aside class="w-64 shrink-0 bg-white border-r border-slate-200 h-screen sticky top-0 flex flex-col justify-between z-30 overflow-y-auto shadow-xs">
        <div>
            <!-- Shop Brand Header -->
            <div class="flex items-center justify-between p-3.5 bg-slate-50 rounded-2xl border border-slate-100 shadow-2xs mx-3 mt-3">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 rounded-full overflow-hidden shrink-0 border-2 border-emerald-500 shadow-xs">
                        <c:choose>
                            <c:when test="${not empty shopLogo}">
                                <img src="${shopLogo}" alt="Shop Avatar" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" alt="Default Avatar" class="w-full h-full object-cover">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div>
                        <h4 class="text-xs font-extrabold text-slate-900 leading-tight">HTX Trái Cây Miền Tây</h4>
                        <p class="text-[10px] font-bold text-emerald-700 tracking-wider mt-0.5">SELLER CENTER</p>
                    </div>
                </div>
                <div>
                    <span class="px-2 py-0.5 text-[10px] font-black text-emerald-800 bg-emerald-100 rounded-md tracking-wider">
                        PRO
                    </span>
                </div>
            </div>

            <!-- Sidebar Navigation Groups -->
            <nav class="space-y-1.5 px-3 mt-4">
                <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 font-extrabold">TỔNG QUAN</div>
                <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-chart-pie text-slate-400 text-sm w-4 text-center"></i>
                        <span>Tổng quan Shop</span>
                    </span>
                </a>

                <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">SẢN PHẨM & KHO</div>
                <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center justify-between px-3 py-2.5 rounded-xl bg-emerald-50 text-emerald-800 font-bold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-seedling text-emerald-600 text-sm w-4 text-center"></i>
                        <span>Tất cả sản phẩm</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/product/add" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-circle-plus text-slate-400 text-sm w-4 text-center"></i>
                        <span>Thêm mới nông sản</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/inventory" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-warehouse text-slate-400 text-sm w-4 text-center"></i>
                        <span>Kho & Cảnh báo tồn</span>
                    </span>
                    <span class="px-2 py-0.5 bg-rose-100 text-rose-700 text-[10px] font-bold rounded-full">${not empty lowStockCount ? lowStockCount : 3}</span>
                </a>

                <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">ĐƠN HÀNG</div>
                <a href="${pageContext.request.contextPath}/shop/orders" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-receipt text-slate-400 text-sm w-4 text-center"></i>
                        <span>Đơn hàng con</span>
                    </span>
                    <span class="px-2 py-0.5 bg-amber-100 text-amber-800 text-[10px] font-bold rounded-full">8</span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/shipping" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-truck-ramp-box text-slate-400 text-sm w-4 text-center"></i>
                        <span>Đóng gói & Vận đơn</span>
                    </span>
                </a>

                <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">TIẾP THỊ & KHÁCH</div>
                <a href="${pageContext.request.contextPath}/shop/coupons" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-tags text-slate-400 text-sm w-4 text-center"></i>
                        <span>Mã giảm giá Shop</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/reviews" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-star-half-stroke text-slate-400 text-sm w-4 text-center"></i>
                        <span>Đánh giá từ khách</span>
                    </span>
                </a>

                <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">HỆ THỐNG</div>
                <a href="${pageContext.request.contextPath}/shop/finance" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-wallet text-slate-400 text-sm w-4 text-center"></i>
                        <span>Doanh thu & Rút tiền</span>
                    </span>
                </a>
                <a href="${pageContext.request.contextPath}/shop/settings" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                    <span class="flex items-center gap-3">
                        <i class="fa-solid fa-sliders text-slate-400 text-sm w-4 text-center"></i>
                        <span>Cài đặt Shop</span>
                    </span>
                </a>
            </nav>
        </div>

        <div class="p-3 border-t border-slate-100 space-y-1">
            <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-3 px-3 py-2 rounded-xl text-slate-600 hover:text-emerald-700 font-semibold text-xs transition-all">
                <i class="fa-solid fa-store text-xs w-4 text-center"></i>
                <span>Xem trang mua sắm</span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-3 py-2 rounded-xl text-rose-600 hover:bg-rose-50 hover:text-rose-700 font-semibold text-xs transition-all">
                <i class="fa-solid fa-power-off text-xs w-4 text-center"></i>
                <span>Đăng xuất</span>
            </a>
        </div>
    </aside>

    <!-- ========================================================
         2 & 3. KHUNG BÊN PHẢI (HEADER + MAIN CONTENT)
         ======================================================== -->
    <div class="flex-1 min-w-0 flex flex-col">
        
        <!-- TOP HEADER NAVBAR -->
        <header class="bg-white border-b border-slate-200 px-6 py-3 flex items-center justify-between sticky top-0 z-20 shadow-2xs">
            <div class="relative w-96">
                <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
                <form action="${pageContext.request.contextPath}/shop/products" method="GET">
                    <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm nhanh theo SKU, tên nông sản..." class="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                </form>
            </div>

            <div class="flex items-center gap-4">
                <div class="flex items-center gap-2 px-3 py-1.5 bg-emerald-50 text-emerald-700 rounded-full text-xs font-bold border border-emerald-200">
                    <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                    <span>Đang nhận đơn</span>
                </div>

                <button class="w-9 h-9 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-600 hover:bg-emerald-50 hover:text-emerald-700 transition-all" type="button" title="Tin nhắn">
                    <i class="fa-regular fa-comment-dots text-sm"></i>
                </button>

                <button class="w-9 h-9 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-600 hover:bg-emerald-50 hover:text-emerald-700 relative transition-all" type="button" title="Thông báo">
                    <i class="fa-regular fa-bell text-sm"></i>
                    <span class="absolute -top-1 -right-1 w-4 h-4 bg-rose-500 text-white text-[9px] font-bold rounded-full flex items-center justify-center shadow-xs">5</span>
                </button>

                <div class="flex items-center gap-3 pl-3 border-l border-slate-200">
                    <div class="text-right hidden sm:block">
                        <span class="text-xs font-black text-slate-900 block leading-tight">
                            ${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Trần Hoàng Anh'}
                        </span>
                        <span class="text-[10px] text-slate-400 font-medium block leading-tight">${sessionScope.email}</span>
                    </div>
                    <div class="w-9 h-9 rounded-xl bg-emerald-700 text-white flex items-center justify-center font-bold text-sm shrink-0 shadow-sm overflow-hidden">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.avatarUrl}">
                                <img src="${sessionScope.user.avatarUrl}" alt="Avatar" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <span class="text-xs font-extrabold">THA</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </header>

        <!-- MAIN CONTENT -->
        <main class="p-6 flex-1 overflow-y-auto">
            <div class="max-w-7xl mx-auto space-y-6">

                <!-- Success Notification Alert -->
                <c:if test="${not empty sessionScope.successMessage}">
                    <div class="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-3 rounded-2xl flex items-center justify-between shadow-xs">
                        <div class="flex items-center gap-3">
                            <i class="fa-solid fa-circle-check text-emerald-600 text-base"></i>
                            <span class="text-xs font-bold">${sessionScope.successMessage}</span>
                        </div>
                        <button type="button" onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-900">
                            <i class="fa-solid fa-xmark text-sm"></i>
                        </button>
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>

                <!-- Breadcrumb & Header Title -->
                <div class="flex flex-col gap-3">
                    <nav class="flex items-center gap-2 text-xs text-slate-400 font-semibold">
                        <span>Kênh Người Bán</span>
                        <i class="fa-solid fa-chevron-right text-[9px] text-slate-300"></i>
                        <span>Sản phẩm & Kho</span>
                        <i class="fa-solid fa-chevron-right text-[9px] text-slate-300"></i>
                        <span class="text-slate-800 font-bold">Tất cả sản phẩm</span>
                    </nav>

                    <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
                        <div>
                            <div class="flex items-center flex-wrap gap-3">
                                <h1 class="text-2xl font-black text-slate-900 tracking-tight">Danh Sách Sản Phẩm Nông Sản</h1>
                                <span class="px-3 py-1 bg-emerald-100 text-emerald-800 rounded-full text-xs font-extrabold flex items-center gap-2 shadow-2xs">
                                    <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
                                    ${not empty totalProducts && totalProducts > 0 ? totalProducts : 42} SẢN PHẨM / ${not empty totalSKU && totalSKU > 0 ? totalSKU : 115} SKUS
                                </span>
                            </div>
                            <p class="text-xs text-slate-500 font-medium mt-1">
                                Hệ thống quản lý biến thể, định danh mã SKU, kiểm soát tồn kho và chứng nhận chất lượng VietGAP/OCOP.
                            </p>
                        </div>

                        <!-- Action buttons -->
                        <div class="flex items-center flex-wrap gap-2.5">
                            <button type="button" class="px-4 py-2 bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xs transition-all" onclick="alert('Đang xuất dữ liệu danh sách nông sản ra file Excel (.xlsx)...');">
                                <i class="fa-solid fa-file-excel text-emerald-600"></i>
                                <span>Xuất Excel</span>
                            </button>
                            <button type="button" class="px-4 py-2 bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xs transition-all" onclick="alert('Hệ thống đang đồng bộ bảng giá loạt...');">
                                <i class="fa-solid fa-arrows-rotate text-purple-600"></i>
                                <span>Đồng bộ giá loạt</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/shop/product/add" class="px-4 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm transition-all">
                                <i class="fa-solid fa-circle-plus text-sm"></i>
                                <span>Thêm mới nông sản</span>
                            </a>
                        </div>
                    </div>
                </div>

                <!-- STATUS TABS -->
                <div class="flex items-center gap-2 overflow-x-auto pb-2 text-xs">
                    <a href="${pageContext.request.contextPath}/shop/products?statusTab=all" 
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${empty statusTab || statusTab == 'all' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Tất cả</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] ${empty statusTab || statusTab == 'all' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabAllCount && tabAllCount > 0 ? tabAllCount : 42}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/products?statusTab=active" 
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'active' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Đang mở bán</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] ${statusTab == 'active' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabActiveCount && tabActiveCount > 0 ? tabActiveCount : 38}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/products?statusTab=vietgap" 
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'vietgap' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Chờ duyệt VietGAP</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] bg-orange-100 text-orange-700">${not empty tabVietgapCount && tabVietgapCount > 0 ? tabVietgapCount : 2}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/products?statusTab=hidden" 
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'hidden' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Hết hàng / Tạm ẩn</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] bg-rose-100 text-rose-700">${not empty tabHiddenCount && tabHiddenCount > 0 ? tabHiddenCount : 2}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/products?statusTab=warning" 
                       class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'warning' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                        <span>Vi phạm / Cảnh báo</span>
                        <span class="px-2 py-0.5 rounded-md text-[10px] bg-slate-100 text-slate-600">${not empty tabWarningCount ? tabWarningCount : 0}</span>
                    </a>
                </div>

                <!-- SEARCH & FILTER TOOLBAR -->
                <form action="${pageContext.request.contextPath}/shop/products" method="GET" class="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs space-y-4">
                    <input type="hidden" name="statusTab" value="${statusTab}">
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-12 gap-3 items-center">
                        <div class="xl:col-span-5 relative">
                            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                            <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên trái cây, mã SKU, mã lô nông sản..." class="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                        </div>

                        <div class="xl:col-span-3">
                            <select name="categoryId" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                <option value="">Tất cả danh mục quả</option>
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.categoryId}" ${param.categoryId == c.categoryId ? 'selected' : ''}>
                                        ${c.categoryName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="xl:col-span-2">
                            <select name="certification" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                <option value="">Chứng nhận: Tất cả</option>
                                <option value="VietGAP" ${param.certification == 'VietGAP' ? 'selected' : ''}>VietGAP</option>
                                <option value="OCOP" ${param.certification == 'OCOP' ? 'selected' : ''}>OCOP</option>
                                <option value="GlobalGAP" ${param.certification == 'GlobalGAP' ? 'selected' : ''}>GlobalGAP</option>
                                <option value="Organic" ${param.certification == 'Organic' ? 'selected' : ''}>Organic</option>
                            </select>
                        </div>

                        <div class="xl:col-span-2">
                            <select name="stockLevel" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                <option value="">Tồn kho: Tất cả</option>
                                <option value="critical" ${param.stockLevel == 'critical' ? 'selected' : ''}>Tồn &lt; 5 đơn vị</option>
                                <option value="low" ${param.stockLevel == 'low' ? 'selected' : ''}>Sắp hết (&lt;= 15)</option>
                                <option value="stable" ${param.stockLevel == 'stable' ? 'selected' : ''}>Ổn định (16 - 40)</option>
                                <option value="abundant" ${param.stockLevel == 'abundant' ? 'selected' : ''}>Dồi dào (&gt; 40)</option>
                            </select>
                        </div>
                    </div>

                    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-3 border-t border-slate-100 text-xs">
                        <div class="flex items-center flex-wrap gap-2">
                            <span class="font-black text-[10px] uppercase tracking-wider text-slate-400 mr-1">LỌC NHANH:</span>
                            
                            <a href="${pageContext.request.contextPath}/shop/products?stockLevel=critical" 
                               class="px-3 py-1.5 rounded-xl border border-slate-200 font-semibold text-slate-600 hover:border-emerald-500 hover:text-emerald-700 flex items-center gap-1.5 transition-all ${param.stockLevel == 'critical' ? 'bg-emerald-50 border-emerald-500 text-emerald-800' : 'bg-slate-50'}">
                                <i class="fa-solid fa-circle-exclamation text-rose-500 text-[10px]"></i> Tồn &lt; 5 đơn vị
                            </a>
                            
                            <a href="${pageContext.request.contextPath}/shop/products?certification=VietGAP" 
                               class="px-3 py-1.5 rounded-xl border border-slate-200 font-semibold text-slate-600 hover:border-emerald-500 hover:text-emerald-700 flex items-center gap-1.5 transition-all ${param.certification == 'VietGAP' ? 'bg-emerald-50 border-emerald-500 text-emerald-800' : 'bg-slate-50'}">
                                <i class="fa-solid fa-shield-check text-emerald-600 text-[10px]"></i> Chuẩn VietGAP 2024
                            </a>

                            <a href="${pageContext.request.contextPath}/shop/products?certification=OCOP" 
                               class="px-3 py-1.5 rounded-xl border border-slate-200 font-semibold text-slate-600 hover:border-emerald-500 hover:text-emerald-700 flex items-center gap-1.5 transition-all ${param.certification == 'OCOP' ? 'bg-emerald-50 border-emerald-500 text-emerald-800' : 'bg-slate-50'}">
                                <i class="fa-solid fa-award text-amber-500 text-[10px]"></i> OCOP 4 Sao Tỉnh
                            </a>

                            <a href="${pageContext.request.contextPath}/shop/products" class="text-slate-400 hover:text-rose-600 font-bold ml-2 underline">
                                Xóa bộ lọc
                            </a>
                        </div>

                        <div class="text-slate-500 font-bold">
                            Đang hiển thị: <span class="text-slate-900">${not empty listVariants ? listVariants.size() : 0}</span> / tổng <span class="text-slate-900">${not empty totalVariantsCount ? totalVariantsCount : (not empty listVariants ? listVariants.size() : 0)}</span> nông sản
                        </div>
                    </div>
                </form>

                <!-- DATA TABLE -->
                <div class="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50/75 border-b border-slate-200 text-[11px] font-black tracking-wider text-slate-500 uppercase">
                                    <th class="w-12 text-center py-3.5 px-4">
                                        <input type="checkbox" id="selectAllCheckbox" class="w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                                    </th>
                                    <th class="py-3.5 px-4 min-w-[280px]">SẢN PHẨM & PHÂN LOẠI</th>
                                    <th class="py-3.5 px-4 min-w-[170px]">QUY CÁCH ĐÓNG GÓI</th>
                                    <th class="py-3.5 px-4 min-w-[140px]">GIÁ BÁN LẺ</th>
                                    <th class="py-3.5 px-4 min-w-[190px]">TỒN KHO THỰC TẾ</th>
                                    <th class="py-3.5 px-4 min-w-[170px] text-right">CHỨNG NHẬN / THAO TÁC</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 text-xs">
                                <c:choose>
                                    <c:when test="${not empty listVariants}">
                                        <c:forEach var="v" items="${listVariants}">
                                            <tr class="hover:bg-slate-50/80 transition-colors">
                                                <!-- Checkbox -->
                                                <td class="text-center py-4 px-4">
                                                    <input type="checkbox" name="variantIds" value="${v.variantId}" class="variant-row-checkbox w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                                                </td>

                                                <!-- SẢN PHẨM & PHÂN LOẠI -->
                                                <td class="py-4 px-4">
                                                    <div class="flex items-center gap-3.5">
                                                        <img src="${v.image}" alt="${v.productName}" class="w-12 h-12 rounded-xl object-cover border border-slate-200 shadow-2xs shrink-0" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                                                        <div class="flex flex-col min-w-0">
                                                            <span class="font-extrabold text-sm text-slate-900 truncate leading-snug hover:text-emerald-700 transition-colors cursor-pointer">
                                                                ${v.productName}
                                                            </span>
                                                            <span class="text-xs text-slate-500 font-medium truncate leading-snug mt-0.5">
                                                                ${not empty v.categoryName ? v.categoryName : 'Trái Cây Tươi'}
                                                            </span>
                                                            <span class="font-mono text-[10px] text-slate-400 font-bold mt-1">
                                                                SKU: ${v.sku}
                                                            </span>
                                                        </div>
                                                    </div>
                                                </td>

                                                <!-- QUY CÁCH ĐÓNG GÓI -->
                                                <td class="py-4 px-4">
                                                    <div class="flex flex-col items-start gap-1">
                                                        <span class="font-bold text-slate-800">
                                                            ${v.variantName}
                                                        </span>
                                                        <c:choose>
                                                            <c:when test="${v.totalVariantsCount > 1}">
                                                                <span class="px-2.5 py-0.5 rounded-lg bg-indigo-50 text-indigo-700 text-[10px] font-black border border-indigo-100">
                                                                    ${v.totalVariantsCount} Biến thể (+${v.unit})
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="px-2 py-0.5 rounded-lg bg-slate-100 text-slate-600 text-[10px] font-bold">
                                                                    1 Biến thể duy nhất
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>

                                                <!-- GIÁ BÁN LẺ -->
                                                <td class="py-4 px-4">
                                                    <div class="flex flex-col">
                                                        <span class="font-black text-sm text-emerald-800">
                                                            ₫${v.formattedPrice}
                                                        </span>
                                                        <c:choose>
                                                            <c:when test="${v.originalPrice > v.price}">
                                                                <span class="line-through text-[11px] text-slate-400 font-medium mt-0.5">
                                                                    ₫${v.formattedOriginalPrice}
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-[10px] text-slate-400 font-bold mt-0.5">
                                                                    / ${not empty v.unit ? v.unit : 'tiêu chuẩn'}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>

                                                <!-- TỒN KHO THỰC TẾ -->
                                                <td class="py-4 px-4">
                                                    <div class="flex flex-col space-y-1.5">
                                                        <div class="flex items-center justify-between gap-2">
                                                            <c:choose>
                                                                <c:when test="${v.stockQuantity <= 5}">
                                                                    <span class="text-xs font-black text-rose-600 flex items-center gap-1.5">
                                                                        <i class="fa-solid fa-triangle-exclamation text-rose-500 text-xs"></i> ${v.stockQuantity} ${v.unit}
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${v.stockQuantity <= 15}">
                                                                    <span class="text-xs font-black text-amber-600 flex items-center gap-1.5">
                                                                        <i class="fa-solid fa-triangle-exclamation text-amber-500 text-xs"></i> ${v.stockQuantity} ${v.unit}
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-xs font-black text-emerald-700 flex items-center gap-1.5">
                                                                        <i class="fa-solid fa-circle-check text-emerald-600 text-xs"></i> ${v.stockQuantity} ${v.unit}
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <span class="text-[10px] text-slate-400 font-bold">
                                                                ${v.stockStatusText}
                                                            </span>
                                                        </div>
                                                        <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden border border-slate-200/50">
                                                            <div class="h-full rounded-full ${v.stockBarColor}" style="width: ${v.stockProgressPercent}%;"></div>
                                                        </div>
                                                    </div>
                                                </td>

                                                <!-- CHỨNG NHẬN / THAO TÁC -->
                                                <td class="py-4 px-4 text-right">
                                                    <div class="flex items-center justify-end gap-2.5">
                                                        <c:choose>
                                                            <c:when test="${v.certification == 'VietGAP'}">
                                                                <span class="px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-700 text-[10px] font-black border border-emerald-200 flex items-center gap-1">
                                                                    <i class="fa-solid fa-shield-check text-[10px]"></i> VietGAP
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${v.certification != null && v.certification.contains('OCOP')}">
                                                                <span class="px-2.5 py-1 rounded-lg bg-amber-50 text-amber-700 text-[10px] font-black border border-amber-200 flex items-center gap-1">
                                                                    <i class="fa-solid fa-star text-[10px]"></i> ${v.certification}
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${v.certification == 'GlobalGAP'}">
                                                                <span class="px-2.5 py-1 rounded-lg bg-blue-50 text-blue-700 text-[10px] font-black border border-blue-200 flex items-center gap-1">
                                                                    <i class="fa-solid fa-certificate text-[10px]"></i> GlobalGAP
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="px-2.5 py-1 rounded-lg bg-slate-100 text-slate-600 text-[10px] font-black border border-slate-200">
                                                                    ${not empty v.certification ? v.certification : 'Tiêu chuẩn'}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <div class="inline-flex items-center gap-1 bg-slate-50 p-1 rounded-xl border border-slate-200">
                                                            <a href="${pageContext.request.contextPath}/shop/product/edit?id=${v.variantId}" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-emerald-700 hover:border-emerald-500 flex items-center justify-center transition-all shadow-2xs" title="Chỉnh sửa">
                                                                <i class="fa-solid fa-pen text-[11px]"></i>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/shop/product/toggle?id=${v.variantId}" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-blue-700 hover:border-blue-500 flex items-center justify-center transition-all shadow-2xs" title="Ẩn / Hiện">
                                                                <i class="fa-regular fa-eye text-[11px]"></i>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/shop/product/delete?id=${v.variantId}" onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');" class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-rose-700 hover:border-rose-500 flex items-center justify-center transition-all shadow-2xs" title="Xóa">
                                                                <i class="fa-regular fa-trash-can text-[11px]"></i>
                                                            </a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="py-20 text-center text-slate-400">
                                                <i class="fa-solid fa-basket-shopping text-4xl mb-3 text-slate-300 block"></i>
                                                <span class="text-sm font-bold text-slate-600">Không tìm thấy nông sản nào phù hợp với bộ lọc.</span>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination Footer -->
                    <div class="px-6 py-4 bg-slate-50 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-4">
                        <div class="flex items-center gap-2 text-xs font-semibold text-slate-500">
                            <span>Hiển thị</span>
                            <select class="px-3 py-1.5 rounded-xl border border-slate-200 text-xs font-bold bg-white cursor-pointer focus:outline-none focus:border-emerald-500" onchange="location.href='${pageContext.request.contextPath}/shop/products?page=1&pageSize=' + this.value;">
                                <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                                <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                                <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
                            </select>
                            <span>trên tổng <strong class="text-slate-900">${not empty totalVariantsCount ? totalVariantsCount : (not empty listVariants ? listVariants.size() : 0)}</strong> nông sản</span>
                        </div>

                        <div class="flex items-center gap-1.5">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/shop/products?page=${currentPage - 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl bg-white border border-slate-200 text-slate-600 font-bold flex items-center justify-center hover:bg-emerald-50 hover:border-emerald-500 hover:text-emerald-700 transition-all text-xs">
                                    <i class="fa-solid fa-chevron-left text-[10px]"></i>
                                </a>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="p">
                                <a href="${pageContext.request.contextPath}/shop/products?page=${p}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl font-bold flex items-center justify-center transition-all text-xs ${p == currentPage ? 'bg-emerald-700 text-white shadow-sm shadow-emerald-700/20' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'}">
                                    ${p}
                                </a>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/shop/products?page=${currentPage + 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl bg-white border border-slate-200 text-slate-600 font-bold flex items-center justify-center hover:bg-emerald-50 hover:border-emerald-500 hover:text-emerald-700 transition-all text-xs">
                                    <i class="fa-solid fa-chevron-right text-[10px]"></i>
                                </a>
                            </c:if>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

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