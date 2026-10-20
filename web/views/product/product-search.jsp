<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tìm kiếm: ${txtSearch} - FreshFruit</title>
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Google Fonts Inter -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <style>
            body { font-family: 'Inter', sans-serif; }
            .home-search-input { width: 100%; padding: .6rem 2.8rem .6rem 1rem; background: #f3f4f6; border: 1px solid #e5e7eb; border-radius: .75rem; font-size: .875rem; outline: none; transition: all .2s; }
            .home-search-input:focus { background: #fff; border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,.15); }
            .home-search-btn { position: absolute; right: .5rem; top: 50%; transform: translateY(-50%); width: 2rem; height: 2rem; background: #10b981; color: white; border-radius: .5rem; display: flex; align-items: center; justify-content: center; }
            .home-nav-item { padding: .75rem 1rem; display: inline-flex; align-items: center; gap: .5rem; color: #e5e7eb; transition: color .2s; }
            .home-nav-item:hover, .home-nav-item.active { color: white; font-weight: 600; }
            @media (max-width: 767px) { .home-search-mobile { display: block; margin-top: .75rem; } }
            .product-card { background: white; border-radius: 1.25rem; border: 1px solid #f3f4f6; padding: 1rem; display: flex; flex-direction: column; justify-content: space-between; height: 100%; transition: all .3s ease; }
            .product-card:hover { transform: translateY(-4px); box-shadow: 0 12px 24px -8px rgba(0,0,0,.08); border-color: #a7f3d0; }
            .product-thumb { position: relative; display: block; width: 100%; height: 180px; border-radius: .85rem; overflow: hidden; margin-bottom: .75rem; background: #f9fafb; }
            .product-thumb img { width: 100%; height: 100%; object-fit: cover; transition: transform .5s ease; }
            .product-card:hover .product-thumb img { transform: scale(1.08); }
            .product-card-footer { display: flex; align-items: center; justify-content: space-between; padding-top: .75rem; border-top: 1px solid #f3f4f6; margin-top: auto; }
            .product-price { font-size: 1.1rem; font-weight: 800; color: #059669; }
            .product-old-price { font-size: .75rem; color: #9ca3af; text-decoration: line-through; margin-left: .35rem; }
            .btn-add-cart { width: 2.5rem; height: 2.5rem; background: #ecfdf5; color: #059669; border-radius: .75rem; display: flex; align-items: center; justify-content: center; transition: all .2s; flex-shrink: 0; }
            .btn-add-cart:hover { background: #059669; color: white; }
        </style>
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

                    <!-- Thanh Search -->
                    <div class="flex-1 max-w-lg mx-4 hidden md:block">
                        <form action="${pageContext.request.contextPath}/search" method="GET" class="relative">
                            <input type="text" name="query" value="${txtSearch}" placeholder="Tìm kiếm hoa quả tươi sạch, táo, cam..." class="home-search-input">
                            <button type="submit" class="home-search-btn" title="Tìm kiếm">
                                <i class="fa-solid fa-magnifying-glass text-xs"></i>
                            </button>
                        </form>
                    </div>

                    <!-- User Actions -->
                    <div class="flex items-center gap-4">
                        <c:choose>
                            <c:when test="${empty sessionScope.account and empty sessionScope.user}">
                                <div class="flex items-center gap-2">
                                    <a href="${pageContext.request.contextPath}/login" class="text-sm font-semibold text-gray-700 hover:text-emerald-600 transition">Đăng nhập</a>
                                    <span class="text-gray-300">/</span>
                                    <a href="${pageContext.request.contextPath}/register" class="text-sm font-semibold bg-emerald-600 text-white px-4 py-2 rounded-xl hover:bg-emerald-700 transition shadow-sm">Đăng ký</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="flex items-center gap-3 cursor-pointer group">
                                    <img src="${not empty currentUser.avatar ? currentUser.avatar : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'}" 
                                         alt="Avatar" class="w-10 h-10 rounded-full object-cover border-2 border-emerald-500 shadow-sm">
                                    <div class="hidden md:block text-left">
                                        <span class="block text-xs text-gray-500">Xin chào,</span>
                                        <span class="text-sm font-bold text-gray-800 group-hover:text-emerald-600 transition">
                                            ${not empty currentUser.fullName ? currentUser.fullName : currentUser.username}
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
                    <div class="home-search-mobile md:hidden">
                        <form action="${pageContext.request.contextPath}/search" method="GET" class="relative">
                            <input type="text" name="query" value="${txtSearch}" placeholder="Tìm kiếm hoa quả tươi sạch, táo, cam..." class="home-search-input" aria-label="Tìm kiếm sản phẩm">
                            <button type="submit" class="home-search-btn" title="Tìm kiếm" aria-label="Tìm kiếm"><i class="fa-solid fa-magnifying-glass text-xs" aria-hidden="true"></i></button>
                        </form>
                    </div>
            </div>
        </header>

        <!-- Navigation đồng bộ với trang chủ -->
        <nav class="bg-emerald-900 text-white hidden md:block">
            <div class="max-w-7xl mx-auto px-4 flex items-center justify-between text-sm font-medium">
                <div class="flex items-center space-x-1">
                    <a href="${pageContext.request.contextPath}/home" class="home-nav-item">
                        <i class="fa-solid fa-house"></i> Trang chủ
                    </a>
                    <a href="${pageContext.request.contextPath}/store" class="home-nav-item"><i class="fa-solid fa-store text-xs"></i> Gian hàng nông trại</a>
                    <a href="${pageContext.request.contextPath}/home#featured" class="home-nav-item">Sản phẩm nổi bật</a>
                    <a href="${pageContext.request.contextPath}/home#about" class="home-nav-item">Về chúng tôi</a>
                </div>
            </div>
        </nav>

        <!-- Main Content Section: Search Results & Filter Sidebar -->
        <main class="max-w-7xl mx-auto px-4 py-8">
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
                
                <!-- CỘT TRÁI: BỘ LỌC TÌM KIẾM -->
<aside class="lg:col-span-1 filter-card space-y-6 bg-white p-6 rounded-3xl border border-gray-100 shadow-sm">
    <h2 class="font-extrabold text-base text-gray-900 flex items-center gap-2.5 border-b border-gray-100 pb-4">
        <i class="fa-solid fa-filter text-emerald-600"></i> BỘ LỌC TÌM KIẾM
    </h2>

    <form action="${pageContext.request.contextPath}/search" method="GET" class="space-y-6">
        <!-- Giữ nguyên từ khóa tìm kiếm khi lọc -->
        <input type="hidden" name="query" value="${txtSearch}" />

        <!-- Theo Danh Mục (Đổ dữ liệu động từ Database) -->
        <div>
            <h3 class="font-bold text-sm mb-3 text-gray-800">Theo Danh Mục</h3>
            <div class="space-y-2.5 text-sm max-h-60 overflow-y-auto pr-2">
                <label class="flex items-center gap-2.5 cursor-pointer text-gray-600 hover:text-emerald-600 transition">
                    <input type="radio" name="categoryId" value="" ${empty selectedCategory or selectedCategory == '0' ? 'checked' : ''} class="text-emerald-600 focus:ring-emerald-500"> Tất cả danh mục
                </label>
                
                <c:forEach var="cat" items="${listCategories}">
                    <label class="flex items-center gap-2.5 cursor-pointer text-gray-600 hover:text-emerald-600 transition">
                        <input type="radio" name="categoryId" value="${cat.categoryId}" ${selectedCategory == cat.categoryId ? 'checked' : ''} class="text-emerald-600 focus:ring-emerald-500"> 
                        ${cat.categoryName}
                    </label>
                </c:forEach>
            </div>
        </div>

        <!-- Khoảng Giá -->
        <div class="border-t border-gray-100 pt-5">
            <h3 class="font-bold text-sm mb-3 text-gray-800">Khoảng Giá (VNĐ)</h3>
            <div class="flex items-center gap-2 mb-3">
                <input type="number" name="minPrice" value="${minPrice}" placeholder="đ TỪ" class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-xs focus:outline-none focus:border-emerald-500">
                <span class="text-gray-400 font-bold">-</span>
                <input type="number" name="maxPrice" value="${maxPrice}" placeholder="đ ĐẾN" class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-xs focus:outline-none focus:border-emerald-500">
            </div>
        </div>

        <!-- Đánh Giá -->
        <div class="border-t border-gray-100 pt-5">
            <label for="ratingFilter" class="font-bold text-sm mb-3 text-gray-800 block">Đánh giá từ</label>
            <select id="ratingFilter" name="rating" class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-emerald-500">
                <option value="" ${empty selectedRating ? 'selected' : ''}>Tất cả đánh giá</option>
                <option value="4" ${selectedRating == '4' ? 'selected' : ''}>4 sao trở lên</option>
                <option value="5" ${selectedRating == '5' ? 'selected' : ''}>5 sao</option>
            </select>
        </div>

        <!-- Tình trạng hàng -->
        <div class="border-t border-gray-100 pt-5">
            <label for="availabilityFilter" class="font-bold text-sm mb-3 text-gray-800 block">Tình trạng hàng</label>
            <select id="availabilityFilter" name="availability" class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-emerald-500">
                <option value="" ${empty selectedAvailability ? 'selected' : ''}>Tất cả</option>
                <option value="in_stock" ${selectedAvailability == 'in_stock' ? 'selected' : ''}>Còn hàng</option>
                <option value="out_of_stock" ${selectedAvailability == 'out_of_stock' ? 'selected' : ''}>Hết hàng</option>
            </select>
        </div>

        <!-- Xuất xứ -->
        <div class="border-t border-gray-100 pt-5">
            <label for="originFilter" class="font-bold text-sm mb-3 text-gray-800 block">Xuất xứ</label>
            <input id="originFilter" type="text" name="origin" value="${selectedOrigin}" placeholder="Ví dụ: Đà Lạt, Mỹ, Nhật Bản" class="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:border-emerald-500">
        </div>

        <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs py-3 rounded-xl transition shadow-sm">ÁP DỤNG BỘ LỌC</button>
    </form>
</aside>

                <!-- CỘT PHẢI: KẾT QUẢ TÌM KIẾM & LƯỚI SẢN PHẨM -->
                <div class="lg:col-span-3 space-y-6">
                    <div class="bg-white p-5 rounded-3xl shadow-sm text-sm text-gray-700 border border-gray-100 flex items-center justify-between">
                        <div>Kết quả tìm kiếm cho từ khóa: <span class="font-extrabold text-emerald-600">"${txtSearch}"</span></div>
                    </div>

                    <!-- Shop Liên Quan Đến Tìm Kiếm (Shopee Style) -->
                    <c:if test="${not empty matchingShops}">
                        <div class="space-y-3">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-bold text-gray-500 uppercase tracking-wider flex items-center gap-1.5">
                                    <i class="fa-solid fa-store text-emerald-600"></i> Gian Hàng Nông Trại Phù Hợp
                                </span>
                            </div>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <c:forEach var="s" items="${matchingShops}">
                                    <div class="bg-white rounded-3xl p-5 border border-emerald-100 shadow-sm hover:shadow-md transition flex items-center justify-between gap-4">
                                        <div class="flex items-center gap-3.5">
                                            <img src="${not empty s.logoUrl ? s.logoUrl : 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=150&h=150&fit=crop'}" 
                                                 alt="${s.shopName}" class="w-14 h-14 rounded-2xl object-cover border-2 border-emerald-500 shadow-xs flex-shrink-0">
                                            <div>
                                                <div class="flex items-center gap-2">
                                                    <h4 class="font-extrabold text-sm text-gray-900">${s.shopName}</h4>
                                                    <span class="text-[10px] bg-emerald-50 text-emerald-800 font-bold px-2 py-0.5 rounded-full border border-emerald-200">
                                                        <i class="fa-solid fa-check text-[9px]"></i> Chuẩn VietGAP
                                                    </span>
                                                </div>
                                                <p class="text-xs text-gray-500 line-clamp-1 mt-0.5">${s.description}</p>
                                                <div class="flex items-center gap-2 text-xs text-gray-400 mt-1">
                                                    <span class="text-amber-500 font-bold"><i class="fa-solid fa-star text-[10px]"></i> ${s.rating}</span>
                                                    <span>&bull;</span>
                                                    <span>${not empty s.province ? s.province : 'Mộc Châu, Sơn La'}</span>
                                                </div>
                                            </div>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/store?id=${s.shopId}" 
                                           class="px-4 py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs shadow-xs transition flex-shrink-0 flex items-center gap-1.5">
                                            <i class="fa-solid fa-store text-xs"></i> Xem Shop
                                        </a>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- Lưới sản phẩm chuẩn chỉnh, bo góc mềm mại và bắt mắt -->
<div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6">
    <c:choose>
        <c:when test="${not empty listProduct}">
            <c:forEach var="p" items="${listProduct}">
                <div class="product-card group">
                    <div>
                        <!-- Khung ảnh sản phẩm có hiệu ứng phóng to và nhãn giảm giá -->
                        <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="product-thumb">
                                <img src="${not empty p.image ? p.image : 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=600&h=600&fit=crop'}" loading="lazy"
                                     alt="${p.name}" 
                                     onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=600&h=600&fit=crop';">
                            <c:if test="${p.discountPercent > 0}">
                                <span class="absolute top-3 left-3 bg-rose-500 text-white font-extrabold text-[10px] px-2.5 py-1 rounded-full shadow-md">
                                    -${p.discountPercent}%
                                </span>
                            </c:if>
                        </a>

                        <!-- Tên danh mục -->
                        <div class="flex items-center gap-2 mb-1">
                        <span class="text-[11px] font-extrabold text-emerald-600 uppercase tracking-wider">
                            ${not empty p.categoryName ? p.categoryName : 'Trái Cây Tươi'}
                        </span>
                        </div>

                        <!-- Tên sản phẩm giới hạn 2 dòng -->
                        <h3 class="font-bold text-sm text-gray-900 mt-1 mb-2 line-clamp-2 h-10 leading-snug">
                            <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="hover:text-emerald-600 transition-colors">
                                ${p.name}
                            </a>
                        </h3>

                        <!-- Đánh giá sao -->
                        <div class="flex items-center gap-1 text-xs text-amber-400 mb-3">
                            <c:choose>
                                <c:when test="${p.reviewsCount > 0}">
                                    <i class="fa-solid fa-star"></i>
                                    <span class="font-bold text-gray-700"><fmt:formatNumber value="${p.rating}" maxFractionDigits="1" /></span>
                                    <span class="text-gray-400 text-[11px]">(${p.reviewsCount} đánh giá)</span>
                                </c:when>
                                <c:otherwise><span class="text-gray-400 text-[11px]">Chưa có đánh giá</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Phần giá và nút thêm giỏ hàng ở đáy card -->
                    <div class="product-card-footer">
                        <div>
                            <span class="product-price">
                                <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                            </span>
                            <c:if test="${p.oldPrice gt p.price}">
                                <span class="product-old-price block">
                                    <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />đ
                                </span>
                            </c:if>
                        </div>
                        
                        <form action="${pageContext.request.contextPath}/add-to-cart" method="GET">
                            <input type="hidden" name="productId" value="${p.id}" />
                            <button type="submit" class="btn-add-cart" title="Thêm vào giỏ hàng">
                                <i class="fa-solid fa-cart-plus text-sm"></i>
                            </button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="col-span-full text-center py-16 bg-white rounded-3xl border border-gray-100 shadow-sm">
                <i class="fa-solid fa-box-open text-5xl text-gray-300 mb-3"></i>
                <p class="text-gray-500 font-medium text-base">Không tìm thấy sản phẩm phù hợp.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>
                </div>

            </div>
        </main>

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
