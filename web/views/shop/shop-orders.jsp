<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản Lý Đơn Hàng Con - Gốc Vườn Seller Center</title>

        <!-- Google Fonts & Font Awesome 6 -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Custom External Stylesheet & Script -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-orders.css">
        <script src="${pageContext.request.contextPath}/assets/js/shop-orders.js"></script>
    </head>
    <body class="bg-slate-50 text-slate-800 antialiased font-['Inter'] min-h-screen flex m-0">

        <!-- ========================================================
             1. SIDEBAR NAVIGATION
             ======================================================== -->
        <aside class="w-64 shrink-0 bg-white border-r border-slate-200 h-screen sticky top-0 flex flex-col justify-between z-30 overflow-y-auto">
            <div>
                <!-- Shop Brand Header -->
                <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-full overflow-hidden shrink-0 border-2 border-emerald-500 shadow-xs">
                            <c:choose>
                                <c:when test="${not empty sessionScope.shopLogo}">
                                    <img src="${sessionScope.shopLogo}" alt="Shop Avatar" class="w-full h-full object-cover">
                                </c:when>
                                <c:otherwise>
                                    <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" alt="Default Avatar" class="w-full h-full object-cover">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <h4 class="text-xs font-extrabold text-slate-900 leading-tight">
                                ${not empty sessionScope.shopName ? sessionScope.shopName : 'Mộc Châu Farm'}
                            </h4>
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
                    <a href="${pageContext.request.contextPath}/shop/products" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-chart-pie text-slate-400 text-sm w-4 text-center"></i>
                            <span>Tổng quan Shop</span>
                        </span>
                    </a>

                    <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">SẢN PHẨM & KHO</div>
                    <a href="${pageContext.request.contextPath}/shop/products" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-seedling text-slate-400 text-sm w-4 text-center"></i>
                            <span>Tất cả sản phẩm</span>
                        </span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/product/add" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-circle-plus text-slate-400 text-sm w-4 text-center"></i>
                            <span>Thêm mới nông sản</span>
                        </span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/inventory" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-warehouse text-slate-400 text-sm w-4 text-center"></i>
                            <span>Kho & Cảnh báo tồn</span>
                        </span>
                        <span class="px-2 py-0.5 bg-rose-100 text-rose-700 text-[10px] font-bold rounded-full">${not empty lowStockCount ? lowStockCount : 3}</span>
                    </a>

                    <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">ĐƠN HÀNG</div>
                    <a href="${pageContext.request.contextPath}/shop/orders" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl bg-emerald-50 text-emerald-800 font-bold text-xs transition-all border border-emerald-200/60 shadow-2xs">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-receipt text-emerald-600 text-sm w-4 text-center"></i>
                            <span>Đơn hàng con</span>
                        </span>
                        <span class="px-2 py-0.5 bg-amber-100 text-amber-800 text-[10px] font-bold rounded-full">8</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/shipping" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-truck-ramp-box text-slate-400 text-sm w-4 text-center"></i>
                            <span>Đóng gói & Vận đơn</span>
                        </span>
                    </a>

                    <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">TIẾP THỊ & KHÁCH</div>
                    <a href="${pageContext.request.contextPath}/shop/coupons" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-tags text-slate-400 text-sm w-4 text-center"></i>
                            <span>Mã giảm giá Shop</span>
                        </span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/reviews" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-star-half-stroke text-slate-400 text-sm w-4 text-center"></i>
                            <span>Đánh giá từ khách</span>
                        </span>
                    </a>

                    <div class="text-[10px] uppercase tracking-wider text-slate-400 px-3 pt-2 font-extrabold">HỆ THỐNG</div>
                    <a href="${pageContext.request.contextPath}/shop/finance" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-wallet text-slate-400 text-sm w-4 text-center"></i>
                            <span>Doanh thu & Rút tiền</span>
                        </span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shop/settings" 
                       class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-sliders text-slate-400 text-sm w-4 text-center"></i>
                            <span>Cài đặt Shop</span>
                        </span>
                    </a>
                </nav>
            </div>

            <!-- Bottom User Bar & Logout -->
            <div class="p-3 border-t border-slate-200">
                <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-3 py-2 rounded-xl text-rose-600 hover:bg-rose-50 hover:text-rose-700 font-semibold text-xs transition-all">
                    <i class="fa-solid fa-power-off text-xs w-4 text-center"></i>
                    <span>Đăng xuất</span>
                </a>
            </div>
        </aside>

        <!-- ========================================================
             2. MAIN CONTENT AREA
             ======================================================== -->
        <div class="flex-1 flex flex-col min-w-0 overflow-y-auto">

            <!-- Top Header -->
            <header class="bg-white border-b border-slate-200 sticky top-0 z-20 px-6 py-2.5 flex items-center justify-between shadow-2xs">
                <!-- Shop Selector -->
                <div class="flex items-center gap-3">
                    <div class="flex items-center gap-2 px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-xs font-semibold text-slate-800 shadow-2xs">
                        <i class="fa-solid fa-seedling text-emerald-600"></i>
                        <span>${not empty sessionScope.shopName ? sessionScope.shopName : 'Nông Trại Hữu Cơ Mộc Châu - Gian hàng chính hãng'}</span>
                        <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 ml-1"></i>
                    </div>
                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                        Đang hoạt động
                    </span>
                </div>

                <!-- Right Profile -->
                <div class="flex items-center gap-3">
                    <div class="flex items-center gap-2.5">
                        <c:choose>
                            <c:when test="${not empty sessionScope.userAvatar}">
                                <img src="${sessionScope.userAvatar}" alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-emerald-500">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" 
                                     alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-emerald-500">
                            </c:otherwise>
                        </c:choose>
                        <div class="hidden sm:block text-left text-xs">
                            <div class="font-bold text-slate-900 leading-tight">
                                ${not empty sessionScope.userfullname ? sessionScope.userfullname : 'Chủ vườn Mộc Châu'}
                            </div>
                            <div class="text-[10px] text-slate-400">
                                ${not empty sessionScope.email ? sessionScope.email : 'mocchau@gocvuon.vn'}
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Main Content Container -->
            <main class="flex-1 p-6 max-w-7xl w-full mx-auto space-y-5">

                <!-- Header & Search Bar -->
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">Danh Sách Đơn Hàng Con (Shop Orders)</h1>
                        <p class="text-xs text-slate-500 mt-1">Theo dõi, xác nhận và đóng gói nông sản xuất xưởng cho khách hàng</p>
                    </div>

                    <!-- Search Form -->
                    <form method="GET" action="${pageContext.request.contextPath}/shop/orders" class="flex items-center gap-2 self-start md:self-center">
                        <input type="hidden" name="status" value="${currentTab}">
                        <div class="relative">
                            <i class="fa-solid fa-magnifying-glass absolute left-3 top-2.5 text-slate-400 text-xs"></i>
                            <input type="text" name="keyword" value="${keyword}" placeholder="Mã đơn con, đơn tổng, người nhận..." 
                                   class="pl-8 pr-4 py-2 rounded-xl border border-slate-200 bg-white text-xs w-64 lg:w-72 focus:outline-none focus:border-emerald-500 shadow-2xs">
                        </div>
                        <button type="submit" class="px-3.5 py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs transition shadow-2xs flex items-center gap-1.5">
                            Tìm
                        </button>
                        <c:if test="${not empty keyword}">
                            <a href="?status=${currentTab}" class="text-xs text-rose-600 hover:underline px-1 font-semibold" title="Xóa tìm kiếm">
                                <i class="fa-solid fa-xmark"></i>
                            </a>
                        </c:if>
                    </form>
                </div>

                <!-- Status Filter Tabs with Counts -->
                <div class="flex items-center gap-1 overflow-x-auto pb-1 border-b border-slate-200 text-xs font-bold">
                    <a href="?status=ALL${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2.5 border-b-2 transition flex items-center gap-2 ${currentTab eq 'ALL' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        <span>Tất cả đơn</span>
                        <span class="px-1.5 py-0.5 rounded-full text-[10px] ${currentTab eq 'ALL' ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'}">${countAll}</span>
                    </a>
                    <a href="?status=NEW${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2.5 border-b-2 transition flex items-center gap-2 ${currentTab eq 'NEW' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        <span>Chờ xác nhận (Mới)</span>
                        <span class="px-1.5 py-0.5 rounded-full text-[10px] ${currentTab eq 'NEW' ? 'bg-blue-100 text-blue-800' : 'bg-slate-100 text-slate-600'}">${countNew}</span>
                    </a>
                    <a href="?status=PACKING${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2.5 border-b-2 transition flex items-center gap-2 ${currentTab eq 'PACKING' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        <span>Đang đóng gói</span>
                        <span class="px-1.5 py-0.5 rounded-full text-[10px] ${currentTab eq 'PACKING' ? 'bg-amber-100 text-amber-800' : 'bg-slate-100 text-slate-600'}">${countPacking}</span>
                    </a>
                    <a href="?status=SHIPPING${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2.5 border-b-2 transition flex items-center gap-2 ${currentTab eq 'SHIPPING' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        <span>Đang giao hàng</span>
                        <span class="px-1.5 py-0.5 rounded-full text-[10px] ${currentTab eq 'SHIPPING' ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'}">${countShipping}</span>
                    </a>
                    <a href="?status=DELIVERED${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2.5 border-b-2 transition flex items-center gap-2 ${currentTab eq 'DELIVERED' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        <span>Đã giao thành công</span>
                        <span class="px-1.5 py-0.5 rounded-full text-[10px] ${currentTab eq 'DELIVERED' ? 'bg-teal-100 text-teal-800' : 'bg-slate-100 text-slate-600'}">${countDelivered}</span>
                    </a>
                    <a href="?status=CANCELLED${not empty keyword ? '&keyword=' += keyword : ''}" 
                       class="px-3.5 py-2.5 border-b-2 transition flex items-center gap-2 ${currentTab eq 'CANCELLED' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        <span>Đã hủy</span>
                        <span class="px-1.5 py-0.5 rounded-full text-[10px] ${currentTab eq 'CANCELLED' ? 'bg-rose-100 text-rose-800' : 'bg-slate-100 text-slate-600'}">${countCancelled}</span>
                    </a>
                </div>

                <!-- Orders Table Card -->
                <div class="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-xs">
                            <thead class="bg-slate-50/80 border-b border-slate-200 text-slate-400 font-extrabold text-[11px]">
                                <tr>
                                    <th class="py-3 px-4">MÃ ĐƠN CON</th>
                                    <th class="py-3 px-4">ĐƠN TỔNG</th>
                                    <th class="py-3 px-4">KHÁCH HÀNG & ĐỊA CHỈ</th>
                                    <th class="py-3 px-4">SẢN PHẨM MUA</th>
                                    <th class="py-3 px-4 text-right">TỔNG TIỀN</th>
                                    <th class="py-3 px-4 text-center">TRẠNG THÁI</th>
                                    <th class="py-3 px-4 text-center">THAO TÁC</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100">
                                <c:choose>
                                    <c:when test="${not empty orderList}">
                                        <c:forEach items="${orderList}" var="o">
                                            <tr class="hover:bg-slate-50/60 transition">
                                                <td class="py-3.5 px-4 font-extrabold text-slate-900">
                                                    <span class="text-emerald-700">#${o.subOrderCode}</span>
                                                    <span class="block text-[10px] text-slate-400 font-normal">
                                                        <fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </span>
                                                </td>
                                                <td class="py-3.5 px-4 font-bold text-slate-600">
                                                    #${o.orderCode}
                                                </td>
                                                <td class="py-3.5 px-4">
                                                    <div class="font-bold text-slate-900">${o.shippingAddress.recipientName}</div>
                                                    <div class="text-[11px] text-slate-400 truncate max-w-xs">
                                                        ${o.shippingAddress.city} • SĐT: ${o.shippingAddress.recipientPhone}
                                                    </div>
                                                </td>
                                                <td class="py-3.5 px-4">
                                                    <c:forEach items="${o.items}" var="it" varStatus="st">
                                                        <div class="text-[11px] text-slate-700 leading-snug">
                                                            • <span class="font-semibold text-slate-900">${it.productNameSnapshot}</span> (x${it.quantity} ${it.unit})
                                                        </div>
                                                    </c:forEach>
                                                </td>
                                                <td class="py-3.5 px-4 text-right">
                                                    <div class="font-black text-emerald-700">
                                                        <fmt:formatNumber value="${o.shopTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                    </div>
                                                    <div class="text-[10px] text-slate-400">${o.paymentMethod}</div>
                                                </td>
                                                <td class="py-3.5 px-4 text-center">
                                                    <c:choose>
                                                        <c:when test="${o.status eq 'NEW'}">
                                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200">
                                                                Chờ xác nhận
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${o.status eq 'PACKING'}">
                                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                                                Đang đóng gói
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${o.status eq 'SHIPPING'}">
                                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                                Đang giao hàng
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${o.status eq 'DELIVERED' or o.status eq 'COMPLETED'}">
                                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-teal-50 text-teal-700 border border-teal-200">
                                                                Đã giao thành công
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${o.status eq 'CANCELLED'}">
                                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                                                                Đã hủy
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-slate-100 text-slate-700">
                                                                ${o.status}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="py-3.5 px-4 text-center">
                                                    <a href="${pageContext.request.contextPath}/shop/order-detail?code=${o.subOrderCode}" 
                                                       class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-50 hover:bg-emerald-100 text-emerald-700 font-bold text-xs transition border border-emerald-200 shadow-2xs">
                                                        <i class="fa-solid fa-box-open text-[11px]"></i> Chi tiết đóng gói
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="py-12 text-center text-slate-400">
                                                <i class="fa-regular fa-folder-open text-2xl text-slate-300 mb-2 block"></i>
                                                <span class="text-xs font-medium">Không có đơn hàng nào trong mục này.</span>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

            </main>
        </div>
    </body>
</html>
