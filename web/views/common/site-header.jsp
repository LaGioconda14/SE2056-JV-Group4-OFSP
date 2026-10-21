<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    /*
     * HEADER DÙNG CHUNG (giống hệt header + thanh menu của Trang chủ).
     * Yêu cầu trang gọi phải nạp sẵn: Tailwind CDN, Font Awesome, assets/css/home.css, assets/js/home.js.
     * Tự nạp danh mục cho mega-menu nếu servlet chưa đặt attribute.
     */
    if (request.getAttribute("hierarchyCategories") == null) {
        service.IProductService siteHeaderService = new service.impl.ProductServiceImpl();
        request.setAttribute("hierarchyCategories", siteHeaderService.getHierarchyCategories());
    }
%>
        <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />

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
                            <input type="text" name="query" placeholder="Tìm kiếm hoa quả tươi sạch, táo, cam..." class="home-search-input">
                            <button type="submit" class="home-search-btn" title="Tìm kiếm">
                                <i class="fa-solid fa-magnifying-glass text-xs"></i>
                            </button>
                        </form>
                    </div>

                    <!-- User Actions -->
                    <div class="flex items-center gap-3 sm:gap-4">
                        <!-- Xử lý hiển thị nút Kênh Người Bán hoặc Đăng Ký Shop dựa trên Role -->
                        <c:choose>
                            <c:when test="${currentUser.role eq 'SHOP_OWNER'}">
                                <a href="${pageContext.request.contextPath}/shop/dashboard" class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200/80 rounded-xl text-xs font-bold transition shadow-xs">
                                    <i class="fa-solid fa-sliders text-emerald-600"></i> Kênh Người Bán
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/seller/status" class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-200/80 rounded-xl text-xs font-bold transition shadow-xs" title="Đăng ký mở gian hàng bán hoa quả">
                                    <i class="fa-solid fa-store text-amber-600"></i> Đăng Ký Shop
                                </a>
                            </c:otherwise>
                        </c:choose>

                        <c:choose>
                            <c:when test="${empty sessionScope.account and empty sessionScope.user}">
                                <div class="flex items-center gap-2">
                                    <a href="${pageContext.request.contextPath}/login" class="text-sm font-semibold text-gray-700 hover:text-emerald-600 transition">Đăng nhập</a>
                                    <span class="text-gray-300">/</span>
                                    <a href="${pageContext.request.contextPath}/register" class="text-sm font-semibold bg-emerald-600 text-white px-4 py-2 rounded-xl hover:bg-emerald-700 transition shadow-sm">Đăng ký</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="flex items-center gap-3 relative group">
                                    <div class="flex items-center gap-2.5 cursor-pointer py-1">
                                        <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'}" 
                                             alt="Avatar" class="w-10 h-10 rounded-full object-cover border-2 border-emerald-500 shadow-sm">
                                        <div class="hidden md:block text-left">
                                            <span class="block text-[10px] text-gray-400 font-medium leading-none">Xin chào,</span>
                                            <span class="text-sm font-bold text-gray-800 group-hover:text-emerald-600 transition leading-tight">
                                                ${not empty currentUser.fullName ? currentUser.fullName : currentUser.username}
                                            </span>
                                        </div>
                                        <i class="fa-solid fa-chevron-down text-xs text-gray-400 ml-1"></i>
                                    </div>

                                    <!-- Dropdown Menu khi rê chuột vào Avatar -->
                                    <div class="absolute right-0 top-full pt-2 w-56 hidden group-hover:block z-50">
                                        <div class="bg-white rounded-2xl shadow-xl border border-gray-100 p-2 space-y-1">
                                            <div class="px-3 py-2 border-b border-gray-100">
                                                <p class="text-xs font-bold text-gray-900 truncate">${currentUser.fullName}</p>
                                                <p class="text-[11px] text-gray-500 truncate">${currentUser.email}</p>
                                            </div>
                                            
                                            <c:choose>
                                                <c:when test="${currentUser.role eq 'SHOP_OWNER'}">
                                                    <a href="${pageContext.request.contextPath}/shop/dashboard" class="flex items-center gap-2 px-3 py-2 text-xs font-bold text-emerald-700 bg-emerald-50 rounded-xl hover:bg-emerald-100 transition">
                                                        <i class="fa-solid fa-sliders text-emerald-600"></i> Kênh Quản Lý Shop
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/store?id=${sessionScope.shopId != null ? sessionScope.shopId : 1}" class="flex items-center gap-2 px-3 py-2 text-xs font-bold text-amber-800 bg-amber-50 rounded-xl hover:bg-amber-100 transition">
                                                        <i class="fa-solid fa-store text-amber-600"></i> Gian Hàng Của Tôi
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/seller/status" class="flex items-center gap-2 px-3 py-2 text-xs font-bold text-amber-800 bg-amber-50 rounded-xl hover:bg-amber-100 transition">
                                                        <i class="fa-solid fa-store text-amber-600"></i> Đăng Ký Trở Thành Seller
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>

                                            <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2 px-3 py-2 text-xs font-medium text-gray-700 rounded-xl hover:bg-gray-100 transition">
                                                <i class="fa-solid fa-user-gear text-gray-400"></i> Tài khoản của tôi
                                            </a>
                                            <a href="${pageContext.request.contextPath}/orders" class="flex items-center gap-2 px-3 py-2 text-xs font-medium text-gray-700 rounded-xl hover:bg-gray-100 transition">
                                                <i class="fa-solid fa-bag-shopping text-gray-400"></i> Đơn mua
                                            </a>
                                            <div class="pt-1 border-t border-gray-100">
                                                <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-2 px-3 py-2 text-xs font-semibold text-red-600 rounded-xl hover:bg-red-50 transition">
                                                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                                </a>
                                            </div>
                                        </div>
                                    </div>
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
        <nav class="bg-emerald-900 text-white hidden md:block">
            <div class="max-w-7xl mx-auto px-4 flex items-center justify-between text-sm font-medium">
                <div class="flex items-center space-x-1">
                    <a href="${pageContext.request.contextPath}/home" class="home-nav-item">
                        <i class="fa-solid fa-house"></i> Trang chủ
                    </a>
                    <a href="${pageContext.request.contextPath}/store" class="home-nav-item">
                        <i class="fa-solid fa-store text-xs"></i> Gian hàng nông trại
                    </a>
                    <!-- Dropdown Danh Mục -->
                    <div class="relative group">
                        <button type="button" id="categoryMenuToggle" class="home-nav-item cursor-pointer focus:outline-none">
                            <span>Danh mục</span>
                            <i id="categoryChevron" class="fa-solid fa-chevron-down text-xs group-hover:rotate-180 transition-transform duration-200"></i>
                        </button>
                        
                        <!-- Dropdown Panel Mega-Menu (Hiển thị khi rê chuột hoặc bấm) -->
                        <div id="categoryDropdownPanel" class="home-category-dropdown hidden group-hover:block">
                            <div class="home-category-dropdown-box">
                                <div class="px-2 py-1.5 border-b border-gray-100 flex items-center justify-between mb-4">
                                    <span class="text-xs font-bold text-gray-500 uppercase tracking-wider">
                                        <i class="fa-solid fa-layer-group text-emerald-600 mr-1.5"></i> Danh Mục Nông Sản Tươi Sạch
                                    </span>
                                    <a href="${pageContext.request.contextPath}/products" class="text-xs font-bold text-emerald-600 hover:text-emerald-700 hover:underline">Xem tất cả nông sản &rarr;</a>
                                </div>
                                <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6 text-gray-800">
                                    <c:forEach var="cat" items="${hierarchyCategories}">
                                        <div class="flex flex-col">
                                            <a href="${pageContext.request.contextPath}/products?category=${cat.slug}" class="group/cat flex flex-col items-center sm:items-start text-center sm:text-left mb-2.5">
                                                <div class="w-16 h-16 rounded-full flex items-center justify-center p-1 bg-gray-50 border border-gray-100 mb-2 group-hover/cat:scale-110 transition duration-300">
                                                    <img src="${pageContext.request.contextPath}/${cat.imageUrl}" alt="${cat.categoryName}" class="max-w-full max-h-full object-contain">
                                                </div>
                                                <span class="font-bold text-sm text-gray-900 group-hover/cat:text-emerald-600 transition leading-snug">
                                                    ${cat.categoryName}
                                                </span>
                                            </a>
                                            <c:if test="${not empty cat.subCategories}">
                                                <div class="space-y-1.5 border-t border-gray-100 pt-2 text-left">
                                                    <c:forEach var="sub" items="${cat.subCategories}">
                                                        <a href="${pageContext.request.contextPath}/products?category=${sub.slug}" class="text-xs text-gray-600 hover:text-emerald-600 underline underline-offset-2 decoration-gray-300 hover:decoration-emerald-500 transition block py-0.5 font-medium">
                                                            ${sub.categoryName}
                                                        </a>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/home#featured" class="home-nav-item">Sản phẩm nổi bật</a>
                    <a href="${pageContext.request.contextPath}/home#featured" class="home-nav-item text-amber-300 font-semibold"><i class="fa-solid fa-fire"></i> Bán chạy</a>
                    <a href="${pageContext.request.contextPath}/home#about" class="home-nav-item">Về chúng tôi</a>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/home#featured" class="bg-amber-500 hover:bg-amber-600 text-gray-900 font-bold px-4 py-1.5 rounded-lg text-xs shadow-sm transition flex items-center gap-1.5">
                        <i class="fa-solid fa-bag-shopping"></i> Mua Ngay Hôm Nay
                    </a>
                </div>
            </div>
        </nav>
