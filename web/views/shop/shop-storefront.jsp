<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty shop.shopName ? shop.shopName : 'Nông Trại Hữu Cơ Mộc Châu'} - FreshFruit Storefront</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8fafc;
            color: #1e293b;
        }
        .hide-scrollbar::-webkit-scrollbar {
            display: none;
        }
        .hide-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col antialiased">



    <!-- 2. MAIN HEADER -->
    <header class="sticky top-0 z-40 bg-white shadow-sm border-b border-gray-100">
        <div class="max-w-7xl mx-auto px-4 py-3 sm:py-3.5">
            <div class="flex items-center justify-between gap-4">
                
                <!-- Logo -->
                <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2.5 flex-shrink-0 group">
                    <div class="w-10 h-10 bg-emerald-50 rounded-full flex items-center justify-center p-1.5 border border-emerald-200 shadow-xs">
                        <svg viewBox="0 0 100 100" class="w-full h-full">
                            <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                            <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                            <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                            <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                        </svg>
                    </div>
                    <span class="text-xl sm:text-2xl font-black tracking-tight text-gray-900">
                        Fresh<span class="text-emerald-600">Fruit</span>
                    </span>
                </a>

                <!-- Search Bar with Category Select -->
                <div class="flex-1 max-w-2xl mx-4 hidden md:block">
                    <form action="${pageContext.request.contextPath}/search" method="GET" class="flex items-center bg-gray-50 border border-gray-200 hover:border-emerald-500 focus-within:border-emerald-600 rounded-full p-1 transition shadow-inner">
                        <div class="relative pl-3 pr-2 py-1 border-r border-gray-200">
                            <select name="categoryId" class="bg-transparent text-xs font-bold text-gray-700 focus:outline-none cursor-pointer pr-4">
                                <option value="">Tất Cả Quả</option>
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.categoryId}">${c.categoryName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <input type="text" name="query" placeholder="Tìm kiếm dâu tây, cam canh mật ong, mận tam hoa, organic..."
                               class="flex-1 bg-transparent px-3 py-1.5 text-xs sm:text-sm text-gray-800 focus:outline-none placeholder-gray-400">
                        <button type="submit" class="w-9 h-9 bg-emerald-600 hover:bg-emerald-700 text-white rounded-full flex items-center justify-center transition shadow-sm flex-shrink-0">
                            <i class="fa-solid fa-magnifying-glass text-xs"></i>
                        </button>
                    </form>
                </div>

                <!-- Right Actions: Wishlist, Cart & Profile -->
                <div class="flex items-center gap-3.5">
                    <!-- Wishlist button -->
                    <a href="#" class="relative p-2 text-gray-500 hover:text-emerald-700 transition" title="Danh sách yêu thích">
                        <i class="fa-regular fa-heart text-xl"></i>
                        <span class="absolute top-0 right-0 bg-red-500 text-white text-[10px] w-4 h-4 rounded-full flex items-center justify-center font-bold">0</span>
                    </a>

                    <!-- Cart button with total amount -->
                    <a href="${pageContext.request.contextPath}/cart" class="flex items-center gap-2.5 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200/80 px-3.5 py-1.5 rounded-full transition group">
                        <div class="relative">
                            <i class="fa-solid fa-basket-shopping text-emerald-800 text-lg"></i>
                            <span class="absolute -top-1.5 -right-2 bg-emerald-700 text-white text-[10px] w-4 h-4 rounded-full flex items-center justify-center font-black">
                                ${sessionScope.cartSize != null ? sessionScope.cartSize : 1}
                            </span>
                        </div>
                        <div class="hidden sm:block text-left text-xs leading-tight">
                            <span class="block text-[10px] text-gray-500 font-semibold uppercase">Giỏ hàng</span>
                            <span class="font-extrabold text-emerald-800">285.000₫</span>
                        </div>
                    </a>

                    <!-- User Account / Avatar -->
                    <c:choose>
                        <c:when test="${empty sessionScope.account and empty sessionScope.user}">
                            <a href="${pageContext.request.contextPath}/login" class="text-xs font-bold bg-emerald-700 hover:bg-emerald-800 text-white px-4 py-2 rounded-full transition shadow-xs">
                                Đăng Nhập
                            </a>
                        </c:when>
                        <c:otherwise>
                            <c:set var="currentUser" value="${not empty sessionScope.account ? sessionScope.account : sessionScope.user}" />
                            <div class="relative group cursor-pointer">
                                <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'}" 
                                     alt="Avatar" class="w-9 h-9 rounded-full object-cover border border-emerald-500 shadow-xs">
                                <!-- Dropdown -->
                                <div class="absolute right-0 top-full pt-2 w-52 hidden group-hover:block z-50">
                                    <div class="bg-white rounded-2xl shadow-xl border border-gray-100 p-2 space-y-1 text-xs">
                                        <div class="px-3 py-2 border-b border-gray-100">
                                            <p class="font-bold text-gray-900 truncate">${currentUser.fullName}</p>
                                            <p class="text-[11px] text-gray-400 truncate">${currentUser.email}</p>
                                        </div>
                                        <c:if test="${currentUser.role eq 'SHOP_OWNER'}">
                                            <a href="${pageContext.request.contextPath}/shop/products" class="flex items-center gap-2 px-3 py-2 font-bold text-emerald-700 bg-emerald-50 rounded-xl hover:bg-emerald-100 transition">
                                                <i class="fa-solid fa-store"></i> Kênh Quản Lý Shop
                                            </a>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2 px-3 py-2 text-gray-700 hover:bg-gray-100 rounded-xl transition">
                                            <i class="fa-solid fa-user text-gray-400"></i> Tài khoản của tôi
                                        </a>
                                        <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-2 px-3 py-2 text-red-600 hover:bg-red-50 rounded-xl font-semibold transition">
                                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>

                </div>
            </div>
        </div>
    </header>

    <!-- 3. SUB-NAV BAR -->
    <nav class="bg-white border-b border-gray-100 hidden md:block">
        <div class="max-w-7xl mx-auto px-4 flex items-center justify-between text-xs font-semibold text-gray-600">
            <div class="flex items-center space-x-6 py-2.5">
                <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700 transition">Trang Chủ</a>
                <a href="${pageContext.request.contextPath}/store" class="text-emerald-700 font-bold flex items-center gap-1.5 transition">
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span> Gian Hàng Shop
                </a>
                <a href="#shop-products" class="hover:text-emerald-700 transition">Danh Mục Nông Sản</a>
                <a href="#reviews" class="hover:text-emerald-700 transition">Đánh Giá Khách Hàng</a>
                <a href="#footer" class="hover:text-emerald-700 transition">Liên Hệ</a>
            </div>
            <div>
                <span class="inline-flex items-center gap-1.5 bg-amber-50 text-amber-800 border border-amber-200/80 px-3 py-1 rounded-full text-[11px] font-bold">
                    <i class="fa-solid fa-bolt text-amber-500"></i> Ưu Đãi Mùa Vụ - Giảm Đến 25%
                </span>
            </div>
        </div>
    </nav>

    <!-- 4. SHOP HERO COVER & PROFILE CARD -->
    <section class="relative">
        <!-- Big Scenic Cover Banner -->
        <div class="w-full h-64 sm:h-72 md:h-80 bg-gray-900 relative overflow-hidden">
            <img src="${not empty shop.bannerUrl ? shop.bannerUrl : 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1600&fit=crop'}" 
                 alt="Farm Cover" 
                 class="w-full h-full object-cover opacity-85">
            <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent"></div>
        </div>

        <!-- Floating Shop Profile Card (Overlapping cover) -->
        <div class="max-w-7xl mx-auto px-4 -mt-24 sm:-mt-20 relative z-20">
            <div class="bg-white rounded-3xl p-6 sm:p-8 shadow-xl border border-gray-100 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6">
                
                <!-- Left: Avatar + Details -->
                <div class="flex items-start sm:items-center gap-5 flex-1">
                    <!-- Shop Logo Avatar with Verified Badge -->
                    <div class="relative flex-shrink-0">
                        <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-2xl border-4 border-white bg-white shadow-md overflow-hidden flex items-center justify-center p-1">
                            <img src="${not empty shop.logoUrl ? shop.logoUrl : 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=150&h=150&fit=crop'}" 
                                 alt="Shop Logo" 
                                 class="w-full h-full object-cover rounded-xl">
                        </div>
                        <div class="absolute -bottom-1 -right-1 w-6 h-6 bg-emerald-600 text-white rounded-full flex items-center justify-center text-xs shadow-md border-2 border-white" title="Chứng nhận nông trại xác thực">
                            <i class="fa-solid fa-check text-[10px]"></i>
                        </div>
                    </div>

                    <!-- Shop Text Info -->
                    <div class="space-y-1.5">
                        <div class="flex flex-wrap items-center gap-2.5">
                            <h1 class="text-2xl sm:text-3xl font-black text-gray-950 tracking-tight">
                                ${not empty shop.shopName ? shop.shopName : 'Nông Trại Hữu Cơ Mộc Châu'}
                            </h1>
                            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 text-xs font-bold">
                                <i class="fa-solid fa-shield-halved text-emerald-600 text-xs"></i> 
                                ${not empty shop.certificationName ? shop.certificationName : 'VietGAP Certified'}
                            </span>
                        </div>

                        <p class="text-xs sm:text-sm text-gray-600 max-w-2xl leading-relaxed">
                            ${not empty shop.description ? shop.description : 'Direct from highland volcanic soils. Grown at 1,050m altitude with pristine spring water and zero synthetic pesticides.'}
                        </p>

                        <!-- Stats Row -->
                        <div class="flex flex-wrap items-center gap-4 sm:gap-6 pt-1 text-xs text-gray-500 font-medium">
                            <div class="flex items-center gap-1 text-gray-900 font-bold">
                                <i class="fa-solid fa-star text-amber-400"></i>
                                <span>${shop.rating != null ? shop.rating : '4.9'}</span>
                                <span class="text-gray-400 font-normal">(${reviews != null ? reviews.size() : 1420} đánh giá)</span>
                            </div>
                            <span class="text-gray-300 hidden sm:inline">&bull;</span>
                            <div class="flex items-center gap-1.5">
                                <i class="fa-solid fa-users text-gray-400"></i>
                                <span class="font-bold text-gray-900">8.4k</span> người theo dõi
                            </div>
                            <span class="text-gray-300 hidden sm:inline">&bull;</span>
                            <div class="flex items-center gap-1.5 text-emerald-700 font-semibold">
                                <i class="fa-solid fa-bolt text-emerald-600"></i>
                                <span>100% tỷ lệ phản hồi (&lt; 1 giờ)</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right: Action Buttons -->
                <div class="flex items-center gap-3 w-full lg:w-auto justify-end pt-2 lg:pt-0">
                    <button type="button" id="btnFollowShop" onclick="toggleFollowShop()" 
                            class="flex-1 lg:flex-none px-5 py-3 rounded-2xl border border-gray-300 hover:border-emerald-600 bg-white hover:bg-emerald-50 text-gray-800 hover:text-emerald-800 font-bold text-xs sm:text-sm flex items-center justify-center gap-2 transition shadow-xs">
                        <i class="fa-regular fa-bookmark text-sm" id="followIcon"></i>
                        <span id="followText">Theo Dõi Shop</span>
                    </button>

                    <button type="button" onclick="alert('Mở cửa sổ trò chuyện trực tiếp với chủ nông trại!')" 
                            class="flex-1 lg:flex-none px-6 py-3 rounded-2xl bg-emerald-800 hover:bg-emerald-900 text-white font-extrabold text-xs sm:text-sm flex items-center justify-center gap-2 transition shadow-md hover:shadow-lg">
                        <i class="fa-solid fa-comment-dots text-base"></i>
                        <span>Chat với Shop</span>
                    </button>
                </div>

            </div>
        </div>
    </section>

    <!-- 5. CATEGORY FILTER PILLS & SORTING BAR -->
    <section id="shop-products" class="max-w-7xl mx-auto px-4 pt-12 pb-6">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-200/70 pb-5">
            
            <!-- Category Pills Filter -->
            <div class="flex items-center gap-2 overflow-x-auto hide-scrollbar py-1">
                <!-- All Products Pill -->
                <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}&sort=${selectedSort}" 
                   class="px-4 py-2 rounded-full text-xs font-bold transition flex items-center gap-1.5 whitespace-nowrap shadow-xs ${empty selectedCatId ? 'bg-emerald-800 text-white' : 'bg-white border border-gray-200 text-gray-700 hover:border-emerald-600'}">
                    Tất Cả Sản Phẩm (${totalProductsCount})
                </a>

                <!-- Dynamic Category Pills from DB -->
                <c:forEach var="c" items="${categories}">
                    <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}&cat=${c.categoryId}&sort=${selectedSort}" 
                       class="px-4 py-2 rounded-full text-xs font-bold transition flex items-center gap-1.5 whitespace-nowrap shadow-xs ${selectedCatId eq c.categoryId ? 'bg-emerald-800 text-white' : 'bg-white border border-gray-200 text-gray-700 hover:border-emerald-600'}">
                        ${c.categoryName} (${c.productCount})
                    </a>
                </c:forEach>
            </div>

            <!-- Sort Dropdown -->
            <div class="flex items-center gap-2 flex-shrink-0 self-end md:self-auto">
                <span class="text-xs text-gray-500 font-medium">Sắp xếp:</span>
                <select onchange="location.href='${pageContext.request.contextPath}/store?id=${shop.shopId}&cat=${selectedCatId}&sort=' + this.value" 
                        class="bg-white border border-gray-200 rounded-xl px-3 py-1.5 text-xs font-bold text-gray-800 focus:outline-none focus:border-emerald-600 cursor-pointer shadow-xs">
                    <option value="featured" ${selectedSort eq 'featured' ? 'selected' : ''}>Nổi Bật Nhất</option>
                    <option value="price_asc" ${selectedSort eq 'price_asc' ? 'selected' : ''}>Giá: Thấp Đến Cao</option>
                    <option value="price_desc" ${selectedSort eq 'price_desc' ? 'selected' : ''}>Giá: Cao Đến Thấp</option>
                    <option value="newest" ${selectedSort eq 'newest' ? 'selected' : ''}>Mới Thu Hoạch</option>
                </select>
            </div>

        </div>
    </section>

    <!-- 6. PRODUCT GRID (4 COLUMNS) -->
    <main class="max-w-7xl mx-auto px-4 pb-14">
        <c:choose>
            <c:when test="${not empty products}">
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    <c:forEach var="p" items="${products}">
                        <div class="bg-white rounded-3xl p-4 border border-gray-100 shadow-xs hover:shadow-xl transition-all duration-300 flex flex-col justify-between group">
                            
                            <div>
                                <!-- Image with Tag Badge & Heart Icon -->
                                <div class="relative aspect-square rounded-2xl overflow-hidden bg-gray-50 mb-3.5">
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="block w-full h-full">
                                        <img src="${p.image}" alt="${p.name}" 
                                             class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500">
                                    </a>

                                    <!-- Tag Badge -->
                                    <div class="absolute top-2.5 left-2.5 flex flex-col gap-1">
                                        <c:if test="${not empty p.tag}">
                                            <span class="bg-emerald-950/80 backdrop-blur-xs text-emerald-200 text-[10px] font-bold px-2.5 py-0.5 rounded-full uppercase tracking-wider shadow-xs">
                                                ${p.tag}
                                            </span>
                                        </c:if>
                                        <c:if test="${p.discountPercent > 0}">
                                            <span class="bg-rose-600 text-white text-[10px] font-extrabold px-2 py-0.5 rounded-full shadow-xs">
                                                -${p.discountPercent}%
                                            </span>
                                        </c:if>
                                    </div>

                                    <!-- Wishlist Heart Button -->
                                    <button type="button" onclick="this.classList.toggle('text-rose-600'); this.classList.toggle('text-gray-400');"
                                            class="absolute top-2.5 right-2.5 w-8 h-8 rounded-full bg-white/90 backdrop-blur-xs hover:bg-white text-gray-400 hover:text-rose-600 flex items-center justify-center transition shadow-xs" title="Yêu thích">
                                        <i class="fa-solid fa-heart text-xs"></i>
                                    </button>
                                </div>

                                <!-- Farm / Origin Subtitle -->
                                <div class="flex items-center justify-between text-[11px] text-gray-400 font-medium mb-1">
                                    <span>${p.origin}</span>
                                    <div class="flex items-center gap-1 text-amber-500 font-bold">
                                        <i class="fa-solid fa-star text-[10px]"></i>
                                        <span class="text-gray-800">${p.rating}</span>
                                        <span class="text-gray-400 font-normal">(${p.reviewsCount})</span>
                                    </div>
                                </div>

                                <!-- Product Title -->
                                <h3 class="font-extrabold text-sm sm:text-base text-gray-900 group-hover:text-emerald-700 transition line-clamp-2 leading-snug mb-1">
                                    <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                </h3>

                                <!-- Unit / Pack Info -->
                                <p class="text-xs text-gray-500 mb-3 font-medium">
                                    ${p.unit}
                                </p>
                            </div>

                            <!-- Pricing & + Add Button -->
                            <div class="flex items-center justify-between pt-2 border-t border-gray-50">
                                <div>
                                    <c:if test="${p.oldPrice > p.price}">
                                        <span class="block text-[11px] text-gray-400 line-through">
                                            <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />₫
                                        </span>
                                    </c:if>
                                    <span class="text-base sm:text-lg font-black text-gray-950">
                                        <fmt:formatNumber value="${p.price}" pattern="#,###" />₫
                                    </span>
                                </div>

                                <!-- + Add Button -->
                                <form action="${pageContext.request.contextPath}/add-to-cart" method="GET">
                                    <input type="hidden" name="productId" value="${p.id}">
                                    <button type="submit" 
                                            class="bg-emerald-800 hover:bg-emerald-900 text-white font-extrabold text-xs px-4 py-2 rounded-xl transition shadow-xs flex items-center gap-1.5 transform active:scale-95">
                                        <i class="fa-solid fa-plus text-xs"></i> Thêm
                                    </button>
                                </form>
                            </div>

                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="text-center py-16 bg-white rounded-3xl border border-gray-100 shadow-sm">
                    <i class="fa-solid fa-box-open text-4xl text-gray-300 mb-3"></i>
                    <p class="text-gray-600 font-bold text-base">Chưa có sản phẩm nào trong danh mục này.</p>
                    <a href="${pageContext.request.contextPath}/store?id=${shop.shopId}" class="inline-block mt-3 text-xs font-bold text-emerald-700 hover:underline">
                        &larr; Xem tất cả sản phẩm của shop
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>



    <!-- 8. CUSTOMER REVIEWS SECTION -->
    <section id="reviews" class="max-w-7xl mx-auto px-4 pb-20">
        <!-- Review Section Header -->
        <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
            <div>
                <span class="text-[11px] font-black uppercase tracking-widest text-emerald-700">PHẢN HỒI XÁC THỰC</span>
                <h2 class="text-2xl sm:text-3xl font-black text-gray-950 tracking-tight">
                    Đánh Giá Khách Hàng Cho ${not empty shop.shopName ? shop.shopName : 'Nông Trại Hữu Cơ Mộc Châu'}
                </h2>
            </div>
            <!-- Overall Score Badge -->
            <div class="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl border border-gray-100 shadow-xs">
                <span class="text-xl font-black text-gray-950">${shop.rating != null ? shop.rating : '4.9'}</span>
                <div class="flex text-amber-400 text-xs gap-0.5">
                    <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                </div>
                <span class="text-xs text-gray-400 font-medium">(${reviews != null ? reviews.size() : 1420} lượt đánh giá)</span>
            </div>
        </div>

        <!-- 3 Review Cards Grid -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <c:forEach var="rev" items="${reviews}">
                <div class="bg-white rounded-3xl p-6 border border-gray-100 shadow-xs flex flex-col justify-between space-y-4">
                    <div>
                        <!-- User Header -->
                        <div class="flex items-center justify-between mb-3">
                            <div class="flex items-center gap-3">
                                <img src="${rev.customerAvatar}" alt="Customer" class="w-10 h-10 rounded-full object-cover border border-gray-200">
                                <div>
                                    <h4 class="font-extrabold text-sm text-gray-900 leading-tight">${rev.customerName}</h4>
                                    <span class="text-[11px] text-gray-400 font-medium">Đã mua hàng &bull; ${rev.timeAgo}</span>
                                </div>
                            </div>
                            <div class="flex text-amber-400 text-[11px] gap-0.5">
                                <c:forEach begin="1" end="${rev.rating}">
                                    <i class="fa-solid fa-star"></i>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- Review Comment -->
                        <p class="text-xs sm:text-sm text-gray-600 leading-relaxed font-normal italic">
                            "${rev.comment}"
                        </p>
                    </div>

                    <!-- Purchased Product Tag -->
                    <div class="pt-3 border-t border-gray-50">
                        <span class="inline-flex items-center gap-1.5 text-[11px] text-emerald-800 font-bold bg-emerald-50 px-3 py-1 rounded-full">
                            <i class="fa-solid fa-check text-emerald-600"></i> Đã mua: ${rev.productName}
                        </span>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>

    <!-- 9. FOOTER -->
    <footer id="footer" class="bg-gray-950 text-gray-300 pt-16 pb-8 border-t border-gray-800 mt-auto">
        <div class="max-w-7xl mx-auto px-4">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10 mb-12">
                <!-- Brand Bio -->
                <div>
                    <div class="flex items-center gap-2.5 mb-4">
                        <div class="w-9 h-9 bg-emerald-50 rounded-full flex items-center justify-center p-1">
                            <svg viewBox="0 0 100 100" class="w-full h-full">
                                <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                                <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                                <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                                <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                            </svg>
                        </div>
                        <span class="text-xl font-extrabold text-white">Fresh<span class="text-emerald-500">Fruit</span></span>
                    </div>
                    <p class="text-xs text-gray-400 mb-6 leading-relaxed">
                        Nông sản tươi sạch tuyển chọn từ các nông trại hữu cơ hàng đầu, thu hoạch chín tự nhiên và giao nhanh trong ngày.
                    </p>
                    <div class="flex items-center space-x-3 text-gray-400 text-sm">
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-900 hover:bg-emerald-600 hover:text-white flex items-center justify-center transition"><i class="fa-brands fa-facebook-f"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-900 hover:bg-emerald-600 hover:text-white flex items-center justify-center transition"><i class="fa-brands fa-instagram"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-900 hover:bg-emerald-600 hover:text-white flex items-center justify-center transition"><i class="fa-brands fa-tiktok"></i></a>
                    </div>
                </div>

                <!-- Quick Links -->
                <div>
                    <h4 class="text-white font-bold text-sm mb-4">Liên Kết Nhanh</h4>
                    <ul class="space-y-2 text-xs">
                        <li><a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-400 transition">Trang Chủ</a></li>
                        <li><a href="${pageContext.request.contextPath}/store" class="hover:text-emerald-400 transition">Gian Hàng Nông Trại</a></li>
                        <li><a href="#shop-products" class="hover:text-emerald-400 transition">Tất Cả Sản Phẩm</a></li>
                        <li><a href="#reviews" class="hover:text-emerald-400 transition">Khách Hàng Đánh Giá</a></li>
                    </ul>
                </div>

                <!-- Customer Service -->
                <div>
                    <h4 class="text-white font-bold text-sm mb-4">Chăm Sóc Khách Hàng</h4>
                    <ul class="space-y-2 text-xs">
                        <li><a href="#" class="hover:text-emerald-400 transition">Chính Sách Đổi Trả 1-1</a></li>
                        <li><a href="#" class="hover:text-emerald-400 transition">Tiêu Chuẩn Chuỗi Lạnh</a></li>
                        <li><a href="#" class="hover:text-emerald-400 transition">Hướng Dẫn Mua Hàng</a></li>
                        <li><a href="#" class="hover:text-emerald-400 transition">Câu Hỏi Thường Gặp (FAQs)</a></li>
                        <li><a href="#" class="hover:text-emerald-400 transition">Hỗ Trợ Trực Tuyến 24/7</a></li>
                    </ul>
                </div>

                <!-- Contact & Payment -->
                <div>
                    <h4 class="text-white font-bold text-sm mb-4">Liên Hệ & Thanh Toán</h4>
                    <ul class="space-y-2 text-xs text-gray-400 mb-4">
                        <li class="flex items-center gap-2"><i class="fa-solid fa-phone text-emerald-500"></i> +1 (800) 673-7438</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-envelope text-emerald-500"></i> care@freshfruit.com</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-location-dot text-emerald-500"></i> Mộc Châu, Sơn La &bull; TP. Hà Nội</li>
                    </ul>
                    <div class="flex items-center space-x-2 text-xs text-gray-400">
                        <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">VISA</span>
                        <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">MasterCard</span>
                        <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">Apple Pay</span>
                        <span class="bg-gray-900 px-2 py-1 rounded border border-gray-800">VNPAY</span>
                    </div>
                </div>
            </div>

            <div class="pt-8 border-t border-gray-800/80 flex flex-col sm:flex-row justify-between items-center text-xs text-gray-500 gap-4">
                <p>&copy; 2026 FreshFruit Marketplace Inc. All rights reserved.</p>
                <div class="flex space-x-6">
                    <a href="#" class="hover:text-gray-400">Chính sách bảo mật</a>
                    <a href="#" class="hover:text-gray-400">Điều khoản sử dụng</a>
                    <a href="#" class="hover:text-gray-400">Sơ đồ trang</a>
                </div>
            </div>
        </div>
    </footer>

    <!-- Interactive script for Follow Shop button -->
    <script>
        let isFollowing = false;
        function toggleFollowShop() {
            isFollowing = !isFollowing;
            const btn = document.getElementById('btnFollowShop');
            const icon = document.getElementById('followIcon');
            const text = document.getElementById('followText');
            
            if (isFollowing) {
                btn.classList.add('bg-emerald-100', 'border-emerald-600', 'text-emerald-800');
                btn.classList.remove('bg-white', 'text-gray-800');
                icon.className = 'fa-solid fa-check text-sm text-emerald-700';
                text.textContent = 'Đang Theo Dõi';
            } else {
                btn.classList.remove('bg-emerald-100', 'border-emerald-600', 'text-emerald-800');
                btn.classList.add('bg-white', 'text-gray-800');
                icon.className = 'fa-regular fa-bookmark text-sm';
                text.textContent = 'Theo Dõi Shop';
            }
        }
    </script>

</body>
</html>

