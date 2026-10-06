<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FreshFruit - Siêu Thị Hoa Quả Tươi Sạch</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Google Fonts Inter -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        colors: {
                            fresh: {
                                50: '#f0fdf4',
                                100: '#dcfce7',
                                500: '#22c55e',
                                600: '#16a34a',
                                700: '#15803d',
                                primary: '#10b981',
                                dark: '#064e3b',
                                accent: '#f97316'
                            }
                        },
                        fontFamily: {
                            sans: ['Inter', 'sans-serif'],
                        }
                    }
                }
            }
        </script>
        <style>
            ::-webkit-scrollbar {
                width: 8px;
                height: 8px;
            }
            ::-webkit-scrollbar-track {
                background: #f1f5f9;
            }
            ::-webkit-scrollbar-thumb {
                background: #cbd5e1;
                border-radius: 4px;
            }
            ::-webkit-scrollbar-thumb:hover {
                background: #94a3b8;
            }
        </style>
    </head>
    <body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

        <!-- Top Bar -->
        <div class="bg-gradient-to-r from-emerald-800 via-emerald-700 to-teal-800 text-white text-xs md:text-sm py-2 px-4 shadow-sm">
            <div class="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-center gap-2">
                <div class="flex items-center space-x-4">
                    <span class="flex items-center gap-1.5 font-medium"><i class="fa-solid fa-truck-fast text-emerald-300"></i> Miễn phí giao hàng đơn từ 350.000đ | Giao nhanh trong 2 giờ</span>
                </div>
                <div class="flex items-center space-x-6">
                    <a href="#" class="hover:text-emerald-200 transition"><i class="fa-solid fa-phone-volume mr-1"></i> Hotline: 1900 6868</a>
                    <span class="text-emerald-400">|</span>
                    <a href="#" class="hover:text-emerald-200 transition"><i class="fa-solid fa-headset mr-1"></i> Hỗ trợ trực tuyến</a>
                    <span class="text-emerald-400">|</span>
                    <a href="#deals" class="hover:text-amber-300 transition font-bold flex items-center gap-1"><i class="fa-solid fa-bolt text-amber-300"></i> Flash Sale Giờ Vàng</a>
                </div>
            </div>
        </div>

        <!-- Header -->
        <header class="sticky top-0 z-40 bg-white shadow-md transition-all">
            <div class="max-w-7xl mx-auto px-4 py-3 sm:py-4">
                <div class="flex items-center justify-between gap-4">
                    <!-- Brand Logo -->
                    <div class="flex items-center gap-3">
                        <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-3 group">
                            <div class="w-11 h-11 sm:w-12 sm:h-12 bg-emerald-50 rounded-full flex items-center justify-center p-1.5 shadow-sm border border-emerald-100 flex-shrink-0">
                                <svg viewBox="0 0 100 100" class="w-full h-full">
                                    <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                                    <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                                    <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                                    <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                                </svg>
                            </div>
                            <div class="flex items-baseline text-xl sm:text-2xl font-extrabold tracking-tight">
                                <span class="text-gray-900 font-extrabold">Fresh</span><span class="text-emerald-600 font-extrabold">Fruit</span>
                            </div>
                        </a>
                    </div>

                    <!-- Thanh Search Cơ Bản -->
                    <div class="flex-1 max-w-lg mx-4 hidden md:block">
                        <form action="${pageContext.request.contextPath}/search" method="GET" class="relative">
                            <input type="text" name="query" placeholder="Tìm kiếm hoa quả tươi sạch, táo, cam..." 
                                   class="w-full bg-gray-100 hover:bg-gray-200/65 focus:bg-white border border-transparent focus:border-emerald-500 rounded-2xl py-2.5 pl-4 pr-12 text-sm text-gray-800 focus:outline-none transition shadow-inner">
                            <button type="submit" class="absolute right-1.5 top-1.5 bottom-1.5 px-4 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl transition flex items-center justify-center shadow-sm">
                                <i class="fa-solid fa-magnifying-glass text-xs"></i>
                            </button>
                        </form>
                    </div>

                    <!-- User Actions -->
                    <div class="flex items-center gap-4">
                        <c:choose>
                            <c:when test="${empty sessionScope.account}">
                                <div class="flex items-center gap-2">
                                    <a href="${pageContext.request.contextPath}/login" class="text-sm font-semibold text-gray-700 hover:text-emerald-600 transition">Đăng nhập</a>
                                    <span class="text-gray-300">/</span>
                                    <a href="${pageContext.request.contextPath}/register" class="text-sm font-semibold bg-emerald-600 text-white px-4 py-2 rounded-xl hover:bg-emerald-700 transition shadow-sm">Đăng ký</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="flex items-center gap-3 cursor-pointer group">
                                    <img src="${not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'https://via.placeholder.com/40'}" 
                                         alt="Avatar" class="w-10 h-10 rounded-full object-cover border-2 border-emerald-500 shadow-sm">
                                    <div class="hidden md:block text-left">
                                        <span class="block text-xs text-gray-500">Xin chào,</span>
                                        <span class="text-sm font-bold text-gray-800 group-hover:text-emerald-600 transition">
                                            ${sessionScope.account.fullName}
                                        </span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/logout" class="text-xs text-red-500 hover:underline ml-2" title="Đăng xuất"><i class="fa-solid fa-right-from-bracket"></i></a>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Cart Button -->
                        <a href="${pageContext.request.contextPath}/cart" class="relative p-2.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 rounded-xl transition flex items-center gap-2 group">
                            <i class="fa-solid fa-bag-shopping text-xl group-hover:scale-110 transition-transform"></i>
                            <span class="hidden sm:inline font-bold text-sm">Giỏ hàng</span>
                            <span id="cartBadge" class="absolute -top-1.5 -right-1.5 bg-amber-500 text-white text-xs w-5 h-5 rounded-full flex items-center justify-center font-bold shadow-md border-2 border-white">${sessionScope.cartSize != null ? sessionScope.cartSize : 0}</span>
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- Navigation Menu -->
        <div class="bg-emerald-900 text-white hidden md:block">
            <div class="max-w-7xl mx-auto px-4 flex items-center justify-between text-sm font-medium">
                <div class="flex items-center space-x-1">
                    <a href="${pageContext.request.contextPath}/home" class="px-4 py-3 bg-emerald-800 hover:bg-emerald-700 transition flex items-center gap-2 font-bold text-amber-300">
                        <i class="fa-solid fa-house"></i> Trang chủ
                    </a>
                    <a href="#categories" class="px-4 py-3 hover:bg-emerald-800 transition flex items-center gap-1.5">Danh mục <i class="fa-solid fa-chevron-down text-xs"></i></a>
                    <a href="#featured" class="px-4 py-3 hover:bg-emerald-800 transition flex items-center gap-1.5">Sản phẩm nổi bật</a>
                    <a href="#deals" class="px-4 py-3 hover:bg-emerald-800 transition flex items-center gap-1.5 text-amber-300 font-semibold"><i class="fa-solid fa-bolt"></i> Siêu ưu đãi</a>
                    <a href="#about" class="px-4 py-3 hover:bg-emerald-800 transition">Về chúng tôi</a>
                    <a href="#reviews" class="px-4 py-3 hover:bg-emerald-800 transition">Đánh giá</a>
                </div>
                <div>
                    <a href="#deals" class="bg-amber-500 hover:bg-amber-600 text-gray-900 font-bold px-4 py-1.5 rounded-lg text-xs shadow-sm transition flex items-center gap-1.5">
                        <i class="fa-solid fa-tag"></i> Săn Voucher Giảm Đến 50%
                    </a>
                </div>
            </div>
        </div>

        <!-- Hero Banner Section -->
        <section class="max-w-7xl mx-auto px-4 py-6">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Left Big Hero Card -->
                <div class="lg:col-span-2 bg-gradient-to-br from-emerald-600 via-emerald-700 to-teal-900 rounded-3xl p-6 sm:p-10 text-white relative overflow-hidden shadow-xl flex flex-col justify-between">
                    <div class="absolute right-0 bottom-0 opacity-10 pointer-events-none transform translate-x-10 translate-y-10">
                        <i class="fa-solid fa-basket-shopping text-[280px]"></i>
                    </div>
                    <div class="relative z-10">
                        <div class="inline-flex items-center gap-2 bg-emerald-500/30 border border-emerald-400/40 px-3 py-1.5 rounded-full text-xs font-bold text-emerald-100 mb-4 backdrop-blur-sm">
                            <i class="fa-solid fa-award text-amber-300"></i> 100% Organic Đạt Chuẩn VietGAP & GlobalGAP
                        </div>
                        <h1 class="text-3xl sm:text-5xl font-extrabold tracking-tight leading-tight mb-4">
                            Hoa Quả Tươi Sạch,<br>Giao Nhanh Mỗi Ngày.
                        </h1>
                        <p class="text-emerald-100 text-sm sm:text-base max-w-xl mb-8 leading-relaxed">
                            Tuyển chọn từ những nông trại hữu cơ hàng đầu, thu hoạch chín tự nhiên và vận chuyển bằng công nghệ lạnh khép kín giữ trọn vitamin.
                        </p>
                        <div class="flex flex-wrap items-center gap-4">
                            <a href="#featured" class="bg-white hover:bg-emerald-50 text-emerald-800 font-bold px-7 py-3.5 rounded-2xl shadow-lg transition flex items-center gap-2">
                                Mua Ngay <i class="fa-solid fa-arrow-right"></i>
                            </a>
                            <a href="#categories" class="bg-emerald-700/60 hover:bg-emerald-700 border border-emerald-500/50 text-white font-semibold px-6 py-3.5 rounded-2xl backdrop-blur-sm transition">
                                Khám Phá Danh Mục
                            </a>
                        </div>
                    </div>
                    <div class="relative z-10 grid grid-cols-3 gap-4 pt-8 mt-8 border-t border-emerald-500/30 text-center">
                        <div class="bg-emerald-800/40 backdrop-blur-sm p-3 rounded-2xl border border-emerald-500/20">
                            <span class="block text-xl sm:text-2xl font-black text-amber-300">50+</span>
                            <span class="text-[11px] sm:text-xs text-emerald-200 font-medium">Nông Trại Đối Tác</span>
                        </div>
                        <div class="bg-emerald-800/40 backdrop-blur-sm p-3 rounded-2xl border border-emerald-500/20">
                            <span class="block text-xl sm:text-2xl font-black text-amber-300">99.8%</span>
                            <span class="text-[11px] sm:text-xs text-emerald-200 font-medium">Độ Tươi Sạch</span>
                        </div>
                        <div class="bg-emerald-800/40 backdrop-blur-sm p-3 rounded-2xl border border-emerald-500/20">
                            <span class="block text-xl sm:text-2xl font-black text-amber-300">15K+</span>
                            <span class="text-[11px] sm:text-xs text-emerald-200 font-medium">Khách Hài Lòng</span>
                        </div>
                    </div>
                </div>

                <!-- Right Live Activity / Voucher Card -->
                <div class="bg-gradient-to-br from-amber-500 via-amber-600 to-orange-600 rounded-3xl p-6 text-white shadow-xl flex flex-col justify-between relative overflow-hidden">
                    <div>
                        <div class="flex items-center justify-between mb-4">
                            <span class="inline-flex items-center gap-1.5 bg-black/20 px-3 py-1 rounded-full text-xs font-bold backdrop-blur-sm">
                                <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span> Live Đơn Hàng Hoạt Động
                            </span>
                        </div>
                        <h2 class="text-xl sm:text-2xl font-black mb-1">Vừa Thu Hoạch Tại Vườn</h2>
                        <p class="text-xs text-amber-100 mb-4">Đà Lạt & Miền Tây • Cập nhật lúc 06:30 Sáng nay</p>

                        <div class="bg-white/10 backdrop-blur-md rounded-2xl p-4 border border-white/20 flex items-center gap-3 mb-6">
                            <div class="w-14 h-14 bg-white rounded-xl flex items-center justify-center p-1 flex-shrink-0 shadow">
                                <span class="text-2xl">🍎</span>
                            </div>
                            <div>
                                <span class="bg-rose-600 text-white text-[10px] font-bold px-2 py-0.5 rounded">Size L</span>
                                <h3 class="font-bold text-sm text-white mt-0.5">Táo Ambrosia Canada Size L</h3>
                                <p class="text-[11px] text-amber-100">Vừa cập bến kho lạnh trung tâm</p>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white rounded-2xl p-4 text-gray-800 shadow-lg">
                        <div class="flex justify-between items-center mb-2">
                            <span class="text-xs font-bold text-gray-500 uppercase tracking-wide">Mã Giảm Giá Độc Quyền</span>
                            <span class="text-[10px] bg-emerald-100 text-emerald-700 font-bold px-2 py-0.5 rounded-full">Còn 45 mã</span>
                        </div>
                        <div class="flex items-center justify-between bg-gray-50 border border-dashed border-gray-300 rounded-xl px-3 py-2">
                            <span class="font-black text-emerald-700 tracking-wider text-sm">FRESHFRUIT50K</span>
                            <button onclick="alert('Đã lưu mã giảm giá thành công!')" class="bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs px-3.5 py-1.5 rounded-lg transition shadow-sm">Lưu Mã</button>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Categories Section -->
        <section id="categories" class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex justify-between items-end mb-6">
                <div>
                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight">Khám Phá Danh Mục</h2>
                    <p class="text-xs sm:text-sm text-gray-500">Tuyển tập hoa quả tươi ngon theo nhu cầu dinh dưỡng hàng ngày</p>
                </div>
                <a href="#" class="text-xs sm:text-sm font-bold text-emerald-600 hover:text-emerald-700 flex items-center gap-1 transition">
                    Xem Tất Cả <i class="fa-solid fa-arrow-right text-xs"></i>
                </a>
            </div>

            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-7 gap-4">
                <a href="#" class="bg-white hover:shadow-lg border border-gray-100 rounded-3xl p-4 text-center transition group flex flex-col items-center">
                    <div class="w-16 h-16 bg-emerald-50 rounded-2xl flex items-center justify-center text-3xl mb-3 group-hover:scale-110 transition duration-300 shadow-sm">🍏</div>
                    <h3 class="font-bold text-sm text-gray-900 mb-0.5">Táo & Lê</h3>
                    <span class="text-[11px] text-gray-400">14 Loại</span>
                </a>
                <a href="#" class="bg-white hover:shadow-lg border border-gray-100 rounded-3xl p-4 text-center transition group flex flex-col items-center">
                    <div class="w-16 h-16 bg-amber-50 rounded-2xl flex items-center justify-center text-3xl mb-3 group-hover:scale-110 transition duration-300 shadow-sm">🍊</div>
                    <h3 class="font-bold text-sm text-gray-900 mb-0.5">Cam & Quýt</h3>
                    <span class="text-[11px] text-gray-400">10 Loại</span>
                </a>
                <a href="#" class="bg-white hover:shadow-lg border border-gray-100 rounded-3xl p-4 text-center transition group flex flex-col items-center">
                    <div class="w-16 h-16 bg-yellow-50 rounded-2xl flex items-center justify-center text-3xl mb-3 group-hover:scale-110 transition duration-300 shadow-sm">🍍</div>
                    <h3 class="font-bold text-sm text-gray-900 mb-0.5">Nhiệt Đới</h3>
                    <span class="text-[11px] text-gray-400">12 Loại</span>
                </a>
                <a href="#" class="bg-white hover:shadow-lg border border-gray-100 rounded-3xl p-4 text-center transition group flex flex-col items-center">
                    <div class="w-16 h-16 bg-rose-50 rounded-2xl flex items-center justify-center text-3xl mb-3 group-hover:scale-110 transition duration-300 shadow-sm">🍓</div>
                    <h3 class="font-bold text-sm text-gray-900 mb-0.5">Quả Mọng</h3>
                    <span class="text-[11px] text-gray-400">16 Loại</span>
                </a>
                <a href="#" class="bg-white hover:shadow-lg border border-gray-100 rounded-3xl p-4 text-center transition group flex flex-col items-center">
                    <div class="w-16 h-16 bg-purple-50 rounded-2xl flex items-center justify-center text-3xl mb-3 group-hover:scale-110 transition duration-300 shadow-sm">🍇</div>
                    <h3 class="font-bold text-sm text-gray-900 mb-0.5">Nho Tươi</h3>
                    <span class="text-[11px] text-gray-400">9 Loại</span>
                </a>
                <a href="#" class="bg-white hover:shadow-lg border border-gray-100 rounded-3xl p-4 text-center transition group flex flex-col items-center">
                    <div class="w-16 h-16 bg-teal-50 rounded-2xl flex items-center justify-center text-3xl mb-3 group-hover:scale-110 transition duration-300 shadow-sm">🍈</div>
                    <h3 class="font-bold text-sm text-gray-900 mb-0.5">Dưa Các Loại</h3>
                    <span class="text-[11px] text-gray-400">8 Loại</span>
                </a>
                <a href="#" class="bg-white hover:shadow-lg border border-gray-100 rounded-3xl p-4 text-center transition group flex flex-col items-center">
                    <div class="w-16 h-16 bg-emerald-50 rounded-2xl flex items-center justify-center text-emerald-600 text-2xl mb-3 group-hover:scale-110 group-hover:bg-emerald-100 transition duration-300 shadow-sm">
                        <i class="fa-solid fa-box-open"></i>
                    </div>
                    <h3 class="font-bold text-sm text-gray-900 mb-0.5 group-hover:text-emerald-600 transition">Nhập Khẩu</h3>
                    <span class="text-[11px] text-gray-400">11 Loại</span>
                </a>
            </div>
        </section>

        <!-- Featured Products Section -->
        <section id="featured" class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
                <div>
                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight">Sản Phẩm Nổi Bật & Mới Về</h2>
                    <p class="text-xs sm:text-sm text-gray-500">Lựa chọn hàng đầu cho sức khỏe gia đình bạn hôm nay</p>
                </div>
                <div class="flex items-center bg-white p-1.5 rounded-2xl shadow-sm border border-gray-200 text-xs font-semibold gap-1">
                    <button class="bg-emerald-600 text-white px-4 py-2 rounded-xl transition shadow">Tất Cả</button>
                    <button class="text-gray-600 hover:bg-gray-100 px-4 py-2 rounded-xl transition">Bán Chạy</button>
                    <button class="text-gray-600 hover:bg-gray-100 px-4 py-2 rounded-xl transition">Mùa Vụ Mới</button>
                    <button class="text-gray-600 hover:bg-gray-100 px-4 py-2 rounded-xl transition">Organic 100%</button>
                </div>
            </div>

            <!-- Product Grid -->
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:choose>
                    <c:when test="${not empty listProduct}">
                        <c:forEach var="p" items="${listProduct}">
                            <div class="bg-white rounded-3xl p-4 shadow-sm hover:shadow-xl border border-gray-100 flex flex-col justify-between transition-all duration-300 group">
                                <div>
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="block relative aspect-square rounded-2xl overflow-hidden bg-gray-100 mb-4 cursor-pointer">
                                        <img src="${p.image}" alt="${p.name}" class="w-full h-full object-cover group-hover:scale-105 transition duration-500">
                                        <c:if test="${p.discountPercent > 0}">
                                            <span class="absolute top-3 left-3 bg-rose-500 text-white font-bold text-[10px] px-2.5 py-1 rounded-full shadow">-${p.discountPercent}%</span>
                                        </c:if>
                                    </a>
                                    <span class="text-[11px] font-bold text-emerald-600 uppercase tracking-wider">${p.categoryName}</span>
                                    <h3 class="font-bold text-sm text-gray-900 mt-1 mb-2 line-clamp-2">
                                        <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="hover:text-emerald-600 transition">${p.name}</a>
                                    </h3>
                                    <div class="flex items-center gap-1 text-xs text-amber-400 mb-2">
                                        <i class="fa-solid fa-star"></i>
                                        <span class="font-bold text-gray-700">${p.rating}</span>
                                        <span class="text-gray-400">(${p.reviewsCount})</span>
                                    </div>
                                </div>
                                <div class="pt-3 border-t border-gray-100 flex items-center justify-between">
                                    <div>
                                        <span class="text-emerald-600 font-black text-base">
                                            <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                                        </span>
                                        <c:if test="${p.oldPrice > p.price}">
                                            <span class="text-gray-400 text-xs line-through block">
                                                <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />đ
                                            </span>
                                        </c:if>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/add-to-cart" method="GET">
                                        <input type="hidden" name="productId" value="${p.id}" />
                                        <button type="submit" class="bg-emerald-50 hover:bg-emerald-600 text-emerald-700 hover:text-white w-10 h-10 rounded-2xl flex items-center justify-center font-bold transition shadow-sm" title="Thêm vào giỏ hàng">
                                            <i class="fa-solid fa-cart-plus"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-span-full text-center py-12 bg-white rounded-3xl border border-gray-100 shadow-sm">
                            <i class="fa-solid fa-box-open text-4xl text-gray-300 mb-3"></i>
                            <p class="text-gray-500 font-medium text-base">Chưa có sản phẩm nào được cập nhật.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <!-- Flash Sale Banner -->
        <section id="deals" class="max-w-7xl mx-auto px-4 py-8">
            <div class="bg-gradient-to-r from-emerald-950 via-emerald-900 to-teal-950 rounded-3xl p-6 sm:p-12 text-white shadow-2xl relative overflow-hidden flex flex-col lg:flex-row items-center justify-between gap-8">
                <div class="absolute right-0 bottom-0 opacity-10 pointer-events-none">
                    <i class="fa-solid fa-fire text-[300px]"></i>
                </div>
                <div class="max-w-xl z-10">
                    <div class="inline-flex items-center gap-2 bg-amber-500 text-gray-900 px-3.5 py-1 rounded-full text-xs font-black uppercase tracking-wider mb-4 shadow">
                        <i class="fa-solid fa-bolt"></i> Khuyến Mãi Có Hạn Theo Giờ
                    </div>
                    <h2 class="text-2xl sm:text-4xl font-black tracking-tight mb-4">
                        Ưu Đãi Trái Cây Mùa Hè - Giá Tốt Nhất.
                    </h2>
                    <p class="text-emerald-100 text-sm sm:text-base mb-6 leading-relaxed">
                        Giảm giá lên đến 25% cho tất cả các loại hoa quả nhập khẩu cao cấp. Cam kết tươi ngon chuẩn vị nông trại, đổi trả 1-1 nếu không đạt chuẩn.
                    </p>
                    <a href="#featured" class="inline-block bg-amber-500 hover:bg-amber-600 text-gray-900 font-extrabold px-8 py-3.5 rounded-2xl shadow-lg transition transform hover:-translate-y-0.5">
                        Xem Tất Cả Sản Phẩm Giảm Giá
                    </a>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer id="about" class="bg-gray-950 text-gray-300 pt-16 pb-8 border-t border-gray-800 mt-12">
            <div class="max-w-7xl mx-auto px-4">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 mb-12">
                    <div class="lg:col-span-2">
                        <div class="flex items-center gap-3 mb-4">
                            <div class="w-10 h-10 bg-emerald-50 rounded-full flex items-center justify-center p-1 shadow">
                                <svg viewBox="0 0 100 100" class="w-full h-full">
                                    <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                                    <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                                    <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                                    <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                                </svg>
                            </div>
                            <span class="text-xl font-extrabold text-white">Fresh<span class="text-emerald-500">Fruit</span></span>
                        </div>
                        <p class="text-xs sm:text-sm text-gray-400 mb-6 leading-relaxed max-w-sm">
                            Hệ thống phân phối hoa quả tươi sạch hàng đầu Việt Nam. Mang thiên nhiên thuần khiết và nguồn dinh dưỡng an toàn đến từng gia đình.
                        </p>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Danh Mục Mua Sắm</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="#" class="hover:text-emerald-400 transition">Táo & Lê Nhập Khẩu</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Cam, Quýt & Bưởi</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Trái Cây Nhiệt Đới</a></li>
                        </ul>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Hỗ Trợ Khách Hàng</h3>
                        <ul class="space-y-2.5 text-xs text-gray-400">
                            <li><a href="#" class="hover:text-emerald-400 transition">Trung Tâm Trợ Giúp</a></li>
                            <li><a href="#" class="hover:text-emerald-400 transition">Chính Sách Đổi Trả 1-1</a></li>
                        </ul>
                    </div>
                    <div>
                        <h3 class="font-bold text-white text-sm uppercase tracking-wider mb-4">Đăng Ký Nhận Bản Tin</h3>
                        <form onsubmit="event.preventDefault(); alert('Đăng ký nhận bản tin thành công!');" class="space-y-2">
                            <input type="email" placeholder="Nhập email của bạn..." class="w-full bg-gray-900 border border-gray-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500">
                            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs py-2.5 rounded-xl transition shadow">Đăng Ký Ngay</button>
                        </form>
                    </div>
                </div>
                <div class="pt-8 border-t border-gray-900 flex flex-col sm:flex-row justify-between items-center text-xs text-gray-500 gap-4">
                    <p>&copy; 2026 FreshFruit Marketplace Inc. Bảo lưu mọi quyền.</p>
                </div>
            </div>
        </footer>
    </body>
</html>

