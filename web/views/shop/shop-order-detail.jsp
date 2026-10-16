<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chi Tiết Đơn Hàng Con #${subOrder.subOrderCode} | FreshFruit Seller Center</title>

        <!-- Google Fonts Inter -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Font Awesome 6 Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

        <!-- Custom Order Detail CSS & JS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shop-order-detail.css">
        <script src="${pageContext.request.contextPath}/assets/js/shop-order-detail.js"></script>
    </head>

    <body class="bg-slate-50 text-slate-800 antialiased font-['Inter'] min-h-screen flex">

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
            <header class="h-16 bg-white border-b border-slate-200 px-6 flex items-center justify-between sticky top-0 z-20 shadow-2xs">
                <!-- Shop Selector -->
                <div class="flex items-center gap-3">
                    <div class="flex items-center gap-2 px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-xs font-semibold text-slate-800 shadow-2xs cursor-pointer hover:border-emerald-500 transition">
                        <i class="fa-solid fa-seedling text-emerald-600"></i>
                        <span>${not empty sessionScope.shopName ? sessionScope.shopName : (not empty subOrder.shopName ? subOrder.shopName : 'Nông Trại Hữu Cơ Mộc Châu - Gian hàng chính hãng')}</span>
                        <i class="fa-solid fa-chevron-down text-[10px] text-slate-400 ml-1"></i>
                    </div>
                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                        Đang hoạt động
                    </span>
                </div>

                <!-- Right Notifications & Profile -->
                <div class="flex items-center gap-3">
                    <button class="relative w-8 h-8 rounded-full border border-slate-200 flex items-center justify-center text-slate-600 hover:bg-slate-50 transition" title="Thông báo">
                        <i class="fa-regular fa-bell text-xs"></i>
                        <span class="absolute top-1 right-1 w-2 h-2 rounded-full bg-red-500"></span>
                    </button>
                    <button class="w-8 h-8 rounded-full border border-slate-200 flex items-center justify-center text-slate-600 hover:bg-slate-50 transition" title="Tin nhắn">
                        <i class="fa-regular fa-comment text-xs"></i>
                    </button>
                    <div class="h-5 w-px bg-slate-200 mx-1"></div>
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
                                ${not empty sessionScope.email ? sessionScope.email : 'seller@freshfruit.vn'}
                            </div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Main Content Container -->
            <main class="flex-1 p-6 max-w-7xl w-full mx-auto space-y-5">

                <!-- Breadcrumb & Back Link -->
                <div class="flex items-center justify-between text-xs text-slate-500">
                    <div class="flex items-center gap-2">
                        <a href="${pageContext.request.contextPath}/shop/products" class="hover:text-emerald-700 transition">Kênh Người Bán</a>
                        <span>&gt;</span>
                        <a href="${pageContext.request.contextPath}/shop/orders" class="hover:text-emerald-700 transition">Quản lý đơn hàng</a>
                        <span>&gt;</span>
                        <span class="font-bold text-slate-800">Chi tiết đơn con #${subOrder.subOrderCode}</span>
                    </div>
                    <a href="${pageContext.request.contextPath}/shop/orders" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-slate-200 bg-white text-xs font-semibold text-slate-600 hover:bg-slate-50 hover:text-emerald-700 transition shadow-2xs">
                        <i class="fa-solid fa-arrow-left text-[10px]"></i> Quay lại danh sách
                    </a>
                </div>

                <!-- Page Header: Title, Tags & Simulator Switches -->
                <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
                    <div>
                        <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">
                            Chi tiết đơn hàng con: #${subOrder.subOrderCode}
                        </h1>
                        <div class="flex flex-wrap items-center gap-2.5 mt-2 text-xs">
                            <span class="px-2.5 py-1 rounded-md bg-slate-100 text-slate-700 font-bold border border-slate-200">
                                Đơn Tổng: #${subOrder.orderCode}
                            </span>
                            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-md bg-emerald-50 text-emerald-700 font-bold border border-emerald-200">
                                <i class="fa-solid fa-snowflake text-[10px] text-emerald-600"></i> ${not empty subOrder.deliverySlot ? subOrder.deliverySlot : 'Cold - Chain Express'}
                            </span>
                            <span class="text-slate-500 font-medium">
                                <i class="fa-regular fa-clock text-slate-400 mr-1"></i> 
                                <fmt:formatDate value="${subOrder.createdAt}" pattern="HH:mm dd/MM/yyyy" />
                            </span>
                            <span class="text-slate-500 font-medium">
                                <i class="fa-solid fa-globe text-slate-400 mr-1"></i> Kênh: Web Khách Hàng
                            </span>
                            <span class="font-extrabold text-amber-700 bg-amber-50 px-2 py-0.5 rounded border border-amber-200">
                                ${subOrder.paymentMethod}: <fmt:formatNumber value="${subOrder.shopTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                            </span>
                        </div>
                    </div>

                    <!-- Simulation Switcher Buttons (Top-Right) -->
                    <div class="flex items-center gap-1.5 bg-white p-1.5 rounded-xl border border-slate-200 shadow-2xs self-start lg:self-center overflow-x-auto">
                        <span class="text-[11px] font-bold text-slate-400 px-2 whitespace-nowrap">Mô phỏng:</span>
                        <a href="?code=${subOrder.subOrderCode}&status=NEW" 
                           class="px-2.5 py-1.5 rounded-lg text-xs font-bold transition whitespace-nowrap ${subOrder.status eq 'NEW' ? 'bg-amber-500 text-white shadow-xs' : 'text-slate-600 hover:bg-slate-100'}">
                            1. Đơn Mới
                        </a>
                        <a href="?code=${subOrder.subOrderCode}&status=PACKING" 
                           class="px-2.5 py-1.5 rounded-lg text-xs font-bold transition whitespace-nowrap ${subOrder.status eq 'PACKING' or empty subOrder.status ? 'bg-emerald-600 text-white shadow-xs' : 'text-slate-600 hover:bg-slate-100'}">
                            2. Đóng gói
                        </a>
                        <a href="?code=${subOrder.subOrderCode}&status=SHIPPING" 
                           class="px-2.5 py-1.5 rounded-lg text-xs font-bold transition whitespace-nowrap ${subOrder.status eq 'SHIPPING' ? 'bg-emerald-600 text-white shadow-xs' : 'text-slate-600 hover:bg-slate-100'}">
                            3. Sẵn sàng
                        </a>
                        <a href="?code=${subOrder.subOrderCode}&status=CANCELLED" 
                           class="px-2.5 py-1.5 rounded-lg text-xs font-bold transition whitespace-nowrap ${subOrder.status eq 'CANCELLED' ? 'bg-rose-600 text-white shadow-xs' : 'text-rose-600 hover:bg-rose-50'}">
                            4. Đã Hủy
                        </a>
                    </div>
                </div>

                <!-- ========================================================
                     3. 5-STEP ORDER PROGRESS STEPPER
                     ======================================================== -->
                <div class="bg-white rounded-2xl border border-slate-200 p-5 shadow-xs">
                    <div class="flex items-start justify-between relative">
                        <!-- Step 1: Đã tạo đơn -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full bg-emerald-600 text-white flex items-center justify-center font-bold text-sm shadow-sm ring-4 ring-emerald-50">
                                <i class="fa-solid fa-check"></i>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs text-slate-900">Đã Tạo Đơn Con</div>
                            <div class="text-[11px] text-slate-400 mt-0.5"><fmt:formatDate value="${subOrder.createdAt}" pattern="HH:mm dd/MM" /></div>
                        </div>

                        <!-- Step 2: Shop Xác nhận / Hủy đơn -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <c:choose>
                                <c:when test="${subOrder.status eq 'CANCELLED'}">
                                    <div class="w-9 h-9 rounded-full bg-rose-600 text-white ring-4 ring-rose-100 flex items-center justify-center font-bold text-sm shadow-sm">
                                        <i class="fa-solid fa-ban"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-rose-600">Đã Hủy Đơn</div>
                                    <div class="text-[11px] text-rose-500 font-semibold mt-0.5">Hết hàng / Quả hỏng</div>
                                </c:when>
                                <c:when test="${subOrder.status eq 'NEW'}">
                                    <div class="w-9 h-9 rounded-full bg-amber-500 text-white ring-4 ring-amber-100 flex items-center justify-center font-bold text-sm shadow-sm animate-pulse">
                                        <i class="fa-solid fa-clock"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-amber-700">Chờ Shop Duyệt</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Kiểm định tồn kho</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-9 h-9 rounded-full bg-emerald-600 text-white ring-4 ring-emerald-50 flex items-center justify-center font-bold text-sm shadow-sm">
                                        <i class="fa-solid fa-check"></i>
                                    </div>
                                    <div class="mt-2.5 font-extrabold text-xs text-slate-900">Shop Xác Nhận</div>
                                    <div class="text-[11px] text-slate-400 mt-0.5">Tiếp nhận nông sản</div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Step 3: Đang đóng gói -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full ${subOrder.status eq 'PACKING' ? 'bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110' : (subOrder.status eq 'SHIPPING' or subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED' ? 'bg-emerald-600 text-white ring-4 ring-emerald-50' : 'bg-slate-200 text-slate-400')} flex items-center justify-center font-bold text-sm">
                                <c:choose>
                                    <c:when test="${subOrder.status eq 'SHIPPING' or subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED'}"><i class="fa-solid fa-check"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-box-open"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs ${subOrder.status eq 'PACKING' ? 'text-emerald-700' : 'text-slate-900'}">Đang Đóng Gói</div>
                            <div class="text-[11px] ${subOrder.status eq 'PACKING' ? 'text-emerald-700 font-semibold' : 'text-slate-400'} mt-0.5">QC độ tươi &amp; đá gel</div>
                        </div>

                        <!-- Step 4: Chờ bàn giao tài xế -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full ${subOrder.status eq 'SHIPPING' ? 'bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110' : (subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED' ? 'bg-emerald-600 text-white' : 'bg-slate-200 text-slate-400')} flex items-center justify-center font-bold text-sm">
                                <c:choose>
                                    <c:when test="${subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED'}"><i class="fa-solid fa-check"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-truck-fast"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs ${subOrder.status eq 'SHIPPING' ? 'text-emerald-700' : 'text-slate-400'}">Chờ Bàn Giao Xe Lạnh</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Xe lạnh tiếp nhận</div>
                        </div>

                        <!-- Step 5: Hoàn tất -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full ${subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED' ? 'bg-emerald-600 text-white ring-4 ring-emerald-50' : 'bg-slate-200 text-slate-400'} flex items-center justify-center font-bold text-sm">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs text-slate-400">Giao Thành Công</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Đã tới tay khách</div>
                        </div>

                        <!-- Background Connection Line -->
                        <div class="absolute top-4 left-16 right-16 h-1 bg-slate-200 -z-0">
                            <div class="h-full ${subOrder.status eq 'CANCELLED' ? 'bg-rose-500' : 'bg-emerald-600'} transition-all duration-500" 
                                 style="width: ${subOrder.status eq 'CANCELLED' ? '25%' : (subOrder.status eq 'NEW' ? '25%' : (subOrder.status eq 'PACKING' ? '50%' : (subOrder.status eq 'SHIPPING' ? '75%' : '100%')))}"></div>
                        </div>
                    </div>
                </div>

                <!-- ========================================================
                     4. TWO-COLUMN LAYOUT: MAIN WORKFLOW & SIDE INFO
                     ======================================================== -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

                    <!-- ================= LEFT COLUMN (8 COLS) ================= -->
                    <div class="lg:col-span-8 space-y-5">

                        <!-- ========================================================
                             FULFILLMENT ACTION CARD (ALIGNED WITH ACTIVITY DIAGRAM)
                             ======================================================== -->
                        <c:choose>
                            <%-- CASE 1: ĐƠN ĐÃ BỊ HỦY (CANCELLED) --%>
                            <c:when test="${subOrder.status eq 'CANCELLED'}">
                                <div class="bg-white rounded-2xl border border-rose-200 p-6 shadow-xs bg-rose-50/20">
                                    <div class="flex items-start gap-4">
                                        <div class="w-11 h-11 rounded-2xl bg-rose-100 text-rose-600 flex items-center justify-center text-xl font-bold shrink-0 shadow-2xs border border-rose-200">
                                            <i class="fa-solid fa-ban"></i>
                                        </div>
                                        <div class="flex-1 min-w-0">
                                            <div class="flex flex-wrap items-center justify-between gap-2 pb-3 border-b border-rose-100">
                                                <div class="flex items-center gap-2">
                                                    <h2 class="text-base font-extrabold text-rose-950">Đơn Hàng Con Đã Bị Hủy</h2>
                                                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-black bg-rose-100 text-rose-700 border border-rose-300 uppercase">
                                                        CANCELLED
                                                    </span>
                                                </div>
                                                <c:if test="${not empty subOrder.cancelledAt}">
                                                    <span class="text-xs text-rose-600 font-medium">
                                                        <i class="fa-regular fa-clock mr-1"></i>
                                                        <fmt:formatDate value="${subOrder.cancelledAt}" pattern="HH:mm dd/MM/yyyy" />
                                                    </span>
                                                </c:if>
                                            </div>

                                            <div class="mt-3 p-3.5 rounded-xl bg-white border border-rose-200/90 text-xs space-y-1.5 shadow-2xs">
                                                <div class="font-extrabold text-rose-800 flex items-center gap-1.5">
                                                    <i class="fa-solid fa-triangle-exclamation text-rose-600"></i> Lý do hủy đơn từ Gian hàng:
                                                </div>
                                                <div class="text-slate-800 leading-relaxed font-semibold pl-4 border-l-2 border-rose-300">
                                                    ${not empty subOrder.cancelReason ? subOrder.cancelReason : 'Nông sản không đủ số lượng tồn kho hoặc không đạt chuẩn chất lượng tươi VietGAP.'}
                                                </div>
                                            </div>

                                            <div class="mt-3 flex items-start gap-2.5 text-xs text-emerald-900 bg-emerald-50 border border-emerald-200 p-3 rounded-xl">
                                                <i class="fa-solid fa-circle-check text-emerald-600 text-sm mt-0.5"></i>
                                                <div class="leading-relaxed">
                                                    <b>Tiến trình hệ thống tự động:</b> Hệ thống FreshFruit đã gửi thông báo hủy đến khách hàng và kích hoạt quy trình hoàn tiền tự động theo chính sách sàn.
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>

                            <%-- CASE 2: ĐƠN MỚI CHỜ DUYỆT (NEW) --%>
                            <c:when test="${subOrder.status eq 'NEW'}">
                                <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                                    <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                        <div class="flex items-center gap-2.5">
                                            <div class="w-8 h-8 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-sm font-bold border border-amber-200">
                                                <i class="fa-solid fa-clipboard-question"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Kiểm Tra Nông Sản &amp; Tiếp Nhận Đơn Hàng</h2>
                                                <p class="text-[11px] text-slate-400">Kiểm tra thực tế kho bảo quản trước khi xác nhận</p>
                                            </div>
                                        </div>
                                        <span class="px-3 py-1 rounded-full text-xs font-extrabold bg-amber-50 text-amber-700 border border-amber-200 animate-pulse">
                                            Đơn mới chờ xác nhận
                                        </span>
                                    </div>

                                    <!-- Decision Prompt matching Activity Diagram -->
                                    <div class="mt-4 p-4 rounded-xl bg-slate-50 border border-slate-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                                        <div class="flex items-center gap-3">
                                            <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center text-lg font-bold shrink-0">
                                                <i class="fa-solid fa-leaf"></i>
                                            </div>
                                            <div>
                                                <div class="text-xs font-black text-slate-900">
                                                    Nông sản tươi có sẵn &amp; đạt chuẩn chất lượng? (Fresh fruit available &amp; qualified?)
                                                </div>
                                                <div class="text-[11px] text-slate-500 mt-0.5">
                                                    Kiểm tra số lượng tồn kho lạnh và chất lượng quả tươi đạt chuẩn trước khi tiếp nhận đóng gói.
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Decision Actions (Yes vs No) -->
                                    <div class="mt-5 grid grid-cols-1 sm:grid-cols-2 gap-3">
                                        <!-- Option YES: Confirm Sub-order -->
                                        <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="m-0">
                                            <input type="hidden" name="action" value="confirm">
                                            <input type="hidden" name="code" value="${subOrder.subOrderCode}">
                                            <button type="submit" class="w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-xs transition shadow-2xs flex items-center justify-center gap-2 cursor-pointer">
                                                <i class="fa-solid fa-check"></i>
                                                <span>Đạt Chuẩn - Tiếp Nhận &amp; Đóng Gói</span>
                                            </button>
                                        </form>

                                        <!-- Option NO: Cancel Sub-order -->
                                        <button type="button" class="btn-open-cancel-modal w-full py-3 px-4 rounded-xl bg-white hover:bg-rose-50 text-rose-600 border border-rose-300 hover:border-rose-400 font-extrabold text-xs transition flex items-center justify-center gap-2 cursor-pointer">
                                            <i class="fa-solid fa-ban"></i>
                                            <span>Hết Hàng / Quả Hỏng - Hủy Đơn</span>
                                        </button>
                                    </div>
                                </div>
                            </c:when>

                            <%-- CASE 3: ĐANG ĐÓNG GÓI (PACKING) --%>
                            <c:when test="${subOrder.status eq 'PACKING' or empty subOrder.status}">
                                <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                                    <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                        <div class="flex items-center gap-2.5">
                                            <div class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-sm font-bold">
                                                <i class="fa-solid fa-box-open"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Quy Chuẩn Kiểm Soát Đóng Gói Lạnh</h2>
                                                <p class="text-[11px] text-slate-400">Kiểm tra và tick chọn 4 tiêu chuẩn bảo quản xuất xưởng</p>
                                            </div>
                                        </div>
                                        <span id="qcProgressBadge" class="px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200/60">
                                            Bắt buộc hoàn thành <span id="qcCount">3</span>/4
                                        </span>
                                    </div>

                                    <!-- 4 Checklist Items -->
                                    <div class="mt-4 space-y-3">
                                        <!-- Item 1 -->
                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none is-checked">
                                            <input type="checkbox" checked class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã kiểm tra chất lượng &amp; loại bỏ quả dập/hỏng</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">Soi kỹ bề mặt vỏ, kiểm tra độ đàn hồi, loại bỏ toàn bộ quả thâm úng để bảo quản lạnh an toàn.</div>
                                            </div>
                                        </label>

                                        <!-- Item 2 -->
                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none is-checked">
                                            <input type="checkbox" checked class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã cân đủ trọng lượng tịnh &amp; kiểm tra số lượng</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">
                                                    Chi tiết đóng gói: 
                                                    <c:forEach items="${subOrder.items}" var="it" varStatus="st">
                                                        <span class="font-medium text-slate-800">${it.productNameSnapshot} (x${it.quantity} ${it.unit})</span>${!st.last ? ', ' : ''}
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </label>

                                        <!-- Item 3 -->
                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none is-checked">
                                            <input type="checkbox" checked class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã đóng gói thùng xốp chuyên dụng &amp; chèn túi đá gel bảo ôn mát</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">Đặt túi đá gel cách nhiệt có vách ngăn xốp chống đọng ẩm trực tiếp lên quả tươi.</div>
                                            </div>
                                        </label>

                                        <!-- Item 4 -->
                                        <label class="qc-check-label flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                            <input type="checkbox" class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                            <div class="flex-1 text-xs">
                                                <div class="font-bold text-slate-900">Đã dán tem niêm phong và mã vận đơn #${subOrder.subOrderCode}</div>
                                                <div class="text-slate-500 text-[11px] mt-0.5">Mã barcode ${subOrder.trackingNumber} in rõ nét trên nắp thùng và mặt bên.</div>
                                            </div>
                                        </label>
                                    </div>

                                    <!-- Finish Packaging Action -->
                                    <div class="mt-4 pt-3 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs border-t border-slate-100">
                                        <button type="button" class="btn-open-cancel-modal text-rose-600 hover:text-rose-700 font-bold text-xs inline-flex items-center gap-1.5 cursor-pointer">
                                            <i class="fa-solid fa-triangle-exclamation"></i> Phát hiện hàng lỗi hỏng không đủ cung cấp? Hủy đơn
                                        </button>
                                        <div class="flex items-center gap-1.5 text-emerald-700 font-semibold text-[11px]">
                                            <i class="fa-solid fa-shield-check text-emerald-600"></i> Bảo chứng chất lượng VietGAP &amp; OCOP
                                        </div>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="mt-3">
                                        <input type="hidden" name="action" value="ready_to_ship">
                                        <input type="hidden" name="code" value="${subOrder.subOrderCode}">
                                        <button type="submit" id="btnFinishPacking" class="w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-sm transition shadow-sm flex items-center justify-center gap-2 cursor-pointer">
                                            <i class="fa-solid fa-box-check"></i> Hoàn tất đóng gói &amp; Báo sẵn sàng giao
                                        </button>
                                    </form>
                                </div>
                            </c:when>

                            <%-- CASE 4: SẴN SÀNG GIAO / CHỜ XE LẠNH (SHIPPING & BEYOND) --%>
                            <c:otherwise>
                                <div class="bg-white rounded-2xl border border-emerald-200 p-6 shadow-xs bg-emerald-50/20">
                                    <div class="flex items-center justify-between pb-3 border-b border-emerald-100">
                                        <div class="flex items-center gap-2.5">
                                            <div class="w-8 h-8 rounded-lg bg-emerald-600 text-white flex items-center justify-center text-sm font-bold shadow-xs">
                                                <i class="fa-solid fa-truck-fast"></i>
                                            </div>
                                            <div>
                                                <h2 class="text-base font-extrabold text-slate-900">Sẵn Sàng Giao - Chờ Bàn Giao Xe Lạnh</h2>
                                                <p class="text-[11px] text-slate-500">Kiện hàng đã hoàn tất đóng gói, bảo quản nhiệt độ mát 2-5°C chờ tài xế</p>
                                            </div>
                                        </div>
                                        <span class="px-3 py-1 rounded-full text-xs font-black bg-emerald-100 text-emerald-800 border border-emerald-300">
                                            CHỜ BÀN GIAO
                                        </span>
                                    </div>
                                    <div class="mt-4 p-4 rounded-xl bg-white border border-emerald-200 text-xs text-slate-700 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                                        <div>
                                            <div class="font-bold text-slate-900">Vận chuyển lạnh FreshFruit Express (FFX)</div>
                                            <div class="text-slate-500 text-[11px] mt-0.5">Mã vận đơn: <b class="font-mono text-emerald-800 text-xs">${not empty subOrder.trackingNumber ? subOrder.trackingNumber : 'FFX-98241-VN'}</b></div>
                                        </div>
                                        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 font-extrabold text-xs">
                                            <i class="fa-solid fa-snowflake animate-spin"></i> Thùng bảo ôn 2-5°C
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- CARD 2: THÔNG TIN SẢN PHẨM NÔNG SẢN (DYNAMIC DỰA TRÊN ĐƠN HÀNG) -->
                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-sm font-bold">
                                        <i class="fa-solid fa-bag-shopping"></i>
                                    </div>
                                    <div>
                                        <h2 class="text-base font-extrabold text-slate-900">Thông Tin Sản Phẩm Nông Sản (${not empty subOrder.items ? subOrder.items.size() : 0} món)</h2>
                                        <p class="text-[11px] text-slate-400">Được bảo chứng nguồn gốc và kiểm định chất lượng xuất xưởng</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Products Table -->
                            <div class="mt-4 overflow-x-auto">
                                <table class="w-full text-left text-xs">
                                    <thead>
                                        <tr class="text-slate-400 font-bold border-b border-slate-100 text-[11px]">
                                            <th class="pb-2.5 w-64">SẢN PHẨM</th>
                                            <th class="pb-2.5 text-center">ĐƠN VỊ</th>
                                            <th class="pb-2.5 text-center">SỐ LƯỢNG</th>
                                            <th class="pb-2.5 text-right">ĐƠN GIÁ</th>
                                            <th class="pb-2.5 text-right">THÀNH TIỀN</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-100">
                                        <c:forEach items="${subOrder.items}" var="item">
                                            <tr>
                                                <td class="py-3.5">
                                                    <div class="flex items-center gap-3">
                                                        <img src="${not empty item.imageUrl ? item.imageUrl : 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=150&h=150&fit=crop'}" 
                                                             alt="${item.productNameSnapshot}" class="w-14 h-14 rounded-xl object-cover border border-slate-100 shrink-0">
                                                        <div>
                                                            <div class="flex items-center gap-2">
                                                                <span class="font-extrabold text-slate-900 text-xs">${item.productNameSnapshot}</span>
                                                                <c:if test="${not empty item.variantNameSnapshot}">
                                                                    <span class="px-1.5 py-0.5 rounded text-[9px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                                                        ${item.variantNameSnapshot}
                                                                    </span>
                                                                </c:if>
                                                            </div>
                                                            <div class="text-[11px] text-slate-500 mt-0.5 flex flex-wrap items-center gap-2">
                                                                <span>SKU: <span class="font-mono text-slate-700">${item.skuSnapshot}</span></span>
                                                                <c:if test="${item.weightKg != null}">
                                                                    <span>• Trọng lượng: <b class="text-slate-700">${item.weightKg}kg/${item.unit}</b></span>
                                                                </c:if>
                                                                <span>• Tồn kho khả dụng: <span class="font-bold ${item.stockQuantity < 10 ? 'text-rose-600' : 'text-emerald-700'}">${item.stockQuantity} ${item.unit}</span></span>
                                                            </div>
                                                            <div class="text-[10px] text-emerald-700 font-semibold mt-1 flex flex-wrap items-center gap-2">
                                                                <span class="flex items-center gap-1">
                                                                    <i class="fa-solid fa-leaf text-[9px]"></i> 
                                                                    Xuất xứ: ${not empty item.origin ? item.origin : 'Nông trại đạt chuẩn'}
                                                                </span>
                                                                <c:if test="${not empty item.certification}">
                                                                    <span class="text-amber-700 font-bold">• ${item.certification}</span>
                                                                </c:if>
                                                                <c:if test="${not empty item.storageTemp}">
                                                                    <span class="text-blue-700 font-bold">• <i class="fa-solid fa-snowflake text-[8px]"></i> Bảo quản: ${item.storageTemp}</span>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="py-3.5 text-center font-medium text-slate-600">${item.unit}</td>
                                                <td class="py-3.5 text-center font-extrabold text-slate-900 text-sm">${item.quantity}</td>
                                                <td class="py-3.5 text-right font-medium text-slate-600">
                                                    <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                                <td class="py-3.5 text-right font-extrabold text-slate-900">
                                                    <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Cost Breakdown -->
                            <div class="mt-4 pt-3 border-t border-slate-100 space-y-1.5 text-xs">
                                <div class="flex justify-between text-slate-600">
                                    <span>Tiền hàng (Tạm tính ${not empty subOrder.items ? subOrder.items.size() : 0} sản phẩm):</span>
                                    <span class="font-bold text-slate-800">
                                        <fmt:formatNumber value="${subOrder.shopSubtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                </div>
                                <div class="flex justify-between text-slate-600">
                                    <span class="flex items-center gap-1.5">
                                        Phí vận chuyển giao lạnh chuyên dụng: 
                                        <c:if test="${empty subOrder.shopShippingFee or subOrder.shopShippingFee == 0}">
                                            <span class="text-[10px] text-emerald-700 bg-emerald-50 px-1 rounded font-bold">Tài trợ bởi Shop</span>
                                        </c:if>
                                    </span>
                                    <span class="text-emerald-700 font-bold">
                                        <c:choose>
                                            <c:when test="${subOrder.shopShippingFee != null && subOrder.shopShippingFee > 0}">
                                                <fmt:formatNumber value="${subOrder.shopShippingFee}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>
                                                Miễn phí (₫0)
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="flex justify-between text-slate-600">
                                    <span>Chiết khấu Voucher Người bán:</span>
                                    <span class="text-slate-400">
                                        -<fmt:formatNumber value="${subOrder.shopDiscount != null ? subOrder.shopDiscount : 0}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                </div>
                                <div class="pt-3 border-t border-slate-100 flex items-baseline justify-between">
                                    <div>
                                        <c:choose>
                                            <c:when test="${subOrder.paymentStatus eq 'PAID' or (not empty subOrder.paymentMethod and !subOrder.paymentMethod.toUpperCase().contains('COD'))}">
                                                <div class="text-sm font-extrabold text-slate-900">Tổng Tiền Đã Thanh Toán</div>
                                                <div class="text-[11px] text-emerald-600 font-bold">
                                                    <i class="fa-solid fa-circle-check"></i> Đã thanh toán qua ${subOrder.paymentMethod} (Không thu COD)
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="text-sm font-extrabold text-slate-900">Tổng Thu Hộ COD</div>
                                                <div class="text-[11px] text-slate-400">Người mua thanh toán tiền mặt khi nhận hàng tươi</div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="text-2xl font-black text-emerald-700">
                                        <fmt:formatNumber value="${subOrder.shopTotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </div>
                                </div>
                            </div>
                        </div>



                    </div>

                    <!-- ================= RIGHT COLUMN (4 COLS) ================= -->
                    <div class="lg:col-span-4 space-y-5">

                        <!-- CARD 1: THÔNG TIN NGƯỜI NHẬN -->
                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                                <div class="flex items-center gap-2">
                                    <i class="fa-solid fa-location-dot text-emerald-600 text-sm"></i>
                                    <h3 class="text-sm font-extrabold text-slate-900">Thông Tin Người Nhận</h3>
                                </div>
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                    Khách Hàng
                                </span>
                            </div>

                            <div class="mt-4 flex items-center gap-3">
                                <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center font-extrabold text-sm shrink-0">
                                    ${not empty subOrder.shippingAddress.recipientName ? subOrder.shippingAddress.recipientName.substring(0, 1).toUpperCase() : 'KH'}
                                </div>
                                <div>
                                    <div class="text-sm font-extrabold text-slate-900">
                                        ${not empty subOrder.shippingAddress.recipientName ? subOrder.shippingAddress.recipientName : 'Khách Mua Hàng'}
                                    </div>
                                    <div class="text-[11px] text-slate-400">
                                        SĐT: ${not empty subOrder.shippingAddress.recipientPhone ? subOrder.shippingAddress.recipientPhone : 'Chưa có SĐT'} (Đã bảo mật)
                                    </div>
                                </div>
                            </div>

                            <div class="mt-4 pt-3 border-t border-slate-100">
                                <div class="text-[10px] font-bold text-slate-400 uppercase">ĐỊA CHỈ GIAO HÀNG TƯƠI:</div>
                                <div class="text-xs font-semibold text-slate-800 mt-1 leading-relaxed">
                                    <c:choose>
                                        <c:when test="${not empty subOrder.shippingAddress.streetAddress}">
                                            ${subOrder.shippingAddress.streetAddress}<c:if test="${not empty subOrder.shippingAddress.ward}">, ${subOrder.shippingAddress.ward}</c:if><c:if test="${not empty subOrder.shippingAddress.district}">, ${subOrder.shippingAddress.district}</c:if><c:if test="${not empty subOrder.shippingAddress.city}">, ${subOrder.shippingAddress.city}</c:if>
                                        </c:when>
                                        <c:otherwise>
                                            Căn hộ 14.02, Tháp B2, Vinhomes Central Park, Phường 22, Quận Bình Thạnh, TP.HCM
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Customer Note Box -->
                            <div class="mt-3.5 p-3 rounded-xl bg-amber-50/70 border border-amber-200/70 text-xs">
                                <div class="flex items-center gap-1.5 text-amber-800 font-bold text-[11px] mb-1">
                                    <i class="fa-regular fa-comment-dots"></i> GHI CHÚ GIAO HÀNG TỪ KHÁCH:
                                </div>
                                <p class="text-[11px] text-amber-900 leading-relaxed italic">
                                    <c:choose>
                                        <c:when test="${not empty subOrder.deliverySlot and subOrder.deliverySlot.contains('2h')}">
                                            "Khách yêu cầu giao hỏa tốc 2h bằng xe lạnh chuyên dụng, gọi trước khi đến 10 phút."
                                        </c:when>
                                        <c:when test="${not empty subOrder.deliverySlot and subOrder.deliverySlot.contains('sáng')}">
                                            "Giao hàng buổi sáng trước 11h30, nhờ tài xế giữ trong túi bảo ôn lạnh cẩn thận."
                                        </c:when>
                                        <c:when test="${not empty subOrder.deliverySlot and subOrder.deliverySlot.contains('chiều')}">
                                            "Giao hàng buổi chiều từ 14h - 17h, gọi trước khi tới nhà."
                                        </c:when>
                                        <c:otherwise>
                                            "Giao hàng tươi theo tuyến vận chuyển nội bộ sàn FreshFruit Cold-Chain."
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>




                    </div>

                </div>

            </main>
        </div>

        <!-- ========================================================
             5. CANCEL SUB-ORDER MODAL DIALOG (OPTION 1 WORKFLOW)
             ======================================================== -->
        <div id="cancelModalBackdrop" class="modal-backdrop hidden"></div>
        <div id="cancelOrderModal" class="modal-dialog hidden">
            <div class="p-5 border-b border-slate-100 flex items-center justify-between">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-xl bg-rose-50 text-rose-600 flex items-center justify-center text-sm font-bold border border-rose-200">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900">Hủy Đơn Hàng Con #${subOrder.subOrderCode}</h3>
                        <p class="text-[10px] text-slate-400">Nông sản không đủ tồn kho hoặc không đạt chuẩn tươi</p>
                    </div>
                </div>
                <button type="button" id="btnCloseCancelModal" class="w-7 h-7 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 flex items-center justify-center transition cursor-pointer">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="p-5 space-y-4">
                <input type="hidden" name="action" value="cancel_sub_order">
                <input type="hidden" name="code" value="${subOrder.subOrderCode}">

                <!-- Cancellation Reason Category -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-2">
                        1. Phân loại lý do hủy đơn <span class="text-rose-500">*</span>
                    </label>
                    <div class="space-y-2">
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition is-selected">
                            <input type="radio" name="cancelReasonCategory" value="Hết hàng nông sản tồn kho" class="mt-0.5 text-rose-600" checked>
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Hết hàng nông sản tồn trong kho</div>
                                <div class="text-[11px] text-slate-400">Số lượng thực tế trong kho không đủ đáp ứng số lượng khách đặt.</div>
                            </div>
                        </label>
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition">
                            <input type="radio" name="cancelReasonCategory" value="Nông sản không đạt chuẩn chất lượng (dập nát, thâm úng)" class="mt-0.5 text-rose-600">
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Nông sản không đạt tiêu chuẩn chất lượng</div>
                                <div class="text-[11px] text-slate-400">Soi kiểm tra QC thấy hoa quả bị thâm úng, biến chất, sâu bệnh hoặc dập nát.</div>
                            </div>
                        </label>
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition">
                            <input type="radio" name="cancelReasonCategory" value="Thời tiết bất thường / Không thu hoạch kịp" class="mt-0.5 text-rose-600">
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Thời tiết bất thường / Không thu hoạch kịp</div>
                                <div class="text-[11px] text-slate-400">Vườn không kịp thu hoạch quả tươi đạt chuẩn trong khung giờ hẹn.</div>
                            </div>
                        </label>
                        <label class="cancel-reason-option flex items-start gap-2.5 p-2.5 rounded-xl border border-slate-200 hover:border-rose-400 cursor-pointer transition">
                            <input type="radio" name="cancelReasonCategory" value="Lý do khác" class="mt-0.5 text-rose-600">
                            <div class="text-xs">
                                <div class="font-bold text-slate-800">Lý do phát sinh khác</div>
                            </div>
                        </label>
                    </div>
                </div>

                <!-- Detailed Note -->
                <div>
                    <label class="block text-xs font-bold text-slate-700 mb-1">
                        2. Ghi chú chi tiết cho khách hàng &amp; sàn <span class="text-rose-500">*</span>
                    </label>
                    <textarea name="cancelReasonNote" rows="3" required placeholder="Ghi chú chi tiết gửi khách hàng (VD: Lô dâu tây sáng nay về bị dập bề mặt do mưa, nhà vườn xin phép hủy đơn và hỗ trợ hoàn tiền)..." class="w-full p-2.5 text-xs rounded-xl border border-slate-200 bg-white focus:outline-none focus:border-rose-500"></textarea>
                </div>

                <!-- Notice Alert -->
                <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-start gap-2">
                    <i class="fa-solid fa-circle-info text-amber-600 mt-0.5 text-sm"></i>
                    <div class="leading-relaxed">
                        <b>Quy trình tự động:</b> Sau khi xác nhận hủy, hệ thống FreshFruit sẽ <b>gửi thông báo ngay</b> đến khách hàng và <b>kích hoạt quy trình hoàn tiền</b>.
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                    <button type="button" id="btnDismissCancelModal" class="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs transition cursor-pointer">
                        Đóng
                    </button>
                    <button type="submit" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-extrabold text-xs transition shadow-2xs cursor-pointer">
                        Xác Nhận Hủy Đơn
                    </button>
                </div>
            </form>
        </div>
    </body>
</html>
