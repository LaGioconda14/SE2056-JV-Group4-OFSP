<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng Quan Shop - FreshFruit Kênh Người Bán</title>
    <!-- Google Fonts & FontAwesome -->
    <link href="https://fonts.googleapis.com" rel="preconnect">
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Chart.js 4.x -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- Custom Dashboard CSS & JS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-dashboard.css">
    <script src="${pageContext.request.contextPath}/assets/js/shop-dashboard.js" defer></script>
</head>
<body class="bg-[#f8fafc] font-['Plus_Jakarta_Sans',sans-serif] text-gray-800 antialiased min-h-screen">

    <!-- ========================================================
         1. LEFT SIDEBAR NAVIGATION (KÊNH NGƯỜI BÁN)
         ======================================================== -->
    <aside class="fixed top-0 left-0 bottom-0 w-64 bg-white border-r border-gray-200/80 z-30 flex flex-col justify-between py-5 px-4 overflow-y-auto">
        <div class="space-y-6">
            <!-- Brand Logo -->
            <div class="flex items-center gap-3 px-2">
                <div class="w-9 h-9 rounded-full bg-emerald-50 flex items-center justify-center p-1 border border-emerald-100 shrink-0">
                    <svg viewBox="0 0 100 100" class="w-full h-full">
                        <circle cx="50" cy="56" r="32" fill="#166534"/>
                        <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                        <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                        <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                    </svg>
                </div>
                <div>
                    <span class="text-lg font-black text-gray-900 tracking-tight block leading-tight">FreshFruit</span>
                    <span class="inline-block px-1.5 py-0.2 rounded bg-emerald-100 text-emerald-800 font-extrabold text-[9px] uppercase tracking-wider">KÊNH NGƯỜI BÁN</span>
                </div>
            </div>

            <!-- Current Shop Badge / Card -->
            <div class="bg-gray-50/80 border border-gray-100 rounded-2xl p-3 flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center text-lg shrink-0">
                    <i class="fa-solid fa-tractor"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <h4 class="font-extrabold text-xs text-gray-900 truncate">
                        ${not empty sessionScope.shopName ? sessionScope.shopName : 'Đà Lạt Organic Farm'}
                    </h4>
                    <span class="flex items-center gap-1.5 text-[11px] text-emerald-700 font-semibold mt-0.5">
                        <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span> Đang mở bán
                    </span>
                </div>
            </div>

            <!-- Navigation Groups -->
            <nav class="space-y-4">
                <!-- Group: TỔNG QUAN -->
                <div>
                    <div class="dash-sidebar-group-title">TỔNG QUAN</div>
                    <div class="space-y-1">
                        <a href="${pageContext.request.contextPath}/shop/dashboard" class="dash-sidebar-nav-item active">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-chart-pie text-sm"></i> Tổng quan Shop
                            </span>
                        </a>
                    </div>
                </div>

                <!-- Group: SẢN PHẨM & KHO -->
                <div>
                    <div class="dash-sidebar-group-title">SẢN PHẨM & KHO</div>
                    <div class="space-y-1">
                        <a href="${pageContext.request.contextPath}/shop/products" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-apple-whole text-sm text-gray-400"></i> Tất cả sản phẩm
                            </span>
                        </a>
                        <a href="${pageContext.request.contextPath}/shop/products?action=add" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-circle-plus text-sm text-gray-400"></i> Thêm quả mới
                            </span>
                        </a>
                        <a href="${pageContext.request.contextPath}/shop/inventory" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-boxes-stacked text-sm text-gray-400"></i> Kho & Cảnh báo tồn
                            </span>
                            <span class="px-1.5 py-0.5 rounded-full bg-red-100 text-red-600 font-bold text-[10px]">3</span>
                        </a>
                    </div>
                </div>

                <!-- Group: ĐƠN HÀNG -->
                <div>
                    <div class="dash-sidebar-group-title">ĐƠN HÀNG</div>
                    <div class="space-y-1">
                        <a href="${pageContext.request.contextPath}/shop/orders" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-receipt text-sm text-gray-400"></i> Đơn hàng con
                            </span>
                            <span class="px-1.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">8</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/shop/shipping" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-dolly text-sm text-gray-400"></i> Đóng gói & Vận đơn
                            </span>
                        </a>
                    </div>
                </div>

                <!-- Group: TIẾP THỊ & KHÁCH HÀNG -->
                <div>
                    <div class="dash-sidebar-group-title">TIẾP THỊ & KHÁCH HÀNG</div>
                    <div class="space-y-1">
                        <a href="${pageContext.request.contextPath}/shop/coupons" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-ticket text-sm text-gray-400"></i> Mã giảm giá Shop
                            </span>
                        </a>
                        <a href="${pageContext.request.contextPath}/shop/reviews" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-regular fa-star text-sm text-gray-400"></i> Đánh giá từ khách
                            </span>
                        </a>
                    </div>
                </div>

                <!-- Group: TÀI CHÍNH & THIẾT LẬP -->
                <div>
                    <div class="dash-sidebar-group-title">TÀI CHÍNH & THIẾT LẬP</div>
                    <div class="space-y-1">
                        <a href="${pageContext.request.contextPath}/shop/finance" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-wallet text-sm text-gray-400"></i> Doanh thu & Rút tiền
                            </span>
                        </a>
                        <a href="${pageContext.request.contextPath}/shop/settings" class="dash-sidebar-nav-item">
                            <span class="flex items-center gap-2.5">
                                <i class="fa-solid fa-store text-sm text-gray-400"></i> Cài đặt Shop
                            </span>
                        </a>
                    </div>
                </div>
            </nav>
        </div>

        <!-- Sidebar Bottom Footer -->
        <div class="pt-4 border-t border-gray-100 space-y-1">
            <a href="${pageContext.request.contextPath}/home" class="dash-sidebar-nav-item text-emerald-700 hover:text-emerald-800">
                <span class="flex items-center gap-2">
                    <i class="fa-solid fa-arrow-up-right-from-square text-xs"></i> Xem trang mua sắm
                </span>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="dash-sidebar-nav-item text-red-600 hover:text-red-700 hover:bg-red-50">
                <span class="flex items-center gap-2">
                    <i class="fa-solid fa-right-from-bracket text-xs"></i> Đăng xuất
                </span>
            </a>
        </div>
    </aside>

    <!-- ========================================================
         2. TOP HEADER NAVBAR
         ======================================================== -->
    <header class="fixed top-0 left-64 right-0 h-16 bg-white border-b border-gray-200/80 z-20 px-8 flex items-center justify-between">
        <!-- Search Input with Shortcut -->
        <div class="relative w-full max-w-md">
            <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-gray-400 text-xs"></i>
            <input type="text" placeholder="Tìm theo SKU, tên trái cây, hoặc mã đơn con (Ctrl+K)..." class="w-full bg-gray-100/80 border border-transparent focus:border-emerald-600 focus:bg-white rounded-xl pl-9 pr-4 py-2 text-xs text-gray-800 placeholder-gray-400 focus:outline-none transition">
        </div>

        <!-- Right Utility Actions -->
        <div class="flex items-center gap-5">
            <!-- Receiving Orders Switcher -->
            <div class="flex items-center gap-2.5 bg-gray-50 border border-gray-200/80 px-3 py-1.5 rounded-full">
                <span id="toggleStatusText" class="text-xs font-bold text-gray-700">Đang nhận đơn</span>
                <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" id="orderReceivingToggle" checked class="sr-only switch-checkbox">
                    <div class="w-9 h-5 bg-gray-300 rounded-full switch-bg transition-colors"></div>
                    <div class="dot absolute left-0.5 top-0.5 bg-white w-4 h-4 rounded-full transition-transform switch-dot shadow-sm"></div>
                </label>
            </div>

            <!-- Notifications & Messages -->
            <div class="flex items-center gap-2">
                <button type="button" class="relative w-9 h-9 rounded-xl hover:bg-gray-100 flex items-center justify-center text-gray-600 transition" title="Thông báo">
                    <i class="fa-regular fa-bell text-sm"></i>
                    <span class="absolute top-1 right-1 w-4 h-4 rounded-full bg-amber-500 text-white font-bold text-[9px] flex items-center justify-center">5</span>
                </button>
                <button type="button" class="w-9 h-9 rounded-xl hover:bg-gray-100 flex items-center justify-center text-gray-600 transition" title="Tin nhắn khách hàng">
                    <i class="fa-regular fa-comment-dots text-sm"></i>
                </button>
            </div>

            <!-- User Profile Avatar & Name -->
            <div class="flex items-center gap-3 pl-3 border-l border-gray-200">
                <div class="text-right hidden sm:block leading-tight">
                    <span class="block text-xs font-bold text-gray-900">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Phạm Văn Nông'}</span>
                    <span class="text-[11px] text-gray-400 font-medium">Chủ Vườn Đà Lạt</span>
                </div>
                <div class="w-9 h-9 rounded-full overflow-hidden border border-emerald-400 shrink-0 bg-emerald-100 flex items-center justify-center font-bold text-emerald-800 text-xs">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatarUrl}">
                            <img src="${sessionScope.user.avatarUrl}" alt="Avatar" class="w-full h-full object-cover">
                        </c:when>
                        <c:otherwise>
                            <i class="fa-solid fa-user"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </header>

    <!-- ========================================================
         3. MAIN DASHBOARD CONTENT AREA
         ======================================================== -->
    <main class="ml-64 pt-20 px-8 pb-16 space-y-6">

        <!-- TITLE & QUICK REFRESH BAR -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2">
            <div>
                <div class="flex items-center gap-2.5">
                    <h1 class="text-2xl font-black text-gray-950 tracking-tight">
                        Xin chào, ${not empty sessionScope.shopName ? sessionScope.shopName : 'Đà Lạt Organic Farm'}!
                    </h1>
                    <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[11px]">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span> Cửa hàng trực tuyến
                    </span>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                    Tổng quan hoạt động kinh doanh nông sản trong ngày và tiến độ giao hàng cho khách lẻ
                </p>
            </div>

            <div class="flex items-center gap-3 text-xs">
                <span class="text-gray-400">Cập nhật: <strong class="text-gray-700">11:42 Hôm nay</strong></span>
                <button type="button" id="btnRefreshDash" class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-gray-200 bg-white hover:bg-gray-50 font-bold text-gray-700 shadow-xs transition">
                    <i class="fa-solid fa-arrows-rotate text-emerald-700 text-xs"></i> Làm mới
                </button>
            </div>
        </div>

        <!-- 3 ACTIONABLE ALERT CARDS (TOP BANNER) -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
            <!-- Alert 1: Đơn hàng chờ đóng gói (Green) -->
            <div class="bg-emerald-50/50 border border-emerald-100 rounded-3xl p-5 flex flex-col justify-between shadow-xs">
                <div class="space-y-2">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center text-sm">
                                <i class="fa-solid fa-box"></i>
                            </div>
                            <span class="font-bold text-sm text-gray-900">${pendingPack} Đơn hàng chờ đóng gói</span>
                        </div>
                        <span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-extrabold text-[10px] uppercase">Ưu tiên</span>
                    </div>
                    <p class="text-xs text-gray-600 leading-relaxed">
                        Cần kiểm tra & đóng gói quả tươi xuất vườn trước <strong>14:00</strong>
                    </p>
                </div>
                <div class="pt-4 flex items-center justify-between border-t border-emerald-100/80 mt-3 text-xs">
                    <span class="text-emerald-800 font-semibold">Hẹn hỏa tốc 2 giờ: 3 đơn</span>
                    <a href="${pageContext.request.contextPath}/shop/orders" class="px-3 py-1.5 rounded-full bg-emerald-800 hover:bg-emerald-900 text-white font-extrabold text-xs transition inline-flex items-center gap-1">
                        Xử lý ngay <i class="fa-solid fa-arrow-right text-[10px]"></i>
                    </a>
                </div>
            </div>

            <!-- Alert 2: Biến thể sắp hết hàng (Orange) -->
            <div class="bg-amber-50/50 border border-amber-200/80 rounded-3xl p-5 flex flex-col justify-between shadow-xs">
                <div class="space-y-2">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-xl bg-amber-100 text-amber-800 flex items-center justify-center text-sm">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                            <span class="font-bold text-sm text-gray-900">${lowStockCount} Biến thể sắp hết hàng</span>
                        </div>
                        <span class="px-2 py-0.5 rounded-full bg-amber-200 text-amber-900 font-extrabold text-[10px] uppercase">Tồn &lt; 5</span>
                    </div>
                    <p class="text-xs text-gray-600 leading-relaxed">
                        Dâu tây Tochiotome hộp 500g chỉ còn <strong class="text-amber-900 font-bold">4 hộp</strong> sẵn bán
                    </p>
                </div>
                <div class="pt-4 flex items-center justify-between border-t border-amber-200/60 mt-3 text-xs">
                    <span class="text-amber-900 font-semibold">Nguy cơ cháy hàng trưa nay</span>
                    <a href="${pageContext.request.contextPath}/shop/inventory" class="px-3 py-1.5 rounded-full bg-emerald-100 hover:bg-emerald-200 text-emerald-800 font-extrabold text-xs transition inline-flex items-center gap-1">
                        Nhập kho nhanh <i class="fa-solid fa-plus text-[10px]"></i>
                    </a>
                </div>
            </div>

            <!-- Alert 3: Đánh giá cần phản hồi (Red) -->
            <div class="bg-red-50/50 border border-red-200/80 rounded-3xl p-5 flex flex-col justify-between shadow-xs">
                <div class="space-y-2">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-xl bg-red-100 text-red-700 flex items-center justify-center text-sm">
                                <i class="fa-regular fa-comment-dots"></i>
                            </div>
                            <span class="font-bold text-sm text-gray-900">2 Đánh giá cần phản hồi</span>
                        </div>
                        <span class="px-2 py-0.5 rounded-full bg-red-100 text-red-700 font-extrabold text-[10px] uppercase">CSKH</span>
                    </div>
                    <p class="text-xs text-gray-600 leading-relaxed">
                        Khách phản ánh quả dập trong quá trình giao đơn vận chuyển
                    </p>
                </div>
                <div class="pt-4 flex items-center justify-between border-t border-red-200/60 mt-3 text-xs">
                    <span class="text-red-700 font-semibold">Đánh giá 1* &amp; 2* cần hỗ trợ</span>
                    <a href="${pageContext.request.contextPath}/shop/reviews" class="px-3 py-1.5 rounded-full border border-gray-300 hover:bg-white text-gray-700 font-extrabold text-xs transition inline-flex items-center gap-1">
                        Xem &amp; Trả lời <i class="fa-regular fa-window-restore text-[10px]"></i>
                    </a>
                </div>
            </div>
        </div>

        <!-- 4 KPI STAT METRIC CARDS -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <!-- KPI 1: Doanh thu hôm nay -->
            <div class="bg-white rounded-3xl p-5 border border-gray-100 shadow-xs flex flex-col justify-between">
                <div>
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-[11px] font-extrabold text-gray-400 uppercase tracking-wider">DOANH THU HÔM NAY</span>
                        <div class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-700 flex items-center justify-center text-xs">
                            <i class="fa-solid fa-wallet"></i>
                        </div>
                    </div>
                    <div class="text-2xl sm:text-3xl font-black text-emerald-800 tracking-tight">
                        ₫<fmt:formatNumber value="${todayRevenue}" pattern="#,###" />
                    </div>
                    <span class="inline-flex items-center gap-1 text-[11px] font-extrabold text-emerald-700 mt-1">
                        <i class="fa-solid fa-arrow-trend-up"></i> +8.5% <span class="font-normal text-gray-400">so với hôm qua</span>
                    </span>
                </div>
                <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs bg-gray-50/60 -mx-5 -mb-5 px-5 py-2.5 rounded-b-3xl">
                    <span class="text-gray-500">Đã thanh toán:</span>
                    <strong class="text-gray-900">${successfulOrders} đơn thành công</strong>
                </div>
            </div>

            <!-- KPI 2: Đơn hàng con mới -->
            <div class="bg-white rounded-3xl p-5 border border-gray-100 shadow-xs flex flex-col justify-between">
                <div>
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-[11px] font-extrabold text-gray-400 uppercase tracking-wider">ĐƠN HÀNG CON MỚI</span>
                        <div class="w-7 h-7 rounded-lg bg-gray-100 text-gray-700 flex items-center justify-center text-xs">
                            <i class="fa-solid fa-bag-shopping"></i>
                        </div>
                    </div>
                    <div class="text-2xl sm:text-3xl font-black text-gray-950 tracking-tight">
                        ${newOrdersCount} Đơn mới
                    </div>
                    <span class="inline-flex items-center gap-1.5 text-[11px] text-emerald-700 font-semibold mt-1">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span> Tất cả trong ca sáng &amp; trưa
                    </span>
                </div>
                <div class="mt-4 pt-3 border-t border-gray-100 grid grid-cols-3 gap-2 text-center text-xs bg-gray-50/60 -mx-5 -mb-5 px-3 py-2.5 rounded-b-3xl">
                    <div><strong class="text-gray-900 block font-bold">${pendingPack}</strong><span class="text-[10px] text-gray-400">Chờ gói</span></div>
                    <div><strong class="text-gray-900 block font-bold">${pendingPickup}</strong><span class="text-[10px] text-gray-400">Chờ lấy</span></div>
                    <div><strong class="text-gray-900 block font-bold">${delivering}</strong><span class="text-[10px] text-gray-400">Đang giao</span></div>
                </div>
            </div>

            <!-- KPI 3: Sản phẩm đang bán -->
            <div class="bg-white rounded-3xl p-5 border border-gray-100 shadow-xs flex flex-col justify-between">
                <div>
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-[11px] font-extrabold text-gray-400 uppercase tracking-wider">SẢN PHẨM ĐANG BÁN</span>
                        <div class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-700 flex items-center justify-center text-xs">
                            <i class="fa-solid fa-lemon"></i>
                        </div>
                    </div>
                    <div class="flex items-baseline justify-between">
                        <span class="text-2xl sm:text-3xl font-black text-gray-950 tracking-tight">
                            ${totalProducts} Quả
                        </span>
                        <span class="text-xs font-black text-gray-400">/ ${totalSkus} SKUs</span>
                    </div>
                    <span class="text-[11px] font-bold text-gray-400 mt-1 block">
                        Tỷ lệ sẵn sàng kho: <strong class="text-emerald-700">95.2%</strong>
                    </span>
                </div>
                <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs bg-gray-50/60 -mx-5 -mb-5 px-5 py-2.5 rounded-b-3xl">
                    <span class="text-gray-500">Tình trạng kho:</span>
                    <strong class="text-red-600 font-bold">${lowStockCount} SKU tồn thấp</strong>
                </div>
            </div>

            <!-- KPI 4: Đánh giá chất lượng -->
            <div class="bg-white rounded-3xl p-5 border border-gray-100 shadow-xs flex flex-col justify-between">
                <div>
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-[11px] font-extrabold text-gray-400 uppercase tracking-wider">ĐÁNH GIÁ CHẤT LƯỢNG</span>
                        <div class="w-7 h-7 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center text-xs">
                            <i class="fa-solid fa-star"></i>
                        </div>
                    </div>
                    <div class="flex items-baseline gap-2">
                        <span class="text-2xl sm:text-3xl font-black text-gray-950 tracking-tight">${ratingAvg}</span>
                        <span class="text-xs font-bold text-gray-400">/ 5.0</span>
                        <div class="flex text-amber-400 text-xs ml-1">
                            <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                        </div>
                    </div>
                    <span class="text-[11px] text-gray-400 mt-1 block">
                        Dựa trên ${totalReviews} lượt đánh giá độ ngọt &amp; tươi
                    </span>
                </div>
                <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs bg-gray-50/60 -mx-5 -mb-5 px-5 py-2.5 rounded-b-3xl">
                    <span class="text-gray-500">Tỷ lệ hài lòng:</span>
                    <strong class="text-emerald-700 font-bold">${satisfactionRate}% đánh giá tốt</strong>
                </div>
            </div>
        </div>

        <!-- ========================================================
             4. MIDDLE SECTION: ORDERS TABLE & INVENTORY / PAYOUT
             ======================================================== -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

            <!-- LEFT 8 COLS: HÀNG ĐỢI ĐÓNG GÓI & XỬ LÝ ĐƠN HÀNG HÔM NAY -->
            <div class="lg:col-span-8 bg-white rounded-3xl p-6 border border-gray-100 shadow-xs flex flex-col justify-between">
                <div>
                    <!-- Header with Tabs Filter -->
                    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-gray-100">
                        <div>
                            <h2 class="text-base font-black text-gray-950">Hàng đợi đóng gói &amp; Xử lý đơn hàng hôm nay</h2>
                            <p class="text-xs text-gray-400 mt-0.5">Cập nhật trực tiếp từ khách mua lẻ trên FreshFruit Marketplace</p>
                        </div>
                        <div class="flex items-center gap-1.5 overflow-x-auto">
                            <button type="button" class="order-filter-tab active" data-filter="all">Tất cả (18)</button>
                            <button type="button" class="order-filter-tab" data-filter="pack">Cần gói (8)</button>
                            <button type="button" class="order-filter-tab" data-filter="pickup">Chờ lấy (4)</button>
                            <button type="button" class="order-filter-tab" data-filter="delivering">Đang giao (6)</button>
                        </div>
                    </div>

                    <!-- Table of Orders -->
                    <div class="overflow-x-auto mt-2">
                        <table class="w-full text-left text-xs">
                            <thead>
                                <tr class="text-[10px] font-extrabold uppercase tracking-wider text-gray-400 border-b border-gray-100">
                                    <th class="py-3 px-2">MÃ ĐƠN CON</th>
                                    <th class="py-3 px-2">NÔNG SẢN ĐẶT MUA</th>
                                    <th class="py-3 px-2">KHÁCH HÀNG &amp; ĐIỂM GIAO</th>
                                    <th class="py-3 px-2">KHUNG GIỜ HẸN</th>
                                    <th class="py-3 px-2 text-right">TRẠNG THÁI</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <!-- Order 1 -->
                                <tr class="order-row hover:bg-gray-50/60 transition" data-status="pack">
                                    <td class="py-3.5 px-2">
                                        <span class="font-extrabold text-emerald-800 block">#SUB-8821</span>
                                        <span class="text-[11px] text-gray-400">10:15 Sáng nay</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <div class="flex items-center gap-2.5">
                                            <img src="https://images.unsplash.com/photo-1543528176-61b239494933?w=80&fit=crop" alt="Dâu" class="w-9 h-9 rounded-xl object-cover shrink-0">
                                            <div>
                                                <strong class="font-bold text-gray-900 block leading-tight">Dâu Tây Tochiotome Nhật Bản</strong>
                                                <span class="text-[11px] text-gray-500">Hộp 500g &times; 2 hộp (1.0 kg)</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="font-bold text-gray-900 block">Chị Thu Trang</span>
                                        <span class="text-[11px] text-gray-400">Q. Bình Thạnh, TP.HCM</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full badge-express text-[10px] font-extrabold">
                                            <i class="fa-solid fa-bolt text-[9px]"></i> Hỏa tốc 2h
                                        </span>
                                    </td>
                                    <td class="py-3.5 px-2 text-right">
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-full badge-pack-now text-[11px] font-extrabold">
                                            Cần gói ngay
                                        </span>
                                    </td>
                                </tr>

                                <!-- Order 2 -->
                                <tr class="order-row hover:bg-gray-50/60 transition" data-status="pickup">
                                    <td class="py-3.5 px-2">
                                        <span class="font-extrabold text-emerald-800 block">#SUB-8818</span>
                                        <span class="text-[11px] text-gray-400">09:50 Sáng nay</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <div class="flex items-center gap-2.5">
                                            <img src="https://images.unsplash.com/photo-1557800636-894a64c1696f?w=80&fit=crop" alt="Bưởi" class="w-9 h-9 rounded-xl object-cover shrink-0">
                                            <div>
                                                <strong class="font-bold text-gray-900 block leading-tight">Bưởi Da Xanh Bến Tre OCOP</strong>
                                                <span class="text-[11px] text-gray-500">2 quả tuyển chọn (~3.2 kg)</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="font-bold text-gray-900 block">Anh Minh Đức</span>
                                        <span class="text-[11px] text-gray-400">Q. Cầu Giấy, Hà Nội</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="text-gray-600 text-[11px] block">Hôm nay</span>
                                        <strong class="text-gray-800 text-[11px]">14:00 - 16:00</strong>
                                    </td>
                                    <td class="py-3.5 px-2 text-right">
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-full badge-waiting-pickup text-[11px] font-extrabold">
                                            Chờ lấy hàng
                                        </span>
                                    </td>
                                </tr>

                                <!-- Order 3 -->
                                <tr class="order-row hover:bg-gray-50/60 transition" data-status="pickup">
                                    <td class="py-3.5 px-2">
                                        <span class="font-extrabold text-emerald-800 block">#SUB-8815</span>
                                        <span class="text-[11px] text-gray-400">08:30 Sáng nay</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <div class="flex items-center gap-2.5">
                                            <img src="https://images.unsplash.com/photo-1553279768-865429fa0078?w=80&fit=crop" alt="Xoài" class="w-9 h-9 rounded-xl object-cover shrink-0">
                                            <div>
                                                <strong class="font-bold text-gray-900 block leading-tight">Xoài Cát Chu Cao Lãnh Vàng</strong>
                                                <span class="text-[11px] text-gray-500">Thùng quà biếu 5kg (10 quả)</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="font-bold text-gray-900 block">Chị Hoàng Yến</span>
                                        <span class="text-[11px] text-gray-400">Q. 1, TP. Hồ Chí Minh</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="text-gray-600 text-[11px] block">Hôm nay</span>
                                        <strong class="text-gray-800 text-[11px]">15:00 - 17:00</strong>
                                    </td>
                                    <td class="py-3.5 px-2 text-right">
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-full badge-ready text-[11px] font-extrabold">
                                            Chuẩn bị xong
                                        </span>
                                    </td>
                                </tr>

                                <!-- Order 4 -->
                                <tr class="order-row hover:bg-gray-50/60 transition" data-status="delivering">
                                    <td class="py-3.5 px-2">
                                        <span class="font-extrabold text-emerald-800 block">#SUB-8810</span>
                                        <span class="text-[11px] text-gray-400">07:45 Sáng nay</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <div class="flex items-center gap-2.5">
                                            <img src="https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=80&fit=crop" alt="Chanh dây" class="w-9 h-9 rounded-xl object-cover shrink-0">
                                            <div>
                                                <strong class="font-bold text-gray-900 block leading-tight">Chanh Dây Vàng Ngọt Đà Lạt</strong>
                                                <span class="text-[11px] text-gray-500">Túi lưới hữu cơ 1kg</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="font-bold text-gray-900 block">Bác Quốc Hùng</span>
                                        <span class="text-[11px] text-gray-400">Q. Ba Đình, Hà Nội</span>
                                    </td>
                                    <td class="py-3.5 px-2">
                                        <span class="text-gray-600 text-[11px] block">Giao ngày mai</span>
                                        <span class="text-gray-400 text-[10px]">(Liên tỉnh)</span>
                                    </td>
                                    <td class="py-3.5 px-2 text-right">
                                        <span class="inline-flex items-center px-2.5 py-1 rounded-full badge-delivering text-[11px] font-extrabold">
                                            Đang giao hàng
                                        </span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Footer Link -->
                <div class="pt-4 border-t border-gray-100 flex items-center justify-between text-xs mt-3">
                    <span class="text-gray-400">Hiển thị 4 trong số 18 đơn hôm nay</span>
                    <a href="${pageContext.request.contextPath}/shop/orders" class="font-bold text-emerald-800 hover:underline inline-flex items-center gap-1">
                        Xem toàn bộ hàng đợi đơn <i class="fa-solid fa-arrow-right text-[10px]"></i>
                    </a>
                </div>
            </div>

            <!-- RIGHT 4 COLS: KỲ QUYẾT TOÁN GẦN NHẤT & VÍ NGƯỜI BÁN -->
            <div class="lg:col-span-4 space-y-6">

                <!-- Widget: Kỳ quyết toán gần nhất -->
                <div class="bg-white rounded-3xl p-6 border border-gray-100 shadow-xs space-y-4">
                    <div class="flex items-center justify-between pb-3 border-b border-gray-100">
                        <div>
                            <span class="text-[10px] font-extrabold uppercase text-gray-400 tracking-wider block">KỲ QUYẾT TOÁN GẦN NHẤT</span>
                            <h4 class="font-extrabold text-sm text-gray-900 mt-0.5">Kỳ 42 (05/10 - 11/10/2024)</h4>
                        </div>
                        <div class="w-8 h-8 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center text-xs">
                            <i class="fa-solid fa-circle-check text-sm"></i>
                        </div>
                    </div>

                    <div class="pt-1">
                        <span class="text-xs text-gray-500 block">Số tiền thực nhận về tài khoản</span>
                        <div class="text-3xl font-black text-emerald-800 tracking-tight mt-1">
                            ₫<fmt:formatNumber value="${payoutAmount}" pattern="#,###" />
                        </div>
                        <span class="text-[11px] text-emerald-700 font-semibold flex items-center gap-1.5 mt-2 bg-emerald-50 px-3 py-1.5 rounded-xl border border-emerald-100/60">
                            <i class="fa-regular fa-circle-check text-emerald-600"></i> Đã chuyển về Vietcombank (STK: 0882***99)
                        </span>
                    </div>

                    <div class="pt-3 border-t border-gray-100 space-y-2 text-xs text-gray-500">
                        <div class="flex items-center justify-between">
                            <span>Tổng giá trị đơn hàng con:</span>
                            <strong class="text-gray-900">₫<fmt:formatNumber value="${subOrderTotal}" pattern="#,###" /></strong>
                        </div>
                        <div class="flex items-center justify-between">
                            <span>Phí dịch vụ sàn (Take rate 5.0%):</span>
                            <strong class="text-red-500">-₫<fmt:formatNumber value="${feeAmount}" pattern="#,###" /></strong>
                        </div>
                        <div class="flex items-center justify-between pt-1">
                            <span>Trạng thái thanh toán:</span>
                            <span class="text-emerald-700 font-bold">Hoàn tất 100%</span>
                        </div>
                    </div>

                    <div class="pt-3">
                        <a href="${pageContext.request.contextPath}/shop/finance" class="block w-full py-2.5 rounded-2xl bg-emerald-50 hover:bg-emerald-100 text-emerald-800 font-extrabold text-xs text-center transition">
                            <i class="fa-solid fa-receipt mr-1"></i> Xem chi tiết ví &amp; sao kê
                        </a>
                    </div>
                </div>

            </div>
        </div>

        <!-- ========================================================
             5. BOTTOM SECTION: 7-DAY REVENUE CHART & TOP 3 PRODUCTS
             ======================================================== -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

            <!-- LEFT 8 COLS: DOANH THU & SẢN LƯỢNG ĐƠN 7 NGÀY QUA -->
            <div class="lg:col-span-8 bg-white rounded-3xl p-6 border border-gray-100 shadow-xs space-y-4">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <div>
                        <h3 class="text-base font-black text-gray-950">Doanh thu &amp; Sản lượng đơn 7 ngày qua</h3>
                        <p class="text-xs text-gray-500 mt-0.5">
                            Doanh thu đỉnh Thứ Bảy đạt <strong class="text-emerald-800">₫24.2M</strong> nhờ đợt hái dâu cuối tuần
                        </p>
                    </div>

                    <!-- Custom Legend -->
                    <div class="flex items-center gap-4 text-xs">
                        <div class="flex items-center gap-1.5">
                            <span class="w-3 h-3 rounded bg-emerald-700"></span>
                            <span class="text-gray-600 font-medium">Doanh thu (triệu đ)</span>
                        </div>
                        <div class="flex items-center gap-1.5">
                            <span class="w-3 h-1 bg-amber-600 rounded"></span>
                            <span class="text-gray-600 font-medium">Số đơn</span>
                        </div>
                    </div>
                </div>

                <!-- Mixed Chart Container -->
                <div class="chart-container">
                    <canvas id="revenueWeeklyChart"></canvas>
                </div>
            </div>

            <!-- RIGHT 4 COLS: TOP 3 NÔNG SẢN BÁN CHẠY -->
            <div class="lg:col-span-4 bg-white rounded-3xl p-6 border border-gray-100 shadow-xs flex flex-col justify-between">
                <div>
                    <div class="flex items-center justify-between pb-3 border-b border-gray-100">
                        <div>
                            <h3 class="font-black text-sm text-gray-950">Top 3 Nông Sản Bán Chạy</h3>
                            <span class="text-xs text-gray-400">Xếp hạng theo sản lượng &amp; doanh thu tuần</span>
                        </div>
                        <span class="px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-extrabold text-[10px]">Tuần 42</span>
                    </div>

                    <!-- Top 3 List -->
                    <div class="space-y-3.5 pt-4">
                        <!-- Top 1 -->
                        <div class="flex items-center gap-3">
                            <div class="w-6 h-6 rounded-lg bg-emerald-700 text-white font-black text-xs flex items-center justify-center shrink-0">
                                1
                            </div>
                            <img src="https://images.unsplash.com/photo-1543528176-61b239494933?w=80&fit=crop" alt="Dâu" class="w-11 h-11 rounded-xl object-cover shrink-0">
                            <div class="min-w-0 flex-1">
                                <h4 class="font-bold text-xs text-gray-900 truncate">Dâu Tây Tochiotome Đà Lạt</h4>
                                <div class="flex items-center justify-between text-xs mt-0.5">
                                    <span class="text-gray-400 text-[11px]">Đã bán: <strong class="text-gray-700">320 kg</strong></span>
                                    <strong class="text-emerald-800 font-black">₫83,200,000</strong>
                                </div>
                            </div>
                        </div>

                        <!-- Top 2 -->
                        <div class="flex items-center gap-3">
                            <div class="w-6 h-6 rounded-lg bg-gray-100 text-gray-600 font-black text-xs flex items-center justify-center shrink-0">
                                2
                            </div>
                            <img src="https://images.unsplash.com/photo-1557800636-894a64c1696f?w=80&fit=crop" alt="Bưởi" class="w-11 h-11 rounded-xl object-cover shrink-0">
                            <div class="min-w-0 flex-1">
                                <h4 class="font-bold text-xs text-gray-900 truncate">Bưởi Da Xanh Bến Tre</h4>
                                <div class="flex items-center justify-between text-xs mt-0.5">
                                    <span class="text-gray-400 text-[11px]">Đã bán: <strong class="text-gray-700">450 kg</strong></span>
                                    <strong class="text-emerald-800 font-black">₫49,500,000</strong>
                                </div>
                            </div>
                        </div>

                        <!-- Top 3 -->
                        <div class="flex items-center gap-3">
                            <div class="w-6 h-6 rounded-lg bg-gray-100 text-gray-600 font-black text-xs flex items-center justify-center shrink-0">
                                3
                            </div>
                            <img src="https://images.unsplash.com/photo-1553279768-865429fa0078?w=80&fit=crop" alt="Xoài" class="w-11 h-11 rounded-xl object-cover shrink-0">
                            <div class="min-w-0 flex-1">
                                <h4 class="font-bold text-xs text-gray-900 truncate">Xoài Cát Chu OCOP Cao Lãnh</h4>
                                <div class="flex items-center justify-between text-xs mt-0.5">
                                    <span class="text-gray-400 text-[11px]">Đã bán: <strong class="text-gray-700">280 kg</strong></span>
                                    <strong class="text-emerald-800 font-black">₫15,400,000</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="pt-4 border-t border-gray-100 flex items-center justify-between text-xs mt-4">
                    <span class="text-gray-400 text-[11px]">Chiếm 82% tổng lượng trái cây bán ra</span>
                    <a href="${pageContext.request.contextPath}/shop/analytics" class="font-bold text-emerald-800 hover:underline flex items-center gap-1">
                        Báo cáo phân tích sản phẩm <i class="fa-solid fa-arrow-right text-[10px]"></i>
                    </a>
                </div>
            </div>

        </div>

    </main>

</body>
</html>

