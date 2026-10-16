<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản Lý Đơn Hàng Con - FreshFruit Seller Center</title>

        <!-- Google Fonts & Font Awesome 6 -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-[#f8fafc] text-slate-800 antialiased min-h-screen flex m-0">

        <!-- ========================================================
             1. SIDEBAR NAVIGATION (KÊNH NGƯỜI BÁN - ĐỒNG BỘ CHUẨN)
             ======================================================== -->
        <aside class="w-64 shrink-0 bg-white border-r border-slate-200 h-screen sticky top-0 flex flex-col justify-between z-30 overflow-y-auto">
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
                            <h4 class="text-xs font-extrabold text-slate-900 leading-tight">${not empty sessionScope.shopName ? sessionScope.shopName : 'Mộc Châu Farm'}</h4>
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
                    <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center justify-between px-3 py-2.5 rounded-xl text-slate-600 hover:bg-slate-50 hover:text-emerald-700 font-semibold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-seedling text-slate-400 text-sm w-4 text-center"></i>
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
                    <a href="${pageContext.request.contextPath}/shop/orders" class="flex items-center justify-between px-3 py-2.5 rounded-xl bg-emerald-50 text-emerald-800 font-bold text-xs transition-all">
                        <span class="flex items-center gap-3">
                            <i class="fa-solid fa-receipt text-emerald-600 text-sm w-4 text-center"></i>
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
             2. MAIN CONTENT AREA
             ======================================================== -->
        <div class="flex-1 flex flex-col min-w-0">

            <!-- Topbar Header -->
            <header class="bg-white border-b border-slate-200 sticky top-0 z-20 px-6 py-2.5 flex items-center justify-between">
                <!-- Shop Selector -->
                <div class="flex items-center gap-3">
                    <div class="flex items-center gap-2 px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-xs font-semibold text-slate-800 shadow-2xs">
                        <i class="fa-solid fa-seedling text-emerald-600"></i>
                        <span>Nông Trại Hữu Cơ Mộc Châu - Gian hàng chính hãng</span>
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
                        <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop" 
                             alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-emerald-500">
                        <div class="hidden sm:block text-left text-xs">
                            <div class="font-bold text-slate-900 leading-tight">Chủ vườn Mộc Châu</div>
                            <div class="text-[10px] text-slate-400">mocchau@freshfruit.vn</div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Main Content Container -->
            <main class="flex-1 p-6 max-w-7xl w-full mx-auto space-y-5">

                <!-- Header & Action -->
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">Danh Sách Đơn Hàng Con (Shop Orders)</h1>
                        <p class="text-xs text-slate-500 mt-1">Theo dõi, xác nhận và đóng gói nông sản xuất xưởng cho khách hàng</p>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="${pageContext.request.contextPath}/shop/order-detail" class="px-4 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-xl text-xs font-bold transition shadow-xs flex items-center gap-2">
                            <i class="fa-solid fa-box-open"></i> Xem màn hình mẫu #SUB-98241
                        </a>
                    </div>
                </div>

                <!-- Status Filter Tabs -->
                <div class="flex items-center gap-2 overflow-x-auto pb-1 border-b border-slate-200 text-xs font-bold">
                    <a href="?status=ALL" class="px-4 py-2.5 border-b-2 transition ${currentTab eq 'ALL' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        Tất cả đơn
                    </a>
                    <a href="?status=NEW" class="px-4 py-2.5 border-b-2 transition ${currentTab eq 'NEW' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        Chờ xác nhận (Mới)
                    </a>
                    <a href="?status=PACKING" class="px-4 py-2.5 border-b-2 transition ${currentTab eq 'PACKING' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        Đang đóng gói
                    </a>
                    <a href="?status=SHIPPING" class="px-4 py-2.5 border-b-2 transition ${currentTab eq 'SHIPPING' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        Đang giao hàng
                    </a>
                    <a href="?status=DELIVERED" class="px-4 py-2.5 border-b-2 transition ${currentTab eq 'DELIVERED' ? 'border-emerald-600 text-emerald-700' : 'border-transparent text-slate-500 hover:text-slate-800'}">
                        Đã giao thành công
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
                                                    <div class="text-[11px] text-slate-400 truncate max-w-xs">${o.shippingAddress.city} - SĐT: ${o.shippingAddress.recipientPhone}</div>
                                                </td>
                                                <td class="py-3.5 px-4">
                                                    <c:forEach items="${o.items}" var="it" varStatus="st">
                                                        <div class="text-[11px] text-slate-700">
                                                            • <span class="font-semibold">${it.productNameSnapshot}</span> (x${it.quantity})
                                                        </div>
                                                    </c:forEach>
                                                </td>
                                                <td class="py-3.5 px-4 text-right">
                                                    <div class="font-black text-emerald-700">
                                                        <fmt:formatNumber value="${o.shopTotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>
                                                    <div class="text-[10px] text-slate-400">${o.paymentMethod}</div>
                                                </td>
                                                <td class="py-3.5 px-4 text-center">
                                                    <c:choose>
                                                        <c:when test="${o.status eq 'NEW'}">
                                                            <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-blue-50 text-blue-700 border border-blue-200">
                                                                Đơn mới
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
                                            <td colspan="7" class="py-8 text-center text-slate-400">
                                                Không có đơn hàng nào trong mục này.
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

