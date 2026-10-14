<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Mục Trái Cây Tươi - FreshFruit Marketplace</title>
    <!-- Google Fonts Inter & Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com" rel="preconnect">
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- FontAwesome 6 Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Custom Catalog CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product-catalog.css">
    <!-- Custom Catalog JS -->
    <script src="${pageContext.request.contextPath}/assets/js/product-catalog.js" defer></script>
</head>
<body class="bg-gray-50/50 font-['Plus_Jakarta_Sans',sans-serif] text-gray-800 antialiased">

    <!-- TOP ANNOUNCEMENT BAR -->
    <div class="catalog-header-topbar px-4">
        <div class="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-center gap-2">
            <div class="flex items-center gap-2">
                <i class="fa-solid fa-truck-fast text-emerald-200"></i>
                <span class="font-medium">Miễn phí giao hàng trong ngày cho đơn từ 300.000₫ | Cam kết 100% Nông sản tươi sạch</span>
            </div>
            <div class="flex items-center gap-5 text-emerald-100">
                <span class="flex items-center gap-1.5"><i class="fa-solid fa-phone text-xs"></i> 1900 6868</span>
                <span>|</span>
                <span>VND (₫)</span>
                <span>|</span>
                <span>VI <i class="fa-solid fa-chevron-down text-[10px]"></i></span>
            </div>
        </div>
    </div>

    <!-- MAIN NAVBAR -->
    <header class="bg-white border-b border-gray-100 sticky top-0 z-40 shadow-xs">
        <div class="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between gap-4">
            <!-- Brand Logo -->
            <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2.5">
                <div class="w-10 h-10 rounded-full bg-emerald-50 flex items-center justify-center p-1 border border-emerald-100">
                    <svg viewBox="0 0 100 100" class="w-full h-full">
                        <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                        <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                        <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                        <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                    </svg>
                </div>
                <div class="text-2xl font-black tracking-tight text-gray-900">
                    Fresh<span class="text-emerald-700">Fruit</span>
                </div>
            </a>

            <!-- Search Bar with Category Dropdown -->
            <div class="flex-1 max-w-2xl mx-4 hidden lg:block">
                <form action="${pageContext.request.contextPath}/products" method="GET" class="flex items-center rounded-2xl bg-gray-100 border border-transparent focus-within:border-emerald-500 focus-within:bg-white transition overflow-hidden">
                    <div class="px-3.5 py-2.5 border-r border-gray-200 text-xs font-semibold text-gray-600 flex items-center gap-1 cursor-pointer bg-gray-50/60 shrink-0">
                        <span>Tất cả</span>
                        <i class="fa-solid fa-chevron-down text-[10px] text-gray-400"></i>
                    </div>
                    <div class="relative flex-1 flex items-center">
                        <i class="fa-solid fa-magnifying-glass absolute left-3.5 text-gray-400 text-sm"></i>
                        <input type="text" name="keyword" value="${paramKeyword}" placeholder="Tìm kiếm táo tươi, dâu tây, cam ngọt, nông sản hữu cơ..." class="w-full bg-transparent pl-10 pr-4 py-2.5 text-sm text-gray-800 placeholder-gray-400 focus:outline-none">
                    </div>
                    <button type="submit" class="bg-emerald-800 hover:bg-emerald-900 text-white px-5 py-2.5 text-xs font-bold transition">
                        Tìm kiếm
                    </button>
                </form>
            </div>

            <!-- Right Actions: Wishlist, Cart & Profile -->
            <div class="flex items-center gap-3">
                <a href="#" class="relative w-10 h-10 rounded-full flex items-center justify-center text-gray-600 hover:bg-gray-100 transition" title="Yêu thích">
                    <i class="fa-regular fa-heart text-lg"></i>
                    <span class="absolute top-1.5 right-1.5 w-4 h-4 rounded-full bg-emerald-600 text-white text-[10px] font-bold flex items-center justify-center">3</span>
                </a>
                
                <a href="${pageContext.request.contextPath}/cart" class="flex items-center gap-2.5 px-3 py-1.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200/60 hover:bg-emerald-100 transition">
                    <div class="relative">
                        <i class="fa-solid fa-basket-shopping text-base"></i>
                        <span class="absolute -top-1.5 -right-2 bg-emerald-700 text-white text-[9px] font-bold rounded-full w-4 h-4 flex items-center justify-center">4</span>
                    </div>
                    <div class="flex flex-col text-left text-xs leading-none">
                        <span class="text-[9px] text-emerald-600 font-bold uppercase">Giỏ hàng</span>
                        <span class="font-extrabold text-emerald-950">250.000₫</span>
                    </div>
                </a>

                <!-- User profile avatar / Login button -->
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div class="relative group">
                            <a href="${pageContext.request.contextPath}/profile" class="w-9 h-9 rounded-full overflow-hidden border border-emerald-400 shrink-0 block">
                                <img src="${not empty sessionScope.user.avatarUrl ? sessionScope.user.avatarUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop'}" alt="User" class="w-full h-full object-cover">
                            </a>
                            <div class="absolute right-0 top-full pt-2 w-52 hidden group-hover:block z-50">
                                <div class="bg-white rounded-2xl shadow-xl border border-gray-100 p-2 space-y-1 text-xs">
                                    <div class="px-3 py-2 border-b border-gray-100">
                                        <p class="font-bold text-gray-900 truncate">${sessionScope.user.fullName}</p>
                                        <p class="text-[11px] text-gray-500 truncate">${sessionScope.user.email}</p>
                                    </div>
                                    <c:if test="${sessionScope.user.role eq 'SHOP_OWNER'}">
                                        <a href="${pageContext.request.contextPath}/shop/dashboard" class="flex items-center gap-2 px-3 py-2 font-bold text-emerald-700 bg-emerald-50 rounded-xl hover:bg-emerald-100 transition">
                                            <i class="fa-solid fa-store"></i> Kênh Quản Lý Shop
                                        </a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/profile" class="flex items-center gap-2 px-3 py-2 font-medium text-gray-700 rounded-xl hover:bg-gray-100 transition">
                                        <i class="fa-solid fa-user-gear text-gray-400"></i> Tài khoản của tôi
                                    </a>
                                    <div class="pt-1 border-t border-gray-100">
                                        <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-2 px-3 py-2 font-semibold text-red-600 rounded-xl hover:bg-red-50 transition">
                                            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="text-sm font-semibold text-emerald-700 hover:text-emerald-800 ml-1">Đăng Nhập</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- NAVIGATION LINKS BAR -->
        <div class="border-t border-gray-100 px-4">
            <div class="max-w-7xl mx-auto flex items-center justify-between text-sm py-2">
                <nav class="flex items-center space-x-7 font-medium text-gray-700">
                    <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700 transition">Trang Chủ</a>
                    <a href="${pageContext.request.contextPath}/products" class="text-emerald-700 font-bold border-b-2 border-emerald-700 pb-0.5">Cửa Hàng</a>
                    <a href="${pageContext.request.contextPath}/categories" class="hover:text-emerald-700 transition">Danh Mục</a>
                    <a href="${pageContext.request.contextPath}/deals" class="hover:text-emerald-700 transition">Khuyến Mãi</a>
                    <a href="${pageContext.request.contextPath}/about" class="hover:text-emerald-700 transition">Về Chúng Tôi</a>
                    <a href="${pageContext.request.contextPath}/contact" class="hover:text-emerald-700 transition">Liên Hệ</a>
                </nav>
                <div class="flex items-center gap-1.5 text-xs font-bold text-amber-800 bg-amber-50 px-3 py-1 rounded-full border border-amber-200">
                    <i class="fa-solid fa-bolt text-amber-500"></i>
                    <span>Khuyến Mãi Mùa Vụ - Giảm tới 25%</span>
                </div>
            </div>
        </div>
    </header>

    <!-- BREADCRUMB & PAGE HERO -->
    <div class="max-w-7xl mx-auto px-4 pt-6 pb-4">
        <nav class="flex items-center gap-2 text-xs text-gray-500 mb-3">
            <a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700">Trang chủ</a>
            <i class="fa-solid fa-chevron-right text-[9px] text-gray-400"></i>
            <a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700">Cửa hàng</a>
            <i class="fa-solid fa-chevron-right text-[9px] text-gray-400"></i>
            <span class="text-gray-900 font-semibold">Danh Mục Trái Cây Tươi</span>
        </nav>

        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-gray-200/80">
            <div>
                <div class="flex items-center gap-3">
                    <h1 class="text-3xl font-black text-gray-900 tracking-tight">Trái Cây Tươi Sạch</h1>
                    <span class="px-2.5 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-xs font-bold uppercase tracking-wider">
                        Hiển thị ${(currentPage - 1) * pageSize + 1}-${currentPage * pageSize > totalProducts ? totalProducts : currentPage * pageSize} trên tổng ${totalProducts} sản phẩm
                    </span>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                    Trồng tại các nông trường giàu khoáng chất, thu hoạch lúc bình minh và vận chuyển khép kín tới gia đình bạn.
                </p>
            </div>

            <!-- In-page Fast Search input with filter icon -->
            <form action="${pageContext.request.contextPath}/products" method="GET" class="relative w-full md:w-80">
                <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-gray-400 text-xs"></i>
                <input type="text" name="keyword" value="${paramKeyword}" placeholder="Tìm theo tên trái cây, đặc sản..." class="w-full bg-white border border-gray-200 rounded-xl pl-9 pr-8 py-2 text-xs text-gray-700 placeholder-gray-400 focus:outline-none focus:border-emerald-600 transition shadow-xs">
                <i class="fa-solid fa-sliders absolute right-3 top-2.5 text-gray-400 text-xs"></i>
            </form>
        </div>

        <!-- QUICK SUGGESTED TAGS -->
        <div class="flex items-center gap-2 overflow-x-auto py-3">
            <span class="text-xs font-bold text-gray-400 uppercase tracking-wider shrink-0 mr-1">Gợi ý:</span>
            <a href="${pageContext.request.contextPath}/products?tag=organic" class="suggested-tag ${paramTag eq 'organic' ? 'active' : ''}">
                <i class="fa-solid fa-leaf text-emerald-600 text-[10px]"></i> Hữu Cơ
            </a>
            <a href="${pageContext.request.contextPath}/products?keyword=Cam" class="suggested-tag">Cam Sành</a>
            <a href="${pageContext.request.contextPath}/products?keyword=Dâu" class="suggested-tag">Dâu Tây</a>
            <a href="${pageContext.request.contextPath}/products?tag=sale" class="suggested-tag ${paramTag eq 'sale' ? 'active' : ''}">
                <i class="fa-solid fa-tag text-amber-600 text-[10px]"></i> Đang Giảm Giá
            </a>
            <a href="${pageContext.request.contextPath}/products?tag=under5" class="suggested-tag ${paramTag eq 'under5' ? 'active' : ''}">Dưới 50.000₫</a>
            <a href="${pageContext.request.contextPath}/products?origin=Đà Lạt" class="suggested-tag">Nông Sản Đà Lạt</a>
            <c:if test="${not empty paramKeyword or not empty paramTag or not empty paramOrigin or not empty paramMinPrice}">
                <a href="${pageContext.request.contextPath}/products" class="suggested-tag text-red-600 hover:bg-red-50">
                    <i class="fa-solid fa-xmark text-[10px]"></i> Xóa Bộ Lọc
                </a>
            </c:if>
        </div>
    </div>

    <!-- MAIN BODY: FILTER SIDEBAR & PRODUCTS GRID -->
    <main class="max-w-7xl mx-auto px-4 pb-16">
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-7">

            <!-- CỘT TRÁI: BỘ LỌC TÌM KIẾM (FILTERS SIDEBAR) -->
            <aside class="lg:col-span-1">
                <form action="${pageContext.request.contextPath}/products" method="GET" class="catalog-filter-card space-y-6">
                    <input type="hidden" name="keyword" value="${paramKeyword}">
                    
                    <div class="flex items-center justify-between border-b border-gray-100 pb-3">
                        <div class="flex items-center gap-2 font-black text-sm text-gray-900 uppercase">
                            <i class="fa-solid fa-sliders text-emerald-700"></i> Bộ Lọc
                        </div>
                        <a href="${pageContext.request.contextPath}/products" class="text-xs font-semibold text-emerald-700 hover:underline">Thiết lập lại</a>
                    </div>

                    <!-- 1. Categories Filter -->
                    <div>
                        <div class="filter-section-title">Danh Mục Sản Phẩm</div>
                        <div class="space-y-2.5 text-xs text-gray-700">
                            <c:forEach var="cat" items="${listCategories}">
                                <label class="flex items-center justify-between cursor-pointer hover:text-emerald-700 transition">
                                    <div class="flex items-center gap-2.5">
                                        <input type="checkbox" name="category" value="${cat.categoryId}" 
                                               ${selectedCategoriesList != null and selectedCategoriesList.contains(String.valueOf(cat.categoryId)) ? 'checked' : ''} 
                                               class="w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-gray-300">
                                        <span class="font-medium">${cat.categoryName}</span>
                                    </div>
                                    <span class="text-gray-400 font-mono">${cat.productCount}</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 2. Price Range Filter -->
                    <div class="border-t border-gray-100 pt-5">
                        <div class="flex items-center justify-between mb-3">
                            <span class="filter-section-title mb-0">Khoảng Giá</span>
                            <span class="text-xs font-extrabold text-emerald-700 font-mono">10.000₫ - 500.000₫</span>
                        </div>
                        <div class="flex items-center gap-2 mt-3">
                            <div class="flex items-center gap-1 bg-gray-50 border border-gray-200 rounded-lg px-2.5 py-1.5 flex-1 text-xs">
                                <span class="text-gray-400">Từ</span>
                                <input type="number" name="minPrice" value="${paramMinPrice != null ? paramMinPrice : 0}" class="w-full bg-transparent font-bold text-gray-800 focus:outline-none">
                            </div>
                            <span class="text-gray-400 text-xs">-</span>
                            <div class="flex items-center gap-1 bg-gray-50 border border-gray-200 rounded-lg px-2.5 py-1.5 flex-1 text-xs">
                                <span class="text-gray-400">Đến</span>
                                <input type="number" name="maxPrice" value="${paramMaxPrice != null ? paramMaxPrice : 500000}" class="w-full bg-transparent font-bold text-gray-800 focus:outline-none">
                            </div>
                        </div>
                    </div>

                    <!-- 3. Customer Rating Filter -->
                    <div class="border-t border-gray-100 pt-5">
                        <div class="filter-section-title">Đánh Giá Khách Hàng</div>
                        <div class="space-y-2 text-xs text-gray-700">
                            <label class="flex items-center justify-between cursor-pointer">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="rating" value="5" ${paramRating == 5 ? 'checked' : ''} class="text-emerald-700 focus:ring-emerald-500">
                                    <div class="flex text-amber-400 text-xs gap-0.5">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i>
                                    </div>
                                </div>
                                <span class="text-gray-500">5 Sao</span>
                            </label>
                            <label class="flex items-center justify-between cursor-pointer">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="rating" value="4" ${paramRating == 4 ? 'checked' : ''} class="text-emerald-700 focus:ring-emerald-500">
                                    <div class="flex text-amber-400 text-xs gap-0.5">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star text-gray-300"></i>
                                    </div>
                                </div>
                                <span class="text-gray-500">Từ 4 sao</span>
                            </label>
                            <label class="flex items-center justify-between cursor-pointer">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="rating" value="3" ${paramRating == 3 ? 'checked' : ''} class="text-emerald-700 focus:ring-emerald-500">
                                    <div class="flex text-amber-400 text-xs gap-0.5">
                                        <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-regular fa-star text-gray-300"></i><i class="fa-regular fa-star text-gray-300"></i>
                                    </div>
                                </div>
                                <span class="text-gray-500">Từ 3 sao</span>
                            </label>
                        </div>
                    </div>

                    <!-- 4. Availability Filter -->
                    <div class="border-t border-gray-100 pt-5">
                        <div class="filter-section-title">Tình Trạng Kho</div>
                        <div class="space-y-2 text-xs text-gray-700">
                            <label class="flex items-center justify-between cursor-pointer">
                                <div class="flex items-center gap-2">
                                    <input type="checkbox" name="availability" value="in_stock" ${paramAvailability eq 'in_stock' ? 'checked' : ''} class="w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500">
                                    <span>Còn Hàng</span>
                                </div>
                                <span class="text-gray-400 font-mono">Có sẵn</span>
                            </label>
                        </div>
                    </div>

                    <!-- 5. Fruit Origin Filter -->
                    <div class="border-t border-gray-100 pt-5">
                        <div class="filter-section-title">Vùng Trồng / Xuất Xứ</div>
                        <div class="space-y-2 text-xs text-gray-700">
                            <label class="flex items-center justify-between cursor-pointer">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="origin" value="Đà Lạt" ${paramOrigin eq 'Đà Lạt' ? 'checked' : ''} class="text-emerald-700 focus:ring-emerald-500">
                                    <span>Đà Lạt - Lâm Đồng</span>
                                </div>
                            </label>
                            <label class="flex items-center justify-between cursor-pointer">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="origin" value="Miền Tây" ${paramOrigin eq 'Miền Tây' ? 'checked' : ''} class="text-emerald-700 focus:ring-emerald-500">
                                    <span>Miền Tây Nam Bộ</span>
                                </div>
                            </label>
                            <label class="flex items-center justify-between cursor-pointer">
                                <div class="flex items-center gap-2">
                                    <input type="radio" name="origin" value="Nhập Khẩu" ${paramOrigin eq 'Nhập Khẩu' ? 'checked' : ''} class="text-emerald-700 focus:ring-emerald-500">
                                    <span>Trái Cây Nhập Khẩu</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" class="w-full py-3 rounded-xl bg-emerald-800 hover:bg-emerald-900 text-white font-bold text-xs shadow-sm transition">
                        Áp Dụng Bộ Lọc
                    </button>
                </form>
            </aside>

            <!-- CỘT PHẢI: THANH CÔNG CỤ & LƯỚI SẢN PHẨM (CATALOG PRODUCT GRID) -->
            <div class="lg:col-span-3 space-y-5">
                
                <!-- SORTING & VIEW TOOLBAR -->
                <div class="flex flex-col sm:flex-row items-center justify-between gap-4 py-2 border-b border-gray-200/60 text-xs">
                    <div class="text-gray-600 font-medium">
                        <strong class="text-gray-900 font-bold">${totalProducts} Sản phẩm tươi sạch</strong> &bull; Sắp xếp theo độ tươi ngon
                    </div>

                    <div class="flex items-center gap-4">
                        <div class="flex items-center gap-2">
                            <span class="text-gray-500">Sắp xếp:</span>
                            <form action="${pageContext.request.contextPath}/products" method="GET" id="sortForm">
                                <input type="hidden" name="keyword" value="${paramKeyword}">
                                <select name="sortBy" onchange="document.getElementById('sortForm').submit();" class="bg-white border border-gray-200 rounded-lg px-3 py-1.5 text-xs font-semibold text-gray-800 focus:outline-none cursor-pointer">
                                    <option value="featured" ${paramSortBy eq 'featured' ? 'selected' : ''}>Nổi Bật Nhất</option>
                                    <option value="price_asc" ${paramSortBy eq 'price_asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                                    <option value="price_desc" ${paramSortBy eq 'price_desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                                    <option value="rating" ${paramSortBy eq 'rating' ? 'selected' : ''}>Đánh Giá Cao Nhất</option>
                                </select>
                            </form>
                        </div>

                        <!-- Grid / List Layout Switcher -->
                        <div class="flex items-center gap-1 border-l border-gray-200 pl-3 text-gray-400">
                            <button type="button" id="gridViewBtn" class="p-1 hover:text-gray-800 text-emerald-700" title="Dạng lưới"><i class="fa-solid fa-table-cells-large text-sm"></i></button>
                            <button type="button" id="listViewBtn" class="p-1 hover:text-gray-800" title="Dạng danh sách"><i class="fa-solid fa-list text-sm"></i></button>
                        </div>
                    </div>
                </div>

                <!-- 12 PRODUCT CARDS GRID -->
                <div id="productGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-5">
                    <c:choose>
                        <c:when test="${not empty listProducts}">
                            <c:forEach var="p" items="${listProducts}">
                                <div class="catalog-product-card group">
                                    <div>
                                        <!-- Image Wrap with Badges & Wishlist -->
                                        <div class="catalog-img-wrap">
                                            <a href="${pageContext.request.contextPath}/detail?id=${p.id}">
                                                <img src="${p.image}" alt="${p.name}">
                                            </a>

                                            <!-- Tag Badge: LOCAL, ORGANIC, SEASONAL, SUPER SWEET... -->
                                            <span class="card-badge-tag 
                                                <c:choose>
                                                    <c:when test="${p.tag eq 'HỮU CƠ' or p.tag eq 'ORGANIC'}">badge-tag-organic</c:when>
                                                    <c:when test="${p.tag eq 'ĐỊA PHƯƠNG' or p.tag eq 'LOCAL'}">badge-tag-local</c:when>
                                                    <c:when test="${p.tag.startsWith('-')}">badge-tag-sale</c:when>
                                                    <c:when test="${p.tag eq 'NGỌT THANH' or p.tag eq 'SUPER SWEET'}">badge-tag-sweet</c:when>
                                                    <c:otherwise>badge-tag-fresh</c:otherwise>
                                                </c:choose>">
                                                ${p.tag}
                                            </span>

                                            <!-- Heart Wishlist Button -->
                                            <button type="button" class="btn-wishlist" title="Lưu vào yêu thích">
                                                <i class="fa-regular fa-heart text-xs"></i>
                                            </button>
                                        </div>

                                        <!-- Rating & Review Count -->
                                        <div class="flex items-center gap-1.5 text-xs mb-1">
                                            <i class="fa-solid fa-star text-amber-400 text-[11px]"></i>
                                            <span class="font-extrabold text-gray-900">${p.rating}</span>
                                            <span class="text-gray-400 text-[11px]">(${p.reviewsCount})</span>
                                        </div>

                                        <!-- Product Name -->
                                        <h3 class="font-bold text-sm text-gray-900 line-clamp-1 group-hover:text-emerald-700 transition">
                                            <a href="${pageContext.request.contextPath}/detail?id=${p.id}">${p.name}</a>
                                        </h3>

                                        <!-- Origin Farm / Subtitle -->
                                        <p class="text-[11px] text-gray-400 truncate mt-0.5 mb-3">${p.origin}</p>
                                    </div>

                                    <!-- Price & Add Button -->
                                    <div class="pt-2 border-t border-gray-100/80 flex items-center justify-between">
                                        <div class="flex flex-col">
                                            <div class="flex items-baseline gap-1.5">
                                                <span class="font-black text-gray-900 text-sm">
                                                    <c:choose>
                                                        <c:when test="${p.price >= 1000}">
                                                            <fmt:formatNumber value="${p.price}" pattern="#,###" /> ₫
                                                        </c:when>
                                                        <c:otherwise>
                                                            $<fmt:formatNumber value="${p.price}" pattern="#,##0.00" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <c:if test="${p.oldPrice > p.price}">
                                                    <span class="text-[11px] text-gray-400 line-through">
                                                        <c:choose>
                                                            <c:when test="${p.oldPrice >= 1000}">
                                                                <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" /> ₫
                                                            </c:when>
                                                            <c:otherwise>
                                                                $<fmt:formatNumber value="${p.oldPrice}" pattern="#,##0.00" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </c:if>
                                            </div>
                                            <span class="text-[9px] font-extrabold tracking-wider text-gray-400 uppercase">/${not empty p.unit ? p.unit : 'kg'}</span>
                                        </div>

                                        <!-- Add Button -->
                                        <form action="${pageContext.request.contextPath}/add-to-cart" method="GET">
                                            <input type="hidden" name="productId" value="${p.id}">
                                            <button type="submit" class="btn-card-add">
                                                <i class="fa-solid fa-plus text-[10px]"></i>
                                                <span>Thêm</span>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-span-full py-16 text-center bg-white rounded-2xl border border-gray-100">
                                <i class="fa-solid fa-apple-whole text-4xl text-gray-300 mb-3"></i>
                                <h4 class="font-bold text-gray-800 text-sm">Không tìm thấy sản phẩm phù hợp</h4>
                                <p class="text-xs text-gray-500 mt-1">Hãy thử điều chỉnh lại bộ lọc hoặc từ khóa tìm kiếm của bạn.</p>
                                <a href="${pageContext.request.contextPath}/products" class="inline-block mt-3 px-4 py-2 bg-emerald-700 text-white rounded-xl text-xs font-bold">Xóa tất cả bộ lọc</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- PAGINATION BAR -->
                <c:if test="${totalPages > 1}">
                    <div class="pt-6 flex flex-col sm:flex-row items-center justify-between gap-4 border-t border-gray-100">
                        <span class="text-xs text-gray-500">
                            Hiển thị <strong>${(currentPage - 1) * pageSize + 1}-${currentPage * pageSize > totalProducts ? totalProducts : currentPage * pageSize}</strong> trên tổng <strong>${totalProducts}</strong> sản phẩm
                        </span>

                        <div class="flex items-center gap-1.5">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/products?page=${currentPage - 1}&keyword=${paramKeyword}&origin=${paramOrigin}&tag=${paramTag}&sortBy=${paramSortBy}" class="catalog-page-btn text-xs">
                                    <i class="fa-solid fa-chevron-left text-[10px] mr-1"></i> Trước
                                </a>
                            </c:if>

                            <c:forEach var="pageNum" begin="1" end="${totalPages}">
                                <c:choose>
                                    <c:when test="${pageNum == currentPage}">
                                        <span class="catalog-page-btn active text-xs font-bold">${pageNum}</span>
                                    </c:when>
                                    <c:when test="${pageNum <= 3 or pageNum == totalPages or (pageNum >= currentPage - 1 and pageNum <= currentPage + 1)}">
                                        <a href="${pageContext.request.contextPath}/products?page=${pageNum}&keyword=${paramKeyword}&origin=${paramOrigin}&tag=${paramTag}&sortBy=${paramSortBy}" class="catalog-page-btn text-xs">${pageNum}</a>
                                    </c:when>
                                    <c:when test="${pageNum == 4 and totalPages > 5 and currentPage > 3}">
                                        <span class="px-1 text-gray-400">...</span>
                                    </c:when>
                                </c:choose>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/products?page=${currentPage + 1}&keyword=${paramKeyword}&origin=${paramOrigin}&tag=${paramTag}&sortBy=${paramSortBy}" class="catalog-page-btn text-xs">
                                    Sau <i class="fa-solid fa-chevron-right text-[10px] ml-1"></i>
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:if>

            </div>
        </div>
    </main>

    <!-- FOOTER SECTION (FRESHFRUIT MARKETPLACE) -->
    <footer class="bg-white border-t border-gray-200/80 pt-14 pb-8 text-gray-600 text-xs">
        <div class="max-w-7xl mx-auto px-4">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 pb-12 border-b border-gray-100">
                <!-- Col 1: Brand Info -->
                <div class="lg:col-span-2 space-y-3">
                    <div class="flex items-center gap-2">
                        <div class="w-8 h-8 rounded-full bg-emerald-50 flex items-center justify-center p-1 border border-emerald-100">
                            <svg viewBox="0 0 100 100" class="w-full h-full">
                                <circle cx="50" cy="56" r="32" fill="#16a34a"/>
                                <path d="M 28 45 Q 36 34 50 34" stroke="#ffffff" stroke-width="6" stroke-linecap="round" fill="none"/>
                                <circle cx="68" cy="46" r="5" fill="#ffffff"/>
                                <path d="M 52 26 C 58 16 68 14 74 18 C 74 24 64 32 52 26 Z" fill="#f97316"/>
                            </svg>
                        </div>
                        <span class="text-xl font-black text-gray-900">Fresh<span class="text-emerald-700">Fruit</span></span>
                    </div>
                    <p class="text-gray-500 max-w-sm leading-relaxed">
                        Nền tảng cung cấp trái cây và nông sản tươi sạch chuẩn VietGAP, kết nối trực tiếp từ nông trại tới bàn ăn của gia đình bạn.
                    </p>
                    <div class="flex items-center gap-3 pt-2 text-gray-400">
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-solid fa-globe"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-brands fa-facebook-f"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-brands fa-instagram"></i></a>
                        <a href="#" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 flex items-center justify-center transition"><i class="fa-brands fa-tiktok"></i></a>
                    </div>
                </div>

                <!-- Col 2: Quick Links -->
                <div>
                    <h4 class="font-extrabold text-gray-900 text-sm mb-3">Liên Kết Nhanh</h4>
                    <ul class="space-y-2 text-gray-500">
                        <li><a href="${pageContext.request.contextPath}/home" class="hover:text-emerald-700 transition">Trang Chủ</a></li>
                        <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700 transition">Tất Cả Trái Cây</a></li>
                        <li><a href="${pageContext.request.contextPath}/deals" class="hover:text-emerald-700 transition">Khuyến Mãi Mùa Vụ</a></li>
                        <li><a href="${pageContext.request.contextPath}/products?tag=organic" class="hover:text-emerald-700 transition">Nông Sản Hữu Cơ</a></li>
                        <li><a href="${pageContext.request.contextPath}/products" class="hover:text-emerald-700 transition">Giỏ Quà Biếu Tặng</a></li>
                        <li><a href="${pageContext.request.contextPath}/wholesale" class="hover:text-emerald-700 transition">Bán Sỉ Doanh Nghiệp</a></li>
                    </ul>
                </div>

                <!-- Col 3: Customer Service -->
                <div>
                    <h4 class="font-extrabold text-gray-900 text-sm mb-3">Chăm Sóc Khách Hàng</h4>
                    <ul class="space-y-2 text-gray-500">
                        <li><a href="#" class="hover:text-emerald-700 transition">Hỏi Đáp & Trợ Giúp</a></li>
                        <li><a href="${pageContext.request.contextPath}/orders" class="hover:text-emerald-700 transition">Tra Cứu Đơn Hàng</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Chính Sách Vận Chuyển</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Chính Sách Đổi Trả</a></li>
                        <li><a href="#" class="hover:text-emerald-700 transition">Liên Hệ Khiếu Nại</a></li>
                    </ul>
                </div>

                <!-- Col 4: Contact & Payment -->
                <div>
                    <h4 class="font-extrabold text-gray-900 text-sm mb-3">Liên Hệ & Thanh Toán</h4>
                    <ul class="space-y-2 text-gray-500 mb-4">
                        <li class="flex items-center gap-2"><i class="fa-solid fa-phone text-emerald-700"></i> 1900 6868</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-envelope text-emerald-700"></i> support@freshfruit.vn</li>
                        <li class="flex items-center gap-2"><i class="fa-solid fa-location-dot text-emerald-700"></i> Lâm Đồng & TP. Hồ Chí Minh</li>
                    </ul>
                    <div class="text-[10px] font-extrabold uppercase text-gray-400 mb-2">Phương thức thanh toán</div>
                    <div class="flex items-center gap-2 text-xs font-bold text-gray-700">
                        <span class="px-2 py-1 bg-gray-100 rounded">VNPAY</span>
                        <span class="px-2 py-1 bg-gray-100 rounded">MOMO</span>
                        <span class="px-2 py-1 bg-gray-100 rounded">VISA</span>
                        <span class="px-2 py-1 bg-gray-100 rounded">COD</span>
                    </div>
                </div>
            </div>

            <div class="pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-gray-400 text-[11px]">
                <p>&copy; 2026 FreshFruit Marketplace. Đã đăng ký toàn bộ bản quyền.</p>
                <div class="flex items-center gap-5">
                    <a href="#" class="hover:underline">Chính Sách Bảo Mật</a>
                    <a href="#" class="hover:underline">Điều Khoản Dịch Vụ</a>
                    <a href="#" class="hover:underline">Sơ Đồ Trang Web</a>
                </div>
            </div>
        </div>
    </footer>

</body>
</html>
