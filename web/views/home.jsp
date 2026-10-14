<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // Tự động load danh sách sản phẩm trang chủ và danh mục qua Service nếu truy cập trực tiếp
    if (request.getAttribute("listProduct") == null) {
        service.IProductService pService = new service.impl.ProductServiceImpl();
        request.setAttribute("listProduct", pService.getHomeProducts());
        request.setAttribute("homeTabs", pService.getHomeFeaturedTabs());
        request.setAttribute("hierarchyCategories", pService.getHierarchyCategories());
        request.setAttribute("categories", pService.getAllCategories());
    }
    if (request.getAttribute("homeTabs") == null) {
        service.IProductService pService = new service.impl.ProductServiceImpl();
        request.setAttribute("homeTabs", pService.getHomeFeaturedTabs());
    }
    if (request.getAttribute("hierarchyCategories") == null) {
        service.IProductService pService = new service.impl.ProductServiceImpl();
        request.setAttribute("hierarchyCategories", pService.getHierarchyCategories());
    }
%>
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
        <!-- FreshFruit Home Custom Stylesheet -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
        <!-- FreshFruit Home Custom Scripts -->
        <script src="${pageContext.request.contextPath}/assets/js/home.js" defer></script>
    </head>
    <body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

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
                        <c:if test="${currentUser.role eq 'SHOP_OWNER'}">
                            <a href="${pageContext.request.contextPath}/shop/products" class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200/80 rounded-xl text-xs font-bold transition shadow-xs">
                                <i class="fa-solid fa-sliders text-emerald-600"></i> Kênh Người Bán
                            </a>
                        </c:if>
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
                                            
                                            <c:if test="${currentUser.role eq 'SHOP_OWNER'}">
                                                <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center gap-2 px-3 py-2 text-xs font-bold text-emerald-700 bg-emerald-50 rounded-xl hover:bg-emerald-100 transition">
                                                    <i class="fa-solid fa-sliders text-emerald-600"></i> Kênh Quản Lý Shop
                                                </a>
                                                <a href="${pageContext.request.contextPath}/store?id=${sessionScope.shopId != null ? sessionScope.shopId : 1}" class="flex items-center gap-2 px-3 py-2 text-xs font-bold text-amber-800 bg-amber-50 rounded-xl hover:bg-amber-100 transition">
                                                    <i class="fa-solid fa-store text-amber-600"></i> Gian Hàng Của Tôi
                                                </a>
                                            </c:if>

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
                    <a href="${pageContext.request.contextPath}/home" class="home-nav-item active">
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
                    <a href="#featured" class="home-nav-item">Sản phẩm nổi bật</a>
                    <a href="#featured" class="home-nav-item text-amber-300 font-semibold"><i class="fa-solid fa-fire"></i> Bán chạy</a>
                    <a href="#about" class="home-nav-item">Về chúng tôi</a>
                </div>
                <div>
                    <a href="#featured" class="bg-amber-500 hover:bg-amber-600 text-gray-900 font-bold px-4 py-1.5 rounded-lg text-xs shadow-sm transition flex items-center gap-1.5">
                        <i class="fa-solid fa-bag-shopping"></i> Mua Ngay Hôm Nay
                    </a>
                </div>
            </div>
        </nav>

        <!-- Hero Banner Section (Full-width edge-to-edge) -->
        <section class="hero-banner">
            <div class="max-w-7xl mx-auto px-4 relative z-10">
                <div class="relative z-10 max-w-3xl">
                    <div class="hero-badge">
                        <i class="fa-solid fa-award text-amber-300"></i> 100% Organic Đạt Chuẩn VietGAP & GlobalGAP
                    </div>
                    <h1 class="hero-title">
                        Hoa Quả Tươi Sạch,<br>Giao Nhanh Mỗi Ngày.
                    </h1>
                    <p class="hero-desc">
                        Tuyển chọn từ những nông trại hữu cơ hàng đầu, thu hoạch chín tự nhiên và vận chuyển bằng công nghệ lạnh khép kín giữ trọn vitamin.
                    </p>
                    <div class="flex flex-wrap items-center gap-4">
                        <a href="#featured" class="hero-btn-primary">
                            Mua Ngay <i class="fa-solid fa-arrow-right"></i>
                        </a>
                        <a href="#categories" class="hero-btn-secondary">
                            Khám Phá Danh Mục
                        </a>
                    </div>
                </div>
            </div>
            <div class="absolute right-0 bottom-0 opacity-10 pointer-events-none transform translate-x-12 translate-y-12">
                <i class="fa-solid fa-basket-shopping text-[360px]"></i>
            </div>
        </section>

        <!-- Categories Section (Thiết kế đúng theo phân cấp danh mục) -->
        <section id="categories" class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex justify-between items-end mb-6">
                <div>
                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight">Khám Phá Danh Mục Nông Sản</h2>
                    <p class="text-xs sm:text-sm text-gray-500">Tuyển tập hoa quả tươi ngon, chuẩn sạch VietGAP & GlobalGAP theo nhu cầu dinh dưỡng</p>
                </div>
                <a href="${pageContext.request.contextPath}/products" class="text-xs sm:text-sm font-bold text-emerald-600 hover:text-emerald-700 flex items-center gap-1 transition">
                    Xem Tất Cả &rarr;
                </a>
            </div>

            <!-- Khối danh mục thiết kế theo mẫu -->
            <div class="bg-white rounded-3xl p-6 sm:p-8 border border-gray-100 shadow-sm">
                <div class="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6 sm:gap-8">
                    <c:forEach var="cat" items="${hierarchyCategories}">
                        <div class="flex flex-col items-start">
                            <a href="${pageContext.request.contextPath}/products?category=${cat.slug}" class="group flex flex-col items-center sm:items-start text-center sm:text-left mb-3 w-full">
                                <div class="w-24 h-24 sm:w-28 sm:h-28 rounded-full flex items-center justify-center p-2 mb-3 bg-gray-50/80 border border-gray-100/80 group-hover:scale-105 transition-transform duration-300">
                                    <img src="${pageContext.request.contextPath}/${cat.imageUrl}" alt="${cat.categoryName}" class="max-w-full max-h-full object-contain">
                                </div>
                                <h3 class="font-bold text-base sm:text-lg text-gray-900 group-hover:text-emerald-600 transition leading-snug">
                                    ${cat.categoryName}
                                </h3>
                            </a>
                            <c:if test="${not empty cat.subCategories}">
                                <div class="space-y-2 w-full text-left">
                                    <c:forEach var="sub" items="${cat.subCategories}">
                                        <a href="${pageContext.request.contextPath}/products?category=${sub.slug}" 
                                           class="text-xs sm:text-sm text-gray-700 hover:text-emerald-600 underline underline-offset-4 decoration-gray-300 hover:decoration-emerald-500 transition block leading-relaxed font-medium">
                                            ${sub.categoryName}
                                        </a>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </section>

        <!-- Featured Products Section -->
        <section id="featured" class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
                <div>
                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight">Sản Phẩm Tươi Ngon Theo Danh Mục</h2>
                    <p class="text-xs sm:text-sm text-gray-500">Tuyển tập hoa quả hữu cơ chuẩn VietGAP & GlobalGAP tươi sạch mỗi ngày</p>
                </div>
                <div class="home-tabs-container flex-wrap sm:flex-nowrap overflow-x-auto max-w-full">
                    <button type="button" onclick="filterHomeProducts('all', this)" class="home-tab-btn active">
                        <i class="fa-solid fa-border-all mr-1 text-xs"></i> Tất Cả
                    </button>
                    <c:forEach var="tab" items="${homeTabs}">
                        <button type="button" onclick="filterHomeProducts('${tab.slug}', this)" class="home-tab-btn" data-slug="${tab.slug}">
                            <c:choose>
                                <c:when test="${tab.slug eq 'trai-cay-nhap-khau'}"><i class="fa-solid fa-plane mr-1 text-xs text-sky-500"></i> </c:when>
                                <c:when test="${tab.slug eq 'trai-cay-viet-nam'}"><i class="fa-solid fa-seedling mr-1 text-xs text-emerald-500"></i> </c:when>
                                <c:when test="${tab.slug eq 'trai-cay-mua-he'}"><i class="fa-solid fa-sun mr-1 text-xs text-amber-500"></i> </c:when>
                                <c:when test="${tab.slug eq 'trai-cay-co-san'}"><i class="fa-solid fa-bolt mr-1 text-xs text-yellow-500"></i> </c:when>
                                <c:when test="${tab.slug eq 'trai-cay-dong-thung'}"><i class="fa-solid fa-box mr-1 text-xs text-amber-700"></i> </c:when>
                                <c:otherwise><i class="fa-solid fa-apple-whole mr-1 text-xs text-emerald-500"></i> </c:otherwise>
                            </c:choose>
                            ${tab.categoryName}
                        </button>
                    </c:forEach>
                </div>
            </div>

            <!-- Product Grid -->
            <div id="homeProductGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:choose>
                    <c:when test="${not empty listProduct}">
                        <c:forEach var="p" items="${listProduct}">
                            <div class="product-card group" data-category-slugs="${p.filterSlugs}" data-category="${p.categoryName}" data-cert="${p.certification}">
                                <div>
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="product-thumb">
                                        <img src="${p.image}" alt="${p.name}">
                                        <c:if test="${p.discountPercent > 0}">
                                            <span class="product-discount-badge">-${p.discountPercent}%</span>
                                        </c:if>
                                    </a>
                                    
                                    <div class="product-meta">
                                        <span class="product-cat-name">${p.categoryName}</span>
                                        <c:if test="${not empty p.certification}">
                                            <span class="product-cert-tag">${p.certification}</span>
                                        </c:if>
                                    </div>

                                    <h3 class="product-name">
                                        <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                    </h3>

                                    <c:if test="${not empty p.origin}">
                                        <p class="product-origin">
                                            <i class="fa-solid fa-location-dot text-[10px] text-emerald-600"></i> ${p.origin}
                                        </p>
                                    </c:if>

                                    <div class="product-rating">
                                        <i class="fa-solid fa-star"></i>
                                        <span class="font-bold text-gray-700">${p.rating}</span>
                                        <span class="text-gray-400">(${p.reviewsCount})</span>
                                    </div>
                                </div>

                                <div class="product-card-footer">
                                    <div>
                                        <span class="product-price">
                                            <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                                            <c:if test="${not empty p.unit}">
                                                <span class="text-xs font-semibold text-emerald-800/70">/${p.unit}</span>
                                            </c:if>
                                        </span>
                                        <c:if test="${p.oldPrice > p.price}">
                                            <span class="product-old-price">
                                                <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />đ
                                            </span>
                                        </c:if>
                                    </div>
                                    <form action="${pageContext.request.contextPath}/add-to-cart" method="GET">
                                        <input type="hidden" name="productId" value="${p.id}" />
                                        <button type="submit" class="btn-add-cart" title="Thêm vào giỏ hàng">
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
                            <c:forEach var="c" items="${categories}" end="4">
                                <li><a href="${pageContext.request.contextPath}/products?category=${c.slug}" class="hover:text-emerald-400 transition">${c.categoryName}</a></li>
                            </c:forEach>
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

