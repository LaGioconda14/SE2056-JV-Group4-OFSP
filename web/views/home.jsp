<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
        
        <!-- CSS Tùy Chỉnh Đồng Bộ Giao Diện -->
        <style>
            body { font-family: 'Inter', sans-serif; }
            .home-search-input {
                width: 100%;
                padding: 0.6rem 2.8rem 0.6rem 1rem;
                background-color: #f3f4f6;
                border: 1px solid #e5e7eb;
                border-radius: 0.75rem;
                font-size: 0.875rem;
                outline: none;
                transition: all 0.2s;
            }
            .home-search-input:focus {
                background-color: #ffffff;
                border-color: #10b981;
                box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
            }
            .home-search-btn {
                position: absolute;
                right: 0.5rem;
                top: 50%;
                transform: translateY(-50%);
                width: 2rem;
                height: 2rem;
                background-color: #10b981;
                color: white;
                border-radius: 0.5rem;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .home-nav-item {
                padding: 0.75rem 1rem;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                color: #e5e7eb;
                transition: color 0.2s;
            }
            .home-nav-item:hover, .home-nav-item.active {
                color: #ffffff;
                font-weight: 600;
            }
            .hero-banner {
                background: linear-gradient(135deg, #064e3b 0%, #047857 50%, #10b981 100%);
                color: white;
                padding: 4rem 2rem;
                position: relative;
                overflow: hidden;
                border-radius: 1.5rem;
                margin: 1.5rem auto;
                max-width: 80rem;
            }
            .hero-badge {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                background: rgba(255, 255, 255, 0.15);
                backdrop-filter: blur(8px);
                padding: 0.35rem 0.85rem;
                border-radius: 9999px;
                font-size: 0.75rem;
                font-weight: 700;
                margin-bottom: 1rem;
                border: 1px solid rgba(255, 255, 255, 0.2);
            }
            .hero-title {
                font-size: 2.5rem;
                font-weight: 800;
                line-height: 1.2;
                margin-bottom: 1rem;
            }
            @media (min-width: 640px) { .hero-title { font-size: 3.5rem; } }
            .hero-desc {
                font-size: 1rem;
                color: #d1fae5;
                margin-bottom: 1.75rem;
                max-width: 36rem;
            }
            .hero-btn-primary {
                background-color: #f59e0b;
                color: #111827;
                font-weight: 800;
                padding: 0.75rem 1.75rem;
                border-radius: 0.75rem;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                transition: all 0.2s;
                box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
            }
            .hero-btn-primary:hover {
                background-color: #d97706;
                transform: translateY(-2px);
            }
            .hero-btn-secondary {
                background: rgba(255, 255, 255, 0.1);
                color: white;
                font-weight: 700;
                padding: 0.75rem 1.5rem;
                border-radius: 0.75rem;
                border: 1px solid rgba(255, 255, 255, 0.25);
                transition: all 0.2s;
            }
            .hero-btn-secondary:hover { background: rgba(255, 255, 255, 0.2); }
            
            .product-card {
                background: white;
                border-radius: 1.25rem;
                border: 1px solid #f3f4f6;
                padding: 1rem;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                height: 100%;
                transition: all 0.3s ease;
            }
            .product-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 12px 24px -8px rgba(0, 0, 0, 0.08);
                border-color: #a7f3d0;
            }
            .product-card > div:first-child {
                flex: 1;
                display: flex;
                flex-direction: column;
            }
            .product-thumb {
                position: relative;
                width: 100%;
                height: 180px;
                border-radius: 0.85rem;
                overflow: hidden;
                margin-bottom: 0.75rem;
                background-color: #f9fafb;
                flex-shrink: 0;
            }
            .product-thumb img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.5s ease;
            }
            .product-card:hover .product-thumb img { transform: scale(1.08); }
            .product-meta {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                margin-bottom: 0.35rem;
            }
            .product-cat-name { font-size: 0.7rem; font-weight: 700; color: #10b981; text-transform: uppercase; }
            .product-name {
                font-weight: 700;
                font-size: 0.95rem;
                color: #111827;
                line-height: 1.4;
                margin-bottom: 0.35rem;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
                text-overflow: ellipsis;
                height: 2.8em;
            }
            .product-origin { font-size: 0.75rem; color: #6b7280; margin-bottom: 0.5rem; }
            .product-card-footer { 
                display: flex; 
                align-items: center; 
                justify-content: space-between; 
                padding-top: 0.75rem; 
                border-top: 1px solid #f3f4f6; 
                margin-top: auto;
            }
            .product-price { font-size: 1.1rem; font-weight: 800; color: #059669; }
            .product-old-price { font-size: 0.75rem; color: #9ca3af; text-decoration: line-through; margin-left: 0.35rem; }
            .btn-add-cart {
                width: 2.25rem;
                height: 2.25rem;
                background-color: #ecfdf5;
                color: #059669;
                border-radius: 0.65rem;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: all 0.2s;
                flex-shrink: 0;
            }
            .btn-add-cart:hover { background-color: #059669; color: white; }
        </style>
    </head>
    <body class="bg-gray-50 text-gray-800 font-sans antialiased selection:bg-emerald-500 selection:text-white">

        <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />

        <!-- Header -->
        <header class="sticky top-0 z-40 bg-white shadow-md transition-all">
            <div class="max-w-7xl mx-auto px-4 py-3 sm:py-4">
                <div class="flex items-center justify-between gap-4">
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

                    <div class="flex-1 max-w-lg mx-4 hidden md:block">
                        <form action="${pageContext.request.contextPath}/search" method="GET" class="relative">
                            <input type="text" name="query" placeholder="Tìm kiếm hoa quả tươi sạch, táo, cam..." class="home-search-input">
                            <button type="submit" class="home-search-btn" title="Tìm kiếm">
                                <i class="fa-solid fa-magnifying-glass text-xs"></i>
                            </button>
                        </form>
                    </div>

                    <div class="flex items-center gap-3 sm:gap-4">
                        <c:if test="${currentUser.role eq 'SHOP_OWNER'}">
                            <a href="${pageContext.request.contextPath}/shop/products" class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200/80 rounded-xl text-xs font-bold transition shadow-xs">
                                <i class="fa-solid fa-sliders text-emerald-600"></i> Kênh Người Bán
                            </a>
                        </c:if>
                        <c:if test="${currentUser.role eq 'DRIVER'}">
                            <a href="${pageContext.request.contextPath}/shipper/deliveries" class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-200/80 rounded-xl text-xs font-bold transition shadow-xs">
                                <i class="fa-solid fa-truck text-amber-600"></i> Cổng Giao Vận
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
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>

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
                    <a href="#featured" class="home-nav-item">Sản phẩm nổi bật</a>
                    <a href="#featured" class="home-nav-item text-amber-300 font-semibold"><i class="fa-solid fa-fire"></i> Bán chạy</a>
                    <a href="#about" class="home-nav-item">Về chúng tôi</a>
                </div>
            </div>
        </nav>

        <!-- Hero Banner Section -->
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
        </section>

        <!-- Categories Section (Mapping ảnh chuẩn xác tuyệt đối cho từng danh mục) -->
        <section id="categories" class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex justify-between items-end mb-6">
                <div>
                    <h2 class="text-xl sm:text-2xl font-extrabold text-gray-900 tracking-tight flex items-center gap-2">
                        <i class="fa-solid fa-layer-group text-emerald-600"></i> Khám Phá Danh Mục Nông Sản
                    </h2>
                    <p class="text-xs sm:text-sm text-gray-500 mt-1">Tuyển tập hoa quả tươi ngon, chuẩn sạch VietGAP & GlobalGAP theo nhu cầu dinh dưỡng</p>
                </div>
                <a href="${pageContext.request.contextPath}/products" class="text-xs sm:text-sm font-bold text-emerald-600 hover:text-emerald-700 flex items-center gap-1 transition group">
                    Xem Tất Cả <i class="fa-solid fa-arrow-right group-hover:translate-x-1 transition-transform"></i>
                </a>
            </div>

            <div class="bg-white rounded-3xl p-6 sm:p-8 border border-gray-100 shadow-sm">
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 sm:gap-6">
                    <c:forEach var="cat" items="${categories}">
                        <c:set var="nameLower" value="${fn:toLowerCase(cat.categoryName)}" />
                        
                        <!-- Ảnh mặc định tổng hợp chất lượng cao -->
                        <c:set var="realImg" value="https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=200&h=200&fit=crop" />
                        
                        <!-- Phân loại chi tiết chuẩn xác theo từng loại quả -->
                        <c:choose>
                            <c:when test="${fn:contains(nameLower, 'táo envy')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'táo') or fn:contains(nameLower, 'lê') or fn:contains(nameLower, 'ổi')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'nho')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'xoài') or fn:contains(nameLower, 'chuối')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1553279768-865429fa0078?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'dâu') or fn:contains(nameLower, 'mọng')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'dưa hấu') or fn:contains(nameLower, 'dưa lưới') or fn:contains(nameLower, 'giải nhiệt')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'thanh long')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'bưởi') or fn:contains(nameLower, 'cam') or fn:contains(nameLower, 'quýt')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'kiwi')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1585059895050-66e5b5a21670?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'mận')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1596363505789-4e6139223594?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'hộp quà') or fn:contains(nameLower, 'quà tặng')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'nhập khẩu')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'việt nam')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1528825871115-3581a5387919?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'thùng') or fn:contains(nameLower, 'nguyên kiện')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1595855759920-86582396756a?w=200&h=200&fit=crop" />
                            </c:when>
                            <c:when test="${fn:contains(nameLower, 'cắt sẵn') or fn:contains(nameLower, 'eat-clean') or fn:contains(nameLower, 'văn phòng')}">
                                <c:set var="realImg" value="https://images.unsplash.com/photo-1519996529931-28324d5a630e?w=200&h=200&fit=crop" />
                            </c:when>
                        </c:choose>

                        <a href="${pageContext.request.contextPath}/products?category=${cat.slug}" 
                           class="group flex flex-col items-center justify-center p-4 rounded-2xl bg-gray-50/70 hover:bg-emerald-50/60 border border-gray-100 hover:border-emerald-200 transition-all duration-300 hover:-translate-y-1 hover:shadow-md text-center">
                            
                            <!-- Khung ảnh tròn -->
                            <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-full flex items-center justify-center mb-3 bg-white border-2 border-gray-100 group-hover:border-emerald-500 shadow-xs group-hover:scale-105 transition-all duration-300 overflow-hidden">
                                <img src="${not empty cat.imageUrl ? pageContext.request.contextPath.concat('/').concat(cat.imageUrl) : realImg}" 
                                     alt="${cat.categoryName}" 
                                     onerror="this.onerror=null; this.src='${realImg}';" 
                                     class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500">
                            </div>

                            <!-- Tên danh mục -->
                            <h3 class="font-bold text-xs sm:text-sm text-gray-800 group-hover:text-emerald-600 transition line-clamp-2 leading-snug">
                                ${cat.categoryName}
                            </h3>
                        </a>
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
            </div>

            <!-- Product Grid -->
            <div id="homeProductGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:choose>
                    <c:when test="${not empty listProduct}">
                        <c:forEach var="p" items="${listProduct}">
                            <div class="product-card group">
                                <div>
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="product-thumb">
                                        <img src="${p.image}" alt="${p.name}">
                                    </a>
                                    
                                    <div class="product-meta">
                                        <span class="product-cat-name">${p.categoryName}</span>
                                    </div>

                                    <h3 class="product-name" title="${p.name}">
                                        <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                    </h3>

                                    <c:if test="${not empty p.origin}">
                                        <p class="product-origin">
                                            <i class="fa-solid fa-location-dot text-[10px] text-emerald-600"></i> ${p.origin}
                                        </p>
                                    </c:if>
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

        <!-- Full Footer -->
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
                            <li><a href="#" class="hover:text-emerald-400 transition">Hướng Dẫn Mua Hàng</a></li>
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