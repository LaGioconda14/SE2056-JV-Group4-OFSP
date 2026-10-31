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
    <body class="bg-[#f8fafc] text-slate-800 font-['Plus_Jakarta_Sans',sans-serif] min-h-screen flex m-0">

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
                            <h4 class="text-xs font-extrabold text-slate-900 leading-tight">${sessionScope.shopName}</h4>
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
                    <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center justify-between px-3 py-2.5 rounded-xl bg-emerald-50 text-emerald-800 font-bold text-xs transition-all shadow-2xs">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-seedling text-emerald-600 text-sm w-4 text-center"></i>
                            <span>Tất cả sản phẩm</span>
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
                        <div class="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-3 rounded-2xl flex items-center justify-between shadow-xs animate-fade-in">
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
                                    <h1 class="text-2xl font-black text-slate-900 tracking-tight">Danh sách sản phẩm nông sản</h1>
                                    <span class="inline-flex items-center gap-1.5 px-3 py-1 bg-emerald-100 border border-emerald-200 text-emerald-800 text-xs font-extrabold rounded-full shadow-2xs">
                                        <span class="w-2 h-2 rounded-full bg-emerald-600 animate-pulse"></span>
                                        ${not empty totalProductsCount ? totalProductsCount : 0} SẢN PHẨM
                                    </span>
                                </div>
                                <p class="text-xs text-slate-500 font-medium mt-1">
                                    Quản lý tổng quan sản phẩm nông sản. Giá hiển thị là khoảng giá biến thể; tồn kho là tổng số lượng các phân loại.
                                </p>
                            </div>

                            <!-- Action buttons -->
                            <div class="flex items-center flex-wrap gap-2.5">
                                <button type="button" class="px-4 py-2 bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 hover:border-slate-300 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xs transition-all" onclick="alert('Đang xuất dữ liệu danh sách nông sản ra file Excel (.xlsx)...');">
                                    <i class="fa-solid fa-file-excel text-emerald-600 text-sm"></i>
                                    <span>Xuất Excel</span>
                                </button>
                                <button type="button" class="px-4 py-2 bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 hover:border-slate-300 rounded-xl text-xs font-bold flex items-center gap-2 shadow-2xs transition-all" onclick="alert('Hệ thống đang đồng bộ bảng giá loạt...');">
                                    <i class="fa-solid fa-arrows-rotate text-purple-600 text-sm"></i>
                                    <span>Đồng bộ giá loạt</span>
                                </button>
                                <a href="${pageContext.request.contextPath}/shop/product/add" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow-sm shadow-emerald-600/30 transition-all">
                                    <i class="fa-solid fa-circle-plus text-sm"></i>
                                    <span>Thêm mới nông sản</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- STATUS TABS -->
                    <div class="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
                        <a href="${pageContext.request.contextPath}/shop/products?statusTab=all"
                           class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${empty statusTab || statusTab == 'all' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                            <span>Tất cả</span>
                            <span class="px-2 py-0.5 rounded-md text-[10px] ${empty statusTab || statusTab == 'all' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabAllProductCount ? tabAllProductCount : 0}</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/shop/products?statusTab=active"
                           class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'active' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                            <span>Đang mở bán</span>
                            <span class="px-2 py-0.5 rounded-md text-[10px] ${statusTab == 'active' ? 'bg-emerald-800 text-white' : 'bg-slate-100 text-slate-600'}">${not empty tabActiveProductCount ? tabActiveProductCount : 0}</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/shop/products?statusTab=vietgap"
                           class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'vietgap' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                            <span>Chờ duyệt VietGAP</span>
                            <span class="px-2 py-0.5 rounded-md text-[10px] bg-amber-100 text-amber-800 font-extrabold">${not empty tabVietgapProductCount ? tabVietgapProductCount : 0}</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/shop/products?statusTab=hidden"
                           class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'hidden' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                            <span>Hết hàng / Tạm ẩn</span>
                            <span class="px-2 py-0.5 rounded-md text-[10px] bg-rose-100 text-rose-700 font-extrabold">${not empty tabHiddenProductCount ? tabHiddenProductCount : 0}</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/shop/products?statusTab=warning"
                           class="px-4 py-2 rounded-xl font-bold transition-all flex items-center gap-2 whitespace-nowrap shadow-2xs ${statusTab == 'warning' ? 'bg-emerald-700 text-white shadow-emerald-700/20' : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'}">
                            <span>Vi phạm / Cảnh báo</span>
                            <span class="px-2 py-0.5 rounded-md text-[10px] bg-slate-100 text-slate-600">${not empty tabWarningProductCount ? tabWarningProductCount : 0}</span>
                        </a>
                    </div>

                    <!-- SEARCH & FILTER TOOLBAR -->
                    <form action="${pageContext.request.contextPath}/shop/product/search" method="GET" class="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs space-y-4">

                        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-12 gap-3 items-center">
                            <!-- 1. Ô tìm kiếm từ khóa -->
                            <div class="xl:col-span-5 relative">
                                <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
                                <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên nông sản, mã xuất xứ..." class="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-medium focus:outline-none focus:border-emerald-500 focus:bg-white transition-all">
                            </div>

                            <!-- 2. Dropdown Danh mục -->
                            <div class="xl:col-span-3">
                                <select name="categoryId" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                    <option value="">Tất cả danh mục quả</option>
                                    <c:forEach var="c" items="${categories}">
                                        <option value="${c.categoryId}" ${param.categoryId == c.categoryId ? 'selected' : ''}>
                                            ${c.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- 3. Dropdown Chứng nhận -->
                            <div class="xl:col-span-2">
                                <select name="certification" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                    <option value="">Chứng nhận: Tất cả</option>
                                    <c:forEach var="cert" items="${certifications}">
                                        <option value="${cert}" ${param.certification == cert ? 'selected' : ''}>
                                            ${cert}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- 4. Dropdown Tồn kho (Đã fix lỗi ngắt dòng) -->
                            <div class="xl:col-span-2">
                                <select name="stockLevel" class="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 focus:outline-none focus:border-emerald-500 focus:bg-white transition-all cursor-pointer" onchange="this.form.submit()">
                                    <option value="">Tồn kho: Tất cả</option>
                                    <option value="critical" ${param.stockLevel == 'critical' ? 'selected' : ''}>Tồn &lt; 5 đơn vị</option>
                                    <option value="low" ${param.stockLevel == 'low' ? 'selected' : ''}>Sắp hết (&lt;= 15)</option>
                                    <option value="stable" ${param.stockLevel == 'stable' ? 'selected' : ''}>Ổn định (16 - 40)</option>
                                    <option value="abundant" ${param.stockLevel == 'abundant' ? 'selected' : ''}>Dồi dào (&gt; 40)</option>
                                </select>
                            </div>
                        </div>

                        <!-- Thanh hiển thị kết quả thống kê -->
                        <div class="flex items-center justify-between pt-2 border-t border-slate-100 text-xs">
                            <div class="text-slate-500 font-semibold">
                                Đang hiển thị: <span class="text-slate-900 font-extrabold">${not empty products ? products.size() : 0}</span> / tổng <span class="text-slate-900 font-extrabold">${not empty totalProductsCount ? totalProductsCount : (not empty products ? products.size() : 0)}</span> nông sản
                            </div>
                            <c:if test="${not empty param.keyword or not empty param.categoryId or not empty param.certification or not empty param.stockLevel}">
                                <a href="${pageContext.request.contextPath}/shop/products" class="text-emerald-600 font-bold hover:underline">
                                    <i class="fa-solid fa-rotate-left mr-1"></i> Xóa bộ lọc
                                </a>
                            </c:if>
                        </div>
                    </form>

                    <!-- ========================================================
                         PRODUCT TABLE (BẢNG DANH SÁCH SẢN PHẨM ĐÃ ĐƯỢC CHỈNH TỈ MỈ)
                         ======================================================== -->
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-2xs overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-slate-50/80 border-b border-slate-200 text-[11px] font-black text-slate-500 uppercase tracking-wider">
                                        <th class="w-12 text-center py-3.5 px-4">
                                            <input type="checkbox" id="selectAllCheckbox" class="w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 focus:ring-offset-0 cursor-pointer">
                                        </th>
                                        <th class="py-3.5 px-4 min-w-[280px]">SẢN PHẨM NÔNG SẢN</th>
                                        <th class="py-3.5 px-4 min-w-[150px]">KHOẢNG GIÁ</th>
                                        <th class="py-3.5 px-4 min-w-[160px]">TỔNG TỒN KHO</th>
                                        <th class="py-3.5 px-4 min-w-[140px]">TRẠNG THÁI</th>
                                        <th class="py-3.5 px-4 min-w-[130px]">CHỨNG NHẬN</th>
                                        <th class="py-3.5 px-4 text-right min-w-[130px]">THAO TÁC</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 text-xs">
                                    <c:choose>
                                        <c:when test="${not empty products}">
                                            <c:forEach var="product" items="${products}">
                                                <tr class="hover:bg-slate-50/80 transition-colors group">
                                                    <!-- Checkbox chọn dòng -->
                                                    <td class="text-center py-4 px-4 align-middle">
                                                        <input type="checkbox" name="productIds" value="${product.id}" class="product-row-checkbox w-4 h-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 cursor-pointer">
                                                    </td>

                                                    <!-- Cột Sản phẩm: Ảnh + Tên + Danh mục + Xuất xứ -->
                                                    <td class="py-4 px-4 align-middle">
                                                        <div class="flex items-center gap-3.5">
                                                            <div class="relative w-12 h-12 rounded-xl overflow-hidden border border-slate-200 shrink-0 shadow-2xs group-hover:border-emerald-400 transition-all">
                                                                <img src="${product.image}" alt="${product.name}" class="w-full h-full object-cover" onerror="this.src='https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=120&h=120&fit=crop';">
                                                            </div>
                                                            <div class="min-w-0 flex-1">
                                                                <a href="${pageContext.request.contextPath}/detail?id=${product.id}" class="font-extrabold text-sm text-slate-900 hover:text-emerald-700 transition-colors line-clamp-1 block">
                                                                    ${product.name}
                                                                </a>
                                                                <div class="flex items-center gap-2 mt-1 flex-wrap">
                                                                    <span class="inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-bold bg-slate-100 text-slate-600 border border-slate-200">
                                                                        <i class="fa-solid fa-layer-group text-[9px] mr-1 text-slate-400"></i>
                                                                        ${not empty product.categoryName ? product.categoryName : 'Chưa phân loại'}
                                                                    </span>
                                                                    <c:if test="${not empty product.origin}">
                                                                        <span class="text-[11px] font-medium text-slate-400 flex items-center gap-1">
                                                                            <i class="fa-solid fa-location-dot text-[9px] text-slate-400"></i>
                                                                            ${product.origin}
                                                                        </span>
                                                                    </c:if>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </td>

                                                    <!-- Cột Giá bán lẻ / Khoảng giá -->
                                                    <td class="py-4 px-4 align-middle">
                                                        <c:choose>
                                                            <c:when test="${product.price > 0}">
                                                                <div class="flex flex-col">
                                                                    <span class="font-black text-sm text-emerald-700 tracking-tight">
                                                                        <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0"/> ₫
                                                                        <c:if test="${product.oldPrice > product.price}">
                                                                            – <fmt:formatNumber value="${product.oldPrice}" type="number" maxFractionDigits="0"/> ₫
                                                                        </c:if>
                                                                    </span>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-xs font-semibold text-slate-400 italic">Chưa thiết lập giá</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <!-- Cột Tổng tồn kho kèm Thanh Progress Bar sống động -->
                                                    <td class="py-4 px-4 align-middle">
                                                        <div class="flex flex-col gap-1.5 max-w-[130px]">
                                                            <div class="flex items-center justify-between">
                                                                <span class="font-black text-xs text-slate-800">
                                                                    ${product.stockQuantity} <span class="text-[10px] font-bold text-slate-400"></span>
                                                                </span>
                                                                <c:choose>
                                                                    <c:when test="${product.stockQuantity < 5}">
                                                                        <span class="text-[9px] font-black text-rose-600 bg-rose-50 px-1.5 py-0.5 rounded border border-rose-200">Cực thấp</span>
                                                                    </c:when>
                                                                    <c:when test="${product.stockQuantity <= 15}">
                                                                        <span class="text-[9px] font-black text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded border border-amber-200">Sắp hết</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-[9px] font-black text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">Dồi dào</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <!-- Progress bar tồn kho -->
                                                            <div class="w-full bg-slate-100 rounded-full h-1.5 overflow-hidden">
                                                                <c:choose>
                                                                    <c:when test="${product.stockQuantity < 5}">
                                                                        <div class="bg-rose-500 h-1.5 rounded-full" style="width: ${product.stockQuantity * 10}%"></div>
                                                                    </c:when>
                                                                    <c:when test="${product.stockQuantity <= 15}">
                                                                        <div class="bg-amber-500 h-1.5 rounded-full" style="width: ${product.stockQuantity * 5}%"></div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="bg-emerald-500 h-1.5 rounded-full" style="width: ${product.stockQuantity > 100 ? 100 : product.stockQuantity}%"></div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </td>

                                                    <!-- Cột Trạng thái & Số phân loại -->
                                                    <td class="py-4 px-4 align-middle">
                                                        <div class="flex flex-col items-start gap-1">
                                                            <c:choose>
                                                                <c:when test="${product.active && product.stockQuantity > 0}">
                                                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-700 text-[10px] font-extrabold">
                                                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                                                        Đang mở bán
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${product.active}">
                                                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-amber-50 border border-amber-200 text-amber-700 text-[10px] font-extrabold">Hết hàng</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-rose-50 border border-rose-200 text-rose-700 text-[10px] font-extrabold">
                                                                        <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                                                                        Đã ẩn / Tạm ngưng
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <span class="text-[10px] font-semibold text-slate-400 pl-1">
                                                                ${product.variantCount} phân loại
                                                            </span>
                                                        </div>
                                                    </td>

                                                    <!-- Cột Chứng nhận -->
                                                    <td class="py-4 px-4 align-middle">
                                                        <c:choose>
                                                            <c:when test="${product.certification == 'VietGAP'}">
                                                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-800 border border-emerald-300 text-[10px] font-black tracking-wide">
                                                                    <i class="fa-solid fa-shield-check text-emerald-600"></i> VietGAP
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${product.certification == 'OCOP'}">
                                                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-amber-50 text-amber-800 border border-amber-300 text-[10px] font-black tracking-wide">
                                                                    <i class="fa-solid fa-award text-amber-600"></i> OCOP 4★
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${product.certification == 'Organic'}">
                                                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-teal-50 text-teal-800 border border-teal-300 text-[10px] font-black tracking-wide">
                                                                    <i class="fa-solid fa-leaf text-teal-600"></i> Hữu cơ
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-slate-100 text-slate-600 border border-slate-200 text-[10px] font-bold">
                                                                    ${not empty product.certification ? product.certification : 'Tiêu chuẩn'}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <!-- Cột Thao tác -->
                                                    <td class="py-4 px-4 align-middle text-right">
                                                        <div class="inline-flex items-center gap-1 bg-slate-100/80 p-1 rounded-xl border border-slate-200/80 shadow-2xs">
                                                            <a href="${pageContext.request.contextPath}/shop/product/variants?productId=${product.id}" class="inline-flex items-center gap-1.5 h-8 px-2 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-indigo-700 hover:border-indigo-300 transition-all text-[10px] font-bold" title="Quản lý biến thể">
                                                                <i class="fa-solid fa-layer-group text-[11px]"></i><span>Biến thể</span>
                                                            </a>
                                                            <c:choose>
                                                                <c:when test="${product.id > 0}">
                                                                    <a href="${pageContext.request.contextPath}/shop/product/edit?productId=${product.id}" class="w-8 h-8 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-emerald-700 hover:border-emerald-300 hover:shadow-2xs flex items-center justify-center transition-all" title="Sửa thông tin sản phẩm">
                                                                        <i class="fa-solid fa-pen-to-square text-[11px]"></i>
                                                                    </a>
                                                                </c:when>
                                                                <c:when test="${product.active}">
                                                                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-amber-50 border border-amber-200 text-amber-700 text-[10px] font-extrabold">&#272;ã bật / Hết hàng</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <button type="button" disabled class="w-8 h-8 rounded-lg bg-slate-50 border border-slate-200 text-slate-300 flex items-center justify-center cursor-not-allowed" title="Chưa có thông tin sửa">
                                                                        <i class="fa-solid fa-pen-to-square text-[11px]"></i>
                                                                    </button>
                                                                </c:otherwise>
                                                            </c:choose>

                                                            <a href="${pageContext.request.contextPath}/detail?id=${product.id}" class="w-8 h-8 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-blue-700 hover:border-blue-300 hover:shadow-2xs flex items-center justify-center transition-all" title="Xem giao diện hiển thị">
                                                                <i class="fa-regular fa-eye text-[12px]"></i>
                                                            </a>

                                                            <a href="${pageContext.request.contextPath}/shop/product/delete?productId=${product.id}" onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm nông sản này không? Hành động này không thể hoàn tác!');" class="w-8 h-8 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-rose-700 hover:border-rose-300 hover:shadow-2xs flex items-center justify-center transition-all" title="Xóa sản phẩm">
                                                                <i class="fa-regular fa-trash-can text-[11px]"></i>
                                                            </a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="7" class="py-16 text-center bg-slate-50/50">
                                                    <div class="flex flex-col items-center justify-center space-y-3">
                                                        <div class="w-14 h-14 rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
                                                            <i class="fa-solid fa-seedling text-2xl"></i>
                                                        </div>
                                                        <p class="text-sm font-bold text-slate-600">Không tìm thấy nông sản nào phù hợp</p>
                                                        <p class="text-xs text-slate-400">Thử thay đổi từ khóa tìm kiếm hoặc bỏ chọn các bộ lọc phía trên.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination Footer -->
                        <div class="px-6 py-4 bg-slate-50/80 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-4">
                            <div class="flex items-center gap-2 text-xs font-semibold text-slate-500">
                                <span>Hiển thị</span>
                                <select class="px-3 py-1.5 rounded-xl border border-slate-200 text-xs font-bold bg-white cursor-pointer focus:outline-none focus:border-emerald-500 transition-all shadow-2xs" onchange="const params = new URLSearchParams(window.location.search); params.set('page', '1'); params.set('pageSize', this.value); window.location.href = '${pageContext.request.contextPath}/shop/product/search?' + params.toString();">
                                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
                                    <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
                                    <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
                                </select>
                                <span>trên tổng <strong class="text-slate-900">${not empty totalProductsCount ? totalProductsCount : (not empty products ? products.size() : 0)}</strong> nông sản</span>
                            </div>

                            <div class="flex items-center gap-1.5">
                                <c:if test="${currentPage > 1}">
                                    <a href="${pageContext.request.contextPath}/shop/product/search?page=${currentPage - 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl bg-white border border-slate-200 text-slate-600 font-bold flex items-center justify-center hover:bg-emerald-50 hover:border-emerald-500 hover:text-emerald-700 transition-all text-xs shadow-2xs">
                                        <i class="fa-solid fa-chevron-left text-[10px]"></i>
                                    </a>
                                </c:if>

                                <c:forEach begin="1" end="${totalPages > 0 ? totalPages : 1}" var="p">
                                    <a href="${pageContext.request.contextPath}/shop/product/search?page=${p}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl font-bold flex items-center justify-center transition-all text-xs ${p == currentPage ? 'bg-emerald-700 text-white shadow-xs shadow-emerald-700/30' : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 shadow-2xs'}">
                                        ${p}
                                    </a>
                                </c:forEach>

                                <c:if test="${currentPage < totalPages}">
                                    <a href="${pageContext.request.contextPath}/shop/product/search?page=${currentPage + 1}&pageSize=${pageSize}&keyword=${param.keyword}&categoryId=${param.categoryId}&certification=${param.certification}&stockLevel=${param.stockLevel}&statusTab=${statusTab}" class="w-8 h-8 rounded-xl bg-white border border-slate-200 text-slate-600 font-bold flex items-center justify-center hover:bg-emerald-50 hover:border-emerald-500 hover:text-emerald-700 transition-all text-xs shadow-2xs">
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
            document.addEventListener('DOMContentLoaded', function () {
                const selectAll = document.getElementById('selectAllCheckbox');
                const rowCheckboxes = document.querySelectorAll('.product-row-checkbox');

                if (selectAll) {
                    selectAll.addEventListener('change', function () {
                        rowCheckboxes.forEach(cb => cb.checked = selectAll.checked);
                    });
                }
            });
        </script>
    </body>
</html>
