<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tìm kiếm: ${txtSearch} - Gốc Vườn</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link rel="dns-prefetch" href="https://cdn.tailwindcss.com">
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Google Fonts Inter -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <!-- Custom Search CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/search-products.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/product-catalog.css">
        <!-- Tailwind CSS (Non-blocking) -->
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- Custom Search JS (Tailwind config) -->
        <script src="${pageContext.request.contextPath}/assets/js/search-products.js" defer></script>
    </head>
    <body class="bg-[#f8fafc] text-slate-800 font-sans antialiased selection:bg-emerald-600 selection:text-white">

        <!-- Header Đồng Bộ Cart -->
        <jsp:include page="/views/common/header.jsp" />

        <!-- Main Content Section: Search Results & Filter Sidebar -->
        <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
                
                <!-- CỘT TRÁI: BỘ LỌC TÌM KIẾM ĐỒNG BỘ VỚI TRANG PRODUCTS -->
                <aside class="lg:col-span-1">
                    <form action="${pageContext.request.contextPath}/search" method="GET" id="searchFilterForm" 
                          class="bg-white rounded-3xl p-5 sm:p-6 border border-slate-200/90 shadow-[0_4px_20px_rgba(0,0,0,0.03)] space-y-6">
                        
                        <!-- Giữ nguyên từ khóa tìm kiếm khi lọc -->
                        <input type="hidden" name="query" value="${txtSearch}" />

                        <!-- Filter Header -->
                        <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                            <div class="flex items-center gap-2.5">
                                <i class="fa-solid fa-sliders text-[#00652c] text-sm"></i>
                                <span class="font-extrabold text-base text-slate-900 tracking-tight">Bộ Lọc Tìm Kiếm</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/search?query=${txtSearch}" class="text-xs font-bold text-emerald-700 hover:text-emerald-800 hover:underline transition">
                                Thiết lập lại
                            </a>
                        </div>

                        <!-- 1. DANH MỤC SẢN PHẨM (DANH SÁCH PHẲNG) -->
                        <div>
                            <div class="flex items-center justify-between mb-3.5">
                                <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500">
                                    Danh Mục Sản Phẩm
                                </h4>
                                <span class="text-[10px] font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded-full">Tất cả</span>
                            </div>
                            <div class="space-y-2.5 text-xs max-h-72 overflow-y-auto pr-1">
                                <c:forEach var="cat" items="${listCategories}">
                                    <label class="flex items-center justify-between cursor-pointer group select-none py-0.5">
                                        <div class="flex items-center gap-2.5 min-w-0 pr-2">
                                            <input type="checkbox" name="category" value="${cat.categoryId}" 
                                                   ${selectedCategoriesList != null and (selectedCategoriesList.contains(cat.categoryId.toString()) or selectedCategoriesList.contains(cat.slug)) ? 'checked' : ''} 
                                                   class="custom-checkbox">
                                            <span class="text-xs font-medium text-slate-700 group-hover:text-emerald-700 transition truncate" title="${cat.categoryName}">
                                                ${cat.categoryName}
                                            </span>
                                        </div>
                                        <span class="text-xs font-bold ${cat.productCount > 0 ? 'text-emerald-700 bg-emerald-50' : 'text-slate-400 bg-slate-50'} font-mono shrink-0 px-2 py-0.5 rounded-full group-hover:bg-emerald-50 group-hover:text-emerald-700 transition">
                                            ${cat.productCount}
                                        </span>
                                    </label>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- 2. KHOẢNG GIÁ (2 ô nhập giá: từ ở trên đến ở dưới) -->
                        <div class="border-t border-slate-100 pt-5">
                            <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3">
                                Khoảng Giá (VNĐ)
                            </h4>

                            <!-- 2 ô nhập Từ (ở trên) - Đến (ở dưới) -->
                            <div class="space-y-2.5 text-xs">
                                <div class="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 focus-within:border-emerald-600 focus-within:bg-white transition">
                                    <span class="text-slate-400 text-xs font-semibold shrink-0 w-8">Từ:</span>
                                    <input type="number" id="inputMinPrice" name="minPrice" 
                                           placeholder="Từ 0đ"
                                           min="0"
                                           value="${paramMinPrice != null ? paramMinPrice : (minPrice != null ? minPrice : '')}" 
                                           class="w-full bg-transparent font-bold text-slate-800 focus:outline-none text-xs">
                                    <span class="text-xs text-slate-400 font-bold shrink-0">đ</span>
                                </div>
                                <div class="flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 focus-within:border-emerald-600 focus-within:bg-white transition">
                                    <span class="text-slate-400 text-xs font-semibold shrink-0 w-8">Đến:</span>
                                    <input type="number" id="inputMaxPrice" name="maxPrice" 
                                           placeholder="Đến mức tối đa"
                                           min="0"
                                           value="${paramMaxPrice != null ? paramMaxPrice : (maxPrice != null ? maxPrice : '')}" 
                                           class="w-full bg-transparent font-bold text-slate-800 focus:outline-none text-xs">
                                    <span class="text-xs text-slate-400 font-bold shrink-0">đ</span>
                                </div>
                            </div>
                        </div>

                        <!-- 3. TÌNH TRẠNG HÀNG -->
                        <div class="border-t border-slate-100 pt-5">
                            <h4 class="text-[11px] font-black uppercase tracking-wider text-slate-500 mb-3.5">
                                Tình Trạng Hàng
                            </h4>
                            <div class="space-y-2.5 text-xs">
                                <label class="flex items-center justify-between cursor-pointer group select-none">
                                    <div class="flex items-center gap-2.5">
                                        <input type="checkbox" name="availability" value="in_stock" 
                                               ${paramAvailability eq 'in_stock' or selectedAvailability eq 'in_stock' ? 'checked' : ''} 
                                               class="custom-checkbox">
                                        <span class="font-medium text-slate-700 group-hover:text-emerald-700 transition">Còn Hàng</span>
                                    </div>
                                    <span class="text-xs font-bold text-slate-400 font-mono px-2 py-0.5 rounded-full bg-slate-50">
                                        ${not empty inStockCount ? inStockCount : 0}
                                    </span>
                                </label>
                            </div>
                        </div>

                        <!-- NÚT ÁP DỤNG BỘ LỌC (MÀU XANH LÁ ĐẬM CHỦ ĐẠO #00652C) -->
                        <div class="pt-2">
                            <button type="submit" class="w-full py-3.5 bg-[#00652c] hover:bg-[#005323] text-white font-bold text-xs uppercase tracking-wider rounded-2xl shadow-md shadow-emerald-900/10 hover:shadow-lg transition-all duration-200 cursor-pointer flex items-center justify-center gap-2">
                                <i class="fa-solid fa-sliders text-xs"></i>
                                <span>Áp Dụng Bộ Lọc</span>
                            </button>
                        </div>
                    </form>
                </aside>

                <!-- CỘT PHẢI: KẾT QUẢ TÌM KIẾM & LƯỚI SẢN PHẨM -->
                <div class="lg:col-span-3 space-y-6">
                    <div class="bg-white p-5 rounded-3xl shadow-sm text-sm text-slate-700 border border-slate-200/90 flex items-center justify-between">
                        <div>Kết quả tìm kiếm cho từ khóa: <span class="font-extrabold text-[#00652c]">"${txtSearch}"</span>
                            <span class="text-xs text-slate-500 font-medium ml-1">(${totalProducts != null ? totalProducts : (not empty listProduct ? listProduct.size() : 0)} sản phẩm)</span>
                        </div>
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
<div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
    <c:choose>
        <c:when test="${not empty listProduct}">
            <c:forEach var="p" items="${listProduct}">
                <div class="bg-white rounded-3xl border border-gray-100 p-4 flex flex-col justify-between shadow-sm hover:shadow-xl hover:border-emerald-200 transition-all duration-300 group">
                    <div>
                        <!-- Khung ảnh sản phẩm có hiệu ứng phóng to và nhãn giảm giá -->
                        <div class="relative w-full h-48 rounded-2xl overflow-hidden bg-gray-50 border border-gray-100 mb-3.5 block">
                            <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="block w-full h-full">
                                <img src="${not empty p.image ? p.image : 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop'}" 
                                     alt="${p.name}" 
                                     onerror="this.src='https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&fit=crop';"
                                     class="w-full h-full object-cover group-hover:scale-108 transition-transform duration-500">
                            </a>
                            <c:if test="${p.discountPercent > 0}">
                                <span class="absolute top-3 left-3 bg-rose-500 text-white font-extrabold text-[10px] px-2.5 py-1 rounded-full shadow-md">
                                    -${p.discountPercent}%
                                </span>
                            </c:if>
                        </div>

                        <!-- Tên danh mục -->
                        <span class="text-[11px] font-extrabold text-emerald-600 uppercase tracking-wider">
                            ${not empty p.categoryName ? p.categoryName : 'Trái Cây Tươi'}
                        </span>

                        <!-- Tên sản phẩm giới hạn 2 dòng -->
                        <h3 class="font-bold text-sm text-gray-900 mt-1 mb-2 line-clamp-2 h-10 leading-snug">
                            <a href="${pageContext.request.contextPath}/detail?id=${p.id}" class="hover:text-emerald-600 transition-colors">
                                ${p.name}
                            </a>
                        </h3>

                        <!-- Đánh giá sao -->
                        <div class="flex items-center gap-1 text-xs text-amber-400 mb-3">
                            <i class="fa-solid fa-star"></i>
                            <span class="font-bold text-gray-700"><fmt:formatNumber value="${not empty p.rating ? p.rating : 5.0}" pattern="#0.0"/></span>
                            <c:if test="${not empty p.reviewsCount and p.reviewsCount > 0}">
                                <span class="text-gray-400 text-[11px]">(${p.reviewsCount})</span>
                            </c:if>
                        </div>
                    </div>

                    <!-- Phần giá và nút thêm giỏ hàng ở đáy card -->
                    <div class="pt-3 border-t border-gray-100 flex items-center justify-between mt-auto">
                        <div>
                            <span class="text-emerald-600 font-extrabold text-base">
                                <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                            </span>
                            <c:if test="${p.oldPrice gt p.price}">
                                <span class="text-gray-400 text-xs line-through block font-medium">
                                    <fmt:formatNumber value="${p.oldPrice}" pattern="#,###" />đ
                                </span>
                            </c:if>
                        </div>
                        
                        <form action="${pageContext.request.contextPath}/cart/add" method="POST">
                            <input type="hidden" name="csrfToken" value="${sessionScope.cartCsrfToken}" />
                            <input type="hidden" name="variantId" value="${p.defaultVariantId}" />
                            <input type="hidden" name="quantity" value="1" />
                            <button type="submit" ${p.defaultVariantId le 0 ? 'disabled' : ''} class="w-10 h-10 bg-emerald-50 hover:bg-emerald-600 disabled:bg-gray-100 disabled:text-gray-300 disabled:cursor-not-allowed text-emerald-600 hover:text-white rounded-2xl flex items-center justify-center transition-all shadow-xs" title="${p.defaultVariantId gt 0 ? 'Thêm vào giỏ hàng' : 'Sản phẩm đã hết hàng'}">
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

        <!-- Footer Chuẩn Đồng Bộ Website Gốc Vườn -->
        <jsp:include page="/views/common/site-footer.jsp" />
    </body>
</html>
