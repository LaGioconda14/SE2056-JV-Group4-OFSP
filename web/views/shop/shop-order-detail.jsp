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
                    <div class="flex items-center gap-2 bg-white p-1.5 rounded-xl border border-slate-200 shadow-2xs self-start lg:self-center">
                        <span class="text-[11px] font-bold text-slate-400 px-2">Trạng thái mô phỏng:</span>
                        <a href="?code=${subOrder.subOrderCode}&status=NEW" 
                           class="px-3 py-1.5 rounded-lg text-xs font-bold transition ${subOrder.status eq 'NEW' ? 'bg-emerald-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100'}">
                            1. Đơn Mới
                        </a>
                        <a href="?code=${subOrder.subOrderCode}&status=PACKING" 
                           class="px-3 py-1.5 rounded-lg text-xs font-bold transition ${subOrder.status eq 'PACKING' or empty subOrder.status ? 'bg-emerald-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100'}">
                            2. Đang đóng gói
                        </a>
                        <a href="?code=${subOrder.subOrderCode}&status=SHIPPING" 
                           class="px-3 py-1.5 rounded-lg text-xs font-bold transition ${subOrder.status eq 'SHIPPING' ? 'bg-emerald-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100'}">
                            3. Sẵn sàng giao
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

                        <!-- Step 2: Shop Xác nhận -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full ${subOrder.status ne 'NEW' ? 'bg-emerald-600 text-white ring-4 ring-emerald-50' : 'bg-amber-500 text-white ring-4 ring-amber-50 animate-pulse'} flex items-center justify-center font-bold text-sm shadow-sm">
                                <c:choose>
                                    <c:when test="${subOrder.status ne 'NEW'}"><i class="fa-solid fa-check"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-clock"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs text-slate-900">Shop Xác Nhận</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Tiếp nhận nông sản</div>
                        </div>

                        <!-- Step 3: Đang đóng gói (Active default) -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full ${subOrder.status eq 'PACKING' ? 'bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110' : (subOrder.status eq 'SHIPPING' or subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED' ? 'bg-emerald-600 text-white ring-4 ring-emerald-50' : 'bg-slate-200 text-slate-500')} flex items-center justify-center font-bold text-sm">
                                <c:choose>
                                    <c:when test="${subOrder.status eq 'SHIPPING' or subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED'}"><i class="fa-solid fa-check"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-box-open"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs ${subOrder.status eq 'PACKING' ? 'text-emerald-700' : 'text-slate-900'}">Đang Đóng Gói</div>
                            <div class="text-[11px] text-emerald-700 font-semibold mt-0.5">Kiểm định QC độ tươi</div>
                        </div>

                        <!-- Step 4: Chờ bàn giao tài xế -->
                        <div class="flex flex-col items-center text-center w-36 z-10">
                            <div class="w-9 h-9 rounded-full ${subOrder.status eq 'SHIPPING' ? 'bg-emerald-700 text-white ring-4 ring-emerald-100 shadow-md scale-110' : (subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED' ? 'bg-emerald-600 text-white' : 'bg-slate-200 text-slate-400')} flex items-center justify-center font-bold text-sm">
                                <c:choose>
                                    <c:when test="${subOrder.status eq 'DELIVERED' or subOrder.status eq 'COMPLETED'}"><i class="fa-solid fa-check"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-truck-fast"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="mt-2.5 font-extrabold text-xs ${subOrder.status eq 'SHIPPING' ? 'text-emerald-700' : 'text-slate-400'}">Chờ Bàn Giao Tài Xế</div>
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
                            <div class="h-full bg-emerald-600 transition-all duration-500" 
                                 style="width: ${subOrder.status eq 'NEW' ? '25%' : (subOrder.status eq 'PACKING' ? '50%' : (subOrder.status eq 'SHIPPING' ? '75%' : '100%'))}"></div>
                        </div>
                    </div>
                </div>

                <!-- ========================================================
                     4. TWO-COLUMN LAYOUT: MAIN WORKFLOW & SIDE INFO
                     ======================================================== -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

                    <!-- ================= LEFT COLUMN (8 COLS) ================= -->
                    <div class="lg:col-span-8 space-y-5">

                        <!-- CARD 1: TIẾN TRÌNH XỬ LÝ ĐƠN HÀNG CON (TẠM ẨN) -->
                        <%--
                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                                <div class="flex items-center gap-2.5">
                                    <div class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center text-sm font-bold">
                                        <i class="fa-solid fa-arrows-rotate"></i>
                                    </div>
                                    <h2 class="text-base font-extrabold text-slate-900">Tiến Trình Xử Lý Đơn Hàng Con</h2>
                                </div>
                                <span class="px-3 py-1 rounded-full text-xs font-extrabold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                    Trạng thái: 
                                    <c:choose>
                                        <c:when test="${subOrder.status eq 'NEW'}">Chờ xác nhận</c:when>
                                        <c:when test="${subOrder.status eq 'PACKING'}">Đang đóng gói & Kiểm định QC</c:when>
                                        <c:when test="${subOrder.status eq 'SHIPPING'}">Đã bàn giao xe lạnh</c:when>
                                        <c:when test="${subOrder.status eq 'DELIVERED'}">Giao thành công</c:when>
                                        <c:otherwise>${subOrder.status}</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <!-- Banner Quy Chuẩn Đóng Gói -->
                            <div class="mt-4 p-4 rounded-xl bg-slate-50 border border-slate-200/80 flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-emerald-600 text-white flex items-center justify-center text-sm font-bold shadow-xs">
                                        <i class="fa-solid fa-clipboard-check"></i>
                                    </div>
                                    <div>
                                        <div class="text-xs font-bold text-slate-900">Quy chuẩn kiểm soát đóng gói nông sản lạnh</div>
                                        <div class="text-[11px] text-slate-500">Tick chọn các tiêu chuẩn đóng hàng đạt chuẩn xuất xưởng</div>
                                    </div>
                                </div>
                                <span id="qcProgressBadge" class="px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200/60">
                                    Bắt buộc hoàn thành <span id="qcCount">3</span>/4
                                </span>
                            </div>

                            <!-- 4 Checklist Items -->
                            <div class="mt-4 space-y-3">
                                <!-- Item 1 -->
                                <label class="flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                    <input type="checkbox" checked class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                    <div class="flex-1 text-xs">
                                        <div class="font-bold text-slate-900">Đã kiểm tra chất lượng & loại bỏ quả dập/hỏng</div>
                                        <div class="text-slate-500 text-[11px] mt-0.5">Soi kỹ bề mặt vỏ, kiểm tra độ đàn hồi, loại bỏ toàn bộ cuống héo hoặc dập vỏ để bảo quản lạnh an toàn.</div>
                                    </div>
                                </label>

                                <!-- Item 2 -->
                                <label class="flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                    <input type="checkbox" checked class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                    <div class="flex-1 text-xs">
                                        <div class="font-bold text-slate-900">Đã cân đủ trọng lượng tịnh & kiểm tra số lượng</div>
                                        <div class="text-slate-500 text-[11px] mt-0.5">
                                            Chi tiết đóng gói: 
                                            <c:forEach items="${subOrder.items}" var="it" varStatus="st">
                                                <span class="font-medium text-slate-800">${it.productNameSnapshot} (x${it.quantity} ${it.unit})</span>${!st.last ? ', ' : ''}
                                            </c:forEach>
                                        </div>
                                    </div>
                                </label>

                                <!-- Item 3 -->
                                <label class="flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                    <input type="checkbox" checked class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                    <div class="flex-1 text-xs">
                                        <div class="font-bold text-slate-900">Đã đóng gói thùng xốp chuyên dụng & chèn túi đá gel bảo ôn mát</div>
                                        <div class="text-slate-500 text-[11px] mt-0.5">Đặt túi đá gel cách nhiệt có vách ngăn xốp chống đọng ẩm trực tiếp lên quả tươi.</div>
                                    </div>
                                </label>

                                <!-- Item 4 -->
                                <label class="flex items-start gap-3.5 p-3.5 rounded-xl border border-slate-200 bg-white hover:border-emerald-400 transition cursor-pointer select-none">
                                    <input type="checkbox" class="qc-check mt-1 w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300">
                                    <div class="flex-1 text-xs">
                                        <div class="font-bold text-slate-900">Đã dán tem niêm phong và mã vận đơn #${subOrder.subOrderCode}</div>
                                        <div class="text-slate-500 text-[11px] mt-0.5">Mã barcode ${subOrder.trackingNumber} in rõ nét trên nắp thùng và mặt bên.</div>
                                    </div>
                                </label>
                            </div>

                            <!-- VietGAP Guarantee & Action Button -->
                            <div class="mt-4 pt-3 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs">
                                <div class="flex items-center gap-1.5 text-emerald-700 font-semibold text-[11px]">
                                    <i class="fa-solid fa-shield-check text-emerald-600"></i> Được bảo chứng quy trình bảo quản tươi bởi VietGAP & OCOP
                                </div>
                            </div>

                            <form action="${pageContext.request.contextPath}/shop/order-detail" method="POST" class="mt-3">
                                <input type="hidden" name="action" value="ready_to_ship">
                                <input type="hidden" name="code" value="${subOrder.subOrderCode}">
                                <button type="submit" id="btnFinishPacking" class="w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-extrabold text-sm transition shadow-sm flex items-center justify-center gap-2">
                                    <i class="fa-solid fa-box-check"></i> Hoàn tất đóng gói & Báo sẵn sàng giao
                                </button>
                            </form>
                        </div>
                        --%>

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

                        <!-- CARD 2: VẬN CHUYỂN & GIAO HÀNG -->
                        <div class="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs">
                            <div class="flex items-center justify-between pb-3 border-b border-slate-100">
                                <div class="flex items-center gap-2">
                                    <i class="fa-solid fa-truck text-emerald-600 text-sm"></i>
                                    <h3 class="text-sm font-extrabold text-slate-900">Vận Chuyển & Giao Hàng</h3>
                                </div>
                                <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                            </div>

                            <div class="mt-3 space-y-2 text-xs">
                                <div class="flex justify-between items-center">
                                    <span class="text-slate-400 text-[11px]">Đơn vị vận chuyển:</span>
                                    <span class="font-bold text-emerald-700 flex items-center gap-1">
                                        <i class="fa-solid fa-snowflake text-[10px]"></i> ${not empty subOrder.carrierName ? subOrder.carrierName : 'FreshFruit Cold-Chain'}
                                    </span>
                                </div>
                                <div class="flex justify-between items-center">
                                    <span class="text-slate-400 text-[11px]">Loại hình giao:</span>
                                    <span class="font-semibold text-slate-700">Tài xế xe lạnh chuyên dụng</span>
                                </div>
                                <div class="flex justify-between items-center">
                                    <span class="text-slate-400 text-[11px]">Mã vận đơn FFX:</span>
                                    <span class="font-extrabold text-slate-900 bg-slate-100 px-2 py-0.5 rounded text-[11px]">
                                        ${not empty subOrder.trackingNumber ? subOrder.trackingNumber : 'Chờ phân bổ'}
                                    </span>
                                </div>
                            </div>

                            <!-- Urgent Pickup Countdown Alert -->
                            <div class="mt-3 p-2.5 rounded-xl bg-red-50 border border-red-200/80 flex items-center gap-2 text-xs text-red-700 font-bold">
                                <i class="fa-solid fa-circle-exclamation text-red-500"></i>
                                <span>Lấy hàng trong ngày: Khung giờ giao ${not empty subOrder.deliverySlot ? subOrder.deliverySlot : 'Tiêu chuẩn'}</span>
                            </div>

                            <!-- Map Mockup Graphic -->
                            <div class="mt-3 relative h-32 rounded-xl overflow-hidden border border-slate-200 bg-slate-100">
                                <img src="https://images.unsplash.com/photo-1524661135-423995f22d0b?w=500&h=250&fit=crop" 
                                     alt="Map Route" class="w-full h-full object-cover filter contrast-125 opacity-75">
                                <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
                                <div class="absolute bottom-2 left-2 right-2 flex items-center justify-between">
                                    <span class="px-2.5 py-1 rounded-lg bg-white/95 text-slate-900 text-[10px] font-extrabold shadow-sm flex items-center gap-1">
                                        <i class="fa-solid fa-route text-emerald-600"></i> Bán kính giao hàng: Nội thành
                                    </span>
                                </div>
                            </div>
                        </div>


                    </div>

                </div>

            </main>
        </div>
    </body>
</html>
